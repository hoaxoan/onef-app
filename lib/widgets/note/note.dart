import 'package:flutter/material.dart';
import 'package:onef/models/note.dart';
import 'package:onef/utils/string_util.dart';
import 'package:onef/widgets/theming/text.dart';

class OFNote extends StatelessWidget {
  final Note note;
  final ValueChanged<Note> onNoteDeleted;
  final ValueChanged<Note> onNoteIsInView;
  final String inViewId;
  final bool isTopNote;

  const OFNote(this.note,
      {Key key,
      @required this.onNoteDeleted,
      this.onNoteIsInView,
      this.inViewId,
      this.isTopNote = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _bootstrap(context);

    return GestureDetector(
        onTap: () => onNoteIsInView(note),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  children: <Widget>[
                    Column(children: <Widget>[
                      Container(
                          alignment: Alignment.topCenter,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                    !StringUtil.isEmpty(note.title)
                                        ? new Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16.0,
                                                left: 14.0,
                                                right: 14.0,
                                                bottom: 8.0),
                                            child: OFText(
                                              note.title,
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "GoogleSans",
                                                  color: Colors.black),
                                            ),
                                          )
                                        : new Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0.0,
                                                left: 14.0,
                                                right: 14.0,
                                                bottom: 12.0)),
                                    !StringUtil.isEmpty(note.content)
                                        ? new Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0.0,
                                                left: 14.0,
                                                right: 14.0,
                                                bottom: 16.0),
                                            child: OFText(
                                              note.content,
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontFamily: "GoogleSans",
                                                  color: Colors.black54),
                                            ),
                                          )
                                        : new Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0.0,
                                                left: 14.0,
                                                right: 14.0,
                                                bottom: 12.0))
                                  ]))
                            ],
                          )),
                    ]),
                  ],
                ))));
  }

  void _bootstrap(BuildContext context) {}
}
