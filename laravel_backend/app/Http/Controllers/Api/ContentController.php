<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ContentResource;
use App\Http\Resources\ContentCollection;
use App\Http\Resources\LiveChannelResource;
use App\Http\Resources\LiveChannelCollection;
use App\Http\Resources\PlaylistResource;
use App\Http\Resources\PlaylistCollection;
use App\Http\Resources\ArtistResource;
use App\Http\Resources\ArtistCollection;
use App\Models\Content;
use App\Models\LiveChannel;
use App\Models\Playlist;
use App\Models\Artist;
use App\Services\ContentService;
use App\Services\SearchService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Spatie\QueryBuilder\QueryBuilder;
use Spatie\QueryBuilder\AllowedFilter;

class ContentController extends Controller
{
    protected $contentService;
    protected $searchService;

    public function __construct(ContentService $contentService, SearchService $searchService)
    {
        $this->contentService = $contentService;
        $this->searchService = $searchService;
    }

    /**
     * Get trending content
     */
    public function getTrending(Request $request): JsonResponse
    {
        try {
            $query = QueryBuilder::for(Content::class)
                ->where('is_trending', true)
                ->where('is_active', true)
                ->with(['videos', 'audios', 'subtitles', 'cast', 'crew', 'tags'])
                ->allowedFilters([
                    'type',
                    'category',
                    'language',
                    'genre',
                    AllowedFilter::exact('year'),
                    AllowedFilter::exact('rating'),
                ])
                ->defaultSort('-created_at');

            $content = $query->paginate($request->get('limit', 20));

            return response()->json([
                'success' => true,
                'data' => new ContentCollection($content),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load trending content: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get featured content
     */
    public function getFeatured(Request $request): JsonResponse
    {
        try {
            $query = QueryBuilder::for(Content::class)
                ->where('is_featured', true)
                ->where('is_active', true)
                ->with(['videos', 'audios', 'subtitles', 'cast', 'crew', 'tags'])
                ->allowedFilters([
                    'type',
                    'category',
                ])
                ->defaultSort('-created_at');

            $content = $query->paginate($request->get('limit', 20));

            return response()->json([
                'success' => true,
                'data' => new ContentCollection($content),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load featured content: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get new content
     */
    public function getNew(Request $request): JsonResponse
    {
        try {
            $query = QueryBuilder::for(Content::class)
                ->where('is_new', true)
                ->where('is_active', true)
                ->with(['videos', 'audios', 'subtitles', 'cast', 'crew', 'tags'])
                ->allowedFilters([
                    'type',
                    'category',
                ])
                ->defaultSort('-created_at');

            $content = $query->paginate($request->get('limit', 20));

            return response()->json([
                'success' => true,
                'data' => new ContentCollection($content),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load new content: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Search content
     */
    public function search(Request $request): JsonResponse
    {
        try {
            $query = $request->get('q');
            
            if (empty($query)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Search query is required',
                ], 400);
            }

            $results = $this->searchService->searchContent($query, [
                'type' => $request->get('type'),
                'category' => $request->get('category'),
                'language' => $request->get('language'),
                'genre' => $request->get('genre'),
                'page' => $request->get('page', 1),
                'limit' => $request->get('limit', 20),
            ]);

            return response()->json([
                'success' => true,
                'data' => new ContentCollection($results),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Search failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get content details
     */
    public function show(Content $content): JsonResponse
    {
        try {
            $content->load(['videos', 'audios', 'subtitles', 'cast', 'crew', 'tags']);
            
            // Track view
            $this->contentService->trackView($content);

            return response()->json([
                'success' => true,
                'data' => new ContentResource($content),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load content: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get related content
     */
    public function getRelated(Content $content, Request $request): JsonResponse
    {
        try {
            $limit = $request->get('limit', 10);
            $relatedContent = $this->contentService->getRelatedContent($content, $limit);

            return response()->json([
                'success' => true,
                'data' => new ContentCollection($relatedContent),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load related content: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get content cast
     */
    public function getCast(Content $content): JsonResponse
    {
        try {
            $cast = $content->cast()->orderBy('order')->get();

            return response()->json([
                'success' => true,
                'data' => $cast,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load cast: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get content crew
     */
    public function getCrew(Content $content): JsonResponse
    {
        try {
            $crew = $content->crew()->get();

            return response()->json([
                'success' => true,
                'data' => $crew,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load crew: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get content videos
     */
    public function getVideos(Content $content): JsonResponse
    {
        try {
            $videos = $content->videos()->orderBy('quality', 'desc')->get();

            return response()->json([
                'success' => true,
                'data' => $videos,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load videos: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get content audios
     */
    public function getAudios(Content $content): JsonResponse
    {
        try {
            $audios = $content->audios()->orderBy('is_default', 'desc')->get();

            return response()->json([
                'success' => true,
                'data' => $audios,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load audios: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get content subtitles
     */
    public function getSubtitles(Content $content): JsonResponse
    {
        try {
            $subtitles = $content->subtitles()->orderBy('is_default', 'desc')->get();

            return response()->json([
                'success' => true,
                'data' => $subtitles,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load subtitles: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get live channels
     */
    public function getLiveChannels(Request $request): JsonResponse
    {
        try {
            $query = QueryBuilder::for(LiveChannel::class)
                ->where('is_active', true)
                ->allowedFilters([
                    'category',
                    'language',
                    'country',
                    AllowedFilter::exact('is_hd'),
                ])
                ->defaultSort('name');

            $channels = $query->paginate($request->get('limit', 20));

            return response()->json([
                'success' => true,
                'data' => new LiveChannelCollection($channels),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load live channels: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get live channel details
     */
    public function getLiveChannel(LiveChannel $channel): JsonResponse
    {
        try {
            return response()->json([
                'success' => true,
                'data' => new LiveChannelResource($channel),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load channel: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get channel EPG
     */
    public function getChannelEPG(LiveChannel $channel, Request $request): JsonResponse
    {
        try {
            $date = $request->get('date', now()->format('Y-m-d'));
            $epg = $this->contentService->getChannelEPG($channel, $date);

            return response()->json([
                'success' => true,
                'data' => $epg,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load EPG: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get playlists
     */
    public function getPlaylists(Request $request): JsonResponse
    {
        try {
            $query = QueryBuilder::for(Playlist::class)
                ->where('is_active', true)
                ->with(['tracks'])
                ->allowedFilters([
                    'category',
                    'language',
                ])
                ->defaultSort('-created_at');

            $playlists = $query->paginate($request->get('limit', 20));

            return response()->json([
                'success' => true,
                'data' => new PlaylistCollection($playlists),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load playlists: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get playlist details
     */
    public function getPlaylist(Playlist $playlist): JsonResponse
    {
        try {
            $playlist->load(['tracks']);

            return response()->json([
                'success' => true,
                'data' => new PlaylistResource($playlist),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load playlist: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get artists
     */
    public function getArtists(Request $request): JsonResponse
    {
        try {
            $query = QueryBuilder::for(Artist::class)
                ->where('is_active', true)
                ->with(['tracks', 'albums'])
                ->allowedFilters([
                    'language',
                ])
                ->defaultSort('name');

            $artists = $query->paginate($request->get('limit', 20));

            return response()->json([
                'success' => true,
                'data' => new ArtistCollection($artists),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load artists: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get artist details
     */
    public function getArtist(Artist $artist): JsonResponse
    {
        try {
            $artist->load(['tracks', 'albums']);

            return response()->json([
                'success' => true,
                'data' => new ArtistResource($artist),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load artist: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get shorts feed
     */
    public function getShortsFeed(Request $request): JsonResponse
    {
        try {
            $query = QueryBuilder::for(Content::class)
                ->where('type', 'short')
                ->where('is_active', true)
                ->with(['videos', 'audios', 'subtitles'])
                ->allowedFilters([
                    'category',
                    'language',
                ])
                ->defaultSort('-created_at');

            $shorts = $query->paginate($request->get('limit', 20));

            return response()->json([
                'success' => true,
                'data' => new ContentCollection($shorts),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load shorts: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get short details
     */
    public function getShort(Content $short): JsonResponse
    {
        try {
            if ($short->type !== 'short') {
                return response()->json([
                    'success' => false,
                    'message' => 'Content is not a short',
                ], 400);
            }

            $short->load(['videos', 'audios', 'subtitles']);

            return response()->json([
                'success' => true,
                'data' => new ContentResource($short),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load short: ' . $e->getMessage(),
            ], 500);
        }
    }
}
