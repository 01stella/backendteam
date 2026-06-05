import '../model/bundle_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Bundle>> fetchBundles() async {
  final response = await http.get(Uri.parse('http://localhost:3000/api/bundles')); 

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