//import 'dart:io';

import 'dart:io';

import 'package:account/mainScreens/home_screen.dart';
import 'package:account/mainScreens/suppTransEditScreen.dart';
import 'package:account/model/supTrans.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:account/global/global.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SuppTransDetailsScreen extends StatefulWidget {
  final SupTrans? model;
  BuildContext? context;
  var extension;

  SuppTransDetailsScreen({this.model, this.context, this.extension});

  @override
  _SuppTransDetailsScreenState createState() => _SuppTransDetailsScreenState();
}

class _SuppTransDetailsScreenState extends State<SuppTransDetailsScreen> {
  TextEditingController counterTextEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getpermission();

  }
  getpermission()async{
    PermissionStatus permissionStatus = await Permission.storage.request();
    setState(() {
      _permissiongranter =permissionStatus;
    });
  }

  var dio = Dio();
  var imagurl;
  static const fileName = '/demo.pdf';
  String? localPath;
  double _progress = 0;
  String progressString = 'File has not been downloaded yet.';
  bool didDownloadPDF = false;
  late PermissionStatus _permissiongranter;

  deleteItem(String suppTransID) {
    FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("suppliers")
        .doc(widget.model!.supplierID!)
        .collection("suppTrans")
        .doc(widget.model!.supplierID!)
        .delete()
        .then((value) {
      FirebaseFirestore.instance
          .collection("suppTrans")
          .doc(widget.model!.supplierID!)
          .delete();

      Navigator.push(
          context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      Fluttertoast.showToast(msg: "Transaction Deleted Successfully.");
    });
  }

  downloadPDF() async {


    if( _permissiongranter ==PermissionStatus.granted)
      {
        FileDownloader.downloadFile(
          url: widget.model!.thumbnailUrl!,
          onProgress: (fileName, progress) {
            setState(() {
              _progress = progress;
            });
          },
          onDownloadCompleted: (path) {
            print("path$path");
            setState(() {
              _progress=0;
            });
          },
        );
     }



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
        title: Text(sharedPreferences!.getString("name").toString()),
        actions: [
          TextButton(
            child: const Text(
              "Edit",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "Varela",
                letterSpacing: 1,
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => SuppTransEditScreen(
                            model: widget.model!,
                            context: context,
                          )));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.extension == "pdf"
                ? Container(
                    height: 250.0,
                    width: double.infinity,
                    child:
                        //PDF().fromUrl(widget.model!.thumbnailUrl!)
                        PDFView(
                      filePath: widget.model!.thumbnailUrl,
                    ),
                  )
                : Container(
                    height: 250.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        image: DecorationImage(
                            image: NetworkImage(
                                widget.model!.thumbnailUrl.toString()),
                            fit: BoxFit.cover)),
                    /* child: Image.network(widget.model!.thumbnailUrl.toString(),
                  height: 180.0, fit: BoxFit.cover),*/
                  ),
            SizedBox(
              height: 10,
            ),
            Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          child:_progress !=0?CircularProgressIndicator(): Icon(Icons.download),
                          onTap: () {
                            //     print(widget.model!.thumbnailUrl);
                            // var  imageUrl =widget.model!.thumbnailUrl;
                            // var tempDir = await getTemporaryDirectory();
                            downloadPDF();
                          },
                        ),
                      ],
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.model!.transName.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 26),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.model!.transInfo.toString(),
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.model!.transAmount.toString() + " €",
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 25),
                      ),
                    ],
                  ),
                ),
                elevation: 5,
                color: Colors.grey.shade200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Card(
                elevation: 5,
                color: Colors.grey.shade200,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.cyan,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Date: " + widget.model!.transDate!.toDate().toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Card(
                elevation: 5,
                color: Colors.grey.shade200,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.cyan,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Due: " +
                            widget.model!.transDueDate!.toDate().toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Card(
                elevation: 5,
                color: Colors.grey.shade200,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.cyan,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Close: " +
                            widget.model!.transClosedDate!.toDate().toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          //delete item
          deleteItem(widget.model!.suppTransID!);
        },
        child: Container(
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
          width: MediaQuery.of(context).size.width - 13,
          height: 60,
          child: const Center(
            child: Text(
              "Delete this Transaction",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }
}
