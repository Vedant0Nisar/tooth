import 'package:get/get.dart';
import '../models/tooth_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

enum SimulatorStep { phase2D, phase3D }

class JawSimulatorController extends GetxController {
  var currentStep = SimulatorStep.phase2D.obs;
  var selectedTooth = Rxn<ToothModel>();
  
  // Placement state
  var placedTeeth = <int, ToothModel>{}.obs; // Key: position number, Value: placed tooth
  var activePlacementTooth = Rxn<ToothModel>();
  var isLocked = false.obs;

  late WebViewController webViewController;

  void selectTooth(ToothModel tooth) {
    selectedTooth.value = tooth;
  }

  void goTo3D() {
    currentStep.value = SimulatorStep.phase3D;
  }

  void goTo2D() {
    currentStep.value = SimulatorStep.phase2D;
  }

  void preparePlacement(ToothModel tooth) {
    activePlacementTooth.value = tooth;
  }

  void placeToothAt(int position) {
    if (activePlacementTooth.value != null) {
      placedTeeth[position] = activePlacementTooth.value!;
      
      // Notify JS to move model
      final moveMsg = {
        'type': 'PLACE_TOOTH',
        'position': position,
        'toothId': activePlacementTooth.value!.number,
      };
      webViewController.runJavaScript('window.handleFlutterMessage(${jsonEncode(moveMsg)})');
      
      // Auto-lock when selecting/finishing one
      isLocked.value = true;
    }
  }

  void rotateActive(double angle) {
     final rotMsg = {
        'type': 'ROTATE_TOOTH',
        'angle': angle,
      };
      webViewController.runJavaScript('window.handleFlutterMessage(${jsonEncode(rotMsg)})');
  }

  void toggleLock() {
    isLocked.value = !isLocked.value;
    final lockMsg = {
      'type': 'SET_LOCK',
      'value': isLocked.value,
    };
    webViewController.runJavaScript('window.handleFlutterMessage(${jsonEncode(lockMsg)})');
  }
}
