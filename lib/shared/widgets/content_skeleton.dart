import 'package:flutter/material.dart';

/// Shimmer-free skeleton placeholders matching common content layouts.
class ContentSkeleton extends StatelessWidget {
  const ContentSkeleton._({required this.child});

  final Widget child;

  static Widget card({double height = 160}) {
    return ContentSkeleton._(
      child: _SkeletonBox(height: height, borderRadius: 12),
    );
  }

  static Widget listTiles({int count = 5}) {
    return ContentSkeleton._(
      child: Column(
        children: List.generate(
          count,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 12),
            child: Row(
              children: [
                const _SkeletonBox(width: 48, height: 48, borderRadius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SkeletonBox(height: 14, width: double.infinity),
                      SizedBox(height: 8),
                      _SkeletonBox(height: 12, width: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget header() {
    return ContentSkeleton._(
      child: Column(
        children: const [
          _SkeletonBox(height: 16, width: 200),
          SizedBox(height: 12),
          _SkeletonBox(height: 24, width: double.infinity),
          SizedBox(height: 8),
          _SkeletonBox(height: 8, width: double.infinity),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: child);
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final base =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
