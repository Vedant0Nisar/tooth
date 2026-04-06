
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TransformController extends GetxController {
  // Camera orbit (syncs from WebView native interaction)
  final RxDouble theta  = 30.0.obs;   // Horizontal (azimuth) degrees
  final RxDouble phi    = 75.0.obs;   // Vertical (from top) degrees
  final RxDouble radius = 80.0.obs;   // Distance/zoom

  // Pan (camera target offset)
  final RxDouble targetX = 0.0.obs;
  final RxDouble targetY = 0.0.obs;
  final RxDouble targetZ = 0.0.obs;

  WebViewController? _webView;

  void setWebView(WebViewController wv) {
    _webView = wv;

    // Add JavaScript Channel to listen to model-viewer camera-change events
    _webView!.addJavaScriptChannel(
      'CameraSync',
      onMessageReceived: (JavaScriptMessage message) {
        _parseCameraState(message.message);
      },
    );

    // Inject JS to emit camera state on every change
    Future.delayed(const Duration(milliseconds: 500), () {
      _webView!.runJavaScript('''
        (function() {
          var mv = document.querySelector('model-viewer');
          if (!mv) return;
          
          function emitState() {
            var orbit = mv.getCameraOrbit();
            var target = mv.getCameraTarget();
            // Emit as: theta,phi,radius|x,y,z
            var msg = orbit.theta + ',' + orbit.phi + ',' + orbit.radius + '|' + target.x + ',' + target.y + ',' + target.z;
            CameraSync.postMessage(msg);
          }

          mv.addEventListener('camera-change', emitState);
          
          // Initial emit
          emitState();
        })();
      ''');
    });
  }

  void _parseCameraState(String message) {
    try {
      final parts = message.split('|');
      final orbitParts = parts[0].split(',');
      final targetParts = parts[1].split(',');

      // getCameraOrbit returns radians for angle, and meters for radius.
      final double rawTheta = double.parse(orbitParts[0]);
      final double rawPhi = double.parse(orbitParts[1]);
      final double rawRadius = double.parse(orbitParts[2]);

      // getCameraTarget
      final double rawX = double.parse(targetParts[0]);
      final double rawY = double.parse(targetParts[1]);
      final double rawZ = double.parse(targetParts[2]);

      // Convert radians to degrees for our HUD and Gizmo
      double tDeg = rawTheta * 180.0 / math.pi;
      double pDeg = rawPhi * 180.0 / math.pi;

      // Keep theta bounded nicely between 0 and 360 for UI display
      tDeg = tDeg % 360.0;
      if (tDeg < 0) tDeg += 360.0;

      theta.value = tDeg;
      phi.value = pDeg;
      radius.value = rawRadius; // Or map to percentage if preferred, but raw is fine

      targetX.value = rawX;
      targetY.value = rawY;
      targetZ.value = rawZ;
    } catch (e) {
      debugPrint("Camera state parse error: \$e");
    }
  }

  // ── Preset views (using JS to gently animate to position) ─────────────────
  void _setCamera(double newThetaDeg, double newPhiDeg, String target) {
    if (_webView == null) return;
    // Use the JS property API (not setAttribute) — works with native cameraControls
    final js = '''
      (function(){
        var mv = document.querySelector('model-viewer');
        if (!mv) return;
        mv.cameraOrbit = '${newThetaDeg}deg ${newPhiDeg}deg 100%';
        mv.cameraTarget = '$target';
        mv.jumpCameraToGoal();
      })();
    ''';
    _webView!.runJavaScript(js);
  }

  void viewFront()  { _setCamera(0,   90, 'auto auto auto'); }
  void viewBack()   { _setCamera(180, 90, 'auto auto auto'); }
  void viewTop()    { _setCamera(0,   1,  'auto auto auto'); }
  void viewRight()  { _setCamera(90,  90, 'auto auto auto'); }
  void viewLeft()   { _setCamera(-90, 90, 'auto auto auto'); }

  void resetView()  { _setCamera(30, 75, 'auto auto auto'); }
}
