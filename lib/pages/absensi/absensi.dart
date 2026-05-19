import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../widgets/bottom_navbar.dart';
import '../../models/attendance_model.dart';
import '../../services/attendance_service.dart';
import '../../services/storage_service.dart';

class AbsensiPage extends StatefulWidget {
  @override
  _AbsensiPageState createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  Timer? _timer;
  int _currentIndex = 0;
  DateTime selectedDate = DateTime.now();

  // Status API
  AttendanceModel? _todayAttendance;
  List<AttendanceModel> _history = [];
  bool _isLoadingStatus = true;
  bool _isLoadingHistory = false;
  bool _isClockinIn = false;
  bool _isClockingOut = false;
  String? _userName;

  // Cache format agar tidak buat DateFormat baru tiap detik
  static final _fmtDate = DateFormat('d MMMM yyyy');
  static final _fmtTime = DateFormat('HH:mm');
  static final _fmtDateFull = DateFormat('dd MMMM yyyy');
  static final _fmtDateKey = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadTodayStatus();
    _loadHistory();

    // Timer hanya update jam header — scope minimal
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final info = await StorageService.getUserInfo();
    if (mounted) {
      setState(() => _userName = info['name'] as String?);
    }
  }

  Future<void> _loadTodayStatus() async {
    setState(() => _isLoadingStatus = true);
    final result = await AttendanceService.getTodayStatus();
    if (!mounted) return;

    setState(() {
      _isLoadingStatus = false;
      if (result['success'] == true && result['data'] != null) {
        _todayAttendance = AttendanceModel.fromJson(
            result['data'] as Map<String, dynamic>);
      }
    });
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    final result = await AttendanceService.getHistory();
    if (!mounted) return;

    setState(() {
      _isLoadingHistory = false;
      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>? ?? [];
        _history = data
            .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    });
  }

  Future<void> _doClockIn() async {
    setState(() => _isClockinIn = true);
    final result = await AttendanceService.clockIn();
    if (!mounted) return;

    setState(() => _isClockinIn = false);

    if (result['success'] == true) {
      _showSnackBar('✅ Clock In berhasil!', Colors.green);
      await _loadTodayStatus();
      await _loadHistory();
    } else {
      _showSnackBar('❌ ${result['message'] ?? 'Clock In gagal'}', Colors.red);
    }
  }

  Future<void> _doClockOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Konfirmasi Clock Out'),
        content: Text('Apakah kamu yakin ingin Clock Out sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4B352A)),
            child: Text('Clock Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isClockingOut = true);
    final result = await AttendanceService.clockOut();
    if (!mounted) return;

    setState(() => _isClockingOut = false);

    if (result['success'] == true) {
      _showSnackBar('✅ Clock Out berhasil!', Colors.green);
      await _loadTodayStatus();
      await _loadHistory();
    } else {
      _showSnackBar(
          '❌ ${result['message'] ?? 'Clock Out gagal'}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${d.inHours}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  Duration _getElapsed() {
    if (_todayAttendance?.clockInTime == null) return Duration.zero;
    final clockIn = DateTime.parse(_todayAttendance!.clockInTime!);

    if (_todayAttendance!.clockOutTime != null) {
      final clockOut = DateTime.parse(_todayAttendance!.clockOutTime!);
      return clockOut.difference(clockIn);
    }

    return DateTime.now().difference(clockIn);
  }

  bool get _isWorking =>
      _todayAttendance != null && _todayAttendance!.isWorking;

  bool get _hasClocked =>
      _todayAttendance != null &&
      _todayAttendance!.clockInTime != null;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/order');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/scan');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/notification');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            SizedBox(height: 10),
            _currentStatusCard(),
            SizedBox(height: 10),
            Expanded(child: _historyList()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
        onLogout: () async {
          await StorageService.clearAll();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (_) => false);
          }
        },
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 25, 20, 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF111111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _userName ?? 'Staff',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CircleAvatar(
                backgroundColor: Color(0xFFC67C4E),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isWorking
                      ? Color(0xFFE6F4EA)
                      : _hasClocked
                          ? Color(0xFFDCE8FF)
                          : Color(0xFFFFD2CD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isLoadingStatus
                      ? 'Memuat...'
                      : _isWorking
                          ? 'Sedang Bekerja'
                          : _hasClocked
                              ? 'Selesai Bekerja'
                              : 'Belum Clock In',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _isWorking
                        ? Colors.green
                        : _hasClocked
                            ? Colors.blue
                            : Colors.red,
                  ),
                ),
              ),
              RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Sora',
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: _fmtDate.format(DateTime.now()) + '\n',
                    ),
                    TextSpan(
                      text: _fmtTime.format(DateTime.now()),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Buttons
          if (_isLoadingStatus)
            Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          else if (_isWorking)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: _isClockingOut ? 'Loading...' : 'Clock Out',
                    color: Color(0xFF4B352A),
                    textColor: Colors.white,
                    onTap: _isClockingOut ? null : _doClockOut,
                  ),
                ),
              ],
            )
          else if (!_hasClocked)
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                label: _isClockinIn ? 'Loading...' : 'Clock In',
                color: Color(0xFFC67C4E),
                textColor: Colors.white,
                onTap: _isClockinIn ? null : _doClockIn,
              ),
            )
          else
            Center(
              child: Text(
                'Sudah selesai bekerja hari ini 👍',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _currentStatusCard() {
    final elapsed = _getElapsed();
    final clockIn = _todayAttendance?.clockInTime;
    final clockOut = _todayAttendance?.clockOutTime;

    String formatTime(String? raw) {
      if (raw == null) return '--:--';
      try {
        return DateFormat('HH:mm').format(DateTime.parse(raw));
      } catch (_) {
        return '--:--';
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Working Hour',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            _formatDuration(elapsed),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('In'),
                  Text(formatTime(clockIn)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Out'),
                  Text(formatTime(clockOut)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Widget _historyList() {
    final selectedDateStr = _fmtDateKey.format(selectedDate);
    final filtered = _history
        .where((item) => item.date == selectedDateStr)
        .toList();

    // Gunakan CustomScrollView agar tidak ada Column tak bounded
    return CustomScrollView(
      slivers: [
        // Filter bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmtDateFull.format(selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),
          ),
        ),

        // Loading
        if (_isLoadingHistory)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        // Kosong
        else if (filtered.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('Tidak ada data absensi')),
          )
        // List item
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = filtered[index];

                Duration dur = Duration.zero;
                if (item.clockInTime != null && item.clockOutTime != null) {
                  dur = DateTime.parse(item.clockOutTime!)
                      .difference(DateTime.parse(item.clockInTime!));
                }

                String formatT(String? raw) {
                  if (raw == null) return '--:--';
                  try {
                    return _fmtTime.format(DateTime.parse(raw));
                  } catch (_) {
                    return '--:--';
                  }
                }

                return Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: ${_formatDuration(dur)}'),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('In: ${formatT(item.clockInTime)}'),
                          Text('Out: ${formatT(item.clockOutTime)}'),
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: filtered.length,
            ),
          ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _scale = 0.96),
      onPointerUp: (_) => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: widget.textColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
