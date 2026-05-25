import 'package:flutter/material.dart';

// ===================== ONBOARDING DATA =====================

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

final List<OnboardingData> onboardingPages = [
  OnboardingData(
    title: "Welcome to\nSakhi Sampatti",
    subtitle:
    "Your personal wealth management companion. Invest smarter, grow faster, and secure your future — all in one place.",
    icon: Icons.account_balance_wallet_rounded,
    gradientStart: const Color(0xFF6C3DE8),
    gradientEnd: const Color(0xFFB06AB3),
  ),
  OnboardingData(
    title: "Track Stocks\nIn Real Time",
    subtitle:
    "Monitor live stock prices, explore market trends, and place buy orders seamlessly from your phone.",
    icon: Icons.show_chart_rounded,
    gradientStart: const Color(0xFF0F2027),
    gradientEnd: const Color(0xFF00C9FF),
  ),
  OnboardingData(
    title: "List Your\nBusiness",
    subtitle:
    "Register and verify your business on our platform. Reach more customers and access financial tools built for entrepreneurs.",
    icon: Icons.store_rounded,
    gradientStart: const Color(0xFF134E5E),
    gradientEnd: const Color(0xFF71B280),
  ),
  OnboardingData(
    title: "Government\nSchemes & Loans",
    subtitle:
    "Explore 20+ government schemes, subsidies, and loan programs designed to help farmers, women, and small businesses thrive.",
    icon: Icons.account_balance_rounded,
    gradientStart: const Color(0xFFFF6B35),
    gradientEnd: const Color(0xFFF7C59F),
  ),
  OnboardingData(
    title: "Learn &\nGrow",
    subtitle:
    "Watch curated finance videos from top Indian creators and our in-app lessons to master money management.",
    icon: Icons.play_circle_fill_rounded,
    gradientStart: const Color(0xFF1A1A2E),
    gradientEnd: const Color(0xFF7C5CFC),
  ),
];

// ===================== ONBOARDING SCREEN =====================

class OnboardingScreen extends StatefulWidget {
  /// Called when the user finishes onboarding.
  /// Pass this callback to navigate to MainPage.
  final VoidCallback onFinished;
  final String userName;

  const OnboardingScreen({
    Key? key,
    required this.onFinished,
    required this.userName,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _iconController;
  late Animation<double> _iconScale;
  late Animation<double> _iconFade;

  late AnimationController _textController;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = CurvedAnimation(parent: _iconController, curve: Curves.elasticOut);
    _iconFade = CurvedAnimation(parent: _iconController, curve: Curves.easeIn);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    _playAnimations();
  }

  void _playAnimations() {
    _iconController.forward(from: 0);
    _textController.forward(from: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinished();
    }
  }

  void _skip() => widget.onFinished();

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _playAnimations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Page View ──────────────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) {
              return _buildPage(onboardingPages[index], index == 0);
            },
          ),

          // ── Top: Skip button ───────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: AnimatedOpacity(
              opacity: _currentPage < onboardingPages.length - 1 ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: TextButton(
                onPressed: _skip,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Controls ────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildDotIndicator(),
                const SizedBox(height: 28),
                _buildBottomButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data, bool isFirst) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.gradientStart, data.gradientEnd],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Icon with animation
              ScaleTransition(
                scale: _iconScale,
                child: FadeTransition(
                  opacity: _iconFade,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      data.icon,
                      size: 72,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Greeting on first page
              if (isFirst) ...[
                FadeTransition(
                  opacity: _textFade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      "Hello, ${widget.userName.isNotEmpty ? widget.userName.split(' ').first : 'there'}! 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Title
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _textSlide.value),
                  child: FadeTransition(
                    opacity: _textFade,
                    child: child,
                  ),
                ),
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Subtitle
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _textSlide.value * 1.3),
                  child: FadeTransition(
                    opacity: _textFade,
                    child: child,
                  ),
                ),
                child: Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 120), // space for bottom controls
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingPages.length,
            (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white38,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton() {
    final isLast = _currentPage == onboardingPages.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: onboardingPages[_currentPage].gradientStart,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Row(
              key: ValueKey(isLast),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLast ? "Get Started" : "Next",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLast
                      ? Icons.rocket_launch_rounded
                      : Icons.arrow_forward_rounded,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
