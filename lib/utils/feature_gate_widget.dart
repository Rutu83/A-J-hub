import 'package:ajhub_app/main.dart'; // for appStore
import 'package:ajhub_app/screens/payment/premium_plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// Wraps any widget with a feature gate.
/// If the user's plan does not allow [feature], the widget is dimmed
/// and tapping shows an upgrade prompt.
///
/// Usage (boolean feature):
///   FeatureGate(feature: 'business_seminar', child: SeminarCard())
///
/// Usage (numeric feature — disabled when limit is 0):
///   FeatureGate(feature: 'download_poster_daily', child: DownloadButton())
class FeatureGate extends StatelessWidget {
  final String feature;
  final Widget child;
  final bool showLockBadge;
  final int? currentCount;
  final Widget? customLockWidget;

  const FeatureGate({
    super.key,
    required this.feature,
    required this.child,
    this.showLockBadge = true,
    this.currentCount,
    this.customLockWidget,
  });

  bool _hasAccess() {
    final limits = appStore.planLimits;

    // Trial Mode Access (inactive user)
    // Allow users in the 7-day trial to add 1 business
    if (appStore.Status == 'inactive') {
      if (feature == 'add_business') {
        int trialLimit = 1;
        if (currentCount != null && currentCount! >= trialLimit) {
          return false;
        }
        return true;
      }
    }

    // Boolean features
    if (feature == 'business_seminar') return limits.businessSeminar;
    if (feature == 'plan_a_day') return limits.planADay;

    // Numeric features
    final limit = limits.getLimit(feature);
    if (limit <= 0) return false; // Not allowed at all

    // If a current count is provided, verify we haven't reached the limit
    if (currentCount != null && currentCount! >= limit) {
      return false;
    }

    return true;
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFFf093fb)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Upgrade Required',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This feature is not available on your current plan. Upgrade to unlock it.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not Now', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumPlansScreen()),
              );
            },
            child:
                const Text('View Plans', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final hasAccess = _hasAccess();

      if (hasAccess) return child;

      if (customLockWidget != null) return customLockWidget!;

      return GestureDetector(
        onTap: () => _showUpgradeDialog(context),
        child: Stack(
          children: [
            // Dimmed original widget
            Opacity(opacity: 0.4, child: child),
            // Lock badge overlay
            if (showLockBadge)
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFFf093fb)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Upgrade',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
