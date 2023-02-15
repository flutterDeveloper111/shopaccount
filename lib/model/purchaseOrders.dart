import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseOrder {
  String? purchaseOrderID;
  String? shopUID;
  String? purchaseOrderName;
  String? purchaseOrderInfo;
  String? supplierName;
  int? totalAmount;
  int? itemsCount;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? status;

  PurchaseOrder({
    this.purchaseOrderID,
    this.shopUID,
    this.purchaseOrderName,
    this.purchaseOrderInfo,
    this.supplierName,
    this.totalAmount,
    this.itemsCount,
    this.publishedDate,
    this.thumbnailUrl,
    this.status,
  });

  PurchaseOrder.fromJson(Map<String, dynamic> json) {
    purchaseOrderID = json["purchaseOrder"];
    shopUID = json['shopUID'];
    purchaseOrderName = json['purchaseOrderName'];
    purchaseOrderInfo = json['purchaseOrderInfo'];
    supplierName = json['supplierName'];
    totalAmount = json["totalAmount"];
    itemsCount = json["itemsCount"];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["purchaseOrderID"] = purchaseOrderID;
    data['sellerUID'] = shopUID;
    data['purchaseOrderName'] = purchaseOrderName;
    data['purchaseOrderInfo'] = purchaseOrderInfo;
    data['supplierName'] = supplierName;
    data['totalAmount'] = totalAmount;
    data['itemsCount'] = itemsCount;
    data['publishedDate'] = publishedDate;
    data['thumbnailUrl'] = thumbnailUrl;
    data['status'] = status;

    return data;
  }
}
