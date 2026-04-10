import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transform_controller.dart';

/// 3D Axis Gizmo — shows X/Y/Z orientation like Blender / Maya
class AxisGizmo extends StatelessWidget {
  const AxisGizmo({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransformController>();
    return Positioned(
      right: 16,
      top: 48,
      child: Obx(() => Column(
            children: [
              // The gizmo painter
              CustomPaint(
                size: const Size(80, 80),
                painter: _AxisGizmoPainter(
                  theta: ctrl.theta.value,
                  phi: ctrl.phi.value,
                ),
              ),
            ],
          )),
    );
  }

  Widget _angleRow(String label, double val, Color color,
      {String suffix = '°'}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace')),
        const SizedBox(width: 4),
        Text('${val.toStringAsFixed(1)}$suffix',
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
      ],
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────

class _AxisGizmoPainter extends CustomPainter {
  final double theta; // degrees – horizontal azimuth
  final double phi; // degrees – elevation from top

  const _AxisGizmoPainter({required this.theta, required this.phi});

  @override
  void paint(Canvas canvas, Size size) {
    final t = theta * math.pi / 180;
    final p = phi * math.pi / 180;
    final ct = math.cos(t), st = math.sin(t);
    final cp = math.cos(p), sp = math.sin(p);

    // Project world unit-axes to 2D gizmo screen
    //   X → (cos t,   cos p · sin t)
    //   Y → (0,      -sin p)
    //   Z → (-sin t,  cos p · cos t)
    final xDir = Offset(ct, cp * st);
    final yDir = Offset(0, -sp);
    final zDir = Offset(-st, cp * ct);

    // Depth  (positive = behind camera = dimmer)
    final xDepth = sp * st;
    final yDepth = -cp;
    final zDepth = sp * ct;

    final center = Offset(size.width / 2, size.height / 2);
    final len = size.width * 0.36;

    final axes = [
      _AxisInfo('X', xDir, xDepth, const Color(0xFFFF4444)),
      _AxisInfo('Y', yDir, yDepth, const Color(0xFF44EE44)),
      _AxisInfo('Z', zDir, zDepth, const Color(0xFF4499FF)),
    ]..sort((a, b) => a.depth.compareTo(b.depth)); // back-to-front

    // Subtle circle bg
    canvas.drawCircle(center, size.width / 2 - 2,
        Paint()..color = Colors.white.withOpacity(0.04));

    for (final ax in axes) {
      final tip = center + ax.dir * len;
      final negTip = center - ax.dir * (len * 0.5);
      final inFront = ax.depth >= 0;
      final alpha = inFront ? 1.0 : 0.28;

      // Dashed negative axis
      _dashLine(canvas, center, negTip, ax.color.withOpacity(0.18), 1.2);

      // Solid positive axis
      canvas.drawLine(
          center,
          tip,
          Paint()
            ..color = ax.color.withOpacity(alpha)
            ..strokeWidth = inFront ? 2.4 : 1.2
            ..strokeCap = StrokeCap.round);

      // Arrow head
      _arrowHead(canvas, center, tip, ax.color.withOpacity(alpha));

      // Label
      _label(canvas, tip + ax.dir * 10, ax.name, ax.color.withOpacity(alpha));
    }

    // Center dot
    canvas.drawCircle(
        center, 3, Paint()..color = Colors.white.withOpacity(0.9));
  }

  void _dashLine(
      Canvas canvas, Offset from, Offset to, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    const dash = 3.0, gap = 3.0;
    final d = to - from;
    final len = d.distance;
    if (len < 1) return;
    final u = d / len;
    double pos = 0;
    bool drawing = true;
    while (pos < len) {
      final step = drawing ? dash : gap;
      final start = from + u * pos;
      final end = from + u * math.min(pos + step, len);
      if (drawing) canvas.drawLine(start, end, paint);
      pos += step;
      drawing = !drawing;
    }
  }

  void _arrowHead(Canvas canvas, Offset from, Offset tip, Color color) {
    final d = tip - from;
    if (d.distance < 1) return;
    final ang = math.atan2(d.dy, d.dx);
    const L = 8.0, spread = 0.42;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - L * math.cos(ang - spread),
          tip.dy - L * math.sin(ang - spread))
      ..lineTo(tip.dx - L * math.cos(ang + spread),
          tip.dy - L * math.sin(ang + spread))
      ..close();
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  void _label(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_AxisGizmoPainter old) =>
      old.theta != theta || old.phi != phi;
}

class _AxisInfo {
  final String name;
  final Offset dir;
  final double depth;
  final Color color;
  const _AxisInfo(this.name, this.dir, this.depth, this.color);
}
