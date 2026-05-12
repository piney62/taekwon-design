import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<Uint8List?> showWebCamera(BuildContext context) =>
    showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _WebCameraDialog(),
    );

class _WebCameraDialog extends StatefulWidget {
  const _WebCameraDialog();

  @override
  State<_WebCameraDialog> createState() => _WebCameraDialogState();
}

class _WebCameraDialogState extends State<_WebCameraDialog> {
  html.VideoElement? _video;
  html.MediaStream? _stream;
  bool _ready = false;
  String? _error;
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'webcam-${DateTime.now().millisecondsSinceEpoch}';
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _video = html.VideoElement()
        ..autoplay = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      _stream = await html.window.navigator.mediaDevices
          ?.getUserMedia({'video': true, 'audio': false});
      _video!.srcObject = _stream;

      ui_web.platformViewRegistry.registerViewFactory(
          _viewId, (int id) => _video!);

      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _capture() {
    final video = _video;
    if (video == null) return;
    final canvas = html.CanvasElement(
        width: video.videoWidth, height: video.videoHeight);
    canvas.context2D.drawImage(video, 0, 0);
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
    final bytes = base64Decode(dataUrl.split(',')[1]);
    Navigator.of(context).pop(Uint8List.fromList(bytes));
  }

  @override
  void dispose() {
    _stream?.getTracks().forEach((t) => t.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('pose.cameraCapture'.tr()),
      content: SizedBox(
        width: 480,
        height: 360,
        child: _error != null
            ? Center(child: Text('${'pose.cameraError'.tr()}: $_error'))
            : _ready
                ? HtmlElementView(viewType: _viewId)
                : const Center(child: CircularProgressIndicator()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('journal.cancel'.tr()),
        ),
        if (_ready)
          FilledButton.icon(
            onPressed: _capture,
            icon: const Icon(Icons.camera_alt),
            label: Text('pose.capture'.tr()),
          ),
      ],
    );
  }
}
