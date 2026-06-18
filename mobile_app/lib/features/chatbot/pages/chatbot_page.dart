import 'dart:io';
import 'dart:ui';

import 'package:gal/gal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/core/widgets/bottom_nav.dart';
import 'package:mobile_app/features/chatbot/services/chatbot_service.dart';
import 'package:mobile_app/features/chatbot/services/image_scan_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final File? image;

  ChatMessage({required this.text, required this.isUser, this.image});
}

class QuickQuestion {
  final String label;
  final String question;
  final IconData icon;

  QuickQuestion({
    required this.label,
    required this.question,
    required this.icon,
  });
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final ChatbotService _chatbotService = ChatbotService();
  final ImageScanService _imageScanService = ImageScanService();
  final TextEditingController _questionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  final List<QuickQuestion> _quickQuestions = [
    QuickQuestion(
      label: 'Plastic Bottle',
      question: 'Can I recycle plastic bottles?',
      icon: Icons.local_drink_outlined,
    ),
    QuickQuestion(
      label: 'Cardboard',
      question: 'How should I recycle cardboard boxes?',
      icon: Icons.inventory_2_outlined,
    ),
    QuickQuestion(
      label: 'Battery',
      question: 'How do I dispose of used batteries safely?',
      icon: Icons.battery_5_bar_outlined,
    ),
    QuickQuestion(
      label: 'E-waste',
      question: 'Where should I recycle e-waste?',
      icon: Icons.devices_other_outlined,
    ),
    QuickQuestion(
      label: 'Food Container',
      question: 'Can I recycle food containers if they are dirty?',
      icon: Icons.lunch_dining_outlined,
    ),
    QuickQuestion(
      label: 'Not Recyclable',
      question: 'What common items cannot be recycled?',
      icon: Icons.block_outlined,
    ),
  ];

  bool _isLoading = false;
  bool _isLoadingLatest = true;
  bool _showImageOptions = false;
  bool _showQuickQuestions = false;

  @override
  void initState() {
    super.initState();
    _loadLatestRecord();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadLatestRecord() async {
    try {
      await _chatbotService.getLatestChatbotRecord();

      if (!mounted) return;

      setState(() {
        _isLoadingLatest = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingLatest = false;
      });
    }
  }

  Future<void> _sendQuestion() async {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type a question first.')),
      );
      return;
    }

    await _sendQuestionText(question);
  }

  Future<void> _sendQuickQuestion(String question) async {
    if (_isLoading) return;
    await _sendQuestionText(question);
  }

  Future<void> _sendQuestionText(String question) async {
    setState(() {
      _isLoading = true;
      _showImageOptions = false;
      _messages.add(ChatMessage(text: question, isUser: true));
      _questionController.clear();
    });

    _scrollToBottom();

    try {
      final answer = await _chatbotService.askQuestion(question);

      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage(text: answer, isUser: false));
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Sorry, I could not get an answer right now. Please try again.',
            isUser: false,
          ),
        );
      });

      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveCameraImageToGallery(File imageFile) async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);

      if (!hasAccess) {
        final requestGranted = await Gal.requestAccess(toAlbum: true);

        if (!requestGranted) {
          debugPrint('Gallery permission denied.');
          return;
        }
      }

      await Gal.putImage(imageFile.path, album: 'SortSnap');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Photo saved to gallery.')));
    } catch (e) {
      debugPrint('Failed to save image to gallery: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _showImageOptions = false;
      });

      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 60,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedImage == null) {
        return;
      }

      final imageFile = File(pickedImage.path);

      // Save camera photo to gallery
      if (source == ImageSource.camera) {
        await _saveCameraImageToGallery(imageFile);
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Scanning image...',
            isUser: true,
            image: imageFile,
          ),
        );
        _isLoading = true;
      });

      _scrollToBottom();

      try {
        final result = await _imageScanService.classifyImage(
          imageFile: imageFile,
        );

        debugPrint('FLUTTER IMAGE RESULT: $result');

        if (!mounted) return;

        final detectionMode = (result['detectionMode'] ?? 'single').toString();

        final classification = Map<String, dynamic>.from(
          result['classification'] as Map? ?? {},
        );

        final classificationsRaw = result['classifications'] as List? ?? [];

        final answer = (result['answer'] ?? 'No guidance returned.').toString();

        String resultMessage;

        if (detectionMode == 'possible_mixed' &&
            classificationsRaw.length > 1) {
          String itemListText = '';

          for (int i = 0; i < classificationsRaw.length; i++) {
            final item = Map<String, dynamic>.from(
              classificationsRaw[i] as Map,
            );

            final category = (item['category'] ?? 'Unknown').toString();
            final confidencePercentage = item['confidencePercentage'] ?? 0;
            final isRecyclable = item['isRecyclable'] == true;

            itemListText +=
                '${i + 1}. $category\n'
                'Confidence: ${(confidencePercentage as num).toStringAsFixed(0)}%\n'
                'Recyclable: ${isRecyclable ? "Yes" : "No"}\n\n';
          }

          resultMessage =
              'Possible mixed materials:\n\n'
              '$itemListText'
              '$answer';
        } else {
          final category = (classification['category'] ?? 'Unknown').toString();
          final itemName = (classification['itemName'] ?? category).toString();
          final isRecyclable = classification['isRecyclable'] == true;

          final confidencePercentage =
              classification['confidencePercentage'] ?? 0;

          resultMessage =
              'Item: $itemName\n'
              'Category: $category\n'
              'Recyclable: ${isRecyclable ? "Yes" : "No"}\n'
              'Confidence: ${(confidencePercentage as num).toStringAsFixed(0)}%\n\n'
              '$answer';
        }

        setState(() {
          _messages.add(ChatMessage(text: resultMessage, isUser: false));
          _isLoading = false;
        });

        _scrollToBottom();
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _messages.add(
            ChatMessage(text: 'Image scan error:\n$e', isUser: false),
          );
          _isLoading = false;
        });

        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Widget _botBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 40, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF62C49D),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
                border: Border.all(color: const Color(0xFFD9F2E8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF264D43),
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingBubble() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 40, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF62C49D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD9F2E8)),
            ),
            child: const Text(
              'SortSnap is thinking...',
              style: TextStyle(
                color: Color(0xFF264D43),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userBubble(ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (message.image != null)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 140,
              height: 175,
              margin: const EdgeInsets.only(right: 18, left: 100, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFEADC)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(message.image!, fit: BoxFit.cover),
            ),
          ),
        if (message.text.isNotEmpty && message.text != 'Scanning image...')
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              margin: const EdgeInsets.only(right: 18, left: 80, bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF62C49D),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(6),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF62C49D).withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatArea() {
    if (_isLoadingLatest) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF62C49D)),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 24, bottom: 20),
      children: [
        _botBubble(
          'Hi! I am SortSnap. Ask me about recycling, disposal tips, or common waste items.',
        ),
        for (final message in _messages)
          message.isUser ? _userBubble(message) : _botBubble(message.text),
        if (_isLoading) _typingBubble(),
      ],
    );
  }

  Widget _buildQuickQuestionsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1F4ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showQuickQuestions = !_showQuickQuestions;
                _showImageOptions = false;
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.question_answer_outlined,
                  color: Color(0xFF3BAA82),
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Common Questions',
                    style: TextStyle(
                      color: Color(0xFF264D43),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  _showQuickQuestions
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF3BAA82),
                  size: 28,
                ),
              ],
            ),
          ),
          if (_showQuickQuestions) const SizedBox(height: 10),
          if (_showQuickQuestions)
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickQuestions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _quickQuestions[index];

                  return GestureDetector(
                    onTap: () => _sendQuickQuestion(item.question),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4FFFA),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFCDEFE2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 16,
                            color: const Color(0xFF3BAA82),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: Color(0xFF264D43),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftMenuButton() {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _showImageOptions = !_showImageOptions;
                _showQuickQuestions = false;
              });
            },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCDEFE2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _showImageOptions ? Icons.close : Icons.add,
          color: const Color(0xFF3BAA82),
          size: 30,
        ),
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      constraints: const BoxConstraints(minHeight: 46, maxHeight: 115),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2F2EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _questionController,
        textAlign: TextAlign.left,
        textInputAction: TextInputAction.send,
        keyboardType: TextInputType.text,
        minLines: 1,
        maxLines: 4,
        onSubmitted: (_) {
          if (!_isLoading) {
            _sendQuestion();
          }
        },
        decoration: const InputDecoration(
          hintText: 'Ask about recycling...',
          hintStyle: TextStyle(
            color: Color(0xFF9FAFA9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFEFFAF5),
        border: Border(top: BorderSide(color: Color(0xFFDDF1EA))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickQuestionsCard(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildLeftMenuButton(),
                const SizedBox(width: 10),
                Expanded(child: _buildInputBox()),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isLoading ? null : _sendQuestion,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF62C49D),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF62C49D).withOpacity(0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 23,
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

  Widget _buildImageOptionOverlay() {
    if (!_showImageOptions) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showImageOptions = false;
              });
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: Colors.black.withOpacity(0.12)),
            ),
          ),

          Positioned(
            left: 15,
            bottom: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showImageOptions = false;
                    });
                    _pickImage(ImageSource.camera);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFCDEFE2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF3BAA82),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Camera',
                        style: TextStyle(
                          color: Color(0xFF264D43),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showImageOptions = false;
                    });
                    _pickImage(ImageSource.gallery);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFCDEFE2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: Color(0xFF3BAA82),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Gallery',
                        style: TextStyle(
                          color: Color(0xFF264D43),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF62C49D),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Chatbot',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _messages.clear();
              _showImageOptions = false;
              _showQuickQuestions = false;
            });
          },
          icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF5),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildChatArea()),
              _buildInputArea(),
            ],
          ),
          _buildImageOptionOverlay(),
        ],
      ),
      bottomNavigationBar: const BottomNav(selectedIndex: 3),
    );
  }
}
