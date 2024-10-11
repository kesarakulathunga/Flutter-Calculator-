// history.dart

class HistoryManager {
  // List to store the history of calculations
  final List<String> _history = [];

  // Get the current history
  List<String> get history => _history;

  // Add a calculation to the history
  void addToHistory(String calculation) {
    if (_history.length == 10) {
      // Keep only the last 10 calculations
      _history.removeAt(0);
    }
    _history.add(calculation);
  }

  // Clear all history
  void clearHistory() {
    _history.clear();
  }
}

///IM 2021 090 Kezara Kulathunga
