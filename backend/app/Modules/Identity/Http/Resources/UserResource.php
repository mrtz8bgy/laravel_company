<?php

declare(strict_types=1);

namespace App\Modules\Identity\Http\Resources;

use App\Core\Support\TenantContext;
use App\Modules\Organizations\Models\CompanyMembership;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Identity\Models\User */
class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $companyId = app(TenantContext::class)->id();
        /** @var CompanyMembership|null $membership */
        $membership = $this->memberships->first(function (CompanyMembership $item) use ($companyId) {
            return $companyId === null || $item->company_id === $companyId;
        });

        return [
            'uuid' => $this->uuid,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'locale' => $this->locale,
            'timezone' => $this->timezone,
            'status' => $this->status,
            'job_title' => $membership?->job_title,
            'employee_code' => $membership?->employee_code,
            'membership_status' => $membership?->status,
            'is_owner' => (bool) $membership?->is_owner,
            'department' => $this->when(
                $membership?->relationLoaded('department') && $membership->department,
                fn () => [
                    'uuid' => $membership->department->uuid,
                    'name' => $membership->department->name,
                    'slug' => $membership->department->slug,
                ],
            ),
            'roles' => $this->whenLoaded('roles', fn () => $this->roles->map(fn ($role) => [
                'uuid' => $role->uuid,
                'name' => $role->name,
                'slug' => $role->slug,
            ])->values()),
            'teams' => $this->whenLoaded('teams', fn () => $this->teams->map(fn ($team) => [
                'uuid' => $team->uuid,
                'name' => $team->name,
                'role' => $team->pivot->role,
            ])->values()),
            'last_login_at' => $this->last_login_at?->toIso8601String(),
        ];
    }
}
