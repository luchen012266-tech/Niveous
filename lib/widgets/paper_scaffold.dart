import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../palettes.dart';

/// 背景色相旋转矩阵（标准 SVG feColorMatrix 公式）
List<double> hueMatrix(double degrees) {
  final double a = degrees * math.pi / 180.0;
  final double c = math.cos(a);
  final double s = math.sin(a);
  const double lumR = 0.213;
  const double lumG = 0.715;
  const double lumB = 0.072;
  return <double>[
    lumR + c * (1 - lumR) + s * (-lumR),
    lumG + c * (-lumG) + s * (-lumG),
    lumB + c * (-lumB) + s * (1 - lumB),
    0, 0, //
    lumR + c * (-lumR) + s * 0.143,
    lumG + c * (1 - lumG) + s * 0.140,
    lumB + c * (-lumB) + s * (-0.283),
    0, 0, //
    lumR + c * (-lumR) + s * (-(1 - lumR)),
    lumG + c * (-lumG) + s * lumG,
    lumB + c * (1 - lumB) + s * lumB,
    0, 0, //
    0, 0, 0, 1, 0,
  ];
}

/// 饱和度矩阵
List<double> saturationMatrix(double s) {
  const double lr = 0.2126;
  const double lg = 0.7152;
  const double lb = 0.0722;
  final double sr = (1 - s) * lr;
  final double sg = (1 - s) * lg;
  final double sb = (1 - s) * lb;
  return <double>[
    sr + s, sg, sb, 0, 0, //
    sr, sg + s, sb, 0, 0, //
    sr, sg, sb + s, 0, 0, //
    0, 0, 0, 1, 0,
  ];
}

/// 亮度矩阵
List<double> brightnessMatrix(double b) => <double>[
      b, 0, 0, 0, 0, //
      0, b, 0, 0, 0, //
      0, 0, b, 0, 0, //
      0, 0, 0, 1, 0,
    ];

/// 带自定义背景的页面容器：底图 → 纸色遮罩 → 内容。
class PaperScaffold extends StatelessWidget {
  const PaperScaffold({
    super.key,
    required this.child,
    this.opacityOverride,
    this.useAppBackground = true,
    this.showImage = true,
  });

  final Widget child;
  final double? opacityOverride;
  final bool useAppBackground;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    final double op = opacityOverride ??
        (useAppBackground ? s.opApp : s.opRd);

    final String? path = s.bgPath;
    final bool isAsset = path != null && path.startsWith('asset:');
    final bool hasImage = showImage &&
        s.bgEnabled &&
        (useAppBackground ? s.applyApp : s.applyRd) &&
        path != null &&
        (isAsset || File(path).existsSync());

    return Stack(
      children: <Widget>[
        if (hasImage) Positioned.fill(child: _buildImage(s.bgPath!, s)),
        Positioned.fill(
          child: ColoredBox(color: p.paper.withOpacity(1 - op)),
        ),
        child,
      ],
    );
  }

  Widget _buildImage(String path, AppState s) {
    Widget img = path.startsWith('asset:')
        ? Image.asset(path.substring('asset:'.length), fit: BoxFit.cover)
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext c, Object e, StackTrace? st) =>
                const SizedBox.shrink(),
          );
    if (s.blur > 0) {
      img = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: s.blur, sigmaY: s.blur),
        child: img,
      );
    }
    if ((s.hue % 360).abs() > 0.5) {
      img = ColorFiltered(
        colorFilter: ColorFilter.matrix(hueMatrix(s.hue)),
        child: img,
      );
    }
    if ((s.sat - 1).abs() > 0.01) {
      img = ColorFiltered(
        colorFilter: ColorFilter.matrix(saturationMatrix(s.sat)),
        child: img,
      );
    }
    if ((s.bri - 1).abs() > 0.01) {
      img = ColorFiltered(
        colorFilter: ColorFilter.matrix(brightnessMatrix(s.bri)),
        child: img,
      );
    }
    return img;
  }
}

/// 通用设置行
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.label,
    this.sub,
    required this.child,
  });

  final String label;
  final String? sub;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(
                  fontSize: 13.5, color: p.ink, fontWeight: FontWeight.w600)),
          if (sub != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(sub!,
                style: TextStyle(fontSize: 11, color: p.muted, height: 1.5)),
          ],
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// 带数值显示的滑块
class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.display,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String? display;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 12.5, color: p.ink2)),
            ),
            Text(display ?? value.toStringAsFixed(0),
                style: TextStyle(fontSize: 11.5, color: p.muted)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: s.accent,
            thumbColor: Colors.white,
            inactiveTrackColor: p.line,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
