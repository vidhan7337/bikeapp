import 'package:bike_app/screens/home.dart';
import 'package:bike_app/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool loading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> updateUser(String n, String e, String a) {
    return users
        .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
        .update({'name': n, 'email': e, 'address': a})
        .then((value) => print("User Data Added"))
        .catchError((error) => print("Failed to add user data: $error"));
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      loading = true;
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
        .get()
        .then((DocumentSnapshot doc) {
      setState(() {
        nameController.text = (doc.data() as Map<String, dynamic>)['name'];
        emailController.text = (doc.data() as Map<String, dynamic>)['email'];
        addressController.text =
            (doc.data() as Map<String, dynamic>)['address'];
        phoneNumberController.text =
            FirebaseAuth.instance.currentUser!.phoneNumber!;
        loading = false;
      });
    });
    super.initState();
  }

  _singOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text("Profile",style: TextStyle(color: Colors.white),),
      ),
      body: loading
          ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 12.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
              ),
            )
          : Container(
              margin: const EdgeInsets.only(left: 25, right: 25),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/bike.png',
                      width: screenWidth / 2,
                      height: screenWidth / 2,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Phone",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(),
                        ),
                        //fillColor: Colors.green
                      ),
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Name",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(),
                        ),
                        //fillColor: Colors.green
                      ),
                      controller: nameController,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(),
                        ),
                        //fillColor: Colors.green
                      ),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Address",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(),
                        ),
                        //fillColor: Colors.green
                      ),
                      controller: addressController,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please Enter Name")));
                            } else if (emailController.text.isNotEmpty) {
                              var x = RegExp(
                                      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
                                      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
                                      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
                                      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
                                      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
                                      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
                                      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])')
                                  .hasMatch(emailController.text);
                              if (!x) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Please Enter valid email")));
                              } else {
                                loading=true;
                                updateUser(
                                    nameController.text,
                                    emailController.text,
                                    addressController.text);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => super.widget),
                                );
                              }
                            } else {
                              updateUser(nameController.text,
                                  emailController.text, addressController.text);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => super.widget),
                              );
                            }
                          },
                          child: const Text("Update Profile",style: TextStyle(color: Colors.white),)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            _singOut();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyPhone()),
                            );
                          },
                          child: const Text("Logout",style: TextStyle(color: Colors.white),)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
