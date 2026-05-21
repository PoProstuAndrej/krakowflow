import '../models/task.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskApiService {
  static Future<List<Task>> fetchTasks() async {
    // Przykładowy endpoint, zamień na prawdziwy jeśli masz
    final response = await http.get(Uri.parse('https://example.com/api/tasks'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Task.fromMap(item)).toList();
    } else {
      throw Exception('Błąd pobierania danych z API');
    }
  }
}
