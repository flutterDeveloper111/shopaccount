import 'package:account/mainScreens/custTransScreen.dart';
import 'package:account/mainScreens/customersEditScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:account/global/global.dart';
//import 'package:foodpanda_sellers_app/mainScreens/itemsScreen.dart';
import 'package:account/model/customers.dart';

class CustInfoDesignWidget extends StatefulWidget {
  Customers? model;
  BuildContext? context;

  CustInfoDesignWidget({this.model, this.context});

  @override
  _CustInfoDesignWidgetState createState() => _CustInfoDesignWidgetState();
}

class _CustInfoDesignWidgetState extends State<CustInfoDesignWidget> {
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
            builder: (c) => CustTransScreen(model: widget.model),
          ),
        );
      },
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          elevation: 5,
          child: ExpansionTile(
            leading: Image.network(
              widget.model!.thumbnailUrl!.toString(),
              //width: 80.0,
            ),
            title: Text(widget.model!.customerName!.toString()),
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
                            builder: (c) => CustomerEditScreen(
                                  model: widget.model!,
                                  context: context,
                                )));
                  }),
                ), //Text("₹" + widget.model!.supplierName!.toString()),
                title: Text("Stock" + widget.model!.status!.toString()),
                trailing: Text("♢" + widget.model!.customerContact!.toString()),
              ),
              ListTile(
                  title: Text(
                      "address :" + widget.model!.customerAddress!.toString())
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
