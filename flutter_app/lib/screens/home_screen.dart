import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/content_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/constants/app_constants.dart';
import '../widgets/content_carousel.dart';
import '../widgets/content_grid.dart';
import '../widgets/live_channels_section.dart';
import '../widgets/music_section.dart';
import '../widgets/shorts_section.dart';
import '../widgets/search_bar.dart';
import '../widgets/user_profile_drawer.dart';
import 'search_screen.dart';
import 'shorts_screen.dart';
import 'live_tv_screen.dart';
import 'music_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final contentProvider = context.read<ContentProvider>();
    await Future.wait([
      contentProvider.loadFeaturedContent(refresh: true),
      contentProvider.loadTrendingContent(refresh: true),
      contentProvider.loadNewContent(refresh: true),
      contentProvider.loadLiveChannels(refresh: true),
      contentProvider.loadPlaylists(refresh: true),
      contentProvider.loadShorts(refresh: true),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const UserProfileDrawer(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: const [
              Tab(text: 'Home'),
              Tab(text: 'Live TV'),
              Tab(text: 'Music'),
              Tab(text: 'Shorts'),
              Tab(text: 'More'),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(),
                const LiveTVScreen(),
                const MusicScreen(),
                const ShortsScreen(),
                _buildMoreTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        if (contentProvider.isLoading && contentProvider.featuredContent.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured Content Carousel
              if (contentProvider.featuredContent.isNotEmpty)
                ContentCarousel(
                  title: 'Featured',
                  content: contentProvider.featuredContent,
                  isLarge: true,
                ),
              
              const SizedBox(height: 24),
              
              // Live Channels Section
              if (contentProvider.liveChannels.isNotEmpty)
                LiveChannelsSection(
                  channels: contentProvider.liveChannels,
                  onViewAll: () {
                    _tabController.animateTo(1);
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Trending Content
              if (contentProvider.trendingContent.isNotEmpty)
                ContentCarousel(
                  title: 'Trending Now',
                  content: contentProvider.trendingContent,
                  onViewAll: () {
                    // TODO: Navigate to trending page
                  },
                ),
              
              const SizedBox(height: 24),
              
              // New Releases
              if (contentProvider.newContent.isNotEmpty)
                ContentCarousel(
                  title: 'New Releases',
                  content: contentProvider.newContent,
                  onViewAll: () {
                    // TODO: Navigate to new releases page
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Music Section
              if (contentProvider.playlists.isNotEmpty)
                MusicSection(
                  playlists: contentProvider.playlists,
                  onViewAll: () {
                    _tabController.animateTo(2);
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Shorts Preview
              if (contentProvider.shorts.isNotEmpty)
                ShortsSection(
                  shorts: contentProvider.shorts.take(6).toList(),
                  onViewAll: () {
                    _tabController.animateTo(3);
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Content by Category
              _buildContentByCategory(),
              
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentByCategory() {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        final categories = [
          'Action',
          'Comedy',
          'Drama',
          'Romance',
          'Thriller',
          'Horror',
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: ContentGrid(
                title: category,
                content: contentProvider.trendingContent
                    .where((item) => item.genres.contains(category))
                    .take(6)
                    .toList(),
                onViewAll: () {
                  // TODO: Navigate to category page
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMoreTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoreSection(
            title: 'My Library',
            items: [
              _MoreItem(
                icon: Icons.favorite,
                title: 'Favorites',
                onTap: () {
                  // TODO: Navigate to favorites
                },
              ),
              _MoreItem(
                icon: Icons.bookmark,
                title: 'Watchlist',
                onTap: () {
                  // TODO: Navigate to watchlist
                },
              ),
              _MoreItem(
                icon: Icons.history,
                title: 'Watch History',
                onTap: () {
                  // TODO: Navigate to history
                },
              ),
              _MoreItem(
                icon: Icons.download,
                title: 'Downloads',
                onTap: () {
                  // TODO: Navigate to downloads
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildMoreSection(
            title: 'Settings',
            items: [
              _MoreItem(
                icon: Icons.person,
                title: 'Profile',
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
              _MoreItem(
                icon: Icons.subscriptions,
                title: 'Subscription',
                onTap: () {
                  // TODO: Navigate to subscription
                },
              ),
              _MoreItem(
                icon: Icons.settings,
                title: 'App Settings',
                onTap: () {
                  // TODO: Navigate to settings
                },
              ),
              _MoreItem(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildMoreSection(
            title: 'About',
            items: [
              _MoreItem(
                icon: Icons.info,
                title: 'About App',
                onTap: () {
                  // TODO: Show about dialog
                },
              ),
              _MoreItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
              _MoreItem(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () {
                  // TODO: Navigate to terms
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoreSection({
    required String title,
    required List<_MoreItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildMoreItem(item)),
      ],
    );
  }

  Widget _buildMoreItem(_MoreItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        item.title,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppTheme.textSecondary,
        size: 16,
      ),
      onTap: item.onTap,
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
