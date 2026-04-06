import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transform_controller.dart';

/// Preset-view toolbar on the right side
class ViewToolbar extends StatelessWidget {
  const ViewToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransformController>();

    return Positioned(
      right: 16, top: 0, bottom: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.62),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _btn(Icons.crop_landscape,  'Front',  ctrl.viewFront),
              _btn(Icons.vertical_align_top, 'Top', ctrl.viewTop),
              _btn(Icons.chevron_right,   'Right',  ctrl.viewRight),
              _btn(Icons.chevron_left,    'Left',   ctrl.viewLeft),
              Container(width: 32, height: 1, color: Colors.white24,
                  margin: const EdgeInsets.symmetric(vertical: 4)),
              _btn(Icons.refresh,         'Reset',  ctrl.resetView,
                   color: Colors.orangeAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String tip, VoidCallback onTap,
      {Color color = Colors.white70}) {
    return Tooltip(
      message: tip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
