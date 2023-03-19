
import 'dart:math';

import 'package:calendar/realm/schemas.dart';
import 'package:flutter/widgets.dart';

Alignment focalPointToAlignment(FocalPoint? focalPoint) {
  if (focalPoint == null) return Alignment.center;
  final x = focalPoint.x * 2 - 1;
  final y = focalPoint.y * 2 - 1;

  return Alignment(x, y);
}
