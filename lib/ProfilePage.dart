import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/BankAccountPage.dart';
import 'ProfileDetailsPage.dart';
import 'ResetPasswordPage.dart';
import 'AccountClosurePage.dart';
import 'LoginPage.dart';

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
        title: const Text('Account'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text('No user data found'))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      userData!['name'] != null
                          ? userData!['name'][0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData!['name'] ?? 'User Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      // Text(
                      //   'CLIENT ID - ${user?.uid ?? 'N/A'}',
                      //   style: const TextStyle(color: Colors.grey),
                      // ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionItem(
                context,
                title: 'Personal Details',
                subtitle: 'Mobile, Email, Address',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileDetailsPage(),
                    ),
                  );
                },
              ),
              _buildSectionItem(
                context,
                title: 'Bank Accounts',
                subtitle: 'Add, Edit or Delete Bank details',
                icon: Icons.account_balance,
                onTap: () {Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankAccountPage(),
                  ),
                );},
              ),
              // _buildSectionItem(
              //   context,
              //   title: 'Manage Segment',
              //   subtitle: 'Equity, FnO, Currency, Commodity',
              //   icon: Icons.settings,
              //   onTap: () {},
              // ),
              // _buildSectionItem(
              //   context,
              //   title: 'Nominee',
              //   subtitle: 'Update Nominee Details',
              //   icon: Icons.person_add_alt_1,
              //   onTap: () {},
              // ),
              _buildSectionItem(
                context,
                title: 'Password & Security',
                subtitle: 'Change your password',
                icon: Icons.lock_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                  );
                },
              ),
              _buildSectionItem(
                context,
                title: 'Account Closure',
                subtitle: 'Account closure is permanent and irreversible',
                icon: Icons.close,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountClosurePage()),
                  );
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: logout,
                  child: const Text('Log Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionItem(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }
}
