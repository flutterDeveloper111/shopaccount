// ignore_for_file: avoid_unnecessary_containers

import 'package:account/constants/constants.dart';
//import 'package:account/global/global.dart';
//import 'package:account/model/custTrans.dart';
//import 'package:account/mainScreens/purchase_Info_design.dart';
//import 'package:account/model/menus.dart';
import 'package:account/model/supTrans.dart';
//import 'package:account/views/bubble_stories.dart';
//import 'package:account/views/dashboard.dart';
//import 'package:account/widgets/custTrans_design.dart';
//import 'package:account/widgets/cust_info_design.dart';
import 'package:account/widgets/my_drawer.dart';
import 'package:account/widgets/progress_bar.dart';
//import 'package:account/widgets/pur_text_widget_header.dart';
import 'package:account/widgets/purchase_Info_design.dart';
//import 'package:account/widgets/pur_text_widget_header.dart';
//import 'package:account/widgets/sales_text_widget_header.dart';
//import 'package:account/widgets/transactions_info_design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

//import '../model/custTrans.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({Key? key}) : super(key: key);

  @override
  _PurchasesScreenState createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  double suppCashTotal = 0;
  double suppCreditTotal = 0;
  double suppTransTotal = 0;
  DateTime? dateQuery;

  @override
  void initState() {
    super.initState();
    setState(() {
      //name = DateTime.now();
    });
  }

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  Future pickRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (newDateRange == null) return;
    setState(() => dateRange = newDateRange);
  }

  String? name;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          actions: [
            IconButton(
                onPressed: pickRange, icon: const Icon(Icons.calendar_month))
          ],
          title: const Text('Purchases'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.money,
                  color: Colors.white,
                ),
                text: "Credit",
              ),
              Tab(
                icon: Icon(
                  Icons.money_off_csred_outlined,
                  color: Colors.white,
                ),
                text: "Cash",
              ),
            ],
            indicatorColor: Colors.white38,
            indicatorWeight: 6,
          ),
        ),
        drawer: MyDrawer(),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.amber,
                Colors.cyan,
              ],
            ),
          ),
          child: TabBarView(
            children: [
              CustomScrollView(
                slivers: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        //.collection("shops")
                        //.doc(sharedPreferences!.getString("uid"))
                        .collection("suppTrans")
                        .where("transDate",
                            isGreaterThanOrEqualTo: dateRange.start)
                        .where("transDate",
                            isLessThanOrEqualTo:
                                dateRange.end.add(const Duration(days: 1)))
                        //.where("transType", isEqualTo: "Credit")
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
                              staggeredTileBuilder: (c) =>
                                  const StaggeredTile.fit(1),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  suppCreditTotal = 0;
                                  suppCashTotal = 0;
                                }
                                debugPrint("Credit Index:: $index");

                                debugPrint(
                                    "Credit Index Amount:: $suppCreditTotal");

                                snapshot.data!.docs[index]['transType']
                                        .toString()
                                        .contains("Credit")
                                    ? suppCreditTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble()
                                    : suppCashTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble();

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
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                            Center(
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                    defaultPadding),
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    //begin: Alignment.topRight,
                                                    //end: Alignment.bottomLeft,
                                                    colors: [
                                                      Colors.brown,
                                                      Color(0xb113331a),
                                                    ],
                                                    begin: FractionalOffset(
                                                        0.0, 0.0),
                                                    end: FractionalOffset(
                                                        1.0, 0.0),
                                                    stops: [0.0, 1.0],
                                                    tileMode: TileMode.clamp,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            const Text(
                                                              "Credit",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${''} Transactions",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .caption!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white70),
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
                                                              suppCreditTotal
                                                                  .toString(),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .caption!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ],
                                                        ),
                                                        const Divider(
                                                            thickness: 22,
                                                            height: 12,
                                                            color: (Color(
                                                                0xffb49e5c))),
                                                        Column(
                                                          children: [
                                                            const Text(
                                                              "Cash",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${''} Transactions",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .caption!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white70),
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
                                                              suppCashTotal
                                                                  .toString(),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .caption!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    const Divider(
                                                        thickness: 22,
                                                        height: 12,
                                                        color: (Color(
                                                            0xffb49e5c))),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            const Text(
                                                              "Total",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${'Credit + Cash'} Transactions",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .caption!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white70),
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
                                                              "${suppCreditTotal + suppCashTotal}"
                                                                  .toString(),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .caption!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        height: 0,
                                      );
                              },
                              itemCount: snapshot.data!.docs.length,
                            );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: name == null
                        ? FirebaseFirestore.instance
                            //.collection("shops")
                            //.doc(sharedPreferences!.getString("uid"))
                            .collection("suppTrans")
                            .where("transDate",
                                isGreaterThanOrEqualTo: dateRange.start)
                            .where("transDate",
                                isLessThanOrEqualTo:
                                    dateRange.end.add(const Duration(days: 1)))

                            //.where("transType", isEqualTo: "Credit")
                            .snapshots()
                        : FirebaseFirestore.instance
                            //.collection("shops")
                            //.doc(sharedPreferences!.getString("uid"))
                            .collection("suppTrans")
                            .where("transType", isEqualTo: "Credit")
                            //.orderBy("transDueDate", descending: false)
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
                              staggeredTileBuilder: (c) =>
                                  const StaggeredTile.fit(1),
                              itemBuilder: (context, index) {
                                SupTrans model = SupTrans.fromJson(
                                  snapshot.data!.docs[index].data()!
                                      as Map<String, dynamic>,
                                );

                                return model.transType!.contains("Credit")
                                    ? PurInfoDesignWidget(
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
              CustomScrollView(
                slivers: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        //.collection("shops")
                        //.doc(sharedPreferences!.getString("uid"))
                        .collection("suppTrans")
                        .where("transDate",
                            isGreaterThanOrEqualTo: dateRange.start)
                        .where("transDate",
                            isLessThanOrEqualTo:
                                dateRange.end.add(const Duration(days: 1)))
                        //.where("transType", isEqualTo: "Credit")
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
                              staggeredTileBuilder: (c) =>
                                  const StaggeredTile.fit(1),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  suppCreditTotal = 0;
                                  suppCashTotal = 0;
                                }
                                debugPrint("Credit Index:: $index");

                                debugPrint(
                                    "Credit Index Amount:: $suppCreditTotal");

                                snapshot.data!.docs[index]['transType']
                                        .toString()
                                        .contains("Credit")
                                    ? suppCreditTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble()
                                    : suppCashTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble();

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
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
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
                                              alignment: Alignment.topCenter,
                                              padding: const EdgeInsets.all(
                                                  defaultPadding),
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  //begin: Alignment.topRight,
                                                  //end: Alignment.bottomLeft,
                                                  colors: [
                                                    Colors.brown,
                                                    Color(0xb113331a),
                                                  ],
                                                  begin: FractionalOffset(
                                                      0.0, 0.0),
                                                  end: FractionalOffset(
                                                      1.0, 0.0),
                                                  stops: [0.0, 1.0],
                                                  tileMode: TileMode.clamp,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          const Text(
                                                            "Credit",
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${''} Transactions",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white70),
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
                                                            suppCreditTotal
                                                                .toString(),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ],
                                                      ),
                                                      const Divider(
                                                          thickness: 22,
                                                          height: 12,
                                                          color: (Color(
                                                              0xffb49e5c))),
                                                      Column(
                                                        children: [
                                                          const Text(
                                                            "Cash",
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${''} Transactions",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white70),
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
                                                            suppCashTotal
                                                                .toString(),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  const Divider(
                                                      thickness: 22,
                                                      height: 12,
                                                      color:
                                                          (Color(0xffb49e5c))),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          const Text(
                                                            "Total",
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${'Credit + Cash'} Transactions",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white70),
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
                                                            "${suppCreditTotal + suppCashTotal}"
                                                                .toString(),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white),
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
                                    : Container(
                                        height: 0,
                                      );
                              },
                              itemCount: snapshot.data!.docs.length,
                            );
                    },
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: name == null
                        ? FirebaseFirestore.instance
                            //.collection("shops")
                            //.doc(sharedPreferences!.getString("uid"))
                            .collection("suppTrans")
                            .where("transDate",
                                isGreaterThanOrEqualTo: dateRange.start)
                            .where("transDate",
                                isLessThanOrEqualTo:
                                    dateRange.end.add(const Duration(days: 1)))
                            //.where("transType", isEqualTo: "Cash")
                            .snapshots()
                        : FirebaseFirestore.instance
                            //.collection("shops")
                            //.doc(sharedPreferences!.getString("uid"))
                            .collection("suppTrans")
                            .where("transType", isEqualTo: "Cash")
                            //.orderBy("transDueDate", descending: false)
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
                              staggeredTileBuilder: (c) =>
                                  const StaggeredTile.fit(1),
                              itemBuilder: (context, index) {
                                SupTrans model = SupTrans.fromJson(
                                  snapshot.data!.docs[index].data()!
                                      as Map<String, dynamic>,
                                );

                                return model.transType!.contains("Cash")
                                    ? PurInfoDesignWidget(
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
            ],
          ),
        ),
      ),
    );
  }
}
