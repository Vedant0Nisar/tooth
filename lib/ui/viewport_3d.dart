import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/transform_controller.dart';

class Viewport3D extends StatelessWidget {
  const Viewport3D({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransformController>();

    return Stack(children: [
      // Background
      Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1E2B3C), Color(0xFF060810)],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
      ),

      // ModelViewer — NATIVE mobile controls: 1-finger rotate, 2-finger pinch+pan
      ModelViewer(
        src: 'assets/Maxillary_Lateral_Incisor_rugved.glb',
        alt: 'Tooth 3D Model',
        ar: false,
        autoRotate: false,
        cameraControls: true,
        disableZoom: false,
        disablePan: false,
        disableTap: true,
        backgroundColor: Colors.transparent,
        onWebViewCreated: (WebViewController wv) {
          ctrl.setWebView(wv);
        },
      ),
    ]);
  }
}
