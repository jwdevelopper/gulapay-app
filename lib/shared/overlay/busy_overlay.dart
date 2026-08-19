import 'package:flutter/material.dart';

class BusyOverlay extends StatelessWidget {
  final bool isBusy;
  final Widget child;
  final String? message;

  const BusyOverlay({
    super.key,
    required this.isBusy,
    required this.child,
    this.message
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(absorbing: isBusy, child: child,),
        AnimatedOpacity(opacity: isBusy ? 1 : 0,
         duration: const Duration(milliseconds: 200),
         child: IgnorePointer(
          ignoring: !isBusy,
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ... [
                    const SizedBox(height: 12,),
                    Text(message!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
         ),)
      ],
    );
  }
}