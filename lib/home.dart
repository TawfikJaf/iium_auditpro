import 'package:flutter/material.dart';
import 'package:iium_auditpro/main.dart';
import 'package:iium_auditpro/profilePage.dart';
import 'package:iium_auditpro/reportDetails.dart';
import 'package:iium_auditpro/reportList.dart';
import 'package:iium_auditpro/userInfo.dart';
import 'package:iium_auditpro/userProfile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
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
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Welcome to IIUM AuditPro Dashboard!',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserProfilePage()));
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

  Sidebar({required this.onSidebarItemTap});

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
          ),
          SidebarItem(
            title: 'Reports',
            icon: Icons.library_books,
            subItems: ['Reports List', 'Report Details'],
            onSubItemTap: onSidebarItemTap,
          ),
          SidebarItem(
            title: 'Users',
            icon: Icons.supervised_user_circle,
            subItems: ['User Information', 'User Profile'],
            onSubItemTap: onSidebarItemTap,
          ),
        ],
      ),
    );
  }
}

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
    if (title == 'Home') {
      return ListTile(
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
          // Handle the navigation to the homepage
          onSubItemTap('Home');
        },
      );
    } else {
      return ExpansionTile(
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
}
