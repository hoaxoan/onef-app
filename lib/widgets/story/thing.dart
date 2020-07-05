import 'package:flutter/material.dart';
import 'package:onef/models/category.dart';
import 'file:///G:/reaction/onef/lib/widgets/shadowed_box.dart';
import 'package:onef/widgets/theming/text.dart';

class OFThing extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Color color;
  final Category category;
  final ValueChanged<Category> onThingTaped;

  const OFThing(this.iconData,
      {Key key,
        @required this.title,
        this.category,
        this.color = Colors.white,
        this.onThingTaped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
   /* return GestureDetector(
        onTapUp: (detail) async {
    }, child: _OFThingItem(
      iconData: iconData,
      selected: true,
      color: color,
      title: title,
    ));*/
    return GestureDetector(
      onTap: () => onThingTaped(category),
      child: OFShadowedBox(
        borderRadius: BorderRadius.circular(8.0),
        spreadRadius: -8.0,
        child: _OFThingItem(
          iconData: iconData,
          selected: true,
          color: color,
          title: title,
        ),
      ),
    );
  }
}

class _OFThingItem extends StatelessWidget {
  const _OFThingItem({
    Key key,
    @required this.iconData,
    @required this.selected,
    @required this.color,
    @required this.title,
  }) : super(key: key);

  final IconData iconData;
  final bool selected;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          iconData,
          color: selected ? primaryColor : color,
          size: 32.0,
        ),
        SizedBox(width: 8.0, height: 8.0),
        OFText(
          title,
          style: Theme.of(context).textTheme.subhead.copyWith(
            color: selected ? primaryColor : Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
