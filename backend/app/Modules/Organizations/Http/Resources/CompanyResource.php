<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Organizations\Models\Company */
class CompanyResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'name' => $this->name,
            'legal_name' => $this->legal_name,
            'slug' => $this->slug,
            'status' => $this->status,
            'timezone' => $this->timezone,
            'locale' => $this->locale,
            'plan' => $this->plan,
            'user_limit' => $this->user_limit,
            'onboarded_at' => $this->onboarded_at?->toIso8601String(),
            'onboarding' => $this->onboardingState(),
        ];
    }
}
