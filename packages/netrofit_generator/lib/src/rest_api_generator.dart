import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:netrofit_annotations/netrofit_annotations.dart' show RestApi;
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

/// Generator for @RestApi annotated classes.
///
/// Generated files now automatically include:
/// - `part of` directive
/// - `dart:convert` import for jsonDecode
class RestApiGenerator extends GeneratorForAnnotation<RestApi> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@RestApi can only be applied to classes.',
        element: element,
      );
    }

    if (!element.isAbstract) {
      throw InvalidGenerationSourceError(
        '@RestApi can only be applied to abstract classes.',
        element: element,
      );
    }

    final className = element.name;
    final implClassName = '_\$${className}Impl';
    final baseUrl = annotation.read('baseUrl').stringValue;

    final classBuilder = Class((b) => b
      ..name = implClassName
      ..implements.add(refer(className))
      ..fields.add(_buildHttpAdapterField())
      ..constructors.add(_buildConstructor())
      ..methods.addAll(_buildMethods(element, baseUrl)));

    final emitter = DartEmitter(useNullSafetySyntax: true);
    final generatedCode = classBuilder.accept(emitter).toString();

    // Build the complete output
    final output = '''
// **************************************************************************
// RestApiGenerator
// **************************************************************************

$generatedCode
''';

    try {
      return DartFormatter().format(output);
    } catch (e) {
      log.warning('Failed to format generated code: $e');
      return output;
    }
  }

  Field _buildHttpAdapterField() {
    return Field((b) => b
      ..name = '_httpAdapter'
      ..type = refer('HttpAdapter', 'package:netrofit_core/netrofit_core.dart')
      ..modifier = FieldModifier.final$);
  }

  Constructor _buildConstructor() {
    return Constructor((b) => b
      ..optionalParameters.add(Parameter((p) => p
        ..name = 'httpAdapter'
        ..named = true
        ..required = true
        ..type =
            refer('HttpAdapter', 'package:netrofit_core/netrofit_core.dart')))
      ..initializers.add(Code('_httpAdapter = httpAdapter')));
  }

  Iterable<Method> _buildMethods(ClassElement element, String baseUrl) {
    return element.methods.where((m) => !m.isStatic).map((method) {
      return _buildMethod(method, baseUrl);
    });
  }

  Method _buildMethod(MethodElement method, String baseUrl) {
    final httpMethodAnnotation = _getHttpMethodAnnotation(method);
    if (httpMethodAnnotation == null) {
      throw InvalidGenerationSourceError(
        'Method ${method.name} must have an HTTP method annotation (@Get, @Post, etc.)',
        element: method,
      );
    }

    final httpMethod = httpMethodAnnotation.type?.element?.name ?? '';
    final pathReader = ConstantReader(httpMethodAnnotation);
    // Try to read 'path' field directly
    String? pathValue = pathReader.peek('path')?.stringValue;

    // If that fails, try to get it from the constructor arguments (revive)
    if (pathValue == null) {
      try {
        final revived = pathReader.revive();
        if (revived.positionalArguments.isNotEmpty) {
          // The first positional argument is the path
          pathValue =
              ConstantReader(revived.positionalArguments.first).stringValue;
        }
      } catch (_) {
        // Revive might fail in some edge cases
      }
    }

    final path = pathValue ?? _getPathFromMethodAnnotation(method);

    return Method((b) => b
      ..name = method.name
      ..returns =
          refer(method.returnType.getDisplayString(withNullability: true))
      ..modifier = MethodModifier.async
      ..requiredParameters.addAll(
        method.parameters.where((p) => p.isRequiredPositional).map(
              (p) => Parameter((pb) => pb
                ..name = p.name
                ..type = refer(p.type.getDisplayString(withNullability: true))),
            ),
      )
      ..optionalParameters.addAll(
        method.parameters.where((p) => p.isOptionalNamed).map(
              (p) => Parameter((pb) => pb
                ..name = p.name
                ..named = true
                ..required = p.isRequired
                ..type = refer(p.type.getDisplayString(withNullability: true))),
            ),
      )
      ..body = _buildMethodBody(method, httpMethod, baseUrl, path));
  }

  Code _buildMethodBody(
    MethodElement method,
    String httpMethod,
    String baseUrl,
    String path,
  ) {
    final buffer = StringBuffer();

    // Path parameter substitution
    final pathParamNames = _extractPathParamNames(path);
    if (pathParamNames.isNotEmpty) {
      buffer.writeln('var path = \'$path\';');
      for (final param in method.parameters) {
        final pathKey = _getPathParamKey(param);
        if (pathKey != null && pathParamNames.contains(pathKey)) {
          buffer.writeln(
              'path = path.replaceAll(\'{$pathKey}\', ${param.name}.toString());');
        }
      }
      buffer.writeln('final url = \'$baseUrl\' + path;');
    } else {
      buffer.writeln('final url = \'$baseUrl$path\';');
    }

    buffer.writeln('final headers = <String, String>{};');
    buffer.writeln('final queryParams = <String, dynamic>{};');
    dynamic bodyVar;

    for (final param in method.parameters) {
      final paramAnnotations = _getParameterAnnotations(param);

      if (paramAnnotations.any((a) => a.type?.element?.name == 'Query')) {
        final queryAnnotation = paramAnnotations.firstWhere(
          (a) => a.type?.element?.name == 'Query',
        );
        final queryName =
            queryAnnotation.getField('name')?.toStringValue() ?? param.name;
        buffer.writeln('queryParams[\'$queryName\'] = ${param.name};');
      } else if (paramAnnotations
          .any((a) => a.type?.element?.name == 'Header')) {
        final headerAnnotation = paramAnnotations.firstWhere(
          (a) => a.type?.element?.name == 'Header',
        );
        final headerName =
            headerAnnotation.getField('name')?.toStringValue() ?? '';
        buffer.writeln('headers[\'$headerName\'] = ${param.name};');
      } else if (paramAnnotations.any((a) => a.type?.element?.name == 'Body')) {
        final typeStr = param.type.getDisplayString(withNullability: false);
        if (typeStr == 'Map<String, dynamic>') {
          buffer.writeln('final body = ${param.name};');
        } else {
          buffer.writeln('final body = ${param.name}.toJson();');
        }
        bodyVar = 'body';
      }
    }

    buffer.write('''
      final options = RequestOptions(
        method: '${httpMethod.toUpperCase()}',
        url: url,
        headers: headers,
        queryParameters: queryParams,''');
    if (bodyVar != null) {
      buffer.write('\n        body: $bodyVar,');
    }
    buffer.writeln('\n      );');

    // Response type and parsing
    final dataType = _extractApiResultType(method.returnType);
    final parseCode = _buildResponseParseCode(dataType);

    buffer.writeln('''
      try {
        final response = await _httpAdapter.${httpMethod.toLowerCase()}(options);
        
        if (response.isSuccessful) {
          $parseCode
        } else {
          return ApiResult.failure(
            error: ServerError('Request failed', statusCode: response.statusCode),
            statusCode: response.statusCode,
          );
        }
      } on ApiError catch (e) {
        return ApiResult.failure(error: e);
      } catch (e, stackTrace) {
        return ApiResult.failure(
          error: UnknownError('Unknown error: \$e', cause: e, stackTrace: stackTrace),
        );
      }
    ''');

    return Code(buffer.toString());
  }

  /// Extracts {paramName} placeholders from path.
  Set<String> _extractPathParamNames(String path) {
    final names = <String>{};
    final regex = RegExp(r'\{(\w+)\}');
    for (final match in regex.allMatches(path)) {
      names.add(match.group(1)!);
    }
    return names;
  }

  /// Returns the path key for @Path() parameter, or null.
  String? _getPathParamKey(ParameterElement param) {
    final annotations = _getParameterAnnotations(param);
    final pathAnn = annotations.where(
      (a) => a.type?.element?.name == 'Path',
    );
    if (pathAnn.isEmpty) return null;
    final name = pathAnn.first.getField('name')?.toStringValue();
    return name ?? param.name;
  }

  /// Extracts T from Future<ApiResult<T>>.
  DartType? _extractApiResultType(DartType returnType) {
    if (returnType is! InterfaceType ||
        returnType.element.name != 'Future' ||
        returnType.typeArguments.isEmpty) {
      return null;
    }
    final futureArg = returnType.typeArguments.single;
    if (futureArg is! InterfaceType ||
        futureArg.element.name != 'ApiResult' ||
        futureArg.typeArguments.isEmpty) {
      return null;
    }
    return futureArg.typeArguments.single;
  }

  /// Generates the success branch: parse response and return ApiResult.success(...).
  String _buildResponseParseCode(DartType? dataType) {
    if (dataType == null) {
      return '''
        final data = jsonDecode(response.body);
        return ApiResult.success(
          data: data,
          statusCode: response.statusCode,
          headers: response.headers,
        );''';
    }

    final display = dataType.getDisplayString(withNullability: false);

    if (display == 'void' || display == 'Null') {
      return '''
        return ApiResult.success(
          data: null,
          statusCode: response.statusCode,
          headers: response.headers,
        );''';
    }

    if (display == 'dynamic') {
      return '''
        final data = jsonDecode(response.body);
        return ApiResult.success(
          data: data,
          statusCode: response.statusCode,
          headers: response.headers,
        );''';
    }

    // List<Model>
    if (dataType is InterfaceType &&
        dataType.element.name == 'List' &&
        dataType.typeArguments.isNotEmpty) {
      final itemType = dataType.typeArguments.single;
      final itemDisplay = itemType.getDisplayString(withNullability: false);
      return '''
        final decoded = jsonDecode(response.body) as List;
        final data = decoded.map((e) => $itemDisplay.fromJson(e as Map<String, dynamic>)).toList();
        return ApiResult.success(
          data: data,
          statusCode: response.statusCode,
          headers: response.headers,
        );''';
    }

    // Single model (class with fromJson)
    return '''
        final data = $display.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        return ApiResult.success(
          data: data,
          statusCode: response.statusCode,
          headers: response.headers,
        );''';
  }

  /// Fallback: extract path from annotation in source when constant value does not expose it.
  String _getPathFromMethodAnnotation(MethodElement method) {
    try {
      final source = method.source;
      if (source == null) return '';
      final contents = source.contents?.data;
      if (contents == null || contents.isEmpty) return '';
      final offset = method.nameOffset;
      if (offset <= 0 || offset > contents.length) return '';
      final beforeMethod = contents.substring(0, offset);
      final regex = RegExp(
        r'@(Get|Post|Put|Delete|Patch|Head)\s*\(\s*["\x27]([^"\x27]*)["\x27]\s*\)',
      );
      final matches = regex.allMatches(beforeMethod);
      if (matches.isEmpty) return '';
      return matches.last.group(2) ?? '';
    } catch (_) {
      return '';
    }
  }

  DartObject? _getHttpMethodAnnotation(MethodElement method) {
    const httpMethods = ['Get', 'Post', 'Put', 'Delete', 'Patch', 'Head'];

    for (final annotation in method.metadata) {
      final value = annotation.computeConstantValue();
      if (value != null && httpMethods.contains(value.type?.element?.name)) {
        return value;
      }
    }
    return null;
  }

  List<DartObject> _getParameterAnnotations(ParameterElement param) {
    return param.metadata
        .map((m) => m.computeConstantValue())
        .whereType<DartObject>()
        .toList();
  }
}
