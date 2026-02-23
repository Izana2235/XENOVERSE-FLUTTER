import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final bool isMobile;
  final bool mobileSearchOpen;
  final VoidCallback onToggleSidebar;
  final VoidCallback onToggleSearch;

  const Header({
    super.key, 
    required this.isMobile, 
    required this.mobileSearchOpen, 
    required this.onToggleSidebar, 
    required this.onToggleSearch, required bool isSearchOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF0F172A),
      child: Row(
        children: [
          // LAGING VISIBLE NA MENU ICON PARA SA LAHAT NG DEVICE
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: onToggleSidebar, 
          ),
          
          const SizedBox(width: 8),

          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.white38, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {},
          ),

          // EMAIL ICON NA LAGING VISIBLE
          IconButton(
            icon: const Icon(Icons.mail_outline, color: Colors.white70),
            onPressed: () {},
          ),

          const SizedBox(width: 8),

          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white10,
            child: Icon(Icons.person_outline, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}