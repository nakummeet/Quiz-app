# AIBridge — test
> Generated on 5/5/2026, 1:28:18 AM  |  Mode: 📄 Full Code
> Paste into ChatGPT, Claude, Gemini, or any AI tool.

---

## 📋 Project Overview

**test** is a software project.

**test** is a  project.

## 🏗 Core Architecture

- Static project — no server-side architecture detected

## 🔄 Business Flow

Client sends request → Middleware validates → Controller processes → Response returned

## 🛠 Tech Stack


## 📎 Selected Files — Full Code

### lib/screens/quiz_screen.dart  _(209 lines)_
```
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String testId;

  const QuizScreen({super.key, required this.testId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int selectedOption = -1;

  List questions = [];
  List<Map<String, dynamic>> answers = [];

  bool isLoading = true;

  int timeLeft = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchTest();
  }

  /// 🔹 FETCH TEST + QUESTIONS
  void fetchTest() async {
    try {
      final data = await ApiService.getTestById(widget.testId);

      setState(() {
        questions = data["questions"];
        isLoading = false;
      });

      startTimer();
    } catch (e) {
      print(e);
    }
  }

  /// 🔹 TIMER
  void startTimer() {
    timer?.cancel();

    // take from backend if exists
    timeLeft = questions[currentQuestion]["time"] ?? 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        nextQuestion();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  /// 🔹 SELECT ANSWER
  void selectAnswer(int index) {
    setState(() {
      selectedOption = index;
    });

    answers.removeWhere(
          (a) => a["questionId"] == questions[currentQuestion]["_id"],
    );

    answers.add({
      "questionId": questions[currentQuestion]["_id"],
      "selected": index,
    });
  }

  /// 🔹 NEXT
  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedOption = -1;
      });
      startTimer();
    } else {
      submitTest();
    }
  }

  /// 🔹 PREVIOUS
  void previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
        selectedOption = -1;
      });
      startTimer();
    }
  }

  /// 🔹 SUBMIT
  void submitTest() async {
    timer?.cancel();

    try {
      final result = await ApiService.submitAnswers(
        testId: widget.testId,
        answers: answers,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: result["score"],
            total: result["total"],
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = questions[currentQuestion];
    final options = List<String>.from(q["options"]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Question ${currentQuestion + 1}/${questions.length}"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(child: Text("$timeLeft s")),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              q["question"],
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            /// OPTIONS
            ...List.generate(options.length, (index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(options[index]),
                  leading: Radio<int>(
                    value: index,
                    groupValue: selectedOption,
                    onChanged: (val) => selectAnswer(val!),
                  ),
                ),
              );
            }),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: previousQuestion,
                  child: const Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: nextQuestion,
                  child: Text(
                    currentQuestion == questions.length - 1
                        ? "Submit"
                        : "Next",
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
```

### lib/screens/result_screen.dart  _(76 lines)_
```
import 'package:flutter/material.dart';
import 'topic_selection_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Center(
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Your Score",
                  style: TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 10),

                Text(
                  "$score / $total",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "$percentage %",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TopicSelectionScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  child: const Text("Go Home"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### lib/screens/test_list_screen.dart  _(141 lines)_
```
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';

class TestListScreen extends StatefulWidget {
  final String topic;

  const TestListScreen({super.key, required this.topic});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  List tests = [];
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchTests();
  }

  /// 🔹 FETCH TESTS FROM BACKEND
  Future<void> fetchTests() async {
    try {
      final data = await ApiService.getTests(widget.topic);

      setState(() {
        tests = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load tests";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.topic} Tests"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: isLoading
            ? const Center(child: CircularProgressIndicator())

            : error.isNotEmpty
            ? Center(child: Text(error))

            : tests.isEmpty
            ? const Center(child: Text("No tests available"))

            : ListView.builder(
          itemCount: tests.length,
          itemBuilder: (context, index) {
            final test = tests[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    /// TEST TITLE
                    Text(
                      test["title"] ?? "No Title",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// QUESTION COUNT
                    Text(
                      "${test["totalQuestions"] ?? 0} Questions",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// START BUTTON
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          final testId = test["_id"];

                          if (testId == null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Invalid test data"),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  QuizScreen(
                                    testId: testId,
                                  ),
                            ),
                          );
                        },
                        child: const Text("Start Test"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

### lib/screens/topic_selection_screen.dart  _(56 lines)_
```
import 'package:flutter/material.dart';
import 'test_list_screen.dart';

class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({super.key});

  final List<String> topics = const [
    "OOP",
    "DBMS",
    "DSA",
    "C",
    "Java"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Topic")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: topics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TestListScreen(topic: topics[index]),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    topics[index],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

### lib/services/api_service.dart  _(53 lines)_
```
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://quiz-backend-sand.vercel.app/api";


  static Future<List<dynamic>> getTests(String topic) async {
    final response = await http.get(
      Uri.parse("$baseUrl/tests?topic=$topic"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load tests");
    }
  }


  static Future<Map<String, dynamic>> getTestById(String id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/test/$id"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load test");
    }
  }


  static Future<Map<String, dynamic>> submitAnswers({
    required String testId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/question/submit"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "testId": testId,
        "answers": answers,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Submission failed");
    }
  }
}
```

### lib/main.dart  _(23 lines)_
```
import 'package:flutter/material.dart';
import 'screens/topic_selection_screen.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const TopicSelectionScreen(),
    );
  }
}
```

---
_Generated by AIBridge — 📄 Full Code mode_