import '../model/bundle_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart'; // Import your ApiService to get the baseUrl

Future<List<Bundle>> fetchBundles() async {
  // Use the baseUrl from ApiService so everything is in sync!
  final response = await http.get(Uri.parse('${ApiService.baseUrl}/bundles')); 

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    
    if (data['success'] == true) {
      List<dynamic> bundleList = data['data'];
      return bundleList.map((json) => Bundle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bundles from API');
    }
  } else {
    throw Exception('Server connection error');
  }
}