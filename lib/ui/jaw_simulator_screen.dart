import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/jaw_simulator_controller.dart';
import 'jaw_2d_view.dart';
import 'jaw_3d_view.dart';

class JawSimulatorScreen extends StatelessWidget {
  const JawSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JawSimulatorController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: const Text('JAW SIMULATOR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => TextButton.icon(
            onPressed: () {
              if (controller.currentStep.value == SimulatorStep.phase2D) {
                controller.goTo3D();
              } else {
                controller.goTo2D();
              }
            },
            icon: Icon(
              controller.currentStep.value == SimulatorStep.phase2D 
                  ? Icons.view_in_ar_rounded 
                  : Icons.map_rounded,
              color: Colors.blueAccent,
            ),
            label: Text(
              controller.currentStep.value == SimulatorStep.phase2D ? 'GO 3D' : 'GO 2D',
              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
          )),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.currentStep.value == SimulatorStep.phase2D) {
          return const Jaw2DView();
        } else {
          return const Jaw3DView();
        }
      }),
    );
  }
}
