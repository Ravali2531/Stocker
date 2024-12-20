import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/ResetPasswordPage.dart';
import 'package:stocker/AccountClosurePage.dart';
import 'package:stocker/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

        if (snapshot.exists) {
          setState(() {
            userData = snapshot.data();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text('No user data found'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display User's Name and Initials
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData!['name'] ?? 'User Name',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.uid ?? 'User ID',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      userData!['name'] != null
                          ? userData!['name'][0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Email
              ListTile(
                title: const Text('E-mail'),
                subtitle: Text(userData!['email'] ?? 'Not available'),
              ),
              const Divider(),

              // Phone
              ListTile(
                title: const Text('Phone'),
                subtitle: Text(userData!['phone'] ?? 'Not available'),
              ),
              const Divider(),

              // SIN
              ListTile(
                title: const Text('SIN'),
                subtitle: Text(userData!['sin'] ?? 'Not available'),
              ),
              const Divider(),

              // Location
              ListTile(
                title: const Text('Location'),
                subtitle: Text(userData!['location'] ?? 'Not available'),
              ),
              const Divider(),

              // Password & Security
              ListTile(
                title: const Text('Password & Security'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                    );
                  },
                  child: const Text('Manage', style: TextStyle(color: Colors.blue)),
                ),
              ),
              const Divider(),

              // Account Closure
              ListTile(
                title: const Text('Account Closure'),
                subtitle: const Text('Account closure is permanent and irreversible.'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AccountClosurePage()),
                    );
                  },
                  child: const Text('Continue', style: TextStyle(color: Colors.blue)),
                ),
              ),
              const Divider(),

              // Log Out Button
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: logout,
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
