/// Infers Dart type and optional nested class name from JSON value.
String inferDartType(dynamic value, {String? suggestedName}) {
  if (value == null) return 'dynamic';
  if (value is bool) return 'bool';
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is String) return 'String';
  if (value is List) {
    if (value.isEmpty) return 'List<dynamic>';
    final first = value.first;
    if (first is Map) {
      final inner = suggestedName != null ? '${suggestedName}Item' : 'ListItem';
      return 'List<${_classNameFromKey(inner)}>';
    }
    return 'List<${inferDartType(first)}>';
  }
  if (value is Map) return suggestedName != null ? _classNameFromKey(suggestedName) : 'Map<String, dynamic>';
  return 'dynamic';
}

String _classNameFromKey(String key) {
  if (key.isEmpty) return 'Item';
  final trimmed = key.trim();
  final first = trimmed.isEmpty ? 'Item' : trimmed[0].toUpperCase() + trimmed.substring(1);
  final buf = StringBuffer();
  for (var i = 0; i < first.length; i++) {
    final c = first[i];
    if (c == '_' || c == ' ' || c == '-') {
      if (i + 1 < first.length) {
        buf.write(first[i + 1].toUpperCase());
        i++;
      }
      continue;
    }
    buf.write(i == 0 ? c : c.toLowerCase());
  }
  final name = buf.toString();
  if (name.isEmpty) return 'Item';
  return name[0].toUpperCase() + (name.length > 1 ? name.substring(1) : '');
}

/// Generates a Dart class name from a key (e.g. "user_name" -> "UserName").
String classNameFromKey(String key) => _classNameFromKey(key);

/// Generates a Dart field name from a key (e.g. "user_name" -> "userName").
String fieldNameFromKey(String key) {
  if (key.isEmpty) return 'field';
  final parts = key.split(RegExp(r'[_-\s]+'));
  final result = parts.map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1).toLowerCase()).join();
  return result.isEmpty ? 'field' : result[0].toLowerCase() + result.substring(1);
}

/// One generated class (name + fields for fromJson/toJson).
class GeneratedClass {
  final String name;
  final Map<String, String> fields; // fieldName -> dart type string
  final Map<String, String> jsonKeys; // fieldName -> original JSON key
  final Map<String, GeneratedClass> nested;

  GeneratedClass({
    required this.name,
    required this.fields,
    Map<String, String>? jsonKeys,
    Map<String, GeneratedClass>? nested,
  })  : jsonKeys = jsonKeys ?? {},
        nested = nested ?? {};
}

/// Infers all classes from a JSON map (root + nested).
List<GeneratedClass> inferClassesFromMap(Map<String, dynamic> json, String rootClassName) {
  final classes = <GeneratedClass>[];
  final root = _inferClassFromMap(json, rootClassName, classes, null);
  if (root != null) classes.insert(0, root);
  return classes;
}

GeneratedClass? _inferClassFromMap(
  Map<String, dynamic> json,
  String className,
  List<GeneratedClass> classes,
  String? parentKey,
) {
  final fields = <String, String>{};
  final jsonKeys = <String, String>{};
  final nested = <String, GeneratedClass>{};

  for (final entry in json.entries) {
    final key = entry.key;
    final value = entry.value;
    final fieldName = fieldNameFromKey(key);
    final type = _inferFieldType(value, key, className, classes, nested);
    fields[fieldName] = type;
    jsonKeys[fieldName] = key;
  }

  final c = GeneratedClass(name: className, fields: fields, jsonKeys: jsonKeys, nested: nested);
  for (final n in nested.values) {
    if (!classes.any((e) => e.name == n.name)) classes.add(n);
  }
  return c;
}

String _inferFieldType(
  dynamic value,
  String key,
  String parentClassName,
  List<GeneratedClass> classes,
  Map<String, GeneratedClass> nested,
) {
  if (value == null) return 'dynamic?';
  if (value is bool) return 'bool';
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is String) return 'String';
  if (value is List) {
    if (value.isEmpty) return 'List<dynamic>?';
    final first = value.first;
    if (first is Map) {
      final itemClassName = '${classNameFromKey(key)}Item';
      final itemClass = _inferClassFromMap(first as Map<String, dynamic>, itemClassName, classes, key);
      if (itemClass != null) {
        nested[fieldNameFromKey(key)] = itemClass;
        return 'List<${itemClass.name}>';
      }
      return 'List<Map<String, dynamic>>';
    }
    return 'List<${inferDartType(first)}>';
  }
  if (value is Map) {
    final childClassName = classNameFromKey(key);
    final childClass = _inferClassFromMap(value as Map<String, dynamic>, childClassName, classes, key);
    if (childClass != null) {
      nested[fieldNameFromKey(key)] = childClass;
      return childClass.name;
    }
    return 'Map<String, dynamic>';
  }
  return 'dynamic';
}

/// Generates Dart source for a class with fromJson/toJson (no json_serializable).
String generateClassSource(GeneratedClass c, {bool useJsonSerializable = false}) {
  final buf = StringBuffer();
  if (useJsonSerializable) {
    buf.writeln('@JsonSerializable()');
  }
  buf.writeln('class ${c.name} {');
  for (final e in c.fields.entries) {
    buf.writeln('  final ${e.value} ${e.key};');
  }
  buf.writeln();
  buf.writeln('  const ${c.name}({');
  for (final e in c.fields.entries) {
    buf.writeln('    required this.${e.key},');
  }
  buf.writeln('  });');
  buf.writeln();
  if (useJsonSerializable) {
    buf.writeln('  factory ${c.name}.fromJson(Map<String, dynamic> json) => _\$${c.name}FromJson(json);');
    buf.writeln('  Map<String, dynamic> toJson() => _\$${c.name}ToJson(this);');
  } else {
    buf.writeln('  factory ${c.name}.fromJson(Map<String, dynamic> json) {');
    buf.writeln('    return ${c.name}(');
    for (final e in c.fields.entries) {
      final f = e.key;
      final t = e.value.replaceAll('?', '');
      final jsonKey = c.jsonKeys[f] ?? f;
      if (t.startsWith('List<') && !t.contains('Map')) {
        final inner = t.length > 6 ? t.substring(5, t.length - 1) : 'dynamic';
        if (inner != 'dynamic' && inner != 'int' && inner != 'String' && inner != 'bool' && inner != 'double') {
          buf.writeln("      $f: (json['$jsonKey'] as List?)?.map((e) => $inner.fromJson(e as Map<String, dynamic>)).toList() ?? [],");
        } else {
          buf.writeln("      $f: (json['$jsonKey'] as List?) ?? [],");
        }
      } else if (t == 'Map<String, dynamic>' || t == 'dynamic') {
        buf.writeln("      $f: json['$jsonKey'],");
      } else if (_isPrimitive(t)) {
        buf.writeln("      $f: json['$jsonKey'] as $t?,");
      } else {
        buf.writeln("      $f: $t.fromJson(json['$jsonKey'] as Map<String, dynamic>),");
      }
    }
    buf.writeln('    );');
    buf.writeln('  }');
    buf.writeln();
    buf.writeln('  Map<String, dynamic> toJson() {');
    buf.writeln('    return {');
    for (final e in c.fields.entries) {
      final f = e.key;
      final t = e.value.replaceAll('?', '');
      final jsonKey = c.jsonKeys[f] ?? f;
      if (_isPrimitive(t) || t == 'dynamic') {
        buf.writeln("      '$jsonKey': $f,");
      } else if (t.startsWith('List<')) {
        final inner = t.length > 6 ? t.substring(5, t.length - 1) : 'dynamic';
        if (inner != 'dynamic' && inner != 'int' && inner != 'String') {
          buf.writeln("      '$jsonKey': $f.map((e) => e.toJson()).toList(),");
        } else {
          buf.writeln("      '$jsonKey': $f,");
        }
      } else {
        buf.writeln("      '$jsonKey': $f.toJson(),");
      }
    }
    buf.writeln('    };');
    buf.writeln('  }');
  }
  buf.writeln('}');
  return buf.toString();
}

bool _isPrimitive(String t) {
  return t == 'bool' || t == 'int' || t == 'double' || t == 'String';
}

/// Generates full file content (all classes, with optional nested classes first).
String generateFileContent(List<GeneratedClass> classes, {bool useJsonSerializable = false, String? partFileName}) {
  final buf = StringBuffer();
  buf.writeln('// Generated by netrofit_cli. Do not edit by hand.');
  buf.writeln();
  if (useJsonSerializable) {
    buf.writeln("import 'package:json_annotation/json_annotation.dart';");
    if (partFileName != null) buf.writeln("part '$partFileName';");
    buf.writeln();
  }
  final seen = <String>{};
  void writeClass(GeneratedClass c) {
    for (final n in c.nested.values) {
      if (!seen.contains(n.name)) {
        seen.add(n.name);
        writeClass(n);
      }
    }
    if (seen.contains(c.name)) return;
    seen.add(c.name);
    buf.writeln(generateClassSource(c, useJsonSerializable: useJsonSerializable));
    buf.writeln();
  }
  for (final c in classes) {
    writeClass(c);
  }
  return buf.toString().trimRight();
}
