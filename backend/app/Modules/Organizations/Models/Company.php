<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Models;

use App\Core\Models\Concerns\HasUuid;
use App\Modules\Access\Models\Role;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Company extends Model
{
    use HasUuid;

    protected $fillable = [
        'uuid',
        'name',
        'legal_name',
        'slug',
        'status',
        'timezone',
        'locale',
        'logo_path',
        'plan',
        'user_limit',
        'settings',
        'onboarded_at',
    ];

    protected function casts(): array
    {
        return [
            'settings' => 'array',
            'onboarded_at' => 'datetime',
            'user_limit' => 'integer',
        ];
    }

    public function memberships(): HasMany
    {
        return $this->hasMany(CompanyMembership::class);
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'company_user')
            ->withPivot(['job_title', 'employee_code', 'status', 'is_owner', 'department_id', 'joined_at'])
            ->withTimestamps();
    }

    public function departments(): HasMany
    {
        return $this->hasMany(Department::class);
    }

    public function teams(): HasMany
    {
        return $this->hasMany(Team::class);
    }

    public function roles(): HasMany
    {
        return $this->hasMany(Role::class);
    }

    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    /**
     * @return array<string, bool>
     */
    public function onboardingState(): array
    {
        $state = $this->settings['onboarding'] ?? [];

        return [
            'departments' => (bool) ($state['departments'] ?? false),
            'teams' => (bool) ($state['teams'] ?? false),
            'invites' => (bool) ($state['invites'] ?? false),
            'schedule' => (bool) ($state['schedule'] ?? false),
            'completed' => $this->onboarded_at !== null,
        ];
    }
}
