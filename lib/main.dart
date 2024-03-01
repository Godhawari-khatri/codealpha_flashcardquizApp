import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(FlashcardQuizApp());
}

class Flashcard {
  String question;
  String answer;

  Flashcard({required this.question, required this.answer});
}

class FlashcardService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Flashcard> getFlashcards() {
    // Mock data for demonstration purposes
    return [
      Flashcard(question: 'What is 2 + 2?', answer: '4'),
      Flashcard(question: 'What is the capital of France?', answer: 'Paris'),
      Flashcard(question: 'Who wrote Hamlet?', answer: 'William Shakespeare'),
    ];
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    // Add flashcard to storage
  }

  Future<void> editFlashcard(int index, Flashcard flashcard) async {
    // Edit flashcard in storage
  }
}

class FlashcardQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcard Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: FlashcardQuizScreen(),
    );
  }
}

class FlashcardQuizScreen extends StatefulWidget {
  @override
  _FlashcardQuizScreenState createState() => _FlashcardQuizScreenState();
}

class _FlashcardQuizScreenState extends State<FlashcardQuizScreen> {
  List<Flashcard> flashcards = []; // List to store flashcards
  int currentCardIndex = 0; // Index of the current flashcard being displayed
  bool showAnswer = false; // Variable to control answer visibility

  @override
  void initState() {
    super.initState();
    // Fetch flashcards from the service
    // flashcards = flashcardService.getFlashcards();

    // Mock data for demonstration purposes
    flashcards = FlashcardService().getFlashcards();
  }

  void nextCard() {
    setState(() {
      currentCardIndex = (currentCardIndex + 1) % flashcards.length;
      showAnswer = false; // Reset answer visibility when moving to the next card
    });
  }

  void previousCard() {
    setState(() {
      currentCardIndex = (currentCardIndex - 1 + flashcards.length) % flashcards.length;
      showAnswer = false; // Reset answer visibility when moving to the previous card
    });
  }

  void addFlashcard(String question, String answer) {
    setState(() {
      flashcards.add(Flashcard(question: question, answer: answer));
    });
  }

  void editFlashcard(int index, String question, String answer) {
    setState(() {
      flashcards[index] = Flashcard(question: question, answer: answer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Quiz'),
      ),
      body: Center(
        child: flashcards.isEmpty
            ? Text('No flashcards available')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlashcardWidget(
                    flashcard: flashcards[currentCardIndex],
                    showAnswer: showAnswer,
                    onShowAnswerPressed: () {
                      setState(() {
                        showAnswer = !showAnswer;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to add question screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditFlashcardScreen(addFlashcard: addFlashcard,editFlashcard: editFlashcard,),
                            ),
                          );
                        },
                        child: Text('Add Question'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to edit question screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditFlashcardScreen(addFlashcard: addFlashcard,
                                index: currentCardIndex,
                                flashcard: flashcards[currentCardIndex],
                                editFlashcard: editFlashcard,
                              ),
                            ),
                          );
                        },
                        child: Text('Edit Question'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: previousCard,
                        child: Text('Previous'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: nextCard,
                        child: Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class AddEditFlashcardScreen extends StatefulWidget {
  final int? index;
  final Flashcard? flashcard;
  final Function(String, String) addFlashcard;
  final Function(int, String, String) editFlashcard;

  AddEditFlashcardScreen({this.index, this.flashcard, required this.addFlashcard, required this.editFlashcard});

  @override
  _AddEditFlashcardScreenState createState() => _AddEditFlashcardScreenState();
}

class _AddEditFlashcardScreenState extends State<AddEditFlashcardScreen> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.flashcard?.question ?? '');
    _answerController = TextEditingController(text: widget.flashcard?.answer ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index != null ? 'Edit Question' : 'Add Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(labelText: 'Question'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(labelText: 'Answer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.index != null) {
                  widget.editFlashcard(widget.index!, _questionController.text, _answerController.text);
                } else {
                  widget.addFlashcard(_questionController.text, _answerController.text);
                }
                Navigator.pop(context);
              },
              child: Text(widget.index != null ? 'Save Changes' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardWidget extends StatelessWidget {
  final Flashcard flashcard;
  final bool showAnswer;
  final VoidCallback onShowAnswerPressed;

  const FlashcardWidget({
    required this.flashcard,
    required this.showAnswer,
    required this.onShowAnswerPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              flashcard.question,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: showAnswer,
              child: Text(
                flashcard.answer,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onShowAnswerPressed,
              child: Text(showAnswer ? 'Hide Answer' : 'Show Answer'),
            ),
          ],
        ),
      ),
    );
  }
}
