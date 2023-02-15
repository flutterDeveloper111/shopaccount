//
import 'dart:async';
import 'dart:io';

import 'package:account/mainScreens/suppTransScreen.dart';
import 'package:account/mainScreens/suppliersEditScreen.dart';
import 'package:account/model/suppliers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:account/global/global.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:foodpanda_sellers_app/mainScreens/itemsScreen.dart';

class SuppliersInfoDesignWidget extends StatefulWidget {
  Suppliers? model;
  BuildContext? context;

  SuppliersInfoDesignWidget({this.model, this.context});

  @override
  _SuppliersInfoDesignWidgetState createState() =>
      _SuppliersInfoDesignWidgetState();
}

class _SuppliersInfoDesignWidgetState extends State<SuppliersInfoDesignWidget> {
  String pathPDF = "";
  String landscapePathPdf = "";
  String remotePDFpath = "";
  String corruptedPathPDF = "";

  initState() {
    createFileOfPdfUrl().then((f) {
      setState(() {
        remotePDFpath = f.path;
      });
    });
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = widget.model!.thumbnailUrl;
      final filename = url?.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url!));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  deleteMenu(String custID) {
    FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("customers")
        .doc(custID)
        .delete()
        .then(
      (value) {
        FirebaseFirestore.instance.collection("customers").doc(custID).delete();
      },
    );

    //Fluttertoast.showToast(msg: "Menu Deleted Successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => SuppTransScreen(model: widget.model),
          ),
        );
      },
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          elevation: 5,
          child: ExpansionTile(
            leading:

            Image.network(
              widget.model!.thumbnailUrl!.toString(),
              //width: 80.0,
            ),
            title: Text(widget.model!.supplierName!.toString()),
            children: [
              ListTile(
                leading: Text("Credit₹" + widget.model!.creditTotal.toString()),
                /*IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => SupplierEditScreen(
                                  model: widget.model!,
                                  context: context,
                                )));
                  }),
                ),*/
                title: Text("Cash₹" + widget.model!.cashTotal.toString()),
                trailing: Text("Total₹" + widget.model!.transTotal.toString()),
              ),
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => SupplierEditScreen(
                                  model: widget.model!,
                                  context: context,
                                )));
                  }),
                ), //Text("₹" + widget.model!.supplierName!.toString()),
                title: Text("Stock" + widget.model!.status.toString()),
                trailing: Text("♢" + widget.model!.supplierContact.toString()),
              ),
              ListTile(
                  title: Text(
                      "address :" + widget.model!.supplierAddress!.toString())
                  //: Text("query not matched."),
                  ),
            ],
            onExpansionChanged: (isExpanded) {
              //print("Expanded: ${isExpanded}");
            },
          ),
        ),
      ),
    );
  }
}
