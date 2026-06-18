class FlashcardSet {
  final String setId;
  final String title;
  final String description;
  final String level;
  final int difficultyOrder;
  final int totalCards;
  final bool isActive;
  final String createdByAdminId;

  FlashcardSet({
    required this.setId,
    required this.title,
    required this.description,
    required this.level,
    required this.difficultyOrder,
    required this.totalCards,
    required this.isActive,
    required this.createdByAdminId,
  });

  factory FlashcardSet.fromFirestore(Map<String, dynamic> data, String id) {
    return FlashcardSet(
      setId: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      level: data['level'] ?? 'beginner',
      difficultyOrder: data['difficultyOrder'] ?? 999,
      totalCards: data['totalCards'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdByAdminId: data['createdByAdminId'] ?? '',
    );
  }
}

class Flashcard {
  final String cardId;
  final String setId;
  final String level;
  final int cardOrder;
  final String frontText;
  final String backExplanation;
  final String imagePath;
  final String category;
  final String sourceNote;
  final bool isActive;

  Flashcard({
    required this.cardId,
    required this.setId,
    required this.level,
    required this.cardOrder,
    required this.frontText,
    required this.backExplanation,
    required this.imagePath,
    required this.category,
    required this.sourceNote,
    required this.isActive,
  });

  factory Flashcard.fromFirestore(Map<String, dynamic> data, String id) {
    return Flashcard(
      cardId: id,
      setId: data['setId'] ?? '',
      level: data['level'] ?? 'beginner',
      cardOrder: data['cardOrder'] ?? 999,
      frontText: data['frontText'] ?? '',
      backExplanation: data['backExplanation'] ?? '',
      imagePath: data['imagePath'] ?? '',
      category: data['category'] ?? '',
      sourceNote: data['sourceNote'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}