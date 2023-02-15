import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/suppliersScreen.dart';
import 'package:account/model/suppliers.dart';
import 'package:account/widgets/custom_text_field.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';

class SupplierEditScreen extends StatefulWidget {
  Suppliers? model;
  BuildContext? context;
  SupplierEditScreen({this.model, this.context});
  _SupplierEditScreenState createState() => _SupplierEditScreenState();
}

class _SupplierEditScreenState extends State<SupplierEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController suppNameController = TextEditingController();
  TextEditingController suppInfoController = TextEditingController();
  TextEditingController suppContactController = TextEditingController();
  TextEditingController suppAddressController = TextEditingController();

  XFile? imageXFile;
  //nameController = sharedPreferences!.getString("name")!;
  final ImagePicker _picker = ImagePicker();

  //nameController = sharedPreferences!.getString("name")!;

  Position? position;
  List<Placemark>? placeMarks;

  String supplierImageUrl = "";
  String completeAddress = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text = widget.model!.thumbnailUrl!.toString();
      suppNameController.text = widget.model!.supplierName!.toString();
      suppInfoController.text = widget.model!.supplierInfo!.toString();
      suppContactController.text = widget.model!.supplierContact!;
      suppAddressController.text = widget.model!.supplierAddress!;
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

    suppAddressController.text = completeAddress;
  }

  Future<void> formValidation() async {
    if (suppNameController.text.isNotEmpty &&
        suppContactController.text.isNotEmpty) {
      //start uploading image
      showDialog(
          context: context,
          builder: (c) {
            return LoadingDialog(
              message: "Updating supplier",
            );
          });

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("suppliers")
          .child(fileName);
      if (imageXFile == null) {
        supplierImageUrl = widget.model!.thumbnailUrl!;
      } else {
        fStorage.UploadTask uploadTask =
            reference.putFile(File(imageXFile!.path));
        fStorage.TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
          supplierImageUrl = url;
        });
      }
      //save info to firestore
      saveDataToFirestore().then(
        (value) {
          //print('customer Updated ');
          Navigator.pop(context);
          //send user to homePage
          Route newRoute =
              MaterialPageRoute(builder: (c) => const SuppliersScreen());
          Navigator.pushReplacement(context, newRoute);
        },
      );
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write the complete required info for supplier.",
            );
          });
    }
  }

  Future saveDataToFirestore() async {
    FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("suppliers")
        .doc(widget.model!.supplierID!)
        .update({
      //"sellerUID": currentUser.uid,
      "supplierName": suppNameController.text.trim(),
      "thumbnailUrl": supplierImageUrl,
      "supplierContact": suppContactController.text.trim(),
      "supplierInfo": suppInfoController.text.trim(),
      "supplierAddress": suppAddressController.text.trim(),
      //"status": "approved",
      //"earnings": 0.0,
    }).then((value) {
      final custRef = FirebaseFirestore.instance.collection("suppliers");

      custRef.doc(widget.model!.supplierID!).update(
        {
          "supplierName": suppNameController.text.toString(),
          "supplierInfo": suppInfoController.text.toString(),
          "supplierContact": suppContactController.text.toString(),
          "supplierAddress": suppAddressController.text.toString(),
          "thumbnailUrl": supplierImageUrl,
        },
      );
    });
    debugPrint('Supplier Data Updated into Firebase');

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
          'Edit Supplier',
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
                        controller: suppNameController,
                        hintText: "Name*",
                        isObsecre: false,
                      ),
                    ),
                    CustomTextField(
                      data: Icons.phone,
                      controller: suppContactController,
                      hintText: "Phone*",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.book_rounded,
                      controller: suppInfoController,
                      hintText: "About Supplier",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.my_location,
                      controller: suppAddressController,
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
                  "Update Supplier",
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
