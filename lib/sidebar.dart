import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<String>? subItems;
  final Function(String) onSubItemTap;

  SidebarItem({
    required this.title,
    required this.onSubItemTap,
    this.icon,
    this.subItems,
  });

  @override
  Widget build(BuildContext context) {
    return title == 'Home'
        ? ListTile(
            title: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
            onTap: () {
              // Handle the navigation to the homepage directly
              onSubItemTap(title);
            },
          )
        : ExpansionTile(
            title: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
            iconColor: Colors.white,
            children: subItems?.map((subItem) {
                  return ListTile(
                    title: Text(
                      subItem,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      onSubItemTap(subItem);
                    },
                  );
                }).toList() ??
                [],
          );
  }
}
