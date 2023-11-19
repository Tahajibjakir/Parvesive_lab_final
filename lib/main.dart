import 'package:all_in_one/calculator/constants.dart';
import 'package:all_in_one/calculator/keyboard.dart';
import 'package:all_in_one/calculator/scientificCalculator.dart';
import 'package:all_in_one/weather.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    PortfolioPage(),
    QuizApp(),
    ScientificCalculator(),
    WeatherPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("My App"),
          backgroundColor: Color.fromARGB(255, 212, 27, 212)),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.portrait),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'ScientificCalculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Weather',
          ),
        ],
      ),
    );
  }
}

String firstOperand = '0';
String secondOperand = '';
String operators = '';
String equation = '0';
String result = '';

class ScientificCalculator extends StatefulWidget {
  @override
  _ScientificCalculatorState createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  bool scientificKeyboard = false;

  @override
  void initState() {
    super.initState();
    initialise();
  }

  String expression = '';
  double equationFontSize = 35.0;
  double resultFontSize = 25.0;

  void initialise() {}

  void _onPressed({String? buttonText}) {
    if (buttonText == null) {
      return;
    }
    switch (buttonText) {
      case EXCHANGE_CALCULATOR:
        setState(() {
          scientificKeyboard = !scientificKeyboard;
          _clear();
        });
        break;
      case CLEAR_ALL_SIGN:
        setState(() {
          _clear();
        });
        break;
      case DEL_SIGN:
        setState(() {
          if (scientificKeyboard) {
            equationFontSize = 35.0;
            resultFontSize = 25.0;
            equation = equation.substring(0, equation.length - 1);
            if (equation == '') equation = '0';
          } else {
            equationFontSize = 35.0;
            resultFontSize = 25.0;
            if (operators == '') {
              firstOperand = firstOperand.substring(0, firstOperand.length - 1);
              if (firstOperand == '') firstOperand = '0';
            } else {
              secondOperand =
                  secondOperand.substring(0, secondOperand.length - 1);
              if (secondOperand == '') secondOperand = '';
            }
          }
        });
        break;
      case EQUAL_SIGN:
        if (result == '') {
          scientificKeyboard ? _scientificResult() : _simpleResult();
        }
        break;
      default:
        scientificKeyboard
            ? _scientificOperands(buttonText)
            : _simpleOperands(buttonText);
    }
  }

  void _clear() {
    firstOperand = '0';
    secondOperand = '';
    operators = '';
    equation = '0';
    result = '';
    expression = '';
    equationFontSize = 35.0;
    resultFontSize = 25.0;
  }

  void _simpleOperands(value) {
    setState(() {
      equationFontSize = 35.0;
      resultFontSize = 25.0;
      switch (value) {
        case MODULAR_SIGN:
          if (result != '') {
            firstOperand = (double.parse(result) / 100).toString();
          } else if (operators != '') {
            if (secondOperand != "") {
              if (operators == PLUS_SIGN || operators == MINUS_SIGN) {
                secondOperand = ((double.parse(firstOperand) / 100) *
                        double.parse(secondOperand))
                    .toString();
              } else if (operators == MULTIPLICATION_SIGN ||
                  operators == DIVISION_SIGN) {
                secondOperand = (double.parse(secondOperand) / 100).toString();
              }
            }
          } else {
            if (firstOperand != "") {
              firstOperand = (double.parse(firstOperand) / 100).toString();
            }
          }
          if (firstOperand.toString().endsWith(".0")) {
            firstOperand =
                int.parse(firstOperand.toString().replaceAll(".0", ""))
                    .toString();
          }
          if (secondOperand.toString().endsWith(".0")) {
            secondOperand =
                int.parse(secondOperand.toString().replaceAll(".0", ""))
                    .toString();
          }
          break;
        case DECIMAL_POINT_SIGN:
          if (result != '') _clear();
          if (operators != '') {
            if (!secondOperand.toString().contains(".")) {
              if (secondOperand == "") {
                secondOperand = ".";
              } else {
                secondOperand += ".";
              }
            }
          } else {
            if (!firstOperand.toString().contains(".")) {
              if (firstOperand == "") {
                firstOperand = ".";
              } else {
                firstOperand += ".";
              }
            }
          }
          break;
        case PLUS_SIGN:
        case MINUS_SIGN:
        case MULTIPLICATION_SIGN:
        case DIVISION_SIGN:
          if (firstOperand == '0') {
            if (value == MINUS_SIGN) firstOperand = MINUS_SIGN;
          } else if (secondOperand == '') {
            operators = value;
          } else {
            _simpleResult();
            firstOperand = result;
            operators = value;
            secondOperand = '';
            result = '';
          }
          break;
        default:
          if (operators != '') {
            secondOperand += value;
          } else {
            firstOperand == ZERO ? firstOperand = value : firstOperand += value;
          }
      }
    });
  }

  void _simpleResult() {
    setState(() {
      equationFontSize = 25.0;
      resultFontSize = 35.0;
      expression = firstOperand + operators + secondOperand;
      expression = expression.replaceAll('×', '*');
      expression = expression.replaceAll('÷', '/');
      try {
        Parser p = Parser();
        Expression exp = p.parse(expression);
        ContextModel cm = ContextModel();
        result = '${exp.evaluate(EvaluationType.REAL, cm)}';
        if (result == 'NaN') result = CALCULATE_ERROR;
        _isIntResult();
      } catch (e) {
        result = CALCULATE_ERROR;
      }
    });
  }

  void _scientificOperands(value) {
    setState(() {
      equationFontSize = 35.0;
      resultFontSize = 25.0;
      if (value == POWER_SIGN) value = '^';
      if (value == MODULAR_SIGN) value = ' mód ';
      if (value == ARCSIN_SIGN) value = 'arcsin';
      if (value == ARCCOS_SIGN) value = 'arccos';
      if (value == ARCTAN_SIGN) value = 'arctan';
      if (value == DECIMAL_POINT_SIGN) {
        if (equation[equation.length - 1] == DECIMAL_POINT_SIGN) return;
      }
      equation == ZERO ? equation = value : equation += value;
    });
  }

  void _scientificResult() {
    setState(() {
      equationFontSize = 25.0;
      resultFontSize = 35.0;
      expression = equation;
      expression = expression.replaceAll('×', '*');
      expression = expression.replaceAll('÷', '/');
      expression = expression.replaceAll(PI, '3.1415926535897932');
      expression = expression.replaceAll(E_NUM, 'e^1');
      expression = expression.replaceAll(SQUARE_ROOT_SIGN, 'sqrt');
      expression = expression.replaceAll(POWER_SIGN, '^');
      expression = expression.replaceAll(ARCSIN_SIGN, 'arcsin');
      expression = expression.replaceAll(ARCCOS_SIGN, 'arccos');
      expression = expression.replaceAll(ARCTAN_SIGN, 'arctan');
      expression = expression.replaceAll(LG_SIGN, 'log');
      expression = expression.replaceAll(' mód ', MODULAR_SIGN);
      try {
        Parser p = Parser();
        Expression exp = p.parse(expression);
        ContextModel cm = ContextModel();
        result = '${exp.evaluate(EvaluationType.REAL, cm)}';
        if (result == 'NaN') result = CALCULATE_ERROR;
        _isIntResult();
      } catch (e) {
        result = CALCULATE_ERROR;
      }
    });
  }

  _isIntResult() {
    if (result.toString().endsWith(".0")) {
      result = int.parse(result.toString().replaceAll(".0", "")).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scientific Calculator'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(child: Container()),
            Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: SingleChildScrollView(
                child: !scientificKeyboard
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          _inOutExpression(firstOperand, equationFontSize),
                          operators != ''
                              ? _inOutExpression(operators, equationFontSize)
                              : Container(),
                          secondOperand != ''
                              ? _inOutExpression(
                                  secondOperand, equationFontSize)
                              : Container(),
                          result != ''
                              ? _inOutExpression(result, resultFontSize)
                              : Container(),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          _inOutExpression(equation, equationFontSize),
                          result != ''
                              ? _inOutExpression(result, resultFontSize)
                              : Container(),
                        ],
                      ),
              ),
            ),
            Keyboard(
              keyboardSigns: (scientificKeyboard)
                  ? keyboardScientificCalculator
                  : keyboardSingleCalculator,
              onTap: _onPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _inOutExpression(text, size) {
    return SingleChildScrollView(
      reverse: true,
      scrollDirection: Axis.horizontal,
      child: Text(
        text is double ? text.toStringAsFixed(2) : text.toString(),
        style: TextStyle(
          color: Color.fromARGB(255, 68, 68, 68),
          fontSize: size,
        ),
        textAlign: TextAlign.end,
      ),
    );
  }
}

class PortfolioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tahajib's Portfolio"),
      ),
      drawer: PortfolioDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green, Colors.teal],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/images/tahajib.png'),
              ),
              SizedBox(height: 15),
              ProfileItem(title: 'Name', value: 'Tahajib Jakir Khan'),
              ProfileItem(title: 'Study', value: 'Bachelor in CSE'),
              ProfileItem(title: 'University', value: 'DIU'),
              ProfileItem(title: 'Present Address', value: 'Dhaka'),
              ProfileItem(title: 'Speciality in', value: 'Data Science'),
              ProfileItem(
                title: 'About',
                value:
                    'I am a CSE engineer and I want to work in Data science. I love cricket as a sport.',
                textAlign: TextAlign.center,
              ),
              ProfileItem(
                  title: 'Facebook',
                  value: 'https://web.facebook.com/tahajib.jakir'),
              ProfileItem(
                  title: 'Linked-in',
                  value: 'https://www.linkedin.com/tahajib jakir'),
              ProfileItem(
                  title: 'Github', value: 'https://github.com/Tahajibjakir'),
            ],
          ),
        ),
      ),
    );
  }
}

class PortfolioDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Name'),
            onTap: () {
              // Navigate to the respective section
            },
          ),
          ListTile(
            title: Text('Study'),
            onTap: () {
              // Navigate to the respective section
            },
          ),
          ListTile(
            title: Text('University'),
            onTap: () {
              // Navigate to the respective section
            },
          ),
          ListTile(
            title: Text('Present Address'),
            onTap: () {
              // Navigate to the respective section
            },
          ),
          ListTile(
            title: Text('Speciality in'),
            onTap: () {
              // Navigate to the respective section
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              // Navigate to the respective section
            },
          ),
        ],
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String title;
  final String value;
  final TextAlign textAlign;

  ProfileItem({
    required this.title,
    required this.value,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: textAlign,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  int _currentQuestionIndex = 0;
  List<Question> _questions = [
    Question(
      'What is the largest country in the world?',
      ['USA', 'Australia', 'Russia', 'Brazil'],
      'Russia',
    ),
    Question(
      'Which country has the most powerful military?',
      ['USA', 'Russia', 'China', 'France'],
      'USA',
    ),
    Question(
      'What is the capital of France?',
      ['Berlin', 'London', 'Madrid', 'Paris'],
      'Paris',
    ),
    Question(
      'Which planet is known as the Red Planet?',
      ['Earth', 'Mars', 'Venus', 'Jupiter'],
      'Mars',
    ),
    Question(
      'Which gas do plants absorb from the atmosphere?',
      ['Carbon dioxide', 'Oxygen', 'Nitrogen', 'Hydrogen'],
      'Carbon dioxide',
    ),
    Question(
      'Who wrote the play "Romeo and Juliet"?',
      ['Charles Dickens', 'William Shakespeare', 'Jane Austen', 'Mark Twain'],
      'William Shakespeare',
    ),
    Question(
      'What is the largest mammal on Earth?',
      ['Elephant', 'Giraffe', 'Blue whale', 'Lion'],
      'Blue whale',
    ),
    Question(
      'Which country is known as the Land of the Rising Sun?',
      ['China', 'South Korea', 'Japan', 'Vietnam'],
      'Japan',
    ),
    Question(
      'What is the chemical symbol for gold?',
      ['Au', 'Ag', 'Fe', 'Cu'],
      'Au',
    ),
    Question(
      'Which gas is responsible for the ozone layer?',
      ['Carbon dioxide', 'Oxygen', 'Chlorofluorocarbon', 'Methane'],
      'Chlorofluorocarbon',
    ),
    // Additional questions:
    Question(
      'What is the largest planet in our solar system?',
      ['Earth', 'Mars', 'Venus', 'Jupiter'],
      'Jupiter',
    ),
    Question(
      'Which gas makes up the majority of Earth\'s atmosphere?',
      ['Carbon dioxide', 'Oxygen', 'Nitrogen', 'Hydrogen'],
      'Nitrogen',
    ),
    Question(
      'Who is known as the father of modern physics?',
      ['Albert Einstein', 'Isaac Newton', 'Stephen Hawking', 'Galileo Galilei'],
      'Albert Einstein',
    ),
    Question(
      'What is the smallest prime number?',
      ['1', '2', '3', '4'],
      '2',
    ),
    Question(
      'Which gas is commonly used in balloons for inflation?',
      ['Oxygen', 'Helium', 'Nitrogen', 'Carbon dioxide'],
      'Helium',
    ),
    Question(
      'Which planet is known as the "Morning Star" or "Evening Star"?',
      ['Mars', 'Venus', 'Jupiter', 'Saturn'],
      'Venus',
    ),
    Question(
      'What is the chemical symbol for water?',
      ['H2O', 'CO2', 'O2', 'N2'],
      'H2O',
    ),
    Question(
      'Which planet is often referred to as the "Red Planet"?',
      ['Earth', 'Mars', 'Venus', 'Jupiter'],
      'Mars',
    ),
  ];

  String _answerResult = '';
  int _correctAnswers = 0;

  void _checkAnswer(String selectedAnswer) {
    if (_questions[_currentQuestionIndex].correctAnswer == selectedAnswer) {
      setState(() {
        _answerResult = 'Correct';
        _correctAnswers++;
      });
    } else {
      setState(() {
        _answerResult = 'Wrong';
      });
    }

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _answerResult = '';
        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
        } else {
          // End of the quiz, show results or do something
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.teal],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              SizedBox(height: 20.0),
              Text(
                _questions[_currentQuestionIndex].questionText,
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
              SizedBox(height: 20.0),
              Column(
                children: _questions[_currentQuestionIndex]
                    .options
                    .map(
                      (option) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0), // Create gap between options
                        child: ElevatedButton(
                          onPressed: () {
                            if (_answerResult.isEmpty) {
                              _checkAnswer(option);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(option),
                              if (_answerResult.isNotEmpty)
                                Icon(
                                  _questions[_currentQuestionIndex]
                                              .correctAnswer ==
                                          option
                                      ? Icons.check
                                      : Icons.close,
                                  color: _questions[_currentQuestionIndex]
                                              .correctAnswer ==
                                          option
                                      ? Colors.green
                                      : Colors.red,
                                ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.pink, // Change button color to pink
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 20.0),
              Text(
                _answerResult,
                style: TextStyle(
                  fontSize: 20.0,
                  color: _answerResult == 'Wrong'
                      ? Colors.red
                      : _answerResult == 'Correct'
                          ? Colors.green
                          : Colors.white,
                ),
              ),
              SizedBox(height: 20.0),
              if (_answerResult.isEmpty)
                ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex < _questions.length - 1) {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    } else {
                      // End of the quiz, show results or do something
                    }
                  },
                  child: Text('Next Question'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                ),
              SizedBox(height: 20.0),
              Text(
                'Correct Answers: $_correctAnswers/${_questions.length}',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  Question(this.questionText, this.options, this.correctAnswer);
}
