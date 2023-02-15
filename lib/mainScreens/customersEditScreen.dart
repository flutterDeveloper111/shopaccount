import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/customersScreen.dart';
//import 'package:account/mainScreens/home_screen.dart';
import 'package:account/model/customers.dart';
//import 'package:account/model/suppliers.dart';
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

class CustomerEditScreen extends StatefulWidget {
  Customers? model;
  BuildContext? context;
  CustomerEditScreen({this.model, this.context});
  _CustomerEditScreenState createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends State<CustomerEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController custNameController = TextEditingController();
  TextEditingController custInfoController = TextEditingController();
  TextEditingController custContactController = TextEditingController();
  TextEditingController custAddressController = TextEditingController();

  XFile? imageXFile;
  //nameController = sharedPreferences!.getString("name")!;
  final ImagePicker _picker = ImagePicker();

  //nameController = sharedPreferences!.getString("name")!;

  Position? position;
  List<Placemark>? placeMarks;

  String customerImageUrl = "";
  String completeAddress = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text = widget.model!.thumbnailUrl!.toString();
      custNameController.text = widget.model!.customerName!;
      custInfoController.text = widget.model!.customerInfo!;
      custContactController.text = widget.model!.customerContact!.toString();
      custAddressController.text = widget.model!.customerAddress!;
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

    custAddressController.text = completeAddress;
  }

  Future<void> formValidation() async {
    if (custNameController.text.isNotEmpty &&
        custContactController.text.isNotEmpty) {
      //start uploading image
      showDialog(
          context: context,
          builder: (c) {
            return LoadingDialog(
              message: "Updating Customer",
            );
          });

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("customers")
          .child(fileName);
      if (imageXFile == null) {
        customerImageUrl = widget.model!.thumbnailUrl!;
      } else {
        fStorage.UploadTask uploadTask =
            reference.putFile(File(imageXFile!.path));
        fStorage.TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
          customerImageUrl = url;
        });
      }
      //save info to firestore
      saveDataToFirestore().then(
        (value) {
          //print('customer Updated ');
          Navigator.pop(context);
          //send user to homePage
          Route newRoute =
              MaterialPageRoute(builder: (c) => const CustomersScreen());
          Navigator.pushReplacement(context, newRoute);
        },
      );
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write the complete required info for customers.",
            );
          });
    }
  }

  Future saveDataToFirestore() async {
    FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("customers")
        .doc(widget.model!.custID!.toString())
        .update({
      //"sellerUID": currentUser.uid,
      "customerName": custNameController.text.trim(),
      "thumbnailUrl": customerImageUrl,
      "customerContact": custContactController.text.trim(),
      "customerInfo": custInfoController.text.trim(),
      "customerAddress": custAddressController.text.trim(),
      //"status": "approved",
      //"earnings": 0.0,
    }).then((value) {
      final custRef = FirebaseFirestore.instance.collection("customers");

      custRef.doc(widget.model!.custID!.toString()).update(
        {
          "customerName": custNameController.text.toString(),
          "customerInfo": custInfoController.text.toString(),
          "customerContact": int.parse(custContactController.text.toString()),
          "customerAddress": custAddressController.text.toString(),
          "thumbnailUrl": customerImageUrl,
        },
      );
    });
    debugPrint('Customer Data Updated into Firebase');

    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
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
          'Edit Customer',
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
                  backgroundImage: imageXFile == null
                      ? NetworkImage(widget.model!.thumbnailUrl!.toString())
                          as ImageProvider
                      : FileImage(File(imageXFile!.path)) as ImageProvider,
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
                        controller: custNameController,
                        hintText: "Name*",
                        isObsecre: false,
                      ),
                    ),
                    CustomTextField(
                      data: Icons.phone,
                      controller: custContactController,
                      hintText: "Phone*",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.book_rounded,
                      controller: custInfoController,
                      hintText: "About Customer",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.my_location,
                      controller: custAddressController,
                      hintText: "Address",
                      isObsecre: false,
                      enabled: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                child: const Text(
                  "Update Customer",
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
