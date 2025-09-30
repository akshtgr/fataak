import 'package:fataak/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  UserData _userData = UserData(
    firstName: '',
    lastName: '',
    address: '',
    phone: '',
  );

  UserProvider() {
    loadUserData();
  }

  UserData get userData => _userData;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userData = UserData(
      firstName: prefs.getString('firstName') ?? '',
      lastName: prefs.getString('lastName') ?? '',
      address: prefs.getString('address') ?? '',
      phone: prefs.getString('phone') ?? '',
    );
    notifyListeners();
  }

  Future<void> saveUserData(UserData newUserData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', newUserData.firstName);
    await prefs.setString('lastName', newUserData.lastName);
    await prefs.setString('address', newUserData.address);
    await prefs.setString('phone', newUserData.phone);
    _userData = newUserData;
    notifyListeners();
  }
}