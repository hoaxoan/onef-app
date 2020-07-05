class StringUtil {
  static bool isEmpty(String value) {
    if (value == null || value.trim().length == 0 || value == "null")
      return true;
    return false;
  }
}
