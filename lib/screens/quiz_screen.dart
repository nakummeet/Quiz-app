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

  List questions = [];
  Map<String, int> selectedAnswers = {};
  List<Map<String, dynamic>> answers = [];

  bool isLoading = true;

  int timeLeft = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchTest();
  }

  void fetchTest() async {
    try {
      final data = await ApiService.getTestById(widget.testId);

      setState(() {
        questions = data["questions"] ?? [];
        isLoading = false;
      });

      if (questions.isNotEmpty) startTimer();
    } catch (e) {
      showError("Failed to load test");
    }
  }

  void startTimer() {
    timer?.cancel();

    if (questions.isEmpty || currentQuestion >= questions.length) return;

    timeLeft = questions[currentQuestion]["time"] ?? 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        nextQuestion();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void selectAnswer(int index) {
    final qId = questions[currentQuestion]["_id"];

    setState(() {
      selectedAnswers[qId] = index;
    });

    answers.removeWhere((a) => a["questionId"] == qId);

    answers.add({
      "questionId": qId,
      "selected": index,
    });
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() => currentQuestion++);
      startTimer();
    } else {
      submitTest();
    }
  }

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
            score: result["score"] ?? 0,
            total: result["total"] ?? 0,
            result: result["result"] ?? [],
          ),
        ),
      );
    } catch (e) {
      showError("Submission failed");
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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

    /// 🔥 FIX CRASH
    if (questions.isEmpty || currentQuestion >= questions.length) {
      return const Scaffold(
        body: Center(child: Text("No questions available")),
      );
    }

    final q = questions[currentQuestion];
    final options = List<String>.from(q["options"] ?? []);
    final qId = q["_id"];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// TIMER
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "⏰ $timeLeft s",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              /// QUESTION INDEX
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(questions.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == currentQuestion
                          ? Colors.white
                          : Colors.transparent,
                      border: Border.all(color: Colors.white),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: index == currentQuestion
                            ? Colors.blue
                            : Colors.white,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              /// QUESTION CARD
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        q["question"] ?? "",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),

                      /// OPTIONS
                      ...List.generate(options.length, (index) {
                        final isSelected =
                            selectedAnswers[qId] == index;

                        return GestureDetector(
                          onTap: () => selectAnswer(index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    options[index],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const Spacer(),

                      /// NEXT BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: nextQuestion,
                          child: Text(
                            currentQuestion == questions.length - 1
                                ? "Submit"
                                : "Next",
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}