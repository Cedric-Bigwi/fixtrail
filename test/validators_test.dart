import 'package:flutter_test/flutter_test.dart';
import 'package:fixtrail/core/validators.dart';

void main() {
  group('Validators.aluEmail', () {
    test('accepts ALU student and staff emails', () {
      expect(Validators.aluEmail('a.hindura@alustudent.com'), isNull);
      expect(Validators.aluEmail('teacher@alueducation.com'), isNull);
    });
    test('rejects other domains', () {
      expect(Validators.aluEmail('me@gmail.com'), isNotNull);
    });
    test('rejects empty and malformed input', () {
      expect(Validators.aluEmail(''), isNotNull);
      expect(Validators.aluEmail('not-an-email'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('requires 8+ characters', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('longenough1'), isNull);
    });
    test('confirm must match', () {
      expect(Validators.confirm('a', 'b'), isNotNull);
      expect(Validators.confirm('a', 'a'), isNull);
    });
  });

  test('minLength validator', () {
    expect(Validators.minLength('abc', 5, 'Title'), isNotNull);
    expect(Validators.minLength('abcde', 5, 'Title'), isNull);
  });
}
