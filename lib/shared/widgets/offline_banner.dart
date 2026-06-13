import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/shared/theme/paedia_tokens.dart';

bool isConnectivityOffline(List<ConnectivityResult>? results) {
  if (results == null || results.isEmpty) {
    return false;
  }
  return results.every((r) => r == ConnectivityResult.none);
}

/// Banner shown when the device has no network connectivity.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  final Connectivity _connectivity = Connectivity();
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _refreshConnectivity();
    _connectivity.onConnectivityChanged.listen(_handleConnectivity);
  }

  Future<void> _refreshConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivity(results);
  }

  void _handleConnectivity(List<ConnectivityResult> results) {
    final offline = isConnectivityOffline(results);
    if (offline == _offline || !mounted) return;
    setState(() => _offline = offline);
  }

  @override
  Widget build(BuildContext context) {
    if (!_offline) return const SizedBox.shrink();

    final tokens = context.paediaTokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'You are offline',
      child: Container(
        width: double.infinity,
        color: tokens.offline.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: tokens.offline,
              size: 20,
              semanticLabel: 'Offline',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You are offline. Some content may be unavailable.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
