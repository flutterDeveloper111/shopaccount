import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/salesPriceListScreen.dart';
import 'package:account/model/priceList.dart';
import 'package:account/widgets/custom_text_field.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class PriceListEditScreen extends StatefulWidget {
  PriceList? model;
  BuildContext? context;
  PriceListEditScreen({this.model, this.context});

  _PriceListEditScreenState createState() => _PriceListEditScreenState();
}

class _PriceListEditScreenState extends State<PriceListEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController priceListNameController = TextEditingController();
  TextEditingController priceListInfoController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController inStockCountController = TextEditingController();

  XFile? imageXFile;
  //nameController = sharedPreferences!.getString("name")!;
  final ImagePicker _picker = ImagePicker();

  //nameController = sharedPreferences!.getString("name")!;
  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();

  Position? position;
  List<Placemark>? placeMarks;

  String priceListImageUrl = "";
  //String completeAddress = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text = widget.model!.thumbnailUrl.toString();
      priceListNameController.text = widget.model!.priceListName!;
      priceListInfoController.text = widget.model!.priceListInfo!;
      salePriceController.text = widget.model!.salePrice!.toString();
      purchasePriceController.text = widget.model!.purchasePrice!.toString();
      inStockCountController.text = widget.model!.inStockCount!.toString();
      supplierNameController.text = widget.model!.supplierName!.toString();
    });
  }

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> formValidation() async {
    if (priceListNameController.text.isNotEmpty &&
        priceListInfoController.text.isNotEmpty &&
        salePriceController.text.isNotEmpty) {
      //start uploading image
      showDialog(
          context: context,
          builder: (c) {
            return LoadingDialog(
              message: "Updating PriceList",
            );
          });

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("priceList")
          .child(fileName);
      if (imageXFile == null) {
        priceListImageUrl = widget.model!.thumbnailUrl!.toString();
      } else {
        fStorage.UploadTask uploadTask =
            reference.putFile(File(imageXFile!.path));
        fStorage.TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
          priceListImageUrl = url;
        });
      }

      //save info to firestore
      saveDataToFirestore(priceListImageUrl).then(
        (value) {
          //print('PriceList Updated ');
          Navigator.pop(context);
          //send user to homePage
          Route newRoute =
              MaterialPageRoute(builder: (c) => const SalesPriceListScreen());
          Navigator.pushReplacement(context, newRoute);
        },
      );
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write the complete required info for PriceList.",
            );
          });
    }
  }

  clearMenusUploadForm() {
    setState(() {
      priceListNameController.clear();
      priceListInfoController.clear();
      salePriceController.clear();
      purchasePriceController.clear();
      supplierNameController.clear();
      inStockCountController.clear();
      imageController.clear();

      imageXFile = null;
    });
  }

  saveDataToFirestore(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("priceList");

    ref.doc(widget.model!.priceListID!.toString()).update({
      "priceListName": priceListNameController.text.trim(),
      "priceListInfo": priceListInfoController.text.trim(),
      "supplierName": supplierNameController.text.trim(),
      "salePrice": num.parse(salePriceController.text.trim()),
      "purchasePrice": num.parse(purchasePriceController.text.trim()),
      "inStockCount": num.parse(inStockCountController.text.trim()),
      "status": "available",
      "thumbnailUrl": downloadUrl,
    }).then(
      (value) {
        final custRef = FirebaseFirestore.instance.collection("priceList");

        custRef.doc(widget.model!.priceListID!.toString()).update(
          {
            "priceListID": uniqueIdName,
            "shopUID": sharedPreferences!.getString("uid"),
            "priceListName": priceListNameController.text.toString(),
            "priceListInfo": priceListInfoController.text.toString(),
            "supplierName": supplierNameController.text.toString(),
            "salePrice": num.parse(salePriceController.text.toString()),
            "purchasePrice": num.parse(purchasePriceController.text.toString()),
            "inStockCount": num.parse(inStockCountController.text.toString()),
            "status": "available",
            "thumbnailUrl": downloadUrl,
          },
        ).then((value) {
          clearMenusUploadForm();

          setState(() {
            uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
            uploading = false;
          });
        });
      },
    );
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
          'PriceList Edit',
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
                        controller: priceListNameController,
                        hintText: "Name*",
                        isObsecre: false,
                      ),
                    ),
                    CustomTextField(
                      data: Icons.book,
                      controller: priceListInfoController,
                      hintText: "Per Kgs, Numbers, Dozens*",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.price_check,
                      controller: salePriceController,
                      hintText: "Sale Price*",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.price_change,
                      controller: purchasePriceController,
                      hintText: "purchasePrice",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.stacked_line_chart,
                      controller: inStockCountController,
                      hintText: "InStock",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.local_shipping,
                      controller: supplierNameController,
                      hintText: "Supplier Name",
                      isObsecre: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                child: const Text(
                  "Update PriceList",
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
