import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';


//vibration class


class VibrationHelper {
  static void triggerVibration() {
    if (Platform.isAndroid) {
      Vibration.vibrate(duration: 500);
    }
  }
}


// camera  pause class 


class CameraPauseIcon extends StatefulWidget {
  final bool storeTemplate;
  final Function() onPause;
  final Function() onResume;
  final dynamic cameraController;

  const CameraPauseIcon({
    Key? key,
    required this.storeTemplate,
    required this.onPause,
    required this.onResume,
    required this.cameraController,
  }) : super(key: key);

  @override
  _CameraPauseIconState createState() => _CameraPauseIconState();
}

class _CameraPauseIconState extends State<CameraPauseIcon> {
  bool pause = false;
  List<String> cartList = [];
  List<String> scanCodeList = [];
  String? result;

  void _togglePause() async {
    if (!pause) {
      await widget.cameraController.stop();
      setState(() {
        pause = true;
        cartList.clear();
        scanCodeList.clear();
        result = null;
      });
      widget.onPause();
    } else {
      await widget.cameraController.start();
      setState(() {
        pause = false;
        cartList.clear();
        scanCodeList.clear();
        result = null;
      });
      widget.onResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _togglePause,
      iconSize: 27.0,
      icon: Icon(
        pause ? Icons.check_circle_outline : Icons.qr_code,
        color: pause ? Colors.green : Colors.black,
        size: 35,
      ),
    );
  }
}
//class flipCamera

class FlipCameraButton extends StatefulWidget {
  final dynamic flipcameraController;

  const FlipCameraButton({Key? key, required this.flipcameraController})
      : super(key: key);

  @override
  _FlipCameraButtonState createState() => _FlipCameraButtonState();
}

class _FlipCameraButtonState extends State<FlipCameraButton> {
  bool flipCamera = false;

  void _toggleCamera() async {
    await widget.flipcameraController.switchCamera();
    setState(() {
      flipCamera = !flipCamera;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.black,
      iconSize: 35.0,
      icon: const Icon(Icons.flip_camera_ios),
      onPressed: _toggleCamera,
    );
  }
}


class FlashToggleButton extends StatefulWidget {
  final dynamic flashcameraController;

  const FlashToggleButton({Key? key, required this.flashcameraController})
      : super(key: key);

  @override
  _FlashToggleButtonState createState() => _FlashToggleButtonState();
}

class _FlashToggleButtonState extends State<FlashToggleButton> {
  bool flashOn = false;

  void _toggleFlash() async {
    await widget.flashcameraController.toggleTorch();
    setState(() {
      flashOn = !flashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.black,
      iconSize: 35.0,
      icon: Icon(flashOn ? Icons.flashlight_on : Icons.flashlight_off),
      onPressed: _toggleFlash,
    );
  }
}
