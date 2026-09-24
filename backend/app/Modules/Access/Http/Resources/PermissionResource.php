<?php

declare(strict_types=1);

namespace App\Modules\Access\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Access\Models\Permission */
class PermissionResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'name' => $this->name,
            'module' => $this->module,
            'description' => $this->description,
        ];
    }
}
