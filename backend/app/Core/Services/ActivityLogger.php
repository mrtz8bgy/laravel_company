<?php

declare(strict_types=1);

namespace App\Core\Services;

use App\Core\Models\ActivityLog;
use App\Core\Support\TenantContext;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Arr;

class ActivityLogger
{
    /**
     * @var list<string>
     */
    private array $redacted = [
        'password',
        'remember_token',
        'two_factor_secret',
        'two_factor_recovery_codes',
        'token',
        'national_id',
        'salary_amount',
        'salary_currency',
        'emergency_name',
        'emergency_phone',
        'amount',
        'budget_amount',
    ];

    /**
     * @param  array<string, mixed>|null  $old
     * @param  array<string, mixed>|null  $new
     */
    public function log(
        string $action,
        ?Model $entity = null,
        ?array $old = null,
        ?array $new = null,
        ?string $description = null,
        ?int $companyId = null,
        ?int $userId = null,
    ): ActivityLog {
        $request = request();

        return ActivityLog::query()->create([
            'company_id' => $companyId ?? app(TenantContext::class)->id() ?? $entity?->getAttribute('company_id'),
            'user_id' => $userId ?? $request->user()?->id,
            'action' => $action,
            'entity_type' => $entity?->getMorphClass(),
            'entity_id' => $entity?->getKey(),
            'entity_uuid' => $entity?->getAttribute('uuid'),
            'description' => $description,
            'old_values' => $this->clean($old),
            'new_values' => $this->clean($new),
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent() ? mb_substr((string) $request->userAgent(), 0, 1000) : null,
            'created_at' => now(),
        ]);
    }

    /**
     * @param  array<string, mixed>|null  $values
     * @return array<string, mixed>|null
     */
    private function clean(?array $values): ?array
    {
        if ($values === null) {
            return null;
        }

        return Arr::except($values, $this->redacted);
    }
}
