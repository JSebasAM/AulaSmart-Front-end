import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';

class NavItemData {
  final String label;
  final IconData icon;
  final Widget page;
  final List<NavSubItem>? subItems;
  final bool showInNavBar;

  const NavItemData({
    required this.label,
    required this.icon,
    required this.page,
    this.subItems,
    this.showInNavBar = true,
  });
}

class NavSubItem {
  final String label;
  final IconData icon;
  final int index;

  const NavSubItem({
    required this.label,
    required this.icon,
    required this.index,
  });
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<NavItemData> items;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Container(
        height: 80, // Reducido un poco para que se vea más como una barra de botones
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pageCard,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: items.asMap().entries.where((e) => e.value.showInNavBar).map((entry) {
              final index = entry.key;
              final item = entry.value;
              
              // Determinar si es el último ítem visible para el padding
              final visibleItems = items.where((i) => i.showInNavBar).toList();
              final isLast = item == visibleItems.last;

              final button = _buildStandardButton(item, index == currentIndex, index);

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 8.0),
                child: button,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardButton(NavItemData item, bool isActive, int index) {
    if (isActive) {
      return FilledButton.icon(
        onPressed: () => onTap(index),
        icon: Icon(item.icon, size: 20),
        label: Text(item.label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      );
    } else {
      return FilledButton.tonalIcon(
        onPressed: () => onTap(index),
        icon: Icon(item.icon, size: 20, color: AppColors.primary),
        label: Text(item.label, style: const TextStyle(color: AppColors.textPrimary)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      );
    }
  }
}
