//
import 'package:account/mainScreens/suppTran_details_screen.dart';
import 'package:account/model/supTrans.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:account/global/global.dart';

//import 'purchase_transScreen.dart';

class PurInfoDesignWidget extends StatefulWidget {
  SupTrans? model;
  BuildContext? context;

  PurInfoDesignWidget({this.model, this.context});

  @override
  _PurInfoDesignWidgetState createState() => _PurInfoDesignWidgetState();
}

class _PurInfoDesignWidgetState extends State<PurInfoDesignWidget> {
  deleteMenu(String menuID) {
    FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("menus")
        .doc(menuID)
        .delete();

    //Fluttertoast.showToast(msg: "Menu Deleted Successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => SuppTransDetailsScreen(
                      model: widget.model,
                      context: context,
                    )));
      },
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          elevation: 5,
          color: Colors.grey.shade200,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            height: 80,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  Divider(
                    height: 4,
                    thickness: 3,
                    color: Colors.grey[300],
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                            image: NetworkImage(
                              widget.model!.thumbnailUrl!,
                            ),
                            fit: BoxFit.cover)),
                    /* child: Image.network(
                      widget.model!.thumbnailUrl!,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),*/
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),

                  Container(
                    width: 220.0,
                    child: Text(
                      widget.model!.transName!,
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 18,
                        fontFamily: "Train",
                      ),
                    ),
                  ),
                  /*IconButton(
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Colors.pinkAccent,
                    ),
                    onPressed: () {
                      //delete menu
                      deleteMenu(widget.model!.menuID!);
                    },
                  ),*/
                  Container(
                    child: Text(
                      widget.model!.transAmount!.toString(),
                      //widget.model!.transDate!  DateTime.now(),

                      style: const TextStyle(
                          color: Colors.red,
                          fontFamily: "Train",
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                  ),

                  // Text(
                  //   widget.model!.menuInfo!,
                  //   style: const TextStyle(
                  //     color: Colors.grey,
                  //     fontSize: 12,
                  //   ),
                  // ),
                  Divider(
                    height: 4,
                    thickness: 3,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
