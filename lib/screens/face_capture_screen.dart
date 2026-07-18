import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../theme/app_theme.dart';

/// شاشة التقاط صورة للتحقق من الحضور.
/// بتتأكد إن فيه وجه واضح جوه الإطار قبل ما تسمح بالالتقاط
/// (اكتشاف وجود وجه فقط — بدون مطابقة هوية بالذكاء الاصطناعي).
class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _controller;
  late final FaceDetector _faceDetector;
  bool _faceDetected = false;
  bool _initializing = true;
  bool _capturing = false;
  String? _errorMessage;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.2,
      ),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _initializing = false);
      _controller!.startImageStream(_processImage);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = 'تعذر الوصول للكاميرا. تأكد من منح صلاحية الكاميرا للتطبيق';
      });
    }
  }

  void _processImage(CameraImage image) async {
    if (_isDetecting || _capturing) return;
    _isDetecting = true;
    try {
      final inputImage = _buildInputImage(image);
      if (inputImage != null) {
        final faces = await _faceDetector.processImage(inputImage);
        if (mounted) {
          setState(() => _faceDetected = faces.isNotEmpty);
        }
      }
    } catch (_) {
      // تجاهل أخطاء الإطارات الفردية أثناء البث المباشر
    }
    _isDetecting = false;
  }

  InputImage? _buildInputImage(CameraImage image) {
    try {
      final camera = _controller!.description;
      final rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final format = Platform.isAndroid
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888;

      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (!_faceDetected || _capturing) return;

    setState(() => _capturing = true);
    try {
      await _controller!.stopImageStream();
      final file = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(File(file.path));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _capturing = false;
        _errorMessage = 'تعذر التقاط الصورة، حاول مرة أخرى';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                  const Expanded(
                    child: Text('تحقق من الهوية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: _faceDetected ? _capture : null,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: _faceDetected ? AppColors.success : Colors.white24,
                      width: 4,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: _capturing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white38, size: 44),
            const SizedBox(height: 12),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
          ],
        ),
      );
    }

    if (_initializing || _controller == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize?.height ?? 0,
              height: _controller!.value.previewSize?.width ?? 0,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
        Container(
          width: 220,
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(
              color: _faceDetected ? AppColors.success : Colors.white70,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(140),
          ),
        ),
        Positioned(
          bottom: 30,
          child: Text(
            _faceDetected ? 'تم رصد الوجه — اضغط للالتقاط' : 'ضع وجهك داخل الإطار',
            style: TextStyle(
              color: _faceDetected ? AppColors.success : Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
            ),
          ),
        ),
      ],
    );
  }
}
