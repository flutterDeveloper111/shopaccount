import 'package:account/assistantMethods/chart.dart';
import 'package:account/constants/constants.dart';
//import 'package:account/main.dart';
import 'package:account/mainScreens/purchasesScreen.dart';
import 'package:account/mainScreens/salesScreen.dart';
import 'package:account/model/custTrans.dart';
import 'package:account/model/supTrans.dart';
import 'package:account/notifications/supp_creditDue_notification.dart';

//import 'package:account/notifications/notificationservice.dart';

//import 'package:account/providers/supp_details_provider.dart';
//import 'package:account/views/bubble_stories.dart';
import 'package:account/views/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
//import 'package:flutter/widgets.dart';
//import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//import 'package:account/authentication/auth_screen.dart';
import 'package:account/global/global.dart';
//import 'package:account/model/menus.dart';
//import 'package:account/uploadScreens/menus_upload_screen.dart';
//import 'package:account/widgets/info_design.dart';
import 'package:account/widgets/my_drawer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
//import 'package:account/widgets/progress_bar.dart';
//import 'package:account/widgets/text_widget_header.dart';
//import 'package:flutter_svg/flutter_svg.dart';
//import 'package:intl/intl.dart';
//import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //NotificationServices notificationServices = NotificationServices();
  String timeText = "";
  String dateText = "";

  double suppCashTotal = 0;
  double suppCreditTotal = 0;
  double custCashTotal = 0;
  double custCreditTotal = 0;
  double transCashTotal = 0;
  double transCreditTotal = 0;
  double transSuppTotal = 0;
  double transCustTotal = 0;
  int suppliersCount = 0;
  int customersCount = 0;
  int suppCreditTransCount = 0;
  int custCashTransCount = 0;
  int suppCashTransCount = 0;
  int custCreditTransCount = 0;

  //var CustTrans;

  /*String formatCurrentLiveTime(DateTime time) {
    return DateFormat("hh:mm:ss a").format(time);
  }

  String formatCurrentDate(DateTime date) {
    return DateFormat("dd MMMM, yyyy").format(date);
  }*/

  /*getCurrentLiveTime() {
    final DateTime timeNow = DateTime.now();
    final String liveTime = formatCurrentLiveTime(timeNow);
    final String liveDate = formatCurrentDate(timeNow);

    if (this.mounted) {
      setState(() {
        timeText = liveTime;
        dateText = liveDate;
      });
    }
  }*/

  @override
  void initState() {
    super.initState();
    Provider.of<NotificationService>(context, listen: false).initialize();
    Provider.of<NotificationService>(context, listen: false)
        .sheduledNotification();

    //time
    //timeText = formatCurrentLiveTime(DateTime.now());

    //date
    //dateText = formatCurrentDate(DateTime.now());

    //Timer.periodic(const Duration(seconds: 1), (timer) {
    //getCurrentLiveTime();
    //});
    getDashBoardsData();

    setState(() {});
  }

  void getDashBoardsData() async {
    final DocumentSnapshot shopRef = await FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .get();

    setState(() {
      suppCashTotal = shopRef.get("suppCashTotal") ?? 0;
      suppCreditTotal = shopRef.get("suppCreditTotal") ?? 0;
      custCashTotal = shopRef.get("custCashTotal") ?? 0;
      custCreditTotal = shopRef.get("custCreditTotal") ?? 0;
      transCashTotal = suppCashTotal + custCashTotal;
      transCreditTotal = suppCreditTotal + custCreditTotal;
      transSuppTotal = suppCashTotal + suppCreditTotal;
      transCustTotal = custCashTotal + custCreditTotal;
      customersCount = shopRef.get("customersCount") ?? 0;
      suppliersCount = shopRef.get("suppliersCount") ?? 0;
    });
  }

  void updateSupplierTransCount(
      int creditSuppTransCount, int cashSuppTransAmout) {
    setState(() {
      suppCreditTransCount = suppCreditTransCount;
      suppCreditTransCount = cashSuppTransAmout;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                //notificationServices.sendNotification("title", "this is body");

                //debugPrint("click");
              },
              child: Container(
                height: 0,
              )),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff6248d7),
                Color(0xff1c10c8),
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text('Dashboard'),
        //bottom:
      ),
      drawer: MyDrawer(),
      body: CustomScrollView(
        slivers: [
          /*SliverPersistentHeader(
              pinned: true, delegate: TextWidgetHeader(title: "My Menus"),
              ),*/

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("suppTrans")
                .orderBy("transDate", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                //scrollDirection: Axis.horizontal,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) =>
                                                  const PurchasesScreen()));
                                    },
                                    child: DashBoard(
                                      name: 'purchase',
                                      type: 'Cash',
                                      amount: suppCashTotal.toString(),
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
                                    child: DashBoard(
                                      name: 'purchase',
                                      type: 'Credit',
                                      amount: suppCreditTotal.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 1,
                      staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                      itemBuilder: (context, index) {
                        SupTrans model = SupTrans.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );

                        if (index == 0) {
                          suppCashTotal = 0;
                          suppCreditTotal = 0;
                        }
                        snapshot.data!.docs[index]['transType']
                                .toString()
                                .contains("Credit")
                            ? {
                                suppCreditTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble() ??
                                    0,
                                model.transDueDate!.toDate().isBefore(
                                        DateTime.now()
                                            .subtract(const Duration(days: 1)))
                                    ? {
                                        Provider.of<NotificationService>(
                                                context,
                                                listen: false)
                                            .stylishNotification(
                                          index: index,
                                          body: model.supplierName!.toString() +
                                              "with" +
                                              model.transAmount!.toString(),
                                        ),
                                      }
                                    : 0,
                              }
                            : {
                                suppCashTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble() ??
                                    0,
                              };

                        return index + 1 == snapshot.data!.docs.length
                            ? SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        //scrollDirection: Axis.horizontal,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (c) =>
                                                          const PurchasesScreen()));
                                            },
                                            child: DashBoard(
                                              name: 'purchase',
                                              type: 'Cash',
                                              amount: suppCashTotal.toString(),
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
                                            child: DashBoard(
                                              name: 'purchase',
                                              type: 'Credit',
                                              amount:
                                                  suppCreditTotal.toString(),
                                            ),
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
            stream: FirebaseFirestore.instance
                .collection("custTrans")
                .orderBy("transDate", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) =>
                                                  const SalesScreen()));
                                    },
                                    child: Container(
                                      child: DashBoard(
                                        name: 'Sales',
                                        type: 'Cash',
                                        amount: custCashTotal.toString(),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) =>
                                                  const SalesScreen()));
                                    },
                                    child: Container(
                                      child: DashBoard(
                                        name: 'Sales',
                                        type: 'Credit',
                                        amount: custCreditTotal.toString(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: Container(
                                      child: DashBoard(
                                        name: 'Total',
                                        type: 'CashFlow',
                                        amount: transCashTotal.toString(),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: Container(
                                      child: DashBoard(
                                        name: 'Total',
                                        type: 'CreditFlow',
                                        amount: transCreditTotal.toString(),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 1,
                      staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                      itemBuilder: (context, index) {
                        CustTrans model = CustTrans.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        if (index == 0) {
                          custCashTotal = 0;
                          custCreditTotal = 0;
                          transCustTotal = 0;
                          custCashTransCount = 0;
                          custCreditTransCount = 0;
                        }
                        snapshot.data!.docs[index]['transType']
                                .toString()
                                .contains("Credit")
                            ? {
                                custCreditTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble() ??
                                    0,
                              }
                            : {
                                custCashTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble() ??
                                    0,
                              };
                        index + 1 == snapshot.data!.docs.length
                            ? {
                                transCashTotal = custCashTotal - suppCashTotal,
                                transCreditTotal =
                                    custCreditTotal - suppCreditTotal,
                              }
                            : {transCashTotal = 0, transCreditTotal = 0};

                        return index + 1 == snapshot.data!.docs.length
                            ? SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (c) =>
                                                          const SalesScreen()));
                                            },
                                            child: Container(
                                              child: DashBoard(
                                                name: 'Sales',
                                                type: 'Cash',
                                                amount:
                                                    custCashTotal.toString(),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (c) =>
                                                          const SalesScreen()));
                                            },
                                            child: Container(
                                              child: DashBoard(
                                                name: 'Sales',
                                                type: 'Credit',
                                                amount:
                                                    custCreditTotal.toString(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {},
                                            child: Container(
                                              child: DashBoard(
                                                name: 'Total',
                                                type: 'CashFlow',
                                                amount:
                                                    transCashTotal.toString(),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {},
                                            child: Container(
                                              child: DashBoard(
                                                name: 'Total',
                                                type: 'CreditFlow',
                                                amount:
                                                    transCreditTotal.toString(),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
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
            stream: FirebaseFirestore.instance
                .collection("custTrans")
                .orderBy("transDate", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      width: 0.5, color: Colors.grey),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade400,
                                      offset: const Offset(
                                        5.0,
                                        5.0,
                                      ),
                                      blurRadius: 10.0,
                                      spreadRadius: 2.0,
                                    ), //BoxShadow
                                    const BoxShadow(
                                      color: Colors.white,
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 0.0,
                                      spreadRadius: 0.0,
                                    ), //BoxShadow
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xff4d38c8),
                                                Color(0xff1c10c8),
                                              ],
                                              begin: FractionalOffset(0.0, 0.0),
                                              end: FractionalOffset(1.0, 0.0),
                                              stops: [0.0, 1.0],
                                              tileMode: TileMode.clamp,
                                            ),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: Center(
                                              child: Text(
                                                'Customers Trans Chart',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Container(
                                          height: 300,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 200,
                                                child: Stack(
                                                  children: [
                                                    PieChart(
                                                      PieChartData(
                                                        sectionsSpace: 0,
                                                        centerSpaceRadius: 70,
                                                        startDegreeOffset: -90,
                                                        sections:
                                                            paiChartSelectionDatas =
                                                                [
                                                          PieChartSectionData(
                                                            color: primaryColor,
                                                            value:
                                                                custCashTotal,
                                                            showTitle: true,
                                                            radius: 25,
                                                          ),
                                                          PieChartSectionData(
                                                            color: const Color(
                                                                0xf6e76124),
                                                            value:
                                                                custCreditTotal,
                                                            showTitle: true,
                                                            radius: 30,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Positioned.fill(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                              height:
                                                                  defaultPadding),
                                                          Text(
                                                            "${transCustTotal / 1000}k",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline4!
                                                                .copyWith(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  height: 0.5,
                                                                ),
                                                          ),
                                                          const Text("Amount"),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              //Chart(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.cyan,
                                                    border: Border.all(
                                                        width: 2,
                                                        color: Colors
                                                            .lightGreen //primaryColor.withOpacity(0.15),
                                                        ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Number Credit Trans",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .caption!
                                                                    .copyWith(
                                                                        color: const Color(
                                                                            0xffe52727)),
                                                              ),
                                                              Text(
                                                                "Number Cash Trans",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .caption!
                                                                    .copyWith(
                                                                        color: const Color(
                                                                            0xc1edf6fb)),
                                                              ),
                                                              const Text(
                                                                "Number of Customers",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ]),
                                                      ),
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          "$custCreditTransCount",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .caption!
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xffe52727)),
                                                        ),
                                                        Text(
                                                          "$custCashTransCount",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .caption!
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xc1edf6fb)),
                                                        ),
                                                        Text("$customersCount"),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 1,
                      staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                      itemBuilder: (context, index) {
                        CustTrans model = CustTrans.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        if (index == 0) {
                          custCashTotal = 0;
                          custCreditTotal = 0;
                          transCustTotal = 0;
                          custCashTransCount = 0;
                          custCreditTransCount = 0;
                        }
                        snapshot.data!.docs[index]['transType']
                                .toString()
                                .contains("Credit")
                            ? {
                                custCreditTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble() ??
                                    0,
                                custCreditTransCount++,
                              }
                            : {
                                custCashTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble() ??
                                    0,
                                custCashTransCount++,
                              };
                        index + 1 == snapshot.data!.docs.length
                            ? transCustTotal = custCashTotal + custCreditTotal
                            : transCustTotal = 0;

                        return index + 1 == snapshot.data!.docs.length
                            ? SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              width: 0.5, color: Colors.grey),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade400,
                                              offset: const Offset(
                                                5.0,
                                                5.0,
                                              ),
                                              blurRadius: 10.0,
                                              spreadRadius: 2.0,
                                            ), //BoxShadow
                                            const BoxShadow(
                                              color: Colors.white,
                                              offset: Offset(0.0, 0.0),
                                              blurRadius: 0.0,
                                              spreadRadius: 0.0,
                                            ), //BoxShadow
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xff564ac5),
                                                        Color(0xff1c10c8),
                                                      ],
                                                      begin: FractionalOffset(
                                                          0.0, 0.0),
                                                      end: FractionalOffset(
                                                          1.0, 0.0),
                                                      stops: [0.0, 1.0],
                                                      tileMode: TileMode.clamp,
                                                    ),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 12),
                                                    child: Center(
                                                      child: Text(
                                                        'Customers Trans Chart',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 22,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: Container(
                                                  height: 300,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 200,
                                                        child: Stack(
                                                          children: [
                                                            PieChart(
                                                              PieChartData(
                                                                sectionsSpace:
                                                                    0,
                                                                centerSpaceRadius:
                                                                    70,
                                                                startDegreeOffset:
                                                                    -90,
                                                                sections:
                                                                    paiChartSelectionDatas =
                                                                        [
                                                                  PieChartSectionData(
                                                                    color:
                                                                        primaryColor,
                                                                    value:
                                                                        custCashTotal,
                                                                    showTitle:
                                                                        true,
                                                                    radius: 25,
                                                                  ),
                                                                  PieChartSectionData(
                                                                    color: const Color(
                                                                        0xf6e76124),
                                                                    value:
                                                                        custCreditTotal,
                                                                    showTitle:
                                                                        true,
                                                                    radius: 30,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Positioned.fill(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const SizedBox(
                                                                      height:
                                                                          defaultPadding),
                                                                  Text(
                                                                    "${transCustTotal / 1000}k",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4!
                                                                        .copyWith(
                                                                          color:
                                                                              Colors.green,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          height:
                                                                              0.5,
                                                                        ),
                                                                  ),
                                                                  const Text(
                                                                      "Amount"),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      //Chart(),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                                color:
                                                                    Colors.cyan,
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: Colors
                                                                        .lightGreen //primaryColor.withOpacity(0.15),
                                                                    ),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            8))),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "Number Credit Trans",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .caption!
                                                                            .copyWith(color: const Color(0xffe52727)),
                                                                      ),
                                                                      Text(
                                                                        "Number Cash Trans",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .caption!
                                                                            .copyWith(color: const Color(0xc1edf6fb)),
                                                                      ),
                                                                      const Text(
                                                                        "Number of Customers",
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                            Column(
                                                              children: [
                                                                Text(
                                                                  "$custCreditTransCount",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .caption!
                                                                      .copyWith(
                                                                          color:
                                                                              const Color(0xffe52727)),
                                                                ),
                                                                Text(
                                                                  "$custCashTransCount",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .caption!
                                                                      .copyWith(
                                                                          color:
                                                                              const Color(0xc1edf6fb)),
                                                                ),
                                                                Text(
                                                                    "$customersCount"),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
            stream: FirebaseFirestore.instance
                .collection("suppTrans")
                .orderBy("transDate", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      width: 0.5, color: Colors.grey),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade400,
                                      offset: const Offset(
                                        5.0,
                                        5.0,
                                      ),
                                      blurRadius: 10.0,
                                      spreadRadius: 2.0,
                                    ), //BoxShadow
                                    const BoxShadow(
                                      color: Colors.white,
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 0.0,
                                      spreadRadius: 0.0,
                                    ), //BoxShadow
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xff424bc3),
                                                Color(0xff1c10c8),
                                              ],
                                              begin: FractionalOffset(0.0, 0.0),
                                              end: FractionalOffset(1.0, 0.0),
                                              stops: [0.0, 1.0],
                                              tileMode: TileMode.clamp,
                                            ),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: Center(
                                              child: Text(
                                                'Suppliers Trans Chart',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Container(
                                          height: 300,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 200,
                                                child: Stack(
                                                  children: [
                                                    PieChart(
                                                      PieChartData(
                                                        sectionsSpace: 0,
                                                        centerSpaceRadius: 70,
                                                        startDegreeOffset: -90,
                                                        sections:
                                                            paiChartSelectionDatas =
                                                                [
                                                          PieChartSectionData(
                                                            color: primaryColor,
                                                            value:
                                                                suppCashTotal,
                                                            showTitle: true,
                                                            radius: 25,
                                                          ),
                                                          PieChartSectionData(
                                                            color: const Color(
                                                                0xf6e76124),
                                                            value:
                                                                suppCreditTotal,
                                                            showTitle: true,
                                                            radius: 30,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Positioned.fill(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                              height:
                                                                  defaultPadding),
                                                          Text(
                                                            "${transSuppTotal / 1000}K",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline4!
                                                                .copyWith(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  height: 0.5,
                                                                ),
                                                          ),
                                                          const Text("Amount"),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              //Chart(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.cyan,
                                                    border: Border.all(
                                                        width: 2,
                                                        color: Colors
                                                            .lightGreen //primaryColor.withOpacity(0.15),
                                                        ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Number Credit Trans",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .caption!
                                                                    .copyWith(
                                                                        color: const Color(
                                                                            0xffd72121)),
                                                              ),
                                                              Text(
                                                                "Number Cash Trans",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .caption!
                                                                    .copyWith(
                                                                        color: const Color(
                                                                            0xc1edf6fb)),
                                                              ),
                                                              const Text(
                                                                "Number of Suppliers",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ]),
                                                      ),
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          "$suppCreditTransCount",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .caption!
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xffe51515)),
                                                        ),
                                                        Text(
                                                          "$suppCashTransCount",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .caption!
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xc1edf6fb)),
                                                        ),
                                                        Text("$suppliersCount"),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 1,
                      staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                      itemBuilder: (context, index) {
                        SupTrans model = SupTrans.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        if (index == 0) {
                          suppCashTotal = 0;
                          suppCreditTotal = 0;
                          transSuppTotal = 0;
                          suppCashTransCount = 0;
                          suppCreditTransCount = 0;
                        }
                        snapshot.data!.docs[index]['transType']
                                .toString()
                                .contains("Credit")
                            ? {
                                suppCreditTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble() ??
                                    0,
                                suppCreditTransCount++,
                              }
                            : {
                                suppCashTotal += snapshot
                                        .data!.docs[index]['transAmount']
                                        .toDouble() ??
                                    0,
                                suppCashTransCount++,
                              };
                        index + 1 == snapshot.data!.docs.length
                            ? transSuppTotal = suppCashTotal + suppCreditTotal
                            : transSuppTotal = 0;

                        return index + 1 == snapshot.data!.docs.length
                            ? SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              width: 0.5, color: Colors.grey),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade400,
                                              offset: const Offset(
                                                5.0,
                                                5.0,
                                              ),
                                              blurRadius: 10.0,
                                              spreadRadius: 2.0,
                                            ), //BoxShadow
                                            const BoxShadow(
                                              color: Colors.white,
                                              offset: Offset(0.0, 0.0),
                                              blurRadius: 0.0,
                                              spreadRadius: 0.0,
                                            ), //BoxShadow
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xff4a41b4),
                                                        Color(0xff1c10c8),
                                                      ],
                                                      begin: FractionalOffset(
                                                          0.0, 0.0),
                                                      end: FractionalOffset(
                                                          1.0, 0.0),
                                                      stops: [0.0, 1.0],
                                                      tileMode: TileMode.clamp,
                                                    ),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 12),
                                                    child: Center(
                                                      child: Text(
                                                        'Suppliers Trans Chart',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 22,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: Container(
                                                  height: 300,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 200,
                                                        child: Stack(
                                                          children: [
                                                            PieChart(
                                                              PieChartData(
                                                                sectionsSpace:
                                                                    0,
                                                                centerSpaceRadius:
                                                                    70,
                                                                startDegreeOffset:
                                                                    -90,
                                                                sections:
                                                                    paiChartSelectionDatas =
                                                                        [
                                                                  PieChartSectionData(
                                                                    color:
                                                                        primaryColor,
                                                                    value:
                                                                        suppCashTotal,
                                                                    showTitle:
                                                                        true,
                                                                    radius: 25,
                                                                  ),
                                                                  PieChartSectionData(
                                                                    color: const Color(
                                                                        0xf6e76124),
                                                                    value:
                                                                        suppCreditTotal,
                                                                    showTitle:
                                                                        true,
                                                                    radius: 30,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Positioned.fill(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const SizedBox(
                                                                      height:
                                                                          defaultPadding),
                                                                  Text(
                                                                    "${transSuppTotal / 1000}K",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4!
                                                                        .copyWith(
                                                                          color:
                                                                              Colors.green,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          height:
                                                                              0.5,
                                                                        ),
                                                                  ),
                                                                  const Text(
                                                                      "Amount"),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      //Chart(),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                                color:
                                                                    Colors.cyan,
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: Colors
                                                                        .lightGreen //primaryColor.withOpacity(0.15),
                                                                    ),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            8))),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "Number Credit Trans",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .caption!
                                                                            .copyWith(color: const Color(0xffd72121)),
                                                                      ),
                                                                      Text(
                                                                        "Number Cash Trans",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .caption!
                                                                            .copyWith(color: const Color(0xc1edf6fb)),
                                                                      ),
                                                                      const Text(
                                                                        "Number of Suppliers",
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                            Column(
                                                              children: [
                                                                Text(
                                                                  "$suppCreditTransCount",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .caption!
                                                                      .copyWith(
                                                                          color:
                                                                              const Color(0xffe51515)),
                                                                ),
                                                                Text(
                                                                  "$suppCashTransCount",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .caption!
                                                                      .copyWith(
                                                                          color:
                                                                              const Color(0xc1edf6fb)),
                                                                ),
                                                                Text(
                                                                    "$suppliersCount"),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
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
        ],
      ),

      /*body:
       SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                //scrollDirection: Axis.horizontal,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const PurchasesScreen()));
                    },
                    child: DashBoard(
                      name: 'purchase',
                      type: 'Cash',
                      amount: suppCashTotal.toString(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const PurchasesScreen()));
                    },
                    child: DashBoard(
                      name: 'purchase',
                      type: 'Credit',
                      amount: suppCreditTotal.toString(),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const SalesScreen()));
                    },
                    child: Container(
                      child: DashBoard(
                        name: 'Sales',
                        type: 'Cash',
                        amount: custCashTotal.toString(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const SalesScreen()));
                    },
                    child: Container(
                      child: DashBoard(
                        name: 'Sales',
                        type: 'Credit',
                        amount: custCreditTotal.toString(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Container(
                      child: DashBoard(
                        name: 'Total',
                        type: 'Cash',
                        amount: transCashTotal.toString(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Container(
                      child: DashBoard(
                        name: 'Total',
                        type: 'Credit',
                        amount: transCreditTotal.toString(),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 0.5, color: Colors.grey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      offset: const Offset(
                        5.0,
                        5.0,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ), //BoxShadow
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
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
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'Customers Trans Chart',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          height: 300,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: Stack(
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sectionsSpace: 0,
                                        centerSpaceRadius: 70,
                                        startDegreeOffset: -90,
                                        sections: paiChartSelectionDatas = [
                                          PieChartSectionData(
                                            color: primaryColor,
                                            value: custCashTotal,
                                            showTitle: true,
                                            radius: 25,
                                          ),
                                          PieChartSectionData(
                                            color: const Color(0xf6e76124),
                                            value: custCreditTotal,
                                            showTitle: true,
                                            radius: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                              height: defaultPadding),
                                          Text(
                                            "$transCustTotal",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4!
                                                .copyWith(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                  height: 0.5,
                                                ),
                                          ),
                                          const Text("of ${'Amount'}"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //Chart(),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    color: Colors.cyan,
                                    border: Border.all(
                                        width: 2,
                                        color: Colors
                                            .lightGreen //primaryColor.withOpacity(0.15),
                                        ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Number Credit Trans",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                        color: const Color(
                                                            0xffe0b2b2)),
                                              ),
                                              Text(
                                                "Number Cash Trans",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                        color: const Color(
                                                            0xc1edf6fb)),
                                              ),
                                              const Text(
                                                "Number of Customers",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ]),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "$custCreditTransCount",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  color:
                                                      const Color(0xffe0b2b2)),
                                        ),
                                        Text(
                                          "$custCashTransCount",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  color:
                                                      const Color(0xc1edf6fb)),
                                        ),
                                        Text("$customersCount"),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 0.5, color: Colors.grey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      offset: const Offset(
                        5.0,
                        5.0,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ), //BoxShadow
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
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
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'Suppliers Trans Chart',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: Stack(
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sectionsSpace: 0,
                                        centerSpaceRadius: 70,
                                        startDegreeOffset: -90,
                                        sections: paiChartSelectionDatas = [
                                          PieChartSectionData(
                                            color: primaryColor,
                                            value: suppCashTotal,
                                            showTitle: true,
                                            radius: 25,
                                          ),
                                          PieChartSectionData(
                                            color: const Color(0xf6e76124),
                                            value: suppCreditTotal,
                                            showTitle: true,
                                            radius: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                              height: defaultPadding),
                                          Text(
                                            "$transSuppTotal",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4!
                                                .copyWith(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                  height: 0.5,
                                                ),
                                          ),
                                          const Text("of Amount"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //Chart(),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    color: Colors.cyan,
                                    border: Border.all(
                                        width: 2,
                                        color: Colors
                                            .lightGreen //primaryColor.withOpacity(0.15),
                                        ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Number Credit Trans",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                        color: const Color(
                                                            0xffe0b2b2)),
                                              ),
                                              Text(
                                                "Number Cash Trans",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                              const Text(
                                                "Number of Suppliers",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ]),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "$suppCreditTransCount",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  color:
                                                      const Color(0xffe0b2b2)),
                                        ),
                                        Text(
                                          "$suppCashTransCount",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  color:
                                                      const Color(0xc1f0f5f8)),
                                        ),
                                        Text("$suppliersCount"),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),*/
    );
  }
}
