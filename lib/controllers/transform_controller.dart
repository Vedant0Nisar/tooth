import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TransformController extends GetxController {
  // Camera orbit (syncs from WebView native interaction)
  final RxDouble theta = 30.0.obs; // Horizontal (azimuth) degrees
  final RxDouble phi = 75.0.obs; // Vertical (from top) degrees
  final RxDouble radius = 0.50.obs; // Distance/zoom

  // Pan (camera target offset)
  final RxDouble targetX = 0.0.obs;
  final RxDouble targetY = 0.0.obs;
  final RxDouble targetZ = 0.0.obs;

  // Loading state for ModelViewer
  final RxBool isModelLoaded = false.obs;

  // Lock state
  final RxBool isLocked = false.obs;

  // ── Gizmo / Edit-mode state ─────────────────────────────────────────────
  final RxBool isEditMode = false.obs;
  final RxString gizmoMode = 'rotate'.obs; // 'translate' or 'rotate'

  // Model object rotation (pitch=X, yaw=Y, roll=Z) in degrees
  final RxDouble modelX = 0.0.obs;
  final RxDouble modelY = 0.0.obs;
  final RxDouble modelZ = 0.0.obs;

  // Camera-orbit aliases (for the HUD)
  double get rotationX => phi.value;
  double get rotationY => theta.value;

  void toggleLock() {
    isLocked.value = !isLocked.value;
    _webView?.runJavaScript("window.setLocked(${isLocked.value});");
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    _webView?.runJavaScript("window.setEditMode(${isEditMode.value});");
  }

  /// Push updated model orientation into model-viewer via JS.
  void applyModelRotation() {
    if (_webView == null) return;
    final x = modelX.value;
    final y = modelY.value;
    final z = modelZ.value;
    _webView!.runJavaScript('''
      (function(){
        var mv = document.querySelector('model-viewer');
        if (!mv) return;
        mv.orientation = '${x}deg ${y}deg ${z}deg';
      })();
    ''');
  }

  late final WebViewController controller;
  WebViewController? _webView;

  @override
  void onInit() {
    super.onInit();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'ThreeJSChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _parseThreeJSState(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _initializeModel();
          },
        ),
      );

    _loadStaticHtml();
    _webView = controller;
  }

  Future<void> _loadStaticHtml() async {
    try {
      final html = await rootBundle.loadString('assets/www/index.html');
      // Use a consistent baseUrl to allow CORS for scripts to resolve
      controller.loadHtmlString(html, baseUrl: 'https://appassets.android.com/assets/www/');
    } catch (e) {
      debugPrint("HTML Load error: $e");
    }
  }

  Future<void> _initializeModel() async {
    try {
      final String assetPath = 'assets/maxillary_lateral_incisor_angled.glb';
      debugPrint("THREE_JS_BRIDGE: Injecting GLB via Base64: $assetPath");
      
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      final String base64Model = base64Encode(bytes);

      _webView?.runJavaScript("window.loadModelBase64('$base64Model');");
    } catch (e) {
      debugPrint("Model injection error: $e");
    }
  }

  void _parseThreeJSState(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      final String type = data['type'] ?? 'sync';

      if (type == 'ready') {
        debugPrint("THREE_JS_LOG: JavaScript Environment Ready");
        // We set isModelLoaded to true as soon as the JS ENGINE is alive
        // (The model itself might follow locally via Base64 injection)
        isModelLoaded.value = true; 
        return;
      }

      if (type == 'loaded') {
        debugPrint("THREE_JS_LOG: Model fully loaded into scene: ${data['message']}");
        return;
      }

      if (type == 'debug') {
        debugPrint("THREE_JS_LOG: ${data['message']}");
        return;
      }

      // Sync data...
      modelX.value = (data['rx'] as num).toDouble();
      modelY.value = (data['ry'] as num).toDouble();
      modelZ.value = (data['rz'] as num).toDouble();

      radius.value = (data['zoom'] as num).toDouble();

      targetX.value = (data['targetX'] as num).toDouble();
      targetY.value = (data['targetY'] as num).toDouble();
      targetZ.value = (data['targetZ'] as num).toDouble();
    } catch (e) {
      debugPrint("ThreeJS state parse error: $e. Raw: $jsonString");
    }
  }

  void setGizmoMode(String mode) {
    gizmoMode.value = mode;
    _webView?.runJavaScript("window.setGizmoMode('$mode');");
  }

  void setCameraOrbit(double theta, double phi, double distance) {
    _webView?.runJavaScript("window.setCameraOrbit($theta, $phi, $distance);");
  }

  void viewFront() {
    setCameraOrbit(0, 90, radius.value);
  }

  void viewTop() {
    setCameraOrbit(0, 0, radius.value);
  }

  void viewRight() {
    setCameraOrbit(90, 90, radius.value);
  }

  void viewLeft() {
    setCameraOrbit(-90, 90, radius.value);
  }

  void resetView() {
    _webView?.runJavaScript("window.resetView();");
    theta.value = 0;
    phi.value = 90;
    radius.value = 8.0; // Standard reset distance
    modelX.value = 0;
    modelY.value = 0;
    modelZ.value = 0;
  }
}
