import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../core/constants/app_assets.dart';
import '../models/commodity.dart';

/// Loads commodity data for the app.
///
/// IMPORTANT (for project defense): this is the ONLY class that
/// knows the data comes from a local JSON file. Every screen and
/// provider only calls [CommodityService.fetchCommodities] — so
/// later, to switch to a real backend API, only THIS file needs to
/// change (e.g. replace rootBundle.loadString with an http.get call
/// that returns the same JSON shape). No screen code would need to
/// change at all.
class CommodityService {
  Future<List<Commodity>> fetchCommodities() async {
    final jsonString = await rootBundle.loadString(AppAssets.commoditiesJson);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    return jsonList
        .map((item) => Commodity.fromJson(item as Map<String, dynamic>))
        .toList();

    // --- Example of how this method would look with a real API ---
    // final response = await http.get(Uri.parse('https://your-api.com/commodities'));
    // final List<dynamic> jsonList = json.decode(response.body);
    // return jsonList.map((item) => Commodity.fromJson(item)).toList();
  }
}