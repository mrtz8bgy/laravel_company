<?php

declare(strict_types=1);

namespace App\Modules\Hr\Services;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Hr\Models\HrProfile;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\CompanyMembership;

class HrVisibility
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function canSeeSensitive(User $actor): bool
    {
        return $this->authorization->allows($actor, PermissionCatalog::HR_SALARY_VIEW);
    }

    /**
     * Own card. Salary and national id are never included, even for HR.
     *
     * @return array<string, mixed>
     */
    public function own(User $user): array
    {
        $profile = HrProfile::query()->where('user_id', $user->id)->first();
        $membership = $this->membership($user);

        return [
            'user' => ['uuid' => $user->uuid, 'name' => $user->name, 'email' => $user->email],
            'job_title' => $membership?->job_title,
            'employee_code' => $membership?->employee_code,
            'employment_type' => $profile?->employment_type,
            'hire_date' => $profile?->hire_date?->toDateString(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function profile(User $actor, User $subject, ?HrProfile $profile): array
    {
        $membership = $this->membership($subject);
        $payload = [
            'user' => ['uuid' => $subject->uuid, 'name' => $subject->name, 'email' => $subject->email],
            'job_title' => $membership?->job_title,
            'employee_code' => $membership?->employee_code,
            'employment_type' => $profile?->employment_type,
            'hire_date' => $profile?->hire_date?->toDateString(),
            'emergency_name' => $profile?->emergency_name,
            'emergency_phone' => $profile?->emergency_phone,
            'notes' => $profile?->notes,
        ];

        if ($this->canSeeSensitive($actor)) {
            $payload['national_id'] = $profile?->national_id;
            $payload['salary_amount'] = $profile?->salary_amount;
            $payload['salary_currency'] = $profile?->salary_currency;
        }

        return $payload;
    }

    private function membership(User $user): ?CompanyMembership
    {
        return CompanyMembership::query()
            ->where('company_id', tenantId())
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->first();
    }
}
