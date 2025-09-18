<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('live_channels', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('logo')->nullable();
            $table->string('banner')->nullable();
            $table->string('stream_url');
            $table->string('backup_url')->nullable();
            $table->enum('category', [
                'entertainment', 'news', 'sports', 'kids', 
                'music', 'education', 'lifestyle', 'comedy', 
                'drama', 'action'
            ]);
            $table->string('language');
            $table->string('country')->nullable();
            $table->boolean('is_live')->default(true);
            $table->boolean('is_hd')->default(false);
            $table->integer('viewers')->nullable();
            $table->boolean('is_active')->default(true);
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['category', 'is_active']);
            $table->index(['language', 'is_active']);
            $table->index(['is_live', 'is_active']);
            $table->index(['is_hd', 'is_active']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('live_channels');
    }
};
