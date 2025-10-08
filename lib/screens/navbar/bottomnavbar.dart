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
      height: 60, // Slightly reduced height for a sleeker look
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Navbar background is primary color (blue)
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5), // Subtle shadow upwards
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
            'Dash',
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
          _buildNavItem(
            context,
            3,
            Icons.vpn_key_outlined,
            'MyNets',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final bool isSelected = index == selectedIndex;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        customBorder: const StadiumBorder(),
        splashColor: primaryColor.withOpacity(0.2),
        highlightColor: primaryColor.withOpacity(0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Reduced horizontal padding
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              if (isSelected)
                const SizedBox(width: 8),
              if (isSelected)
                Text(
                  label,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 11, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }




}