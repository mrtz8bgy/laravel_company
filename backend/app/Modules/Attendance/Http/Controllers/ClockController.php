<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Http\Controllers;

use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Attendance\Actions\AttendanceSnapshot;
use App\Modules\Attendance\Actions\ClockAttendance;
use App\Modules\Attendance\Http\Requests\CheckInRequest;
use App\Modules\Attendance\Http\Requests\StatusRequest;
use App\Modules\Attendance\Http\Resources\AttendanceDayResource;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Identity\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ClockController extends Controller
{
    public function __construct(
        private readonly ClockAttendance $clock,
        private readonly AttendanceSnapshot $snapshot,
    ) {}

    public function today(Request $request): JsonResponse
    {
        return ApiResponse::success($this->snapshot->today($this->user($request)));
    }

    public function history(Request $request): JsonResponse
    {
        $user = $this->user($request);
        $timezone = tenant()->timezone ?: 'Asia/Tehran';
        $to = $request->date('to') ?: now($timezone);
        $from = $request->date('from') ?: $to->copy()->subDays(13);
        if ($from->diffInDays($to) > 62) {
            $from = $to->copy()->subDays(62);
        }

        $days = AttendanceDay::query()
            ->where('user_id', $user->id)
            ->whereDate('work_date', '>=', $from->toDateString())
            ->whereDate('work_date', '<=', $to->toDateString())
            ->orderByDesc('work_date')
            ->get();

        return ApiResponse::success(AttendanceDayResource::collection($days)->resolve());
    }

    public function checkIn(CheckInRequest $request): JsonResponse
    {
        $day = $this->clock->checkIn($this->user($request), $request->string('location')->toString(), $request->input('note'));

        return ApiResponse::success((new AttendanceDayResource($day))->resolve(), __('messages.updated'));
    }

    public function checkOut(Request $request): JsonResponse
    {
        $request->validate(['note' => ['nullable', 'string', 'max:500']]);
        $day = $this->clock->checkOut($this->user($request), $request->input('note'));

        return ApiResponse::success((new AttendanceDayResource($day))->resolve(), __('messages.updated'));
    }

    public function startBreak(Request $request): JsonResponse
    {
        $request->validate(['note' => ['nullable', 'string', 'max:500']]);
        $day = $this->clock->startBreak($this->user($request), $request->input('note'));

        return ApiResponse::success((new AttendanceDayResource($day))->resolve(), __('messages.updated'));
    }

    public function endBreak(Request $request): JsonResponse
    {
        $request->validate(['note' => ['nullable', 'string', 'max:500']]);
        $day = $this->clock->endBreak($this->user($request), $request->input('note'));

        return ApiResponse::success((new AttendanceDayResource($day))->resolve(), __('messages.updated'));
    }

    public function status(StatusRequest $request): JsonResponse
    {
        $day = $this->clock->setStatus(
            $this->user($request),
            $request->string('status')->toString(),
            $request->input('note'),
        );

        return ApiResponse::success((new AttendanceDayResource($day))->resolve(), __('messages.updated'));
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
