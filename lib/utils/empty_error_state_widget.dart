import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyStateWidget extends StatelessWidget {
  final double? height;
  final double? width;

  const EmptyStateWidget({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/animation/empty_lottie.json', height: 10, repeat: true);
  }
}

class ErrorStateWidget extends StatelessWidget {
  final double? height;
  final double? width;

  const ErrorStateWidget({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/animation/error_lottie.json', height: 1, repeat: true);
  }
}
