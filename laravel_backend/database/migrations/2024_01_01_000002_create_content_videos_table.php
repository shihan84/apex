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
        Schema::create('content_videos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('content_id')->constrained()->onDelete('cascade');
            $table->string('url');
            $table->enum('quality', ['auto', 'low', 'medium', 'high', 'ultra']);
            $table->enum('format', ['mp4', 'hls', 'dash', 'webm', 'mkv']);
            $table->string('title')->nullable();
            $table->text('description')->nullable();
            $table->integer('duration')->nullable(); // in seconds
            $table->bigInteger('file_size')->nullable(); // in bytes
            $table->boolean('is_hls')->default(false);
            $table->boolean('is_dash')->default(false);
            $table->boolean('is_embedded')->default(false);
            $table->text('embed_code')->nullable();
            $table->json('headers')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['content_id', 'quality']);
            $table->index(['content_id', 'format']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('content_videos');
    }
};
