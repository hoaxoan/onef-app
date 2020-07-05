import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onef/models/note.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/drawable.dart';

class OFNoteDetailPage extends StatefulWidget {
  /* const OFNoteDetailPage({Key key, this.note, @required this.sourceRect})
      : super(key: key);*/

  const OFNoteDetailPage({Key key, this.note}) : super(key: key);

  final Note note;
  /*final Rect sourceRect;

  static Route<dynamic> route(BuildContext context, Note note) {
    final RenderBox box = context.findRenderObject();
    final Rect sourceRect = box.localToGlobal(Offset.zero) & box.size;

    return PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, _, __) => OFNoteDetailPage(
        note: note,
        sourceRect: sourceRect,
      ),
      transitionDuration: const Duration(milliseconds: 100),
    );
  }*/

  @override
  State<StatefulWidget> createState() => _OFNoteDetailPageState(note);
}

class _OFNoteDetailPageState extends State<OFNoteDetailPage> {
  _OFNoteDetailPageState(Note note)
      : this._note = note ?? Note(),
        _originNote = note?.copy() ?? Note(),
        this._titleTextController = TextEditingController(text: note?.title),
        this._contentTextController =
            TextEditingController(text: note?.content);

  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  bool _needsBootstrap;

  /// The note in editing
  final Note _note;

  /// The origin copy before editing
  Note _originNote;

  Color get _noteColor => _note.color ?? Colors.white;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _titleTextController;
  final TextEditingController _contentTextController;

  @override
  void initState() {
    super.initState();
    _titleTextController
        .addListener(() => _note.title = _titleTextController.text);
    _contentTextController
        .addListener(() => _note.content = _contentTextController.text);
    _needsBootstrap = true;
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _contentTextController.dispose();
    super.dispose();
  }

  void _bootstrap() async {}

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;
      _themeService = provider.themeService;
      _themeValueParserService = provider.themeValueParserService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return Hero(
      tag: 'NoteItem${_note.id}',
      child: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: _noteColor,
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                elevation: 0,
              ),
          scaffoldBackgroundColor: _noteColor,
          bottomAppBarColor: _noteColor,
        ),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: _noteColor,
            systemNavigationBarColor: _noteColor,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              actions: _buildTopActions(context),
              bottom: const PreferredSize(
                preferredSize: Size(0, 24),
                child: SizedBox(),
              ),
            ),
            body: _buildBody(context),
            bottomNavigationBar: _buildBottomAppBar(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) => DefaultTextStyle(
        style: TextStyle(
          color: Color(0xC2000000),
          fontSize: 18,
          height: 1.3125,
        ),
        child: WillPopScope(
          onWillPop: () => _onPop(null),
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: _buildNoteDetail(),
            ),
          ),
        ),
      );

  Widget _buildNoteDetail() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _titleTextController,
            style: TextStyle(
              color: Color(0xFF202124),
              fontSize: 21,
              height: 19 / 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              counter: const SizedBox(),
            ),
            maxLines: null,
            maxLength: 1024,
            textCapitalization: TextCapitalization.sentences,
            readOnly: _note.status == NoteStatus.deleted,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _contentTextController,
            style: TextStyle(
              color: Color(0xC2000000),
              fontSize: 18,
              height: 1.3125,
            ),
            decoration: const InputDecoration.collapsed(hintText: 'Note'),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            readOnly: _note.status == NoteStatus.deleted,
          ),
        ],
      );

  List<Widget> _buildTopActions(BuildContext context) => [
        if (_note.status != NoteStatus.deleted)
          IconButton(
            icon: Icon(_note.pinned == true
                ? D.ic_keep_pin_outline
                : D.ic_keep_pin_outline),
            tooltip: _note.pinned == true ? 'Unpin' : 'Pin',
          ),
        /* if (_note.id != null && _note.status.code < NoteStatus.archived.code)
          IconButton(
            icon: const Icon(D.ic_archive),
            tooltip: 'Archive',
          ),*/
        if (_note.status == NoteStatus.archived)
          IconButton(
            icon: const Icon(D.ic_archive),
            tooltip: 'Unarchive',
          ),
      ];

  Widget _buildBottomAppBar(BuildContext context) => BottomAppBar(
        child: Container(
          height: 56.0,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(D.ic_add_box),
                color: Color(0xFF5F6368),
              ),
              Text('Edited ${_note.strLastModified}'),
              IconButton(
                icon: const Icon(Icons.more_vert),
                color: Color(0xFF5F6368),
                onPressed: () => _showNoteBottomSheet(context),
              ),
            ],
          ),
        ),
      );

  void _showNoteBottomSheet(BuildContext context) async {}

  Future<bool> _onPop(String uid) {
    return Future.value(true);
  }
}
