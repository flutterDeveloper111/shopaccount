import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/cashBookScreen.dart';
import 'package:account/model/cashBook.dart';
import 'package:account/widgets/custom_text_field.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CashBookEditScreen extends StatefulWidget {
  CashBook? model;
  BuildContext? context;
  CashBookEditScreen({this.model, this.context});
  CashBookEditScreenState createState() => CashBookEditScreenState();
}

class CashBookEditScreenState extends State<CashBookEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController cashBookInfoController = TextEditingController();
  TextEditingController transDateController = TextEditingController();
  TextEditingController cashInAmountController = TextEditingController();
  TextEditingController cashOutAmountController = TextEditingController();
  TextEditingController onlineInAmountController = TextEditingController();
  TextEditingController onlineOutAmountController = TextEditingController();

  //nameController = sharedPreferences!.getString("name")!;

  //nameController = sharedPreferences!.getString("name")!;
  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();

  Position? position;
  List<Placemark>? placeMarks;
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
      imageController.text = sharedPreferences!.getString("photoUrl")!;
      cashBookInfoController.text = widget.model!.cashBookInfo!.toString();
      cashInAmountController.text = widget.model!.cashInAmount!.toString();
      transDateController.text = widget.model!.transDate!.toDate().toString();
      cashOutAmountController.text = widget.model!.cashOutAmount!.toString();
      onlineInAmountController.text = widget.model!.onlineInAmount!.toString();
      onlineOutAmountController.text =
          widget.model!.onlineOutAmount!.toString();
      transDateTime = widget.model!.transDate!.toDate();
    });
  }

  Future<void> formValidation() async {
    if (cashInAmountController.text.isNotEmpty) {
      setState(() {
        uploading = true;
      });
      debugPrint("Transaction Details are passed now");
      //start uploading image

      //save info to firestore
      saveDataToFirestore();
      debugPrint('CashBook Updated in two docs ');
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
              message: "Please write the complete required info for  CashBook.",
            );
          });
    }
  }

  clearMenusUploadForm() {
    setState(() {
      imageController.clear();
      cashBookInfoController.clear();
      cashInAmountController.clear();
      cashOutAmountController.clear();
      onlineInAmountController.clear();
      onlineOutAmountController.clear();
    });
  }

  saveDataToFirestore() {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("cashBook");

    ref.doc(widget.model!.cashBookID!.toString()).update({
      "cashBookInfo": cashBookInfoController.text.trim(),
      "cashInAmount": num.parse(cashInAmountController.text.trim()),
      "cashOutAmount": num.parse(cashOutAmountController.text.trim()),
      "onlineInAmount": num.parse(onlineInAmountController.text.trim()),
      "onlineOutAmount": num.parse(onlineOutAmountController.text.trim()),
      "transDate": DateTime.parse(transDateTime.toString()),
    }).then(
      (value) {
        debugPrint("First Firestore data is updated");
        final custRef = FirebaseFirestore.instance.collection("cashBook");

        custRef.doc(widget.model!.cashBookID!.toString()).update(
          {
            "cashBookInfo": cashBookInfoController.text.trim(),
            "cashInAmount": num.parse(cashInAmountController.text.trim()),
            "cashOutAmount": num.parse(cashOutAmountController.text.trim()),
            "onlineInAmount": num.parse(onlineInAmountController.text.trim()),
            "onlineOutAmount": num.parse(onlineOutAmountController.text.trim()),
            "transDate": DateTime.parse(transDateTime.toString()),
          },
        ).then((value) {
          debugPrint("second Firestore data is updated");
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
          'Cash Edit',
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
                      hintText: "Info",
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
                      hintText: "Cash In Amount*",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      //keyboardType: TextInputType.number,
                      //style: const TextStyle(color: Colors.black),
                      data: Icons.price_change,
                      controller: cashOutAmountController,
                      hintText: "Cash Out Amount",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.stacked_line_chart,
                      controller: onlineInAmountController,
                      hintText: "Online In Amount",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.local_shipping,
                      controller: onlineOutAmountController,
                      hintText: "Online Out Amount",
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
                  "Update Cash",
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
