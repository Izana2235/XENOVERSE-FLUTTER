import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state.dart';

// ─── Light-mode palette (matches the app's ThemeData.light) ──────────────────
const _bgPage = Color(0xFFF3F4F6); // scaffoldBackgroundColor
const _bgCard = Color(0xFFFFFFFF); // surface
const _bgInput = Color(0xFFF3F4F6); // subtle input fill
const _primary = Color(0xFF4B6BFB); // primary / accent
const _borderClr = Color(0xFFE5E7EB); // light border
const _textPrimary = Color(0xFF1A1D2E); // foreground
const _textMuted = Color(0xFF6B7280); // muted text
const _errorClr = Color(0xFFEF4444);

// ─── Login Screen ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onBack;

  const LoginScreen({
    super.key,
    required this.appState,
    this.onLoginSuccess,
    this.onBack,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // 🌟 FIREBASE SIGN IN LOGIC
  void _signIn() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an email and password', style: TextStyle(color: Colors.white)), 
          backgroundColor: _errorClr
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      
      widget.onLoginSuccess?.call();

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Login failed', style: const TextStyle(color: Colors.white)), 
          backgroundColor: _errorClr
        )
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo Placeholder ─────────────────────────────────────────
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.point_of_sale_rounded, size: 40, color: _primary),
                    ),
                    const SizedBox(height: 24),

                    // ── Heading ───────────────────────────────────────
                    const Text(
                      'Welcome to Xenoverse',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to your POS account',
                      style: TextStyle(color: _textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // ── Card ─────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: _bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _borderClr),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          const _FieldLabel('Email'),
                          const SizedBox(height: 8),
                          _LightInput(
                            controller: _emailCtrl,
                            hint: 'xenoverse@gmail.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 18),

                          // Password
                          const _FieldLabel('Password'),
                          const SizedBox(height: 8),
                          _LightInput(
                            controller: _passwordCtrl,
                            hint: 'Enter password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign In
                          _PrimaryButton(
                            label: 'Sign In',
                            isLoading: _isLoading,
                            onTap: _signIn,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Footer
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(color: _textMuted, fontSize: 12),
                        children: [
                          const TextSpan(
                              text: 'By signing in, you agree to our '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const _TermsDialog(),
                                );
                              },
                              child: const Text(
                                'Terms',
                                style: TextStyle(
                                  color: _primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _primary,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' & '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      const _TermsDialog(isPrivacy: true),
                                );
                              },
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: _primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _primary,
                                ),
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
          ),

          // ── Back button — on top so it receives taps ────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _borderClr, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded,
                            color: _textPrimary, size: 13),
                        SizedBox(width: 6),
                        Text('Back',
                            style: TextStyle(
                                color: _textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Register Wizard ──────────────────────────────────────────────────────────
class RegisterWizard extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onFinished;
  final VoidCallback? onBack;

  const RegisterWizard({super.key, required this.appState, this.onFinished, this.onBack});

  @override
  State<RegisterWizard> createState() => _RegisterWizardState();
}

class _RegisterWizardState extends State<RegisterWizard> {
  int _step = 0;
  bool _isLoading = false; 

  final _nameCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();

  String? _selectedCountry;
  String? _selectedCurrency;

  static const _countryCurrencyMap = {
    'Philippines':    'PHP (₱) — Philippine Peso',
    'United States':  'USD (\$) — US Dollar',
    'United Kingdom': 'GBP (£) — British Pound',
    'Australia':      'AUD (A\$) — Australian Dollar',
    'Canada':         'CAD (C\$) — Canadian Dollar',
    'Singapore':      'SGD (S\$) — Singapore Dollar',
    'Japan':          'JPY (¥) — Japanese Yen',
    'South Korea':    'KRW (₩) — South Korean Won',
    'India':          'INR (₹) — Indian Rupee',
    'Malaysia':       'MYR (RM) — Malaysian Ringgit',
    'Indonesia':      'IDR (Rp) — Indonesian Rupiah',
    'Thailand':       'THB (฿) — Thai Baht',
    'Vietnam':        'VND (₫) — Vietnamese Dong',
    'Hong Kong':      'HKD (HK\$) — Hong Kong Dollar',
    'Taiwan':         'TWD (NT\$) — New Taiwan Dollar',
    'New Zealand':    'NZD (NZ\$) — New Zealand Dollar',
    'Germany':        'EUR (€) — Euro',
    'France':         'EUR (€) — Euro',
    'Spain':          'EUR (€) — Euro',
    'Italy':          'EUR (€) — Euro',
  };

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _termsError = false;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  static const _countries = [
    'Philippines', 'United States', 'United Kingdom', 'Australia', 'Canada',
    'Singapore', 'Japan', 'South Korea', 'India', 'Malaysia', 'Indonesia',
    'Thailand', 'Vietnam', 'Hong Kong', 'Taiwan', 'New Zealand', 'Germany',
    'France', 'Spain', 'Italy',
  ];

  static const _currencies = [
    'PHP (₱) — Philippine Peso', 'USD (\$) — US Dollar', 'EUR (€) — Euro',
    'GBP (£) — British Pound', 'AUD (A\$) — Australian Dollar', 'CAD (C\$) — Canadian Dollar',
    'SGD (S\$) — Singapore Dollar', 'JPY (¥) — Japanese Yen', 'KRW (₩) — South Korean Won',
    'INR (₹) — Indian Rupee', 'MYR (RM) — Malaysian Ringgit', 'IDR (Rp) — Indonesian Rupiah',
    'THB (฿) — Thai Baht', 'VND (₫) — Vietnamese Dong', 'HKD (HK\$) — Hong Kong Dollar',
    'TWD (NT\$) — New Taiwan Dollar', 'NZD (NZ\$) — New Zealand Dollar',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _storeCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // 🌟 FIREBASE REGISTRATION LOGIC
  void _next() async {
    if (_step == 0 && !(_step1Key.currentState?.validate() ?? false)) return;
    if (_step == 1 && !(_step2Key.currentState?.validate() ?? false)) return;
    
    if (_step == 2) {
      if (!(_step3Key.currentState?.validate() ?? false)) return;
      if (!_agreedToTerms) {
        setState(() => _termsError = true);
        return;
      }

      setState(() => _isLoading = true);

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );

        widget.appState.adminName = _nameCtrl.text.trim();
        widget.appState.storeName = _storeCtrl.text.trim();
        widget.appState.country = _selectedCountry ?? widget.appState.country;
        widget.appState.currency = _selectedCurrency ?? 'PHP (₱) — Philippine Peso';
        
        widget.onFinished?.call();

      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Registration failed', style: const TextStyle(color: Colors.white)), 
            backgroundColor: _errorClr
          )
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      if (widget.onBack != null) {
        widget.onBack!();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Gradient header ──────────────────────────────────
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4B6BFB), Color(0xFF7C3AED)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              // ── Logo Placeholder ─────────────────────────
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 14),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Welcome to Xenoverse POS',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800)),
                                  Text("Let's set up your store",
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ]),
                            const SizedBox(height: 24),
                            _StepProgressBar(currentStep: _step),
                            const SizedBox(height: 12),
                            Text('Step ${_step + 1} of 3',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),

                      // ── White card body ──────────────────────────────────
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: _bgCard,
                          borderRadius:
                              BorderRadius.vertical(bottom: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(_step == 2 ? 16 : 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step title
                            Center(
                              child: Column(children: [
                                Text(_stepTitle(),
                                    style: const TextStyle(
                                        color: _textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(_stepSubtitle(),
                                    style: const TextStyle(
                                        color: _textMuted, fontSize: 13)),
                              ]),
                            ),
                            SizedBox(height: _step == 2 ? 10 : 28),

                            if (_step == 0) _buildStep1(),
                            if (_step == 1) _buildStep2(),
                            if (_step == 2) _buildStep3(),

                            SizedBox(height: _step == 2 ? 6 : 24),
                            const Divider(color: _borderClr),
                            SizedBox(height: _step == 2 ? 6 : 16),

                            // Buttons
                            Row(children: [
                              if (_step > 0) ...[
                                SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: _back,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: _borderClr, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      foregroundColor: _textPrimary,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 24),
                                    ),
                                    child: const Text('Back',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: _textPrimary)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: _PrimaryButton(
                                  label: _step == 2 ? 'Finish Setup' : 'Continue  →',
                                  isLoading: _isLoading,
                                  onTap: _next,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Back button overlay — always top-left ────────────────
            Positioned(
              top: 12,
              left: 16,
              child: GestureDetector(
                onTap: _back,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _borderClr, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          color: _textPrimary, size: 13),
                      SizedBox(width: 6),
                      Text('Back',
                          style: TextStyle(
                              color: _textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 0:
        return 'Tell us about yourself';
      case 1:
        return 'Where is your store?';
      case 2:
        return 'Create your account';
      default:
        return '';
    }
  }

  String _stepSubtitle() {
    switch (_step) {
      case 0:
        return "Let's start with some basic information";
      case 1:
        return 'Select your country and currency';
      case 2:
        return 'Set up your login credentials';
      default:
        return '';
    }
  }

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _FieldLabel('Your Name'),
        const SizedBox(height: 8),
        _LightFormField(
          controller: _nameCtrl,
          hint: 'Juan Dela Cruz',
          icon: Icons.person_outline_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 18),
        const _FieldLabel('Store Name'),
        const SizedBox(height: 8),
        _LightFormField(
          controller: _storeCtrl,
          hint: 'Juan\'s Bistro',
          icon: Icons.storefront_outlined,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Store name is required' : null,
        ),
      ]),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _step2Key,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _FieldLabel('Country'),
        const SizedBox(height: 8),
        FormField<String>(
          validator: (_) =>
              _selectedCountry == null ? 'Please select a country' : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LightDropdown(
                value: _selectedCountry,
                hint: 'Select your country',
                icon: Icons.location_on_outlined,
                items: _countries,
                onChanged: (v) {
                  setState(() {
                    _selectedCountry = v;
                    if (v != null && _countryCurrencyMap.containsKey(v)) {
                      _selectedCurrency = _countryCurrencyMap[v];
                    }
                  });
                  field.didChange(v);
                },
                hasError: field.hasError,
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(field.errorText!,
                      style: const TextStyle(color: _errorClr, fontSize: 12)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(children: [
          const _FieldLabel('Currency'),
          const SizedBox(width: 8),
          if (_selectedCurrency != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4B6BFB).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Auto-filled',
                  style: TextStyle(color: Color(0xFF4B6BFB), fontSize: 10, fontWeight: FontWeight.w600)),
            ),
        ]),
        const SizedBox(height: 8),
        FormField<String>(
          validator: (_) =>
              _selectedCurrency == null ? 'Please select a currency' : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LightDropdown(
                value: _selectedCurrency,
                hint: 'Select currency',
                icon: Icons.attach_money_rounded,
                items: _currencies,
                onChanged: (v) {
                  setState(() {
                    _selectedCurrency = v;
                  });
                  field.didChange(v);
                },
                hasError: field.hasError,
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(field.errorText!,
                      style: const TextStyle(color: _errorClr, fontSize: 12)),
                ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: _step3Key,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _FieldLabel('Email Address'),
        const SizedBox(height: 8),
        _LightFormField(
          controller: _emailCtrl,
          hint: 'juandelacruz67@gmail.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 10),
        const _FieldLabel('Password'),
        const SizedBox(height: 8),
        _LightFormField(
          controller: _passwordCtrl,
          hint: 'Min. 6 characters',
          icon: Icons.lock_outline_rounded,
          obscure: _obscurePass,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePass = !_obscurePass),
            child: Icon(
              _obscurePass
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _textMuted,
              size: 20,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 10),
        const _FieldLabel('Confirm Password'),
        const SizedBox(height: 8),
        _LightFormField(
          controller: _confirmCtrl,
          hint: 'Re-enter password',
          icon: Icons.lock_outline_rounded,
          obscure: _obscureConfirm,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
            child: Icon(
              _obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _textMuted,
              size: 20,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please confirm your password';
            if (v != _passwordCtrl.text) return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 12),

        // ── Terms & Conditions checkbox ───────────────────────────
        GestureDetector(
          onTap: () => setState(() { _agreedToTerms = !_agreedToTerms; _termsError = false; }),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _agreedToTerms ? _primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _agreedToTerms ? _primary : _textMuted,
                    width: 1.5,
                  ),
                ),
                child: _agreedToTerms
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: _textMuted, fontSize: 13, height: 1.5),
                    children: [
                      const TextSpan(text: 'I have read and agree to the '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => const _TermsDialog(),
                            );
                          },
                          child: const Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: _primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: _primary,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  const _TermsDialog(isPrivacy: true),
                            );
                          },
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: _primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: _primary,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_termsError) ...[
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: _errorClr, size: 15),
              SizedBox(width: 6),
              Text(
                'Please agree to the Terms & Conditions to continue.',
                style: TextStyle(color: _errorClr, fontSize: 12),
              ),
            ],
          ),
        ],
      ]),
    );
  }
}

// ─── Terms & Conditions Dialog ────────────────────────────────────────────────
class _TermsDialog extends StatelessWidget {
  final bool isPrivacy;
  const _TermsDialog({this.isPrivacy = false});

  @override
  Widget build(BuildContext context) {
    final title = isPrivacy ? 'Privacy Policy' : 'Terms & Conditions';
    final content = isPrivacy
        ? '''Xenoverse respects your privacy. We collect only the information necessary to operate the POS system, including your name, store details, and account credentials. Your data is never sold to third parties.\n\nWe use industry-standard encryption to protect your information. You may request deletion of your account and data at any time by contacting support.\n\nBy using Xenoverse, you consent to this Privacy Policy.'''
        : '''Welcome to Xenoverse POS. By creating an account, you agree to the following:\n\n1. Account Responsibility\nYou are responsible for maintaining the confidentiality of your credentials and all activities under your account.\n\n2. Acceptable Use\nYou agree to use Xenoverse only for lawful business purposes. Misuse, reverse engineering, or unauthorized access is strictly prohibited.\n\n3. Data Accuracy\nYou are responsible for the accuracy of data entered into the system, including inventory, pricing, and transactions.\n\n4. Termination\nWe reserve the right to suspend or terminate accounts that violate these terms.\n\n5. Changes\nWe may update these Terms periodically. Continued use of the service constitutes acceptance of any changes.''';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), _primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(children: [
                const Icon(Icons.description_outlined,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white70, size: 20),
                ),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  content,
                  style: const TextStyle(
                      color: _textPrimary, fontSize: 13, height: 1.7),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Got it',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step Progress Bar ────────────────────────────────────────────────────────
class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  const _StepProgressBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final isDone = i < currentStep;
        final isCurrent = i == currentStep;
        return Expanded(
          child: Row(children: [
            if (i > 0)
              Expanded(
                child: Container(
                  height: 3,
                  color: (isDone || isCurrent)
                      ? Colors.white
                      : Colors.white.withOpacity(0.35),
                ),
              ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? Colors.white
                    : isCurrent
                        ? Colors.white.withOpacity(0.25)
                        : Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: (isDone || isCurrent)
                      ? Colors.white
                      : Colors.white.withOpacity(0.35),
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, color: _primary, size: 15)
                    : Text('${i + 1}',
                        style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
              ),
            ),
            if (i < 2)
              Expanded(
                child: Container(
                  height: 3,
                  color: isDone ? Colors.white : Colors.white.withOpacity(0.35),
                ),
              ),
          ]),
        );
      }),
    );
  }
}

// ─── Shared light-mode widgets ────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
      );
}

class _LightInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const _LightInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: _textMuted, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _bgInput,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderClr)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderClr)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }
}

class _LightFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _LightFormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: _textMuted, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _bgInput,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderClr)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderClr)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _errorClr, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _errorClr, width: 1.5)),
        errorStyle: const TextStyle(color: _errorClr, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }
}

class _LightDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool hasError;
  final bool enabled = true;

  const _LightDropdown({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? _errorClr : _borderClr,
          width: hasError ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(children: [
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint,
                  style: const TextStyle(color: _textMuted, fontSize: 14)),
              dropdownColor: Colors.white,
              style: const TextStyle(color: _textPrimary, fontSize: 14),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: _textMuted),
              focusColor: Colors.transparent,
              isExpanded: true,
              items: items
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ]),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B6BFB), Color(0xFF7C3AED)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}