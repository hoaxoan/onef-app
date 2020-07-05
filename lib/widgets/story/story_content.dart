import 'package:flutter/material.dart';
import 'package:onef/widgets/story/finishing.dart';
import 'package:onef/widgets/story/how_you_feel.dart';
import 'package:onef/widgets/story/story_select_date.dart';
import 'package:onef/widgets/story/what_made_today.dart';

class OFStoryContent extends StatefulWidget {

  OFStoryContent();
  @override
  State<OFStoryContent> createState() {
    return OFStoryContentState();
  }
}

class OFStoryContentState extends State<OFStoryContent> {
  var currentPage = 0;
  PageController _controller;

  OFStoryContentState();

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    if (_controller.hasClients) {
      _controller.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 1200),
        curve: Curves.ease,
      );
    }

    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _controller,
      scrollDirection: Axis.vertical,
      onPageChanged: onPageChanged,
      children: <Widget>[
        OFStorySelectDate(controller: _controller),
        OFHowYouFeel(controller: _controller),
        OFWhatMadeToday(controller: _controller),
        /*CoverStory(),*/
       ListView(
          children: <Widget>[
            SizedBox(
              height: height,
              child: OFFinishing(controller: _controller),
            )
          ],
        ),
      ],
    );
  }

  onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }
}
