import 'package:account/mainScreens/itemsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:account/global/global.dart';
//import 'package:foodpanda_sellers_app/mainScreens/itemsScreen.dart';
import 'package:account/model/menus.dart';

class InfoDesignWidget extends StatefulWidget {
  Menus? model;
  BuildContext? context;

  InfoDesignWidget({this.model, this.context});

  @override
  _InfoDesignWidgetState createState() => _InfoDesignWidgetState();
}

class _InfoDesignWidgetState extends State<InfoDesignWidget> {
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
                builder: (c) => ItemsScreen(model: widget.model)));
      },
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              const SizedBox(
                height: 30.0,
              ),
              Divider(
                height: 4,
                thickness: 3,
                color: Colors.grey[300],
              ),
              /*Image.network(
                widget.model!.thumbnailUrl!,
                height: 220.0,
                fit: BoxFit.cover,
              ),*/
              const SizedBox(
                height: 1.0,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExpansionTile(
                    title: Text(
                      widget.model!.menuTitle!,
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 20,
                        fontFamily: "Train",
                      ),
                    ),
                    children: [
                      ListTile(
                        title: Text(
                          '  20000'.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.model!.menuTitle!,
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 20,
                      fontFamily: "Train",
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
                  Text(
                    '  20000'.toString(),
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  //BubbleStories(text: widget.model!.menuTitle!)
                ],
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
    );
  }
}
