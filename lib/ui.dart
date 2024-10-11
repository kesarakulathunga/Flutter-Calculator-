import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';
import 'history.dart';

///IM 2021 090 Kezara Kulathunga


class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> {
  String displayValue = "0";
  static const int maxDisplayLength = 10;

  final HistoryManager _historyManager = HistoryManager();

  void onButtonPress(String value) {
    setState(() {
      if (value == "AC") {
        displayValue = "0"; // Reset display
      } else if (value == "C") {
        // Handle backspace
        displayValue = displayValue.length > 1
            ? displayValue.substring(0, displayValue.length - 1)
            : "0";
      } else if (value == "=") {
        // Evaluate expression and add to history
        String result = _evaluateExpression(displayValue);
        _historyManager.addToHistory("$displayValue = $result");
        displayValue = result;
      } else if (value == "√") {
        displayValue = _calculateSquareRoot(displayValue);
      } else if (value == "%") {
        displayValue = _calculatePercentage(displayValue);
      } else if (_isOperatorChar(value)) {
        if (_isOperatorChar(displayValue[displayValue.length - 1])) {
          displayValue =
              displayValue.substring(0, displayValue.length - 1) + value;
        } else {
          displayValue += value;
        }
      } else if (value == ".") {
        if (_canAddDecimal()) {
          displayValue += value;
        }
      } else {
        if (displayValue.length >= maxDisplayLength) {
          _showError(context, "Maximum input length reached!");
        } else {
          displayValue = displayValue == "0" ? value : displayValue + value;
        }
      }
    });
  }

  String _evaluateExpression(String expression) {
    try {
      // Check for division by zero
      if (expression.contains(RegExp(r'/0(\D|$)')) ||
          expression.startsWith("0/")) {
        return "Can't divide"; // Handle division by zero or zero divided by any number
      }

      final parser = Parser();
      final exp = parser.parse(expression);
      final contextModel = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, contextModel);

      // Format result to remove unnecessary decimals
      if (result == result.toInt()) {
        return result.toInt().toString();
      } else {
        return result.toStringAsFixed(5);
      }
    } catch (e) {
      return "Error"; // For other invalid inputs
    }
  }

  bool _isOperatorChar(String char) {
    return ["+", "-", "*", "/"].contains(char);
  }

  bool _canAddDecimal() {
    final parts = displayValue.split(RegExp(r'[+\-*/]'));
    final lastPart = parts.last;
    return !lastPart.contains('.');
  }

  String _calculateSquareRoot(String displayValue) {
    try {
      double num = double.parse(displayValue);
      if (num >= 0) {
        double result = num.sqrt();
        return result == result.toInt()
            ? result.toInt().toString()
            : result.toStringAsFixed(5);
      } else {
        return "Error"; // Negative square root is invalid
      }
    } catch (e) {
      return "Error";
    }
  }

  String _calculatePercentage(String displayValue) {
    try {
      double num = double.parse(displayValue);
      double result = num / 100;
      return result == result.toInt()
          ? result.toInt().toString()
          : result.toStringAsFixed(5);
    } catch (e) {
      return "Error";
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("History"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _historyManager.history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _historyManager.history[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _historyManager.clearHistory();
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text("Clear"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Calculator"),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "History") {
                _showHistoryDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "History",
                child: Text("History"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildButtonRow(["AC", "C", "√", "%"]),
          _buildButtonRow(["7", "8", "9", "/"]),
          _buildButtonRow(["4", "5", "6", "*"]),
          _buildButtonRow(["1", "2", "3", "-"]),
          _buildButtonRow(["0", ".", "+", "="]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) => _buildButton(label)).toList(),
    );
  }

  Widget _buildButton(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => onButtonPress(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: label == "="
                ? const Color(0xFFFF9800)
                : _isYellowButton(label)
                    ? const Color(0xFFFF9800)
                    : _isOperatorChar(label)
                        ? const Color(0xFFFF9800)
                        : Colors.white,
            foregroundColor:
                label == "=" || _isYellowButton(label) || _isOperatorChar(label)
                    ? Colors.white
                    : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  bool _isYellowButton(String label) {
    return ["AC", "C", "√", "%"].contains(label);
  }
}

extension on double {
  double sqrt() => pow(this, 0.5).toDouble();
}
