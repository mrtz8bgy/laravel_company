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
        Schema::create('customers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('uuid')->unique();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('status', 16)->default('pending');
            $table->string('organization_name')->nullable();
            $table->string('phone', 32)->nullable();
            $table->text('note')->nullable();
            $table->text('review_note')->nullable();
            $table->foreignId('reviewer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();

            $table->unique(['company_id', 'user_id']);
            $table->index(['company_id', 'status']);
        });

        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('uuid')->unique();
            $table->string('name');
            $table->string('sku', 40)->nullable();
            $table->text('description')->nullable();
            $table->decimal('unit_price', 14, 0)->default(0);
            $table->string('currency', 8)->default('IRR');
            $table->unsignedInteger('stock')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['company_id', 'sku']);
            $table->index(['company_id', 'is_active']);
        });

        Schema::create('customer_orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('uuid')->unique();
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete();
            $table->string('number', 32);
            $table->string('status', 16)->default('submitted');
            $table->text('note')->nullable();
            $table->text('staff_note')->nullable();
            $table->decimal('total_amount', 14, 0)->default(0);
            $table->string('currency', 8)->default('IRR');
            $table->foreignId('reviewer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();

            $table->unique(['company_id', 'number']);
            $table->index(['company_id', 'status']);
            $table->index(['customer_id', 'created_at']);
        });

        Schema::create('customer_order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('order_id')->constrained('customer_orders')->cascadeOnDelete();
            $table->foreignId('product_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name');
            $table->unsignedInteger('quantity');
            $table->decimal('unit_price', 14, 0);
            $table->decimal('line_total', 14, 0);
            $table->timestamps();
        });

        Schema::create('customer_threads', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('uuid')->unique();
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete();
            $table->string('desk', 16);
            $table->string('subject');
            $table->string('status', 16)->default('open');
            $table->timestamps();

            $table->index(['company_id', 'desk', 'status']);
        });

        Schema::create('customer_thread_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('thread_id')->constrained('customer_threads')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->text('body');
            $table->boolean('is_staff')->default(false);
            $table->timestamps();

            $table->index(['thread_id', 'id']);
        });

        app(SyncPermissions::class)->handle();
        app(AlignSystemRoles::class)->handle();

        if (Schema::hasTable('companies') && Schema::hasTable('features')) {
            $now = now();
            foreach (DB::table('companies')->pluck('id') as $companyId) {
                DB::table('features')->updateOrInsert(
                    ['company_id' => $companyId, 'key' => 'portal'],
                    ['enabled' => true, 'created_at' => $now, 'updated_at' => $now],
                );
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_thread_messages');
        Schema::dropIfExists('customer_threads');
        Schema::dropIfExists('customer_order_items');
        Schema::dropIfExists('customer_orders');
        Schema::dropIfExists('products');
        Schema::dropIfExists('customers');
    }
};
