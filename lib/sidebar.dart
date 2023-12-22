import 'package:flutter/material.dart';

class SidebarItem extends StatefulWidget {
  final String title;
  final IconData? icon;
  final List<String>? subItems;
  final Function(String) onSubItemTap;
  final bool isActive; // Add this line
  final bool keepSubMenuOpen;
  final String? currentPage; // Add this line

  SidebarItem({
    required this.title,
    required this.onSubItemTap,
    this.icon,
    this.subItems,
    this.isActive = false, // Set a default value
    this.keepSubMenuOpen = false, // Set a default value
    this.currentPage, // Add this line
  });

  @override
  _SidebarItemState createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = Color.fromARGB(255, 215, 215, 215);
    final hoverColor = Colors.white;

    final isActive = widget.title == widget.currentPage ||
        widget.subItems?.contains(widget.currentPage) == true;
    final isHoveredOrActive = isHovered || isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: buildItem(baseColor, hoverColor, isHoveredOrActive),
    );
  }

  Widget buildItem(Color baseColor, Color hoverColor, bool isHoveredOrActive) {
    if (widget.title == 'Home') {
      return ListTile(
        title: Row(
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon),
              SizedBox(width: 8),
            ],
            Text(
              widget.title,
              style: TextStyle(
                color: isHoveredOrActive ? hoverColor : baseColor,
                fontSize: 20,
                fontWeight:
                    isHoveredOrActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        onTap: () {
          widget.onSubItemTap(widget.title);
        },
      );
    } else {
      return ExpansionTile(
        title: Row(
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon),
              SizedBox(width: 8),
            ],
            Text(
              widget.title,
              style: TextStyle(
                color: isHoveredOrActive ? hoverColor : baseColor,
                fontSize: 20,
                fontWeight:
                    isHoveredOrActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        iconColor: Colors.white,
        initiallyExpanded: widget.keepSubMenuOpen,
        children: (widget.subItems ?? []).map((subItem) {
          return ListTile(
            title: Text(
              subItem,
              style:
                  TextStyle(color: isHoveredOrActive ? hoverColor : baseColor),
            ),
            onTap: () {
              widget.onSubItemTap(subItem);
            },
          );
        }).toList(),
        onExpansionChanged: (isOpen) {
          if (!widget.keepSubMenuOpen && !isOpen) {
            setState(() => isHovered = false);
          }
        },
      );
    }
  }
}
