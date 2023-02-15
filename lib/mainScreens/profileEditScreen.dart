import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/home_screen.dart';
import 'package:account/widgets/custom_text_field.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController aboutUsController = TextEditingController();

  XFile? imageXFile;
  //nameController = sharedPreferences!.getString("name")!;
  final ImagePicker _picker = ImagePicker();

  //nameController = sharedPreferences!.getString("name")!;

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = "";
  String completeAddress = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text = sharedPreferences!.getString("photoUrl")!;
      nameController.text = sharedPreferences!.getString("name")!;
      emailController.text = sharedPreferences!.getString("email")!;
      passwordController.text = sharedPreferences!.getString("pwd")!;
      confirmPasswordController.text = sharedPreferences!.getString("pwd")!;
      phoneController.text = sharedPreferences!.getString("phone")!;
      aboutUsController.text = sharedPreferences!.getString("aboutUs")!;
      locationController.text = sharedPreferences!.getString("address")!;
    });
  }

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    position = newPosition;
    placeMarks =
        await placemarkFromCoordinates(position!.latitude, position!.longitude);

    Placemark pMark = placeMarks![0];

    String completeAddress =
        ' ${pMark.subThoroughfare} ${pMark.thoroughfare} , ${pMark.subLocality}  ${pMark.locality} , ${pMark.subAdministrativeArea} , ${pMark.administrativeArea}  ${pMark.postalCode} , ${pMark.country}';

    locationController.text = completeAddress;
  }

  Future<void> formValidation() async {
    if (passwordController.text == confirmPasswordController.text) {
      if (confirmPasswordController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          locationController.text.isNotEmpty &&
          aboutUsController.text.isNotEmpty) {
        //start uploading image
        showDialog(
            context: context,
            builder: (c) {
              return LoadingDialog(
                message: "Updating Account",
              );
            });

        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        fStorage.Reference reference = fStorage.FirebaseStorage.instance
            .ref()
            .child("shops")
            .child(fileName);
        if (imageXFile == null) {
          sellerImageUrl = sharedPreferences!.getString("photoUrl")!;
        } else {
          fStorage.UploadTask uploadTask =
              reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot =
              await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            sellerImageUrl = url;
          });
        }
        //save info to firestore
        saveDataToFirestore().then(
          (value) {
            debugPrint('Profile Updated ');
            Navigator.pop(context);
            //send user to homePage
            Route newRoute =
                MaterialPageRoute(builder: (c) => const HomeScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        );
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message:
                    "Please write the complete required info for Registration.",
              );
            });
      }
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Password do not match.",
            );
          });
    }
  }

  Future saveDataToFirestore() async {
    FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .update({
      //"sellerUID": currentUser.uid,
      "shopEmail": emailController.text.trim(),
      "shopName": nameController.text.trim(),
      "shopAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "aboutUs": aboutUsController.text.trim(),
      "address": locationController.text.trim(),
      //"status": "approved",
      //"earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
      "suppliersCount": 0,
      "customersCount": 0,
      "suppCashTotal": 0.0,
      "suppCredittotal": 0.0,
      "suppTransTotal": 0.0,
      "custCashTotal": 0.0,
      "custCredittotal": 0.0,
      "custTransTotal": 0.0,
      "transCashTotal": 0.0,
      "transCreditTotal": 0.0,
      "transSuppTotal": 0.0,
      "transCustTotal": 0.0,
      "suppCreditTransCount": 0.0,
      "custCashTransCount": 0.0,
      "suppCashTransCount": 0.0,
      "custCreditTransCount": 0.0,
    });
    debugPrint('Profile Data Updated into Firebase');

    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    //await sharedPreferences!.setString("uid", currentUser.uid);]
    await sharedPreferences!.setString("email", nameController.text.trim());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("pwd", passwordController.text.trim());
    await sharedPreferences!.setString("phone", phoneController.text.trim());
    await sharedPreferences!
        .setString("aboutUs", aboutUsController.text.trim());
    await sharedPreferences!
        .setString("address", locationController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Colors.cyan,
              Colors.amber,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        automaticallyImplyLeading: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: "Lobster",
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.amber,
                Colors.cyan,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  _getImage();
                },
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.20,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      NetworkImage(sharedPreferences!.getString("photoUrl")!),
                  child: imageXFile == null
                      ? Icon(
                          Icons.add_photo_alternate,
                          size: MediaQuery.of(context).size.width * 0.20,
                          color: Colors.greenAccent,
                        )
                      : null,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomTextField(
                        data: Icons.person,
                        controller: nameController,
                        hintText: "Name",
                        isObsecre: false,
                      ),
                    ),
                    CustomTextField(
                      data: Icons.email,
                      controller: emailController,
                      hintText: "Email",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.lock,
                      controller: passwordController,
                      hintText: "Password",
                      isObsecre: true,
                    ),
                    CustomTextField(
                      data: Icons.lock,
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      isObsecre: true,
                    ),
                    CustomTextField(
                      data: Icons.phone,
                      controller: phoneController,
                      hintText: "Phone",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.book_rounded,
                      controller: aboutUsController,
                      hintText: "AboutShop",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.my_location,
                      controller: locationController,
                      hintText: "Shop Address",
                      isObsecre: false,
                      enabled: true,
                    ),
                    Container(
                      width: 400,
                      height: 40,
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        label: const Text(
                          "Get my Current Location",
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          getCurrentLocation();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                child: const Text(
                  "Update Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyan,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
                onPressed: () {
                  formValidation();
                },
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
