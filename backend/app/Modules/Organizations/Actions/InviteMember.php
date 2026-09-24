<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Actions;

use App\Core\Services\ActivityLogger;
use App\Core\Support\TenantContext;
use App\Modules\Access\Models\Role;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Invitation;
use App\Modules\Organizations\Models\Team;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class InviteMember
{
    public function __construct(
        private readonly ActivityLogger $activity,
        private readonly TenantContext $tenant,
    ) {}

    /**
     * @param  array<string, mixed>  $input
     * @return array{invitation: Invitation, accept_url: string}
     */
    public function handle(array $input, User $actor): array
    {
        $company = $this->tenant->check();
        $email = strtolower(trim((string) $input['email']));

        $pending = Invitation::query()
            ->where('email', $email)
            ->whereNull('accepted_at')
            ->where('expires_at', '>', now())
            ->exists();

        if ($pending) {
            throw ValidationException::withMessages([
                'email' => [__('messages.invite_pending')],
            ]);
        }

        $role = null;
        if (! empty($input['role_uuid'])) {
            $role = Role::query()->where('uuid', $input['role_uuid'])->first();
            if (! $role) {
                throw ValidationException::withMessages(['role_uuid' => [__('messages.not_found')]]);
            }
        }

        $department = null;
        if (! empty($input['department_uuid'])) {
            $department = Department::query()->where('uuid', $input['department_uuid'])->first();
            if (! $department) {
                throw ValidationException::withMessages(['department_uuid' => [__('messages.not_found')]]);
            }
        }

        $team = null;
        if (! empty($input['team_uuid'])) {
            $team = Team::query()->where('uuid', $input['team_uuid'])->first();
            if (! $team) {
                throw ValidationException::withMessages(['team_uuid' => [__('messages.not_found')]]);
            }
        }

        $raw = Str::random(64);
        $invitation = Invitation::query()->create([
            'email' => $email,
            'name' => $input['name'] ?? null,
            'role_id' => $role?->id,
            'department_id' => $department?->id,
            'team_id' => $team?->id,
            'token' => hash('sha256', $raw),
            'invited_by' => $actor->id,
            'expires_at' => now()->addHours((int) config('vcos.invitation_ttl_hours')),
        ]);

        $acceptUrl = rtrim((string) config('vcos.frontend_url'), '/').'/accept-invite?token='.$raw;
        $locale = $company->locale === 'fa' ? 'fa' : 'en';
        $body = $locale === 'fa'
            ? "به {$company->name} دعوت شده‌اید.\nبرای پذیرش دعوت این پیوند را باز کنید:\n{$acceptUrl}"
            : "You have been invited to {$company->name}.\nAccept the invitation:\n{$acceptUrl}";

        Mail::raw($body, function ($message) use ($email, $company): void {
            $message->to($email)->subject($company->locale === 'fa' ? 'دعوت به شرکت' : 'Company invitation');
        });

        $this->activity->log('CREATE', $invitation, null, ['email' => $email], 'Invitation sent');

        return ['invitation' => $invitation, 'accept_url' => $acceptUrl];
    }
}
