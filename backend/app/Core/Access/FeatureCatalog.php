<?php

declare(strict_types=1);

namespace App\Core\Access;

/**
 * Feature flags prepared for later modules and future plan limits.
 * Foundation cannot be turned off.
 */
final class FeatureCatalog
{
    /**
     * @return array<string, bool>
     */
    public static function defaults(): array
    {
        return [
            'foundation' => true,
            'attendance' => true,
            'projects' => true,
            'hr' => true,
            'communication' => true,
            'calendar' => true,
            'crm' => true,
            'marketing' => true,
            'advertising' => true,
            'finance' => true,
            'operations' => true,
            'workflows' => true,
            'documents' => true,
            'analytics' => true,
            'portal' => true,
        ];
    }

    /**
     * @return list<string>
     */
    public static function locked(): array
    {
        return ['foundation'];
    }
}
