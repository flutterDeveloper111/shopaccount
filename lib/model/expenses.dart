import 'package:cloud_firestore/cloud_firestore.dart';

class Expenses {
  String? expenseID;
  String? shopUID;
  String? expenseInfo;
  String? expenseType;
  num? cashOutAmount;
  num? onlineOutAmount;
  Timestamp? transDate;
  String? thumbnailUrl;
  String? status;

  Expenses({
    this.expenseID,
    this.shopUID,
    this.expenseInfo,
    this.expenseType,
    this.cashOutAmount,
    this.onlineOutAmount,
    this.transDate,
    this.thumbnailUrl,
    this.status,
  });

  Expenses.fromJson(Map<String, dynamic> json) {
    expenseID = json["expenseID"];
    shopUID = json['shopUID'];
    expenseInfo = json['expenseInfo'];
    expenseType = json['expenseType'];
    cashOutAmount = json["cashOutAmount"];
    onlineOutAmount = json["onlineOutAmount"];
    transDate = json['transDate'];
    thumbnailUrl = json['thumbnailUrl'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["expenseID"] = expenseID;
    data['sellerUID'] = shopUID;
    data['expenseInfo'] = expenseInfo;
    data['expenseType'] = expenseType;
    data['cashOutAmount'] = cashOutAmount;
    data['onlineOutAmount'] = onlineOutAmount;
    data['transDate'] = transDate;
    data['thumbnailUrl'] = thumbnailUrl;
    data['status'] = status;

    return data;
  }
}
