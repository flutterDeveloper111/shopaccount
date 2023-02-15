import 'package:account/mainScreens/purchasesScreen.dart';
import 'package:account/mainScreens/salesScreen.dart';
import 'package:account/views/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PurchaseTextWidgetHeader extends SliverPersistentHeaderDelegate {
  String? title;
  String? cashTransType1 = '';
  String? creditTransType2 = '';
  String? cashTransamount1 = '';
  String? creditTransamount2 = '';
  PurchaseTextWidgetHeader(
      {this.title,
      this.cashTransType1,
      this.creditTransType2,
      this.cashTransamount1,
      this.creditTransamount2});

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
        child: Row(
          children: [
            SizedBox(
              height: 1.0,
              //width: 10.0,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => PurchasesScreen()));
                    },
                    child: Column(
                      children: [
                        DashBoard(
                          name: title.toString(),
                          type: cashTransType1.toString(),
                          amount: cashTransamount1.toString(),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => PurchasesScreen()));
                    },
                    child: DashBoard(
                      name: title.toString(),
                      type: creditTransType2.toString(),
                      amount: creditTransamount2.toString(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60.0,
              width: 80.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 50;

  @override
  // TODO: implement minExtent
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
