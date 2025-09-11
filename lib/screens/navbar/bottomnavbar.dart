import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // Increased height for better visual
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Yellow background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            0,
            Icons.dashboard_outlined,
            'Dashboard',
          ),
          _buildNavItem(
            context,
            1,
            Icons.contacts_outlined,
            'Contacts',
          ),
          _buildNavItem(
            context,
            2,
            Icons.note_alt_outlined,
            'Notes',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final bool isSelected = index == selectedIndex;
    final Color itemColor = isSelected ? Theme.of(context).colorScheme.onPrimary : Colors.white.withOpacity(0.7);

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(15), // Slightly rounded background for selected item
          ),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: itemColor, size: 28),
              Text(
                label,
                style: TextStyle(color: itemColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}