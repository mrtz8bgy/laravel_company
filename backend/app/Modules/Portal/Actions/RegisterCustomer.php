<?php

declare(strict_types=1);

namespace App\Modules\Portal\Actions;

use App\Core\Services\ActivityLogger;
use App\Core\Support\TenantContext;
use App\Modules\Identity\Actions\MembershipService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Feature;
use App\Modules\Portal\Models\Customer;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class RegisterCustomer
{
    public function __construct(
        private readonly MembershipService $memberships,
        private readonly ActivityLogger $activity,
        private readonly TenantContext $tenant,
    ) {}

    /**
     * @param  array{name: string, email: string, password: string, phone?: string|null, organization_name?: string|null}  $input
     * @return array{user: User, customer: Customer}
     */
    public function handle(Company $company, array $input): array
    {
        $this->assertOpen($company);
        $email = strtolower(trim($input['email']));

        if (User::query()->where('email', $email)->exists()) {
            throw ValidationException::withMessages([
                'email' => [__('messages.email_taken')],
            ]);
        }

        return DB::transaction(function () use ($company, $input, $email): array {
            $this->tenant->set($company);

            $user = User::query()->create([
                'name' => $input['name'],
                'email' => $email,
                'phone' => $input['phone'] ?? null,
                'password' => $input['password'],
                'locale' => $company->locale ?: 'fa',
                'timezone' => $company->timezone ?: 'Asia/Tehran',
                'status' => 'active',
                'email_verified_at' => now(),
            ]);

            $this->memberships->attach($company, $user, [
                'job_title' => 'مشتری',
                'status' => 'pending',
                'joined_at' => null,
            ], ['client']);

            $customer = Customer::query()->create([
                'user_id' => $user->id,
                'status' => Customer::PENDING,
                'organization_name' => $input['organization_name'] ?? null,
                'phone' => $input['phone'] ?? null,
            ]);

            $this->activity->log('CREATE', $customer, null, [
                'email' => $user->email,
                'status' => Customer::PENDING,
            ], 'Customer registered');

            return ['user' => $user, 'customer' => $customer];
        });
    }

    private function assertOpen(Company $company): void
    {
        if (! $company->isActive()) {
            throw ValidationException::withMessages([
                'company' => [__('auth.company_unavailable')],
            ]);
        }

        $enabled = Feature::query()
            ->withoutGlobalScope('company')
            ->where('company_id', $company->id)
            ->where('key', 'portal')
            ->value('enabled');

        if (! $enabled) {
            throw ValidationException::withMessages([
                'company' => [__('messages.feature_disabled')],
            ]);
        }
    }
}
