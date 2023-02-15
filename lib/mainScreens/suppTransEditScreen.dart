import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/home_screen.dart';
import 'package:account/model/supTrans.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class SuppTransEditScreen extends StatefulWidget {
  SupTrans? model;
  BuildContext? context;
  SuppTransEditScreen({this.model, this.context});
  _SuppTransEditScreenState createState() => _SuppTransEditScreenState();
}

class _SuppTransEditScreenState extends State<SuppTransEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController transNameController = TextEditingController();
  TextEditingController transTypeController = TextEditingController();
  TextEditingController transInfoController = TextEditingController();
  TextEditingController transDateController = TextEditingController();
  TextEditingController transDueDateController = TextEditingController();
  TextEditingController transClosedDateController = TextEditingController();
  TextEditingController transPaymentDetailsController = TextEditingController();
  TextEditingController transAmountController = TextEditingController();

  XFile? imageXFile;
  //nameController = sharedPreferences!.getString("name")!;
  final ImagePicker _picker = ImagePicker();

  //nameController = sharedPreferences!.getString("name")!;

  Position? position;
  List<Placemark>? placeMarks;
  String? billType1;
  String? billType2;

  String custTransImageUrl = "";
  String completeAddress = "";
  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
  DateTime? todayDateTime = DateTime.now();
  DateTime? transDateTime;
  DateTime? transDueDateTime;
  DateTime? transClosedDateTime;

  @override
  void initState() {
    super.initState();
    setState(() {
      //billType = widget.model!.transType.toString() ?? "Cash";
    });
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text = widget.model!.thumbnailUrl!.toString();
      transNameController.text = widget.model!.transName!.toString();
      transInfoController.text = widget.model!.transInfo.toString();
      transTypeController.text = widget.model!.transType!.toString();
      transDateController.text = widget.model!.transDate!.toDate().toString();
      transDateTime = widget.model!.transDate!.toDate();
      transDueDateController.text =
          widget.model!.transDueDate!.toDate().toString();
      transDueDateTime = widget.model!.transDueDate!.toDate();
      transClosedDateController.text =
          widget.model!.transClosedDate!.toDate().toString();
      transClosedDateTime = widget.model!.transClosedDate!.toDate();
      transPaymentDetailsController.text =
          widget.model!.transPaymentDetails.toString();
      transAmountController.text = widget.model!.transAmount.toString();
      //print("Trans Type:: " + widget.model!.transType!.toString());
      //print("Trans Name ID:: " + widget.model!.suppTransID!.toString());
      billType1 = widget.model!.transType!.toString().contains("Cash")
          ? "Cash"
          : "Credit";
      //billType2 = billType1!.contains("Cash") ? "Credit" : "Cash";
    });
  }

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  clearMenusUploadForm() {
    setState(() {
      transNameController.clear();
      transTypeController.clear();
      transInfoController.clear();
      transPaymentDetailsController.clear();
      transAmountController.clear();
      transDateController.clear();
      transDueDateController.clear();
      transClosedDateController.clear();

      imageXFile = null;
    });
  }

  Future<void> validateUploadForm() async {
    if (transNameController.text.isNotEmpty &&
        transAmountController.text.isNotEmpty &&
        transTypeController.text.isNotEmpty) {
      debugPrint("Transaction Details are passed now");
      debugPrint("Transaction ID::" + widget.model!.suppTransID.toString());
      //start uploading image

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("suppTrans")
          .child(fileName);
      if (imageXFile == null) {
        custTransImageUrl = widget.model!.thumbnailUrl!.toString();
        debugPrint("Image URL" + custTransImageUrl);
      } else {
        fStorage.UploadTask uploadTask =
            reference.putFile(File(imageXFile!.path));
        fStorage.TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
          custTransImageUrl = url;
        });
      }
      //save info to firestore
      saveDataToFirestore(custTransImageUrl);

      debugPrint('Purchase Trans Updated ');
      Navigator.pop(context);
      //send user to homePage
      Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write the complete required info for Updation.",
            );
          });
    }
  }

  saveDataToFirestore(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("suppliers")
        .doc(widget.model!.supplierID)
        .collection("suppTrans");
    debugPrint("data Firestore reference is created.");

    ref.doc(widget.model!.suppTransID!.toString()).update({
      "transName": transNameController.text.toString(),
      "transType": transTypeController.text.toString(),
      "transInfo": transInfoController.text.toString(),
      "transPaymentDetails": transPaymentDetailsController.text.toString(),
      "transAmount": double.parse(transAmountController.text.trim()),
      "transDate": DateTime.parse(transDateController.text.trim()),
      "transDueDate": DateTime.parse(transDueDateController.text.trim()),
      "transClosedDate": DateTime.parse(transClosedDateController.text.trim()),
      "thumbnailUrl": downloadUrl,
    }).then((value) {
      debugPrint("First Firestore data is updated");
      final itemsRef = FirebaseFirestore.instance.collection("suppTrans");

      itemsRef.doc(widget.model!.suppTransID.toString()).update({
        "transName": transNameController.text.trim(),
        "transType": transTypeController.text.trim(),
        "transInfo": transInfoController.text.trim(),
        "transPaymentDetails": transPaymentDetailsController.text.trim(),
        "transAmount": double.parse(transAmountController.text.trim()),
        "transDate": DateTime.parse(transDateController.text.trim()),
        "transDueDate": DateTime.parse(transDueDateController.text.trim()),
        "transClosedDate":
            DateTime.parse(transClosedDateController.text.trim()),
        "thumbnailUrl": downloadUrl,
      });
      debugPrint("Second FireStore Data is Updated");
      debugPrint("Payment details::" + transAmountController.text.trim());
    }).then((value) {
      clearMenusUploadForm();

      setState(() {
        //uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
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
        title: const Text(
          "Updating Transaction",
          style: TextStyle(fontSize: 20, fontFamily: "Lobster"),
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          TextButton(
            child: const Text(
              "Update",
              style: TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: "Varela",
                letterSpacing: 1,
              ),
            ),
            onPressed: uploading ? null : () => validateUploadForm(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uploading == true ? linearProgress() : const Text(""),
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(360),
                      border: Border.all(color: Colors.grey, width: 1),
                      image: DecorationImage(
                        image: NetworkImage(
                            widget.model!.thumbnailUrl!.toString()),
                        fit: BoxFit.cover,
                      )),
                ),
              ),

              /* Container(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          NetworkImage(widget.model!.thumbnailUrl!.toString()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
           ),*/
              /*const Divider(
                  color: Colors.amber,
                  thickness: 1,
                ),*/
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                color: Colors.grey.shade200,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: transNameController,
                    decoration: const InputDecoration(
                      label: Text("Transaction Name *"),
                      prefixIcon: Icon(Icons.title),
                      hintText: "Transaction Name *",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              /*  ListTile(
                leading: const Icon(
                  Icons.title,
                  color: Colors.cyan,
                ),
                title: Container(
                  width: 250,
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: transNameController,
                    decoration: const InputDecoration(
                      hintText: "Transaction Name *",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
                const Divider(
                  color: Colors.amber,
                  thickness: 1,
                ),*/
              const SizedBox(
                height: 10,
              ),
              Card(
                elevation: 4,
                color: Colors.grey.shade200,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          value: billType1,
                          //icon: Icon(Icons.menu),
                          style: const TextStyle(color: Colors.black),
                          //itemHeight: 2,

                          underline: Container(color: Colors.white),
                          isExpanded: true,

                          onChanged: (String? newValue) {
                            setState(
                              () {
                                transTypeController.text = newValue.toString();
                                billType1 = newValue.toString();
                              },
                            );
                          },
                          items: const [
                            DropdownMenuItem<String>(
                              value: "Cash",
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Credit',
                              child: Text('Credit'),
                            ),
                          ],
                        ),
                      ),
                      //Text(":Type")
                    ],
                  ),
                ),
              ),
              /*ListTile(
                  leading: const Icon(
                    Icons.menu,
                    color: Colors.cyan,
                  ),
                  title: Container(
                    width: 250,
                    /*decoration: InputDecoration(
                border: InputBorder.none,
              ),*/
                    child: DropdownButton<String>(

                      value: billType1,
                      //icon: Icon(Icons.menu),
                      style: const TextStyle(color: Colors.black),

                      //itemHeight: 2,
                      underline: Container(color: Colors.white),
                      onChanged: (String? newValue) {
                        setState(
                          () {
                            transTypeController.text = newValue.toString();
                            billType1 = newValue.toString();
                          },
                        );
                      },
                      padding : EdgeInsets.only(left:10)
                      items: const [
                        DropdownMenuItem<String>(
                          value: "Cash",
                          child: Text('Cash'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Credit',
                          child: Text('Credit'),
                        ),
                      ],
                    ),
                  ),
                ),*/
              /*const Divider(
                  color: Colors.amber,
                  thickness: 1,
                ),*/
              /*ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.cyan,
                  ),
                  title:*/
              const SizedBox(
                height: 10,
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
                child: Card(
                  elevation: 4,
                  color: Colors.grey.shade200,
                  child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
                      //margin: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),

                      // padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
                      child: transDateTime == null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
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
                              ))
                          : Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    '$transDateTime',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const Text(" :Date"),
                                ],
                              ))

                      //style: const TextStyle(color: Colors.grey),
                      ),
                ),
              ),

              /*ListTile(
                  leading: const Icon(
                    Icons.currency_exchange,
                    color: Colors.cyan,
                  ),
                  title: */
              const SizedBox(
                height: 20,
              ),
              Card(
                elevation: 4,
                color: Colors.grey.shade200,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    controller: transAmountController,
                    decoration: const InputDecoration(
                      label: Text("Transaction Amount *"),
                      hintText: "Transaction Amount *",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.currency_exchange,
                      ),
                    ),
                  ),
                ),
              ),

              /* ListTile(
                  leading: const Icon(
                    Icons.perm_device_information,
                    color: Colors.cyan,
                  ),
                  title: */
              const SizedBox(
                height: 20,
              ),
              Card(
                elevation: 4,
                color: Colors.grey.shade200,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: transInfoController,
                    decoration: const InputDecoration(
                      label: Text("Transaction Info"),
                      hintText: "Transaction Info",
                      prefixIcon: Icon(Icons.perm_device_information),
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
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
                            () => transDueDateTime = newTime,
                          );
                        },
                        use24hFormat: true,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  color: Colors.grey.shade200,
                  child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
                      //margin: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),

                      // padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
                      child: transDueDateTime == null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: const [
                                  Icon(Icons.calendar_today),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    'Bill Due Date',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(" :DueDate"),
                                ],
                              ))
                          : Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    '$transDueDateTime',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const Text(" :DueDate"),
                                ],
                              ))

                      //style: const TextStyle(color: Colors.grey),
                      ),
                ),
              ),
              const SizedBox(
                height: 20,
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
                            () => transClosedDateTime = newTime,
                          );
                        },
                        use24hFormat: true,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  color: Colors.grey.shade200,
                  child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
                      //margin: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),

                      // padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
                      child: transClosedDateTime == null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: const [
                                  Icon(Icons.calendar_today),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    'Bill Closed Date',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(" :ClosedDate"),
                                ],
                              ))
                          : Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    '$transClosedDateTime',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const Text(" :ClosedDate"),
                                ],
                              ))

                      //style: const TextStyle(color: Colors.grey),
                      ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                elevation: 4,
                color: Colors.grey.shade200,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    controller: transPaymentDetailsController,
                    decoration: const InputDecoration(
                      label: Text("Partial Payment Details"),
                      prefixIcon: Icon(Icons.currency_exchange),
                      hintText: "Partial Payment Details",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
