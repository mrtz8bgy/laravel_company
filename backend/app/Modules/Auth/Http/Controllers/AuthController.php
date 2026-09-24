<?php

declare(strict_types=1);

namespace App\Modules\Auth\Http\Controllers;

use App\Core\Http\Resources\LoginSessionResource;
use App\Core\Models\LoginSession;
use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Core\Support\TenantContext;
use App\Http\Controllers\Controller;
use App\Modules\Auth\Actions\AcceptInvitation;
use App\Modules\Auth\Actions\AuthPayload;
use App\Modules\Auth\Actions\AuthenticateUser;
use App\Modules\Auth\Actions\IssueToken;
use App\Modules\Auth\Http\Requests\LoginRequest;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\Rules\Password as PasswordRule;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(
        private readonly AuthenticateUser $authenticate,
        private readonly AuthPayload $payload,
        private readonly AcceptInvitation $acceptInvitation,
        private readonly IssueToken $issueToken,
        private readonly ActivityLogger $activity,
        private readonly TenantContext $tenant,
    ) {}

    public function login(LoginRequest $request): JsonResponse
    {
        try {
            $result = $this->authenticate->handle(
                $request->string('email')->toString(),
                $request->string('password')->toString(),
                $request->input('company_uuid'),
                $request,
            );
        } catch (AuthenticationException $exception) {
            return ApiResponse::error($exception->getMessage() ?: __('auth.failed'), 401);
        }

        if ($result['requires_company']) {
            return ApiResponse::success([
                'requires_company' => true,
                'companies' => $result['companies'],
            ], __('messages.choose_company'));
        }

        if ($result['company']) {
            $this->tenant->set($result['company']);
        }

        return ApiResponse::success(
            $this->payload->make($result['user'], $result['company'], $result['issued']['token']),
            __('messages.welcome'),
        );
    }

    public function me(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $company = $this->companyFromToken($user);
        if ($company) {
            $this->tenant->set($company);
        }

        return ApiResponse::success($this->payload->make($user, $company));
    }

    public function logout(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $token = $user->currentAccessToken();
        $this->closeSession($user, $token?->id);
        $token?->delete();
        $this->activity->log('LOGOUT', $user, null, null, null, $token?->company_id, $user->id);

        return ApiResponse::success(null, __('messages.logged_out'));
    }

    public function logoutAll(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $user->tokens()->delete();
        LoginSession::query()
            ->where('user_id', $user->id)
            ->whereNull('logged_out_at')
            ->update(['logged_out_at' => now()]);
        $this->activity->log('LOGOUT', $user, null, ['all' => true], 'All sessions revoked', null, $user->id);

        return ApiResponse::success(null, __('messages.logged_out'));
    }

    public function sessions(Request $request): JsonResponse
    {
        $sessions = LoginSession::query()
            ->where('user_id', $request->user()->id)
            ->latest('logged_in_at')
            ->limit(20)
            ->get();

        return ApiResponse::success(LoginSessionResource::collection($sessions)->resolve());
    }

    public function revokeSession(Request $request, string $session): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $record = LoginSession::query()
            ->where('user_id', $user->id)
            ->where('uuid', $session)
            ->first();

        if (! $record) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        if ($record->token_id) {
            $user->tokens()->where('id', $record->token_id)->delete();
        }
        $record->forceFill(['logged_out_at' => now()])->save();

        return ApiResponse::success(null, __('messages.session_revoked'));
    }

    public function switchCompany(Request $request): JsonResponse
    {
        $data = $request->validate([
            'company_uuid' => ['required', 'uuid'],
        ]);

        /** @var User $user */
        $user = $request->user();
        $company = Company::query()->where('uuid', $data['company_uuid'])->first();
        if (! $company || ! $company->isActive()) {
            return ApiResponse::error(__('auth.company_unavailable'), 403);
        }

        if (! $user->is_platform_admin && ! $user->belongsToCompany($company)) {
            return ApiResponse::error(__('auth.forbidden'), 403);
        }

        $current = $user->currentAccessToken();
        $this->closeSession($user, $current?->id);
        $current?->delete();

        $this->tenant->set($company);
        $issued = $this->issueToken->handle($user, $company, $request, 'LOGIN');

        return ApiResponse::success($this->payload->make($user, $company, $issued['token']));
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate(['email' => ['required', 'email']]);

        try {
            Password::sendResetLink(['email' => strtolower(trim((string) $request->input('email')))]);
        } catch (\Throwable $exception) {
            report($exception);
        }

        return ApiResponse::success(null, __('messages.reset_sent'));
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $request->validate([
            'token' => ['required', 'string'],
            'email' => ['required', 'email'],
            'password' => ['required', 'confirmed', PasswordRule::min(8)->mixedCase()->numbers()->symbols()],
        ]);

        $status = Password::reset(
            [
                'email' => strtolower(trim((string) $request->input('email'))),
                'password' => $request->input('password'),
                'password_confirmation' => $request->input('password_confirmation'),
                'token' => $request->input('token'),
            ],
            function (User $user, string $password): void {
                $user->forceFill(['password' => $password])->save();
                $user->tokens()->delete();
            },
        );

        if ($status !== Password::PASSWORD_RESET) {
            return ApiResponse::error(__('messages.reset_invalid'), 422);
        }

        return ApiResponse::success(null, __('messages.reset_done'));
    }

    public function acceptInvite(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'min:32'],
            'name' => ['required', 'string', 'max:120'],
            'password' => ['required', 'confirmed', PasswordRule::min(8)->mixedCase()->numbers()->symbols()],
        ]);

        try {
            $result = $this->acceptInvitation->handle($data, $request);
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invite_invalid'), 422, $exception->errors());
        }

        $this->tenant->set($result['company']);

        return ApiResponse::success(
            $this->payload->make($result['user'], $result['company'], $result['issued']['token']),
            __('messages.welcome'),
        );
    }

    private function companyFromToken(User $user): ?Company
    {
        $companyId = $user->currentAccessToken()?->company_id;
        if (! $companyId) {
            return null;
        }

        return Company::query()->find($companyId);
    }

    private function closeSession(User $user, ?int $tokenId): void
    {
        if (! $tokenId) {
            return;
        }

        LoginSession::query()
            ->where('user_id', $user->id)
            ->where('token_id', $tokenId)
            ->whereNull('logged_out_at')
            ->update(['logged_out_at' => now()]);
    }
}
