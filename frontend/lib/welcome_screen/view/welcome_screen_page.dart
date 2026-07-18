import 'dart:ui';
import 'package:frontend/l10n/l10n.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Care Connect - Splash / Welcome Page
///
/// Colors and type now come from [AppTheme] / [AppColors] (Kindred Care
/// System spec) instead of local hardcoded hex values, so this screen
/// automatically follows light/dark mode and any future palette updates.
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              // ---------- Hero image with curved bottom ----------
              // Sits outside SafeArea on purpose, so it extends
              // behind the status bar, matching the reference design.
              _HeroImageWithBadge(
                accentColor: AppColors.darkTeal,
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
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkTeal,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.welcomeTagline,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            height: 1.4,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const Spacer(),

                        // ---------- Get Started button ----------
                        // Inherits height/shape/text style from
                        // AppTheme.elevatedButtonTheme; only the icon
                        // is added on top.
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkTeal,      // Button background
                              foregroundColor: Colors.white,     // Text & icon color
                            ),
                            onPressed: onGetStarted,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(l10n.getStarted),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ---------- Login button ----------
                        // Inherits height/shape/text style from
                        // AppTheme.outlinedButtonTheme.
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkTeal, // Text color
                              side: const BorderSide(
                                color: AppColors.darkTeal, // Border color
                                width: 1,
                              ),
                              //backgroundColor: Colors.white, // Optional background
                            ),
                            onPressed: onLogin,
                            child: Text(l10n.login),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ---------- Footer link ----------
                        RichText(
                          text: TextSpan(
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(text: '${l10n.needHelp} '),
                              TextSpan(
                                text: l10n.contactSupport,
                                style: TextStyle(
                                  color: AppColors.darkTeal,
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
            top: MediaQuery.of(context).padding.top,
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
///
/// Kept as a dark overlay (Colors.black/white) on purpose: it sits on
/// top of the hero photo in both light and dark mode, so it uses fixed
/// contrast values rather than theme colors.
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
    required this.accentColor,
    required this.heroHeight,
  });

  final Color accentColor;
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
                        accentColor.withOpacity(0.15),
                        accentColor.withOpacity(0.35),
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
                color: accentColor,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.45),
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