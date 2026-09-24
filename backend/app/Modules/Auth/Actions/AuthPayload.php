<?php

declare(strict_types=1);

namespace App\Modules\Auth\Actions;

use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Http\Resources\UserResource;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Http\Resources\CompanyResource;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Feature;

class AuthPayload
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    /**
     * @return array<string, mixed>
     */
    public function make(User $user, ?Company $company, ?string $token = null): array
    {
        $user->loadMissing([
            'memberships' => fn ($query) => $company
                ? $query->where('company_id', $company->id)
                : $query,
            'roles' => fn ($query) => $query->withoutGlobalScope('company')->when(
                $company,
                fn ($roles) => $roles->where('roles.company_id', $company->id)->where('user_roles.company_id', $company->id),
            ),
            'teams' => fn ($query) => $query->withoutGlobalScope('company')->when(
                $company,
                fn ($teams) => $teams->where('teams.company_id', $company->id),
            ),
        ]);

        $payload = [
            'user' => (new UserResource($user))->resolve(),
            'company' => $company ? (new CompanyResource($company))->resolve() : null,
            'roles' => $user->roles->map(fn ($role) => [
                'uuid' => $role->uuid,
                'name' => $role->name,
                'slug' => $role->slug,
            ])->values()->all(),
            'permissions' => $company ? $this->authorization->permissionsFor($user, $company) : [],
            'features' => $company
                ? (object) Feature::query()->withoutGlobalScope('company')->where('company_id', $company->id)->pluck('enabled', 'key')->all()
                : (object) [],
            'onboarding' => $company?->onboardingState(),
            'is_platform_admin' => $user->is_platform_admin,
        ];

        if ($token !== null) {
            $payload = ['token' => $token, 'token_type' => 'Bearer'] + $payload;
        }

        return $payload;
    }
}
