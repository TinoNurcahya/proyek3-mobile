import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../widgets/bottom_navbar.dart';

class AbsensiPage extends StatefulWidget {
  @override
  _AbsensiPageState createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  DateTime? clockInTime;
  DateTime? clockOutTime;
  Timer? _timer;
  bool isWorking = false;
  int _currentIndex =
      0; // Absensi = index 1 (0: Home, 1: Absensi, 2: Scan, 3: Notif, 4: Profile)
  bool isBreak = false;
  DateTime? breakStartTime;
  DateTime selectedDate = DateTime.now();
  Duration totalBreakDuration = Duration.zero;

  List<Map<String, dynamic>> history = [];

  void clockIn() {
    setState(() {
      clockInTime = DateTime.now();
      clockOutTime = null;
      isWorking = true;
      totalBreakDuration = Duration.zero;
      isBreak = false;
      breakStartTime = null;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  void clockOut() {
    if (clockInTime == null) return;

    if (isBreak && breakStartTime != null) {
      Duration breakDuration = DateTime.now().difference(breakStartTime!);
      totalBreakDuration += breakDuration;
      isBreak = false;
      breakStartTime = null;
    }

    _timer?.cancel();

    setState(() {
      clockOutTime = DateTime.now();
      isWorking = false;
      Duration total =
          clockOutTime!.difference(clockInTime!) - totalBreakDuration;
      if (total.isNegative) total = Duration.zero;

      history.insert(0, {
        'date': DateFormat('dd MMMM yyyy').format(clockInTime!),
        'in': DateFormat('HH:mm').format(clockInTime!),
        'out': DateFormat('HH:mm').format(clockOutTime!),
        'total': formatDuration(total),
      });
    });
  }

  void startBreak() {
    setState(() {
      isBreak = true;
      breakStartTime = DateTime.now();
    });
  }

  void endBreak() {
    if (breakStartTime == null) return;
    setState(() {
      Duration breakDuration = DateTime.now().difference(breakStartTime!);
      totalBreakDuration += breakDuration;
      isBreak = false;
      breakStartTime = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = (d.inHours).toString();
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // Navigasi antar halaman via bottom navbar
  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;

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
        onProfile: () {
          Navigator.pushReplacementNamed(context, '/profile');
        },
        onLogout: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
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
                "Fahrul Zahir",
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: !isWorking
                      ? Color(0xFFFFD2CD)
                      : isBreak
                      ? Color(0xFFFFECCE)
                      : Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isWorking
                      ? (isBreak ? "Sedang Break" : "Sedang Bekerja")
                      : "Belum Clock In",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: !isWorking
                        ? Colors.red
                        : isBreak
                        ? Colors.orange
                        : Colors.green,
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
                      text: DateFormat('d MMMM yyyy\n').format(DateTime.now()),
                    ),
                    TextSpan(
                      text: DateFormat('HH:mm').format(DateTime.now()),
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
          isWorking
              ? Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        onTap: isBreak ? endBreak : startBreak,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBreak
                              ? Colors.green
                              : Color(0xFFF9E5BE),
                          foregroundColor: isBreak
                              ? Colors.white
                              : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(isBreak ? "End Break" : "Take A Break"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: AnimatedButton(
                        onTap: clockOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4B352A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text("Clock Out"),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: AnimatedButton(
                    onTap: clockIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC67C4E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text("Clock In"),
                  ),
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
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _currentStatusCard() {
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
            "Total Working Hour",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            (clockInTime != null && isWorking)
                ? formatDuration(
                    (isBreak ? breakStartTime! : DateTime.now()).difference(
                          clockInTime!,
                        ) -
                        totalBreakDuration,
                  )
                : "0:00:00",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("In"),
                  Text(
                    clockInTime != null
                        ? DateFormat('HH:mm').format(clockInTime!)
                        : "--:--",
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Out"),
                  Text(
                    clockOutTime != null
                        ? DateFormat('HH:mm').format(clockOutTime!)
                        : "--:--",
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyList() {
    final filtered = history.where((item) {
      return item['date'] == DateFormat('dd MMMM yyyy').format(selectedDate);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMMM yyyy').format(selectedDate),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _pickDate,
                icon: Icon(Icons.calendar_month),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text("Tidak ada data"))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total: ${item['total']}"),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("In: ${item['in']}"),
                              Text("Out: ${item['out']}"),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final ButtonStyle style;

  const AnimatedButton({
    required this.child,
    required this.onTap,
    required this.style,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double scale = 1.0;

  void _pressDown() => setState(() => scale = 0.96);
  void _pressUp() => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _pressDown(),
      onPointerUp: (_) => _pressUp(),
      child: AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: widget.style,
          child: widget.child,
        ),
      ),
    );
  }
}
