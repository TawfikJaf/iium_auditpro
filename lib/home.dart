import 'package:flutter/material.dart';
import 'package:iium_auditpro/main.dart';
import 'package:iium_auditpro/profilePage.dart';
import 'package:iium_auditpro/reportDetails.dart';
import 'package:iium_auditpro/reportList.dart';
import 'package:iium_auditpro/userInfo.dart';
import 'package:iium_auditpro/userProfile.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      home: HomePage(currentPage: 'Home'), // Pass the current page name here
    );
  }
}

class HomePage extends StatelessWidget {
  final String currentPage;

  HomePage({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Remove back button
      backgroundColor: Colors.green,
      title: Row(
        children: [
          NotificationIcon(),
          Spacer(),
        ],
      ),
      actions: [
        CustomPopupMenu(),
      ],
    );
  }

  Future<String> _getFirstName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch user data from Firestore based on email
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('profilePage')
            .where('email', isEqualTo: user.email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // User data found in Firestore
          final userData = snapshot.docs.first.data();
          return userData['firstName'] ?? '';
        } else {
          return ''; // Handle the case when the document is not found
        }
      } catch (e) {
        print('Error loading user data: $e');
        return ''; // Handle the error case
      }
    }

    return ''; // Handle the case when the user is not logged in
  }

  Widget buildBody(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Row(
        children: [
          Sidebar(
            onSidebarItemTap: (title) => handleSidebarItemTap(context, title),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: FutureBuilder<String>(
                future: _getFirstName(),
                builder: (context, snapshot) {
                  String firstName = snapshot.data ?? '';

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String welcomeMessage =
                        'Welcome ${firstName.isNotEmpty ? '$firstName ' : ''}to IIUM AuditPro Dashboard!';
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        welcomeMessage,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleSidebarItemTap(BuildContext context, String title) {
    if (title == 'Home') {
      // No need to navigate, already on the home page
      return;
    }

    switch (title) {
      case 'Reports List':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ReportsListPage()));
        break;
      case 'Report Details':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ReportDetailsPage()));
        break;
      case 'User Information':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserInformationPage()));
        break;
      case 'User Profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(
                userData: {}), // Provide default user data or adjust as needed
          ),
        );
        break;
    }
  }
}

class NotificationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(290),
      child: Icon(
        Icons.notifications,
        color: Colors.white,
      ),
    );
  }
}

class CustomPopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'Profile',
          child: Container(
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                SizedBox(width: 8),
                Text(
                  'Profile',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Logout',
          child: Container(
            child: Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        } else if (value == 'Logout') {
          bool? confirmLogout = await showLogoutConfirmationDialog(context);
          if (confirmLogout != null && confirmLogout) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      WelcomeScreen()), // Redirect to WelcomeScreen
            );
          }
        }
      },
    );
  }

  Future<bool?> showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: TextStyle(color: Colors.red),
          ),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Sidebar extends StatelessWidget {
  final Function(String) onSidebarItemTap;
  final String? currentPage;

  Sidebar({required this.onSidebarItemTap, this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            child: Container(
              child: Image.asset(
                'assets/images/wlogo.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
          SidebarItem(
            title: 'Home',
            icon: Icons.home,
            onSubItemTap: onSidebarItemTap,
            isActive: currentPage == 'Home',
            currentPage: currentPage, // Pass the currentPage to SidebarItem
          ),
          SidebarItem(
            title: 'Reports',
            icon: Icons.library_books,
            subItems: ['Reports List', 'Report Details'],
            onSubItemTap: onSidebarItemTap,
            isActive: currentPage == 'Reports List' ||
                currentPage == 'Report Details',
            keepSubMenuOpen: currentPage == 'Reports List' ||
                currentPage == 'Report Details',
            currentPage: currentPage, // Pass the currentPage to SidebarItem
          ),
          SidebarItem(
            title: 'Users',
            icon: Icons.supervised_user_circle,
            subItems: ['User Information', 'User Profile'],
            onSubItemTap: onSidebarItemTap,
            isActive: currentPage == 'User Information' ||
                currentPage == 'User Profile',
            keepSubMenuOpen: currentPage == 'User Information' ||
                currentPage == 'User Profile',
            currentPage: currentPage, // Pass the currentPage to SidebarItem
          ),
        ],
      ),
    );
  }
}

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
