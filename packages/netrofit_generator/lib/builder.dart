import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/rest_api_generator.dart';

/// Builder for generating REST API implementations.
Builder netrofitBuilder(BuilderOptions options) {
  return PartBuilder(
    [RestApiGenerator()],
    '.netrofit.g.dart',
  );
}
