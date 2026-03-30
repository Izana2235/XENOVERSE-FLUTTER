import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────────────────────────────────────
// Xenoverse Landing Page — Modern Premium POS System Landing Page
// Place in: lib/screens/landing_page.dart
// ─────────────────────────────────────────────────────────────────────────────

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _heroAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _backgroundShiftAnimation;

  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _heroAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _heroFadeAnimation = CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.easeOut,
    );

    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.easeOut,
    ));

    _backgroundShiftAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_backgroundAnimationController);

    // Start hero animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _heroAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated Background
          AnimatedBackground(
            scrollOffset: _scrollOffset,
            animation: _backgroundShiftAnimation,
          ),

          // Content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero Section
                HeroSection(
                  size: size,
                  isMobile: isMobile,
                  fadeAnimation: _heroFadeAnimation,
                  slideAnimation: _heroSlideAnimation,
                ),

                // Features Section
                FeaturesSection(
                  size: size,
                  isMobile: isMobile,
                  scrollOffset: _scrollOffset,
                ),

                // Dashboard Preview Section
                DashboardPreviewSection(
                  size: size,
                  isMobile: isMobile,
                  scrollOffset: _scrollOffset,
                ),

                // Footer
                Container(
                  height: 100,
                  color: Colors.black.withOpacity(0.8),
                  child: const Center(
                    child: Text(
                      '© 2024 Xenoverse. All rights reserved.',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navbar
          AnimatedNavbar(
            scrollOffset: _scrollOffset,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Background Widget
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedBackground extends StatelessWidget {
  final double scrollOffset;
  final Animation<double> animation;

  const AnimatedBackground({
    super.key,
    required this.scrollOffset,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F0F23),
                Color.lerp(
                  const Color(0xFF1a1a2e),
                  const Color(0xFF16213e),
                  animation.value,
                )!,
                Color.lerp(
                  const Color(0xFF0f3460),
                  const Color(0xFF1a1a2e),
                  animation.value,
                )!,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Floating shapes
              Positioned(
                top: 100 - scrollOffset * 0.5,
                left: 50,
                child: _FloatingShape(
                  size: 120,
                  color: Colors.purple.withOpacity(0.1),
                ),
              ),
              Positioned(
                top: 300 - scrollOffset * 0.3,
                right: 100,
                child: _FloatingShape(
                  size: 80,
                  color: Colors.blue.withOpacity(0.1),
                ),
              ),
              Positioned(
                bottom: 200 + scrollOffset * 0.2,
                left: 200,
                child: _FloatingShape(
                  size: 100,
                  color: Colors.indigo.withOpacity(0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingShape extends StatelessWidget {
  final double size;
  final Color color;

  const _FloatingShape({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section Widget
// ─────────────────────────────────────────────────────────────────────────────

class HeroSection extends StatelessWidget {
  final Size size;
  final bool isMobile;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const HeroSection({
    super.key,
    required this.size,
    required this.isMobile,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 80,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Name
          Text(
            'Xenoverse',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 32),

          // Headline
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Text(
                'Grow your business smarter.',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: isMobile ? 36 : 64,
                  fontWeight: FontWeight.w300,
                  height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Subtext
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Text(
                'Streamline inventory management, track sales analytics,\nand boost productivity with AI-powered insights.',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isMobile ? 16 : 20,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // CTA Buttons
          FadeTransition(
            opacity: fadeAnimation,
            child: Row(
              children: [
                _CTAButton(
                  text: 'Start for free',
                  isPrimary: true,
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                _CTAButton(
                  text: 'Sign in',
                  isPrimary: false,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CTAButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _CTAButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _scaleController.reverse(),
            onTapCancel: () => _scaleController.reverse(),
            onTap: widget.onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: widget.isPrimary
                    ? const Color(0xFF6366f1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: widget.isPrimary
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366f1).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                widget.text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Features Section Widget
// ─────────────────────────────────────────────────────────────────────────────

class FeaturesSection extends StatelessWidget {
  final Size size;
  final bool isMobile;
  final double scrollOffset;

  const FeaturesSection({
    super.key,
    required this.size,
    required this.isMobile,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureData(
        title: 'Inventory Management',
        description:
            'Track stock levels, manage suppliers, and automate reordering.',
        icon: Icons.inventory,
      ),
      _FeatureData(
        title: 'Sales Analytics',
        description: 'Real-time insights into sales performance and trends.',
        icon: Icons.analytics,
      ),
      _FeatureData(
        title: 'AI Predictions',
        description:
            'Forecast demand and optimize inventory with machine learning.',
        icon: Icons.smart_toy,
      ),
      _FeatureData(
        title: 'Order History',
        description: 'Complete transaction records with detailed reporting.',
        icon: Icons.history,
      ),
      _FeatureData(
        title: 'Categories',
        description:
            'Organize products efficiently with customizable categories.',
        icon: Icons.category,
      ),
      _FeatureData(
        title: 'Multi-Device',
        description: 'Access your POS system from any device, anywhere.',
        icon: Icons.devices,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Powerful Features',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Everything you need to run your business efficiently.',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 64),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.2,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              return _FeatureCard(
                data: features[index],
                scrollOffset: scrollOffset,
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final String title;
  final String description;
  final IconData icon;

  const _FeatureData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData data;
  final double scrollOffset;
  final int index;

  const _FeatureCard({
    required this.data,
    required this.scrollOffset,
    required this.index,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_hoverController);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366f1).withOpacity(
                      _glowAnimation.value * 0.2,
                    ),
                    blurRadius: 20 + _glowAnimation.value * 10,
                    spreadRadius: _glowAnimation.value * 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.data.title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.data.description,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Preview Section Widget
// ─────────────────────────────────────────────────────────────────────────────

class DashboardPreviewSection extends StatelessWidget {
  final Size size;
  final bool isMobile;
  final double scrollOffset;

  const DashboardPreviewSection({
    super.key,
    required this.size,
    required this.isMobile,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Dashboard Preview',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Get a glimpse of your powerful analytics dashboard.',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 64),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: isMobile ? size.width - 48 : 1200,
            ),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Row(
                  children: [
                    _DashboardStat(
                      title: 'Revenue',
                      value: '\$12,345',
                      icon: Icons.attach_money,
                    ),
                    const SizedBox(width: 32),
                    _DashboardStat(
                      title: 'Orders',
                      value: '156',
                      icon: Icons.shopping_cart,
                    ),
                    const SizedBox(width: 32),
                    _DashboardStat(
                      title: 'Low Stock',
                      value: '8',
                      icon: Icons.warning,
                    ),
                    const SizedBox(width: 32),
                    _DashboardStat(
                      title: 'Products',
                      value: '1,234',
                      icon: Icons.inventory,
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Chart
                const Text(
                  'Weekly Sales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                _SalesChart(),

                const SizedBox(height: 48),

                // Product List
                const Text(
                  'Recent Products',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                _ProductList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF6366f1),
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart();

  @override
  Widget build(BuildContext context) {
    final data = [1200, 1800, 1500, 2200, 1900, 2400, 2100];

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((value) {
          final height = (value / 2400) * 180;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1),
                borderRadius: BorderRadius.circular(4),
              ),
              height: height,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList();

  @override
  Widget build(BuildContext context) {
    final products = [
      _ProductData('Wireless Headphones', 45),
      _ProductData('Smart Watch', 12),
      _ProductData('Laptop Stand', 78),
      _ProductData('USB Cable', 156),
    ];

    return Column(
      children: products.map((product) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.stock < 20
                      ? Colors.red.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${product.stock}',
                  style: GoogleFonts.inter(
                    color: product.stock < 20 ? Colors.red : Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ProductData {
  final String name;
  final int stock;

  const _ProductData(this.name, this.stock);
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Navbar Widget
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedNavbar extends StatelessWidget {
  final double scrollOffset;
  final bool isMobile;

  const AnimatedNavbar({
    super.key,
    required this.scrollOffset,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = (scrollOffset / 200).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(opacity * 0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(opacity * 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Xenoverse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            _NavItem('Features', () {}),
            const SizedBox(width: 32),
            _NavItem('Pricing', () {}),
            const SizedBox(width: 32),
            _NavItem('Support', () {}),
            const SizedBox(width: 32),
            _NavItem('Sign In', () {}),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _NavItem(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.8),
          fontSize: 16,
        ),
      ),
    );
  }
}
