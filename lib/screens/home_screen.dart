import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — Shopify-style cinematic landing page
// Place in: lib/screens/home_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onCreateAccount;

  const HomeScreen({super.key, this.onLogin, this.onCreateAccount});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // Hero text reveal
  late AnimationController _textCtrl;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subFade;
  late Animation<Offset> _subSlide;
  late Animation<double> _btnFade;

  // Parallax shimmer on background
  late AnimationController _bgCtrl;
  late Animation<double> _bgAnim;

  // Navbar scroll tint
  final ScrollController _scroll = ScrollController();
  double _scrollY = 0;

  @override
  void initState() {
    super.initState();

    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();

    _titleFade = CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));

    _subFade = CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOut));
    _subSlide = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.3, 0.75, curve: Curves.easeOut)));

    _btnFade = CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut));

    _bgAnim = Tween<double>(begin: 0, end: 1).animate(_bgCtrl);

    _scroll.addListener(() => setState(() => _scrollY = _scroll.offset));

    // Start animations after first frame
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _textCtrl.forward());
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _bgCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 750;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // ── Full scrollable content ──────────────────────────────
        SingleChildScrollView(
          controller: _scroll,
          child: Column(children: [
            // ── HERO ─────────────────────────────────────────────
            _HeroSection(
              size: size,
              isMobile: isMobile,
              bgAnim: _bgAnim,
              titleFade: _titleFade,
              titleSlide: _titleSlide,
              subFade: _subFade,
              subSlide: _subSlide,
              btnFade: _btnFade,
              onCreateAccount: widget.onCreateAccount,
              onLogin: widget.onLogin,
            ),

            // ── TRUSTED BY ───────────────────────────────────────
            _TrustedSection(isMobile: isMobile),

            // ── FEATURES ─────────────────────────────────────────
            _FeaturesSection(isMobile: isMobile),

            // ── DASHBOARD PREVIEW ────────────────────────────────
            _DashboardPreview(isMobile: isMobile),

            // ── HOW IT WORKS ─────────────────────────────────────
            _HowItWorksSection(isMobile: isMobile),

            // ── CTA BOTTOM ───────────────────────────────────────
            _BottomCTA(
              isMobile: isMobile,
              onCreateAccount: widget.onCreateAccount,
              onLogin: widget.onLogin,
            ),

            // ── FOOTER ───────────────────────────────────────────
            _FooterSection(isMobile: isMobile),
          ]),
        ),

        // ── NAVBAR (always on top) ───────────────────────────────
        _NavBar(
          scrollY: _scrollY,
          isMobile: isMobile,
          onLogin: widget.onLogin,
          onCreateAccount: widget.onCreateAccount,
        ),
      ]),
    );
  }
}

// ─── NAVBAR ───────────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final double scrollY;
  final bool isMobile;
  final VoidCallback? onLogin;
  final VoidCallback? onCreateAccount;

  const _NavBar(
      {required this.scrollY,
      required this.isMobile,
      this.onLogin,
      this.onCreateAccount});

  @override
  Widget build(BuildContext context) {
    final scrolled = scrollY > 60;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: scrolled ? Colors.black.withOpacity(0.88) : Colors.transparent,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 12,
        left: isMobile ? 20 : 48,
        right: isMobile ? 20 : 48,
      ),
      child: Row(children: [
        // Logo
        Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4B6BFB), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                    text: 'Xeno',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
                TextSpan(
                    text: 'verse',
                    style: TextStyle(
                        color: Color(0xFF4B6BFB),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
              ],
            ),
          ),
        ]),

        const Spacer(),

        if (!isMobile) ...[
          _NavItem('Features'),
          _NavItem('How It Works'),
          _NavItem('Pricing'),
          const SizedBox(width: 24),
        ],

        // Log in
        GestureDetector(
          onTap: onLogin,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Log in',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ),

        // Start for free
        GestureDetector(
          onTap: onCreateAccount,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text('Start for free',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  const _NavItem(this.label);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      );
}

// ─── HERO SECTION ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final Size size;
  final bool isMobile;
  final Animation<double> bgAnim, titleFade, subFade, btnFade;
  final Animation<Offset> titleSlide, subSlide;
  final VoidCallback? onCreateAccount, onLogin;

  const _HeroSection({
    required this.size,
    required this.isMobile,
    required this.bgAnim,
    required this.titleFade,
    required this.titleSlide,
    required this.subFade,
    required this.subSlide,
    required this.btnFade,
    this.onCreateAccount,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final heroH = isMobile ? size.height * 0.88 : size.height;

    return SizedBox(
      width: double.infinity,
      height: heroH,
      child: Stack(fit: StackFit.expand, children: [
        // ── Cinematic background ─────────────────────────────────
        AnimatedBuilder(
          animation: bgAnim,
          builder: (_, __) => CustomPaint(
            painter: _CinematicBgPainter(bgAnim.value),
          ),
        ),

        // ── Dark gradient overlay (bottom fade for text legibility)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                Colors.transparent,
                Color(0xCC000000),
                Colors.black,
              ],
              stops: [0.3, 0.6, 1.0],
            ),
          ),
        ),

        // Bottom fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 160,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
              ),
            ),
          ),
        ),

        // ── Hero text content ────────────────────────────────────
        Positioned(
          left: isMobile ? 24 : 72,
          right: isMobile ? 24 : size.width * 0.4,
          bottom: isMobile ? 80 : heroH * 0.18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Big headline
              FadeTransition(
                opacity: titleFade,
                child: SlideTransition(
                  position: titleSlide,
                  child: Text(
                    isMobile
                        ? 'Grow your\nbusiness\nsmarter.'
                        : 'Grow your\nbusiness\nsmarter.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 52 : 76,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: -2.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Subtitle
              FadeTransition(
                opacity: subFade,
                child: SlideTransition(
                  position: subSlide,
                  child: Text(
                    'Xenoverse POS gives you the tools to\nmanage inventory, track sales, and\nmake smarter decisions — all in one place.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: isMobile ? 15 : 17,
                      height: 1.65,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Buttons
              FadeTransition(
                opacity: btnFade,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Primary CTA — white pill (Shopify style)
                    GestureDetector(
                      onTap: onCreateAccount,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text('Start for free',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),

                    // Secondary — outlined pill
                    GestureDetector(
                      onTap: onLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_outline_rounded,
                                color: Colors.white.withOpacity(0.85),
                                size: 18),
                            const SizedBox(width: 8),
                            Text('Sign in',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Cinematic background painter ─────────────────────────────────────────────
class _CinematicBgPainter extends CustomPainter {
  final double t;
  _CinematicBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Deep dark base
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF0A0A0F));

    // Large slow-moving colored light blobs — cinematic feel
    final blobs = [
      _BlobData(0.85, 0.2, 420, const Color(0xFF1a1060), 0.0),
      _BlobData(0.65, 0.55, 380, const Color(0xFF0d1855), 0.25),
      _BlobData(0.9, 0.75, 300, const Color(0xFF0a0f30), 0.5),
      _BlobData(0.5, 0.15, 280, const Color(0xFF180830), 0.7),
    ];

    for (final b in blobs) {
      final phase = (t + b.phase) % 1.0;
      final dx = math.sin(phase * math.pi * 2) * 40;
      final dy = math.cos(phase * math.pi * 2) * 25;
      final cx = size.width * b.x + dx;
      final cy = size.height * b.y + dy;

      final gradient = RadialGradient(colors: [
        b.color.withOpacity(0.9),
        b.color.withOpacity(0.3),
        Colors.transparent,
      ], stops: const [
        0,
        0.5,
        1
      ]);

      canvas.drawCircle(
          Offset(cx, cy),
          b.radius,
          Paint()
            ..shader = gradient.createShader(
                Rect.fromCircle(center: Offset(cx, cy), radius: b.radius)));
    }

    // Subtle grain texture via dots
    final rng = math.Random(42);
    final grainPaint = Paint()..color = Colors.white.withOpacity(0.015);
    for (int i = 0; i < 300; i++) {
      canvas.drawCircle(
          Offset(rng.nextDouble() * size.width,
              rng.nextDouble() * size.height),
          rng.nextDouble() * 1.2,
          grainPaint);
    }

    // Faint diagonal lines (cinematic bars feel)
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width + size.height; x += 80) {
      canvas.drawLine(
          Offset(x, 0), Offset(x + size.height, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(_CinematicBgPainter old) => old.t != t;
}

class _BlobData {
  final double x, y, radius, phase;
  final Color color;
  const _BlobData(this.x, this.y, this.radius, this.color, this.phase);
}

// ─── TRUSTED BY ───────────────────────────────────────────────────────────────
class _TrustedSection extends StatelessWidget {
  final bool isMobile;
  const _TrustedSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 72, vertical: 48),
      child: Column(children: [
        Text('Trusted by store owners across the Philippines',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 13,
                letterSpacing: 0.5)),
        const SizedBox(height: 32),
        Wrap(
          spacing: isMobile ? 28 : 56,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _TrustBadge(Icons.store_outlined, 'Retail Shops'),
            _TrustBadge(Icons.restaurant_outlined, 'Restaurants'),
            _TrustBadge(Icons.checkroom_outlined, 'Boutiques'),
            _TrustBadge(Icons.computer_outlined, 'Tech Stores'),
            _TrustBadge(Icons.spa_outlined, 'Salons & Spas'),
          ],
        ),
      ]),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white24, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      );
}

// ─── FEATURES ─────────────────────────────────────────────────────────────────
class _FeaturesSection extends StatelessWidget {
  final bool isMobile;
  const _FeaturesSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080810),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 72, vertical: 80),
      child: Column(children: [
        // Label
        Text('THE PLATFORM',
            style: TextStyle(
                color: const Color(0xFF4B6BFB).withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0)),
        const SizedBox(height: 16),
        Text(
            isMobile
                ? 'Everything your\nstore needs'
                : 'Everything your store needs',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 36 : 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                height: 1.1)),
        const SizedBox(height: 14),
        Text('One system. Full control.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 16)),
        const SizedBox(height: 60),

        // Feature grid
        isMobile
            ? Column(
                children: _featureCards()
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: c,
                        ))
                    .toList())
            : Column(children: [
                Row(children: [
                  Expanded(child: _featureCards()[0]),
                  const SizedBox(width: 16),
                  Expanded(child: _featureCards()[1]),
                  const SizedBox(width: 16),
                  Expanded(child: _featureCards()[2]),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _featureCards()[3]),
                  const SizedBox(width: 16),
                  Expanded(child: _featureCards()[4]),
                  const SizedBox(width: 16),
                  Expanded(child: _featureCards()[5]),
                ]),
              ]),
      ]),
    );
  }

  List<Widget> _featureCards() => [
        _FeatureCard(Icons.inventory_2_outlined, 'Inventory Management',
            'Real-time stock tracking with automatic low-stock alerts.',
            const Color(0xFF4B6BFB)),
        _FeatureCard(Icons.bar_chart_rounded, 'Sales Analytics',
            'Beautiful charts showing revenue, orders, and top products.',
            const Color(0xFF7C3AED)),
        _FeatureCard(Icons.auto_awesome_outlined, 'AI Predictions',
            'Forecast demand and get smart restocking recommendations.',
            const Color(0xFF06B6D4)),
        _FeatureCard(Icons.receipt_long_outlined, 'Order History',
            'Full transaction log with search and export support.',
            const Color(0xFF22C88A)),
        _FeatureCard(Icons.category_outlined, 'Categories',
            'Organize products for faster checkout and reporting.',
            const Color(0xFFF59E0B)),
        _FeatureCard(Icons.devices_outlined, 'Multi-Device',
            'Works seamlessly on desktop and mobile browsers.',
            const Color(0xFFEF4444)),
      ];
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  const _FeatureCard(this.icon, this.title, this.desc, this.color);

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _hovered
              ? widget.color.withOpacity(0.08)
              : Colors.white.withOpacity(0.04),
          border: Border.all(
              color: _hovered
                  ? widget.color.withOpacity(0.4)
                  : Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, color: widget.color, size: 24),
            ),
            const SizedBox(height: 18),
            Text(widget.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(widget.desc,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 13,
                    height: 1.55)),
          ],
        ),
      ),
    );
  }
}

// ─── DASHBOARD PREVIEW ────────────────────────────────────────────────────────
class _DashboardPreview extends StatelessWidget {
  final bool isMobile;
  const _DashboardPreview({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 72, vertical: 80),
      child: Column(children: [
        Text('SEE IT IN ACTION',
            style: TextStyle(
                color: const Color(0xFF22C88A).withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0)),
        const SizedBox(height: 16),
        Text('Your command center',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 32 : 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5)),
        const SizedBox(height: 12),
        Text('Everything at a glance, always up to date.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 15)),
        const SizedBox(height: 48),

        // Mockup container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            color: const Color(0xFF0D1117),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4B6BFB).withOpacity(0.15),
                blurRadius: 80,
                spreadRadius: -20,
                offset: const Offset(0, 40),
              )
            ],
          ),
          child: Column(children: [
            // Window chrome
            Row(children: [
              _Dot(Colors.redAccent),
              const SizedBox(width: 6),
              _Dot(const Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              _Dot(const Color(0xFF22C88A)),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Text('xenoverse-pos.app/dashboard',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11)),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Dashboard stats row
            isMobile
                ? Column(children: [
                    Row(children: [
                      Expanded(
                          child: _StatBox(
                              'Total Revenue', '₱48,290', '+12.5%', true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatBox(
                              'Orders', '284', '+8.3%', true)),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: _StatBox(
                              'Low Stock', '5 items', 'Alert', false)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatBox(
                              'Products', '42', 'Active', true)),
                    ]),
                  ])
                : Row(children: [
                    Expanded(
                        child: _StatBox(
                            'Total Revenue', '₱48,290', '+12.5%', true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child:
                            _StatBox('Orders', '284', '+8.3%', true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatBox(
                            'Low Stock', '5 items', 'Alert', false)),
                    const SizedBox(width: 10),
                    Expanded(
                        child:
                            _StatBox('Products', '42', 'Active', true)),
                  ]),
            const SizedBox(height: 16),

            // Chart mockup
            Container(
              height: isMobile ? 100 : 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales This Week',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Expanded(
                      child: CustomPaint(
                          painter: _ChartPainter(),
                          child: Container())),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Product table rows
            ...['Wireless Headphones — Electronics — ₱2,999 — 15 units',
                'Mechanical Keyboard — Electronics — ₱4,500 — 8 units',
                'Office Chair — Furniture — ₱8,500 — 5 units']
                .asMap()
                .entries
                .map((e) => _TableRow(e.value, e.key)),
          ]),
        ),
      ]),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);
  @override
  Widget build(BuildContext context) => Container(
      width: 12, height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _StatBox extends StatelessWidget {
  final String label, value, trend;
  final bool positive;
  const _StatBox(this.label, this.value, this.trend, this.positive);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          const SizedBox(height: 4),
          Text(trend,
              style: TextStyle(
                  color: positive
                      ? const Color(0xFF22C88A)
                      : const Color(0xFFEF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

class _TableRow extends StatelessWidget {
  final String data;
  final int index;
  const _TableRow(this.data, this.index);
  @override
  Widget build(BuildContext context) {
    final parts = data.split(' — ');
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: [
              const Color(0xFF4B6BFB),
              const Color(0xFF7C3AED),
              const Color(0xFFEF4444)
            ][index].withOpacity(0.15),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(Icons.inventory_2_outlined,
              size: 14,
              color: [
                const Color(0xFF4B6BFB),
                const Color(0xFF7C3AED),
                const Color(0xFFEF4444)
              ][index]),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(parts[0],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12))),
        Text(parts[2],
            style: const TextStyle(
                color: Colors.white54, fontSize: 12)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: index == 2
                ? const Color(0xFFEF4444).withOpacity(0.12)
                : const Color(0xFF22C88A).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(parts[3],
              style: TextStyle(
                  color: index == 2
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF22C88A),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = [0.4, 0.55, 0.45, 0.72, 0.65, 0.88, 0.78];
    final barW = size.width / data.length * 0.55;
    final gap = size.width / data.length;
    for (int i = 0; i < data.length; i++) {
      final x = i * gap + gap * 0.2;
      final h = data[i] * size.height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - h, barW, h),
            const Radius.circular(4)),
        Paint()
          ..color = const Color(0xFF4B6BFB).withOpacity(0.7 + data[i] * 0.3),
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── HOW IT WORKS ─────────────────────────────────────────────────────────────
class _HowItWorksSection extends StatelessWidget {
  final bool isMobile;
  const _HowItWorksSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ['01', 'Create Your Account',
          'Sign up, name your store, set your country and currency.',
          Icons.person_add_outlined, const Color(0xFF4B6BFB)],
      ['02', 'Add Your Products',
          'Upload your catalog with photos, prices, and stock levels.',
          Icons.add_box_outlined, const Color(0xFF7C3AED)],
      ['03', 'Sell & Grow',
          'Process orders, watch analytics, and get AI-powered insights.',
          Icons.trending_up_rounded, const Color(0xFF22C88A)],
    ];

    return Container(
      color: const Color(0xFF080810),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 72, vertical: 80),
      child: Column(children: [
        Text('HOW IT WORKS',
            style: TextStyle(
                color: const Color(0xFF4B6BFB).withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0)),
        const SizedBox(height: 16),
        Text('Up and running\nin minutes',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 34 : 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                height: 1.15)),
        const SizedBox(height: 52),
        isMobile
            ? Column(
                children: steps.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _StepCard(
                          s[0] as String, s[1] as String,
                          s[2] as String, s[3] as IconData,
                          s[4] as Color),
                    )).toList())
            : Row(
                children: steps.map((s) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _StepCard(
                            s[0] as String, s[1] as String,
                            s[2] as String, s[3] as IconData,
                            s[4] as Color),
                      ),
                    )).toList(),
              ),
      ]),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String num, title, desc;
  final IconData icon;
  final Color color;
  const _StepCard(this.num, this.title, this.desc, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(num,
                style: TextStyle(
                    color: color.withOpacity(0.35),
                    fontSize: 38,
                    fontWeight: FontWeight.w900)),
            const Spacer(),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          ]),
          const SizedBox(height: 18),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(desc,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  height: 1.55)),
        ]),
      );
}

// ─── BOTTOM CTA ───────────────────────────────────────────────────────────────
class _BottomCTA extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onCreateAccount, onLogin;
  const _BottomCTA(
      {required this.isMobile, this.onCreateAccount, this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 72, vertical: 80),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 28 : 72,
            vertical: isMobile ? 52 : 72),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF0f1535), Color(0xFF1a0a35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4B6BFB).withOpacity(0.2),
              blurRadius: 80,
              spreadRadius: -10,
            )
          ],
        ),
        child: Column(children: [
          Text(
              isMobile
                  ? 'Start building\nyour empire'
                  : 'Start building your empire',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 34 : 50,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.1)),
          const SizedBox(height: 16),
          Text(
              'Join thousands of Filipino store owners using\nXenoverse POS to run their business smarter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 15,
                  height: 1.6)),
          const SizedBox(height: 40),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: onCreateAccount,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text('Create free account',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              GestureDetector(
                onTap: onLogin,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: Text('Sign in',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

// ─── FOOTER ───────────────────────────────────────────────────────────────────
class _FooterSection extends StatelessWidget {
  final bool isMobile;
  const _FooterSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060608),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 72, vertical: 36),
      child: Row(children: [
        Row(children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF4B6BFB), Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(children: [
              TextSpan(
                  text: 'Xeno',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
              TextSpan(
                  text: 'verse POS',
                  style: TextStyle(
                      color: Color(0xFF4B6BFB),
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ]),
          ),
        ]),
        const Spacer(),
        Text('© 2025 Xenoverse POS',
            style: TextStyle(
                color: Colors.white.withOpacity(0.2), fontSize: 12)),
      ]),
    );
  }
}
