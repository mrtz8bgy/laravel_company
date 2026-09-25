<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Controllers;

use App\Core\Access\FeatureCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Organizations\Http\Resources\CompanyResource;
use App\Modules\Organizations\Http\Resources\WorkScheduleResource;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Feature;
use App\Modules\Organizations\Models\Setting;
use App\Modules\Organizations\Models\WorkSchedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CompanyController extends Controller
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function show(): JsonResponse
    {
        $this->authorize('view', tenant());

        return ApiResponse::success((new CompanyResource(tenant()))->resolve());
    }

    public function update(Request $request): JsonResponse
    {
        $company = tenant();
        $this->authorize('update', $company);

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:160'],
            'legal_name' => ['sometimes', 'nullable', 'string', 'max:200'],
            'timezone' => ['sometimes', 'timezone'],
            'locale' => ['sometimes', 'in:fa,en'],
            'calendar' => ['sometimes', 'in:jalali,gregorian'],
        ]);

        $calendar = $data['calendar'] ?? null;
        unset($data['calendar']);

        $old = $company->only(array_keys($data));
        if ($calendar !== null) {
            $old['calendar'] = $company->calendarSystem();
            $company->settings = [...($company->settings ?? []), 'calendar' => $calendar];
        }
        $company->update($data);
        $this->activity->log('UPDATE', $company, $old, $data);

        return ApiResponse::success((new CompanyResource($company))->resolve(), __('messages.updated'));
    }

    public function schedule(): JsonResponse
    {
        $this->authorize('view', tenant());
        $days = WorkSchedule::query()->orderBy('weekday')->get();

        return ApiResponse::success(WorkScheduleResource::collection($days)->resolve());
    }

    public function updateSchedule(Request $request): JsonResponse
    {
        $this->authorize('manageSettings', tenant());

        $data = $request->validate([
            'days' => ['required', 'array', 'size:7'],
            'days.*.weekday' => ['required', 'integer', 'between:0,6', 'distinct'],
            'days.*.is_working_day' => ['required', 'boolean'],
            'days.*.start_time' => ['required', 'date_format:H:i'],
            'days.*.end_time' => ['required', 'date_format:H:i'],
            'days.*.break_minutes' => ['required', 'integer', 'min:0', 'max:480'],
            'days.*.grace_minutes' => ['required', 'integer', 'min:0', 'max:180'],
        ]);

        foreach ($data['days'] as $day) {
            if ($day['is_working_day'] && $day['end_time'] <= $day['start_time']) {
                return ApiResponse::error(__('messages.invalid_hours'), 422, [
                    'days' => [__('messages.invalid_hours')],
                ]);
            }

            WorkSchedule::query()->updateOrCreate(
                ['weekday' => $day['weekday']],
                [
                    'is_working_day' => $day['is_working_day'],
                    'start_time' => $day['start_time'],
                    'end_time' => $day['end_time'],
                    'break_minutes' => $day['break_minutes'],
                    'grace_minutes' => $day['grace_minutes'],
                ],
            );
        }

        $this->activity->log('UPDATE', tenant(), null, ['schedule' => true], 'Work schedule updated');

        return ApiResponse::success(
            WorkScheduleResource::collection(WorkSchedule::query()->orderBy('weekday')->get())->resolve(),
            __('messages.updated'),
        );
    }

    public function features(): JsonResponse
    {
        $this->authorize('view', tenant());

        return ApiResponse::success(
            Feature::query()->orderBy('key')->get(['key', 'enabled']),
        );
    }

    public function updateFeature(Request $request, string $key): JsonResponse
    {
        $this->authorize('manageSettings', tenant());

        if (! array_key_exists($key, FeatureCatalog::defaults())) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }
        if (in_array($key, FeatureCatalog::locked(), true)) {
            return ApiResponse::error(__('messages.feature_locked'), 422);
        }

        $data = $request->validate(['enabled' => ['required', 'boolean']]);
        $feature = Feature::query()->where('key', $key)->firstOrFail();
        $old = $feature->enabled;
        $feature->update(['enabled' => $data['enabled']]);
        $this->activity->log('UPDATE', tenant(), ['feature' => $key, 'enabled' => $old], ['feature' => $key, 'enabled' => $feature->enabled]);

        return ApiResponse::success(['key' => $feature->key, 'enabled' => $feature->enabled], __('messages.updated'));
    }

    public function settings(): JsonResponse
    {
        $this->authorize('manageSettings', tenant());

        return ApiResponse::success(Setting::query()->orderBy('key')->get(['key', 'value']));
    }

    public function updateSetting(Request $request, string $key): JsonResponse
    {
        $this->authorize('manageSettings', tenant());
        $data = $request->validate([
            'key' => ['sometimes', 'string', Rule::in([$key])],
            'value' => ['present'],
        ]);

        if (! preg_match('/^[a-z0-9._-]{2,80}$/', $key)) {
            return ApiResponse::error(__('messages.invalid_permission'), 422);
        }

        $setting = Setting::query()->updateOrCreate(
            ['key' => $key],
            ['value' => ['data' => $data['value']]],
        );
        $this->activity->log('UPDATE', tenant(), null, ['setting' => $key]);

        return ApiResponse::success(['key' => $setting->key, 'value' => $setting->value], __('messages.updated'));
    }
}
