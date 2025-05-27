class ClipboardItem {
  final String id;
  final String text;
  final int timestamp;

  ClipboardItem({
    required this.id,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory ClipboardItem.fromMap(Map<String, dynamic> map, String id) {
    return ClipboardItem(
      id: id,
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}