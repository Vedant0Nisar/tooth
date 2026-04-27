import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class LocalAssetsServer {
  HttpServer? _server;
  int port = 8080;
  bool _isRunning = false;

  Future<void> start() async {
    if (_isRunning) return;
    try {
      // Use bind with 0 to auto-assign a free port, avoiding collisions
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      port = _server!.port;
      _isRunning = true;
      debugPrint("LocalAssetsServer running on http://127.0.0.1:$port");

      _server!.listen((HttpRequest request) async {
        String path = request.uri.path;
        if (path == '/') path = '/index.html';
        
        // Map to flutter asset path
        String assetPath = 'assets/www/jaw_sim$path';
        
        try {
          ByteData data = await rootBundle.load(assetPath);
          List<int> bytes = data.buffer.asUint8List();
          
          // Add permissive CORS headers just in case
          request.response.headers.add('Access-Control-Allow-Origin', '*');
          
          if (path.endsWith('.html')) {
            request.response.headers.contentType = ContentType.html;
          } else if (path.endsWith('.js')) {
            request.response.headers.contentType = ContentType.parse('application/javascript');
          } else if (path.endsWith('.css')) {
            request.response.headers.contentType = ContentType.parse('text/css');
          } else if (path.endsWith('.glb')) {
            request.response.headers.contentType = ContentType.parse('model/gltf-binary');
          } else if (path.endsWith('.json')) {
            request.response.headers.contentType = ContentType.parse('application/json');
          } else if (path.endsWith('.png')) {
            request.response.headers.contentType = ContentType.parse('image/png');
          } else if (path.endsWith('.wasm')) {
            request.response.headers.contentType = ContentType.parse('application/wasm');
          }
          
          request.response.add(bytes);
          await request.response.close();
        } catch (e) {
          debugPrint("LocalAssetsServer: 404 Not Found -> $assetPath");
          request.response.statusCode = 404;
          await request.response.close();
        }
      });
    } catch (e) {
      debugPrint("LocalAssetsServer Error: $e");
    }
  }

  void stop() {
    _server?.close();
    _isRunning = false;
  }
}
