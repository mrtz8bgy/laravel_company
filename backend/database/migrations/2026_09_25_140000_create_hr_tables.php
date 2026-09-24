<?php

use App\Modules\Access\Actions\AlignSystemRoles;
use App\Modules\Access\Actions\SyncPermissions;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('hr_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->date('hire_date')->nullable();
            $table->string('employment_type', 24)->nullable();
            $table->string('national_id', 32)->nullable();
            $table->string('emergency_name')->nullable();
            $table->string('emergency_phone', 32)->nullable();
            $table->decimal('salary_amount', 14, 0)->nullable();
            $table->string('salary_currency', 8)->default('IRR');
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->unique(['company_id', 'user_id']);
        });

        Schema::create('leave_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('uuid')->unique();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('type', 16);
            $table->date('starts_on');
            $table->date('ends_on');
            $table->text('reason');
            $table->string('status', 16)->default('pending')->index();
            $table->foreignId('reviewer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->text('review_note')->nullable();
            $table->timestamps();

            $table->index(['company_id', 'user_id', 'status']);
        });

        Schema::create('mission_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('uuid')->unique();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('destination');
            $table->date('starts_on');
            $table->date('ends_on');
            $table->text('purpose');
            $table->string('status', 16)->default('pending')->index();
            $table->foreignId('reviewer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->text('review_note')->nullable();
            $table->timestamps();

            $table->index(['company_id', 'user_id', 'status']);
        });

        app(SyncPermissions::class)->handle();
        app(AlignSystemRoles::class)->handle();

        if (Schema::hasTable('features')) {
            DB::table('features')->where('key', 'hr')->update([
                'enabled' => true,
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('mission_requests');
        Schema::dropIfExists('leave_requests');
        Schema::dropIfExists('hr_profiles');
    }
};
