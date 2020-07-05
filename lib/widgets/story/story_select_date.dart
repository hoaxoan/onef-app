import 'package:flutter/material.dart';
import 'package:onef/pages/home/pages/story/blocs/create_story.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/theming/text.dart';

class OFStorySelectDate extends StatefulWidget {

  final PageController controller;
  const OFStorySelectDate({Key key, @required this.controller})
      : assert(controller != null),
  super(key: key);

  @override
  _OFStorySelectDateState createState() => _OFStorySelectDateState();
}

class _OFStorySelectDateState extends State<OFStorySelectDate> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(width: 80.0, height: 80.0),
        _OFGreeting(),
        //SelectDate(),
        _OFLetsDoIt(controller: widget.controller),
      ],
    );
  }
}

class _OFGreeting extends StatelessWidget {
  const _OFGreeting({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: OFText(
        "Create new story",
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headline
            .copyWith(color: Colors.white70),
      ),
    );
  }
}

class _OFLetsDoIt extends StatelessWidget {
  CreateStoryBloc _createStoryBloc;
  PageController controller;
  _OFLetsDoIt({Key key, @required this.controller})
      : assert(controller != null),
        super(key: key);

  factory _OFLetsDoIt.forDesignTime() => _OFLetsDoIt();

  @override
  Widget build(BuildContext context) {

    var provider = OneFProvider.of(context);
    _createStoryBloc = provider.createStoryBloc;

    return FractionallySizedBox(
      widthFactor: 0.8,
      child: RaisedButton(
        elevation: 8.0,
        padding: EdgeInsets.symmetric(vertical: 16.0),
        onPressed: () {
          _createStoryBloc.setCurrentPage(1);
          if (controller.hasClients) {
            controller.animateToPage(
              _createStoryBloc.getCurrentPage(),
              duration: Duration(milliseconds: 1200),
              curve: Curves.ease,
            );
          }
          //controller.nextPage(duration: Duration(milliseconds: 1200), curve: null);
        },
        shape: StadiumBorder(),
        color: Colors.white,
        child: Text(
          "Do It",
          style: Theme.of(context).textTheme.subhead.copyWith(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(89, 157, 166, 1)
          ),
        ),
      ),
    );
  }
}
