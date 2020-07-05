import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:onef/models/stories_list.dart';
import 'package:onef/models/story.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/lib/poppable_page_controller.dart';
import 'package:onef/pages/home/pages/story/edit_story/edit_story_page.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/bottom_sheet.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/modal_service.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/buttons/floating_action_button.dart';
import 'package:onef/widgets/drawable.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/icon_button.dart';
import 'package:onef/widgets/page_scaffold.dart';
import 'package:onef/widgets/stories_stream/stories_stream.dart';
import 'package:onef/widgets/story/stories.dart';
import 'package:onef/widgets/story/story.dart';
import 'package:onef/widgets/theming/primary_accent_text.dart';

class OFStoryPage extends StatefulWidget {
  final OFStoryPageController controller;

  OFStoryPage({
    @required this.controller,
  });
  @override
  State<OFStoryPage> createState() {
    return OFStoryPageState();
  }
}

class OFStoryPageState extends State<OFStoryPage> with TickerProviderStateMixin {
  UserService _userService;
  ModalService _modalService;
  BottomSheetService _bottomSheetService;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  StoriesList _storiesList;
  bool _refreshInProgress;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  List<Story> _initialStories;
  OFStoriesStreamController _ofStoriesStreamController;
  ScrollController _storiesStreamScrollController;

  StreamSubscription _loggedInUserChangeSubscription;

  bool _needsBootstrap;
  bool _loggedInUserBootstrapped;

  double _hideFloatingButtonTolerance = 10;
  AnimationController _hideFloatingButtonAnimation;
  double _previousScrollPixels;

  @override
  void initState() {
    super.initState();
    _ofStoriesStreamController = OFStoriesStreamController();
    _storiesStreamScrollController = ScrollController();
    widget.controller.attach(context: context, state: this);
    _needsBootstrap = true;
    _loggedInUserBootstrapped = false;

    _hideFloatingButtonAnimation = AnimationController(vsync: this, duration: kThemeAnimationDuration);
    _hideFloatingButtonAnimation.forward();

    _previousScrollPixels = 0;

    _storiesStreamScrollController.addListener(() {
      double newScrollPixelPosition = _storiesStreamScrollController.position.pixels;
      double scrollPixelDifference = _previousScrollPixels - newScrollPixelPosition;

      if (_storiesStreamScrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (scrollPixelDifference * -1 > _hideFloatingButtonTolerance) {
          _hideFloatingButtonAnimation.reverse();
        }
      } else {
        if (scrollPixelDifference > _hideFloatingButtonTolerance) {
          _hideFloatingButtonAnimation.forward();
        }
      }

      _previousScrollPixels = newScrollPixelPosition;
    });

    _refreshInProgress = false;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  }

  @override
  void dispose() {
    super.dispose();
    _loggedInUserChangeSubscription.cancel();
  }

  void _bootstrap() async {
    _loggedInUserChangeSubscription = _userService.loggedInUserChange.listen(_onLoggedInUserChange);
  }

  void _onLoggedInUserChange(User newUser) async {
    if (newUser == null) return;
    List<Story> initialStories = (await _userService.getStoredFirstPosts()).stories;
    setState(() {
      _loggedInUserBootstrapped = true;
      _initialStories = initialStories;
      _loggedInUserChangeSubscription.cancel();
    });
  }

  Future refresh() {
    return _ofStoriesStreamController.refresh();
  }

  void scrollToTop() {
    _ofStoriesStreamController.scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;

    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _bottomSheetService = provider.bottomSheetService;
      _modalService = provider.modalService;
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;
      _themeService = provider.themeService;
      _themeValueParserService = provider.themeValueParserService;
      _bootstrap();

      _needsBootstrap = false;
    }

    return OFCupertinoPageScaffold(
        backgroundColor: _themeValueParserService
            .parseColor(_themeService.getActiveTheme().primaryColor),
        child: Stack(
          children: <Widget>[
            _loggedInUserBootstrapped
                ? OFStoriesStream(
              controller: _ofStoriesStreamController,
              scrollController: _storiesStreamScrollController,
              streamIdentifier: 'timeline',
              onScrollLoader: _storiesStreamOnScrollLoader,
              refresher: _storiesStreamRefresher,
              initialStories: _initialStories,
              prependedItems: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 20, right: 20, bottom: 10, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      OFPrimaryAccentText(_localizationService.post__top_posts_title,
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      OFIconButton(
                        OFIcons.settings,
                        themeColor: OFIconThemeColor.primaryAccent,
                      )
                    ],
                  ),
                )
              ],
            )
                : const SizedBox(),
            Positioned(
                bottom: 20.0,
                right: 20.0,
                child: Semantics(
                    button: true,
                    label: _localizationService.post__create_new_post_label,
                    child: ScaleTransition(
                        scale: _hideFloatingButtonAnimation,
                        child: OFFloatingActionButton(
                            type: OFButtonType.primary,
                            onPressed: _onCreateStory,
                            child: const OFIcon(OFIcons.createPost,
                                size: OFIconSize.large, color: Colors.white)))))
          ],
        ));

    /*return RefreshIndicator(
      onRefresh: _refreshStoriesList,
      key: _refreshIndicatorKey,
      child: Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Padding(
              padding:
              EdgeInsets.only(top: devicePadding.top, left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text("Good morning",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .title
                                  .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black38,
                                  fontFamily: 'Avenir')),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            right: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    D.filter0,
                                    color: Colors.black54,
                                    size: 26,
                                  ),
                                  onPressed: () async {
                                  },
                                ),
                                _buildAddButton(context)
                              ],
                            ),
                          ),
                        ),
                      ]),
                  Container(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Do Nguyen",
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .title
                                .copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.black54,
                                fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0, height: 16.0),
                  OFStoriesStream(
                    controller: _ofStoriesStreamController,
                    streamIdentifier: 'timeline',
                    onScrollLoader: _storiesStreamOnScrollLoader,
                    refresher: _storiesStreamRefresher,
                    initialStories: _initialStories,
                    prependedItems: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            OFPrimaryAccentText(_localizationService.post__top_posts_title,
                                style:
                                TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                            OFIconButton(
                              OFIcons.settings,
                              themeColor: OFIconThemeColor.primaryAccent,
                            )
                          ],
                        ),
                      )
                    ],
                  ),

                *//*  Flexible(
                    child: OFStories(
                      items: [],
                    )
                  )*//*
                ],
              ),
            ),
          ],
        ),
      ));*/
  }

  Widget _buildAddButton(BuildContext context) {
    return IconButton(
        icon: OFIcon(OFIconData(nativeIcon: D.add0),
          color: Colors.black54,
          size: OFIconSize.medium),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OFEditStoryPage()),
          );
        });
  }


  Future<void> _refreshStoriesList() async {
    debugPrint('Refreshing task list');
    //_setRefreshInProgress(true);
    try {
      //_getTaskList();
    } catch (error) {
      _onError(error);
    } finally {
      //_setRefreshInProgress(false);
    }
  }

  Future<List<Story>> _storiesStreamRefresher() async {
    List<Story> stories = (await _userService.getStories(
        count: 10))
        .stories;

    return stories;
  }

  Future<List<Story>> _storiesStreamOnScrollLoader(List<Story> stories) async {
    Story lastStory = stories.last;
    int lastStoryId = lastStory.id;

    List<Story> moreStories = (await _userService.getStories(
        maxId: lastStoryId,
        count: 10))
        .stories;

    return moreStories;
  }

  Future<bool> _onCreateStory() async {
    var route = MaterialPageRoute(builder: (BuildContext context) {
      return OFEditStoryPage();
    });
    await Navigator.of(context, rootNavigator: true).push(route);

    return true;
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
}

class OFStoryPageController extends PoppablePageController {
  OFStoryPageState _state;

  void attach({@required BuildContext context, OFStoryPageState state}) {
    super.attach(context: context);
    _state = state;
  }

  void scrollToTop() {
    _state.scrollToTop();
  }
}
