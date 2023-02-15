import 'dart:io';

import 'package:account/mainScreens/suppliersScreen.dart';
import 'package:account/model/suppliers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:account/global/global.dart';
import 'package:account/widgets/error_dialog.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;

class SuppTransUploadScreen extends StatefulWidget {
  final Suppliers? model;

  SuppTransUploadScreen({this.model});

  @override
  _SuppTransUploadScreenState createState() => _SuppTransUploadScreenState();
}

class _SuppTransUploadScreenState extends State<SuppTransUploadScreen> {
  DateTime? todayDateTime = DateTime.now();
  DateTime? transDateTime;
  DateTime? transDueDateTime;
  DateTime? transClosedDateTime;
  String? billType = 'Credit';
  XFile? imageXFile;
  var result,pdffilelocation;
 late final extension,fileName;
  final ImagePicker _picker = ImagePicker();

  TextEditingController transNameController = TextEditingController();
  TextEditingController transTypeController = TextEditingController();
  TextEditingController transInfoController = TextEditingController();
  TextEditingController transDateController = TextEditingController();
  TextEditingController transDueDateController = TextEditingController();
  TextEditingController transClosedDateController = TextEditingController();
  TextEditingController transPaymentDetailsController = TextEditingController();
  TextEditingController transAmountController = TextEditingController();

  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();

  defaultScreen() {
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
          "Add Transactions",
          style: TextStyle(fontSize: 30, fontFamily: "Lobster"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const SuppliersScreen()));
          },
        ),
      ),
      body: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shop_two,
                color: Colors.white,
                size: 200.0,
              ),
              ElevatedButton(
                child: const Text(
                  "Add New Transaction",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.amber),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: () {
                  takeImage(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          title: const Text(
            "Bill Image",
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          children: [
            SimpleDialogOption(
              child: const Text(
                "Capture with Camera",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: const Text(
                "Select from Gallery",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: const Text(
                "Select PDF",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: pickpdfdoc,
            ),
            SimpleDialogOption(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  captureImageWithCamera() async {
    Navigator.pop(context);

    imageXFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 720,
      maxWidth: 1280,
    );

    setState(() {
      imageXFile;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);

    imageXFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 720,
      maxWidth: 1280,
    );

    setState(() {
      imageXFile;
    });
  }
  Future<void>pickpdfdoc()async{
    Navigator.pop(context);
    /*final path=await FlutterDocumentPicker.openDocument();
   print(path);
   File file =File(path.toString());*/
    result=await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ['pdf']);
    /*if(result==null){
      return null;
    }*/

    pdffilelocation =result!.paths.first.toString();
     fileName = result.files.single.name;
     extension = fileName.split('.').last;
    print("result is :$pdffilelocation");
    print('Selected file name: $fileName');
    print('Selected file extension: $extension');
    setState(() {
      pdffilelocation;
      // pdffile=result!.path;
    });


  }

  suppTransUploadFormScreen() {
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
          "Uploading New Transaction",
          style: TextStyle(fontSize: 20, fontFamily: "Lobster"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            clearMenusUploadForm();
          },
        ),
        actions: [
          TextButton(
            child: const Text(
              "Add",
              style: TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "Varela",
                letterSpacing: 3,
              ),
            ),
            onPressed: uploading ? null : () => validateUploadForm(),
          ),
        ],
      ),
      body: ListView(
        children: [
          uploading == true ? linearProgress() : const Text(""),
       imageXFile==null?
       Container(
         height: 230,
         width: MediaQuery.of(context).size.width * 0.8,
         child: PDFView(
           filePath: pdffilelocation,
         ),
       )

        :  Container(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imageXFile!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.cyan,
            ),
            //trailing: const Text("Name*"),
            title: Container(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: transNameController,
                decoration: const InputDecoration(
                  label: Text("Transaction Name *"),
                  hintText: "Transaction Name *",
                  hintStyle: TextStyle(color: Color(0xffcb6262)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.menu,
              color: Colors.cyan,
            ),
            trailing: const Text(" :Type"),
            title: Container(
              width: 250,
              /*decoration: InputDecoration(
                border: InputBorder.none,
              ),*/
              child: DropdownButton<String>(
                value: billType,
                //icon: Icon(Icons.menu),
                style: const TextStyle(color: Colors.black),
                //itemHeight: 2,
                underline: Container(color: Colors.white),
                onChanged: (String? newValue) {
                  setState(
                        () {
                      transTypeController.text = newValue.toString();
                      billType = newValue.toString();
                    },
                  );
                },
                items: const [
                  DropdownMenuItem<String>(
                    value: 'Cash',
                    child: Text('Cash'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Credit',
                    child: Text('Credit'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_today,
              color: Colors.cyan,
            ),
            trailing: const Text(" :Date"),
            title: Container(
              width: 250,
              padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
              margin: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
              child: CupertinoButton(
                padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
                child: transDateTime == null
                    ? const Text(
                  'Transaction Date',
                  style: TextStyle(color: Colors.grey),
                )
                    : Text(
                  '$transDateTime',
                  style: const TextStyle(color: Colors.black),
                ),
                //style: const TextStyle(color: Colors.grey),

                onPressed: () {
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
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.currency_exchange,
              color: Colors.cyan,
            ),
            title: Container(
              width: 250,
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                controller: transAmountController,
                decoration: const InputDecoration(
                  label: Text("Transaction Amount *"),
                  hintText: "Transaction Amount *",
                  hintStyle: TextStyle(color: Color(0xffcb6262)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.perm_device_information,
              color: Colors.cyan,
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: transInfoController,
                decoration: const InputDecoration(
                  label: Text("Transaction Info"),
                  hintText: "Transaction Info",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_month_sharp,
              color: Colors.cyan,
            ),
            trailing: const Text(" :DueDate"),
            title: Container(
              width: 250,
              padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
              margin: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
              child: CupertinoButton(
                padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
                child: transDueDateTime == null
                    ? const Text(
                  'Bill Due Date',
                  style: TextStyle(color: Colors.grey),
                )
                    : Text(
                  '$transDueDateTime',
                  style: const TextStyle(color: Colors.black),
                ),
                //style: const TextStyle(color: Colors.grey),

                onPressed: () {
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
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_view_day_outlined,
              color: Colors.cyan,
            ),
            trailing: const Text(" :ClosedDate"),
            title: Container(
              width: 250,
              padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
              margin: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
              child: CupertinoButton(
                padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 1.0),
                child: transClosedDateTime == null
                    ? const Text(
                  'Bill Closed Date',
                  style: TextStyle(color: Colors.grey),
                )
                    : Text(
                  '$transClosedDateTime',
                  style: const TextStyle(color: Colors.black),
                ),
                //style: const TextStyle(color: Colors.grey),

                onPressed: () {
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
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.camera,
              color: Colors.cyan,
            ),
            title: Container(
              width: 250,
              child: TextField(
                //keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                controller: transPaymentDetailsController,
                decoration: const InputDecoration(
                  label: Text("Partial Payment Details"),
                  hintText: "Partial Payment Details",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
        ],
      ),
    );
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

  validateUploadForm() async {
    if (imageXFile != null || pdffilelocation !=null) {
      if (transNameController.text.isNotEmpty &&
          transTypeController.text.isNotEmpty &&
          transAmountController.text.isNotEmpty
      //transDateController.text.isNotEmpty &&
      //transDueDateController.text.isNotEmpty &&
      //transClosedDateController.text.isNotEmpty
      ) {
        setState(() {
          uploading = true;
        });

        //upload image
        String downloadUrl = await uploadImage(pdffilelocation!=null?File(pdffilelocation):File(imageXFile!.path));

        //save info to firestore
        saveInfo(downloadUrl);
      }
      else {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "Please write name and info for Transaction.",
              );
            });
      }
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please pick an image for Transaction.",
            );
          });
    }
  }

  saveInfo(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("suppliers")
        .doc(widget.model!.supplierID)
        .collection("suppTrans");

    ref.doc(uniqueIdName).set({
      "suppTransID": uniqueIdName,
      "supplierID": widget.model!.supplierID,
      "supplierName": widget.model!.supplierName,
      "supplierContact": widget.model!.supplierInfo,
      "supplierAddress": widget.model!.supplierAddress,
      "shopUID": sharedPreferences!.getString("uid"),
      "shopName": sharedPreferences!.getString("name"),
      "transName": transNameController.text.toString(),
      "transType": transTypeController.text.toString(),
      "transInfo": transInfoController.text.toString(),
      "transPaymentDetails": transPaymentDetailsController.text.toString(),
      "transAmount": int.parse(transAmountController.text),
      "transDate": DateTime.parse(transDateTime.toString()),
      "transDueDate": DateTime.parse(transDueDateTime.toString()),
      "transClosedDate": DateTime.parse(transClosedDateTime.toString()),
      //"transDate": DateTime.parse(transDateController.text),
      //"transDueDate": DateTime.parse(transDueDateController.text),
      //"transClosedDate": DateTime.parse(transClosedDateController.text),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl,
    }).then((value) {
      final itemsRef = FirebaseFirestore.instance.collection("suppTrans");

      itemsRef.doc(uniqueIdName).set({
        "suppTransID": uniqueIdName,
        "supplierID": widget.model!.supplierID,
        "supplierName": widget.model!.supplierName,
        "supplierContact": widget.model!.supplierInfo,
        "supplierAddress": widget.model!.supplierAddress,
        "shopUID": sharedPreferences!.getString("uid"),
        "shopName": sharedPreferences!.getString("name"),
        "transName": transNameController.text.toString(),
        "transType": transTypeController.text.toString(),
        "transInfo": transInfoController.text.toString(),
        "transPaymentDetails": transPaymentDetailsController.text.toString(),
        "transAmount": int.parse(transAmountController.text),
        "transDate": DateTime.parse(transDateTime.toString()),
        "transDueDate": DateTime.parse(transDueDateTime.toString()),
        "transClosedDate": DateTime.parse(transClosedDateTime.toString()),
        //"transDate": DateTime.parse(transDateController.text),
        //"transDueDate": DateTime.parse(transDueDateController.text),
        //"transClosedDate": DateTime.parse(transClosedDateController.text),
        "publishedDate": DateTime.now(),
        "status": "available",
        "thumbnailUrl": downloadUrl,
      });
    }).then((value) {
      clearMenusUploadForm();

      setState(() {
        uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
        uploading = false;
      });
    });
  }

  uploadImage(mImageFile) async {
    print("file is :$mImageFile");
    storageRef.Reference reference =
    storageRef.FirebaseStorage.instance.ref().child("suppTrans");

    storageRef.UploadTask uploadTask =
    reference.child(pdffilelocation!=null ?uniqueIdName+".pdf" :uniqueIdName + ".jpg").putFile(mImageFile);

    storageRef.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return imageXFile == null ? pdffilelocation == null ? defaultScreen(): suppTransUploadFormScreen() : suppTransUploadFormScreen();
  }
}
