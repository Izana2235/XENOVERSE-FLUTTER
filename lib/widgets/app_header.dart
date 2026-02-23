import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart' as app_state;
import '../theme/app_theme.dart';

class AppHeader extends StatefulWidget {
  final bool isMobile;
  final VoidCallback onMenuPressed;

  const AppHeader({
    super.key,
    required this.isMobile,
    required this.onMenuPressed,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String? _activeDropdown;
  final TextEditingController _searchController = TextEditingController();

  void _toggleDropdown(String dropdown) {
    setState(() {
      if (_activeDropdown == dropdown) {
        _activeDropdown = null;
      } else {
        _activeDropdown = dropdown;
      }
    });
  }

  void _closeDropdowns() {
    if (_activeDropdown != null) {
      setState(() {
        _activeDropdown = null;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark1 : AppColors.bgLight0;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final surface = isDark ? AppColors.surfaceLight : AppColors.bgLight1;
    final dropdownBg = isDark ? const Color(0xFF1A2540) : Colors.white;

    return Stack(
      children: [
        GestureDetector(
          onTap: _closeDropdowns,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.95),
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Menu Icon (Mobile Only)
                if (widget.isMobile)
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: widget.onMenuPressed,
                    color: textColor,
                  ),
                // Header Left - Centered Search Bar (Desktop) or Compact Search Bar (Mobile)
                if (!widget.isMobile)
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: _buildSearchBar(textColor, borderColor, surface),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: _buildSearchBar(textColor, borderColor, surface),
                      ),
                    ),
                  ),
                // Spacer (Desktop only to push icons right)
                if (!widget.isMobile) const Spacer(),
                // Header Right - Icons with dropdowns
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.notifications_outlined,
                        onPressed: () => _toggleDropdown('notifications'),
                        isActive: _activeDropdown == 'notifications',
                      ),
                      _HeaderIconButton(
                        icon: Icons.email_outlined,
                        onPressed: () => _toggleDropdown('messages'),
                        isActive: _activeDropdown == 'messages',
                      ),
                      _HeaderIconButton(
                        icon: Icons.account_circle_outlined,
                        onPressed: () => _toggleDropdown('profile'),
                        isActive: _activeDropdown == 'profile',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Dropdowns
        if (_activeDropdown == 'notifications')
          Positioned(
            top: 70,
            right: widget.isMobile ? 12 : 100,
            child: _NotificationsDropdown(
              bgColor: dropdownBg,
              textColor: textColor,
              borderColor: borderColor,
              isDark: isDark,
              onClose: _closeDropdowns,
            ),
          ),
        if (_activeDropdown == 'messages')
          Positioned(
            top: 70,
            right: widget.isMobile ? 12 : 50,
            child: _MessagesDropdown(
              bgColor: dropdownBg,
              textColor: textColor,
              borderColor: borderColor,
              isDark: isDark,
              onClose: _closeDropdowns,
            ),
          ),
        if (_activeDropdown == 'profile')
          Positioned(
            top: 70,
            right: 12,
            child: _ProfileDropdown(
              bgColor: dropdownBg,
              textColor: textColor,
              borderColor: borderColor,
              isDark: isDark,
              onClose: _closeDropdowns,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar(Color textColor, Color borderColor, Color surface) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.search, color: textColor, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search…',
                hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.isActive,
  });

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            widget.icon,
            color: textColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _NotificationsDropdown extends StatelessWidget {
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final bool isDark;
  final VoidCallback onClose;

  const _NotificationsDropdown({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final headerBg = isDark ? const Color(0xFF0F1A2E) : const Color(0xFFF5F5F5);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: headerBg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, color: textColor, size: 20),
                ),
              ],
            ),
          ),
          _NotificationItem(
            icon: Icons.info_outlined,
            title: 'New Order',
            time: '2 minutes ago',
            textColor: textColor,
            isDark: isDark,
          ),
          _NotificationItem(
            icon: Icons.warning_outlined,
            title: 'Low Stock Alert',
            time: '1 hour ago',
            textColor: textColor,
            isDark: isDark,
          ),
          _NotificationItem(
            icon: Icons.done_outlined,
            title: 'Order Completed',
            time: '3 hours ago',
            textColor: textColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final Color textColor;
  final bool isDark;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.time,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
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

class _MessagesDropdown extends StatelessWidget {
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final bool isDark;
  final VoidCallback onClose;

  const _MessagesDropdown({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final headerBg = isDark ? const Color(0xFF0F1A2E) : const Color(0xFFF5F5F5);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: headerBg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, color: textColor, size: 20),
                ),
              ],
            ),
          ),
          _MessageItem(
            initials: 'JD',
            sender: 'John Doe',
            preview: 'Can you check the inventory report?',
            textColor: textColor,
            isDark: isDark,
          ),
          _MessageItem(
            initials: 'SM',
            sender: 'Sarah Manager',
            preview: 'Meeting scheduled for 3 PM',
            textColor: textColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  final String initials;
  final String sender;
  final String preview;
  final Color textColor;
  final bool isDark;

  const _MessageItem({
    required this.initials,
    required this.sender,
    required this.preview,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sender,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
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

class _ProfileDropdown extends StatelessWidget {
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final bool isDark;
  final VoidCallback onClose;

  const _ProfileDropdown({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.read<app_state.AppState>();
    final headerBg = isDark ? const Color(0xFF0F1A2E) : const Color(0xFFF5F5F5);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: headerBg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, color: textColor, size: 20),
                ),
              ],
            ),
          ),
          _ProfileOption(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {
              appState.switchTab('settings');
              onClose();
            },
            textColor: textColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
          _ProfileOption(
            icon: Icons.person_outlined,
            label: 'My Profile',
            onTap: () {
              appState.switchTab('settings');
              onClose();
            },
            textColor: textColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
          _ProfileOption(
            icon: Icons.logout_outlined,
            label: 'Logout',
            onTap: onClose,
            textColor: textColor,
            borderColor: borderColor,
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color borderColor;
  final bool isDark;
  final bool isLast;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.textColor,
    required this.borderColor,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentLight, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
