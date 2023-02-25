import 'dart:math';

String generateInviteToken() {
  var random = Random.secure();
  const chars = 'abcdefghijklmnopqrstuvwxyz';
  var token = '';

  for (var i = 0; i < 8; i++) {
    token += chars[random.nextInt(chars.length)];
  }

  return token;
}
