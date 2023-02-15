import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/salesOrderPendingScreen.dart';
import 'package:account/model/salesOrder.dart';
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

class SalesOrderPendingEditScreen extends StatefulWidget {
  SalesOrder? model;
  BuildContext? context;

  SalesOrderPendingEditScreen({this.model, this.context});
  SalesOrderPendingEditScreenState createState() =>
      SalesOrderPendingEditScreenState();
}

class SalesOrderPendingEditScreenState
    extends State<SalesOrderPendingEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController salesOrderNameController = TextEditingController();
  TextEditingController salesOrderInfoController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController itemsCountController = TextEditingController();

  XFile? imageXFile;
  //nameController = sharedPreferences!.getString("name")!;
  final ImagePicker _picker = ImagePicker();

  //nameController = sharedPreferences!.getString("name")!;
  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();

  Position? position;
  List<Placemark>? placeMarks;

  String salesOrderImageUrl = "";
  //String completeAddress = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text = widget.model!.thumbnailUrl.toString();
      salesOrderNameController.text = widget.model!.salesOrderName.toString();
      salesOrderInfoController.text = widget.model!.salesOrderInfo.toString();
      totalAmountController.text = widget.model!.totalAmount.toString();
      itemsCountController.text = widget.model!.itemsCount.toString();
      customerNameController.text = widget.model!.customerName.toString();
    });
  }

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> formValidation() async {
    if (salesOrderNameController.text.isNotEmpty &&
        salesOrderInfoController.text.isNotEmpty &&
        totalAmountController.text.isNotEmpty) {
      //start uploading image
      showDialog(
          context: context,
          builder: (c) {
            return LoadingDialog(
              message: "Updating SalesOrder",
            );
          });

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("salesOrders")
          .child(fileName);
      if (imageXFile == null) {
        salesOrderImageUrl = widget.model!.thumbnailUrl!.toString();
      } else {
        fStorage.UploadTask uploadTask =
            reference.putFile(File(imageXFile!.path));
        fStorage.TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
          salesOrderImageUrl = url;
        });
      }

      //save info to firestore
      saveDataToFirestore(salesOrderImageUrl).then(
        (value) {
          //print('PriceList Updated ');
          Navigator.pop(context);
          //send user to homePage
          Route newRoute =
              MaterialPageRoute(builder: (c) => const SalesOrderPendingList());
          Navigator.pushReplacement(context, newRoute);
        },
      );
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write the complete required info for SO.",
            );
          });
    }
  }

  clearMenusUploadForm() {
    setState(() {
      imageController.clear();
      salesOrderNameController.clear();
      salesOrderInfoController.clear();
      totalAmountController.clear();
      itemsCountController.clear();
      customerNameController.clear();
      imageXFile = null;
    });
  }

  saveDataToFirestore(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("salesOrders");

    ref.doc(widget.model!.salesOrderID).update({
      "salesOrderName": salesOrderNameController.text.toString(),
      "salesOrderInfo": salesOrderInfoController.text.toString(),
      "customerName": customerNameController.text.toString(),
      "totalAmount": int.parse(totalAmountController.text.toString()),
      "itemsCount": int.parse(itemsCountController.text.toString()),
      "status": "available",
      "thumbnailUrl": downloadUrl,
    }).then(
      (value) {
        final custRef = FirebaseFirestore.instance.collection("priceList");

        custRef.doc(widget.model!.salesOrderID).update(
          {
            "salesOrderName": salesOrderNameController.text.toString(),
            "salesOrderInfo": salesOrderInfoController.text.toString(),
            "customerName": customerNameController.text.toString(),
            "totalAmount": int.parse(totalAmountController.text.toString()),
            "itemsCount": int.parse(itemsCountController.text.toString()),
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
          'Sales Order Edit',
          style: TextStyle(
            fontSize: 18,
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
                      ? NetworkImage(imageController.text) as ImageProvider
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
                        controller: salesOrderNameController,
                        hintText: "Name*",
                        isObsecre: false,
                      ),
                    ),
                    CustomTextField(
                      data: Icons.book,
                      controller: salesOrderInfoController,
                      hintText: "Per Kgs, Numbers, Dozens *",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.price_check,
                      controller: totalAmountController,
                      hintText: "Sale Order Amount *",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.stacked_line_chart,
                      controller: itemsCountController,
                      hintText: "Items Count",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.local_shipping,
                      controller: customerNameController,
                      hintText: "Customer Name",
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
                  "Update SalesOrder",
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
