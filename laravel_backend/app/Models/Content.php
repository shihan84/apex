<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;
use Spatie\Activitylog\Traits\LogsActivity;
use Spatie\Activitylog\LogOptions;

class Content extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia, LogsActivity;

    protected $fillable = [
        'title',
        'description',
        'short_description',
        'type',
        'category',
        'genres',
        'languages',
        'countries',
        'year',
        'duration',
        'rating',
        'imdb_rating',
        'total_views',
        'total_likes',
        'is_featured',
        'is_trending',
        'is_new',
        'is_exclusive',
        'is_downloadable',
        'is_live',
        'is_active',
        'release_date',
        'trailer_url',
        'metadata',
    ];

    protected $casts = [
        'genres' => 'array',
        'languages' => 'array',
        'countries' => 'array',
        'metadata' => 'array',
        'is_featured' => 'boolean',
        'is_trending' => 'boolean',
        'is_new' => 'boolean',
        'is_exclusive' => 'boolean',
        'is_downloadable' => 'boolean',
        'is_live' => 'boolean',
        'is_active' => 'boolean',
        'release_date' => 'date',
        'imdb_rating' => 'decimal:1',
    ];

    protected $appends = [
        'thumbnail_url',
        'poster_url',
        'banner_url',
    ];

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnly(['title', 'type', 'category', 'is_active'])
            ->logOnlyDirty()
            ->dontSubmitEmptyLogs();
    }

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('thumbnail')
            ->singleFile()
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);

        $this->addMediaCollection('poster')
            ->singleFile()
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);

        $this->addMediaCollection('banner')
            ->singleFile()
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);

        $this->addMediaCollection('gallery')
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);
    }

    public function registerMediaConversions(Media $media = null): void
    {
        $this->addMediaConversion('thumb')
            ->width(300)
            ->height(200)
            ->sharpen(10)
            ->performOnCollections('thumbnail', 'poster', 'banner');

        $this->addMediaConversion('medium')
            ->width(600)
            ->height(400)
            ->sharpen(10)
            ->performOnCollections('thumbnail', 'poster', 'banner');

        $this->addMediaConversion('large')
            ->width(1200)
            ->height(800)
            ->sharpen(10)
            ->performOnCollections('banner');
    }

    public function getThumbnailUrlAttribute(): ?string
    {
        return $this->getFirstMediaUrl('thumbnail', 'medium') ?: 
               $this->getFirstMediaUrl('poster', 'thumb');
    }

    public function getPosterUrlAttribute(): ?string
    {
        return $this->getFirstMediaUrl('poster', 'medium') ?: 
               $this->getFirstMediaUrl('thumbnail', 'medium');
    }

    public function getBannerUrlAttribute(): ?string
    {
        return $this->getFirstMediaUrl('banner', 'large') ?: 
               $this->getFirstMediaUrl('poster', 'large');
    }

    public function getDurationFormattedAttribute(): string
    {
        if (!$this->duration) {
            return '';
        }

        $hours = floor($this->duration / 60);
        $minutes = $this->duration % 60;

        if ($hours > 0) {
            return sprintf('%dh %dm', $hours, $minutes);
        }

        return sprintf('%dm', $minutes);
    }

    public function getDisplayTitleAttribute(): string
    {
        return $this->title;
    }

    public function getDisplayDescriptionAttribute(): string
    {
        return $this->description ?: $this->short_description ?: '';
    }

    public function getHasTrailerAttribute(): bool
    {
        return !empty($this->trailer_url);
    }

    public function getHasVideosAttribute(): bool
    {
        return $this->videos()->exists();
    }

    public function getHasAudiosAttribute(): bool
    {
        return $this->audios()->exists();
    }

    public function getHasSubtitlesAttribute(): bool
    {
        return $this->subtitles()->exists();
    }

    // Relationships
    public function videos(): HasMany
    {
        return $this->hasMany(ContentVideo::class);
    }

    public function audios(): HasMany
    {
        return $this->hasMany(ContentAudio::class);
    }

    public function subtitles(): HasMany
    {
        return $this->hasMany(ContentSubtitle::class);
    }

    public function cast(): HasMany
    {
        return $this->hasMany(ContentCast::class);
    }

    public function crew(): HasMany
    {
        return $this->hasMany(ContentCrew::class);
    }

    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(ContentTag::class, 'content_tag_pivot');
    }

    public function comments(): HasMany
    {
        return $this->hasMany(ContentComment::class);
    }

    public function ratings(): HasMany
    {
        return $this->hasMany(ContentRating::class);
    }

    public function favorites(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_favorites');
    }

    public function watchlist(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_watchlist');
    }

    public function history(): HasMany
    {
        return $this->hasMany(UserWatchHistory::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeTrending($query)
    {
        return $query->where('is_trending', true);
    }

    public function scopeNew($query)
    {
        return $query->where('is_new', true);
    }

    public function scopeExclusive($query)
    {
        return $query->where('is_exclusive', true);
    }

    public function scopeDownloadable($query)
    {
        return $query->where('is_downloadable', true);
    }

    public function scopeLive($query)
    {
        return $query->where('is_live', true);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopeByGenre($query, $genre)
    {
        return $query->whereJsonContains('genres', $genre);
    }

    public function scopeByLanguage($query, $language)
    {
        return $query->whereJsonContains('languages', $language);
    }

    public function scopeByYear($query, $year)
    {
        return $query->where('year', $year);
    }

    public function scopeByRating($query, $rating)
    {
        return $query->where('rating', $rating);
    }

    public function scopeSearch($query, $search)
    {
        return $query->where(function ($q) use ($search) {
            $q->where('title', 'like', "%{$search}%")
              ->orWhere('description', 'like', "%{$search}%")
              ->orWhere('short_description', 'like', "%{$search}%");
        });
    }

    // Methods
    public function incrementViews(): void
    {
        $this->increment('total_views');
    }

    public function incrementLikes(): void
    {
        $this->increment('total_likes');
    }

    public function decrementLikes(): void
    {
        $this->decrement('total_likes');
    }

    public function getAverageRating(): float
    {
        return $this->ratings()->avg('rating') ?: 0;
    }

    public function getTotalRatings(): int
    {
        return $this->ratings()->count();
    }

    public function isFavoritedBy(User $user): bool
    {
        return $this->favorites()->where('user_id', $user->id)->exists();
    }

    public function isInWatchlist(User $user): bool
    {
        return $this->watchlist()->where('user_id', $user->id)->exists();
    }

    public function getUserRating(User $user): ?ContentRating
    {
        return $this->ratings()->where('user_id', $user->id)->first();
    }
}
