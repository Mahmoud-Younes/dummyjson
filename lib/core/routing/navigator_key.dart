// The app's ONE door handle.
//
// A GlobalKey<NavigatorState> lets code that lives OUTSIDE the
// widget tree (the dependency-injection wiring that reacts to an
// expired session) reach the app's Navigator without any
// BuildContext. DummyJsonApp hands this key to its MaterialApp,
// so navigatorKey.currentState IS the app's navigator.

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
