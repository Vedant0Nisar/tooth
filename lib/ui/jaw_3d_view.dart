import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../controllers/jaw_simulator_controller.dart';
import '../controllers/tooth_list_controller.dart';
import '../models/tooth_model.dart';

class Jaw3DView extends StatefulWidget {
  const Jaw3DView({super.key});

  @override
  State<Jaw3DView> createState() => _Jaw3DViewState();
}

class _Jaw3DViewState extends State<Jaw3DView> {
  late final WebViewController _webController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    final simulatorController = Get.find<JawSimulatorController>();

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          final data = jsonDecode(message.message);
          if (data['type'] == 'MARKER_TAP') {
            simulatorController.placeToothAt(data['position']);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (!_isInit) {
              await _loadToothModel();
              _isInit = true;
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/www/jaw_viewer.html');

    simulatorController.webViewController = _webController;
  }

  Future<void> _loadToothModel() async {
    try {
      final ByteData data = await rootBundle.load('assets/maxillary_lateral_incisor_angled.glb');
      final Uint8List bytes = data.buffer.asUint8List();
      final String base64Model = base64Encode(bytes);
      await _webController.runJavaScript('window.loadModel("$base64Model")');
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final simulatorController = Get.find<JawSimulatorController>();
    final toothListController = Get.find<ToothListController>();

    return Stack(
      children: [
        // 3D Viewport
        WebViewWidget(controller: _webController),

        // UI Overlays
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomInterface(simulatorController, toothListController),
        ),

        // Lock Toggle
        Positioned(
          top: 20,
          right: 20,
          child: _buildLockToggle(simulatorController),
        ),
        
        // Instructions
        Positioned(
          top: 20,
          left: 20,
          child: _buildStatusInfo(simulatorController),
        ),
      ],
    );
  }

  Widget _buildStatusInfo(JawSimulatorController controller) {
    return Obx(() {
      final active = controller.activePlacementTooth.value;
      if (active == null) return const SizedBox.shrink();
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('READY TO PLACE', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(active.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      );
    });
  }

  Widget _buildLockToggle(JawSimulatorController controller) {
    return Obx(() => IconButton(
      onPressed: controller.toggleLock,
      icon: Icon(controller.isLocked.value ? Icons.lock_rounded : Icons.lock_open_rounded),
      style: IconButton.styleFrom(
        backgroundColor: controller.isLocked.value ? Colors.redAccent : Colors.white24,
        foregroundColor: Colors.white,
      ),
    ));
  }

  Widget _buildBottomInterface(JawSimulatorController simulatorController, ToothListController toothController) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black, Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Column(
        children: [
          // Rotation Slider
          _buildRotationControl(simulatorController),
          
          const Spacer(),
          
          // Horizontal Tooth List
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: toothController.teethList.length,
              itemBuilder: (context, index) {
                final tooth = toothController.teethList[index];
                return _buildToothCard(simulatorController, tooth);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRotationControl(JawSimulatorController controller) {
    return Obx(() {
      if (controller.activePlacementTooth.value == null) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const Icon(Icons.rotate_left, color: Colors.white54, size: 16),
            Expanded(
              child: Slider(
                value: 0, // In a real app we'd track this in controller
                min: -180,
                max: 180,
                activeColor: Colors.blueAccent,
                onChanged: (val) => controller.rotateActive(val),
              ),
            ),
            const Icon(Icons.rotate_right, color: Colors.white54, size: 16),
          ],
        ),
      );
    });
  }

  Widget _buildToothCard(JawSimulatorController controller, ToothModel tooth) {
    return Obx(() {
      final isActive = controller.activePlacementTooth.value?.number == tooth.number;
      return GestureDetector(
        onTap: () => controller.preparePlacement(tooth),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isActive ? Colors.blueAccent : Colors.white10, width: 2),
            boxShadow: isActive ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10)] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tooth.number.toString(),
                style: TextStyle(
                  color: isActive ? Colors.blueAccent : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  tooth.name.split(' ')[0],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
