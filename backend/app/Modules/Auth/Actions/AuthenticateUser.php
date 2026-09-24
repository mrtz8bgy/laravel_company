<?php

declare(strict_types=1);

namespace App\Modules\Auth\Actions;

use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\CompanyMembership;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthenticateUser
{
    public function __construct(private readonly IssueToken $issueToken) {}

    /**
     * @return array<string, mixed>
     */
    public function handle(string $email, string $password, ?string $companyUuid, Request $request): array
    {
        $user = User::query()->where('email', strtolower(trim($email)))->first();

        if (! $user || ! Hash::check($password, $user->password)) {
            throw new AuthenticationException(__('auth.failed'));
        }

        if (! $user->isActive()) {
            throw new AuthenticationException(__('auth.inactive'));
        }

        $memberships = CompanyMembership::query()
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->with('company')
            ->get()
            ->filter(fn (CompanyMembership $membership) => $membership->company?->isActive());

        if ($companyUuid) {
            $company = Company::query()->where('uuid', $companyUuid)->first();
            if (! $company || ! $company->isActive()) {
                throw new AuthenticationException(__('auth.failed'));
            }
            $this->assertCanEnter($user, $company, $memberships);

            return ['requires_company' => false, 'user' => $user, 'company' => $company, 'issued' => $this->issueToken->handle($user, $company, $request)];
        }

        if ($memberships->count() === 1) {
            $company = $memberships->first()->company;

            return ['requires_company' => false, 'user' => $user, 'company' => $company, 'issued' => $this->issueToken->handle($user, $company, $request)];
        }

        if ($memberships->isEmpty() && $user->is_platform_admin) {
            return ['requires_company' => false, 'user' => $user, 'company' => null, 'issued' => $this->issueToken->handle($user, null, $request)];
        }

        if ($memberships->isEmpty()) {
            throw new AuthenticationException(__('auth.no_company'));
        }

        return [
            'requires_company' => true,
            'user' => $user,
            'company' => null,
            'companies' => $memberships->map(fn (CompanyMembership $membership) => [
                'uuid' => $membership->company->uuid,
                'name' => $membership->company->name,
                'job_title' => $membership->job_title,
            ])->values()->all(),
        ];
    }

    /**
     * @param  \Illuminate\Support\Collection<int, CompanyMembership>  $memberships
     */
    private function assertCanEnter(User $user, Company $company, $memberships): void
    {
        if ($user->is_platform_admin) {
            return;
        }

        $match = $memberships->first(fn (CompanyMembership $membership) => $membership->company_id === $company->id);
        if (! $match) {
            throw new AuthenticationException(__('auth.failed'));
        }
    }
}
