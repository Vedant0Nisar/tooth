import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transform_controller.dart';
import 'viewport_3d.dart';
import 'precision_hud.dart';
import 'toolbar.dart';
import 'navigation_bar.dart';
import 'axis_gizmo.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TransformController());

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Viewport3D(),
          PrecisionHUD(),
          ViewToolbar(),
          AxisGizmo(),
          BottomBar(),
        ],
      ),
    );
  }
}
