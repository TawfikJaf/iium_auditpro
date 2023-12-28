import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:iium_auditpro/home.dart';
import 'package:iium_auditpro/main.dart';
import 'package:iium_auditpro/profilePage.dart';
import 'package:iium_auditpro/reportList.dart';
import 'package:iium_auditpro/userInfo.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDetailsPage extends StatefulWidget {
  final Map<String, dynamic> reportDetails;

  ReportDetailsPage({required this.reportDetails});

  @override
  _ReportDetailsPageState createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Container(
        color: Colors.grey[200], // Set the overall background color
        child: Row(
          children: [
            Sidebar(
              onSidebarItemTap: (title) => handleSidebarItemTap(context, title),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Details Page',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100], // Set box color to blue
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  onPressed: () {
                                    Navigator.pop(context); // Navigate back
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
                            // Build boxes in the specified order
                            buildInfoBox("Issue", widget.reportDetails['issue'],
                                fullwidth: true),
                            buildInfoBox(
                                "Location", widget.reportDetails['location'],
                                fullwidth: true),
                            buildInfoBox(
                              "Specific Location",
                              widget.reportDetails['specificLocation'],
                              fullwidth: true,
                            ),
                            buildInfoBox(
                              "Description",
                              widget.reportDetails['description'],
                              halfWidth: true,
                            ),
                            buildInfoBox(
                                "Status", widget.reportDetails['status'],
                                halfWidth: true),

                            // Horizontal gray line
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              height: 1,
                              color: Colors.grey,
                            ),
                            // "Reported By" text
                            Text(
                              'Reported By',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            // Build boxes for "name" and "matric" side by side
                            Row(
                              children: [
                                Expanded(
                                  child: buildInfoBox(
                                      "Name", widget.reportDetails['name'],
                                      halfWidth: true),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: buildInfoBox("Matric Number",
                                      widget.reportDetails['matricNumber'],
                                      halfWidth: true),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // Build boxes for "email" and "time" side by side
                            Row(
                              children: [
                                Expanded(
                                  child: buildInfoBox("Email",
                                      widget.reportDetails['userEmail'],
                                      halfWidth: true),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: buildInfoBox("Time",
                                      _formatDate(widget.reportDetails['time']),
                                      halfWidth: true),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                width: 200, // Set the desired width
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors
                                        .blue, // Set button background color to blue
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 40), // Adjust padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30), // Adjust border radius
                                    ),
                                  ),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Colors
                                            .white), // Set text size and color
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
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 8),
        Container(
          width: 700, // Set a fixed width for the dropdown
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButton<String>(
            value: widget.reportDetails['status'],
            isExpanded: true,
            items: ['In progress', 'Approved', 'Declined', 'Solved']
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: (String? newValue) {
              // Handle status change
              // You can update the 'status' in your database or perform any other actions
              if (newValue != null &&
                  newValue != widget.reportDetails['status']) {
                // Update the status in the reportDetails only if it's different
                setState(() {
                  widget.reportDetails['status'] = newValue;
                });
              }
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Replace the buildInfoBox method with this updated version
  Widget buildInfoBox(String title, String value,
      {bool halfWidth = false, bool fullwidth = false}) {
    if (title == 'Status') {
      // Return the dropdown widget for "Status"
      return buildStatusDropdown();
    }

    // Default behavior for other fields
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 8),
        Container(
          width: fullwidth ? double.infinity : (halfWidth ? 700 : null),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildEmptyBox() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 20,
      ),
    );
  }
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
    iconTheme: IconThemeData(color: Colors.white),
    actions: [
      CustomPopupMenu(),
    ],
  );
}

String _formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
}

void handleSidebarItemTap(BuildContext context, String title) {
  if (title == 'Home') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(currentPage: 'Home'),
      ),
    );
    return;
  }

  switch (title) {
    case 'Reports':
      // Navigate to Report List page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReportsListPage(),
        ),
      );
      break;
    case 'Users':
      // Navigate to UserInfo page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserInformationPage(),
        ),
      );
      break;
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
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
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
