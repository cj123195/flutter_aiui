import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 波纹动画的每一项配置
class WaveConfig {
  const WaveConfig({
    this.color,
    this.gradients,
    this.begin,
    this.end,
    this.duration = 6000,
    this.heightFactor = 0.2,
    this.amplitudes = 10,
    this.wavePhase = 10.0,
    this.frequency = 1.6,
    this.blur,
  });

  /// 波纹的颜色
  final Color? color;

  /// 渐变色
  final List<Color>? gradients;

  /// 渐变开始位置
  ///
  /// 默认为[Alignment.topCenter]
  final Alignment? begin;

  /// 渐变结束位置
  ///
  /// 默认为[Alignment.topCenter]
  final Alignment? end;

  /// 动画时间
  ///
  /// 即动画执行一次的时间
  final int duration;

  /// 波纹与容器的高度比
  ///
  /// 默认为0.2
  final double heightFactor;

  /// 模糊
  final MaskFilter? blur;

  /// 振幅
  ///
  /// 默认为10.0
  final double amplitudes;

  /// 波项
  ///
  /// 默认为10.0
  final double wavePhase;

  /// 频率
  ///
  /// 默认为1.6
  final double frequency;
}

/// 波纹效果展示组件。
///
/// 允许用户配置波纹的颜色、振幅、时间等。
///
/// 另请参阅:
///
///  * [WaveConfig], 配置实体。
class Wave extends StatelessWidget {
  const Wave({
    required this.configs,
    super.key,
    this.duration = 6000,
    this.backgroundColor,
    this.backgroundImage,
    this.isLoop = true,
  });

  /// 配置列表
  ///
  /// 具体配置可查看[WaveConfig]
  final List<WaveConfig> configs;

  /// 动画持续时间
  ///
  /// 与[WaveConfig]的[duration]不同，用于控制动画的持续时间。
  final int duration;

  /// 填充背景色
  ///
  /// 容器的背景色，一般与波纹的颜色搭配使用
  final Color? backgroundColor;

  /// 填充背景图片
  final DecorationImage? backgroundImage;

  /// 是否循环动画
  ///
  /// 为true时展示一个不断循环的动画
  /// false时，则会在在时间到达[duration]处停止动画
  final bool isLoop;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, image: backgroundImage),
      child: Stack(
        fit: StackFit.expand,
        children: configs.map((config) {
          return SingleWave(
            config: config,
            isLoop: isLoop,
            duration: duration,
          );
        }).toList(),
      ),
    );
  }
}

/// 单条波浪
class SingleWave extends StatefulWidget {
  const SingleWave({
    required this.config,
    super.key,
    this.isLoop = true,
    this.duration = 6000,
  });

  final WaveConfig config;
  final bool isLoop;
  final int duration;

  @override
  State<SingleWave> createState() => _SingleWaveState();
}

class _SingleWaveState extends State<SingleWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Timer? _timer;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.config.duration),
    );
    final CurvedAnimation curve =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _animation = Tween<double>(
      begin: widget.config.wavePhase,
      end: 360 + widget.config.wavePhase,
    ).animate(curve);
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          _controller.forward();
          break;
        case AnimationStatus.completed:
          _controller.reverse();
          break;
        default:
          break;
      }
    });
    _controller.forward();

    if (!widget.isLoop) {
      _timer = Timer(Duration(milliseconds: widget.duration), () {
        _controller.stop();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(
            animation: _animation,
            waveFrequency: widget.config.frequency,
            waveAmplitude: widget.config.amplitudes,
            heightFactor: widget.config.heightFactor,
            color: widget.config.color,
            blur: widget.config.blur,
            gradient: widget.config.gradients,
            gradientBegin: widget.config.begin,
            gradientEnd: widget.config.end,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.animation,
    required this.waveFrequency,
    required this.waveAmplitude,
    required this.heightFactor,
    this.color,
    this.gradient,
    this.gradientBegin,
    this.gradientEnd,
    this.blur,
  });

  final Color? color;
  final List<Color>? gradient;
  final Alignment? gradientBegin;
  final Alignment? gradientEnd;
  final MaskFilter? blur;
  final Animation<double> animation;
  final double waveFrequency;
  final double waveAmplitude;
  final double heightFactor;

  double _tempA = 0.0;
  double _tempB = 0.0;
  double _viewWidth = 0.0;

  double _getSinY(double startRadius, double waveFrequency, int currPosition) {
    if (_tempA == 0) {
      _tempA = math.pi / _viewWidth;
    }
    if (_tempB == 0) {
      _tempB = 2 * math.pi / 360.0;
    }

    return math.sin(
      _tempA * waveFrequency * (currPosition + 1) + startRadius * _tempB,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * (heightFactor + 0.1);
    _viewWidth = size.width;
    final double phase = animation.value * 2 + 30;

    final Path path = Path();
    path.moveTo(
      0.0,
      centerY + waveAmplitude * _getSinY(phase, waveFrequency, -1),
    );
    for (int i = 0; i < size.width + 1; i++) {
      path.lineTo(
        i.toDouble(),
        centerY + waveAmplitude * _getSinY(phase, waveFrequency, i),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();

    final Paint paint = Paint();
    if (color != null) {
      paint.color = color!;
    }
    if (gradient != null) {
      final Rect rect =
          Offset.zero & Size(size.width, size.height - centerY * heightFactor);
      paint.shader = LinearGradient(
        colors: gradient!,
        begin: gradientBegin ?? Alignment.bottomCenter,
        end: gradientEnd ?? Alignment.topCenter,
      ).createShader(rect);
    }
    if (blur != null) {
      paint.maskFilter = blur;
    }
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return true;
  }
}
