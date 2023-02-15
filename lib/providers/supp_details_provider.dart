//import 'dart:ffi';

//import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class SupplierProvider with ChangeNotifier {
  double suppCashTotal = 0;
  double suppCreditTotal = 0;
  double custCashTotal = 0;
  double custCreditTotal = 0;
  double transCashTotal = 0;
  double transCreditTotal = 0;
  double transSuppTotal = 0;
  double transCustTotal = 0;
  int suppliersCount = 0;
  int customersCount = 0;
  int suppCreditTransCount = 0;
  int custCashTransCount = 0;
  int suppCashTransCount = 0;
  int custCreditTransCount = 0;

  SupplierProvider({
    this.suppCashTotal = 0,
    this.suppCreditTotal = 0,
    this.suppliersCount = 0,
    this.suppCreditTransCount = 0,
    this.suppCashTransCount = 0,
  });

  double get cashTotal => suppCashTotal;
  double get creditTotal => suppCreditTotal;

  void updateSuppCashTotal(double newValue) {
    suppCashTotal = suppCashTotal + newValue;
    //debugPrint("Provider Supplier Cash Total:: $suppCashTotal");
    notifyListeners();
  }

  void updateSuppCreditTotal(double newValue) {
    suppCreditTotal = suppCreditTotal + newValue;
    notifyListeners();
  }

  void updateSuppliersCount() {
    suppliersCount++;
    notifyListeners();
  }

  void updateSuppCashTransCount() {
    suppCashTransCount++;
    notifyListeners();
  }

  void updateSuppCreditTransCount() {
    suppCreditTransCount++;
    notifyListeners();
  }
}
