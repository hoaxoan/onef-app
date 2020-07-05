import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFPostActionComment extends StatelessWidget {
  final Post _post;
  final VoidCallback onWantsToCommentPost;

  OFPostActionComment(this._post, {this.onWantsToCommentPost});

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var navigationService = provider.navigationService;
    var localizationService = provider.localizationService;

    return OFButton(
        type: OFButtonType.highlight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const OFIcon(
              OFIcons.comment,
              customSize: 20.0,
            ),
            const SizedBox(
              width: 10.0,
            ),
            OFText(localizationService.trans('post__action_comment')),
          ],
        ),
        onPressed: () {
          if (onWantsToCommentPost != null) {
            onWantsToCommentPost();
          } else {
            navigationService.navigateToCommentPost(
                post: _post, context: context);
          }
        });
  }
}

typedef void OnWantsToCommentPost(Post post);
