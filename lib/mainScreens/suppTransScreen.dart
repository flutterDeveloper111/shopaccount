import 'package:account/model/supTrans.dart';
import 'package:account/model/suppliers.dart';
//import 'package:account/providers/supp_details_provider.dart';
import 'package:account/uploadScreens/suppTrans_upload_screen.dart';
import 'package:account/widgets/suppTrans_design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:account/global/global.dart';
import 'package:account/widgets/my_drawer.dart';
import 'package:account/widgets/progress_bar.dart';
//import 'package:provider/provider.dart';

class SuppTransScreen extends StatefulWidget {
  final Suppliers? model;
  SuppTransScreen({this.model});

  @override
  _SuppTransScreenState createState() => _SuppTransScreenState();
}

class _SuppTransScreenState extends State<SuppTransScreen> {
  List<double> cashTransAmount = [];
  List<double> creditTransAmount = [];
  double cashTotal = 0;
  double creditTotal = 0;
  double transTotal = 0;
  String query = "";

  updateFireStore(var supplierID) {
    final ref = FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .collection("suppliers");
    cashTransAmount.forEach((e) => cashTotal += e);
    creditTransAmount.forEach((e) => creditTotal += e);
    transTotal = cashTotal + creditTotal;

    ref.doc(supplierID!.toString()).update(
      {
        "transTotal": transTotal.toDouble(),
        "cashTotal": cashTotal.toDouble(),
        "creditTotal": creditTotal.toDouble(),
      },
    ).then((value) {
      final suppRef = FirebaseFirestore.instance.collection("suppliers");
      suppRef.doc(supplierID!.toString()).update({
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
          widget.model!.supplierName!.toString(),
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
                          SuppTransUploadScreen(model: widget.model)));
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
                .collection("suppliers")
                .doc(widget.model!.supplierID)
                .collection("suppTrans")
                .orderBy("transDate", descending: true)
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
                        SupTrans model = SupTrans.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        model.transType == "Cash"
                            ? cashTransAmount.add(model.transAmount!.toDouble())
                            : creditTransAmount
                                .add(model.transAmount!.toDouble());

                        if (index + 1 == snapshot.data!.docs.length) {
                          updateFireStore(model.supplierID);
                        }

                        return model.transName!.toString().contains(query)
                            ? SuppTransDesignWidget(
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
