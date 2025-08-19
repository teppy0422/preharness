String formatCode(String value, String sep) {
  if (value.length == 8) {
    return "${value.substring(0, 4)}$sep${value.substring(4, 8)}";
  } else if (value.length == 10) {
    return "${value.substring(0, 4)}$sep${value.substring(4, 8)}$sep${value.substring(8, 10)}";
  }
  return value; // 8・10桁以外は元のまま返す
}
