import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onef/models/note.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/lib/poppable_page_controller.dart';
import 'package:onef/pages/home/pages/note/note_detail_page.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/utils/utils.dart';
import 'package:onef/widgets/action_button.dart';
import 'package:onef/widgets/drawable.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/note/note.dart';
import 'package:onef/widgets/notes_stream/notes_stream.dart';
import 'package:onef/widgets/page_scaffold.dart';
import 'package:onef/widgets/search_bar.dart';
import 'package:onef/widgets/theming/primary_color_container.dart';

class OFNotePage extends StatefulWidget {
  final OFNotePageController controller;

  OFNotePage({
    @required this.controller,
  });
  @override
  State<OFNotePage> createState() {
    return OFNotePageState();
  }
}

class OFNotePageState extends State<OFNotePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  OFNotesStreamController _notesStreamController;

  List<Note> _initialNotes;

  StreamSubscription _loggedInUserChangeSubscription;
  bool _needsBootstrap;
  bool _loggedInUserBootstrapped;

  List<Note> _currentNotes;

  /// `true` to show notes in a GridView, a ListView otherwise.
  bool _gridView = true;

  double _extraPaddingForSlidableSection;
  static const double HEIGHT_SEARCH_BAR = 76.0;

  @override
  void initState() {
    super.initState();
    _notesStreamController = OFNotesStreamController();
    widget.controller.attach(context: context, state: this);
    _needsBootstrap = true;
    _loggedInUserBootstrapped = false;
  }

  @override
  void dispose() {
    super.dispose();
    _loggedInUserChangeSubscription.cancel();
  }

  Future refresh() {
    return _notesStreamController.refreshNotes();
  }

  void scrollToTop() {
    _notesStreamController.scrollToTop();
  }

  void _bootstrap() async {
    _loggedInUserChangeSubscription =
        _userService.loggedInUserChange.listen(_onLoggedInUserChange);
  }

  void _onLoggedInUserChange(User newUser) async {
    if (newUser == null) return;

    setState(() {
      _loggedInUserBootstrapped = true;
      _loggedInUserChangeSubscription.cancel();
    });
  }

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

    if (_extraPaddingForSlidableSection == null)
      _extraPaddingForSlidableSection = _getExtraPaddingForSlidableSection();

    return OFCupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: OFPrimaryColorContainer(
        child: Stack(
          children: <Widget>[_createSearchBar(), _createNotesStream()],
        ),
      ),
    );

    /*return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 720),
          child: CustomScrollView(
            slivers: <Widget>[
              _appBar,
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              Container(
                child: OFNotesStream(
                  onScrollLoadMoreLimit: 20,
                  onScrollLoadMoreLimitLoadMoreText:
                      _localizationService.post__trending_posts_load_more,
                  streamIdentifier: 'notes',
                  refresher: _notesStreamRefresher,
                  onScrollLoader: _notesStreamOnScrollLoader,
                  controller: _notesStreamController,
                  noteBuilder: _notesBuilder,
                  //onScrollCallback: widget.onScrollCallback,
                  refreshIndicatorDisplacement: 110.0,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 10.0),
              ),
            ],
          ),
        ),
      ),
      */ /*drawer: AppDrawer(),*/ /*
      floatingActionButton: _fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      extendBody: true,
    );*/
  }

  Widget get _appBar {
    return SliverAppBar(
      floating: true,
      snap: true,
      title: _topActions(context),
      automaticallyImplyLeading: false,
      centerTitle: true,
      titleSpacing: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _topActions(BuildContext context) => Container(
        // width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 720,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isNotAndroid ? 7 : 5),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 20),
                InkWell(
                  child: const Icon(Icons.menu),
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Search...',
                    softWrap: false,
                    style: TextStyle(
                      color: Color(0xFF61656A),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  child: OFIcon(OFIconData(
                      nativeIcon: _gridView ? D.ic_list_view : D.ic_grid_view)),
                  onTap: () => setState(() {
                    _gridView = !_gridView;
                  }),
                ),
                const SizedBox(width: 18),
                //_buildAvatar(context),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      );

  /*List<Widget> _buildNotesView() {
    final asGrid = filter.noteState == NoteState.deleted || _gridView;
    final factory = asGrid ? NotesGrid.create : NotesList.create;
    final showPinned = filter.noteState == NoteState.unspecified;

    if (!showPinned) {
      return [
        factory(notes: notes, onTap: _onNoteTap),
      ];
    }

    final partition = _partitionNotes(notes);
    final hasPinned = partition.item1.isNotEmpty;
    final hasUnpinned = partition.item2.isNotEmpty;

    final _buildLabel = (String label, [double top = 26]) => SliverToBoxAdapter(
          child: Container(
            padding:
                EdgeInsetsDirectional.only(start: 26, bottom: 25, top: top),
            child: Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF61656A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        );

    return [
      if (hasPinned) _buildLabel('PINNED', 0),
      if (hasPinned) factory(notes: partition.item1, onTap: _onNoteTap),
      if (hasPinned && hasUnpinned) _buildLabel('OTHERS'),
      factory(notes: partition.item2, onTap: _onNoteTap),
    ];
  }*/

  Widget _createNotesStream() {
    return IndexedStack(
      index: 0,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
              top: HEIGHT_SEARCH_BAR + _extraPaddingForSlidableSection),
          child: OFNotesStream(
            onScrollLoadMoreLimit: 20,
            onScrollLoadMoreLimitLoadMoreText:
                _localizationService.post__trending_posts_load_more,
            streamIdentifier: 'notes',
            refresher: _notesStreamRefresher,
            onScrollLoader: _notesStreamOnScrollLoader,
            controller: _notesStreamController,
            noteBuilder: _notesBuilder,
            //onScrollCallback: widget.onScrollCallback,
            refreshIndicatorDisplacement: 110.0,
          ),
        ),
      ],
    );
  }

  double _getExtraPaddingForSlidableSection() {
    return 34.0;
  }

  Widget _createSearchBar() {
    MediaQueryData existingMediaQuery = MediaQuery.of(context);
    return Positioned(
        left: 0,
        top: 0,
        height: HEIGHT_SEARCH_BAR + _extraPaddingForSlidableSection,
        width: existingMediaQuery.size.width,
        child: OFCupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: OFPrimaryColorContainer(
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  OFSearchBar(
                    onSearch: _onSearch,
                    hintText: _localizationService.user_search__search_text,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<List<Note>> _notesStreamRefresher() async {
    List<Note> notes =
        (await _userService.getNotes(count: 10, cacheNotes: false)).notes;

    _setNotes(notes);
    return notes;
  }

  Future<List<Note>> _notesStreamOnScrollLoader(List<Note> notes) async {
    Note lastNote = notes.last;
    int lastNoteId = lastNote.id;

    List<Note> moreNotes =
        (await _userService.getNotes(maxId: lastNoteId, count: 10)).notes;

    _appendCurrentNotes(moreNotes);

    return moreNotes;
  }

  Widget _notesBuilder(
      {BuildContext context,
      Note note,
      String noteIdentifier,
      ValueChanged<Note> onNoteDeleted}) {
    return OFNote(note,
        key: Key(noteIdentifier),
        inViewId: noteIdentifier,
        onNoteIsInView: onNoteIsInView,
        onNoteDeleted: onNoteDeleted);
  }

  void onNoteIsInView(Note note) async {
    var route = MaterialPageRoute(builder: (BuildContext context) {
      return OFNoteDetailPage(
        note: note,
      );
    });
    await Navigator.of(context, rootNavigator: true).push(route);
  }

  void _setNotes(List<Note> notes) {
    setState(() {
      _currentNotes = notes;
    });
  }

  void _appendCurrentNotes(List<Note> notes) {
    List<Note> newNotes = _currentNotes + notes;
    setState(() {
      _currentNotes = newNotes;
    });
  }

  void _onSearch(String query) {
    /* _setSearchQuery(query);
    if (query.isEmpty) {
      _setHasSearch(false);
      return;
    }

    if (_hasSearch == false) {
      _setHasSearch(true);
    }

    _searchWithQuery(query);*/
  }

  Widget get _fab {
    return AnimatedBuilder(
      animation: ModalRoute.of(context).animation,
      child: OFActionButton(
        onPressed: () async {},
      ),
      builder: (BuildContext context, Widget fab) {
        final Animation<double> animation = ModalRoute.of(context).animation;
        return SizedBox(
          width: 54 * animation.value,
          height: 54 * animation.value,
          child: fab,
        );
      },
    );
  }
}

class OFNotePageController extends PoppablePageController {
  OFNotePageState _state;

  void attach({@required BuildContext context, OFNotePageState state}) {
    super.attach(context: context);
    _state = state;
  }

  Future<void> refresh() {
    return _state.refresh();
  }

  void scrollToTop() {
    _state.scrollToTop();
  }
}
