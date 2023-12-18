import 'package:flutter/material.dart';
import 'package:iium_auditpro/home.dart';
import 'package:iium_auditpro/main.dart';
import 'package:iium_auditpro/reportDetails.dart';
import 'package:iium_auditpro/reportList.dart';
import 'package:iium_auditpro/userInfo.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  late String initialFirstName;
  late String initialLastName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success!'),
          content: Text('Profile information updated successfully'),
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

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    initialFirstName = prefs.getString('firstName') ?? '';
    initialLastName = prefs.getString('lastName') ?? '';

    setState(() {
      _firstNameController.text = initialFirstName;
      _lastNameController.text = initialLastName;
    });
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String newFirstName = _firstNameController.text;
    String newLastName = _lastNameController.text;

    if (newFirstName != initialFirstName || newLastName != initialLastName) {
      prefs.setString('firstName', newFirstName);
      prefs.setString('lastName', newLastName);

      _showSuccessDialog(context);
    } else {
      _showNoChangeDialog(context);
    }
  }

  void _showNoChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Changes'),
          content: Text('You have not made any changes to your profile.'),
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
                    'Profile Page',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  buildProfileForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileForm() {
    return FutureBuilder<User?>(
      // Obtain the current user
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Error state
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          // User not logged in state
          return Text('User not logged in');
        } else {
          // User logged in state
          User user = snapshot.data!;
          _emailController.text = user.email ?? '';
          _passwordController.text = '********';
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildProfileTextField("First Name", _firstNameController),
                SizedBox(height: 20),
                buildDividerWithPadding(),
                buildProfileTextField("Last Name", _lastNameController),
                SizedBox(height: 20),
                buildDividerWithPadding(),
                buildProfileTextField("Email", _emailController,
                    isEnabled: false),
                SizedBox(height: 20),
                buildDividerWithPadding(),
                buildProfileTextField("Password", _passwordController,
                    isEnabled: false, isPassword: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Show the edit password dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return EditPasswordDialog();
                      },
                    );
                  },
                  child: Text('Edit Password'),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveUserData();
                        // Show success dialog
                        _showSuccessDialog(context);
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildDividerWithPadding() {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 20), // Adjust the padding as needed
      child: Divider(), // Divider with padding
    );
  }

  Widget buildProfileTextField(String label, TextEditingController controller,
      {bool isEnabled = true, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18, // Adjust the font size as needed
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        TextField(
          enabled: isEnabled,
          obscureText: isPassword,
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  void handleSidebarItemTap(BuildContext context, String title) {
    if (title == 'Home') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserInformationPage()),
        );
        break;
      case 'User Profile':
        // No need to navigate to the same page (Profile Page)
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
          // No need to navigate to the same page (Profile Page)
          return;
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

class EditPasswordDialog extends StatefulWidget {
  @override
  _EditPasswordDialogState createState() => _EditPasswordDialogState();
}

class _EditPasswordDialogState extends State<EditPasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentPasswordController,
            decoration: InputDecoration(labelText: 'Current Password'),
            obscureText: true,
          ),
          TextField(
            controller: _newPasswordController,
            decoration: InputDecoration(labelText: 'New Password'),
            obscureText: true,
          ),
          TextField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(labelText: 'Confirm New Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _showConfirmationDialog(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Password Change'),
          content: Text('Are you sure you want to change your password?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate the current password and new password
                String currentPassword = _currentPasswordController.text;
                String newPassword = _newPasswordController.text;
                String confirmPassword = _confirmPasswordController.text;

                // Check if any of the password fields is empty
                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  _showErrorDialog(context, 'Fill up all fields');
                  return;
                }

                print(
                    'Debug: newPassword == currentPassword: ${newPassword == currentPassword}');
                print(
                    'Debug: newPassword != confirmPassword: ${newPassword != confirmPassword}');

                if (newPassword.isNotEmpty && newPassword == currentPassword) {
                  print(
                      'Debug: Showing error dialog for matching old and new passwords');
                  _showErrorDialog(context,
                      'New password cannot be the same as the old password');
                  return;
                }

                if (newPassword != confirmPassword) {
                  _showErrorDialog(context, 'Passwords do not match');
                  return;
                }

                try {
                  // Attempt to reauthenticate the user
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: FirebaseAuth.instance.currentUser!.email!,
                    password: currentPassword,
                  );

                  // Change the password
                  await FirebaseAuth.instance.currentUser!
                      .updatePassword(newPassword);

                  // Close the confirmation dialog
                  Navigator.of(context).pop();

                  // Display success message
                  _showSuccessDialog(context);
                } catch (e) {
                  // Print the error message to help identify the issue
                  print('Error changing password: $e');

                  // Close the confirmation dialog
                  Navigator.of(context).pop();

                  // Display a generic error message
                  _showErrorDialog(
                      context, 'Failed to change password. Please try again.');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success!'),
          content: Text('Password changed successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the error dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
