import 'package:account/model/custTrans.dart';
import 'package:account/model/customers.dart';
import 'package:account/uploadScreens/custTrans_upload_screen.dart';
import 'package:account/widgets/custTrans_design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:account/global/global.dart';
import 'package:account/widgets/my_drawer.dart';
import 'package:account/widgets/progress_bar.dart';

class CustTransScreen extends StatefulWidget {
  final Customers? model;
  CustTransScreen({this.model});

  @override
  _CustTransScreenState createState() => _CustTransScreenState();
}

class _CustTransScreenState extends State<CustTransScreen> {
  List<double> cashTransAmount = [];
  List<double> creditTransAmount = [];
  double cashTotal = 0;
  double creditTotal = 0;
  double transTotal = 0;
  String query = "";

  updateFireStore(var custID) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("customers");
    cashTransAmount.forEach((e) => cashTotal += e);
    creditTransAmount.forEach((e) => creditTotal += e);
    transTotal = cashTotal + creditTotal;

    ref.doc(custID).update(
      {
        "transTotal": transTotal.toDouble(),
        "cashTotal": cashTotal.toDouble(),
        "creditTotal": creditTotal.toDouble(),
      },
    ).then((value) {
      final suppRef = FirebaseFirestore.instance.collection("customers");
      suppRef.doc(custID).update({
        "transTotal": transTotal.toDouble(),
        "cashTotal": cashTotal.toDouble(),
        "creditTotal": creditTotal.toDouble(),
      });
    });
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
        title: Text(
          widget.model!.customerName!.toString(),
          style: const TextStyle(fontSize: 14, fontFamily: "Lobster"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.library_add,
              color: Colors.cyan,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) =>
                          CustTransUploadScreen(model: widget.model)));
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
                hintText: ("Search TransName"),
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
      drawer: MyDrawer(),
      body: CustomScrollView(
        slivers: [
          /*SliverPersistentHeader(
              pinned: true,
              delegate: TextWidgetHeader(
                  title:
                      "My " + widget.model!.menuTitle.toString() + "'s Items"),
                      ),*/
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("shops")
                .doc(sharedPreferences!.getString("uid"))
                .collection("customers")
                .doc(widget.model!.custID)
                .collection("custTrans")
                .orderBy(
                  "transDate",
                  descending: true,
                )
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
                        CustTrans model = CustTrans.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        model.transType == "Cash"
                            ? cashTransAmount.add(model.transAmount!.toDouble())
                            : creditTransAmount
                                .add(model.transAmount!.toDouble());

                        if (index + 1 == snapshot.data!.docs.length) {
                          updateFireStore(model.custID);
                        }
                        return model.transName!.toString().contains(query)
                            ? CustTransDesignWidget(
                                model: model,
                                context: context,
                              )
                            : Container();
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
