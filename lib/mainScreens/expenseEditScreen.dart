import 'dart:io';

import 'package:account/global/global.dart';
import 'package:account/mainScreens/expensesScreen.dart';
import 'package:account/model/expenses.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class ExpenseEditScreen extends StatefulWidget {
  Expenses? model;
  BuildContext? context;
  ExpenseEditScreen({this.model, this.context});
  _ExpenseEditScreenState createState() => _ExpenseEditScreenState();
}

class _ExpenseEditScreenState extends State<ExpenseEditScreen> {
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
  String? expenseType = "Salaries";
  String custTransImageUrl = "";
  String completeAddress = "";
  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
  DateTime? todayDateTime = DateTime.now();
  DateTime? transDateTime = DateTime.now();
  DateTime? transDueDateTime;
  DateTime? transClosedDateTime;

  @override
  void initState() {
    super.initState();
    setState(() {
      //expenseType = widget.model!.expenseType!.toString();
      //debugPrint("Expense Type:: $expenseType");
      //billType = widget.model!.transType.toString() ?? "Cash";
    });
    getUser();
  }

  getUser() async {
    setState(() {
      imageController.text = widget.model!.thumbnailUrl!.toString();
      expenseInfoController.text = widget.model!.expenseInfo.toString();
      expenseTypeController.text = widget.model!.expenseType!.toString();
      transDateController.text = widget.model!.transDate!.toDate().toString();
      transDateTime = widget.model!.transDate!.toDate();
      onlineOutAmountController.text = widget.model!.onlineOutAmount.toString();
      cashOutAmountController.text = widget.model!.cashOutAmount.toString();
      //print("Trans Type:: " + widget.model!.transType!.toString());
      //print("Trans Name ID:: " + widget.model!.suppTransID!.toString());
      billType1 = widget.model!.expenseType!.toString().contains("ShopRent")
          ? "ShopRent"
          : widget.model!.expenseType!.toString().contains("Salaries")
              ? "Salaries"
              : widget.model!.expenseType!.toString().contains("Electricity")
                  ? "Electricity"
                  : widget.model!.expenseType!.toString().contains("Labour")
                      ? "Labour"
                      : "Other";
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
      expenseInfoController.clear();
      expenseTypeController.clear();
      onlineOutAmountController.clear();
      cashOutAmountController.clear();
      transDateController.clear();

      imageXFile = null;
    });
  }

  Future<void> validateUploadForm() async {
    if (cashOutAmountController.text.isNotEmpty) {
      setState(() {
        uploading = true;
      });
      debugPrint("Transaction Details are passed now");
      debugPrint("Transaction ID::" + widget.model!.expenseID!.toString());
      //start uploading image

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("expenses")
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

      debugPrint('Expense Updated ');
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
              message: "Please write the complete required info for Updation.",
            );
          });
    }
  }

  saveDataToFirestore(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("expenses");
    debugPrint("data Firestore reference is created.");

    ref.doc(widget.model!.expenseID!.toString()).update({
      "expenseType": expenseTypeController.text.toString(),
      "expenseInfo": expenseInfoController.text.toString(),
      "onlineOutAmount": double.parse(onlineOutAmountController.text.trim()),
      "cashOutAmount": double.parse(cashOutAmountController.text.trim()),
      "transDate": DateTime.parse(transDateTime.toString()),
      "thumbnailUrl": downloadUrl,
    }).then((value) {
      debugPrint("First Firestore data is updated");
      final itemsRef = FirebaseFirestore.instance.collection("expenses");

      itemsRef.doc(widget.model!.expenseID!.toString()).update({
        "expenseType": expenseTypeController.text.toString(),
        "expenseInfo": expenseInfoController.text.toString(),
        "onlineOutAmount": double.parse(onlineOutAmountController.text.trim()),
        "cashOutAmount": double.parse(cashOutAmountController.text.trim()),
        "transDate": DateTime.parse(transDateTime.toString()),
        "thumbnailUrl": downloadUrl,
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
          "Expense Edit",
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
                                expenseTypeController.text =
                                    newValue.toString();
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
                    controller: cashOutAmountController,
                    decoration: const InputDecoration(
                      label: Text("Cash Amount *"),
                      hintText: "Cash Amount *",
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
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
