import 'package:flutter/material.dart';
import 'package:iium_auditpro/main.dart';
import 'package:iium_auditpro/profilePage.dart';
import 'package:iium_auditpro/reportDetails.dart';
import 'package:iium_auditpro/reportList.dart';
import 'package:iium_auditpro/userInfo.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
              color: Colors.white), // Set back button color to white
        ),
      ),
      home: HomePage(currentPage: 'Home'),
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
          VerticalDivider(
            // Add a vertical divider here
            color: Colors.black,
            thickness: 1,
            width: 1,
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          welcomeMessage,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Divider(
                          // Add a horizontal divider here
                          color: Colors.black,
                          thickness: 1,
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: Container(
                              child: buildPaginatedReportsTable(),
                            ),
                          ),
                        ),
                      ],
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

  Widget buildPaginatedReportsTable() {
    return FutureBuilder(
      future: _fetchReportsData(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No reports available.');
        }

        List<Map<String, dynamic>> reportsData = snapshot.data!;

        final _reportsDataTableSource = _ReportsDataTableSource(
          reportsData: reportsData,
          onViewDetails: (Map<String, dynamic> reportDetails) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReportDetailsPage(reportDetails: reportDetails),
              ),
            );
          },
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Reports',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Text(
                  '  (Last 7 Days)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: PaginatedDataTable(
                  columnSpacing: 210, // Set your desired spacing value
                  rowsPerPage: 10,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Location',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '   Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  source: _reportsDataTableSource,
                  dataRowHeight: 55, // Set your desired row height
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchReportsData() async {
    List<Map<String, dynamic>> combinedReportsData = [];

    await _fetchCollectionData(
        'reportsFacility', combinedReportsData, 'facility');
    await _fetchCollectionData(
        'reportsKulliyah', combinedReportsData, 'kulliyah');
    await _fetchCollectionData(
        'reportsMahallah', combinedReportsData, 'mahallah');
    await _fetchCollectionData('reportsOther', combinedReportsData, 'other');

    // TODO: Add any additional sorting, filtering, or customization if needed

    return combinedReportsData;
  }

  Future<void> _fetchCollectionData(
      String collectionName,
      List<Map<String, dynamic>> combinedReportsData,
      String locationFieldName) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    DateTime currentDate = DateTime.now();

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('time')) {
        // Check if the 'time' field is present in the document
        print('Timestamp field found: ${data['time']}');

        // Ensure the 'time' field is not null
        if (data['time'] != null) {
          Timestamp timestamp = data['time'] as Timestamp;
          print('Fetched Timestamp: $timestamp');

          DateTime reportDate = timestamp.toDate();
          Duration difference = currentDate.difference(reportDate);

          if (difference.inDays <= 7) {
            data['location'] = data[locationFieldName];
            combinedReportsData.add(data);
          }
        } else {
          print('Warning: Timestamp field is null.');
        }
      } else {
        print('Warning: Timestamp field not found in the document.');
      }
    });

    // Sort the list based on the timestamp in descending order
    combinedReportsData.sort((a, b) {
      Timestamp timestampA = a['time'] as Timestamp;
      Timestamp timestampB = b['time'] as Timestamp;
      return timestampB.compareTo(timestampA);
    });
  }
}

class _ReportsDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> reportsData;
  final Function(Map<String, dynamic>) onViewDetails;

  _ReportsDataTableSource({
    required this.reportsData,
    required this.onViewDetails,
  });

  @override
  DataRow getRow(int index) {
    final Map<String, dynamic> data = reportsData[index];
    final Timestamp timestamp = data['time'] as Timestamp;

    return DataRow(
      cells: [
        DataCell(Text(data['name']?.toString() ?? 'N/A')),
        DataCell(Text(data['location']?.toString() ?? 'N/A')),
        DataCell(Text(_formatDate(timestamp))),
        DataCell(Text(data['status']?.toString() ?? 'N/A')),
        DataCell(
          TextButton(
            onPressed: () {
              onViewDetails(data);
            },
            child: Text('View Details'),
          ),
        ),
      ],
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  @override
  int get rowCount => reportsData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
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
          SizedBox(height: 40), // Add some spacing
          SidebarItem(
            title: 'Home',
            icon: Icons.home,
            onSubItemTap: (String title) => onSidebarItemTap(title),
            isActive: currentPage == 'Home',
            currentPage: currentPage,
          ),
          SizedBox(height: 10), // Add some spacing
          SidebarItem(
            title: 'Reports',
            icon: Icons.library_books,
            onSubItemTap: (String title) => onSidebarItemTap(title),
            isActive: currentPage == 'ReportsListPage',
            currentPage: currentPage,
          ),
          SizedBox(height: 10), // Add some spacing
          SidebarItem(
            title: 'Users',
            icon: Icons.supervised_user_circle,
            onSubItemTap: (String title) => onSidebarItemTap(title),
            isActive: currentPage == 'UserInformationPage',
            currentPage: currentPage,
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
