import 'package:cloud_firestore/cloud_firestore.dart';

class CustTrans {
  String? custID;
  String? shopUID;
  String? shopName;
  String? customerName;
  String? customerContact;
  String? customerAddress;
  String? custTransID;
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

  CustTrans({
    this.custID,
    this.shopUID,
    this.shopName,
    this.customerName,
    this.customerContact,
    this.customerAddress,
    this.custTransID,
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

  CustTrans.fromJson(Map<String, dynamic> json) {
    custID = json['custID'];
    shopUID = json['shopUID'];
    shopName = json['shopName'];
    customerName = json['customerName'];
    customerContact = json['customerContact'];
    customerAddress = json['customerAddress'];
    custTransID = json['custTransID'];
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
    data['custID'] = custID;
    data['shopUID'] = shopUID;
    data['shopName'] = shopName;
    data['customerName'] = customerName;
    data['customerContact'] = customerContact;
    data['customerAddress'] = customerAddress;
    data['custTransID'] = custTransID;
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
