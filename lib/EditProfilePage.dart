import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_place/google_place.dart';
import 'package:stocker/ProfilePage.dart';
import 'HomePageWithNavBar.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _sinController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = true;
  bool _isFirstTime = false;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    googlePlace = GooglePlace("AIzaSyDb4Hz-QA2By33rwPGaYGjQX3JEPwVNyhk");

    _locationController.addListener(() {
      _getAutocompleteSuggestions(_locationController.text);
    });
  }

  Future<void> _fetchProfileData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'] ?? '';
          _phoneController.text = userDoc['phone'] ?? '';
          _sinController.text = userDoc['sin'] ?? '';
          _locationController.text = userDoc['location'] ?? '';
          _isFirstTime = false;
        });
      } else {
        _isFirstTime = true;
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getAutocompleteSuggestions(String input) async {
    if (input.isNotEmpty) {
      var result = await googlePlace.autocomplete.get(
        input,
        types: "geocode",
        language: "en",
        components: [Component("country", "ca")],
      );

      if (result != null && result.predictions != null) {
        setState(() {
          predictions = result.predictions!;
        });
      } else {
        setState(() {
          predictions = [];
        });
      }
    } else {
      setState(() {
        predictions = [];
      });
    }
  }

  void _selectPrediction(AutocompletePrediction prediction) {
    setState(() {
      _locationController.text = prediction.description ?? '';
      predictions = [];
    });
  }

  bool _validateInput() {
    final phoneRegex = RegExp(r'^\d{10}$');
    final sinRegex = RegExp(r'^\d{9}$');

    if (!phoneRegex.hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must be exactly 10 digits')),
      );
      return false;
    }

    if (!sinRegex.hasMatch(_sinController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SIN must be exactly 9 digits')),
      );
      return false;
    }

    return true;
  }

  Future<void> _updateProfile() async {
    if (!_validateInput()) return;

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'sin': _sinController.text,
          'location': _locationController.text,
          'email': user.email,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        if (_isFirstTime) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePageWithNavBar()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'SIN'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  suffixIcon: Icon(Icons.location_on),
                ),
              ),
              // Display predictions list
              if (predictions.isNotEmpty)
                Container(
                  height: 200,
                  child: ListView.builder(
                    itemCount: predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(predictions[index].description ?? ''),
                        onTap: () => _selectPrediction(predictions[index]),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_place/google_place.dart';
//
// class EditProfilePage extends StatefulWidget {
//   @override
//   _EditProfilePageState createState() => _EditProfilePageState();
// }
//
// class _EditProfilePageState extends State<EditProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _sinController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//
//   bool _isLoading = true;
//   late GooglePlace googlePlace;
//   List<AutocompletePrediction> predictions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileData();
//     googlePlace = GooglePlace("YOUR_API_KEY");
//
//     _locationController.addListener(() {
//       _getAutocompleteSuggestions(_locationController.text);
//     });
//   }
//
//   Future<void> _fetchProfileData() async {
//     try {
//       User? user = _auth.currentUser;
//       if (user != null) {
//         DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
//
//         if (userDoc.exists) {
//           setState(() {
//             _nameController.text = userDoc['name'] ?? '';
//             _phoneController.text = userDoc['phone'] ?? '';
//             _sinController.text = userDoc['sin'] ?? '';
//             _locationController.text = userDoc['location'] ?? '';
//           });
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to fetch profile data: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _getAutocompleteSuggestions(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         predictions = [];
//       });
//       return;
//     }
//
//     try {
//       var result = await googlePlace.autocomplete.get(
//         input,
//         types: "address",
//         language: "en",
//       );
//
//       if (result != null && result.predictions != null) {
//         setState(() {
//           predictions = result.predictions!;
//         });
//       } else {
//         setState(() {
//           predictions = [];
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to fetch location suggestions: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             _buildDetailRow(Icons.person, 'Name', _nameController),
//             const Divider(),
//             _buildDetailRow(Icons.phone, 'Phone Number', _phoneController),
//             const Divider(),
//             _buildDetailRow(Icons.assignment, 'SIN', _sinController),
//             const Divider(),
//             _buildLocationRow(),
//             const Divider(),
//             ElevatedButton(
//               onPressed: _updateProfile,
//               child: const Text('Save Changes'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String title, TextEditingController controller) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 28, color: Colors.blue),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextField(
//                 controller: controller,
//                 decoration: InputDecoration(
//                   hintText: 'Enter $title',
//                   hintStyle: const TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLocationRow() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.location_on, size: 28, color: Colors.blue),
//             const SizedBox(width: 16),
//             Expanded(
//               child: TextField(
//                 controller: _locationController,
//                 decoration: const InputDecoration(
//                   labelText: 'Location',
//                   hintText: 'Enter your location',
//                 ),
//               ),
//             ),
//           ],
//         ),
//         if (predictions.isNotEmpty)
//           Container(
//             height: 200,
//             child: ListView.builder(
//               itemCount: predictions.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: Icon(Icons.location_on),
//                   title: Text(predictions[index].description ?? ''),
//                   onTap: () {
//                     _selectPrediction(predictions[index]);
//                   },
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }
//
//   void _selectPrediction(AutocompletePrediction prediction) {
//     setState(() {
//       _locationController.text = prediction.description ?? '';
//       predictions = [];
//     });
//   }
//
//   Future<void> _updateProfile() async {
//     try {
//       User? user = _auth.currentUser;
//       if (user != null) {
//         await _firestore.collection('users').doc(user.uid).set(
//           {
//             'name': _nameController.text,
//             'phone': _phoneController.text,
//             'sin': _sinController.text,
//             'location': _locationController.text,
//           },
//           SetOptions(merge: true),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully!')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update profile: $e')),
//       );
//     }
//   }
// }
