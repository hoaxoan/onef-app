import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/nav_bars/themed_nav_bar.dart';
import 'package:onef/widgets/page_scaffold.dart';
import 'package:onef/widgets/post/post.dart';
import 'package:onef/widgets/theming/primary_color_container.dart';

class OFPostPage extends StatefulWidget {
  final Post post;

  OFPostPage(this.post);

  @override
  State<OFPostPage> createState() {
    return OFPostPageState();
  }
}

class OFPostPageState extends State<OFPostPage> {
  UserService _userService;
  ToastService _toastService;

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _userService = provider.userService;
    _toastService = provider.toastService;

    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }

    return OFCupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OFThemedNavigationBar(
          title: 'Post',
        ),
        child: OFPrimaryColorContainer(
          child: Column(
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    child: ListView(
                      padding: const EdgeInsets.all(0),
                      physics: const ClampingScrollPhysics(),
                      children: <Widget>[
                        StreamBuilder(
                            stream: widget.post.updateSubject,
                            initialData: widget.post,
                            builder: _buildPost)
                      ],
                    ),
                    onRefresh: _refreshPost),
              ),
            ],
          ),
        ));
  }

  Widget _buildPost(BuildContext context, AsyncSnapshot<Post> snapshot) {
    Post latestPost = snapshot.data;

    return OFPost(
      latestPost,
      key: Key(latestPost.id.toString()),
      onPostDeleted: _onPostDeleted,
    );
  }

  void _onPostDeleted(Post post) {
    Navigator.pop(context);
  }

  void _bootstrap() async {
    await _refreshPost();
  }

  Future<void> _refreshPost() async {
    try {
      // This will trigger the updateSubject of the post
      await _userService.getPostWithUuid(widget.post.uuid);
    } catch (error) {
      _onError(error);
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
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }
}
