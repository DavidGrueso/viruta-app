class MockAPI {
  static Future<Map<String, dynamic>> getStatus() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      "temp": 215.5,
      "usageMin": 87,
      "connected": true
    };
  }
}
