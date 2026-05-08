import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:split_button_m3e/split_button_m3e.dart';

class NavItemData {
  final String label;
  final IconData icon;
  final Widget page;
  final List<NavSubItem>? subItems;

  const NavItemData({
    required this.label,
    required this.icon,
    required this.page,
    this.subItems,
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
            children: List.generate(items.length, (index) {
              final isActive = index == currentIndex;
              final item = items[index];
              final isLast = index == items.length - 1;

              Widget button;

              if (item.subItems != null && item.subItems!.isNotEmpty) {
                button = Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColors.primary,
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      secondaryContainer: AppColors.surfaceVariant,
                    ),
                  ),
                  child: SplitButtonM3E<int>(
                    size: SplitButtonM3ESize.md,
                    shape: SplitButtonM3EShape.round,
                    emphasis: isActive ? SplitButtonM3EEmphasis.filled : SplitButtonM3EEmphasis.tonal,
                    label: item.label,
                    leadingIcon: item.icon,
                    onPressed: () => onTap(index),
                    items: item.subItems!.map((sub) => SplitButtonM3EItem<int>(
                      value: sub.index,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(sub.icon, size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            sub.label,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    onSelected: (v) => onTap(v),
                  ),
                );
              } else {
                button = _buildStandardButton(item, isActive, index);
              }

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 8.0),
                child: button,
              );
            }),
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
