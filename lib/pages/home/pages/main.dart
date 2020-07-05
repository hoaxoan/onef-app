import 'package:flutter/material.dart';
import 'package:onef/libs/ui/placeholder/placeholder_card_tall.dart';
import 'package:onef/pages/home/lib/poppable_page_controller.dart';

class OFMainPage extends StatefulWidget {
  final OFMainPageController controller;

  OFMainPage({
    @required this.controller,
  });

  @override
  OFMainPageState createState() {
    return OFMainPageState();
  }
}

class OFMainPageState extends State<OFMainPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.attach(context: context, state: this);
  }

  @override
  Widget build(context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: ListView.builder(
        itemCount: 9,
        itemBuilder: (content, index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: PlaceholderCardTall(
                height: 200,
                color: Color(0xFF99D3F7),
                backgroundColor: Color(0xFFC7EAFF)),
          );
        },
      ),
    );
  }

  void scrollToTop() {
    //_timelinePostsStreamController.scrollToTop();
  }
}

class OFMainPageController extends PoppablePageController {
  OFMainPageState _state;

  void attach({@required BuildContext context, OFMainPageState state}) {
    super.attach(context: context);
    _state = state;
  }

  void scrollToTop() {
    _state.scrollToTop();
  }
}
