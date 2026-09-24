<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class TeamRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        $teamId = $this->route('team')?->id;

        return [
            'name' => ['required', 'string', 'max:120'],
            'department_uuid' => ['required', 'uuid'],
            'slug' => [
                'nullable',
                'string',
                'max:80',
                'alpha_dash',
                Rule::unique('teams', 'slug')
                    ->where(fn ($query) => $query->where('company_id', tenantId()))
                    ->ignore($teamId),
            ],
            'description' => ['nullable', 'string', 'max:2000'],
            'is_active' => ['sometimes', 'boolean'],
            'leader_uuid' => ['nullable', 'uuid'],
            'members' => ['sometimes', 'array'],
            'members.*.uuid' => ['required_with:members', 'uuid'],
            'members.*.role' => ['nullable', 'in:member,leader'],
        ];
    }
}
