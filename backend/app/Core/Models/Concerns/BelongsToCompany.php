<?php

declare(strict_types=1);

namespace App\Core\Models\Concerns;

use App\Core\Support\TenantContext;
use App\Modules\Organizations\Models\Company;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use RuntimeException;

/**
 * Fail-closed tenant scope.
 *
 * If no company is bound to the request, queries return no rows.
 * This is intentional: a missing tenant must never fall open.
 */
trait BelongsToCompany
{
    public static function bootBelongsToCompany(): void
    {
        static::addGlobalScope('company', function (Builder $builder): void {
            $companyId = static::resolveTenantCompanyId();
            $column = $builder->getModel()->getTable().'.company_id';

            if ($companyId === null) {
                $builder->whereRaw('1 = 0');

                return;
            }

            $builder->where($column, $companyId);
        });

        static::creating(function (Model $model): void {
            if (! empty($model->getAttribute('company_id'))) {
                return;
            }

            $companyId = app(TenantContext::class)->id();
            if ($companyId === null) {
                throw new RuntimeException('Company context is required to create '.class_basename($model).'.');
            }

            $model->setAttribute('company_id', $companyId);
        });
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    /**
     * Prefer the company bound to the authenticated token over any leftover
     * context. A missing company fails closed.
     */
    protected static function resolveTenantCompanyId(): ?int
    {
        $user = auth()->user();
        if ($user) {
            $tokenCompanyId = $user->currentAccessToken()?->company_id ?? null;
            if ($tokenCompanyId) {
                return (int) $tokenCompanyId;
            }

            if ($user->is_platform_admin && request()->headers->has('X-Company-Id')) {
                return Company::query()
                    ->where('uuid', (string) request()->header('X-Company-Id'))
                    ->value('id');
            }

            return null;
        }

        return app(TenantContext::class)->id();
    }
}
