import 'package:flutter/material.dart';

class BottomBarItem {
  final String label;
  final IconData icon;

  const BottomBarItem({required this.label, required this.icon});
}

class BottomBar extends StatelessWidget {
  final List<BottomBarItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeIndicatorColor;

  const BottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == selectedIndex;
              return Expanded(
                child: InkResponse(
                  onTap: onTap == null ? null : () => onTap!(index),
                  radius: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selected
                              ? activeIndicatorColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: selected ? activeColor : inactiveColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: selected ? activeColor : inactiveColor,
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
