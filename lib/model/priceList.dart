import 'package:cloud_firestore/cloud_firestore.dart';

class PriceList {
  String? priceListID;
  String? shopUID;
  String? priceListName;
  String? priceListInfo;
  String? supplierName;
  int? salePrice;
  int? purchasePrice;
  int? inStockCount;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? status;

  PriceList({
    this.priceListID,
    this.shopUID,
    this.priceListName,
    this.priceListInfo,
    this.supplierName,
    this.salePrice,
    this.purchasePrice,
    this.inStockCount,
    this.publishedDate,
    this.thumbnailUrl,
    this.status,
  });

  PriceList.fromJson(Map<String, dynamic> json) {
    priceListID = json["priceListID"];
    shopUID = json['shopUID'];
    priceListName = json['priceListName'];
    priceListInfo = json['priceListInfo'];
    supplierName = json['supplierName'];
    salePrice = json['salePrice'];
    purchasePrice = json["purchasePrice"];
    inStockCount = json["inStockCount"];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["priceListID"] = priceListID;
    data['sellerUID'] = shopUID;
    data['priceListName'] = priceListName;
    data['priceListName'] = priceListInfo;
    data['supplierName'] = supplierName;
    data['salePrice'] = salePrice;
    data['purchasePrice'] = purchasePrice;
    data['inStockCount'] = inStockCount;
    data['publishedDate'] = publishedDate;
    data['thumbnailUrl'] = thumbnailUrl;
    data['status'] = status;

    return data;
  }
}
