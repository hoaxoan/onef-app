import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/secondary_text.dart';

class OFPostComments extends StatelessWidget {
  final Post _post;

  OFPostComments(this._post);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: _post.updateSubject,
      initialData: _post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        int commentsCount = _post.commentsCount;
        var provider = OneFProvider.of(context);
        var navigationService = provider.navigationService;
        LocalizationService _localizationService = provider.localizationService;

        bool isClosed = _post.isClosed ?? false;
        bool hasComments = commentsCount != null && commentsCount > 0;
        bool areCommentsEnabled = _post.areCommentsEnabled ?? true;
        bool canDisableOrEnableCommentsForPost = false;

        if (!areCommentsEnabled) {
          canDisableOrEnableCommentsForPost = provider.userService
              .getLoggedInUser()
              .canDisableOrEnableCommentsForPost(_post);
        }

        List<Widget> rowItems = [];

        if (hasComments) {
          rowItems.add(GestureDetector(
            onTap: () {
              navigationService.navigateToPostComments(
                  post: _post, context: context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: OFSecondaryText(_localizationService.post__comments_view_all_comments(commentsCount)),
            ),
          ));
        }

        if (isClosed ||
            (!areCommentsEnabled && canDisableOrEnableCommentsForPost)) {
          List<Widget> secondaryItems = [];

          if (isClosed) {
            secondaryItems.add(Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const OFIcon(
                  OFIcons.closePost,
                  size: OFIconSize.small,
                ),
                const SizedBox(
                  width: 10,
                ),
                OFSecondaryText(_localizationService.post__comments_closed_post)
              ],
            ));
          }

          if (!areCommentsEnabled && canDisableOrEnableCommentsForPost) {
            secondaryItems.add(Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const OFIcon(
                  OFIcons.disableComments,
                  size: OFIconSize.small,
                ),
                const SizedBox(
                  width: 10,
                ),
                OFSecondaryText(_localizationService.post__comments_disabled)
              ],
            ));
          }

          rowItems.addAll([
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: secondaryItems,
              ),
            )
          ]);
        }

        return Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Row(children: rowItems)],
          ),
        );
      },
    );
  }
}

typedef void OnWantsToSeePostComments(Post post);
