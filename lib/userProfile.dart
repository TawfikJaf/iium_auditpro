import 'package:flutter/material.dart';
import 'package:iium_auditpro/home.dart';
import 'package:iium_auditpro/main.dart';
import 'package:iium_auditpro/profilePage.dart';
import 'package:iium_auditpro/reportDetails.dart';
import 'package:iium_auditpro/reportList.dart';
import 'package:iium_auditpro/userInfo.dart';

class UserProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserProfilePage({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      title: Row(
        children: [
          NotificationIcon(),
          Spacer(),
        ],
      ),
      iconTheme:
          IconThemeData(color: Colors.white), // Set back button color to white
      actions: [
        CustomPopupMenu(),
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    return Container(
      color: Colors.grey[200], // Set the overall background color
      child: Row(
        children: [
          Sidebar(
            onSidebarItemTap: (title) => handleSidebarItemTap(context, title),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Profile Page',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Container(
                    color: Colors
                        .grey[100], // Set the background color for this part
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(
                                    context); // Navigate back to User Information page
                              },
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Back',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildInfoBox("Name", userData['name']),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: buildInfoBox(
                                "Matric Number",
                                userData['matricNumber'],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildInfoBox("Email", userData['email']),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: buildInfoBox(
                                "Password",
                                "********", // Display a placeholder for the password
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 100),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle delete button click
                              // You can add logic to delete the user
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              padding: EdgeInsets.symmetric(
                                vertical: 20, // Adjust the vertical padding
                                horizontal: 40, // Adjust the horizontal padding
                              ),
                            ),
                            child: Text(
                              'Delete Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18, // Adjust the font size
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoBox(String label, String? value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            value ?? 'N/A', // Display 'N/A' if the value is null
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void handleSidebarItemTap(BuildContext context, String title) {
    if (title == 'Home') {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    currentPage: 'Home',
                  )));
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
        // No need to navigate to the same page (User Profile Page)
        return;
    }
  }
}

class NotificationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(230),
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
