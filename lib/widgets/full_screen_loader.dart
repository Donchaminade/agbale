
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FullScreenLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const FullScreenLoader({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              alignment: Alignment.center,
              child: SpinKitWave(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
            ),
          ),
      ],
    );
  }
}
