<?php

declare(strict_types=1);

namespace App\Modules\Identity\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class UpdateUserRequest extends FormRequest
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
        return [
            'name' => ['sometimes', 'string', 'max:120'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:32'],
            'locale' => ['sometimes', 'in:fa,en'],
            'timezone' => ['sometimes', 'nullable', 'timezone'],
            'job_title' => ['sometimes', 'nullable', 'string', 'max:120'],
            'employee_code' => ['sometimes', 'nullable', 'string', 'max:64'],
            'status' => ['sometimes', 'in:active,suspended'],
            'department_uuid' => ['sometimes', 'nullable', 'uuid'],
            'role_slugs' => ['sometimes', 'array', 'min:1'],
            'role_slugs.*' => ['string', 'max:80'],
            'direct_permissions' => ['sometimes', 'array'],
            'direct_permissions.*' => ['string', 'max:120'],
            'password' => ['sometimes', Password::min(8)->mixedCase()->numbers()->symbols()],
        ];
    }
}
