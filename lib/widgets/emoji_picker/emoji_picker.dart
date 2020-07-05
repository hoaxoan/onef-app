import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/emoji.dart';
import 'package:onef/models/emoji_group.dart';
import 'package:onef/models/emoji_group_list.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/emoji_picker/widgets/emoji_groups/emoji_groups.dart';
import 'package:onef/widgets/emoji_picker/widgets/emoji_search_results.dart';
import 'package:onef/widgets/search_bar.dart';

class OFEmojiPicker extends StatefulWidget {
  final OnEmojiPicked onEmojiPicked;
  final bool isReactionsPicker;
  final bool hasSearch;

  OFEmojiPicker(
      {this.onEmojiPicked,
      this.isReactionsPicker = false,
      this.hasSearch = true});

  @override
  State<StatefulWidget> createState() {
    return OFEmojiPickerState();
  }
}

class OFEmojiPickerState extends State<OFEmojiPicker> {
  UserService _userService;

  bool _needsBootstrap;
  bool _hasSearch;

  List<EmojiGroup> _emojiGroups;
  List<EmojiGroupSearchResults> _emojiSearchResults;
  String _emojiSearchQuery;

  @override
  void initState() {
    super.initState();
    _emojiGroups = [];
    _emojiSearchResults = [];
    _emojiSearchQuery = '';
    _needsBootstrap = true;
    _hasSearch = false;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _userService = provider.userService;

    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _hasSearch
            ? OFSearchBar(
                onSearch: _onSearch,
                hintText: 'Search emojis...',
              )
            : const SizedBox(),
        Expanded(
            child: _hasSearch
                ? OFEmojiSearchResults(
                    _emojiSearchResults,
                    _emojiSearchQuery,
                    onEmojiPressed: _onEmojiPressed,
                  )
                : OFEmojiGroups(
                    _emojiGroups,
                    onEmojiPressed: _onEmojiPressed,
                  ))
      ],
    );
  }

  void _onEmojiPressed(Emoji pressedEmoji, EmojiGroup emojiGroup) {
    widget.onEmojiPicked(pressedEmoji, emojiGroup);
  }

  void _onSearch(String searchString) {
    if (searchString.length == 0) {
      _setHasSearch(false);
      return;
    }

    if (!_hasSearch) _setHasSearch(true);

    String standarisedSearchStr = searchString.toLowerCase();

    List<EmojiGroupSearchResults> searchResults =
        _emojiGroups.map((EmojiGroup emojiGroup) {
      List<Emoji> groupEmojis = emojiGroup.getEmojis();
      List<Emoji> groupSearchResults = groupEmojis.where((Emoji emoji) {
        return emoji.keyword.toLowerCase().contains(standarisedSearchStr);
      }).toList();
      return EmojiGroupSearchResults(
          group: emojiGroup, searchResults: groupSearchResults);
    }).toList();

    _setEmojiSearchResults(searchResults);
    _setEmojiSearchQuery(searchString);
  }

  void _bootstrap() async {
    EmojiGroupList emojiGroupList = await (widget.isReactionsPicker
        ? _userService.getReactionEmojiGroups()
        : _userService.getEmojiGroups());
    this._setEmojiGroups(emojiGroupList.emojisGroups);
  }

  void _setEmojiGroups(List<EmojiGroup> emojiGroups) {
    setState(() {
      _emojiGroups = emojiGroups;
    });
  }

  void _setEmojiSearchResults(
      List<EmojiGroupSearchResults> emojiSearchResults) {
    setState(() {
      _emojiSearchResults = emojiSearchResults;
    });
  }

  void _setEmojiSearchQuery(String searchQuery) {
    setState(() {
      _emojiSearchQuery = searchQuery;
    });
  }

  void _setHasSearch(bool hasSearch) {
    setState(() {
      _hasSearch = hasSearch;
    });
  }
}

enum OBEmojiPickerStatus { searching, suggesting, overview }

typedef void OnEmojiPicked(Emoji pickedEmoji, EmojiGroup emojiGroup);

class EmojiGroupSearchResults {
  final EmojiGroup group;
  final List<Emoji> searchResults;

  EmojiGroupSearchResults({@required this.group, @required this.searchResults});
}
