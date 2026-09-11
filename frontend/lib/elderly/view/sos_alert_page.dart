import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/elderly/data/repositories/elder_repository.dart';
import 'package:frontend/shared/chat/chat.dart';
import 'package:frontend/theme/app_colors.dart';

/// Full-screen SOS alert shown when the elder taps the SOS button.
///
/// Tries to grab a fresh GPS fix, then posts `/elders/sos` — the backend
/// shares whatever location comes back (falling back to the elder's last
/// known one if a fresh fix wasn't available) with every accepted family
/// member and caregiver, and pushes them a notification. This page just
/// reflects whatever actually happened: who got notified, and whether the
/// shared location was live or last-known.
class SosAlertPage extends StatefulWidget {
  const SosAlertPage({super.key});

  @override
  State<SosAlertPage> createState() => _SosAlertPageState();
}

enum _SosStage { sharing, shared, failed }

class _NotifiedContact {
  const _NotifiedContact(this.name, this.role);

  final String name;
  final String role;
}

/// A fresh fix has to arrive within this window of pressing SOS, or the
/// request goes out with none — better to notify with a last-known
/// location right away than to leave the elder waiting on a slow GPS lock
/// during an emergency.
const _locationFixTimeout = Duration(seconds: 6);

class _SosAlertPageState extends State<SosAlertPage>
    with SingleTickerProviderStateMixin {
  final _elderRepository = ElderRepository(ApiClient());

  _SosStage _stage = _SosStage.sharing;
  List<_NotifiedContact> _notifiedContacts = const [];
  bool _isLiveLocation = false;
  bool _hasLocation = false;
  String? _errorMessage;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    unawaited(_sendSos());
  }

  Future<void> _sendSos() async {
    setState(() {
      _stage = _SosStage.sharing;
      _errorMessage = null;
    });
    _pulseController
      ..value = 0
      ..repeat();

    double? latitude;
    double? longitude;
    try {
      final position = await LocationService()
          .getCurrentLocation()
          .timeout(_locationFixTimeout, onTimeout: () => null);
      latitude = position?.latitude;
      longitude = position?.longitude;
    } catch (_) {
      // No fresh fix — the backend falls back to the elder's last known
      // location, so this is never fatal to sending the alert.
    }

    try {
      final response = await _elderRepository.triggerSos(
        latitude: latitude,
        longitude: longitude,
      );
      if (!mounted) return;

      final notified = (response['notified'] as List<dynamic>? ?? const [])
          .map((raw) {
            final entry = Map<String, dynamic>.from(raw as Map);
            return _NotifiedContact(
              entry['name']?.toString() ?? 'Contact',
              _roleLabel(entry['role']?.toString()),
            );
          })
          .toList();

      setState(() {
        _stage = _SosStage.shared;
        _notifiedContacts = notified;
        _isLiveLocation = response['is_live'] as bool? ?? false;
        _hasLocation =
            response['latitude'] != null && response['longitude'] != null;
      });
      _pulseController
        ..stop()
        ..value = 0;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _SosStage.failed;
        _errorMessage = 'Could not send your SOS alert. Please try again.';
      });
      _pulseController
        ..stop()
        ..value = 0;
    }
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'family':
        return 'Family';
      case 'caregiver':
        return 'Caregiver';
      default:
        return 'Contact';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSharing = _stage == _SosStage.sharing;
    final isFailed = _stage == _SosStage.failed;
    final accentColor = isSharing
        ? AppColors.warningRed
        : isFailed
            ? AppColors.warningRed
            : Colors.green;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Spacer(),
              _PulsingAlarmIcon(
                controller: _pulseController,
                color: accentColor,
                icon: isSharing
                    ? Icons.sos_rounded
                    : isFailed
                        ? Icons.error_outline_rounded
                        : Icons.check_rounded,
                pulsing: isSharing,
              ),
              const SizedBox(height: 40),
              Text(
                isSharing
                    ? 'SOS ALERT ACTIVE'
                    : isFailed
                        ? 'Alert Not Sent'
                        : 'Location Shared',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: isSharing ? 2 : 0,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isSharing
                    ? 'Sharing your live location...'
                    : isFailed
                        ? (_errorMessage ?? 'Something went wrong.')
                        : _sharedSubtitle(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              if (isSharing) ...[
                const SizedBox(height: 28),
                const _LoadingDots(),
              ] else if (!isFailed) ...[
                const SizedBox(height: 28),
                _NotifiedContactsCard(contacts: _notifiedContacts),
              ],
              const Spacer(),
              if (isSharing)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              else if (isFailed)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkTeal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => unawaited(_sendSos()),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkTeal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              // Scaffolded here so the session gate's
                              // loading/error states land on a Material
                              // surface — ChatInboxPage brings its own.
                              builder: (_) => Scaffold(
                                body: ChatSessionGate(
                                  builder:
                                      (context, repository, currentUser) =>
                                          ChatInboxPage(
                                            repository: repository,
                                            currentUser: currentUser,
                                          ),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.call, size: 20),
                        label: const Text(
                          'Contacts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkTeal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _sharedSubtitle() {
    if (_notifiedContacts.isEmpty) {
      return _hasLocation
          ? 'Your location was recorded, but no linked family or\ncaregiver was found to notify.'
          : 'No location or linked contacts were found to share.';
    }
    final locationLabel = !_hasLocation
        ? 'An alert was'
        : _isLiveLocation
            ? 'Your live location has been'
            : "Your last known location has been";
    return '$locationLabel shared and your\nemergency contacts have been notified.';
  }
}

/// A siren-style pulsing icon: expanding, fading rings behind a solid
/// circle when [pulsing] is true; a plain static circle otherwise.
class _PulsingAlarmIcon extends StatelessWidget {
  const _PulsingAlarmIcon({
    required this.controller,
    required this.color,
    required this.icon,
    required this.pulsing,
  });

  final AnimationController controller;
  final Color color;
  final IconData icon;
  final bool pulsing;

  static const _ringCount = 3;
  static const _maxDiameter = 220.0;
  static const _coreDiameter = 140.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _maxDiameter,
      height: _maxDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (pulsing)
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(_ringCount, (i) {
                    final t = (controller.value + i / _ringCount) % 1.0;
                    final diameter =
                        _coreDiameter + (_maxDiameter - _coreDiameter) * t;
                    return Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0) * 0.55,
                      child: Container(
                        width: diameter,
                        height: diameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2.5),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          Container(
            width: _coreDiameter,
            height: _coreDiameter,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.55),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 64),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
      ),
    );
  }
}

class _NotifiedContactsCard extends StatelessWidget {
  const _NotifiedContactsCard({required this.contacts});

  final List<_NotifiedContact> contacts;

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notified',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          for (final contact in contacts) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ${contact.role}',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
            if (contact != contacts.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
