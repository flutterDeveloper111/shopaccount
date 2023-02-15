import 'package:cloud_firestore/cloud_firestore.dart';

class Suppliers {
  String? supplierID;
  String? shopUID;
  String? supplierName;
  String? supplierInfo;
  String? supplierContact;
  String? supplierAddress;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? status;
  num? transTotal;
  num? cashTotal;
  num? creditTotal;

  Suppliers(
      {this.supplierID,
      this.shopUID,
      this.supplierName,
      this.supplierInfo,
      this.supplierContact,
      this.supplierAddress,
      this.publishedDate,
      this.thumbnailUrl,
      this.status,
      this.transTotal,
      this.cashTotal,
      this.creditTotal});

  Suppliers.fromJson(Map<String, dynamic> json) {
    supplierID = json["supplierID"];
    shopUID = json['shopUID'];
    supplierName = json['supplierName'];
    supplierInfo = json['supplierInfo'];
    supplierContact = json['supplierContact'];
    supplierAddress = json["supplierAddress"];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    status = json['status'];
    transTotal = json['transTotal'];
    cashTotal = json['cashTotal'];
    creditTotal = json['creditTotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["supplierID"] = supplierID;
    data['shopUID'] = shopUID;
    data['supplierName'] = supplierName;
    data['supplierInfo'] = supplierInfo;
    data['supplierContact'] = supplierContact;
    data['supplierAddress'] = supplierAddress;
    data['publishedDate'] = publishedDate;
    data['thumbnailUrl'] = thumbnailUrl;
    data['status'] = status;
    data['transTotal'] = transTotal;
    data['cashTotal'] = cashTotal;
    data['creditTotal'] = creditTotal;

    return data;
  }
}
