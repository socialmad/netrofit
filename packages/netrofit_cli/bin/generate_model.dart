#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:netrofit_cli/json_to_model.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('json', abbr: 'j', help: 'Path to JSON file (or use stdin)')
    ..addOption('output', abbr: 'o', help: 'Output path: file or directory')
    ..addOption('class-name', abbr: 'c', help: 'Root class name (default: from file name or "Response")')
    ..addFlag('json-serializable', help: 'Add @JsonSerializable() and part directive for build_runner')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage');

  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      print(parser.usage);
      exit(0);
    }

    String jsonInput;
    final jsonPath = results['json'] as String?;
    if (jsonPath != null) {
      final f = File(jsonPath);
      if (!f.existsSync()) {
        stderr.writeln('Error: File not found: $jsonPath');
        exit(1);
      }
      jsonInput = await f.readAsString();
    } else {
      if (stdin.hasTerminal) {
        stderr.writeln('Error: No --json file and no stdin. Pipe JSON or use --json=path.');
        exit(1);
      }
      jsonInput = await stdin.transform(utf8.decoder).join();
    }

    final decoded = jsonDecode(jsonInput);
    if (decoded is! Map<String, dynamic>) {
      stderr.writeln('Error: Root JSON must be an object (map).');
      exit(1);
    }

    String className = results['class-name'] as String? ?? 'Response';
    final explicitClassName = results['class-name'] as String?;
    if (jsonPath != null && (explicitClassName == null || explicitClassName.isEmpty)) {
      final base = jsonPath.split(RegExp(r'[/\\]')).last.replaceAll(RegExp(r'\.json$'), '');
      if (base.isNotEmpty) className = classNameFromKey(base);
    }

    final useJsonSerializable = results['json-serializable'] as bool;
    final output = results['output'] as String? ?? 'lib/models/$className.dart';
    final outPath = output.endsWith('.dart') ? output : '$output/${_fileName(className)}.dart';

    final classes = inferClassesFromMap(decoded, className);
    final partFileName = useJsonSerializable ? '${_fileName(className)}.g.dart' : null;
    final content = generateFileContent(classes, useJsonSerializable: useJsonSerializable, partFileName: partFileName);

    final outFile = File(outPath);
    await outFile.parent.create(recursive: true);
    await outFile.writeAsString(content);

    print('Wrote ${outFile.path} (class $className${classes.length > 1 ? ' + ${classes.length - 1} nested' : ''})');
    if (useJsonSerializable) {
      print('Run: dart run build_runner build --delete-conflicting-outputs');
    }
  } on ArgParserException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exit(1);
  } on FormatException catch (e) {
    stderr.writeln('Error: Invalid JSON - ${e.message}');
    exit(1);
  }
}

String _fileName(String className) {
  final buf = StringBuffer();
  for (var i = 0; i < className.length; i++) {
    final c = className[i];
    if (c.toUpperCase() == c && c.toLowerCase() != c && i > 0) buf.write('_');
    buf.write(c.toLowerCase());
  }
  return buf.toString();
}

