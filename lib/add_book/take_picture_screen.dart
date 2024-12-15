import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'display_picture_screen.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      var camerasList = await availableCameras();
      if (camerasList.isEmpty) {
        throw Exception('No hay cámaras disponibles.');
      }

      _cameraController = CameraController(
        camerasList.first,
        ResolutionPreset.max,
      );

      await _cameraController!.initialize();
    } catch (e) {
      debugPrint('Error al inicializar la cámara: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tomar una foto')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_cameraController != null) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: CameraPreview(_cameraController!),
                ),
              );
            } else {
              return const Center(
                child: Text('Error: el controlador de la cámara no está inicializado.'),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _takePicture(context);
        },
        child: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }

  void _takePicture(BuildContext context) async {
    var image = await _cameraController?.takePicture();
    if (image != null) {
      var result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: image.path),
        ),
      );
      if (result != null && result.isNotEmpty) {
        Navigator.pop(context, result);
      }
    }
  }
}