<?php

declare(strict_types=1);

namespace App\Modules\Communication\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Core\Support\Slugger;
use App\Http\Controllers\Controller;
use App\Modules\Communication\Models\Channel;
use App\Modules\Communication\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChannelController extends Controller
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function index(): JsonResponse
    {
        $rows = Channel::query()->orderBy('name')->get()->map(fn (Channel $channel) => [
            'uuid' => $channel->uuid,
            'name' => $channel->name,
            'slug' => $channel->slug,
        ])->all();

        return ApiResponse::success($rows);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate(['name' => ['required', 'string', 'max:120']]);
        $channel = Channel::query()->create([
            'name' => $data['name'],
            'slug' => Slugger::unique($data['name'], fn (string $candidate) => Channel::query()->where('slug', $candidate)->exists(), 'ch'),
            'kind' => 'company',
        ]);
        $this->activity->log('CREATE', $channel, null, ['name' => $channel->name]);

        return ApiResponse::success(['uuid' => $channel->uuid, 'name' => $channel->name], __('messages.created'), 201);
    }

    public function messages(Channel $channel): JsonResponse
    {
        $rows = Message::query()->with('user:id,uuid,name')->where('channel_id', $channel->id)->latest('id')->limit(80)->get()
            ->sortBy('id')->values()->map(fn (Message $message) => [
                'uuid' => $message->uuid,
                'body' => $message->body,
                'created_at' => $message->created_at?->toIso8601String(),
                'user' => $message->user ? ['uuid' => $message->user->uuid, 'name' => $message->user->name] : null,
            ])->all();

        return ApiResponse::success($rows);
    }

    public function send(Request $request, Channel $channel): JsonResponse
    {
        $data = $request->validate(['body' => ['required', 'string', 'min:1', 'max:4000']]);
        $message = Message::query()->create([
            'channel_id' => $channel->id,
            'user_id' => $request->user()->id,
            'body' => $data['body'],
        ]);

        return ApiResponse::success(['uuid' => $message->uuid, 'body' => $message->body], __('messages.created'), 201);
    }
}
