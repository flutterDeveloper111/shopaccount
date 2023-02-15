import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/cashBookScreen.dart';
import 'package:account/widgets/custom_text_field.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';

class CashBookUploadScreen extends StatefulWidget {
  const CashBookUploadScreen({Key? key}) : super(key: key);
  _CashBookUploadScreenState createState() => _CashBookUploadScreenState();
}

class _CashBookUploadScreenState extends State<CashBookUploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController cashBookInfoController = TextEditingController();
  TextEditingController transDateController = TextEditingController();
  TextEditingController cashInAmountController = TextEditingController();
  TextEditingController cashOutAmountController = TextEditingController();
  TextEditingController onlineInAmountController = TextEditingController();
  TextEditingController onlineOutAmountController = TextEditingController();

  XFile? imageXFile;
  //nameController = sharedPreferences!.getString("name")!;
  final ImagePicker _picker = ImagePicker();

  //nameController = sharedPreferences!.getString("name")!;
  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();

  Position? position;
  List<Placemark>? placeMarks;

  String imageUrl = "";
  DateTime? todayDateTime = DateTime.now();
  DateTime? transDateTime = DateTime.now();
  //String completeAddress = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text =
          sharedPreferences!.getString("photoUrl")!.toString();
      cashBookInfoController.text = "Info";
      cashInAmountController.text = 0.toString();
      cashOutAmountController.text = 0.toString();
      onlineInAmountController.text = 0.toString();
      onlineOutAmountController.text = 0.toString();
      transDateController.text = "TransDate";
      transDateTime = DateTime.now();
    });
  }

  Future<void> formValidation() async {
    if (cashInAmountController.text.isNotEmpty) {
      setState(() {
        uploading = true;
      });

      //save info to firestore
      saveDataToFirestore();
      debugPrint('CashBook Uploaded in two docs');
      Navigator.pop(context);
      //send user to homePage
      Route newRoute =
          MaterialPageRoute(builder: (c) => const CashBookScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write the complete required info for CashBook.",
            );
          });
    }
  }

  clearMenusUploadForm() {
    imageController.clear();
    cashBookInfoController.clear();
    cashInAmountController.clear();
    cashOutAmountController.clear();
    onlineInAmountController.clear();
    onlineOutAmountController.clear();
  }

  saveDataToFirestore() {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("cashBook");

    ref.doc(uniqueIdName).set({
      "cashBookID": uniqueIdName,
      "shopUID": sharedPreferences!.getString("uid"),
      "cashBookInfo": cashBookInfoController.text.trim(),
      "cashInAmount": num.parse(cashInAmountController.text.trim()),
      "cashOutAmount": num.parse(cashOutAmountController.text.trim()),
      "onlineInAmount": int.parse(onlineInAmountController.text.trim()),
      "onlineOutAmount": int.parse(onlineOutAmountController.text.trim()),
      "transDate": DateTime.parse(transDateTime.toString()),
      "publishedDate": DateTime.now(),
      "status": "available",
    }).then(
      (value) {
        final poRef = FirebaseFirestore.instance.collection("cashBook");

        poRef.doc(uniqueIdName).set(
          {
            "cashBookID": uniqueIdName,
            "shopUID": sharedPreferences!.getString("uid"),
            "cashBookInfo": cashBookInfoController.text.trim(),
            "cashInAmount": int.parse(cashInAmountController.text.trim()),
            "cashOutAmount": int.parse(cashOutAmountController.text.trim()),
            "onlineInAmount": int.parse(onlineInAmountController.text.trim()),
            "onlineOutAmount": int.parse(onlineOutAmountController.text.trim()),
            "transDate": DateTime.parse(transDateTime.toString()),
            "publishedDate": DateTime.now(),
            "status": "available",
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
          'Cash Upload',
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
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      data: Icons.person,
                      controller: cashBookInfoController,
                      hintText: "Cash Info",
                      isObsecre: false,
                    ),
                    InkWell(
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => SizedBox(
                            height: 250,
                            child: CupertinoDatePicker(
                              backgroundColor: Colors.white,
                              initialDateTime: todayDateTime,
                              onDateTimeChanged: (DateTime newTime) {
                                setState(
                                  () => transDateTime = newTime,
                                );
                              },
                              use24hFormat: true,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Card(
                          elevation: 4,
                          color: Colors.white,

                          margin: const EdgeInsets.all(6),
//                          margin:EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            //set border radius more than 50% of height and width to make circle
                          ),
                          child: transDateTime == null
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 22),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.calendar_today),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        'Transaction Date',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      Text(" :Date"),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 22),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        '$transDateTime',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      const Text(" :Date"),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    CustomTextField(
                      data: Icons.book,
                      controller: cashInAmountController,
                      hintText: "Cash In Hand*",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.price_check,
                      controller: cashOutAmountController,
                      hintText: "Cash Out Hand",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.stacked_line_chart,
                      controller: onlineInAmountController,
                      hintText: "Online In Account",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.price_change,
                      controller: onlineOutAmountController,
                      hintText: "Online Out Account",
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
                  "Add Cash",
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
