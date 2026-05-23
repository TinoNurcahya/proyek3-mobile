import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onProfile;
  final VoidCallback? onLogout;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onProfile,
    this.onLogout,
  });

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded),
              _buildNavItem(context, 1, Icons.menu_book_rounded),
              _buildScanButton(context),
              _buildNavItem(context, 3, Icons.notifications_rounded),
              _buildProfileIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon) {
    final isSelected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFC67C4E)
                  : const Color(0xFFA2A2A2),
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 20 : 0,
              height: isSelected ? 3 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFFC67C4E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(2),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8D5C4), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC67C4E).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.camera_alt_rounded,
            color: Color(0xFFC67C4E),
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileIcon() {
    final isSelected = widget.currentIndex == 4;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onTap(4);
        widget.onProfile?.call();
      },
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_rounded,
              color: isSelected
                  ? const Color(0xFFC67C4E)
                  : const Color(0xFFA2A2A2),
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 20 : 0,
              height: isSelected ? 3 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFFC67C4E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

