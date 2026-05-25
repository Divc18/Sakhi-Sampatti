import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Entry Point ────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanceHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ExploreScreen(),
    );
  }
}

// ─── Theme ───────────────────────────────────────────────────
class AppTheme {
  static const Color bg = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color card = Color(0xFF1A2235);
  static const Color cardHover = Color(0xFF1E2940);
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentSoft = Color(0xFF00D4AA22);
  static const Color gold = Color(0xFFFFB800);
  static const Color goldSoft = Color(0xFFFFB80020);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleSoft = Color(0xFF7C3AED22);
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8B9DC3);
  static const Color divider = Color(0xFF1E2D45);
  static const Color red = Color(0xFFFF4757);
  static const Color blue = Color(0xFF2979FF);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: gold,
          surface: surface,
        ),
        fontFamily: 'Roboto',
      );
}

// ─── Data Models ─────────────────────────────────────────────
enum VideoType { local, youtube }

class VideoItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String duration;
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;
  final VideoType type;
  final String source; // asset path or YouTube ID
  final String thumbnailGradientKey;
  final List<String> tags;
  final String views;

  const VideoItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.duration,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
    required this.type,
    required this.source,
    required this.thumbnailGradientKey,
    required this.tags,
    required this.views,
  });
}

class YoutubeVideoItem {
  final String id;
  final String youtubeId;
  final String title;
  final String channelName;
  final String views;
  final String duration;
  final String category;
  final Color categoryColor;

  const YoutubeVideoItem({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.channelName,
    required this.views,
    required this.duration,
    required this.category,
    required this.categoryColor,
  });
}

// ─── Sample Data ──────────────────────────────────────────────
class AppData {
  static const List<VideoItem> featuredVideos = [
    VideoItem(
      id: 'v1',
      title: 'Sakhi Sampatti',
      subtitle: 'Women\'s Wealth & Empowerment',
      description:
          'A comprehensive guide to financial independence for women. Learn about savings, investments, and building lasting wealth through smart financial decisions.',
      duration: '12:45',
      category: 'Empowerment',
      categoryColor: AppTheme.accent,
      categoryIcon: Icons.favorite_rounded,
      type: VideoType.local,
      source: 'assets/videos/video1.mp4',
      thumbnailGradientKey: 'teal',
      tags: ['Women', 'Savings', 'Investment'],
      views: '24.5K',
    ),
    VideoItem(
      id: 'v2',
      title: 'Stock Market Mastery',
      subtitle: 'Trading & Investment Strategies',
      description:
          'Deep dive into the world of stocks. From basics to advanced trading strategies, understand how to grow your portfolio with confidence.',
      duration: '18:20',
      category: 'Stocks',
      categoryColor: AppTheme.gold,
      categoryIcon: Icons.trending_up_rounded,
      type: VideoType.local,
      source: 'assets/videos/video2.mp4',
      thumbnailGradientKey: 'gold',
      tags: ['Stocks', 'Trading', 'Portfolio'],
      views: '41.2K',
    ),
    VideoItem(
      id: 'v3',
      title: 'Govt Schemes & Loans',
      subtitle: 'Benefits You Must Know',
      description:
          'Explore government schemes, subsidies, and loan programs designed to help citizens. Know your rights and financial benefits available to you.',
      duration: '15:10',
      category: 'Government',
      categoryColor: AppTheme.purple,
      categoryIcon: Icons.account_balance_rounded,
      type: VideoType.local,
      source: 'assets/videos/video3.mp4',
      thumbnailGradientKey: 'purple',
      tags: ['Schemes', 'Loans', 'Benefits'],
      views: '33.8K',
    ),
  ];

  static const List<YoutubeVideoItem> youtubeVideos = [
    YoutubeVideoItem(
      id: 'yt1',
      youtubeId: 'Xn7KWR9EOGQ',
      title: 'Personal Finance for Beginners',
      channelName: 'Finance with Sharan',
      views: '2.1M',
      duration: '22:18',
      category: 'Finance Basics',
      categoryColor: AppTheme.blue,
    ),
    YoutubeVideoItem(
      id: 'yt2',
      youtubeId: 'mNjFBMhEBnQ',
      title: 'How to Invest in Mutual Funds',
      channelName: 'CA Rachana Ranade',
      views: '4.7M',
      duration: '35:42',
      category: 'Mutual Funds',
      categoryColor: AppTheme.accent,
    ),
    YoutubeVideoItem(
      id: 'yt3',
      youtubeId: 'tD5y_BInxWA',
      title: 'SIP Investment Strategy 2024',
      channelName: 'Groww',
      views: '1.8M',
      duration: '18:05',
      category: 'SIP',
      categoryColor: AppTheme.gold,
    ),
    YoutubeVideoItem(
      id: 'yt4',
      youtubeId: 'iDqGFkFpJeY',
      title: 'Tax Saving Guide - Section 80C',
      channelName: 'Zerodha Varsity',
      views: '986K',
      duration: '28:33',
      category: 'Tax Planning',
      categoryColor: AppTheme.purple,
    ),
    YoutubeVideoItem(
      id: 'yt5',
      youtubeId: '3PknLDtvFn4',
      title: 'Stock Market Basics Hindi',
      channelName: 'Pranjal Kamra',
      views: '5.2M',
      duration: '41:20',
      category: 'Stock Market',
      categoryColor: AppTheme.red,
    ),
    YoutubeVideoItem(
      id: 'yt6',
      youtubeId: 'rf2OxSycrTE',
      title: 'Emergency Fund - Why & How',
      channelName: 'Labour Law Advisor',
      views: '1.3M',
      duration: '14:55',
      category: 'Savings',
      categoryColor: Color(0xFF00BCD4),
    ),
  ];

  static const List<String> categories = [
    'All',
    'Empowerment',
    'Stocks',
    'Government',
    'Mutual Funds',
    'Tax Planning',
    'Savings',
  ];
}

// ─── Explore Screen ───────────────────────────────────────────
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();
  bool _showTopBar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(() {
      final show = _scrollController.offset > 120;
      if (show != _showTopBar) setState(() => _showTopBar = show);
    });
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
      backgroundColor: AppTheme.bg,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (ctx, inner) => [_buildSliverHeader()],
        body: Column(
          children: [
            _buildTabBar(),
            _buildCategoryChips(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOurVideosTab(),
                  _buildYouTubeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.bg,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderBackground(),
        collapseMode: CollapseMode.parallax,
      ),
      title: AnimatedOpacity(
        opacity: _showTopBar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Text(
          'Explore',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B35), AppTheme.bg],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accent, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.play_circle_fill_rounded,
                            color: AppTheme.accent, size: 13),
                        SizedBox(width: 5),
                        Text(
                          'EXPLORE',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Financial\nKnowledge Hub',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Learn, grow & master your finances',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ─────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.accent, Color(0xFF00A88A)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: '🎬  Our Videos'),
          Tab(text: '▶️  YouTube'),
        ],
      ),
    );
  }

  // ── Category Chips ──────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: AppData.categories.length,
        itemBuilder: (ctx, i) {
          final cat = AppData.categories[i];
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [AppTheme.accent, Color(0xFF00A88A)],
                      )
                    : null,
                color: selected ? null : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.transparent : AppTheme.divider,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: selected ? Colors.black : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Our Videos Tab ──────────────────────────────────────────
  Widget _buildOurVideosTab() {
    final videos = _selectedCategory == 'All'
        ? AppData.featuredVideos
        : AppData.featuredVideos
            .where((v) => v.category == _selectedCategory)
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Featured large card
        if (videos.isNotEmpty) ...[
          _buildFeaturedCard(videos.first),
          const SizedBox(height: 24),
        ],
        if (videos.length > 1) ...[
          _buildSectionHeader('More Videos', Icons.video_library_rounded),
          const SizedBox(height: 12),
          ...videos.skip(1).map((v) => _buildVideoListCard(v)),
        ],
        if (videos.isEmpty) _buildEmptyState(),
      ],
    );
  }

  Widget _buildFeaturedCard(VideoItem video) {
    return GestureDetector(
      onTap: () => _openVideo(video),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: video.categoryColor.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  _buildThumbnail(video, height: 200),
                  // Featured badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.gold, Color(0xFFF57F00)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '⭐ FEATURED',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  // Duration
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: _buildDurationBadge(video.duration),
                  ),
                  // Play button
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.8), width: 2),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
              // Info
              Container(
                color: AppTheme.card,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildCategoryBadge(video.category, video.categoryColor,
                            icon: video.categoryIcon),
                        const Spacer(),
                        Icon(Icons.visibility_outlined,
                            color: AppTheme.textSecondary, size: 13),
                        const SizedBox(width: 4),
                        Text(video.views,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.subtitle,
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: video.tags
                          .map((t) => _buildTag(t, video.categoryColor))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    // Watch button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openVideo(video),
                        icon: const Icon(Icons.play_circle_fill_rounded,
                            size: 18),
                        label: const Text('Watch Now',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: video.categoryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoListCard(VideoItem video) {
    return GestureDetector(
      onTap: () => _openVideo(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 120,
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildThumbnail(video, height: 100),
                    Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: _buildDurationBadge(video.duration, small: true),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryBadge(video.category, video.categoryColor,
                        small: true),
                    const SizedBox(height: 6),
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.visibility_outlined,
                            color: AppTheme.textSecondary, size: 12),
                        const SizedBox(width: 3),
                        Text(video.views,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11)),
                        const SizedBox(width: 10),
                        Icon(Icons.local_offer_outlined,
                            color: AppTheme.textSecondary, size: 12),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            video.tags.join(', '),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textSecondary, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── YouTube Tab ─────────────────────────────────────────────
  Widget _buildYouTubeTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        _buildYouTubeBanner(),
        const SizedBox(height: 20),
        _buildSectionHeader(
            'Curated Finance Videos', Icons.youtube_searched_for_rounded),
        const SizedBox(height: 12),
        ...AppData.youtubeVideos.map((v) => _buildYouTubeCard(v)),
      ],
    );
  }

  Widget _buildYouTubeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A0A), Color(0xFF2D0A0A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YouTube Finance Hub',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Top financial education content',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: AppTheme.red,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeCard(YoutubeVideoItem video) {
    final thumbUrl =
        'https://img.youtube.com/vi/${video.youtubeId}/maxresdefault.jpg';

    return GestureDetector(
      onTap: () => _openYouTubeVideo(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YouTube thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    thumbUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: AppTheme.surface,
                      child: Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  // Dark overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Play button
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.red.withOpacity(0.4),
                            blurRadius: 16,
                          )
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 30),
                    ),
                  ),
                  // Duration
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: _buildDurationBadge(video.duration),
                  ),
                  // Category
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _buildCategoryBadge(
                        video.category, video.categoryColor,
                        small: true),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video.channelName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(Icons.visibility_outlined,
                          color: AppTheme.textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        video.views,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared Widgets ──────────────────────────────────────────
  Widget _buildThumbnail(VideoItem video, {required double height}) {
    final Map<String, List<Color>> gradients = {
      'teal': [
        const Color(0xFF004D40),
        const Color(0xFF00695C),
        AppTheme.accent
      ],
      'gold': [const Color(0xFF4A2E00), const Color(0xFF7A4E00), AppTheme.gold],
      'purple': [
        const Color(0xFF1A0A4A),
        const Color(0xFF3A1A7A),
        AppTheme.purple
      ],
    };

    final colors = gradients[video.thumbnailGradientKey] ?? gradients['teal']!;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.last.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.last.withOpacity(0.1),
              ),
            ),
          ),
          // Center icon
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(video.categoryIcon, color: colors.last, size: 40),
                const SizedBox(height: 8),
                Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationBadge(String duration, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        duration,
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category, Color color,
      {bool small = false, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: small ? 10 : 12),
            SizedBox(width: small ? 3 : 4),
          ],
          Text(
            category,
            style: TextStyle(
              color: color,
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text(
            'See all',
            style: TextStyle(color: AppTheme.accent, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.video_library_outlined,
              color: AppTheme.textSecondary, size: 56),
          const SizedBox(height: 16),
          const Text(
            'No videos in this category',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────
  void _openVideo(VideoItem video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video),
      ),
    );
  }

  void _openYouTubeVideo(YoutubeVideoItem video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YouTubePlayerScreen(video: video),
      ),
    );
  }
}

// ─── Local Video Player Screen ────────────────────────────────
class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.asset(widget.video.source);
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: Container(color: Colors.black),
        materialProgressColors: ChewieProgressColors(
          playedColor: widget.video.categoryColor,
          handleColor: widget.video.categoryColor,
          backgroundColor: AppTheme.surface,
          bufferedColor: widget.video.categoryColor.withOpacity(0.3),
        ),
        allowFullScreen: true,
        allowMuting: true,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg =
            'Could not load video. Check asset path:\n${widget.video.source}';
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.video.title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent))
                : _errorMsg != null
                    ? _buildErrorState()
                    : Chewie(controller: _chewieController!),
          ),
          // Info
          Expanded(
            child: Container(
              color: AppTheme.bg,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildCategoryBadgeDetailed(),
                  const SizedBox(height: 12),
                  Text(
                    widget.video.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.video.subtitle,
                    style: TextStyle(
                      color: widget.video.categoryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statChip(Icons.visibility_outlined, widget.video.views),
                      const SizedBox(width: 12),
                      _statChip(
                          Icons.access_time_rounded, widget.video.duration),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.divider),
                  const SizedBox(height: 16),
                  const Text(
                    'About this video',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.video.tags
                        .map((t) => _buildTagDetailed(t))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: AppTheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppTheme.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMsg ?? 'Error loading video',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadgeDetailed() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.video.categoryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: widget.video.categoryColor.withOpacity(0.4), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.video.categoryIcon,
                  color: widget.video.categoryColor, size: 13),
              const SizedBox(width: 5),
              Text(
                widget.video.category,
                style: TextStyle(
                  color: widget.video.categoryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 14),
        const SizedBox(width: 5),
        Text(value,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildTagDetailed(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── YouTube Player Screen ────────────────────────────────────
class YouTubePlayerScreen extends StatefulWidget {
  final YoutubeVideoItem video;
  const YouTubePlayerScreen({super.key, required this.video});

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.red,
        progressColors: const ProgressBarColors(
          playedColor: AppTheme.red,
          handleColor: AppTheme.red,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
            backgroundColor: AppTheme.bg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.video.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
          ),
          body: ListView(
            children: [
              player,
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryBadgeYT(),
                    const SizedBox(height: 12),
                    Text(
                      widget.video.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.video.channelName,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${widget.video.views} views',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(
                                'https://www.youtube.com/watch?v=${widget.video.youtubeId}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_new_rounded,
                              size: 14, color: AppTheme.red),
                          label: const Text(
                            'YouTube',
                            style: TextStyle(color: AppTheme.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ytStat(Icons.access_time_rounded,
                              widget.video.duration, 'Duration'),
                          _dividerV(),
                          _ytStat(Icons.visibility_outlined, widget.video.views,
                              'Views'),
                          _dividerV(),
                          _ytStat(Icons.label_outline_rounded,
                              widget.video.category, 'Category'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dividerV() =>
      Container(width: 1, height: 36, color: AppTheme.divider);

  Widget _ytStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accent, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildCategoryBadgeYT() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.video.categoryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: widget.video.categoryColor.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        widget.video.category,
        style: TextStyle(
          color: widget.video.categoryColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
