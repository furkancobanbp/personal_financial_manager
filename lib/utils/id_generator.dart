// lib/utils/id_generator.dart
import 'package:uuid/uuid.dart';

class IdGenerator {
  static final _uuid = Uuid();
  
  static String generateId() {
    return _uuid.v4();
  }
}