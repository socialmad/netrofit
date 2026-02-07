import 'package:netrofit_result/netrofit_result.dart';
import 'package:test/test.dart';

void main() {
  group('ApiResult', () {
    group('success', () {
      test('creates successful result with data', () {
        final result = ApiResult<String>.success(
          data: 'test data',
          statusCode: 200,
        );

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.hasData, isTrue);
        expect(result.hasError, isFalse);
        expect(result.data, equals('test data'));
        expect(result.statusCode, equals(200));
      });

      test('when() calls success callback', () {
        final result = ApiResult<int>.success(data: 42, statusCode: 200);

        final output = result.when(
          success: (data) => 'Success: $data',
          failure: (error) => 'Failure: ${error.message}',
        );

        expect(output, equals('Success: 42'));
      });

      test('map() transforms data', () {
        final result = ApiResult<int>.success(data: 5, statusCode: 200);
        final mapped = result.map((data) => data * 2);

        expect(mapped.isSuccess, isTrue);
        expect(mapped.data, equals(10));
      });

      test('getOrElse() returns data', () {
        final result = ApiResult<String>.success(data: 'hello', statusCode: 200);
        expect(result.getOrElse('default'), equals('hello'));
      });

      test('getOrThrow() returns data', () {
        final result = ApiResult<String>.success(data: 'hello', statusCode: 200);
        expect(result.getOrThrow(), equals('hello'));
      });
    });

    group('failure', () {
      test('creates failed result with error', () {
        final error = NetworkError('No connection');
        final result = ApiResult<String>.failure(
          error: error,
          statusCode: 0,
        );

        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.hasData, isFalse);
        expect(result.hasError, isTrue);
        expect(result.error, equals(error));
        expect(result.isNetworkError, isTrue);
      });

      test('when() calls failure callback', () {
        final error = ClientError('Bad request', statusCode: 400);
        final result = ApiResult<int>.failure(error: error, statusCode: 400);

        final output = result.when(
          success: (data) => 'Success: $data',
          failure: (error) => 'Failure: ${error.message}',
        );

        expect(output, equals('Failure: Bad request'));
      });

      test('map() preserves error', () {
        final error = ServerError('Server error', statusCode: 500);
        final result = ApiResult<int>.failure(error: error, statusCode: 500);
        final mapped = result.map((data) => data * 2);

        expect(mapped.isSuccess, isFalse);
        expect(mapped.error, equals(error));
      });

      test('getOrElse() returns default value', () {
        final error = NetworkError('No connection');
        final result = ApiResult<String>.failure(error: error);
        expect(result.getOrElse('default'), equals('default'));
      });

      test('getOrThrow() throws error', () {
        final error = NetworkError('No connection');
        final result = ApiResult<String>.failure(error: error);
        expect(() => result.getOrThrow(), throwsA(isA<NetworkError>()));
      });
    });

    group('error type detection', () {
      test('detects network error', () {
        final result = ApiResult<String>.failure(
          error: NetworkError('No connection'),
        );
        expect(result.isNetworkError, isTrue);
        expect(result.isServerError, isFalse);
        expect(result.isClientError, isFalse);
      });

      test('detects server error', () {
        final result = ApiResult<String>.failure(
          error: ServerError('Internal error', statusCode: 500),
          statusCode: 500,
        );
        expect(result.isServerError, isTrue);
        expect(result.isNetworkError, isFalse);
        expect(result.isClientError, isFalse);
      });

      test('detects client error', () {
        final result = ApiResult<String>.failure(
          error: ClientError('Not found', statusCode: 404),
          statusCode: 404,
        );
        expect(result.isClientError, isTrue);
        expect(result.isNetworkError, isFalse);
        expect(result.isServerError, isFalse);
      });

      test('detects timeout error', () {
        final result = ApiResult<String>.failure(
          error: TimeoutError('Request timeout'),
        );
        expect(result.isTimeoutError, isTrue);
      });

      test('detects cancellation error', () {
        final result = ApiResult<String>.failure(
          error: CancellationError('User cancelled'),
        );
        expect(result.isCancelled, isTrue);
      });

      test('detects SSL error', () {
        final result = ApiResult<String>.failure(
          error: SslError('Certificate invalid'),
        );
        expect(result.isSslError, isTrue);
      });
    });

    group('fold', () {
      test('calls onSuccess for successful result', () {
        final result = ApiResult<int>.success(data: 42, statusCode: 200);
        final output = result.fold(
          (error) => 'Error: ${error.message}',
          (data) => 'Data: $data',
        );
        expect(output, equals('Data: 42'));
      });

      test('calls onFailure for failed result', () {
        final result = ApiResult<int>.failure(
          error: NetworkError('No connection'),
        );
        final output = result.fold(
          (error) => 'Error: ${error.message}',
          (data) => 'Data: $data',
        );
        expect(output, equals('Error: No connection'));
      });
    });
  });

  group('ApiError', () {
    test('NetworkError has correct message', () {
      final error = NetworkError('Connection failed');
      expect(error.message, equals('Connection failed'));
      expect(error.toString(), contains('NetworkError'));
    });

    test('ServerError includes status code', () {
      final error = ServerError('Internal error', statusCode: 500);
      expect(error.statusCode, equals(500));
      expect(error.toString(), contains('500'));
    });

    test('ClientError detects unauthorized', () {
      final error = ClientError('Unauthorized', statusCode: 401);
      expect(error.isUnauthorized, isTrue);
      expect(error.isForbidden, isFalse);
      expect(error.isNotFound, isFalse);
    });

    test('ClientError detects forbidden', () {
      final error = ClientError('Forbidden', statusCode: 403);
      expect(error.isForbidden, isTrue);
      expect(error.isUnauthorized, isFalse);
    });

    test('ClientError detects not found', () {
      final error = ClientError('Not found', statusCode: 404);
      expect(error.isNotFound, isTrue);
      expect(error.isUnauthorized, isFalse);
    });

    test('ClientError detects validation error', () {
      final error = ClientError('Validation failed', statusCode: 422);
      expect(error.isValidationError, isTrue);
    });

    test('TimeoutError includes timeout duration', () {
      final error = TimeoutError(
        'Request timeout',
        timeout: Duration(seconds: 30),
        type: TimeoutType.receive,
      );
      expect(error.timeout, equals(Duration(seconds: 30)));
      expect(error.type, equals(TimeoutType.receive));
    });

    test('CancellationError includes reason', () {
      final error = CancellationError('User navigated away');
      expect(error.reason, equals('User navigated away'));
    });

    test('SslError includes error type', () {
      final error = SslError(
        'Certificate pinning failed',
        type: SslErrorType.pinningFailed,
      );
      expect(error.type, equals(SslErrorType.pinningFailed));
    });

    test('ParseError includes raw data', () {
      final error = ParseError(
        'Failed to parse JSON',
        rawData: '{"invalid": json}',
        expectedType: Map,
      );
      expect(error.rawData, equals('{"invalid": json}'));
      expect(error.expectedType, equals(Map));
    });
  });
}
