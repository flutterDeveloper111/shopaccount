import 'dart:typed_data';

import 'package:account/constants/constants.dart';
import 'package:account/global/global.dart';
import 'package:account/model/customers.dart';
import 'package:account/uploadScreens/customers_upload_screen.dart';

//import 'package:account/uploadScreens/menus_upload_screen.dart';
import 'package:account/widgets/cust_info_design.dart';
import 'package:account/widgets/my_drawer.dart';
import 'package:account/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String query = "";
  List<double> cashTransAmount = [
    0,
  ];
  List<double> creditTransAmount = [
    0,
  ];

  double cashTotal = 0;
  double creditTotal = 0;
  double transTotal = 0;
  int customersCount = 0;
  List<Contact> contacts = [];
  List<Contact> filtercontacts = [];
  bool isSearching = false;


  bool contactsLoaded = false;

  initState() {
   getContact();
    filtercontacts = contacts;

  }

  updateDashBoardTotal(List<double> cashTransAmount,
      List<double> creditTransAmount, int customersCount) {
    cashTransAmount.forEach((e) => cashTotal += e);
    creditTransAmount.forEach((e) => creditTotal += e);
    transTotal = cashTotal + creditTotal;

    FirebaseFirestore.instance
        .collection("shops")
        .doc(sharedPreferences!.getString("uid"))
        .update(
      {
        "custCashTotal": (cashTotal).toDouble(),
        "custCreditTotal": (creditTotal).toDouble(),
        "customersCount": customersCount.toInt(),
      },
    ).then((value) => debugPrint("its successfull"));
    debugPrint("values of query:: $query");
    debugPrint("values of UID ${sharedPreferences!.getString("uid")}");
    debugPrint("values of cashTotal $cashTotal");
    debugPrint("values of creditTotal $creditTotal");
    debugPrint("values of customersCount $customersCount");
  }

  void _runFilter(String enteredKeyword) {
    print(enteredKeyword);
    List<Contact> results = [];
    if (enteredKeyword.isEmpty) {
      setState(() {
        results = contacts;
      });
      // if the search field is empty or only contains white-space, we'll display all users
    } else {
      setState(() {
        results = contacts
            .where((user) => user.displayName
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()))
            .toList();
      });

      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      filtercontacts = results;
    });
  }

  void getContact() async {
    if (await FlutterContacts.requestPermission()) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      print(contacts);
      setState(() {
        filtercontacts = contacts;
      });
    }
  }

  showContact() {
    //getPermissions();
    getContact();
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.60,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              children: [
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _runFilter(value);
                    });
                  },
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search_sharp, color: Colors.cyan),
                      hintText: "Search...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                SizedBox(
                  height: 20,
                ),
                filtercontacts == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: filtercontacts.length,
                          itemBuilder: (context, index) {
                            Uint8List? image = filtercontacts![index].photo;
                            String num = (filtercontacts![index].phones.isNotEmpty)
                                ? (filtercontacts![index].phones.first.number)
                                : "--";

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CustomersUploadScreen(
                                        cust_name:
                                            filtercontacts![index].displayName,
                                        cust_contactnumber: num,
                                      ),
                                    ));
                              },
                              child: ListTile(
                                leading: (filtercontacts![index].photo == null)
                                    ? const CircleAvatar(
                                        child: Icon(Icons.person))
                                    : CircleAvatar(
                                        backgroundImage: MemoryImage(image!)),
                                /*title: Text(
                                    "${contacts![index].name.first} ${contacts![index].name.last}"),*/
                                title: Text(
                                    "${filtercontacts![index].displayName}"),
                                subtitle: Text(num),
                              ),
                            );
                          },
                        ),
                      )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //isSearching=searchController.text.isNotEmpty;
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
          )),
        ),
        title: const Text(
          //sharedPreferences!.getString("name")!,
          'Customers',
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
              showContact();
              /* Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => const CustomersUploadScreen()));*/
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
                hintText: ("Search Customers"),
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
                .collection("customers")
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
                        Customers model = Customers.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );

                        snapshot.data!.docs[index]['customerName']
                                .toString()
                                .contains(query.toString())
                            ? creditTotal += model.creditTotal ?? 0.toDouble()
                            : debugPrint("not containes");
                        snapshot.data!.docs[index]['customerName']
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
            stream: FirebaseFirestore.instance
                .collection("shops")
                .doc(sharedPreferences!.getString("uid"))
                .collection("customers")
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
                        debugPrint("printed at ItemBuilder");
                        Customers model = Customers.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        if (index == 0) {
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
                        }
                        return model.customerName!
                                .toString()
                                .contains(query.toString())
                            ? CustInfoDesignWidget(
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
