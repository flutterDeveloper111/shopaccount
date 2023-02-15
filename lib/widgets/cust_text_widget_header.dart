import 'package:account/global/global.dart';
import 'package:account/mainScreens/salesScreen.dart';
import 'package:account/views/dashboard.dart';
import 'package:flutter/material.dart';

class CustTextWidgetHeader extends SliverPersistentHeaderDelegate {
  String? title;
  String? transType1 = '';
  String? transType2 = '';
  String? transamount1 = '';
  String? transamount2 = '';
  String? query = '';
  CustTextWidgetHeader({
    this.title,
    this.transType1,
    this.transType2,
    this.transamount1,
    this.transamount2,
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
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
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
                    child: DashBoard(
                      name: title.toString(),
                      type: transType1.toString(),
                      amount: dashBoardSuppCashTotal.toString(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const SalesScreen()));
                    },
                    child: DashBoard(
                      name: title.toString(),
                      type: transType2.toString(),
                      amount: transamount2.toString(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 60.0,
              width: 80.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
