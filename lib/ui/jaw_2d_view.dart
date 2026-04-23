import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../controllers/jaw_simulator_controller.dart';
import '../controllers/tooth_list_controller.dart';
import '../models/tooth_model.dart';

class Jaw2DView extends StatelessWidget {
  const Jaw2DView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JawSimulatorController>();
    final toothListController = Get.put(ToothListController());

    return Column(
      children: [
        const SizedBox(height: 20),
        _buildLegend(),
        const SizedBox(height: 40),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The Jaw Arc
              CustomPaint(
                size: const Size(400, 400),
                painter: JawArcPainter(),
              ),
              
              // Interactive Teeth
              ...toothListController.teethList.map((tooth) {
                return _buildInteractiveTooth(controller, tooth);
              }),
              
              // Center Info Panel
              Obx(() {
                final selected = controller.selectedTooth.value;
                if (selected == null) return const Text('SELECT A TOOTH', style: TextStyle(color: Colors.white24, letterSpacing: 2));
                return _buildDetailPanel(selected);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Upper Right', Colors.blueAccent),
        const SizedBox(width: 12),
        _legendItem('Upper Left', Colors.tealAccent),
        const SizedBox(width: 12),
        _legendItem('Lower Left', Colors.orangeAccent),
        const SizedBox(width: 12),
        _legendItem('Lower Right', Colors.purpleAccent),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildInteractiveTooth(JawSimulatorController controller, ToothModel tooth) {
    // Logic to position teeth in an arc
    double angle;
    double radius = 140;
    
    // Tooth number logic (1-16 upper, 17-32 lower)
    if (tooth.number <= 16) {
      // Upper Arch (Top arc)
      // 1 at far right, 8/9 at center, 16 at far left
      angle = (tooth.number - 8.5) * (math.pi / 14) - (math.pi / 2);
    } else {
      // Lower Arch (Bottom arc)
      // 32 at far right, 24/25 at center, 17 at far left
      // We reverse the mapping for lower
      angle = (24.5 - tooth.number) * (math.pi / 14) + (math.pi / 2);
    }

    double x = radius * math.cos(angle);
    double y = radius * math.sin(angle);

    return Positioned(
      left: 200 + x - 15,
      top: 200 + y - 15,
      child: Obx(() {
        final isSelected = controller.selectedTooth.value?.number == tooth.number;
        Color color = _getQuadrantColor(tooth.position);
        
        return GestureDetector(
          onTap: () => controller.selectTooth(tooth),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: isSelected ? 36 : 30,
            height: isSelected ? 36 : 30,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: isSelected ? 3 : 1),
              boxShadow: isSelected ? [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 15, spreadRadius: 5),
              ] : [],
            ),
            child: Center(
              child: Text(
                tooth.number.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailPanel(ToothModel tooth) {
    Color color = _getQuadrantColor(tooth.position);
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TOOTH #${tooth.number}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            tooth.name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            tooth.position.toUpperCase(),
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Color _getQuadrantColor(String position) {
    if (position.contains("Upper Right")) return Colors.blueAccent;
    if (position.contains("Upper Left")) return Colors.tealAccent;
    if (position.contains("Lower Left")) return Colors.orangeAccent;
    return Colors.purpleAccent;
  }
}

class JawArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 35
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw Upper Arch
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 140),
      math.pi + 0.2,
      math.pi - 0.4,
      false,
      paint,
    );

    // Draw Lower Arch
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 140),
      0.2,
      math.pi - 0.4,
      false,
      paint,
    );
    
    // Draw gums subtle fill
    final gumPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: 140), math.pi + 0.2, math.pi - 0.4, false, gumPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: 140), 0.2, math.pi - 0.4, false, gumPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
