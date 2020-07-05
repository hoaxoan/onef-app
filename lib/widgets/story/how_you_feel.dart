import 'package:flutter/material.dart';
import 'package:onef/models/mood.dart';
import 'package:onef/models/moods_list.dart';
import 'package:onef/pages/home/pages/story/blocs/create_story.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/moods_api.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/story/question.dart';
import 'package:onef/widgets/theming/text.dart';

class OFHowYouFeel extends StatelessWidget {
  final PageController controller;
  const OFHowYouFeel({Key key, @required this.controller})
      : assert(controller != null),
        super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(height: 100.0),
        OFQuestion("How you feeling?"),
        Flexible(
            child: _OFFeel(controller: controller)),
      ],
    );
  }
}

class _OFFeel extends StatefulWidget {
  final PageController controller;
  const _OFFeel({Key key, @required this.controller})
      : assert(controller != null),
        super(key: key);

  @override
  _OFFeelState createState() {
    return _OFFeelState();
  }
}

class _OFFeelState extends State<_OFFeel> {
  final _controller = PageController(viewportFraction: 0.35);

  CreateStoryBloc _createStoryBloc;
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;

  bool _needsBootstrap;
  List<Mood> _moods;

  @override
  void initState() {
    super.initState();
    _moods = [];
    _needsBootstrap = true;
  }


  @override
  void dispose() {
    _controller.dispose();
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

      _loadMoodsList();

      _needsBootstrap = false;
    }

    return PageView.builder(
      controller: _controller,
      itemCount: _moods.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double iconFactor = 1.0;
            double labelFactor = 1.0;
            if (_controller.position.haveDimensions) {
              iconFactor = _controller.page - index;
              iconFactor = (1 - (iconFactor.abs() * .6)).clamp(0.4, 1.0);

              labelFactor = _controller.page - index;
              labelFactor = (1 - labelFactor.abs()).clamp(0.0, 1.0);
            } else if (index == 1) {
              iconFactor = 0.5;
              labelFactor = 0.0;
            }

            return Transform.scale(
              scale: Curves.easeOut.transform(iconFactor),
              child: GestureDetector(
                  onTap: () async {
                    _createStoryBloc.setMood(_moods[index]);
                    _createStoryBloc.setCurrentPage(_createStoryBloc.getCurrentPage() + 1);
                    if (widget.controller.hasClients) {
                      widget.controller.animateToPage(
                        _createStoryBloc.getCurrentPage(),
                        duration: Duration(milliseconds: 1200),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        new IconData(int.parse(_moods[index].code),
                            fontFamily: 'ReflectlyIcons'),
                        size: 80.0,
                        color: Colors.white.withOpacity(iconFactor),
                      ),
                      SizedBox(width: 16.0, height: 16.0),
                      OFText(
                        _moods[index].name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(labelFactor),
                        ),
                      ),
                    ],
                  )),
            );
          },
        );
      },
    );
  }

  void _setMoods(List<Mood> moods) {
    setState(() {
      _moods = moods;
    });
  }

  Future<void> _loadMoodsList() async {
    debugPrint('Refreshing moods list');
    //_setRefreshInProgress(true);
    try {
      var moodsList = await _userService.getMoods();
      _setMoods(moodsList.moods);
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
}
