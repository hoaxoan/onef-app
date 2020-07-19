import 'package:flutter/cupertino.dart';
import 'package:onef/models/community.dart';
import 'package:onef/widgets/checkbox.dart';
import 'package:onef/widgets/tiles/community_tile.dart';

class OFCommunitySelectableTile extends StatelessWidget {
  final Community community;
  final ValueChanged<Community> onCommunityPressed;
  final bool isSelected;

  const OFCommunitySelectableTile(
      {Key key,
      @required this.community,
      @required this.onCommunityPressed,
      @required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onCommunityPressed(community);
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: OFCommunityTile(
              community,
              size: OFCommunityTileSize.small,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: OFCheckbox(
              value: isSelected,
            ),
          )
        ],
      ),
    );
  }
}
