<?php

declare(strict_types=1);

namespace App\Modules\Auth\Actions;

use App\Core\Models\LoginSession;
use App\Core\Services\ActivityLogger;
use App\Core\Support\DeviceParser;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use Illuminate\Http\Request;

class IssueToken
{
    public function __construct(private readonly ActivityLogger $activity) {}

    /**
     * @return array{token: string, session: LoginSession}
     */
    public function handle(User $user, ?Company $company, Request $request, string $action = 'LOGIN'): array
    {
        $minutes = config('sanctum.expiration');
        $expiresAt = $minutes ? now()->addMinutes((int) $minutes) : now()->addDays(7);
        $device = DeviceParser::fromUserAgent($request->userAgent());

        $issued = $user->createToken($device, ['*'], $expiresAt);
        $issued->accessToken->forceFill([
            'company_id' => $company?->id,
        ])->save();

        $session = LoginSession::query()->create([
            'user_id' => $user->id,
            'company_id' => $company?->id,
            'token_id' => $issued->accessToken->id,
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent() ? mb_substr((string) $request->userAgent(), 0, 1000) : null,
            'device' => $device,
            'logged_in_at' => now(),
            'last_activity_at' => now(),
        ]);

        $user->forceFill([
            'last_login_at' => now(),
            'last_login_ip' => $request->ip(),
        ])->save();

        $this->activity->log($action, $user, null, [
            'company_uuid' => $company?->uuid,
            'device' => $device,
        ], null, $company?->id, $user->id);

        return [
            'token' => $issued->plainTextToken,
            'session' => $session,
        ];
    }
}
