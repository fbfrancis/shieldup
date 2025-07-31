import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizScreen extends StatefulWidget {
  static const routeName = '/quiz';
  final String courseTitle;

  const QuizScreen({super.key, required this.courseTitle});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, Object>> _questions = [
    {
      'question': 'What does "https" stand for?',
      'options': [
        'HyperText Transfer Protocol Secure',
        'High Transfer Protocol System',
        'Hyper Terminal Transfer System',
      ],
      'answer': 'HyperText Transfer Protocol Secure',
    },
    {
      'question': 'Which of the following is a strong password?',
      'options': ['123456', 'Password123', 'L!f3@2025#'],
      'answer': 'L!f3@2025#',
    },
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  bool _answered = false;
  String _selectedAnswer = '';

  void _selectAnswer(String selectedOption) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = selectedOption;
      _answered = true;
      if (selectedOption == _questions[_currentQuestionIndex]['answer']) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _answered = false;
          _selectedAnswer = '';
        });
      } else {
        setState(() {
          _quizCompleted = true;
        });
        _storeResultsToFirestore();
      }
    });
  }

  void _retakeQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
      _answered = false;
      _selectedAnswer = '';
    });
  }

  void _storeResultsToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('quizResults').add({
      'email': user.email,
      'course': widget.courseTitle,
      'score': _score,
      'totalQuestions': _questions.length,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final question = _questions[_currentQuestionIndex];
    final total = _questions.length;
    final _ = ((_currentQuestionIndex + 1) / total) * 100;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Quiz - ${widget.courseTitle}',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _quizCompleted
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Quiz Completed!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You scored $_score out of $total',
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _retakeQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Retake Quiz',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Indicator
                    Text(
                      'Question ${_currentQuestionIndex + 1} of $total',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / total,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.teal,
                      minHeight: 6,
                    ),
                    const SizedBox(height: 24),

                    // Question Card
                    Card(
                      elevation: 4,
                      color: isDark ? Colors.grey[900] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          question['question'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options
                    ...(question['options'] as List<String>).map((option) {
                      Color optionColor = Colors.grey.shade200;
                      if (_answered) {
                        if (option == question['answer']) {
                          optionColor = Colors.green.shade400;
                        } else if (option == _selectedAnswer) {
                          optionColor = Colors.red.shade300;
                        }
                      }

                      return GestureDetector(
                        onTap: () => _selectAnswer(option),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? optionColor.withOpacity(0.2)
                                    : optionColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isDark
                                      ? Colors.white24
                                      : Colors.grey.shade400,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 12,
                                color: Colors.teal.shade600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const Spacer(),

                    // Footer Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _quizCompleted ? null : () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _quizCompleted ? Colors.grey : Colors.teal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _quizCompleted ? 'Quiz Completed' : 'Take Quiz',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
