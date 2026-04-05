class DataBook {
  final String word;
  final String pos;
  final String phonetic;
  final String phoneticText;
  final String phoneticAm;
  final String phoneticAmText;
  final List<Senses> senses;

  DataBook({
    required this.word,
    required this.pos,
    required this.phonetic,
    required this.phoneticText,
    required this.phoneticAm,
    required this.phoneticAmText,
    required this.senses,
  });

  // Sử dụng factory để xử lý JSON an toàn hơn
  factory DataBook.fromJson(Map<String, dynamic> json) {
    return DataBook(
      word: json['word'] ?? "",
      pos: json['pos'] ?? "",
      phonetic: json['phonetic'] ?? "",
      phoneticText: json['phonetic_text'] ?? "",
      phoneticAm: json['phonetic_am'] ?? "",
      phoneticAmText: json['phonetic_am_text'] ?? "",
      senses: (json['senses'] as List?)
          ?.map((v) => Senses.fromJson(v))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'pos': pos,
      'phonetic': phonetic,
      'phonetic_text': phoneticText,
      'phonetic_am': phoneticAm,
      'phonetic_am_text': phoneticAmText,
      'senses': senses.map((v) => v.toJson()).toList(),
    };
  }
}

class Senses {
  final String? definition;
  final List<String>? examples;

  Senses({this.definition, this.examples});

  factory Senses.fromJson(Map<String, dynamic> json) {
    return Senses(
      definition: json['definition'],

      examples: json['examples'] != null
          ? List<String>.from(json['examples'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      'examples': examples,
    };
  }
}