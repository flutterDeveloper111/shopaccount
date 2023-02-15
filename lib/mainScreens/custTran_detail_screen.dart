import 'package:account/mainScreens/custTransEditScreen.dart';
import 'package:account/mainScreens/home_screen.dart';
import 'package:account/model/custTrans.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:account/global/global.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustTransDetailsScreen extends StatefulWidget {
  final CustTrans? model;
  CustTransDetailsScreen({this.model});

  @override
  _CustTransDetailsScreenState createState() => _CustTransDetailsScreenState();
}

class _CustTransDetailsScreenState extends State<CustTransDetailsScreen> {
  TextEditingController counterTextEditingController = TextEditingController();

  deleteItem(String custTransID) {
    FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("customers")
        .doc(widget.model!.custID!)
        .collection("custTrans")
        .doc(custTransID)
        .delete()
        .then((value) {
      FirebaseFirestore.instance.collection("items").doc(custTransID).delete();

      Navigator.push(
          context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      Fluttertoast.showToast(msg: "Transaction Deleted Successfully.");
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
        title: Text(sharedPreferences!.getString("name").toString()),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              semanticLabel: ("Edit"),
              color: Color(0xff09a20e),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) =>
                          CustTransEditScreen(model: widget.model!)));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250.0,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
                  image: DecorationImage(
                      image:
                          NetworkImage(widget.model!.thumbnailUrl!.toString()),
                      fit: BoxFit.cover)),
              /* child: Image.network(widget.model!.thumbnailUrl.toString(),
                  height: 180.0, fit: BoxFit.cover),*/
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
                        widget.model!.transName!.toString(),
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
                            widget.model!.transInfo!.toString(),
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
                        widget.model!.transAmount!.toString() + " €",
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
          deleteItem(widget.model!.custTransID!);
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
