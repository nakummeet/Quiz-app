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
        title: Text("${widget.topic} Tests"),backgroundColor: Colors.blue
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