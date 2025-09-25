import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/show.dart';

class ApiService {
  static const String baseUrl = 'https://api.tvmaze.com';
  static const Duration timeout = Duration(seconds: 10);

  static Future<List<Show>> searchShows(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/search/shows?q=$query'),
          )
          .timeout(timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Show.fromJson(item['show'])).toList();
      }
      throw Exception('Failed to search shows: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: Check internet connection');
    }
  }

  static Future<List<Show>> getTrendingShows(int page) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shows'),
          )
          .timeout(timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Sort by ID (newer shows have higher IDs) and take recent ones
        data.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
        final startIndex = page * 20;
        // final endIndex = startIndex + 20;
        if (startIndex >= data.length) return [];
        return data
            .skip(startIndex)
            .take(20)
            .map((item) => Show.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load trending shows: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: Check internet connection');
    }
  }

  static Future<Show> getShowDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/shows/$id'));
    if (response.statusCode == 200) {
      return Show.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load show details');
  }

  static Future<List<Show>> getPopularShows(int page) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shows'),
          )
          .timeout(timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Filter shows with ratings and sort by rating descending
        final ratedShows =
            data.where((item) => item['rating']?['average'] != null).toList();
        ratedShows.sort((a, b) => (b['rating']['average'] ?? 0.0)
            .compareTo(a['rating']['average'] ?? 0.0));
        final startIndex = page * 20;
        if (startIndex >= ratedShows.length) return [];
        return ratedShows
            .skip(startIndex)
            .take(20)
            .map((item) => Show.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load popular shows: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: Check internet connection');
    }
  }

  static Future<List<Show>> getUpcomingShows(int page) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shows'),
          )
          .timeout(timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Filter shows with status 'Running' or recent shows, fallback to all shows
        final filteredShows = data.where((item) {
          final status = item['status'];
          final premiered = item['premiered'];

          // Prefer running shows
          if (status == 'Running') return true;

          // Include shows from last 5 years if premiered date exists
          if (premiered != null) {
            final premiereYear = DateTime.tryParse(premiered)?.year;
            return premiereYear != null &&
                premiereYear >= DateTime.now().year - 5;
          }

          return true; // Include all shows as fallback
        }).toList();

        // Sort by status (Running first) then by premiere date
        filteredShows.sort((a, b) {
          final statusA = a['status'] == 'Running' ? 1 : 0;
          final statusB = b['status'] == 'Running' ? 1 : 0;
          if (statusA != statusB) return statusB.compareTo(statusA);

          final dateA =
              DateTime.tryParse(a['premiered'] ?? '') ?? DateTime(1900);
          final dateB =
              DateTime.tryParse(b['premiered'] ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        final startIndex = page * 20;
        if (startIndex >= filteredShows.length) return [];
        return filteredShows
            .skip(startIndex)
            .take(20)
            .map((item) => Show.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load upcoming shows: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: Check internet connection');
    }
  }
}
