import 'package:flutter/material.dart';

class Question {
  final String userId;
  final String question;

  Question({required this.userId, required this.question});
}

class UserQAScreen extends StatefulWidget {
  @override
  _UserQAScreenState createState() => _UserQAScreenState();
}

class _UserQAScreenState extends State<UserQAScreen> {
  final TextEditingController _questionController = TextEditingController();
  List<Question> questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Q&A'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Question ${index + 1}: ${questions[index].question}'),
                  subtitle: Text('User ID: ${questions[index].userId}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(hintText: 'Ask a question...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    askQuestion('dummyUserId', _questionController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void askQuestion(String userId, String question) {
    setState(() {
      questions.add(Question(userId: userId, question: question));
      _questionController.clear();
    });
  }
}

void main() {
  runApp(
    MaterialApp(
      home: UserQAScreen(),
    ),
  );
}
