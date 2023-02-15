import 'package:cloud_firestore/cloud_firestore.dart';

class SupTrans {
  String? supplierID;
  String? shopUID;
  String? shopName;
  String? supplierName;
  String? supplierContact;
  String? supplierAddress;
  String? suppTransID;
  String? transName;
  String? transInfo;
  String? transType;
  Timestamp? transDate;
  Timestamp? publishedDate;
  Timestamp? transDueDate;
  Timestamp? transClosedDate;
  String? thumbnailUrl;
  String? transPaymentDetails;
  String? status;
  num? transAmount;

  SupTrans({
    this.supplierID,
    this.shopUID,
    this.shopName,
    this.supplierName,
    this.supplierContact,
    this.supplierAddress,
    this.suppTransID,
    this.transName,
    this.transInfo,
    this.transType,
    this.transDate,
    this.publishedDate,
    this.transDueDate,
    this.transClosedDate,
    this.thumbnailUrl,
    this.transPaymentDetails,
    this.transAmount,
  });

  SupTrans.fromJson(Map<String, dynamic> json) {
    supplierID = json['supplierID'];
    shopUID = json['shopUID'];
    shopName = json['shopName'];
    supplierName = json['supplierName'];
    supplierContact = json['supplierContact'];
    supplierAddress = json['supplierAddress'];
    suppTransID = json['suppTransID'];
    transName = json['transName'];
    transInfo = json['transInfo'];
    transType = json['transType'];
    transDate = json['transDate'];
    publishedDate = json['publishedDate'];
    transDueDate = json['transDueDate'];
    transClosedDate = json['transClosedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    transPaymentDetails = json['transPaymentDetails'];
    status = json['status'];
    transAmount = json['transAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['supplierID'] = supplierID;
    data['shopUID'] = shopUID;
    data['shopName'] = shopName;
    data['supplierName'] = supplierName;
    data['supplierContact'] = supplierContact;
    data['supplierAddress'] = supplierAddress;
    data['suppTransID'] = suppTransID;
    data['transName'] = transName;
    data['transInfo'] = transInfo;
    data['transAmount'] = transAmount;
    data['transDate'] = transDate;
    data['publishedDate'] = publishedDate;
    data['transDueDate'] = transDueDate;
    data['transClosedDate'] = transClosedDate;
    data['thumbnailUrl'] = thumbnailUrl;
    data['transPaymentDetails'] = transPaymentDetails;
    data['status'] = status;

    return data;
  }
}
