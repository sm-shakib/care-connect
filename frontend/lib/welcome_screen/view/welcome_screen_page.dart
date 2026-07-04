import 'dart:ui';
import 'package:frontend/l10n/l10n.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Care Connect - Splash / Welcome Page
class WelcomeScreenPage extends StatelessWidget {
  const WelcomeScreenPage({
    super.key,
    this.onGetStarted,
    this.onLogin,
    this.onContactSupport,
    this.onLanguageToggle,
  });

  final VoidCallback? onGetStarted;
  final VoidCallback? onLogin;
  final VoidCallback? onContactSupport;

  /// Called when the language toggle button is tapped.
  /// The actual locale switch happens up in `App`.
  final VoidCallback? onLanguageToggle;

  // Brand colors pulled from the design.
  static const Color _primaryBlue = Color(0xFF1a56db);
  static const Color _titleBlue = Color(0xFF003fb1);
  static const Color _subtitleGrey = Color(0xFF7A8593);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // ---------- Hero image with curved bottom ----------
              // Sits outside SafeArea on purpose, so it extends
              // behind the status bar, matching the reference design.
              _HeroImageWithBadge(
                primaryBlue: _primaryBlue,
                heroHeight: screenHeight * 0.55,
              ),

              // ---------- Content ----------
              Expanded(
                child: SafeArea(
                  top: false, // image already covers the top; only guard the bottom
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          l10n.careConnectTitle,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: _titleBlue,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.welcomeTagline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: _subtitleGrey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const Spacer(),

                        // ---------- Get Started button ----------
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: onGetStarted,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _titleBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.getStarted,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ---------- Login button ----------
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: onLogin,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _titleBlue,
                              side: BorderSide(color: Colors.grey.shade300, width: 1.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              l10n.login,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ---------- Footer link ----------
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: _subtitleGrey,
                            ),
                            children: [
                              TextSpan(text: '${l10n.needHelp} '),
                              TextSpan(
                                text: l10n.contactSupport,
                                style: const TextStyle(
                                  color: _primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: (TapGestureRecognizer()
                                  ..onTap = onContactSupport),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ---------- Language toggle (glass effect, top-right) ----------
          Positioned(
            top: MediaQuery.of(context).padding.top - 0,
            right: 6,
            child: _LanguageGlassButton(
              // Shows the OTHER language name — tapping switches to it.
              label: l10n.languageToggleToBangla,
              onTap: onLanguageToggle ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}

/// A frosted-glass pill button used for the language toggle.
class _LanguageGlassButton extends StatelessWidget {
  const _LanguageGlassButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.black.withOpacity(0.25),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Top hero section: photo with a rounded/curved bottom edge and a
/// floating circular icon badge that overlaps the curve.
class _HeroImageWithBadge extends StatelessWidget {
  const _HeroImageWithBadge({
    required this.primaryBlue,
    required this.heroHeight,
  });

  final Color primaryBlue;
  final double heroHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: heroHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          ClipPath(
            clipper: _BottomCurveClipper(),
            child: SizedBox(
              width: double.infinity,
              height: heroHeight - 20,
              child: Image.asset(
                'assets/images/welcome.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryBlue.withOpacity(0.15),
                        primaryBlue.withOpacity(0.35),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -32,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryBlue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clips the bottom edge of the hero image into a soft upward curve.
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}