import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/expensesScreen.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class ExpenseUploadScreen extends StatefulWidget {
  const ExpenseUploadScreen({Key? key}) : super(key: key);
  _ExpenseUploadScreenState createState() => _ExpenseUploadScreenState();
}

class _ExpenseUploadScreenState extends State<ExpenseUploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController imageController = TextEditingController();
  TextEditingController expenseTypeController = TextEditingController();
  TextEditingController expenseInfoController = TextEditingController();
  TextEditingController transDateController = TextEditingController();
  TextEditingController cashOutAmountController = TextEditingController();
  TextEditingController onlineOutAmountController = TextEditingController();

  XFile? imageXFile;
  //nameController = sharedPreferences!.getString("name")!;
  final ImagePicker _picker = ImagePicker();

  //nameController = sharedPreferences!.getString("name")!;

  String? billType1;
  String? billType2;

  String imageUrl = "";
  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
  DateTime? todayDateTime = DateTime.now();
  DateTime? transDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text =
          sharedPreferences!.getString("photoUrl")!.toString();
      expenseInfoController.text = "Expense Info";
      expenseTypeController.text = "Type";
      transDateController.text = "TransDate";
      transDateTime = DateTime.now();
      onlineOutAmountController.text = 0.toString();
      cashOutAmountController.text = 0.toString();
      //debugPrint("Trans Type:: " + widget.model!.transType!.toString());
      //debugPrint("Trans Name ID:: " + widget.model!.suppTransID!.toString());
      billType1 = "ShopRent";

      //billType2 = billType1!.contains("Cash") ? "Credit" : "Cash";
    });
  }

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> validateUploadForm() async {
    if (cashOutAmountController.text.isNotEmpty) {
      setState(() {
        uploading = true;
      });
      debugPrint("Transaction Details are passed now");
      //debugPrint("Transaction ID::" + widget.model!.expenseID!.toString());
      //start uploading image

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("expenses")
          .child(fileName);
      if (imageXFile == null) {
        imageUrl = sharedPreferences!.getString("photoUrl")!.toString();
        debugPrint("Image URL" + imageUrl);
      } else {
        fStorage.UploadTask uploadTask =
            reference.putFile(File(imageXFile!.path));
        fStorage.TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
          imageUrl = url;
        });
      }
      saveDataToFirestore(imageUrl);
      debugPrint('Expense Uploaded in two docs');
      Navigator.pop(context);
      //send user to homePage
      Route newRoute =
          MaterialPageRoute(builder: (c) => const ExpensesScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message:
                  "Please write the complete required info for Expense Upload.",
            );
          });
    }
  }

  clearMenusUploadForm() {
    setState(() {
      expenseInfoController.clear();
      expenseTypeController.clear();
      onlineOutAmountController.clear();
      cashOutAmountController.clear();
      transDateController.clear();

      imageXFile = null;
    });
  }

  saveDataToFirestore(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("expenses");
    debugPrint("data Firestore reference is created.");

    ref.doc(uniqueIdName.toString()).set({
      "expenseID": uniqueIdName,
      "shopUID": sharedPreferences!.getString("uid"),
      "expenseType": expenseTypeController.text.toString(),
      "expenseInfo": expenseInfoController.text.toString(),
      "onlineOutAmount": num.parse(onlineOutAmountController.text.trim()),
      "cashOutAmount": num.parse(cashOutAmountController.text.trim()),
      "transDate": DateTime.parse(transDateTime.toString()),
      "thumbnailUrl": downloadUrl,
      "status": "available",
    }).then((value) {
      debugPrint("First Firestore data is Added");
      final itemsRef = FirebaseFirestore.instance.collection("expenses");

      itemsRef.doc(uniqueIdName.toString()).set({
        "expenseID": uniqueIdName,
        "shopUID": sharedPreferences!.getString("uid"),
        "expenseType": expenseTypeController.text.toString(),
        "expenseInfo": expenseInfoController.text.toString(),
        "onlineOutAmount": num.parse(onlineOutAmountController.text.trim()),
        "cashOutAmount": num.parse(cashOutAmountController.text.trim()),
        "transDate": DateTime.parse(transDateTime.toString()),
        "thumbnailUrl": downloadUrl,
        "status": "available",
      });
      debugPrint("Second FireStore Data is Updated");
      debugPrint("Payment details::" + cashOutAmountController.text.trim());
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
          "Uploading Expenses",
          style: TextStyle(fontSize: 20, fontFamily: "Lobster"),
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          TextButton(
            child: const Text(
              "ADD",
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
              InkWell(
                onTap: () {
                  _getImage();
                },
                child: Center(
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
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  //color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: expenseInfoController,
                  decoration: const InputDecoration(
                    label: Text("Transaction Info *"),
                    prefixIcon: Icon(Icons.title),
                    hintText: "Transaction Info *",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  // color: Colors.grey.shade200,
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
                              expenseTypeController.text = newValue.toString();
                              billType1 = newValue.toString();
                            },
                          );
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: "ShopRent",
                            child: Text('ShopRent'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Salaries',
                            child: Text('Salaries'),
                          ),
                          DropdownMenuItem<String>(
                            value: "Electricity",
                            child: Text('Electricity'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Labour',
                            child: Text('Labour'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                      ),
                    ),
                    //Text(":Type")
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
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
                child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.5),
                      // color: Colors.grey.shade200,
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
                                const Text(" :Date"),
                                Text(
                                  '$transDateTime',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ))

                    //style: const TextStyle(color: Colors.grey),
                    ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  //  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  controller: cashOutAmountController,
                  decoration: const InputDecoration(
                    label: Text("Cash Payment*"),
                    hintText: "Cash Payment*",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.currency_exchange,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  // color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  controller: onlineOutAmountController,
                  decoration: const InputDecoration(
                    label: Text("Online Payment "),
                    prefixIcon: Icon(Icons.currency_exchange),
                    hintText: "ONline Payment ",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
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
