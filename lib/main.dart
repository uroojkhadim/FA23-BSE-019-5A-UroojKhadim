import 'package:flutter/material.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      theme: ThemeData.dark(),
      home: Calculator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String display = "0";
  String currentInput = "";
  double result = 0;
  String lastOperation = "";
  bool shouldResetDisplay = false;

  void onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == "CLEAR") {
        display = "0";
        currentInput = "";
        result = 0;
        lastOperation = "";
        shouldResetDisplay = false;
      }
      else if (buttonText == "+" || buttonText == "-" ||
          buttonText == "X" || buttonText == "/") {
        if (currentInput.isNotEmpty) {
          if (lastOperation.isEmpty) {
            result = double.parse(currentInput);
          } else {
            calculateResult();
          }
          lastOperation = buttonText;
          shouldResetDisplay = true;
        }
      }
      else if (buttonText == "=") {
        if (currentInput.isNotEmpty && lastOperation.isNotEmpty) {
          calculateResult();
          lastOperation = "";
          shouldResetDisplay = true;
        }
      }
      else if (buttonText == ".") {
        if (shouldResetDisplay) {
          currentInput = "0";
          shouldResetDisplay = false;
        }
        if (!currentInput.contains(".")) {
          currentInput = currentInput.isEmpty ? "0." : currentInput + ".";
          display = currentInput;
        }
      }
      else {
        if (shouldResetDisplay) {
          currentInput = "";
          shouldResetDisplay = false;
        }
        currentInput = currentInput + buttonText;
        display = currentInput;
      }
    });
  }

  void calculateResult() {
    double currentValue = double.parse(currentInput);

    switch (lastOperation) {
      case "+":
        result += currentValue;
        break;
      case "-":
        result -= currentValue;
        break;
      case "X":
        result *= currentValue;
        break;
      case "/":
        if (currentValue != 0) {
          result /= currentValue;
        } else {
          display = "Error";
          return;
        }
        break;
    }

    // Format the result
    String formattedResult = result.toString();
    if (formattedResult.endsWith(".0")) {
      formattedResult = formattedResult.substring(0, formattedResult.length - 2);
    }

    display = formattedResult;
    currentInput = formattedResult;
  }

  Widget buildButton(String buttonText) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(24.0),
            backgroundColor: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () => onButtonPressed(buttonText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Calculator"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 12.0,
              ),
              child: Text(
                display,
                style: TextStyle(
                  fontSize: 72.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.white),
            ),
            Column(
              children: [
                Row(children: [
                  buildButton("7"),
                  buildButton("8"),
                  buildButton("9"),
                  buildButton("/"),
                ]),
                Row(children: [
                  buildButton("4"),
                  buildButton("5"),
                  buildButton("6"),
                  buildButton("X"),
                ]),
                Row(children: [
                  buildButton("1"),
                  buildButton("2"),
                  buildButton("3"),
                  buildButton("-"),
                ]),
                Row(children: [
                  buildButton("0"),
                  buildButton("."),
                  buildButton("="),
                  buildButton("+"),
                ]),
                Row(children: [
                  buildButton("CLEAR"),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}