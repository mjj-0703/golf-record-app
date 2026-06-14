import 'package:flutter/material.dart';

/// AppBar 用 FeelShot ワードマーク（Feel=グラデ / Shot=コーラル）
class FeelShotTitle extends StatelessWidget {
  const FeelShotTitle({super.key, this.fontSize = 22});

  final double fontSize;

  static const _feelGradient = LinearGradient(
    colors: [Color(0xFF7ED957), Color(0xFF2D9B4E)],
  );

  static const _shotColor = Color(0xFFFF6B4A);

  @override
  Widget build(BuildContext context) {
    final feelStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      height: 1,
    );
    final shotStyle = feelStyle.copyWith(
      color: _shotColor,
      letterSpacing: 0.4,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => _feelGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text('Feel', style: feelStyle.copyWith(color: Colors.white)),
        ),
        Text('Shot', style: shotStyle),
      ],
    );
  }
}
