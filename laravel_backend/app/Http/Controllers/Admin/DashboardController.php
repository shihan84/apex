<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Content;
use App\Models\LiveChannel;
use App\Models\User;
use App\Models\Subscription;
use App\Models\Payment;
use App\Services\AnalyticsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    protected $analyticsService;

    public function __construct(AnalyticsService $analyticsService)
    {
        $this->analyticsService = $analyticsService;
    }

    /**
     * Display the admin dashboard
     */
    public function index(Request $request)
    {
        $period = $request->get('period', '30'); // days
        
        // Basic statistics
        $stats = [
            'total_users' => User::count(),
            'active_users' => User::where('is_active', true)->count(),
            'total_content' => Content::count(),
            'active_content' => Content::where('is_active', true)->count(),
            'total_channels' => LiveChannel::count(),
            'active_channels' => LiveChannel::where('is_active', true)->count(),
            'total_subscriptions' => Subscription::count(),
            'active_subscriptions' => Subscription::where('is_active', true)->count(),
            'total_revenue' => Payment::where('status', 'completed')->sum('amount'),
            'monthly_revenue' => Payment::where('status', 'completed')
                ->where('created_at', '>=', now()->subMonth())
                ->sum('amount'),
        ];

        // User growth chart
        $userGrowth = User::select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('COUNT(*) as count')
            )
            ->where('created_at', '>=', now()->subDays($period))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Content views chart
        $contentViews = Content::select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('SUM(total_views) as views')
            )
            ->where('created_at', '>=', now()->subDays($period))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Revenue chart
        $revenue = Payment::select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('SUM(amount) as revenue')
            )
            ->where('status', 'completed')
            ->where('created_at', '>=', now()->subDays($period))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Top content
        $topContent = Content::with(['videos', 'audios'])
            ->where('is_active', true)
            ->orderBy('total_views', 'desc')
            ->limit(10)
            ->get();

        // Top channels
        $topChannels = LiveChannel::where('is_active', true)
            ->orderBy('viewers', 'desc')
            ->limit(10)
            ->get();

        // Recent activities
        $recentActivities = $this->analyticsService->getRecentActivities(20);

        // Content by category
        $contentByCategory = Content::select('category', DB::raw('COUNT(*) as count'))
            ->where('is_active', true)
            ->groupBy('category')
            ->get();

        // Content by type
        $contentByType = Content::select('type', DB::raw('COUNT(*) as count'))
            ->where('is_active', true)
            ->groupBy('type')
            ->get();

        // User registrations by month
        $userRegistrations = User::select(
                DB::raw('YEAR(created_at) as year'),
                DB::raw('MONTH(created_at) as month'),
                DB::raw('COUNT(*) as count')
            )
            ->where('created_at', '>=', now()->subYear())
            ->groupBy('year', 'month')
            ->orderBy('year', 'month')
            ->get();

        // Subscription analytics
        $subscriptionStats = [
            'total' => Subscription::count(),
            'active' => Subscription::where('is_active', true)->count(),
            'expired' => Subscription::where('is_active', false)->count(),
            'by_plan' => Subscription::select('plan_name', DB::raw('COUNT(*) as count'))
                ->groupBy('plan_name')
                ->get(),
        ];

        // Payment analytics
        $paymentStats = [
            'total_revenue' => Payment::where('status', 'completed')->sum('amount'),
            'pending_payments' => Payment::where('status', 'pending')->count(),
            'failed_payments' => Payment::where('status', 'failed')->count(),
            'by_method' => Payment::select('payment_method', DB::raw('COUNT(*) as count'))
                ->groupBy('payment_method')
                ->get(),
        ];

        return view('admin.dashboard', compact(
            'stats',
            'userGrowth',
            'contentViews',
            'revenue',
            'topContent',
            'topChannels',
            'recentActivities',
            'contentByCategory',
            'contentByType',
            'userRegistrations',
            'subscriptionStats',
            'paymentStats',
            'period'
        ));
    }

    /**
     * Get analytics data for charts
     */
    public function analytics(Request $request)
    {
        $type = $request->get('type', 'users');
        $period = $request->get('period', '30');
        
        switch ($type) {
            case 'users':
                $data = User::select(
                    DB::raw('DATE(created_at) as date'),
                    DB::raw('COUNT(*) as count')
                )
                ->where('created_at', '>=', now()->subDays($period))
                ->groupBy('date')
                ->orderBy('date')
                ->get();
                break;
                
            case 'content_views':
                $data = Content::select(
                    DB::raw('DATE(created_at) as date'),
                    DB::raw('SUM(total_views) as views')
                )
                ->where('created_at', '>=', now()->subDays($period))
                ->groupBy('date')
                ->orderBy('date')
                ->get();
                break;
                
            case 'revenue':
                $data = Payment::select(
                    DB::raw('DATE(created_at) as date'),
                    DB::raw('SUM(amount) as revenue')
                )
                ->where('status', 'completed')
                ->where('created_at', '>=', now()->subDays($period))
                ->groupBy('date')
                ->orderBy('date')
                ->get();
                break;
                
            default:
                $data = collect();
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Get real-time statistics
     */
    public function realtimeStats()
    {
        $stats = [
            'online_users' => $this->analyticsService->getOnlineUsersCount(),
            'current_viewers' => $this->analyticsService->getCurrentViewersCount(),
            'live_channels' => LiveChannel::where('is_live', true)->count(),
            'recent_registrations' => User::where('created_at', '>=', now()->subHour())->count(),
            'recent_views' => Content::where('updated_at', '>=', now()->subHour())
                ->sum('total_views'),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }
}
