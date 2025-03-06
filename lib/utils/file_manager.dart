// lib/utils/file_manager.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  // Read data from asset
  static Future<List<dynamic>> readFromAsset(String assetPath) async {
    final String jsonString = await rootBundle.loadString(assetPath);
    return jsonDecode(jsonString) as List<dynamic>;
  }

  // Read data from file or asset if file doesn't exist
  static Future<List<dynamic>> readData(String fileName, String assetPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        return jsonDecode(jsonString) as List<dynamic>;
      } else {
        // Fall back to asset if file doesn't exist
        return readFromAsset(assetPath);
      }
    } catch (e) {
      print('Error reading $fileName: $e');
      // Fall back to asset in case of error
      return readFromAsset(assetPath);
    }
  }

  // Write data to file
  static Future<bool> writeData(String fileName, List<dynamic> data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      
      // Create directory if it doesn't exist
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }
      
      // Convert data to JSON string
      final jsonString = jsonEncode(data);
      
      // Write to file
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      print('Error writing to $fileName: $e');
      return false;
    }
  }
}