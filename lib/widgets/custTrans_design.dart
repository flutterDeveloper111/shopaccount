//import 'package:account/global/global.dart';
import 'package:account/mainScreens/custTran_detail_screen.dart';
import 'package:account/model/custTrans.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:account/mainScreens/item_detail_screen.dart';
//import 'package:account/mainScreens/itemsScreen.dart';
//import 'package:account/model/items.dart';
//import 'package:account/model/menus.dart';

class CustTransDesignWidget extends StatefulWidget {
  CustTrans? model;
  BuildContext? context;

  CustTransDesignWidget({this.model, this.context});

  @override
  _CustTransDesignWidgetState createState() => _CustTransDesignWidgetState();
}

class _CustTransDesignWidgetState extends State<CustTransDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => CustTransDetailsScreen(model: widget.model)));
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
                  /**/
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
