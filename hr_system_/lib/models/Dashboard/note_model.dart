class NoteModel {
  final String title;
  final String content;

  NoteModel({required this.title, required this.content});

  Map<String, dynamic> toJson() => {'title': title, 'content': content};
}
