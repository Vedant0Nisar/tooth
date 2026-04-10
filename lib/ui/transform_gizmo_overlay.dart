import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transform_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  TransformGizmoOverlay
//  Blender-style 3-ring rotation gizmo.
//  • Red   ring  → X-axis (pitch / tilt)
//  • Green ring  → Y-axis (yaw   / spin)
//  • Blue  ring  → Z-axis (roll)
//  Shown only while ctrl.isEditMode == true.
// ─────────────────────────────────────────────────────────────────────────────
class TransformGizmoOverlay extends StatelessWidget {
  const TransformGizmoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransformController>();

    return Obx(() {
      if (!ctrl.isEditMode.value) return const SizedBox.shrink();

      return Stack(
        children: [
          // Semi-transparent dim to signal edit mode
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          // Three interactive rings — centered on screen
          Center(
            child: Obx(
              () => _GizmoWidget(
                modelX: ctrl.modelX.value,
                modelY: ctrl.modelY.value,
                modelZ: ctrl.modelZ.value,
                onDragX: (delta) {
                  ctrl.modelX.value =
                      (ctrl.modelX.value + delta) % 360.0;
                  if (ctrl.modelX.value < 0) ctrl.modelX.value += 360.0;
                  ctrl.applyModelRotation();
                },
                onDragY: (delta) {
                  ctrl.modelY.value =
                      (ctrl.modelY.value + delta) % 360.0;
                  if (ctrl.modelY.value < 0) ctrl.modelY.value += 360.0;
                  ctrl.applyModelRotation();
                },
                onDragZ: (delta) {
                  ctrl.modelZ.value =
                      (ctrl.modelZ.value + delta) % 360.0;
                  if (ctrl.modelZ.value < 0) ctrl.modelZ.value += 360.0;
                  ctrl.applyModelRotation();
                },
              ),
            ),
          ),

          // DONE button — top-center
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: ctrl.toggleEditMode,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1AE86B).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1AE86B).withOpacity(0.45),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.black, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'DONE',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Live X / Y / Z readout bar — bottom-center
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _axisChip('X', ctrl.modelX.value,
                          const Color(0xFFFF4444)),
                      const SizedBox(width: 16),
                      _axisChip('Y', ctrl.modelY.value,
                          const Color(0xFF44EE44)),
                      const SizedBox(width: 16),
                      _axisChip('Z', ctrl.modelZ.value,
                          const Color(0xFF4499FF)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _axisChip(String label, double val, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace'),
        ),
        Text(
          '${val.toStringAsFixed(1)}°',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'monospace'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _GizmoWidget — handles touch routing to the correct ring
// ─────────────────────────────────────────────────────────────────────────────
class _GizmoWidget extends StatefulWidget {
  final double modelX, modelY, modelZ;
  final ValueChanged<double> onDragX, onDragY, onDragZ;

  const _GizmoWidget({
    required this.modelX,
    required this.modelY,
    required this.modelZ,
    required this.onDragX,
    required this.onDragY,
    required this.onDragZ,
  });

  @override
  State<_GizmoWidget> createState() => _GizmoWidgetState();
}

class _GizmoWidgetState extends State<_GizmoWidget> {
  static const double kSize  = 260.0;
  static const double rOuter = 110.0; // X ring radius
  static const double rMid   = 85.0;  // Y ring radius
  static const double rInner = 60.0;  // Z ring radius
  static const double hitTol = 16.0;  // px tolerance for hit tests

  int _activeRing = 0; // 0=none 1=X 2=Y 3=Z
  Offset? _lastPos;

  Offset get _center => const Offset(kSize / 2, kSize / 2);

  int _hitTest(Offset p) {
    final d = (p - _center).distance;
    if ((d - rOuter).abs() < hitTol) return 1;
    if ((d - rMid).abs()   < hitTol) return 2;
    if ((d - rInner).abs() < hitTol) return 3;
    return 0;
  }

  double _angleDelta(Offset prev, Offset curr) {
    final a1 = math.atan2((prev - _center).dy, (prev - _center).dx);
    final a2 = math.atan2((curr - _center).dy, (curr - _center).dx);
    double d = (a2 - a1) * 180.0 / math.pi;
    // wrap to (-180, 180]
    if (d > 180) d -= 360;
    if (d < -180) d += 360;
    return d;
  }

  void _onStart(DragStartDetails d) {
    _activeRing = _hitTest(d.localPosition);
    _lastPos = d.localPosition;
  }

  void _onUpdate(DragUpdateDetails d) {
    if (_activeRing == 0 || _lastPos == null) return;
    final delta = _angleDelta(_lastPos!, d.localPosition);
    switch (_activeRing) {
      case 1: widget.onDragX(delta); break;
      case 2: widget.onDragY(delta); break;
      case 3: widget.onDragZ(delta); break;
    }
    _lastPos = d.localPosition;
    setState(() {}); // repaint activeRing highlight
  }

  void _onEnd(DragEndDetails _) {
    _activeRing = 0;
    _lastPos = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onStart,
      onPanUpdate: _onUpdate,
      onPanEnd: _onEnd,
      child: CustomPaint(
        size: const Size(kSize, kSize),
        painter: _GizmoPainter(
          modelX: widget.modelX,
          modelY: widget.modelY,
          modelZ: widget.modelZ,
          activeRing: _activeRing,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _GizmoPainter — draws the 3 colored Blender-style rings
// ─────────────────────────────────────────────────────────────────────────────
class _GizmoPainter extends CustomPainter {
  final double modelX, modelY, modelZ;
  final int activeRing;

  const _GizmoPainter({
    required this.modelX,
    required this.modelY,
    required this.modelZ,
    required this.activeRing,
  });

  static const double rOuter = _GizmoWidgetState.rOuter;
  static const double rMid   = _GizmoWidgetState.rMid;
  static const double rInner = _GizmoWidgetState.rInner;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw back to front so labels don't overlap badly
    _drawRing(canvas, center, rOuter, const Color(0xFFFF4444),
        activeRing == 1, modelX * math.pi / 180, 'X');
    _drawRing(canvas, center, rMid, const Color(0xFF44EE44),
        activeRing == 2, modelY * math.pi / 180, 'Y');
    _drawRing(canvas, center, rInner, const Color(0xFF4499FF),
        activeRing == 3, modelZ * math.pi / 180, 'Z');

    // Center dot
    canvas.drawCircle(
        center, 5, Paint()..color = Colors.white.withOpacity(0.9));
  }

  void _drawRing(Canvas canvas, Offset center, double r, Color color,
      bool active, double angleRad, String label) {
    final ringW = active ? 14.0 : 8.0;

    // Glow halo when active
    if (active) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = color.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW * 3.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // Main ring
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = active ? color : color.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringW
        ..strokeCap = StrokeCap.round,
    );

    // Angle marker dot on the ring
    final mx = center.dx + r * math.cos(angleRad);
    final my = center.dy + r * math.sin(angleRad);
    canvas.drawCircle(
      Offset(mx, my),
      active ? 8 : 5,
      Paint()..color = active ? Colors.white : color.withOpacity(0.9),
    );

    // Axis label
    final lx = center.dx + (r + 18) * math.cos(angleRad + 0.45);
    final ly = center.dy + (r + 18) * math.sin(angleRad + 0.45);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
            color: active ? Colors.white : color.withOpacity(0.85),
            fontSize: active ? 14 : 11,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
  }

  @override
  bool shouldRepaint(_GizmoPainter old) =>
      old.modelX != modelX ||
      old.modelY != modelY ||
      old.modelZ != modelZ ||
      old.activeRing != activeRing;
}
