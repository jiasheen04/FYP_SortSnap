import 'package:flutter/material.dart';
import 'package:mobile_app/features/community/models/quiz.dart';
import 'package:mobile_app/features/community/services/community_service.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;

  const QuizPage({super.key, required this.quiz});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final CommunityService _communityService = CommunityService();

  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  String? _selectedOptionId;
  bool _answered = false;
  int _score = 0;
  bool _quizCompleted = false;
  final List<Map<String, dynamic>> _answers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _communityService.getQuizQuestions(
        widget.quiz.quizId,
      );
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectOption(String optionId) {
    if (_answered) return;

    final currentQuestion = _questions[_currentIndex];
    final selectedOption = currentQuestion.options.firstWhere(
      (o) => o.optionId == optionId,
    );

    setState(() {
      _selectedOptionId = optionId;
      _answered = true;
      if (selectedOption.isCorrect) {
        _score++;
      }
      _answers.add({
        'questionId': currentQuestion.questionId,
        'selectedOptionId': optionId,
        'isCorrect': selectedOption.isCorrect,
      });
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionId = null;
        _answered = false;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
      _communityService.saveQuizAttempt(
        quizId: widget.quiz.quizId,
        quizTitle: widget.quiz.title,
        score: _score,
        totalQuestions: _questions.length,
        answers: _answers,
      );
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedOptionId = null;
        _answered = false;
        // Remove last answer since we're going back
        if (_answers.isNotEmpty) {
          final removedAnswer = _answers.removeLast();
          if (removedAnswer['isCorrect'] == true) {
            _score--;
          }
        }
      });
    }
  }

  Color _getOptionColor(QuizOption option) {
    if (!_answered) {
      if (_selectedOptionId == option.optionId) {
        return const Color(0xFFE8F8F0);
      }
      return Colors.white;
    }

    if (option.isCorrect) {
      return const Color(0xFFD4EDDA);
    }

    if (_selectedOptionId == option.optionId && !option.isCorrect) {
      return const Color(0xFFF8D7DA);
    }

    return Colors.white;
  }

  Widget _buildQuizContent() {
    if (_quizCompleted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 64, color: Color(0xFF51BA90)),
              const SizedBox(height: 24),
              const Text(
                'Quiz Completed!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Your Score: $_score / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFF51BA90),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _score == _questions.length
                    ? 'Perfect score! Amazing!'
                    : _score >= _questions.length * 0.7
                    ? 'Great job! Keep learning!'
                    : 'Keep practicing, you\'ll improve!',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51BA90),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Challenges',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Text(
          'No questions available for this quiz.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF51BA90)),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_currentIndex + 1} of ${_questions.length}',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Question image
          if (question.imagePath.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  question.imagePath,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      alignment: Alignment.center,
                      child: const Text(
                        'Image not found',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Options
          ...question.options.map((option) {
            return GestureDetector(
              onTap: () => _selectOption(option.optionId),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getOptionColor(option),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedOptionId == option.optionId
                        ? const Color(0xFF51BA90)
                        : Colors.grey[300]!,
                    width: _selectedOptionId == option.optionId ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.optionText,
                        style: const TextStyle(fontSize: 15, height: 1.3),
                      ),
                    ),
                    if (_answered && option.isCorrect)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 22,
                      ),
                    if (_answered &&
                        _selectedOptionId == option.optionId &&
                        !option.isCorrect)
                      const Icon(Icons.cancel, color: Colors.red, size: 22),
                  ],
                ),
              ),
            );
          }),

          // Explanation
          if (_answered &&
              question.explanation != null &&
              question.explanation!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBDE0FE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF0077B6),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF023E7D),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF51BA90),
                      side: const BorderSide(color: Color(0xFF51BA90)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _answered ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF51BA90),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? 'Next' : 'Finish',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5EDE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF62C49D),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.quiz.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF51BA90)),
            )
          : _buildQuizContent(),
    );
  }
}
