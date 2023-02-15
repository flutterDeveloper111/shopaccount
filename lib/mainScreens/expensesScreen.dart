// ignore_for_file: prefer_const_constructors

import 'package:account/constants/constants.dart';
import 'package:account/global/global.dart';
import 'package:account/mainScreens/expenseEditScreen.dart';
import 'package:account/model/expenses.dart';
import 'package:account/uploadScreens/expense_upload_screen.dart';
import 'package:account/widgets/my_drawer.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool isExpand = false;
  String name = "";
  num shopRentTotal = 0;
  num salariesTotal = 0;
  num labourTotal = 0;
  num electricityTotal = 0;
  num otherTotal = 0;
  double expenseTotal = 0.00;
  CollectionReference ref = FirebaseFirestore.instance
      .collection("shops")
      .doc(sharedPreferences!.getString("uid"))
      .collection("expenses");
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
        title: Text("Expenses Screen"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.post_add,
              color: Colors.cyan,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => ExpenseUploadScreen()));
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
                hintText: ("ShopRent, Salaries, Electricity.."),
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
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: ref
                .orderBy("transDate", descending: true)
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
                          shopRentTotal = 0;
                          salariesTotal = 0;
                          labourTotal = 0;
                          electricityTotal = 0;
                          otherTotal = 0;
                        }
                        //debugPrint("Credit Index:: $index");

                        //debugPrint("Credit Index Amount:: $creditTotal");
                        Expenses model = Expenses.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        snapshot.data!.docs[index]['expenseType']
                                .toString()
                                .contains(name.toString())
                            ? {
                                model.expenseType
                                        .toString()
                                        .contains("ShopRent")
                                    ? shopRentTotal +=
                                        (model.cashOutAmount!.toDouble() +
                                            model.onlineOutAmount!.toDouble())
                                    : model.expenseType
                                            .toString()
                                            .contains("Salaries")
                                        ? salariesTotal += (model.cashOutAmount!
                                                .toDouble() +
                                            model.onlineOutAmount!.toDouble())
                                        : model.expenseType
                                                .toString()
                                                .contains("Labour")
                                            ? labourTotal += (model
                                                    .cashOutAmount!
                                                    .toDouble() +
                                                model.onlineOutAmount!
                                                    .toDouble())
                                            : model.expenseType
                                                    .toString()
                                                    .contains("Electricity")
                                                ? electricityTotal += (model
                                                        .cashOutAmount!
                                                        .toDouble() +
                                                    model.onlineOutAmount!
                                                        .toDouble())
                                                : otherTotal += (model
                                                        .cashOutAmount!
                                                        .toDouble() +
                                                    model.onlineOutAmount!
                                                        .toDouble()),
                                expenseTotal +=
                                    (model.cashOutAmount!.toDouble() +
                                        model.onlineOutAmount!.toDouble()),
                              }
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
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
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
                                        padding: EdgeInsets.all(defaultPadding),
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
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      const Text(
                                                        "ShopRent",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${shopRentTotal.toDouble()}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white70),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Column(
                                                    children: [
                                                      const Text(
                                                        "Salaries",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${salariesTotal.toDouble()}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white70),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Column(
                                                    children: [
                                                      const Text(
                                                        "Electricity",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${electricityTotal.toDouble()}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white70),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Column(
                                                    children: [
                                                      const Text(
                                                        "Labour",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${labourTotal.toDouble()}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white70),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Column(
                                                    children: [
                                                      const Text(
                                                        "Other Expense",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${otherTotal.toDouble()}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white70),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Divider(
                                                thickness: 22,
                                                height: 12,
                                                color: (Color(0xffb49e5c)),
                                              ),
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        const Text(
                                                          "Total",
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${'All Shop'} Expenses",
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
                                                          "${expenseTotal.toDouble()}"
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
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
          /*SliverPersistentHeader(
            pinned: true,
            delegate: SalesTextWidgetHeader(
              title: "Purchases",
              cashTransType: "Cash",
              creditTransType: "Credit",
              cashTransamount: cashTotal.toString(),
              creditTransamount: creditTotal.toString(),
            ),
          ),*/
          StreamBuilder<QuerySnapshot>(
            stream: ref.orderBy("transDate", descending: true).snapshots(),
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
                        debugPrint("printed at ItemBuilder");
                        Expenses model = Expenses.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        /*if (index == 0) {
                          cashTransAmount = [
                            0,
                          ];
                          creditTransAmount = [
                            0,
                          ];
                        }
                        if (model.customerName!
                            .toString()
                            .contains(query.toString())) {
                          cashTransAmount
                              .add((model.cashTotal ?? 0.00).toDouble());
                          creditTransAmount
                              .add((model.creditTotal ?? 0.00).toDouble());
                        }

                        if (index + 1 == snapshot.data!.docs.length) {
                          updateDashBoardTotal(cashTransAmount,
                              creditTransAmount, snapshot.data!.docs.length);
                        }*/
                        return model.expenseType!
                                .toString()
                                .contains(name.toString())
                            ? SingleChildScrollView(
                                child: Card(
                                  elevation: 5,
                                  child: ExpansionTile(
                                    leading: Image.network(
                                      model.thumbnailUrl.toString(),
                                      //width: 80.0,
                                    ),
                                    title: Text(
                                        "${model.cashOutAmount!.toDouble() + model.onlineOutAmount!.toDouble()}"),
                                    children: [
                                      ListTile(
                                        leading: IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: (() {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        ExpenseEditScreen(
                                                          model: model,
                                                          context: context,
                                                        )));
                                          }),
                                        ),
                                        title:
                                            Text(model.expenseInfo!.toString()),
                                      ),
                                      ListTile(
                                        leading: Text("Online: ₹" +
                                            model.cashOutAmount.toString()),
                                        title: Text("Cash: ₹" +
                                            model.onlineOutAmount.toString()),
                                      ),
                                      ListTile(
                                        leading:
                                            Text(model.expenseType!.toString()),
                                        title: Text(model.transDate!
                                            .toDate()
                                            .toString()),
                                      ),
                                    ],
                                    onExpansionChanged: (isExpanded) {
                                      //print("Expanded: ${isExpanded}");
                                    },
                                  ),
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
        ],
      ),
    );
  }
}
