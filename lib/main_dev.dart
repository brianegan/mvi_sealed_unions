import 'dart:io';

import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:mvi_sealed_unions/main.dart' as app;

void main() {
  HttpOverrides.global = StethoHttpOverrides();

  app.main();
}
