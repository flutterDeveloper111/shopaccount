import 'package:cloud_firestore/cloud_firestore.dart';

class CashBook {
  String? cashBookID;
  String? shopUID;
  String? cashBookInfo;
  num? cashInAmount;
  num? cashOutAmount;
  num? onlineInAmount;
  num? onlineOutAmount;
  Timestamp? publishedDate;
  Timestamp? transDate;
  String? status;

  CashBook({
    this.cashBookID,
    this.shopUID,
    this.cashBookInfo,
    this.cashInAmount,
    this.cashOutAmount,
    this.onlineInAmount,
    this.onlineOutAmount,
    this.publishedDate,
    this.transDate,
    this.status,
  });

  CashBook.fromJson(Map<String, dynamic> json) {
    cashBookID = json["cashBookID"];
    shopUID = json['shopUID'];
    cashBookInfo = json['cashBookInfo'];
    cashInAmount = json["cashInAmount"];
    cashOutAmount = json["cashOutAmount"];
    onlineInAmount = json["onlineInAmount"];
    onlineOutAmount = json["onlineOutAmount"];
    publishedDate = json['publishedDate'];
    transDate = json['transDate'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["cashBookID"] = cashBookID;
    data['sellerUID'] = shopUID;
    data['cashBookInfo'] = cashBookInfo;
    data['cashInAmount'] = cashInAmount;
    data['cashOutAmount'] = cashOutAmount;
    data['onlineInAmount'] = onlineInAmount;
    data['onlineOutAmount'] = onlineOutAmount;
    data['publishedDate'] = publishedDate;
    data['transDate'] = transDate;
    data['status'] = status;
    return data;
  }
}
