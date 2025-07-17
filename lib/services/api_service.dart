import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../screens/health_tips_screen.dart';

class ApiService {
  static const String _baseUrl = 'https://api.fda.gov/drug/drugsfda.json';
  static const String _HealthTipsUrl =
      'https://health.gov/myhealthfinder/api/v3/topicsearch.json?lang=english';

  static Future<List<String>> getMedicationNames() async {
    try {
      final response = await http.get(Uri.parse(
          '$_baseUrl?search=products.brand_name:exact+"aspirin"&limit=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        return results
            .map((item) => item['products'][0]['brand_name'] as String)
            .toList();
      }
      return [];
    } catch (e) {
      // API Error: $e
      return [];
    }
  }

  static Future<String> getHealthTip() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.adviceslip.com/advice'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['slip']['advice'] as String;
      }
      // fallback to local tips
    } catch (e) {
      // fallback to local tips
    }
    // Fallback: pick a random health tip from a local list
    const fallbackTips = [
      'Drink plenty of water every day.',
      'Get at least 7-8 hours of sleep each night.',
      'Exercise regularly for a healthy body and mind.',
      'Eat a balanced diet rich in fruits and vegetables.',
      'Take breaks and stretch during long periods of sitting.',
      'Wash your hands frequently to prevent illness.',
      'Manage stress with mindfulness or meditation.',
      'Schedule regular check-ups with your doctor.',
      'Limit your intake of processed foods and sugar.',
      'Protect your skin from excessive sun exposure.'
    ];
    final random = Random();
    return fallbackTips[random.nextInt(fallbackTips.length)];
  }

  static Future<List<HealthNewsItem>> getHealthNewsDetailed() async {
    try {
      final url = Uri.parse(
          'https://api.mediastack.com/v1/news?access_key=demo&categories=health&languages=en&limit=5');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['data'] as List<dynamic>?;
        if (articles != null && articles.isNotEmpty) {
          return articles
              .map((a) => HealthNewsItem(
                    title: a['title'] ?? '',
                    description: a['description'] ?? '',
                    url: a['url'],
                  ))
              .toList();
        }
      }
    } catch (e) {}
    // Fallback
    return [
      HealthNewsItem(
          title: 'New Study Shows Benefits of Daily Walking',
          description:
              'A new study highlights the health benefits of walking daily for at least 30 minutes.',
          url: null),
      HealthNewsItem(
          title: 'How to Stay Hydrated in Summer',
          description:
              'Experts recommend drinking at least 8 cups of water a day, especially during hot weather.',
          url: null),
      HealthNewsItem(
          title: 'Tips for Better Sleep Hygiene',
          description:
              'Simple changes to your bedtime routine can improve your sleep quality.',
          url: null),
      HealthNewsItem(
          title: 'Understanding Mental Health Awareness',
          description:
              'Mental health is as important as physical health. Learn how to support yourself and others.',
          url: null),
      HealthNewsItem(
          title: 'Healthy Eating: What the Experts Say',
          description:
              'Nutritionists share their top tips for a balanced diet.',
          url: null),
    ];
  }
}
