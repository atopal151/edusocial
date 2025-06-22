import 'dart:convert';
import 'package:http/http.dart' as http;

class LanguageEndpointTester {
  static const String baseUrl = "https://stageapi.edusocial.pl/mobile";
  static const String token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5ZTcwNDFjMS0zMDgxLTQ1MGQtODJlOS1lZGZjZmYzOGIwY2MiLCJqdGkiOiIzMjEwYjhkOTAwNTQwM2Y5MDY3Zjg3YTZlNjMzMjE3ZTVmZjRkOGNlZjk0MjEyYWQyM2U1MWVhNmVhYjg1YjRlMjE0M2FhMWU3OGE4MmIxOCIsImlhdCI6MTc0NzY3MjY3MC44NTk2ODUsIm5iZiI6MTc0NzY3MjY3MC44NTk2ODcsImV4cCI6MTc3OTIwODY3MC44NTcwNTUsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.jbsnmsoyZMLZhMg2qvaWrx9LE1iyvlSHlubNgRpzHpotrMOoKkdR9EDKSF_OOPtlsom8VZTJRM1iYBWrprgh4jXcbDcjGMM-X0tyD2YUr9fRKIa21RFb4QmbW01TxYYq3bh1Rq3K_V9w1QG8K4m9sgbXgWVPbx-g4_1Um7RcFsVfF5E66IS-D5lW1wA6YNYxo4alABlUUKlUveTHuQSWZ5BQMikZiz52r2H0eOkA2EnAWznxWvVg4MOgQR7hHtDeLdAMD7vLhu-cYfnqMSnPm7L5boo_j-EklrmIPKEIxa6PXszJB9oesPhJ_sRrjEGToeEkxV6lj2YxBAnm5TyqCxdZlEPONDC1Hb-HWtbrA24fyJKM8juKSqXGNBLo2PYZB5U55Dq6SdyDtohbDKGEHkDdmFMlIYPJpgVsOMNhUnBeXKMbDAuY7Dq6LQ2ocLGJLUR16PK1iTZIprETgMG2uV_NLgIAtWiwgcO9jrrKo2ux-XYQlcOE-llTdtbe1mbWS3LrB31-nVgPHKjHaQMubvuz4oqeA0n7LSlxpNPiZqPA7DP3-n34wMXuj_f4QxGnQDhk9-zak0OAtyxjgK3QRJJ_A67tpmqO58BCba8cVbjbCkrQL837otDSXU9WEKacrZqba2Wb_t8c8N_UbEMoY0CUAi918ppQY7uhcc9ToQM";

  /// Test Languages endpoint (/languages)
  static Future<void> testLanguagesEndpoint() async {
    print("🔍 Testing Languages endpoint...");
    print("URL: $baseUrl/languages");
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/languages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("📊 Status Code: ${response.statusCode}");
      print("📄 Response Headers: ${response.headers}");
      print("📝 Response Body:");
      print(response.body);
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print("\n✅ Success! Parsed JSON:");
        print(jsonData);
        
        if (jsonData['data'] != null) {
          print("\n📋 Languages found: ${jsonData['data'].length}");
          for (int i = 0; i < jsonData['data'].length; i++) {
            final language = jsonData['data'][i];
            print("  ${i + 1}. ID: ${language['id']}, Name: ${language['name']}");
          }
        }
      } else {
        print("❌ Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
    print("\n" + "="*50 + "\n");
  }

  /// Test Frontend Language endpoint (/json-language)
  static Future<void> testFrontendLanguageEndpoint() async {
    print("🔍 Testing Frontend Language endpoint...");
    print("URL: $baseUrl/json-language");
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/json-language'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("📊 Status Code: ${response.statusCode}");
      print("📄 Response Headers: ${response.headers}");
      print("📝 Response Body:");
      print(response.body);
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print("\n✅ Success! Parsed JSON:");
        print(jsonData);
        
        // Try to identify the structure
        if (jsonData is Map) {
          print("\n📋 Frontend Language Data Structure:");
          jsonData.forEach((key, value) {
            print("  $key: $value");
          });
        } else if (jsonData is List) {
          print("\n📋 Frontend Language Data (List):");
          print("  Items count: ${jsonData.length}");
          for (int i = 0; i < jsonData.length; i++) {
            print("  ${i + 1}. ${jsonData[i]}");
          }
        }
      } else {
        print("❌ Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
    print("\n" + "="*50 + "\n");
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    print("🚀 Starting Language Endpoint Tests...\n");
    
    await testLanguagesEndpoint();
    await testFrontendLanguageEndpoint();
    
    print("✅ All tests completed!");
  }
}

// Test runner
void main() async {
  await LanguageEndpointTester.runAllTests();
} 