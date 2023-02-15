import 'package:cloud_firestore/cloud_firestore.dart';

class Customers {
  String? custID;
  String? shopUID;
  String? customerName;
  String? customerInfo;
  String? customerContact;
  String? customerAddress;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? status;
  num? transTotal;
  num? cashTotal;
  num? creditTotal;

  Customers({
    this.custID,
    this.shopUID,
    this.customerName,
    this.customerInfo,
    this.customerContact,
    this.customerAddress,
    this.publishedDate,
    this.thumbnailUrl,
    this.status,
    this.transTotal,
    this.cashTotal,
    this.creditTotal,
  });

  Customers.fromJson(Map<String, dynamic> json) {
    custID = json["custID"];
    shopUID = json['shopUID'];
    customerName = json['customerName'];
    customerInfo = json['customerInfo'];
    customerContact = json['customerContact'];
    customerAddress = json["customerAddress"];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    status = json['status'];
    transTotal = json['transTotal'];
    cashTotal = json['cashTotal'];
    creditTotal = json['creditTotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["custID"] = custID;
    data['shopUID'] = shopUID;
    data['customerName'] = customerName;
    data['customerInfo'] = customerInfo;
    data['customerContact'] = customerContact;
    data['customerAddress'] = customerAddress;
    data['publishedDate'] = publishedDate;
    data['thumbnailUrl'] = thumbnailUrl;
    data['status'] = status;
    data['transTotal'] = transTotal;
    data['cashTotal'] = cashTotal;
    data['creditTotal'] = creditTotal;

    return data;
  }
}
