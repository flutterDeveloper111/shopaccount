import 'package:account/global/global.dart';
import 'package:account/model/suppliers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuppTextWidgetHeader extends SliverPersistentHeaderDelegate {
  String? title;
  String? cashTransType = '';
  String? creditTransType = '';
  String? cashTransamount = '';
  String? creditTransamount = '';
  String? query = '';
  double? cashTotal = 0;
  double? creditTotal = 0;
  SuppTextWidgetHeader({
    this.title,
    this.cashTransType,
    this.creditTransType,
    this.cashTransamount,
    this.creditTransamount,
    this.query,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
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
        height: 420.0,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(
              height: 1.0,
              //width: 10.0,
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("shops")
                    .doc(sharedPreferences!.getString("uid"))
                    .collection("suppliers")
                    //.where("transType", isEqualTo: "Credit")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  debugPrint("builder had -->> cashTotal:: $cashTotal");
                  if (snapshot.hasData) {
                    debugPrint("has data -->> cashTotal:: $cashTotal");

                    //int lenthCount = snapshot.data!.docs.length;
                    for (var i = 0;
                        i < snapshot.data!.docs.length.toInt();
                        i++) {
                      Suppliers model = Suppliers.fromJson(
                        snapshot.data!.docs[i].data()! as Map<String, dynamic>,
                      );
                      model.supplierName!.toString().contains(query!.toString())
                          ? creditTotal =
                              creditTotal! + model.creditTotal!.toDouble()

                          /*cashTotal = cashTotal!.toDouble() ??
                            0 + model.cashTotal!.toDouble() ??
                            0;*/
                          : debugPrint("$creditTotal");
                      debugPrint("Index $i");

                      return i + 1 == snapshot.data!.docs.length
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(""),
                                  Text("$creditTotal")
                                ],
                              ),
                            )
                          : Container();
                    }
                  }
                  return const Text("number of snapshots documents:: 2");
                  /*while(snapshot.data!.docs.length)
                    return snapshot.data!.docs[index]['transType']
                                          .toString()
                                          .contains("Credit")
                                      ? custCreditTotal += snapshot
                                          .data!.docs[index]['transAmount']
                                          .toDouble()
                                      : custCashTotal += snapshot
                                          .data!.docs[index]['transAmount']
                                          .toDouble();
                    Text("$")*/
                  /*ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          scrollDirection:
                          Axis.vertical;

                          debugPrint("cashTotal:: ${cashTotal}");
                          if (index == 0) {
                            creditTotal = 0;
                            cashTotal = 0;

                            debugPrint("cashTotal:: ${cashTotal}");
                          }
                          Suppliers model = Suppliers.fromJson(
                            snapshot.data!.docs[index].data()!
                                as Map<String, dynamic>,
                          );
                          if (model.supplierName!
                              .toString()
                              .contains(query.toString())) {
                            creditTotal = creditTotal ??
                                0 + model.creditTotal!.toDouble() ??
                                0;
                            cashTotal = cashTotal ??
                                0 + model.cashTotal!.toDouble() ??
                                0;
                            debugPrint("cashTotal:: ${cashTotal}");
                          }
                          //DocumentSnapshot doc = snapshot.data!.docs[index];
                          return index + 1 == snapshot.data!.docs.length
                              ? Container(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          child: Column(
                                            children: [
                                              const Text("Credit"),
                                              Text(creditTotal.toString()),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {},
                                          child: Column(
                                            children: [
                                              const Text("Cash"),
                                              Text(cashTotal.toString()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container();
                        });*/
                }),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 180;

  @override
  double get minExtent => 150;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
