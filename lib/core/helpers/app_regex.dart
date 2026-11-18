// Small reusable validators for the login and sign-up forms.
//
// All methods are static: call them like AppRegex.isUsernameValid(text).

abstract final class AppRegex {
  // Matches ANY whitespace character (space, tab, enter...).
  static final RegExp _whitespace = RegExp(r'\s');

  // A valid username: at least 3 characters and no spaces inside.
  static bool isUsernameValid(String username) =>
      username.length >= 3 && !_whitespace.hasMatch(username);

  // A valid password: at least 6 characters.
  static bool isPasswordValid(String password) => password.length >= 6;

  // A valid email: something@something.something
  // (a simple shape check, not a full RFC parser.
  //  \\w = letters/digits/underscore, plus the dots and dashes
  //  emails often carry).
  static bool isEmailValid(String email) =>
      RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(email);

  // ---- Password checklist helpers (the live list on sign-up) ----
  //
  // isPasswordValid above stays the LOGIN rule (6+ characters) on
  // purpose: the demo account's password breaks three of the five
  // rules below and login must keep accepting it. These small
  // checks feed the LIVE checklist under the sign-up password field
  // - every keystroke re-runs them and ticks/unticks a row, so the
  // user SEES what their password is made of while typing.

  // A STRONG password: all five checklist rules at once (lowercase
  // + uppercase + number + special character + 6+ characters).
  // Only the SIGN-UP validator uses this - the checklist rows the
  // user watches are exactly the rules this one method demands, so
  // the guide and the gate can never disagree.
  static bool isStrongPasswordValid(String password) =>
      hasLowerCase(password) &&
      hasUpperCase(password) &&
      hasNumber(password) &&
      hasSpecialCharacter(password) &&
      hasMinLength(password);

  // Contains at least one lowercase letter (a-z)?
  static bool hasLowerCase(String password) =>
      RegExp(r'[a-z]').hasMatch(password);

  // Contains at least one uppercase letter (A-Z)?
  static bool hasUpperCase(String password) =>
      RegExp(r'[A-Z]').hasMatch(password);

  // Contains at least one number (0-9)?
  static bool hasNumber(String password) =>
      RegExp(r'\d').hasMatch(password);

  // Contains at least one special character (like ! @ # $...)?
  static bool hasSpecialCharacter(String password) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

  // At least 6 characters - the same rule as isPasswordValid.
  static bool hasMinLength(String password) => password.length >= 6;
}
