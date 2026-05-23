import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../widgets/bottom_navbar.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  Timer? _timer;
  int _currentIndex = 0;
  DateTime selectedDate = DateTime.now();

  // Cache format agar tidak buat DateFormat baru tiap detik
  static final _fmtDate = DateFormat('d MMMM yyyy');
  static final _fmtTime = DateFormat('HH:mm');
  static final _fmtDateFull = DateFormat('dd MMMM yyyy');
  static final _fmtDateKey = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchTodayStatus();
      context.read<AttendanceProvider>().fetchHistory();
    });

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

  Future<void> _doClockIn() async {
    final provider = context.read<AttendanceProvider>();
    final success = await provider.clockIn(null);
    if (!mounted) return;

    if (success) {
      _showSnackBar('✅ Clock In berhasil!', Colors.green);
    } else {
      _showSnackBar('❌ ${provider.errorMessage ?? 'Clock In gagal'}', Colors.red);
    }
  }

  Future<void> _doClockOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Clock Out'),
        content: const Text('Apakah kamu yakin ingin Clock Out sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B352A)),
            child: const Text('Clock Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    final provider = context.read<AttendanceProvider>();
    final success = await provider.clockOut(null);
    if (!mounted) return;

    if (success) {
      _showSnackBar('✅ Clock Out berhasil!', Colors.green);
    } else {
      _showSnackBar('❌ ${provider.errorMessage ?? 'Clock Out gagal'}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${d.inHours}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

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
            const SizedBox(height: 10),
            _currentStatusCard(),
            const SizedBox(height: 10),
            Expanded(child: _historyList()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
        onLogout: () async {
          final authProvider = context.read<AuthProvider>();
          await authProvider.logout();
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (_) => false);
        },
      ),
    );
  }

  Widget _header() {
    final userName = context.watch<AuthProvider>().currentUser?.name ?? 'Staff';
    final provider = context.watch<AttendanceProvider>();
    final todayStatus = provider.todayStatus;
    
    final isWorking = todayStatus != null && todayStatus.isWorking;
    final hasClocked = todayStatus != null && todayStatus.clockInTime != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
      decoration: const BoxDecoration(
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
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const CircleAvatar(
                backgroundColor: Color(0xFFC67C4E),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isWorking
                      ? const Color(0xFFE6F4EA)
                      : hasClocked
                          ? const Color(0xFFDCE8FF)
                          : const Color(0xFFFFD2CD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  provider.isLoading && todayStatus == null
                      ? 'Memuat...'
                      : isWorking
                          ? 'Sedang Bekerja'
                          : hasClocked
                              ? 'Selesai Bekerja'
                              : 'Belum Clock In',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isWorking
                        ? Colors.green
                        : hasClocked
                            ? Colors.blue
                            : Colors.red,
                  ),
                ),
              ),
              RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Sora',
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '${_fmtDate.format(DateTime.now())}\n',
                    ),
                    TextSpan(
                      text: _fmtTime.format(DateTime.now()),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Buttons
          if (provider.isLoading && todayStatus == null)
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          else if (isWorking)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: provider.isLoading ? 'Loading...' : 'Clock Out',
                    color: const Color(0xFF4B352A),
                    textColor: Colors.white,
                    onTap: provider.isLoading ? null : _doClockOut,
                  ),
                ),
              ],
            )
          else if (!hasClocked)
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                label: provider.isLoading ? 'Loading...' : 'Clock In',
                color: const Color(0xFFC67C4E),
                textColor: Colors.white,
                onTap: provider.isLoading ? null : _doClockIn,
              ),
            )
          else
            const Center(
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
    final provider = context.watch<AttendanceProvider>();
    final today = provider.todayStatus;

    Duration elapsed = Duration.zero;
    if (today != null) {
      final clockInTime = today.clockInTime;
      if (clockInTime != null) {
        final clockIn = DateTime.parse(clockInTime);
        final clockOutTime = today.clockOutTime;
        if (clockOutTime != null) {
          final clockOut = DateTime.parse(clockOutTime);
          elapsed = clockOut.difference(clockIn);
        } else {
          elapsed = DateTime.now().difference(clockIn);
        }
      }
    }

    String formatTime(String? raw) {
      if (raw == null) return '--:--';
      try {
        return DateFormat('HH:mm').format(DateTime.parse(raw));
      } catch (_) {
        return '--:--';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Working Hour',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _formatDuration(elapsed),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('In'),
                  Text(formatTime(today?.clockInTime)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Out'),
                  Text(formatTime(today?.clockOutTime)),
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
    final provider = context.watch<AttendanceProvider>();
    final selectedDateStr = _fmtDateKey.format(selectedDate);
    
    final filtered = provider.history
        .where((item) => item.date == selectedDateStr)
        .toList();

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

        // Status Handler
        if (provider.isLoading && provider.history.isEmpty)
          const SliverFillRemaining(
            child: LoadingWidget(message: 'Memuat histori...'),
          )
        else if (provider.errorMessage != null && provider.history.isEmpty)
          SliverFillRemaining(
            child: AppErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchHistory(),
            ),
          )
        else if (filtered.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('Tidak ada data absensi pada tanggal ini')),
          )
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
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: widget.textColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
