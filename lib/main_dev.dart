import 'dart:io';

import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:sealed_union_demo/main.dart' as app;

void main() {
  HttpOverrides.global = StethoHttpOverrides();

  app.main();
}
