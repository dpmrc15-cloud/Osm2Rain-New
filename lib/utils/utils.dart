import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class Utils {
  /// แสดง Toast ข้อความสั้น ๆ
  static Future<bool?> createToast(String text) {
    return Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black38,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// ตรวจสอบว่า string เป็น null หรือว่างหรือไม่
  static bool isNullOrEmpty(String? text) {
    if (text == null) return true;
    if (text.trim().isEmpty) return true;
    return false;
  }
}