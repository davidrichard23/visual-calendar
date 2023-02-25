extension IntUtils on int {
  String toOrdinalString() {
    if ((this < 0)) {
      //here you change the range
      throw Exception('Invalid number: Number must be a positive number');
    }
    if (this == 0) {
      return '0';
    }

    String stringValue = toString();

    switch (stringValue[stringValue.length - 1]) {
      case '1':
        return '${stringValue}st';
      case '2':
        return '${stringValue}nd';
      case '3':
        return '${stringValue}rd';
      default:
        return '${stringValue}th';
    }
  }
}
