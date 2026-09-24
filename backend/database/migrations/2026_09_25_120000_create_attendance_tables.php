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
        Schema::create('attendance_days', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('uuid')->unique();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->date('work_date');
            $table->string('location', 16)->default('office');
            $table->string('day_status', 16)->default('marked');
            $table->timestamp('check_in_at')->nullable();
            $table->timestamp('check_out_at')->nullable();
            $table->unsignedSmallInteger('late_minutes')->default(0);
            $table->unsignedSmallInteger('worked_minutes')->default(0);
            $table->unsignedSmallInteger('break_minutes')->default(0);
            $table->unsignedSmallInteger('expected_minutes')->default(0);
            $table->boolean('excused')->default(false);
            $table->text('note')->nullable();
            $table->timestamps();

            $table->unique(['company_id', 'user_id', 'work_date']);
            $table->index(['company_id', 'work_date']);
        });

        Schema::create('attendance_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('uuid')->unique();
            $table->foreignId('attendance_day_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('type', 24);
            $table->timestamp('occurred_at');
            $table->string('location', 16)->nullable();
            $table->string('status', 24)->nullable();
            $table->text('note')->nullable();
            $table->string('source', 16)->default('self');
            $table->foreignId('actor_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('ip', 45)->nullable();
            $table->timestamps();

            $table->index(['company_id', 'user_id', 'occurred_at']);
        });

        Schema::create('work_presences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('status', 24)->default('off');
            $table->string('resume_status', 24)->nullable();
            $table->text('note')->nullable();
            $table->timestamp('since')->nullable();
            $table->timestamps();

            $table->unique(['company_id', 'user_id']);
        });

        Schema::create('daily_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('uuid')->unique();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->date('work_date');
            $table->string('kind', 16);
            $table->text('body');
            $table->text('blockers')->nullable();
            $table->timestamp('submitted_at');
            $table->timestamps();

            $table->unique(['company_id', 'user_id', 'work_date', 'kind']);
        });

        app(SyncPermissions::class)->handle();
        app(AlignSystemRoles::class)->handle();

        if (Schema::hasTable('features')) {
            DB::table('features')->where('key', 'attendance')->update([
                'enabled' => true,
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_reports');
        Schema::dropIfExists('work_presences');
        Schema::dropIfExists('attendance_events');
        Schema::dropIfExists('attendance_days');
    }
};
