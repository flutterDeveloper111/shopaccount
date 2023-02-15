import 'package:account/constants/constants.dart';
import 'package:account/widgets/my_drawer.dart';
import 'package:account/widgets/progress_bar.dart';
//import 'package:account/widgets/purchase_Info_design.dart';>
import 'package:account/widgets/sales_info_design.dart';
//import 'package:account/widgets/pur_text_widget_header.dart';
//import 'package:account/widgets/sales_text_widget_header.dart';
//import 'package:account/widgets/transactions_info_design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../model/custTrans.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  double custCashTotal = 0;
  double custCreditTotal = 0;
  double custTransTotal = 0;
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
          title: const Text('Sales Screen'),
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
              Container(
                child: CustomScrollView(
                  slivers: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          //.collection("shops")
                          //.doc(sharedPreferences!.getString("uid"))
                          .collection("custTrans")
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
                                    custCreditTotal = 0;
                                    custCashTotal = 0;
                                  }
                                  debugPrint("Credit Index:: $index");

                                  debugPrint(
                                      "Credit Index Amount:: $custCreditTotal");

                                  snapshot.data!.docs[index]['transType']
                                          .toString()
                                          .contains("Credit")
                                      ? custCreditTotal += snapshot
                                          .data!.docs[index]['transAmount']
                                          .toDouble()
                                      : custCashTotal += snapshot
                                          .data!.docs[index]['transAmount']
                                          .toDouble();

                                  return index + 1 == snapshot.data!.docs.length
                                      ? Container(
                                          alignment: Alignment.center,
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
                                                              custCreditTotal
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
                                                              custCashTotal
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
                                                              "${custCreditTotal + custCashTotal}"
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
                              .collection("custTrans")
                              .where("transDate",
                                  isGreaterThanOrEqualTo: dateRange.start)
                              .where("transDate",
                                  isLessThanOrEqualTo: dateRange.end
                                      .add(const Duration(days: 1)))

                              //.where("transType", isEqualTo: "Credit")
                              .snapshots()
                          : FirebaseFirestore.instance
                              //.collection("shops")
                              //.doc(sharedPreferences!.getString("uid"))
                              .collection("custTrans")
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
                                  CustTrans model = CustTrans.fromJson(
                                    snapshot.data!.docs[index].data()!
                                        as Map<String, dynamic>,
                                  );

                                  return model.transType!.contains("Credit")
                                      ? SaleInfoDesignWidget(
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
              ),
              Container(
                child: CustomScrollView(
                  slivers: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          //.collection("shops")
                          //.doc(sharedPreferences!.getString("uid"))
                          .collection("custTrans")
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
                                    custCreditTotal = 0;
                                    custCashTotal = 0;
                                  }
                                  debugPrint("Credit Index:: $index");

                                  debugPrint(
                                      "Credit Index Amount:: $custCreditTotal");

                                  snapshot.data!.docs[index]['transType']
                                          .toString()
                                          .contains("Credit")
                                      ? custCreditTotal += snapshot
                                          .data!.docs[index]['transAmount']
                                          .toDouble()
                                      : custCashTotal += snapshot
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
                                                      Color(0xb1030303),
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
                                                              custCreditTotal
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
                                                              custCashTotal
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
                                                              "${custCreditTotal + custCashTotal}"
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
                              .collection("custTrans")
                              .where("transDate",
                                  isGreaterThanOrEqualTo: dateRange.start)
                              .where("transDate",
                                  isLessThanOrEqualTo: dateRange.end
                                      .add(const Duration(days: 1)))
                              //.where("transType", isEqualTo: "Cash")
                              .snapshots()
                          : FirebaseFirestore.instance
                              //.collection("shops")
                              //.doc(sharedPreferences!.getString("uid"))
                              .collection("custTrans")
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
                                  scrollDirection:
                                  Axis.vertical;
                                  CustTrans model = CustTrans.fromJson(
                                    snapshot.data!.docs[index].data()!
                                        as Map<String, dynamic>,
                                  );

                                  return model.transType!.contains("Cash")
                                      ? SaleInfoDesignWidget(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
