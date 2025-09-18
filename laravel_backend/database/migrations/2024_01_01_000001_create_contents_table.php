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
        Schema::create('contents', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->text('short_description')->nullable();
            $table->enum('type', [
                'movie', 'series', 'episode', 'live_tv', 
                'music', 'short', 'documentary', 'trailer'
            ]);
            $table->enum('category', [
                'entertainment', 'news', 'sports', 'kids', 
                'music', 'education', 'lifestyle', 'comedy', 
                'drama', 'action'
            ]);
            $table->json('genres')->nullable();
            $table->json('languages')->nullable();
            $table->json('countries')->nullable();
            $table->integer('year')->nullable();
            $table->integer('duration')->nullable(); // in minutes
            $table->string('rating')->nullable(); // PG, PG-13, R, etc.
            $table->decimal('imdb_rating', 3, 1)->nullable();
            $table->bigInteger('total_views')->default(0);
            $table->bigInteger('total_likes')->default(0);
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_trending')->default(false);
            $table->boolean('is_new')->default(false);
            $table->boolean('is_exclusive')->default(false);
            $table->boolean('is_downloadable')->default(false);
            $table->boolean('is_live')->default(false);
            $table->boolean('is_active')->default(true);
            $table->date('release_date')->nullable();
            $table->string('trailer_url')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['type', 'is_active']);
            $table->index(['category', 'is_active']);
            $table->index(['is_featured', 'is_active']);
            $table->index(['is_trending', 'is_active']);
            $table->index(['is_new', 'is_active']);
            $table->index(['year', 'is_active']);
            $table->index(['total_views', 'is_active']);
            $table->index(['created_at', 'is_active']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('contents');
    }
};
