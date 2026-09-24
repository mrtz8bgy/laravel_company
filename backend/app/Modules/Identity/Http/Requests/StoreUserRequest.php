<?php

declare(strict_types=1);

namespace App\Modules\Identity\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class StoreUserRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190'],
            'password' => ['required', Password::min(8)->mixedCase()->numbers()->symbols()],
            'phone' => ['nullable', 'string', 'max:32'],
            'job_title' => ['nullable', 'string', 'max:120'],
            'employee_code' => ['nullable', 'string', 'max:64'],
            'locale' => ['nullable', 'in:fa,en'],
            'timezone' => ['nullable', 'timezone'],
            'department_uuid' => ['nullable', 'uuid'],
            'team_uuid' => ['nullable', 'uuid'],
            'team_role' => ['nullable', 'in:member,leader'],
            'role_slugs' => ['required', 'array', 'min:1'],
            'role_slugs.*' => ['string', 'max:80'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->filled('email')) {
            $this->merge(['email' => strtolower(trim((string) $this->input('email')))]);
        }
        if ($this->input('employee_code') === '') {
            $this->merge(['employee_code' => null]);
        }
    }
}
