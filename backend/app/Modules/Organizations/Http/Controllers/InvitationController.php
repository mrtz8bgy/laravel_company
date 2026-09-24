<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Controllers;

use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Actions\InviteMember;
use App\Modules\Organizations\Http\Resources\InvitationResource;
use App\Modules\Organizations\Models\Invitation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InvitationController extends Controller
{
    public function index(): JsonResponse
    {
        $this->authorize('viewAny', User::class);

        $invitations = Invitation::query()
            ->with('role:id,uuid,name,slug')
            ->latest('id')
            ->limit(100)
            ->get();

        return ApiResponse::success(InvitationResource::collection($invitations)->resolve());
    }

    public function store(Request $request, InviteMember $inviteMember): JsonResponse
    {
        $this->authorize('create', User::class);
        $data = $request->validate([
            'email' => ['required', 'email'],
            'name' => ['nullable', 'string', 'max:120'],
            'role_uuid' => ['nullable', 'uuid'],
            'department_uuid' => ['nullable', 'uuid'],
            'team_uuid' => ['nullable', 'uuid'],
        ]);

        $result = $inviteMember->handle($data, $request->user());

        return ApiResponse::success([
            'invitation' => (new InvitationResource($result['invitation']->load('role')))->resolve(),
            'accept_url' => $result['accept_url'],
        ], __('messages.invited'), 201);
    }

    public function destroy(Invitation $invitation): JsonResponse
    {
        $this->authorize('viewAny', User::class);
        if ($invitation->accepted_at) {
            return ApiResponse::error(__('messages.invite_invalid'), 422);
        }
        $invitation->delete();

        return ApiResponse::success(null, __('messages.deleted'));
    }
}
