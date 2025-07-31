import 'package:flutter/material.dart';

class BouncingDots extends StatefulWidget {
  const BouncingDots({super.key});

  @override
  State<BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      controller.repeat(
        reverse: true,
        period: Duration(milliseconds: 300 * (i + 1)),
      );
      return controller;
    });

    _animations =
        _controllers
            .map(
              (controller) => Tween<double>(begin: 0, end: 8).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
            )
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8 + _animations[i].value,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
