import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lottie/lottie.dart';
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
            colors: [Color(0xFF393939), Color(0xFF222222)],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
      ),

      // Three.js WebView — Custom high-performance 3D editor
      WebViewWidget(controller: ctrl.controller),

      // Interaction Blocker for Lock State ONLY
      Obx(() {
        if (ctrl.isLocked.value) {
          return Positioned.fill(
            child: GestureDetector(
              onPanDown: (_) {},
              onScaleStart: (_) {},
              child: Container(color: Colors.transparent),
            ),
          );
        }
        return const SizedBox.shrink();
      }),

      // Control Panel overlay (XYZ Rotation, Lock, Reset)
      Positioned(
        left: 16,
        top: 48,
        child: _buildControlPanel(ctrl),
      ),

      // Outer Space Lottie Loader Overlay
      Obx(() {
        if (!ctrl.isModelLoaded.value) {
          return Container(
            color: const Color(0xFF060810),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                            strokeWidth: 2,
                          ),
                        ),
                        Lottie.asset(
                          'assets/tooth_loader.json',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error_outline,
                                  color: Colors.blueAccent, size: 50),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Acquiring 3D Coordinates...',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(color: Colors.blueAccent, blurRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    ]);
  }

  Widget _buildControlPanel(TransformController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TRANSFORM',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() => _rotRow('Rot X:', ctrl.modelX.value, Colors.cyanAccent)),
          const SizedBox(height: 4),
          Obx(() => _rotRow('Rot Y:', ctrl.modelY.value, Colors.orange)),
          const SizedBox(height: 4),
          Obx(() =>
              _rotRow('Rot Z:', ctrl.modelZ.value, const Color(0xFF4499FF))),
          const SizedBox(height: 4),
          Obx(() => _rotRow('Zoom:', ctrl.radius.value, Colors.greenAccent,
              suffix: '%')),
          const SizedBox(height: 4),
          Obx(() => _panRow('Pan:', ctrl.targetX.value, ctrl.targetY.value)),
          const SizedBox(height: 12),
          Container(height: 1, width: 120, color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => _iconBtn(
                    ctrl.isLocked.value ? Icons.lock : Icons.lock_open,
                    ctrl.isLocked.value ? 'Unlock' : 'Lock',
                    ctrl.toggleLock,
                    color:
                        ctrl.isLocked.value ? Colors.redAccent : Colors.white70,
                  )),
              const SizedBox(width: 6),
              Obx(() => _iconBtn(
                    ctrl.isEditMode.value ? Icons.check_circle : Icons.edit,
                    ctrl.isEditMode.value ? 'Done' : 'Edit',
                    ctrl.toggleEditMode,
                    color: ctrl.isEditMode.value
                        ? const Color(0xFF1AE86B)
                        : Colors.white70,
                  )),
              const SizedBox(width: 6),
              _iconBtn(Icons.refresh, 'Reset', ctrl.resetView),
            ],
          ),
          const SizedBox(height: 8),
          // MOVE / ROTATE MODE TOGGLE (Visible only in Edit Mode)
          Obx(() {
            if (!ctrl.isEditMode.value) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modeBtn(
                  Icons.open_with_rounded,
                  'Move',
                  () => ctrl.setGizmoMode('translate'),
                  ctrl.gizmoMode.value == 'translate',
                ),
                const SizedBox(width: 8),
                _modeBtn(
                  Icons.rotate_right_rounded,
                  'Rotate',
                  () => ctrl.setGizmoMode('rotate'),
                  ctrl.gizmoMode.value == 'rotate',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _modeBtn(IconData icon, String label, VoidCallback onTap, bool active) {
    final color = active ? Colors.yellowAccent : Colors.white60;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? Colors.yellowAccent.withOpacity(0.5) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _rotRow(String label, double val, Color c, {String suffix = '°'}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 45,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace')),
        ),
        SizedBox(
          width: 65,
          child: Text('${val.toStringAsFixed(1)}$suffix',
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: c,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
        ),
      ],
    );
  }

  Widget _panRow(String label, double x, double y) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 45,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace')),
        ),
        SizedBox(
          width: 65,
          child: Text('${x.toStringAsFixed(1)} ${y.toStringAsFixed(1)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, String label, VoidCallback onTap,
      {Color color = Colors.white70}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
