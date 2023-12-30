import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iium_auditpro/home.dart';
import 'package:iium_auditpro/main.dart';
import 'package:iium_auditpro/profilePage.dart';
import 'package:iium_auditpro/reportList.dart';
import 'package:iium_auditpro/userProfile.dart';

class UserInformationPage extends StatefulWidget {
  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot>? _filteredStream;

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
      stream: _filteredStream ??
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

        List<DocumentSnapshot> userData = snapshot.data!.docs;

        userData.sort((a, b) => (a['name'] as String)
            .toLowerCase()
            .compareTo((b['name'] as String).toLowerCase()));

        List<DocumentSnapshot> filteredData = userData.where((document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String name = data['name']?.toString() ?? '';
          String matricNumber = data['matricNumber']?.toString() ?? '';
          String searchTerm = searchController.text.toLowerCase();
          return name.toLowerCase().contains(searchTerm) ||
              matricNumber.toLowerCase().contains(searchTerm);
        }).toList();

        final _userDataTableSource =
            _UserDataTableSource(filteredData, context);

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
                  'Matric Number',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(''),
              ),
            ],
            source: _userDataTableSource,
            dataRowHeight: 55,
          ),
        );
      },
    );
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
              updateStreamBasedOnSearchQuery(value);
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              hintText: 'Enter Matric Number',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  void updateStreamBasedOnSearchQuery(String searchQuery) {
    Stream<QuerySnapshot> filteredStream = FirebaseFirestore.instance
        .collection('User Information')
        .where('matricNumber', isEqualTo: searchQuery)
        .snapshots();

    setState(() {
      _filteredStream = filteredStream;
    });
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReportsListPage(),
          ),
        );
        break;
      case 'Users':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserInformationPage(),
          ),
        );
        break;
    }
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

  int get rowsPerPage => 10;
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
