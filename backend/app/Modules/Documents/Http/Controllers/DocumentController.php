<?php

declare(strict_types=1);

namespace App\Modules\Documents\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Documents\Models\Document;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DocumentController extends Controller
{
    public function __construct(
        private readonly AuthorizationService $authorization,
        private readonly ActivityLogger $activity,
    ) {}

    public function index(Request $request): JsonResponse
    {
        return ApiResponse::success($this->visible($request)->orderBy('title')->get()->map(fn (Document $document) => [
            'uuid' => $document->uuid,
            'title' => $document->title,
            'visibility' => $document->visibility,
        ])->all());
    }

    public function show(Request $request, Document $document): JsonResponse
    {
        $this->assertVisible($request, $document);

        return ApiResponse::success([
            'uuid' => $document->uuid,
            'title' => $document->title,
            'body' => $document->body,
            'visibility' => $document->visibility,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:160'],
            'body' => ['required', 'string', 'min:1', 'max:20000'],
            'visibility' => ['nullable', 'in:company,private'],
        ]);
        $document = Document::query()->create([
            ...$data,
            'visibility' => $data['visibility'] ?? 'company',
            'author_id' => $request->user()->id,
        ]);
        $this->activity->log('CREATE', $document, null, ['title' => $document->title, 'visibility' => $document->visibility]);

        return ApiResponse::success(['uuid' => $document->uuid, 'title' => $document->title], __('messages.created'), 201);
    }

    private function visible(Request $request): Builder
    {
        $query = Document::query();
        if ($this->authorization->isPrivileged($request->user(), tenant())) {
            return $query;
        }

        return $query->where(function (Builder $inner) use ($request): void {
            $inner->where('visibility', 'company')->orWhere('author_id', $request->user()->id);
        });
    }

    private function assertVisible(Request $request, Document $document): void
    {
        if ($document->visibility !== 'private' || $document->author_id === $request->user()->id || $this->authorization->isPrivileged($request->user(), tenant())) {
            return;
        }
        throw (new ModelNotFoundException())->setModel(Document::class);
    }
}
