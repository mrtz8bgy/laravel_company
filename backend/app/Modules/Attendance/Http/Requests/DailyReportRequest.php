<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class DailyReportRequest extends FormRequest
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
            'kind' => ['required', 'in:morning,daily'],
            'body' => ['required', 'string', 'min:3', 'max:5000'],
            'blockers' => ['nullable', 'string', 'max:2000'],
        ];
    }
}
