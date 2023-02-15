import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;

int dashBoardSuppCashTotal = 0;
int dashBoardSuppCreditTotal = 0;
int dashBoardSuppTransTotal = 0;
