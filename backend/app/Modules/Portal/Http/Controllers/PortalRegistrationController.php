<?php

declare(strict_types=1);

namespace App\Modules\Portal\Http\Controllers;

use App\Core\Support\ApiResponse;
use App\Core\Support\TenantContext;
use App\Http\Controllers\Controller;
use App\Modules\Auth\Actions\AuthPayload;
use App\Modules\Auth\Actions\IssueToken;
use App\Modules\Organizations\Models\Company;
use App\Modules\Portal\Actions\RegisterCustomer;
use App\Modules\Portal\Http\Resources\CustomerResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;

class PortalRegistrationController extends Controller
{
    public function __construct(
        private readonly RegisterCustomer $register,
        private readonly IssueToken $issueToken,
        private readonly AuthPayload $payload,
        private readonly TenantContext $tenant,
    ) {}

    public function company(string $slug): JsonResponse
    {
        $company = Company::query()->where('slug', $slug)->where('status', 'active')->first();
        if (! $company) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        return ApiResponse::success([
            'name' => $company->name,
            'slug' => $company->slug,
        ]);
    }

    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'company_slug' => ['required', 'string', 'max:80'],
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190'],
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()],
            'phone' => ['nullable', 'string', 'max:32'],
            'organization_name' => ['nullable', 'string', 'max:160'],
        ]);

        $company = Company::query()->where('slug', $data['company_slug'])->first();
        if (! $company) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        try {
            $created = $this->register->handle($company, $data);
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invalid'), 422, $exception->errors());
        }

        $this->tenant->set($company);
        $issued = $this->issueToken->handle($created['user'], $company, $request, 'LOGIN');
        $session = $this->payload->make($created['user'], $company, $issued['token']);
        $session['customer'] = (new CustomerResource($created['customer']))->resolve();

        return ApiResponse::success($session, __('messages.portal_registered'), 201);
    }
}
