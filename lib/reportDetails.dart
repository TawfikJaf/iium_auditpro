import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String? newStatus;
  Future<void> updateStatusAndShowDialog(String newStatus) async {
    print('Updating status. New Status: $newStatus');

    // Check if the status has changed
    if (newStatus != widget.reportDetails['status']) {
      print('Status has changed. Performing update.');

      // Update the status in Firestore for each collection
      for (final collectionName in [
        'reportsFacility',
        'reportsKulliyah',
        'reportsMahallah',
        'reportsOther',
      ]) {
        try {
          // Query the collection to find matching documents
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(collectionName)
              .where('issue', isEqualTo: widget.reportDetails['issue'])
              .where('description',
                  isEqualTo: widget.reportDetails['description'])
              .where('matricNumber',
                  isEqualTo: widget.reportDetails['matricNumber'])
              .get();

          // Update the status in all matching documents
          for (QueryDocumentSnapshot doc in querySnapshot.docs) {
            await FirebaseFirestore.instance
                .collection(collectionName)
                .doc(doc.id)
                .update({'status': newStatus});
          }
        } catch (error) {
          print('Error updating status in $collectionName: $error');
          // Handle error, show an error dialog if needed
        }
      }

      // Update the local state with the new status
      setState(() {
        widget.reportDetails['status'] = newStatus;
      });

      print('Status updated successfully.');
    } else {
      print('Status remains unchanged.');

      // Show a dialog indicating that the status remains unchanged
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Change'),
            content: Text('Status remains unchanged.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      return; // Exit the method without showing the success dialog
    }

    // Show a dialog indicating that the status has been updated
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Status updated successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Container(
        color: Colors.grey[200],
        child: Row(
          children: [
            Sidebar(
              onSidebarItemTap: (title) => handleSidebarItemTap(context, title),
            ),
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
                          color: Colors.grey[100],
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
                                    Navigator.pop(context);
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
                            buildInfoBox("Issue", widget.reportDetails['issue'],
                                fullwidth: true),
                            buildLocationBox(
                                widget.reportDetails['location'],
                                widget.reportDetails['latitude'],
                                widget.reportDetails['longitude'],
                                halfWidth: true),
                            buildInfoBox("Specific Location",
                                widget.reportDetails['specificLocation'],
                                fullwidth: true),
                            buildInfoBox("Description",
                                widget.reportDetails['description'],
                                halfWidth: true),
                            buildInfoBox(
                                "Status", widget.reportDetails['status'],
                                halfWidth: true),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              height: 1,
                              color: Colors.grey,
                            ),
                            Text(
                              'Reported By',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
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
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await updateStatusAndShowDialog(newStatus ??
                                        widget.reportDetails['status']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
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

  Widget buildLocationBox(String location, double? latitude, double? longitude,
      {bool halfWidth = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: halfWidth ? 700 : null,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                location,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(
                width: 10), // Add a little space between the field and button
            if (location.toLowerCase() == 'other' &&
                latitude != null &&
                longitude != null)
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Location Details'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Google Map Link:'),
                            SelectableText(
                              'https://maps.google.com/?q=$latitude,$longitude',
                              style: TextStyle(color: Colors.blue),
                            ),
                            SizedBox(height: 10),
                            Text('Latitude: $latitude'),
                            Text('Longitude: $longitude'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Open the URL in the default browser
                              String mapsLink =
                                  'https://maps.google.com/?q=$latitude,$longitude';
                              if (await canLaunch(mapsLink)) {
                                await launch(mapsLink);
                              } else {
                                // Handle error, show an error dialog if needed
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Error'),
                                      content:
                                          Text('Could not launch the URL.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Text('Open in Browser'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Set the button color to blue
                  padding: EdgeInsets.all(15), // Set the padding for the button
                  fixedSize: Size(200, 50),
                ),
                child: Text(
                  'View Location',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
          ],
        ),
        SizedBox(height: 20),
      ],
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
            value: newStatus ??
                widget.reportDetails['status'], // Use newStatus here
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
                // Update the newStatus variable
                setState(() {
                  newStatus = newValue;
                });
              }
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildInfoBox(String title, String value,
      {bool halfWidth = false, bool fullwidth = false}) {
    if (title == 'Status') {
      return buildStatusDropdown();
    } else if (title == 'Description') {
      return buildDescriptionBox(value, halfWidth: halfWidth);
    } else {
      return buildDefaultInfoBox(title, value,
          halfWidth: halfWidth, fullwidth: fullwidth);
    }
  }

  Widget buildDescriptionBox(String description, {bool halfWidth = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 700, // Set the width to 700
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            SizedBox(
              width: 15, // Add a little space between the field and button
            ),
            if (widget.reportDetails
                .containsKey('image')) // Check if image field exists
              ElevatedButton(
                onPressed: () {
                  _showImageDialog(context, widget.reportDetails['image']);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.all(15),
                  fixedSize: Size(200, 50),
                ),
                child: Text(
                  'View Image',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildImageBox(String imageUrl) {
    print(
        'Building Image Box with URL: $imageUrl'); // Add this line for debugging

    if (widget.reportDetails.containsKey('image')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showImageDialog(context, imageUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.all(15),
                  ),
                  child: Text(
                    'View Image',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(height: 20),
        ],
      );
    } else {
      print('Image URL is null or empty'); // Add this line for debugging
      return Container(); // Return an empty container if image URL is not available
    }
  }

  Widget buildDefaultInfoBox(String title, String value,
      {bool halfWidth = false, bool fullwidth = false}) {
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

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image URL'),
          content: SelectableText(
            imageUrl,
            style: TextStyle(color: Colors.blue),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () async {
                // Open the URL in the default browser
                if (await canLaunch(imageUrl)) {
                  await launch(imageUrl);
                } else {
                  // Handle error, for example, show an error dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Could not launch the URL.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Open in Browser'),
            ),
          ],
        );
      },
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
