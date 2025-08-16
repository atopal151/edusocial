  void printFullText(String text) {
    const int chunkSize = 800; // 800 karakterlik parçalar
    for (int i = 0; i < text.length; i += chunkSize) {
      print(text.substring(
          i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
  }
