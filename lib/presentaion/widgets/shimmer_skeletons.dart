import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCircle extends StatelessWidget {
  final double size;
  const ShimmerCircle({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ShimmerLine extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  const ShimmerLine({super.key, this.height = 12, this.width = double.infinity, this.borderRadius = const BorderRadius.all(Radius.circular(6))});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        ShimmerCircle(size: 48),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLine(height: 14, width: 140),
              SizedBox(height: 8),
              ShimmerLine(height: 12, width: 100),
            ],
          ),
        ),
      ],
    );
  }
}

class ShimmerCardGrid extends StatelessWidget {
  final int count;
  const ShimmerCardGrid({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final itemWidth = (width - 48) / 2;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(count, (index) {
        return Container(
          width: itemWidth,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: const [
              ShimmerCircle(size: 28),
              SizedBox(height: 8),
              ShimmerLine(height: 16, width: 80),
              SizedBox(height: 4),
              ShimmerLine(height: 12, width: 60),
              SizedBox(height: 2),
              ShimmerLine(height: 10, width: 100),
            ],
          ),
        );
      }),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  const ShimmerList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: ShimmerListTile(),
          ),
        );
      },
    );
  }
}
