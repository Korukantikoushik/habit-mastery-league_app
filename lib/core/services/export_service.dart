import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ExportService {
  Future<String> exportHabitsToJson(List<Map<String, dynamic>> habits) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/habit_export.json');

    final content = const JsonEncoder.withIndent('  ').convert(habits);
    await file.writeAsString(content);

    return file.path;
  }
}
