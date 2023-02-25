import 'package:rake/rake.dart';

final rake = Rake();

extension StringUtils on String {
  List<String> get getTags {
    return rake.rank(this, minChars: 3, minFrequency: 1);
  }

  String getInitials() =>
      isNotEmpty ? trim().split(' ').map((l) => l[0]).take(2).join() : '';
}
