import 'package:flutter/material.dart';
import 'package:onef/models/category.dart';
import 'package:onef/pages/home/pages/story/blocs/create_story.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/story/question.dart';
import 'package:onef/widgets/story/thing.dart';

class OFWhatMadeToday extends StatefulWidget {

  final PageController controller;
  const OFWhatMadeToday({Key key, @required this.controller})
      : assert(controller != null),
        super(key: key);

  @override
  _OFWhatMadeTodayState createState() => _OFWhatMadeTodayState();
}

class _OFWhatMadeTodayState extends State<OFWhatMadeToday> {

  CreateStoryBloc _createStoryBloc;
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;

  bool _needsBootstrap;
  List<Category> _categories;

  @override
  void initState() {
    super.initState();
    _categories = [];
    _needsBootstrap = true;
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _createStoryBloc = provider.createStoryBloc;
      _userService = provider.userService;
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;

      _loadCategoriesList();

      _needsBootstrap = false;
    }

    return Column(
      children: <Widget>[
        SizedBox(height: 100.0),
        OFQuestion("Amazing - what made today super awesome?"),
        Flexible(
            child: _OFThingMadeToday(categories: _categories, onThingTaped: onThingTaped,)),
        SizedBox(width: 64.0, height: 64.0),
      ],
    );
  }


  void _setCategories(List<Category> categories) {
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _loadCategoriesList() async {
    debugPrint('Refreshing categories list');
    //_setRefreshInProgress(true);
    try {
      var categoriesList = await _userService.getCategories();
      _setCategories(categoriesList.categories);
    } catch (error) {
      _onError(error);
    } finally {
      //_setRefreshInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void onThingTaped(Category category) async {
    _createStoryBloc.setCategory(category);
    _createStoryBloc.setCurrentPage(_createStoryBloc.getCurrentPage() + 1);
    if (widget.controller.hasClients) {
      widget.controller.animateToPage(
        _createStoryBloc.getCurrentPage(),
        duration: Duration(milliseconds: 1200),
        curve: Curves.ease,
      );
    }
  }
}

class _OFThingMadeToday extends StatelessWidget {
  List<Category> categories;
  ValueChanged<Category> onThingTaped;
  _OFThingMadeToday({Key key, @required this.categories, this.onThingTaped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> things = categories
        .map<Widget>((Category category) => OFThing(
      IconData(int.parse(category.code), fontFamily: 'ReflectlyIcons'),
      title: category.name,
      category: category,
      onThingTaped: onThingTaped,
    ))
        .toList();


    return Center(
      child: GridView.count(
        padding: EdgeInsets.symmetric(
          vertical: 32.0,
          horizontal: 16.0,
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        children: things,
      ),
    );
  }
}
