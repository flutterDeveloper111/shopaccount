import 'package:cloud_firestore/cloud_firestore.dart';

class SalesOrder {
  String? salesOrderID;
  String? shopUID;
  String? salesOrderName;
  String? salesOrderInfo;
  String? customerName;
  int? totalAmount;
  int? itemsCount;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? status;

  SalesOrder({
    this.salesOrderID,
    this.shopUID,
    this.salesOrderName,
    this.salesOrderInfo,
    this.customerName,
    this.totalAmount,
    this.itemsCount,
    this.publishedDate,
    this.thumbnailUrl,
    this.status,
  });

  SalesOrder.fromJson(Map<String, dynamic> json) {
    salesOrderID = json["salesOrder"];
    shopUID = json['shopUID'];
    salesOrderName = json['salesOrderName'];
    salesOrderInfo = json['salesOrderInfo'];
    customerName = json['customerName'];
    totalAmount = json["totalAmount"];
    itemsCount = json["itemsCount"];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["salesOrderID"] = salesOrderID;
    data['sellerUID'] = shopUID;
    data['salesOrderName'] = salesOrderName;
    data['salesOrderInfo'] = salesOrderInfo;
    data['customerName'] = customerName;
    data['totalAmount'] = totalAmount;
    data['itemsCount'] = itemsCount;
    data['publishedDate'] = publishedDate;
    data['thumbnailUrl'] = thumbnailUrl;
    data['status'] = status;

    return data;
  }
}
