import 'package:app_bitacora/models/app_user.dart';
import 'package:flutter/material.dart';


class UserProvider extends ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;

  void loginUser(String username, String role, String pass){
    _user = AppUser(username: username, role: role, pass: pass);
    notifyListeners();
  }

  void logout(){
    _user = null;
    notifyListeners();
  }
}