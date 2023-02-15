// ignore_for_file: prefer_const_constructors

import 'package:account/global/global.dart';
import 'package:account/mainScreens/salesOrder_editScreen.dart';
import 'package:account/model/salesOrder.dart';
import 'package:account/uploadScreens/salesOrder_upload_screen.dart';
import 'package:account/widgets/my_drawer.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SalesOrderPendingList extends StatefulWidget {
  const SalesOrderPendingList({Key? key}) : super(key: key);
  _SalesOrderPendingListState createState() => _SalesOrderPendingListState();
}

class _SalesOrderPendingListState extends State<SalesOrderPendingList> {
  bool isExpand = false;
  String name = "";
  CollectionReference ref = FirebaseFirestore.instance
      .collection("shops")
      .doc(sharedPreferences!.getString("uid"))
      .collection("salesOrders");
  @override
  void initState() {
    super.initState();
    setState(() {});
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
        title: Text("Sales Orders Pending List"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.post_add,
              color: Colors.cyan,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => SalesOrderUploadScreen()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            color: Colors.amber,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: ("Search SalesOrders"),
              ),
              onChanged: ((value) {
                setState(() {
                  name = value;
                });

                debugPrint("name : $name");
              }),
            ),
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: ref.snapshots(),
        builder: (context, snapshots) {
          return (snapshots.connectionState == ConnectionState.waiting)
              ? circularProgress()
              : ListView.builder(
                  itemCount: snapshots.data!.docs.length,
                  itemBuilder: (context, index) {
                    SalesOrder model = SalesOrder.fromJson(
                        snapshots.data!.docs[index].data()!
                            as Map<String, dynamic>);
                    return model.salesOrderName.toString().contains(name)
                        ? SingleChildScrollView(
                            child: Card(
                              elevation: 5,
                              child: ExpansionTile(
                                leading: Image.network(
                                  model.thumbnailUrl.toString(),
                                  //width: 80.0,
                                ),
                                title: Text(model.salesOrderName.toString()),
                                children: [
                                  ListTile(
                                    leading: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: (() {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (c) =>
                                                    SalesOrderPendingEditScreen(
                                                      model: model,
                                                      context: context,
                                                    )));
                                      }),
                                    ),
                                    title:
                                        Text(model.salesOrderInfo.toString()),
                                    trailing:
                                        Text(model.totalAmount.toString()),
                                  ),
                                  ListTile(
                                    leading: Text(
                                        "₹" + model.totalAmount.toString()),
                                    title: Text(
                                        "Stock" + model.itemsCount.toString()),
                                    trailing: Text(
                                        "♢" + model.customerName.toString()),
                                  ),
                                  /*ListTile(
                              title: Text("Query String ${name}" +
                                  model.inStockCount.toString()),
                              trailing: model.priceListName
                                      .toString()
                                      .startsWith(name)
                                  ? Text(
                                      "query matched ${model.priceListName.toString().startsWith(name)}")
                                  : Text("query not matched."),
                          ),*/
                                ],
                                onExpansionChanged: (isExpanded) {
                                  //print("Expanded: ${isExpanded}");
                                },
                              ),
                            ),
                          )
                        : Center(child: Text(""));
                  },
                );
        },
        /*ListView.builder(
                  itemCount: snapshots.data!.docs.length,
                  itemBuilder: (context, index) {
                    PriceList model = PriceList.fromJson(
                        snapshots.data!.docs[index].data()
                            as Map<String, dynamic>);
                    if (name.isEmpty) {
                      return SingleChildScrollView(
                        child: ExpansionTile(
                          leading: Image.network(
                            model.thumbnailUrl.toString(),
                            //width: 80.0,
                          ),
                          title: Text(model.priceListName.toString()),
                          children: [
                            ListTile(
                              leading: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: (() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) => PriceListEditScreen(
                                                model: model,
                                                context: context,
                                              )));
                                }),
                              ),
                              title: Text(model.priceListInfo.toString()),
                              trailing: Text(model.salePrice.toString()),
                            ),
                            ListTile(
                              leading: Text("₹" + model.salePrice.toString()),
                              title:
                                  Text("Stock" + model.inStockCount.toString()),
                              trailing:
                                  Text("♢" + model.supplierName.toString()),
                            ),
                          ],
                          onExpansionChanged: (isExpanded) {
                            print("Expanded: ${isExpanded}");
                          },
                        ),
                      );
                    }
                    if (model.priceListName.toString().startsWith(name)) {
                      return SingleChildScrollView(
                        child: ExpansionTile(
                          leading: Image.network(
                            snapshots.data!.docs.first[""],
                            //width: 80.0,
                          ),
                          title: Text(model.priceListName.toString()),
                          children: [
                            ListTile(
                              leading: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: (() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) => PriceListEditScreen(
                                                model: model,
                                                context: context,
                                              )));
                                }),
                              ),
                              title: Text(model.priceListInfo.toString()),
                              trailing: Text(model.salePrice.toString()),
                            ),
                            ListTile(
                              leading: Text("₹" + model.salePrice.toString()),
                              title:
                                  Text("Stock" + model.inStockCount.toString()),
                              trailing:
                                  Text("♢" + model.supplierName.toString()),
                            ),
                          ],
                          onExpansionChanged: (isExpanded) {
                            print("Expanded: ${isExpanded}");
                          },
                        ),
                      );
                    }
                    return Container();
                  },
                );
        },
      ),
      ListView(
        children: [
          StreamBuilder(
            stream: ref.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return SingleChildScrollView(
                child: ExpansionTile(
                  leading: Image.network(
                    snapshot.data!.docs.first["thumbnailUrl"],
                    //width: 80.0,
                  ),
                  title: Text(snapshot.data!.docs.first["priceListName"]),
                  children: [
                    ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: (() {
                          PriceList model = PriceList.fromJson(
                            //snapshot.data!.docs[1].data()!
                            snapshot.data!.docs.first.data()!
                                as Map<String, dynamic>,
                          );
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => PriceListEditScreen(
                                        model: model,
                                        context: context,
                                      )));
                        }),
                      ),
                      title: Text(snapshot.data!.docs.first["priceListInfo"]),
                      trailing: Text(
                          snapshot.data!.docs.first["salePrice"].toString()),
                    ),
                    ListTile(
                      leading: Text("₹" +
                          snapshot.data!.docs.first["salePrice"].toString()),
                      title: Text("Stock" +
                          snapshot.data!.docs.first["inStockCount"].toString()),
                      trailing: Text("♢" +
                          snapshot.data!.docs.first["supplierName"].toString()),
                    ),
                  ],
                  onExpansionChanged: (isExpanded) {
                    print("Expanded: ${isExpanded}");
                  },
                ),
              );
            },
          ),
        ],
      );*/
      ),
    );
  }
}
