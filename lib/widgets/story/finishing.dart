import 'package:flutter/material.dart';
import 'package:onef/pages/home/pages/story/blocs/create_story.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/story/bi_operate.dart';
import 'package:onef/widgets/story/question.dart';

class OFFinishing extends StatefulWidget {

  final PageController controller;
  const OFFinishing({Key key, @required this.controller})
      : assert(controller != null),
        super(key: key);

  @override
  _OFFinishingState createState() {
    return _OFFinishingState();
  }
}

class _OFFinishingState extends State<OFFinishing> {
  int _textCount = 0;

  CreateStoryBloc _createStoryBloc;
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;

  bool _needsBootstrap;
  bool mustRequestCreateStory;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    mustRequestCreateStory = true;
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
      _needsBootstrap = false;
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(height: 96.0),
        OFQuestion("Want to give your story a title?"),
        TextField(
          onChanged: (title) {
            setState(() {
              _createStoryBloc.setTitle(title);
              _textCount = title.length;
            });
          },
          cursorColor: Colors.white70,
          cursorWidth: 1.0,
          style: Theme.of(context)
              .textTheme
              .headline
              .copyWith(color: Colors.white70),
          decoration: InputDecoration(
            counterText: '$_textCount / 40',
            helperText: 'TITLE OF THE DAY',
            helperStyle: Theme.of(context)
                .textTheme
                .caption
                .copyWith(color: Colors.white30),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            border: InputBorder.none,
            hintText: "Add title...",
            hintStyle: Theme.of(context)
                .textTheme
                .headline
                .copyWith(color: Colors.white70, fontFamily: 'Avenir'),
          ),
        ),
        OFBiOperate(
          positiveLabel: "SAVE YOUR STORY",
          negativeLabel: "WAIT, I FORGOT SOMETHING!",
          color: Color.fromRGBO(89, 157, 166, 1),
          onPositivePressed: () async {
            _requestCreateStory();
          },
          onNegativePressed: () {
            if (widget.controller.hasClients) {
              widget.controller.animateToPage(
                _createStoryBloc.getCurrentPage() - 1,
                duration: Duration(milliseconds: 1200),
                curve: Curves.ease,
              );
            }
          },
        ),
      ],
    );
  }

  void _requestCreateStory() async {
    bool createdStory = await _createStoryBloc.createStory();
    if (createdStory) {
      _createStoryBloc.clearAll();
      Navigator.pop(context); //pop this form screen
    }
    mustRequestCreateStory = false;
  }
}
