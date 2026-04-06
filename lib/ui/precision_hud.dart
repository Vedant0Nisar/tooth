import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transform_controller.dart';

class PrecisionHUD extends StatelessWidget {
  const PrecisionHUD({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransformController>();

    return Positioned(
      top: 48, left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12)],
        ),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('H-Orbit', '${ctrl.theta.value.toStringAsFixed(1)}°', Colors.orange),
              const SizedBox(height: 5),
              _row('V-Orbit', '${ctrl.phi.value.toStringAsFixed(1)}°',   Colors.cyanAccent),
              const SizedBox(height: 5),
              _row('Zoom   ', '${ctrl.radius.value.toStringAsFixed(0)}%', Colors.greenAccent),
              const SizedBox(height: 5),
              _row('Pan    ',
                  '${ctrl.targetX.value.toStringAsFixed(2)}  ${ctrl.targetY.value.toStringAsFixed(2)}',
                  Colors.white70),
            ],
          );
        }),
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label,
          style: const TextStyle(
              color: Colors.white54, fontSize: 11,
              fontFamily: 'monospace', fontWeight: FontWeight.w600)),
      const SizedBox(width: 8),
      Text(value,
          style: TextStyle(
              color: valueColor, fontSize: 12, fontFamily: 'monospace')),
    ],
  );
}
