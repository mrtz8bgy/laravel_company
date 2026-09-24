<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Actions;

use App\Modules\Organizations\Models\Company;

class MarkOnboarding
{
    public function mark(Company $company, string $step, bool $done = true): Company
    {
        $settings = $company->settings ?? [];
        $settings['onboarding'][$step] = $done;
        $company->settings = $settings;
        $company->save();

        return $company->refresh();
    }

    public function complete(Company $company): Company
    {
        $settings = $company->settings ?? [];
        $settings['onboarding']['completed'] = true;
        $company->settings = $settings;
        $company->onboarded_at = now();
        $company->save();

        return $company->refresh();
    }
}
