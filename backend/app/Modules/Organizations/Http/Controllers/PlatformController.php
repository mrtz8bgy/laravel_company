<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Organizations\Http\Resources\CompanyResource;
use App\Modules\Organizations\Models\Company;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlatformController extends Controller
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function companies(): JsonResponse
    {
        $companies = Company::query()->latest('id')->get();

        return ApiResponse::success(CompanyResource::collection($companies)->resolve());
    }

    public function updateCompany(Request $request, Company $company): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', 'in:active,suspended'],
        ]);

        $old = $company->status;
        $company->update(['status' => $data['status']]);
        $this->activity->log(
            'STATUS_CHANGE',
            $company,
            ['status' => $old],
            ['status' => $company->status],
            'Platform company status change',
            $company->id,
            $request->user()->id,
        );

        return ApiResponse::success((new CompanyResource($company))->resolve(), __('messages.updated'));
    }
}
