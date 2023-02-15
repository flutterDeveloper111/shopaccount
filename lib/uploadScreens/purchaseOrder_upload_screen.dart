import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/purchaseOrderPendingScreen.dart';
import 'package:account/model/purchaseOrders.dart';
import 'package:account/widgets/custom_text_field.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class PurchaseOrderListUploadScreen extends StatefulWidget {
  PurchaseOrder? model;
  BuildContext? context;
  PurchaseOrderListUploadScreen({this.model, this.context});
  _PurchaseOrderListUploadScreenState createState() =>
      _PurchaseOrderListUploadScreenState();
}

class _PurchaseOrderListUploadScreenState
    extends State<PurchaseOrderListUploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController purchaseOrderNameController = TextEditingController();
  TextEditingController purchaseOrderInfoController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController itemsCountController = TextEditingController();

  XFile? imageXFile;
  //nameController = sharedPreferences!.getString("name")!;
  final ImagePicker _picker = ImagePicker();

  //nameController = sharedPreferences!.getString("name")!;
  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();

  String imageUrl = "";
  //String completeAddress = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text = sharedPreferences!.getString("photoUrl")!;
      purchaseOrderNameController.text = "Name";
      purchaseOrderInfoController.text = "Information";
      totalAmountController.text = "Total Amount";
      itemsCountController.text = "Items Count";
      supplierNameController.text = "Supplier Name";
    });
  }

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> formValidation() async {
    if (purchaseOrderNameController.text.isNotEmpty &&
        purchaseOrderInfoController.text.isNotEmpty &&
        totalAmountController.text.isNotEmpty) {
      setState(() {
        uploading = true;
      });

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("purchaseOrders")
          .child(fileName);
      if (imageXFile == null) {
        imageUrl = sharedPreferences!.getString("photoUrl")!;
      } else {
        fStorage.UploadTask uploadTask =
            reference.putFile(File(imageXFile!.path));
        fStorage.TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
          imageUrl = url;
        });
      }

      //save info to firestore
      saveDataToFirestore(imageUrl).then(
        (value) {
          //print('PriceList Updated ');
          Navigator.pop(context);
          //send user to homePage
          Route newRoute = MaterialPageRoute(
              builder: (c) => const PurchaseOrdersPendingList());
          Navigator.pushReplacement(context, newRoute);
        },
      );
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write the complete required info for PO.",
            );
          });
    }
  }

  clearMenusUploadForm() {
    imageController.clear();
    purchaseOrderNameController.clear();
    purchaseOrderInfoController.clear();
    totalAmountController.clear();
    itemsCountController.clear();
    supplierNameController.clear();
  }

  saveDataToFirestore(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("purchaseOrders");

    ref.doc(uniqueIdName).set({
      "purchaseOrderID": uniqueIdName,
      "shopUID": sharedPreferences!.getString("uid"),
      "purchaseOrderName": purchaseOrderNameController.text.toString(),
      "purchaseOrderInfo": purchaseOrderInfoController.text.toString(),
      "suppliersName": supplierNameController.text.toString(),
      "totalAmount": int.parse(totalAmountController.text.toString()),
      "itemsCount": int.parse(itemsCountController.text.toString()),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl,
    }).then(
      (value) {
        final poRef = FirebaseFirestore.instance.collection("purchaseOrders");

        poRef.doc(uniqueIdName).set(
          {
            "purchaseOrderID": uniqueIdName,
            "shopUID": sharedPreferences!.getString("uid"),
            "purchaseOrderName": purchaseOrderNameController.text.toString(),
            "purchaseOrderInfo": purchaseOrderInfoController.text.toString(),
            "supplierName": supplierNameController.text.toString(),
            "totalAmount": int.parse(totalAmountController.text.toString()),
            "itemsCount": int.parse(itemsCountController.text.toString()),
            "publishedDate": DateTime.now(),
            "status": "available",
            "thumbnailUrl": downloadUrl,
          },
        );
      },
    ).then((value) {
      clearMenusUploadForm();

      setState(() {
        uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
        uploading = false;
      });
    });
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
          'Purchase Order Upload',
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
              uploading == true ? linearProgress() : const Text(""),
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
                        controller: purchaseOrderNameController,
                        hintText: "Name*",
                        isObsecre: false,
                      ),
                    ),
                    CustomTextField(
                      data: Icons.book,
                      controller: purchaseOrderInfoController,
                      hintText: "Per Kgs, Numbers, Dozens*",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.price_check,
                      controller: totalAmountController,
                      hintText: "Total Amount*",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.stacked_line_chart,
                      controller: itemsCountController,
                      hintText: "Items Count",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.price_change,
                      controller: supplierNameController,
                      hintText: "Suppliers List",
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
                  "Update PurchaseOrder",
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
