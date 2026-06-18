import 'package:flutter/material.dart';
import 'package:mobile_app/features/community/models/flashcard.dart';
import 'package:mobile_app/features/community/services/community_service.dart';

class FlashcardPage extends StatefulWidget {
  final FlashcardSet flashcardSet;

  const FlashcardPage({super.key, required this.flashcardSet});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final CommunityService _communityService = CommunityService();

  List<Flashcard> _flashcards = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    try {
      final flashcards = await _communityService.getFlashcards(
        widget.flashcardSet.setId,
      );

      if (!mounted) return;

      setState(() {
        _flashcards = flashcards;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
    });
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _showBack = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showBack = false;
      });
    }
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
          widget.flashcardSet.title,
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
          : _flashcards.isEmpty
          ? const Center(
              child: Text(
                'No flashcards available.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Card ${_currentIndex + 1} of ${_flashcards.length}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _flashcards.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF51BA90),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: _showBack
                              ? const Color(0xFFF6FFFB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _showBack
                                ? const Color(0xFF51BA90)
                                : Colors.grey[300]!,
                            width: _showBack ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_showBack &&
                                  _flashcards[_currentIndex]
                                      .imagePath
                                      .isNotEmpty) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    _flashcards[_currentIndex].imagePath,
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 220,
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Image not found',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ] else ...[
                                Icon(
                                  _showBack
                                      ? Icons.lightbulb
                                      : Icons.help_outline,
                                  size: 40,
                                  color: _showBack
                                      ? const Color(0xFF51BA90)
                                      : Colors.grey[400],
                                ),
                                const SizedBox(height: 20),
                              ],

                              Text(
                                _showBack ? 'Answer' : 'Question',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _showBack
                                      ? const Color(0xFF51BA90)
                                      : Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                _showBack
                                    ? _flashcards[_currentIndex].backExplanation
                                    : _flashcards[_currentIndex].frontText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  color: _showBack
                                      ? const Color(0xFF264D43)
                                      : Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 24),

                              Text(
                                'Tap to ${_showBack ? 'see question' : 'reveal answer'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentIndex > 0 ? _previousCard : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF51BA90),
                            side: const BorderSide(color: Color(0xFF51BA90)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_currentIndex == _flashcards.length - 1) {
                              Navigator.pop(context);
                            } else {
                              _nextCard();
                            }
                          },
                          icon: Icon(
                            _currentIndex == _flashcards.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            _currentIndex == _flashcards.length - 1
                                ? 'Finish'
                                : 'Next',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF51BA90),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
