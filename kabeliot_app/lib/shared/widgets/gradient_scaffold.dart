import 'package:flutter/material.dart';
import '../../core/theme/app_decorations.dart';
import 'iot_grid_painter.dart';

/// Tüm ekranlar için standart koyu gradient arka plan.
/// [showGrid] ile IoT devre grid overlay gösterilebilir.
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.child,
    this.showGrid = true,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final bool showGrid;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: DecoratedBox(
        decoration: Theme.of(context).brightness == Brightness.dark
            ? AppDecorations.screenBackground
            : AppDecorations.screenBackgroundLight,
        child: showGrid
            ? Stack(
                children: [
                  const Positioned.fill(
                    child: CustomPaint(painter: IoTGridPainter()),
                  ),
                  child,
                ],
              )
            : child,
      ),
    );
  }
}
