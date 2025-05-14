import 'dart:math' as math;
import 'dart:ui';

import 'package:advertising_id/advertising_id.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olympus_and_corp/src/core/utils/app_icon.dart';
import 'package:olympus_and_corp/src/core/utils/size_utils.dart';

import '../../../../../routes/route_value.dart';
import '../../../../core/utils/icon_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // 1,5 с — столько же, сколько было в Future.delayed
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )
      ..addListener(() => setState(() {})) // перерисовываем ProgressBar
      ..forward(); // старт анимации

    _startLoading(); // параллельный async-процесс
  }

  Future<void> _startLoading() async {
    // ждём, пока анимация дойдёт до конца
    await _controller.forward().orCancel;

    // любые ваши тяжёлые операции
  //  await AdvertisingId.id(true);

    // даём индикатору успеть «дозалиться» (если нужно)
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) context.go(RouteValue.home.path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.8),
              BlendMode.darken,
            ),
            child: AppIcon(
              asset: "assets/images/Office Corridor.webp",
              height: getHeight(context, percent: 1),
              width: getWidth(context, percent: 1),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SafeArea(
          child: AppIcon(
            asset: IconProvider.logo.buildImageUrl(),
            width: getWidth(context, percent: isIpad(context) ? 0.5: 0.8),
          ),
        ),
        Positioned(
          bottom: getHeight(context, baseSize: 41),
          child: SafeArea(
            child: StitchedProgressBar(value: _controller.value),
          ),
        )
      ],
    );
  }
}

class StitchedProgressBar extends StatelessWidget {
  const StitchedProgressBar({
    super.key,
    required this.value, // 0.0-1.0
    this.width = 220,
    this.height = 22,
    this.backgroundColor = const Color(0xFF442100), // тёмно-коричневый
    this.foregroundColor = const Color(0xFF9AFF35), // салатовый
    this.borderColor = const Color(0xFFFF9A34), // оранжевая «прострочка»
    this.strokeWidth = 2,
    this.dashWidth = 6,
    this.gap = 3,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Текущее значение 0 … 1.
  final double value;

  /// Ширина/высота индикатора.
  final double width;
  final double height;

  /// Цвета задника, заполнения и рамки.
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  /// Параметры «прострочки».
  final double strokeWidth;
  final double dashWidth;
  final double gap;

  /// Скругление; по умолчанию = height / 2 (полная капсула).
  final BorderRadius? borderRadius;

  /// На сколько анимировать смену value.
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(

        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Задний слой
              Container(color: backgroundColor),
              // Заполнение (анимируется)
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: animationDuration,
                  width: width * value.clamp(0.0, 1.0),
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------
///  Painter «простроченной» рамки
/// ------------------------------
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: radius.topLeft,
      topRight: radius.topRight,
      bottomLeft: radius.bottomLeft,
      bottomRight: radius.bottomRight,
    );

    final Path path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double len = math.min(dash, metric.length - distance);
        canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        distance += len + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
