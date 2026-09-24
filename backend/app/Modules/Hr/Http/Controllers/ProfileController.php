<?php

declare(strict_types=1);

namespace App\Modules\Hr\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Hr\Models\HrProfile;
use App\Modules\Hr\Services\HrVisibility;
use App\Modules\Identity\Models\User;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function __construct(
        private readonly HrVisibility $visibility,
        private readonly AuthorizationService $authorization,
        private readonly ActivityLogger $activity,
    ) {}

    public function me(Request $request): JsonResponse
    {
        return ApiResponse::success($this->visibility->own($this->user($request)));
    }

    public function show(Request $request, User $user): JsonResponse
    {
        $this->assertColleague($user);
        $profile = HrProfile::query()->where('user_id', $user->id)->first();

        return ApiResponse::success($this->visibility->profile($this->user($request), $user, $profile));
    }

    public function update(Request $request, User $user): JsonResponse
    {
        $this->assertColleague($user);
        $data = $request->validate([
            'employment_type' => ['sometimes', 'nullable', 'in:full_time,part_time,contract,intern'],
            'hire_date' => ['sometimes', 'nullable', 'date'],
            'emergency_name' => ['sometimes', 'nullable', 'string', 'max:120'],
            'emergency_phone' => ['sometimes', 'nullable', 'string', 'max:32'],
            'notes' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'national_id' => ['sometimes', 'nullable', 'string', 'max:32'],
            'salary_amount' => ['sometimes', 'nullable', 'integer', 'min:0'],
            'salary_currency' => ['sometimes', 'nullable', 'string', 'size:3'],
        ]);

        $sensitive = array_intersect_key($data, array_flip(['national_id', 'salary_amount', 'salary_currency']));
        if ($sensitive !== [] && ! $this->authorization->allows($this->user($request), PermissionCatalog::HR_SALARY_VIEW)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }

        $profile = HrProfile::query()->firstOrNew(['user_id' => $user->id]);
        $profile->fill($data)->save();
        $this->activity->log('UPDATE', $profile, null, array_diff_key($data, array_flip([
            'national_id',
            'salary_amount',
            'salary_currency',
            'emergency_name',
            'emergency_phone',
            'notes',
        ])));

        return ApiResponse::success(
            $this->visibility->profile($this->user($request), $user, $profile->fresh()),
            __('messages.updated'),
        );
    }

    private function assertColleague(User $user): void
    {
        $active = $user->memberships()->where('company_id', tenantId())->where('status', 'active')->exists();
        if (! $active) {
            throw (new ModelNotFoundException())->setModel(User::class);
        }
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
