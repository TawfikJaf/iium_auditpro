import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iium_auditpro/home.dart';
import 'package:iium_auditpro/main.dart';
import 'package:iium_auditpro/profilePage.dart';
import 'package:iium_auditpro/reportDetails.dart';
import 'package:iium_auditpro/reportList.dart';
import 'package:iium_auditpro/userProfile.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserInformationPage extends StatelessWidget {
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
    TextEditingController searchController = TextEditingController();

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
                    'User Information Page',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 500,
                    child: buildSearchField(searchController),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        buildPaginatedUserTable(searchController),
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

  Widget buildPaginatedUserTable(TextEditingController searchController) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('User Information').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No user information available.');
        }

        List<DocumentSnapshot> filteredData =
            snapshot.data!.docs.where((document) {
          // Add your filter logic here based on name or matric
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String name = data['name']?.toString() ?? '';
          String matricNumber = data['matricNumber']?.toString() ?? '';
          String searchTerm = searchController.text.toLowerCase();
          return name.toLowerCase().contains(searchTerm) ||
              matricNumber.toLowerCase().contains(searchTerm);
        }).toList();

        final _userDataTableSource =
            _UserDataTableSource(filteredData, context);

        return PaginatedDataTable(
          rowsPerPage: 10,
          columns: [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Matric Number')),
            DataColumn(label: Text('')),
          ],
          source: _userDataTableSource,
        );
      },
    );
  }
}

class _UserDataTableSource extends DataTableSource {
  final List<DocumentSnapshot> _userDocuments;
  final BuildContext context;
  int _page = 0;

  _UserDataTableSource(this._userDocuments, this.context);

  @override
  DataRow getRow(int index) {
    final Map<String, dynamic> data =
        _userDocuments[index].data() as Map<String, dynamic>;

    return DataRow(
      cells: [
        DataCell(Text(data['name']?.toString() ?? 'N/A')),
        DataCell(Text(data['matricNumber']?.toString() ?? 'N/A')),
        DataCell(
          TextButton(
            onPressed: () {
              // Navigate to UserProfilePage with user data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(userData: data),
                ),
              );
            },
            child: Text('View Information'),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => _userDocuments.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  int get pageRowCount => min(rowCount - _page * rowsPerPage, rowsPerPage);

  bool get hasPrevious => _page * rowsPerPage > 0;

  bool get hasNext => (_page + 1) * rowsPerPage < rowCount;

  void previousPage() {
    if (hasPrevious) {
      _page--;
    }
  }

  void nextPage() {
    if (hasNext) {
      _page++;
    }
  }

  int get rowsPerPage => 10; // Specify the number of rows per page
}

Widget buildSearchField(TextEditingController searchController) {
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
          controller: searchController,
          onChanged: (value) {
            // Implement search functionality here
            // You may want to update the StreamBuilder based on the search query
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            hintText: 'Enter name or Matric Number',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ],
  );
}

void handleSidebarItemTap(BuildContext context, String title) {
  if (title == 'Home') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          currentPage: 'Home',
        ),
      ),
    );
    return;
  }

  switch (title) {
    case 'Reports List':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportsListPage()),
      );
      break;
    case 'Report Details':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportDetailsPage()),
      );
      break;
    case 'User Information':
      // No need to navigate to the same page (User Information Page)
      return;
    case 'User Profile':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(
            userData: {}, // Provide default user data or adjust as needed
          ),
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
                builder: (context) => WelcomeScreen(),
              ),
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
