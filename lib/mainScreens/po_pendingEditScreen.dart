import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/purchaseOrderPendingScreen.dart';
import 'package:account/model/purchaseOrders.dart';
import 'package:account/widgets/custom_text_field.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';

class PoPendingEditScreen extends StatefulWidget {
  PurchaseOrder? model;
  BuildContext? context;
  PoPendingEditScreen({this.model, this.context});
  PoPendingEditScreenState createState() => PoPendingEditScreenState();
}

class PoPendingEditScreenState extends State<PoPendingEditScreen> {
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

  String purchaseOrderImageUrl = "";
  //String completeAddress = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text = sharedPreferences!.getString("photoUrl")!;
      purchaseOrderNameController.text =
          widget.model!.purchaseOrderName!.toString();
      purchaseOrderInfoController.text =
          widget.model!.purchaseOrderInfo!.toString();
      totalAmountController.text = widget.model!.totalAmount!.toString();
      itemsCountController.text = widget.model!.itemsCount!.toString();
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
    if (purchaseOrderNameController.text.isNotEmpty &&
        purchaseOrderInfoController.text.isNotEmpty &&
        totalAmountController.text.isNotEmpty) {
      //start uploading image
      showDialog(
          context: context,
          builder: (c) {
            return LoadingDialog(
              message: "Updating Purchase Order",
            );
          });

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("purchaseOrders")
          .child(fileName);
      if (imageXFile == null) {
        purchaseOrderImageUrl = widget.model!.thumbnailUrl!.toString();
      } else {
        fStorage.UploadTask uploadTask =
            reference.putFile(File(imageXFile!.path));
        fStorage.TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
          purchaseOrderImageUrl = url;
        });
      }

      //save info to firestore
      saveDataToFirestore(purchaseOrderImageUrl).then(
        (value) {
          debugPrint('PriceList Updated ');
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
    setState(() {
      imageController.clear();
      purchaseOrderNameController.clear();
      purchaseOrderInfoController.clear();
      totalAmountController.clear();
      itemsCountController.clear();
      supplierNameController.clear();
      imageXFile = null;
    });
  }

  saveDataToFirestore(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("purchaseOrders");

    ref.doc(widget.model!.purchaseOrderID!.toString()).update({
      "purchaseOrderName": purchaseOrderNameController.text.toString(),
      "purchaseOrderInfo": purchaseOrderInfoController.text.toString(),
      "supplierName": supplierNameController.text.toString(),
      "totalAmountPrice": int.parse(totalAmountController.text.toString()),
      "itemsCountCount": int.parse(itemsCountController.text.toString()),
      "status": "available",
      "thumbnailUrl": downloadUrl,
    }).then(
      (value) {
        final custRef = FirebaseFirestore.instance.collection("purchaseOrders");

        custRef.doc(widget.model!.purchaseOrderID!.toString()).update(
          {
            "purchaseOrderName": purchaseOrderNameController.text.toString(),
            "purchaseOrderInfo": purchaseOrderInfoController.text.toString(),
            "supplierName": supplierNameController.text.toString(),
            "totalAmountPrice":
                int.parse(totalAmountController.text.toString()),
            "itemsCountCount": int.parse(itemsCountController.text.toString()),
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
            ),
          ),
        ),
        automaticallyImplyLeading: true,
        title: const Text(
          'Purchase Orders Edit',
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
                        controller: purchaseOrderNameController,
                        hintText: "Purchase Order Name *",
                        isObsecre: false,
                      ),
                    ),
                    CustomTextField(
                      data: Icons.book,
                      controller: purchaseOrderInfoController,
                      hintText: "Per Kgs, Numbers, Dozens *",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      //keyboardType: TextInputType.number,
                      //style: const TextStyle(color: Colors.black),
                      data: Icons.price_change,
                      controller: totalAmountController,
                      hintText: "purchase Order Amount *",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.stacked_line_chart,
                      controller: itemsCountController,
                      hintText: "Number Of Items",
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
