<?php

declare(strict_types=1);

namespace App\Modules\Communication\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Communication\Models\Announcement;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnnouncementController extends Controller
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function index(): JsonResponse
    {
        $rows = Announcement::query()->with('author:id,uuid,name')->latest()->limit(40)->get()->map(fn (Announcement $item) => [
            'uuid' => $item->uuid,
            'title' => $item->title,
            'body' => $item->body,
            'author' => $item->author ? ['name' => $item->author->name] : null,
            'created_at' => $item->created_at?->toIso8601String(),
        ])->all();

        return ApiResponse::success($rows);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:160'],
            'body' => ['required', 'string', 'min:3', 'max:5000'],
        ]);
        $item = Announcement::query()->create([...$data, 'author_id' => $request->user()->id]);
        $this->activity->log('CREATE', $item, null, ['title' => $item->title]);

        return ApiResponse::success(['uuid' => $item->uuid, 'title' => $item->title], __('messages.created'), 201);
    }
}
