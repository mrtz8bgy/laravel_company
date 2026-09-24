<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class DepartmentRequest extends FormRequest
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
        $departmentId = $this->route('department')?->id;

        return [
            'name' => ['required', 'string', 'max:120'],
            'slug' => [
                'nullable',
                'string',
                'max:80',
                'alpha_dash',
                Rule::unique('departments', 'slug')
                    ->where(fn ($query) => $query->where('company_id', tenantId()))
                    ->ignore($departmentId),
            ],
            'code' => [
                'nullable',
                'string',
                'max:32',
                'alpha_dash',
                Rule::unique('departments', 'code')
                    ->where(fn ($query) => $query->where('company_id', tenantId()))
                    ->ignore($departmentId),
            ],
            'description' => ['nullable', 'string', 'max:2000'],
            'is_active' => ['sometimes', 'boolean'],
            'sort_order' => ['sometimes', 'integer', 'min:0', 'max:10000'],
            'manager_uuid' => ['nullable', 'uuid'],
            'parent_uuid' => ['nullable', 'uuid'],
        ];
    }
}
