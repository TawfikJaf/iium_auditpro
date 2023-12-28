import 'package:flutter/material.dart';

class SidebarItem extends StatefulWidget {
  final String title;
  final IconData? icon;
  final List<String>? subItems;
  final Function(String) onSubItemTap;
  final bool isActive;
  final bool keepSubMenuOpen;
  final String? currentPage;

  SidebarItem({
    required this.title,
    required this.onSubItemTap,
    this.icon,
    this.subItems,
    this.isActive = false,
    this.keepSubMenuOpen = false,
    this.currentPage,
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
    return ListTile(
      title: Row(
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: 30, // Increase the icon size
              color: isHoveredOrActive
                  ? hoverColor
                  : Colors.white, // Set icon color
            ),
            SizedBox(width: 12), // Increase the spacing
          ],
          Text(
            widget.title,
            style: TextStyle(
              color: isHoveredOrActive ? hoverColor : baseColor,
              fontSize: 28, // Increase the font size
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
  }
}
