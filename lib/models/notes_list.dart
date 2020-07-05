import 'package:onef/models/note.dart';

class NotesList {
  final List<Note> notes;

  NotesList({
    this.notes,
  });

  factory NotesList.fromJson(List<dynamic> parsedJson) {
    List<Note> notes =
        parsedJson.map((noteJson) => Note.fromJSON(noteJson)).toList();

    return new NotesList(
      notes: notes,
    );
  }
}
