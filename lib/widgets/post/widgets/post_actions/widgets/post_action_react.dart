import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_reaction.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFPostActionReact extends StatefulWidget {
  final Post post;

  OFPostActionReact(this.post);

  @override
  State<StatefulWidget> createState() {
    return OFPostActionReactState();
  }
}

class OFPostActionReactState extends State<OFPostActionReact> {
  CancelableOperation _clearPostReactionOperation;
  bool _clearPostReactionInProgress;
  LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    _clearPostReactionInProgress = false;
  }

  @override
  void dispose() {
    super.dispose();
    if (_clearPostReactionOperation != null)
      _clearPostReactionOperation.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _localizationService = provider.localizationService;

    return StreamBuilder(
      stream: widget.post.updateSubject,
      initialData: widget.post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        Post post = snapshot.data;
        PostReaction reaction = post.reaction;
        bool hasReaction = reaction != null;

        Widget buttonChild = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            hasReaction
                ? CachedNetworkImage(
                    height: 18.0,
                    imageUrl: reaction.getEmojiImage(),
                    errorWidget:
                        (BuildContext context, String url, Object error) {
                      return SizedBox(
                        child: Center(child: Text('?')),
                      );
                    },
                  )
                : const OFIcon(
                    OFIcons.react,
                    customSize: 20.0,
                  ),
            const SizedBox(
              width: 10.0,
            ),
            OFText(
              hasReaction ? reaction.getEmojiKeyword() : _localizationService.post__action_react,
              style: TextStyle(
                color: hasReaction ? Colors.white : null,
                fontWeight: hasReaction ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );

        return OFButton(
          child: buttonChild,
          isLoading: _clearPostReactionInProgress,
          onPressed: _onPressed,
          type: hasReaction ? OFButtonType.primary : OFButtonType.highlight,
        );
      },
    );
  }

  void _onPressed() {
    if (widget.post.hasReaction()) {
      _clearPostReaction();
    } else {
      var provider = OneFProvider.of(context);
      provider.bottomSheetService.showReactToPost(post: widget.post, context: context);
    }
  }

  Future _clearPostReaction() async {
    if (_clearPostReactionInProgress) return;
    _setClearPostReactionInProgress(true);
    var provider = OneFProvider.of(context);

    try {
      _clearPostReactionOperation = CancelableOperation.fromFuture(
          provider.userService.deletePostReaction(postReaction: widget.post.reaction, post: widget.post));

      await _clearPostReactionOperation.value;
      widget.post.clearReaction();
    } catch (error) {
      _onError(error: error, provider: provider);
    } finally {
      _clearPostReactionOperation = null;
      _setClearPostReactionInProgress(false);
    }
  }

  void _setClearPostReactionInProgress(bool clearPostReactionInProgress) {
    setState(() {
      _clearPostReactionInProgress = clearPostReactionInProgress;
    });
  }

  void _onError(
      {@required error,
      @required OneFProviderState provider}) async {
    ToastService toastService = provider.toastService;

    if (error is HttpieConnectionRefusedError) {
      toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      toastService.error(message: errorMessage, context: context);
    } else {
      toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }
}

typedef void OnWantsToReactToPost(Post post);
