<?php

declare(strict_types=1);

namespace App\Modules\Auth\Actions;

use App\Core\Support\TenantContext;
use App\Modules\Access\Models\Role;
use App\Modules\Identity\Actions\MembershipService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Invitation;
use App\Modules\Organizations\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AcceptInvitation
{
    public function __construct(
        private readonly MembershipService $memberships,
        private readonly IssueToken $issueToken,
        private readonly TenantContext $tenant,
    ) {}

    /**
     * @param  array{token: string, name: string, password: string}  $input
     * @return array{user: User, company: \App\Modules\Organizations\Models\Company, issued: array{token: string, session: \App\Core\Models\LoginSession}}
     */
    public function handle(array $input, Request $request): array
    {
        $invitation = Invitation::query()
            ->withoutGlobalScope('company')
            ->where('token', hash('sha256', $input['token']))
            ->first();

        if (! $invitation || $invitation->accepted_at !== null || $invitation->expires_at->isPast()) {
            throw ValidationException::withMessages([
                'token' => [__('messages.invite_invalid')],
            ]);
        }

        $company = $invitation->company()->firstOrFail();
        if (! $company->isActive()) {
            throw ValidationException::withMessages([
                'token' => [__('auth.company_unavailable')],
            ]);
        }

        return DB::transaction(function () use ($invitation, $input, $request, $company): array {
            $this->tenant->set($company);

            $user = User::query()->where('email', $invitation->email)->first();
            if (! $user) {
                $user = User::query()->create([
                    'name' => $input['name'] ?: ($invitation->name ?: 'Member'),
                    'email' => $invitation->email,
                    'password' => $input['password'],
                    'locale' => $company->locale,
                    'timezone' => $company->timezone,
                    'status' => 'active',
                    'email_verified_at' => now(),
                ]);
            } elseif ($user->status !== 'active') {
                throw ValidationException::withMessages([
                    'token' => [__('auth.inactive')],
                ]);
            }

            $roleSlug = null;
            if ($invitation->role_id) {
                $roleSlug = Role::query()->withoutGlobalScope('company')->find($invitation->role_id)?->slug;
            }

            if (! $user->memberships()->where('company_id', $company->id)->exists()) {
                $this->memberships->attach($company, $user, [
                    'department_id' => $invitation->department_id,
                    'status' => 'active',
                ], $roleSlug ? [$roleSlug] : ['employee']);
            }

            if ($invitation->team_id) {
                $team = Team::query()->withoutGlobalScope('company')->find($invitation->team_id);
                $team?->members()->syncWithoutDetaching([$user->id => ['role' => 'member']]);
            }

            $invitation->forceFill(['accepted_at' => now()])->save();

            return [
                'user' => $user,
                'company' => $company,
                'issued' => $this->issueToken->handle($user, $company, $request, 'LOGIN'),
            ];
        });
    }
}
