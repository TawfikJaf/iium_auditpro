import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'package:iium_auditpro/home.dart';
import 'package:iium_auditpro/main.dart';
import 'package:iium_auditpro/profilePage.dart';
import 'package:iium_auditpro/reportDetails.dart';
import 'package:iium_auditpro/userInfo.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsListPage extends StatefulWidget {
  @override
  _ReportsListPageState createState() => _ReportsListPageState();
}

class _ReportsListPageState extends State<ReportsListPage> {
  int selectedFilterIndex = 0;

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
      iconTheme: IconThemeData(color: Colors.white),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports List Page',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 500,
                    child: buildSearchField(),
                  ),
                  SizedBox(height: 20),
                  buildFilterSegmentedControl(), // Moved the filter here
                  SizedBox(height: 1),
                  Expanded(
                    child: SizedBox(
                      width: 1700, // Set the desired width
                      child: Container(
                        child: buildPaginatedReportsTable(),
                      ),
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

  Widget buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 8),
        Container(
          width: 500,
          child: TextField(
            onChanged: (value) {
              // Implement search functionality here
              // You may want to update the StreamBuilder based on the search query
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              hintText: 'Enter report name or location',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
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

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: PaginatedDataTable(
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
                  'Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            source: _reportsDataTableSource,
            dataRowHeight: 50, // Set your desired row height
          ),
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

    if (selectedFilterIndex != 0) {
      String statusFilter = getStatusFilter(selectedFilterIndex);
      combinedReportsData = combinedReportsData
          .where((report) => report['status'] == statusFilter)
          .toList();
    }

    combinedReportsData.sort((a, b) {
      Timestamp timestampA = a['time'] as Timestamp;
      Timestamp timestampB = b['time'] as Timestamp;
      return timestampB.compareTo(timestampA);
    });

    return combinedReportsData;
  }

  // Add the following method
  String getStatusFilter(int index) {
    switch (index) {
      case 1:
        return 'In progress';
      case 2:
        return 'Approved';
      case 3:
        return 'Declined';
      case 4:
        return 'Solved';
      default:
        return '';
    }
  }

  Future<void> _fetchCollectionData(
      String collectionName,
      List<Map<String, dynamic>> combinedReportsData,
      String locationFieldName) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('time')) {
        // Check if the 'time' field is present in the document
        print('Timestamp field found: ${data['time']}');

        // Ensure the 'time' field is not null
        if (data['time'] != null) {
          Timestamp timestamp = data['time'] as Timestamp;
          print('Fetched Timestamp: $timestamp');

          data['location'] = data[locationFieldName];
          combinedReportsData.add(data);
        } else {
          print('Warning: Timestamp field is null.');
        }
      } else {
        print('Warning: Timestamp field not found in the document.');
      }
    });
  }

  Widget buildFilterSegmentedControl() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: selectedFilterIndex,
        children: {
          0: Text('All'),
          1: Text('In progress'),
          2: Text('Approved'),
          3: Text('Declined'),
          4: Text('Solved'),
        },
        onValueChanged: (index) {
          setState(() {
            selectedFilterIndex = index!;
          });
        },
      ),
    );
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
