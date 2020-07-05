import 'package:flutter/material.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/text_autocompletion.dart';

abstract class OFContextualSearchBoxState<T extends StatefulWidget>
    extends State<T> {
  TextAutocompletionService _textAutocompletionService;

  TextAutocompletionType _autocompletionType;

  TextEditingController _autocompleteTextController;

  bool isAutocompleting;

  @override
  void initState() {
    super.initState();
    isAutocompleting = false;
  }

  @override
  void dispose() {
    super.dispose();
    _autocompleteTextController?.removeListener(_checkForAutocomplete);
  }

  void bootstrap() {
    var provider = OneFProvider.of(context);
    _textAutocompletionService = provider.textAccountAutocompletionService;
  }

  void setAutocompleteTextController(TextEditingController textController) {
    _autocompleteTextController = textController;
    textController.addListener(_checkForAutocomplete);
  }

  Widget buildSearchBox() {
    if (!isAutocompleting) {
      throw 'There is no current autocompletion';
    }

    /* switch (_autocompletionType) {
      case TextAutocompletionType.account:
        return _buildAccountSearchBox();
      case TextAutocompletionType.community:
        return _buildCommunitySearchBox();
      case TextAutocompletionType.hashtag:
        return _buildHashtagSearchBox();
      default:
        throw 'Unhandled text autocompletion type';
    }*/
  }

  void _checkForAutocomplete() {
    TextAutocompletionResult result = _textAutocompletionService
        .checkTextForAutocompletion(_autocompleteTextController);

    if (result.isAutocompleting) {
      debugLog('Wants to autocomplete with type ${result.type} searchQuery:' +
          result.autocompleteQuery);
      _setIsAutocompleting(true);
      _setAutocompletionType(result.type);
      /*switch (result.type) {
        case TextAutocompletionType.hashtag:
          _contextualHashtagSearchBoxController
              .search(result.autocompleteQuery);
          break;
        case TextAutocompletionType.account:
          _contextualAccountSearchBoxController
              .search(result.autocompleteQuery);
          break;
        case TextAutocompletionType.community:
          _contextualCommunitySearchBoxController
              .search(result.autocompleteQuery);
          break;
      }*/
    } else if (isAutocompleting) {
      debugLog('Finished autocompleting');
      _setIsAutocompleting(false);
    }
  }

  void autocompleteFoundAccountUsername(String foundAccountUsername) {
    if (!isAutocompleting) {
      debugLog(
          'Tried to autocomplete found account username but was not searching account');
      return;
    }

    debugLog('Autocompleting with username:$foundAccountUsername');
    setState(() {
      _textAutocompletionService.autocompleteTextWithUsername(
          _autocompleteTextController, foundAccountUsername);
    });
  }

  void autocompleteFoundCommunityName(String foundCommunityName) {
    if (!isAutocompleting) {
      debugLog(
          'Tried to autocomplete found community name but was not searching community');
      return;
    }

    debugLog('Autocompleting with name:$foundCommunityName');
    setState(() {
      _textAutocompletionService.autocompleteTextWithCommunityName(
          _autocompleteTextController, foundCommunityName);
    });
  }

  void autocompleteFoundHashtagName(String foundHashtagName) {
    if (!isAutocompleting) {
      debugLog(
          'Tried to autocomplete found hashtag name but was not searching hashtag');
      return;
    }

    debugLog('Autocompleting with name:$foundHashtagName');
    setState(() {
      _textAutocompletionService.autocompleteTextWithHashtagName(
          _autocompleteTextController, foundHashtagName);
    });
  }

  void _setIsAutocompleting(bool isSearchingAccount) {
    setState(() {
      isAutocompleting = isSearchingAccount;
    });
  }

  void _setAutocompletionType(TextAutocompletionType autocompletionType) {
    setState(() {
      _autocompletionType = autocompletionType;
    });
  }

  void setState(VoidCallback fn);

  void debugLog(String log) {
    debugPrint('ContextualSearchBoxStateMixin:$log');
  }
}
