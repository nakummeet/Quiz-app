import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  final List result;

  const ReviewScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Answers")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: result.length,
        itemBuilder: (context, index) {
          final q = result[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// QUESTION
                  Text(
                    "${index + 1}. ${q["question"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// OPTIONS
                  ...List.generate(q["options"].length, (i) {
                    final option = q["options"][i];

                    bool isCorrect = i == q["correctAnswer"];
                    bool isSelected = i == q["selected"];

                    Color color = Colors.grey.shade200;

                    if (isCorrect) {
                      color = Colors.green.shade200;
                    } else if (isSelected) {
                      color = Colors.red.shade200;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(option),
                    );
                  }),

                  const SizedBox(height: 8),

                  /// RESULT
                  Text(
                    q["isCorrect"] ? "Correct ✅" : "Wrong ❌",
                    style: TextStyle(
                      color:
                      q["isCorrect"] ? Colors.green : Colors.red,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}