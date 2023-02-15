import 'package:account/constants/constants.dart';
import 'package:account/global/global.dart';
import 'package:account/model/suppliers.dart';
import 'package:account/uploadScreens/suppliers_upload_screen.dart';
import 'package:account/widgets/my_drawer.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:account/widgets/supplier_info_design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({Key? key}) : super(key: key);

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  String query = "";
  List<double> cashTransAmount = [];
  List<double> creditTransAmount = [];

  double cashTotal = 0;
  double creditTotal = 0;
  double transTotal = 0;
  int suppliersCount = 0;
  @override
  initState() {
    setState(() {});
  }

  updateDashBoardTotal(List<double> cashTransAmount,
      List<double> creditTransAmount, int suppliersCount) {
    cashTransAmount.forEach((e) => cashTotal += e);
    creditTransAmount.forEach((e) => creditTotal += e);
    transTotal = cashTotal + creditTotal;

    FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .update(
      {
        "suppCashTotal": cashTotal.toDouble(),
        "suppCreditTotal": creditTotal.toDouble(),
        "suppliersCount": suppliersCount.toInt(),
      },
    ).then((value) => debugPrint("its successfull"));
    debugPrint("values of query:: $query");
    debugPrint("values of UID ${sharedPreferences!.getString("uid")}");
    debugPrint("values of cashTotal $cashTotal");
    debugPrint("values of creditTotal $creditTotal");
    debugPrint("values of suppliersCount $suppliersCount");
  }

  @override
  Widget build(BuildContext context) {
    var ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("suppliers")
        .orderBy("publishedDate", descending: true)
        .snapshots();

    return Scaffold(
      drawer: MyDrawer(),
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
            ),
          ),
        ),
        title: const Text(
          //sharedPreferences!.getString("name")!,
          'Suppliers',
          style: TextStyle(fontSize: 30, fontFamily: "Lobster"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.post_add,
              color: Colors.cyan,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => const SuppliersUploadScreen()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            color: Colors.cyan,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: ("Search Supplier"),
              ),
              onChanged: ((value) {
                setState(() {
                  query = value;
                });

                //print("name : ${query}");
              }),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("shops")
                .doc(sharedPreferences!.getString("uid"))
                .collection("suppliers")
                .orderBy("publishedDate", descending: true)
                //.where("thumbnailUrl", isEqualTo: "Credit")
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: circularProgress(),
                      ),
                    )
                  : SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 1,
                      staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          creditTotal = 0;
                          cashTotal = 0;
                        }
                        debugPrint("Credit Index:: $index");

                        debugPrint("Credit Index Amount:: $creditTotal");
                        Suppliers model = Suppliers.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );

                        snapshot.data!.docs[index]['supplierName']
                                .toString()
                                .contains(query.toString())
                            ? creditTotal += model.creditTotal ?? 0.toDouble()
                            : debugPrint("not containes");
                        snapshot.data!.docs[index]['supplierName']
                                .toString()
                                .contains(query.toString())
                            ? cashTotal += model.cashTotal ?? 0.toDouble()
                            : debugPrint("not containes");

                        return index + 1 == snapshot.data!.docs.length
                            ? Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    //begin: Alignment.topRight,
                                    //end: Alignment.bottomLeft,
                                    colors: [
                                      Color(0xb113331a),
                                      Colors.brown,
                                    ],
                                    begin: FractionalOffset(0.0, 0.0),
                                    end: FractionalOffset(1.0, 0.0),
                                    stops: [0.0, 1.0],
                                    tileMode: TileMode.clamp,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    /*ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (c) =>
                                                          const PurchasesScreen()));
                                            },
                                            child: Column(
                                              children: [
                                                const Text("Credit"),
                                                Text(suppCreditTotal
                                                    .toString()),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (c) =>
                                                          const PurchasesScreen()));
                                            },
                                            child: Column(
                                              children: [
                                                const Text("Cash"),
                                                Text(
                                                    suppCashTotal.toString()),
                                              ],
                                            ),
                                          ),*/
                                    Container(
                                      padding:
                                          const EdgeInsets.all(defaultPadding),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          //begin: Alignment.topRight,
                                          //end: Alignment.bottomLeft,
                                          colors: [
                                            Colors.brown,
                                            Color(0xb113331a),
                                          ],
                                          begin: FractionalOffset(0.0, 0.0),
                                          end: FractionalOffset(1.0, 0.0),
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  const Text(
                                                    "Credit",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${''} Transactions",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                            color:
                                                                Colors.white70),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    creditTotal.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ],
                                              ),
                                              const Divider(
                                                  thickness: 22,
                                                  height: 12,
                                                  color: (Color(0xffb49e5c))),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "Cash",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${''} Transactions",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                            color:
                                                                Colors.white70),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    cashTotal.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          const Divider(
                                              thickness: 22,
                                              height: 12,
                                              color: (Color(0xffb49e5c))),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  const Text(
                                                    "Total",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${'Credit + Cash'} Transactions",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                            color:
                                                                Colors.white70),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    "${creditTotal + cashTotal}"
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container();
                      },
                      itemCount: snapshot.data!.docs.length,
                    );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("shops")
                .doc(sharedPreferences!.getString("uid"))
                .collection("suppliers")
                .orderBy("publishedDate", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: circularProgress(),
                        //child: Text("its working upto streaming"),
                      ),
                    )
                  : SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 1,
                      staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                      itemBuilder: (context, index) {

                        //print("printed at ItemBuilder");
                        Suppliers model = Suppliers.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        cashTransAmount
                            .add((model.cashTotal ?? 0.00).toDouble());
                        creditTransAmount
                            .add((model.creditTotal ?? 0.00).toDouble());

                        if (index + 1 == snapshot.data!.docs.length) {
                          updateDashBoardTotal(cashTransAmount,
                              creditTransAmount, snapshot.data!.docs.length);
                        }
                        return model.supplierName!
                                .toString()
                                .contains(query.toString())
                            ? SuppliersInfoDesignWidget(
                                model: model,
                                context: context,
                              )
                            : Container(
                                height: 0,
                              );
                      },
                      itemCount: snapshot.data!.docs.length,
                    );
            },
          ),
        ],
      ),
    );
  }
}
