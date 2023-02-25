extension ListUtils on List {
  String get toOxfordListString {
    var newList = List.from(this);
    if (newList.length < 3) return newList.join(' and ');
    final lastItem = newList.removeAt(newList.length - 1);
    return '${newList.join(', ')}, and $lastItem';
  }
}
