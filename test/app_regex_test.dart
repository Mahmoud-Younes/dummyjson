// Unit tests for the pure validators in AppRegex.
// No mocks, no internet: these are plain input -> bool checks.

import 'package:flutter_test/flutter_test.dart';

import 'package:dummyjson/core/helpers/app_regex.dart';

void main() {
  group('AppRegex.isUsernameValid', () {
    test('accepts a normal username', () {
      expect(AppRegex.isUsernameValid('emilys'), isTrue);
    });

    test('accepts exactly 3 characters (minimum length)', () {
      expect(AppRegex.isUsernameValid('abc'), isTrue);
    });

    test('rejects a too-short username', () {
      expect(AppRegex.isUsernameValid('ab'), isFalse);
    });

    test('rejects an empty username', () {
      expect(AppRegex.isUsernameValid(''), isFalse);
    });

    test('rejects a username with a space inside', () {
      expect(AppRegex.isUsernameValid('emily s'), isFalse);
    });

    test('rejects a username made only of whitespace', () {
      expect(AppRegex.isUsernameValid('   '), isFalse);
    });

    test('accepts usernames with digits and dots', () {
      expect(AppRegex.isUsernameValid('user.123'), isTrue);
    });
  });

  group('AppRegex.isPasswordValid', () {
    test('accepts a normal password', () {
      expect(AppRegex.isPasswordValid('emilyspass'), isTrue);
    });

    test('accepts exactly 6 characters (minimum length)', () {
      expect(AppRegex.isPasswordValid('123456'), isTrue);
    });

    test('rejects a too-short password', () {
      expect(AppRegex.isPasswordValid('12345'), isFalse);
    });

    test('rejects an empty password', () {
      expect(AppRegex.isPasswordValid(''), isFalse);
    });

    test('accepts passwords with spaces (only length matters)', () {
      expect(AppRegex.isPasswordValid('a b c d'), isTrue);
    });
  });

  group('AppRegex.isEmailValid', () {
    test('accepts a normal email', () {
      expect(AppRegex.isEmailValid('ovi99@test.com'), isTrue);
    });

    test('accepts an email with dots and a plus in the local part', () {
      expect(AppRegex.isEmailValid('first.last+tag@mail.co'), isTrue);
    });

    test('accepts a subdomain email', () {
      expect(AppRegex.isEmailValid('a@mail.example.com'), isTrue);
    });

    test('rejects a missing @', () {
      expect(AppRegex.isEmailValid('not-an-email'), isFalse);
    });

    test('rejects a missing domain', () {
      expect(AppRegex.isEmailValid('user@'), isFalse);
    });

    test('rejects a missing dot in the domain', () {
      expect(AppRegex.isEmailValid('user@server'), isFalse);
    });

    test('rejects an empty email', () {
      expect(AppRegex.isEmailValid(''), isFalse);
    });
  });

  group('AppRegex password checklist helpers', () {
    test('hasLowerCase / hasUpperCase spot the letter cases', () {
      expect(AppRegex.hasLowerCase('abc'), isTrue);
      expect(AppRegex.hasLowerCase('ABC'), isFalse);
      expect(AppRegex.hasUpperCase('ABC'), isTrue);
      expect(AppRegex.hasUpperCase('abc'), isFalse);
    });

    test('hasNumber / hasSpecialCharacter spot digits and symbols', () {
      expect(AppRegex.hasNumber('a1'), isTrue);
      expect(AppRegex.hasNumber('ab'), isFalse);
      expect(AppRegex.hasSpecialCharacter('a!b'), isTrue);
      expect(AppRegex.hasSpecialCharacter('ab1'), isFalse);
    });

    test('hasMinLength asks for 6 characters (the same rule as login)', () {
      expect(AppRegex.hasMinLength('123456'), isTrue);
      expect(AppRegex.hasMinLength('12345'), isFalse);
    });
  });
}
