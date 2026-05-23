import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:proyek3_mobile/widgets/bottom_navbar.dart';

const List<String> _kategoriTerisi = [
  'food and drink',
  'food',
  'drink',
  'fashion good',
  'fashion',
];
const List<String> _kategoriFurniture = ['home good', 'place'];

class ScanMejaPage extends StatefulWidget {
  const ScanMejaPage({Key? key}) : super(key: key);

  @override
  State<ScanMejaPage> createState() => _ScanMejaPageState();
}

class _ScanMejaPageState extends State<ScanMejaPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;

  bool _isProcessing = false;
  bool _isScanning = true;
  List<DetectedObject> _detectedObjects = [];
  StatusMeja _statusMeja = StatusMeja.menunggu;

  int _frameCountKosong = 0;
  int _frameCountTerisi = 0;
  static const int _frameThreshold = 8;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnim;
  late ObjectDetector _detector;
  Size _imageSize = Size.zero;

  static const Color kDark = Color(0xFF1A1A1A);
  static const Color kBrown = Color(0xFFB5714A);

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnim = CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    );
    _detector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    final back = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );
    _cameraController = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() => _cameraReady = true);
    _cameraController!.startImageStream(_processFrame);
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing || !_isScanning) return;
    _isProcessing = true;
    try {
      _imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes)
        allBytes.putUint8List(plane.bytes);
      final bytes = allBytes.done().buffer.asUint8List();
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: _imageSize,
          rotation: InputImageRotation.rotation90deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
      final objects = await _detector.processImage(inputImage);
      if (!mounted) return;

      bool adaTerisi = false;
      bool adaFurniture = false;
      for (final obj in objects) {
        for (final label in obj.labels) {
          final l = label.text.toLowerCase();
          if (_kategoriTerisi.any((k) => l.contains(k)) &&
              label.confidence > 0.6)
            adaTerisi = true;
          if (_kategoriFurniture.any((k) => l.contains(k)) &&
              label.confidence > 0.5)
            adaFurniture = true;
        }
      }

      setState(() => _detectedObjects = objects);

      if (adaTerisi) {
        _frameCountTerisi++;
        _frameCountKosong = 0;
      } else if (adaFurniture || objects.isEmpty) {
        _frameCountKosong++;
        _frameCountTerisi = 0;
      }

      if (_frameCountTerisi >= 3)
        setState(() => _statusMeja = StatusMeja.terisi);
      else if (_frameCountKosong >= 3)
        setState(() => _statusMeja = StatusMeja.kosong);
      else
        setState(() => _statusMeja = StatusMeja.menunggu);

      if (_frameCountTerisi >= _frameThreshold ||
          _frameCountKosong >= _frameThreshold) {
        final finalStatus = _frameCountTerisi >= _frameThreshold
            ? StatusMeja.terisi
            : StatusMeja.kosong;
        _isScanning = false;
        _frameCountKosong = 0;
        _frameCountTerisi = 0;
        await _cameraController?.stopImageStream();
        HapticFeedback.mediumImpact();
        if (mounted) _showResultSheet(finalStatus);
      }
    } catch (_) {
    } finally {
      _isProcessing = false;
    }
  }

  void _resetScan() async {
    setState(() {
      _isScanning = true;
      _statusMeja = StatusMeja.menunggu;
      _detectedObjects = [];
      _frameCountKosong = 0;
      _frameCountTerisi = 0;
    });
    await _cameraController?.startImageStream(_processFrame);
  }

  void _showResultSheet(StatusMeja status) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _ResultSheet(
        status: status,
        kBrown: kBrown,
        kDark: kDark,
        onScanUlang: () {
          Navigator.pop(context);
          _resetScan();
        },
        onLihatOrder: status == StatusMeja.terisi
            ? () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/daftar-order');
              }
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/daftar-order');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/notification');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
        onLogout: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
      ),
      body: Column(
        children: [
          // ── HEADER GELAP ─────────────────────────────────────
          _Header(onBack: () => Navigator.pop(context)),

          // ── KAMERA + OVERLAY ─────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_cameraReady && _cameraController != null)
                  CameraPreview(_cameraController!)
                else
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFB5714A)),
                        SizedBox(height: 12),
                        Text(
                          'Memuat kamera...',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                if (_cameraReady && _detectedObjects.isNotEmpty)
                  CustomPaint(
                    painter: _BoundingBoxPainter(
                      objects: _detectedObjects,
                      imageSize: _imageSize,
                      screenSize: MediaQuery.of(context).size,
                    ),
                  ),

                _ScanFrame(status: _statusMeja),

                if (_isScanning && _statusMeja == StatusMeja.menunggu)
                  _ScanLine(animation: _scanLineAnim, kBrown: kBrown),

                if (_isScanning && _statusMeja != StatusMeja.menunggu)
                  Align(
                    alignment: const Alignment(0, 0.6),
                    child: _ProgressBar(
                      status: _statusMeja,
                      frameCount: _statusMeja == StatusMeja.terisi
                          ? _frameCountTerisi
                          : _frameCountKosong,
                      frameThreshold: _frameThreshold,
                    ),
                  ),

                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: _BottomLabel(
                    status: _statusMeja,
                    kBrown: kBrown,
                    onTataLetak: () =>
                        Navigator.pushNamed(context, '/tata-letak'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusMeja { menunggu, kosong, terisi }

// ── HEADER ────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 14),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onBack,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Meja',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Arahkan kamera ke area meja',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BOUNDING BOX ──────────────────────────────────────────────
class _BoundingBoxPainter extends CustomPainter {
  final List<DetectedObject> objects;
  final Size imageSize, screenSize;
  _BoundingBoxPainter({
    required this.objects,
    required this.imageSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final obj in objects) {
      if (obj.labels.isEmpty) continue;
      final topLabel = obj.labels.reduce(
        (a, b) => a.confidence > b.confidence ? a : b,
      );
      final isTerisi = _kategoriTerisi.any(
        (k) => topLabel.text.toLowerCase().contains(k),
      );
      final color = isTerisi
          ? const Color(0xFFE53935)
          : const Color(0xFF4CAF50);
      final scaleX = size.width / imageSize.height;
      final scaleY = size.height / imageSize.width;
      final rect = Rect.fromLTRB(
        obj.boundingBox.left * scaleX,
        obj.boundingBox.top * scaleY,
        obj.boundingBox.right * scaleX,
        obj.boundingBox.bottom * scaleY,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final labelText =
          '${topLabel.text} ${(topLabel.confidence * 100).toStringAsFixed(0)}%';
      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final bgTop = (rect.top - 20).clamp(0.0, size.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, bgTop, tp.width + 10, 18),
          const Radius.circular(4),
        ),
        Paint()..color = color,
      );
      tp.paint(canvas, Offset(rect.left + 5, bgTop + 2));
    }
  }

  @override
  bool shouldRepaint(_BoundingBoxPainter old) => old.objects != objects;
}

// ── SCAN FRAME ────────────────────────────────────────────────
class _ScanFrame extends StatelessWidget {
  final StatusMeja status;
  const _ScanFrame({required this.status});

  Color get _cornerColor => switch (status) {
    StatusMeja.kosong => const Color(0xFF4CAF50),
    StatusMeja.terisi => const Color(0xFFE53935),
    _ => Colors.white,
  };

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _FramePainter(cornerColor: _cornerColor),
    child: const SizedBox.expand(),
  );
}

class _FramePainter extends CustomPainter {
  final Color cornerColor;
  _FramePainter({required this.cornerColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 20),
      width: size.width * 0.82,
      height: size.height * 0.5,
    );

    final paint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const double len = 28.0;
    const double r = 14.0;

    void line(Offset a, Offset b) => canvas.drawLine(a, b, paint);
    line(
      Offset(rect.left + r, rect.top),
      Offset(rect.left + r + len, rect.top),
    );
    line(
      Offset(rect.left, rect.top + r),
      Offset(rect.left, rect.top + r + len),
    );
    line(
      Offset(rect.right - r, rect.top),
      Offset(rect.right - r - len, rect.top),
    );
    line(
      Offset(rect.right, rect.top + r),
      Offset(rect.right, rect.top + r + len),
    );
    line(
      Offset(rect.left + r, rect.bottom),
      Offset(rect.left + r + len, rect.bottom),
    );
    line(
      Offset(rect.left, rect.bottom - r),
      Offset(rect.left, rect.bottom - r - len),
    );
    line(
      Offset(rect.right - r, rect.bottom),
      Offset(rect.right - r - len, rect.bottom),
    );
    line(
      Offset(rect.right, rect.bottom - r),
      Offset(rect.right, rect.bottom - r - len),
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.cornerColor != cornerColor;
}

// ── SCAN LINE ─────────────────────────────────────────────────
class _ScanLine extends StatelessWidget {
  final Animation<double> animation;
  final Color kBrown;
  const _ScanLine({required this.animation, required this.kBrown});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameH = size.height * 0.5;
    final frameTop = size.height / 2 - 20 - frameH / 2;
    final frameLeft = size.width * 0.09;
    final frameWidth = size.width * 0.82;

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Positioned(
        left: frameLeft + 10,
        top: frameTop + animation.value * (frameH - 4),
        child: Container(
          width: frameWidth - 20,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                kBrown.withValues(alpha: 0.8),
                kBrown,
                kBrown.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
            boxShadow: [
              BoxShadow(
                color: kBrown.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PROGRESS BAR ──────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final StatusMeja status;
  final int frameCount, frameThreshold;
  const _ProgressBar({
    required this.status,
    required this.frameCount,
    required this.frameThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final color = status == StatusMeja.terisi
        ? const Color(0xFFE53935)
        : const Color(0xFF4CAF50);
    final progress = (frameCount / frameThreshold).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status == StatusMeja.terisi
                ? 'Mengkonfirmasi meja terisi...'
                : 'Mengkonfirmasi meja kosong...',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              color: color,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── LABEL BAWAH ───────────────────────────────────────────────
class _BottomLabel extends StatelessWidget {
  final StatusMeja status;
  final Color kBrown;
  final VoidCallback onTataLetak;
  const _BottomLabel({
    required this.status,
    required this.kBrown,
    required this.onTataLetak,
  });

  String get _label => switch (status) {
    StatusMeja.kosong => 'Meja Kosong Terdeteksi',
    StatusMeja.terisi => 'Meja Terisi Terdeteksi',
    _ => 'Arahkan kamera ke meja',
  };
  Color get _color => switch (status) {
    StatusMeja.kosong => const Color(0xFF4CAF50),
    StatusMeja.terisi => const Color(0xFFE53935),
    _ => Colors.white,
  };
  IconData get _icon => switch (status) {
    StatusMeja.kosong => Icons.chair_outlined,
    StatusMeja.terisi => Icons.people_outline_rounded,
    _ => Icons.document_scanner_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, color: _color, size: 16),
              const SizedBox(width: 8),
              Text(
                _label,
                style: TextStyle(
                  color: _color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTataLetak,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: kBrown,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kBrown.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.table_restaurant_outlined,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'Tata Letak Meja',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── RESULT SHEET ──────────────────────────────────────────────
class _ResultSheet extends StatelessWidget {
  final StatusMeja status;
  final Color kBrown, kDark;
  final VoidCallback onScanUlang;
  final VoidCallback? onLihatOrder;
  const _ResultSheet({
    required this.status,
    required this.kBrown,
    required this.kDark,
    required this.onScanUlang,
    this.onLihatOrder,
  });

  @override
  Widget build(BuildContext context) {
    final bool terisi = status == StatusMeja.terisi;
    final Color statusColor = terisi
        ? const Color(0xFFE53935)
        : const Color(0xFF4CAF50);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                terisi ? Icons.people_outline_rounded : Icons.chair_outlined,
                color: statusColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              terisi ? 'Meja Terisi' : 'Meja Kosong',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                terisi
                    ? 'Terdeteksi ada orang atau makanan di meja ini'
                    : 'Tidak ada orang atau makanan — meja siap digunakan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onScanUlang,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Scan Ulang',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                if (terisi && onLihatOrder != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onLihatOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lihat Order',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
