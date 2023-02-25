import 'dart:developer';

import 'package:flutter/material.dart';

const BASE_URL = 'https://imagedelivery.net/DhyPTPLE_5stzZ0kW1Ypiw/';

String getCloudflareImageUrl(String imageId, {int width = 400}) {
  final q = 'w=$width';
  return '$BASE_URL$imageId/$q';
}
