class ListNoteModel {
  final String noteId;
  final String date;
  final String title;
  final String content;

  ListNoteModel({
    required this.noteId,
    required this.date,
    required this.title,
    required this.content,
  });

  factory ListNoteModel.fromJson(Map<String, dynamic> json) {
    return ListNoteModel(
      noteId: json['noteId'],
      date: json['date'],
      title: json['title'],
      content: json['content'],
    );
  }
}
