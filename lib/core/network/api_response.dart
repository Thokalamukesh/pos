Map<String, dynamic> unwrapDataMap(Object? responseData) {
  if (responseData is Map<String, dynamic>) {
    final data = responseData['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return responseData;
  }
  return const {};
}
