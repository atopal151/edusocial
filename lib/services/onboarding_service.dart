import '../models/onboarding_model.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';


class OnboardingServices {
  
  static Future<SchoolDepartmentData> fetchSchoolAndDepartments(
      String email) async {
    await Future.delayed(Duration(milliseconds: 500));
    return SchoolDepartmentData(
      school: "Monnet International School",
      departments: ["Computer Engineering", "Math", "Physics"],
    );
  }

/*
  static Future<SchoolDepartmentData> fetchSchoolAndDepartments(String email) async {
    final response = await http.get(Uri.parse("https://your-api.com/api/user-school?email=$email"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return SchoolDepartmentData.fromJson(jsonData);
    } else {
      throw Exception("Okul bilgisi alınamadı");
    }
  }*/
}
