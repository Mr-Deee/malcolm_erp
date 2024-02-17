import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';

class Admin extends ChangeNotifier
{
  String?CompanyName;
  String?lastname;
  String?phone;
  String?email;
  String?id;
  String?automobile_color;
  String? automobile_model;
  String?plate_number;
  String?profilepicture;

  Admin({this.CompanyName, this.lastname,this.phone, this.email, this.id, this.automobile_color, this.automobile_model, this.plate_number, this.profilepicture,});

  static Admin fromMap(Map<String, dynamic> data)

  {
    //var data= dataSnapshot.value;
    return Admin(
      id: data['uid'],
      phone: data["phone"],
      email: data["email"],
      CompanyName: data["CompanyName"],
      // lastname: data["LastName"],
      //   profilepicture: data["riderImageUrl"],
      // automobile_color: data["car_details"]["automobile_color"],
      // automobile_model: data["car_details"]["motorBrand"],
      //  plate_number:data["car_details"]["licensePlateNumber"],
    );
  }

  Admin? _adminInfo;

  Admin? get admininfo => _adminInfo;

  void setAdmin(Admin admin) {
    _adminInfo = admin;
    notifyListeners();
  }
}
