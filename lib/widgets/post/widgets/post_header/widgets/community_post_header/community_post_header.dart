import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/bottom_sheet.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/navigation_service.dart';
import 'package:onef/services/utils_service.dart';
import 'package:onef/widgets/avatars/avatar.dart';
import 'package:onef/widgets/avatars/community_avatar.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/post/post.dart';
import 'package:onef/widgets/post/widgets/post_header/widgets/community_post_header/community_post_creator_identifier.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/theming/text.dart';

class OFCommunityPostHeader extends StatelessWidget {
  final Post _post;
  final OnPostDeleted onPostDeleted;
  final ValueChanged<Post> onPostReported;
  final bool hasActions;
  final OFPostDisplayContext displayContext;

  // What are we using these 2 for?
  final Function onCommunityExcluded;
  final Function onUndoCommunityExcluded;

  final ValueChanged<Community> onPostCommunityExcludedFromProfilePosts;

  const OFCommunityPostHeader(this._post,
      {Key key,
      @required this.onPostDeleted,
      this.onPostReported,
      this.hasActions = true,
      this.onCommunityExcluded,
      this.onUndoCommunityExcluded,
      this.displayContext = OFPostDisplayContext.timelinePosts,
      this.onPostCommunityExcludedFromProfilePosts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var navigationService = provider.navigationService;
    var bottomSheetService = provider.bottomSheetService;
    var localizationService = provider.localizationService;
    var utilsService = provider.utilsService;

    return StreamBuilder(
        stream: _post.community.updateSubject,
        initialData: _post.community,
        builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
          Community community = snapshot.data;

          return displayContext == OFPostDisplayContext.ownProfilePosts ||
                  displayContext == OFPostDisplayContext.foreignProfilePosts
              ? _buildCommunityHighlightHeader(
                  context: context,
                  community: community,
                  navigationService: navigationService,
                  bottomSheetService: bottomSheetService,
                  utilsService: utilsService,
                  localizationService: localizationService)
              : _buildUserHighlightHeader(
                  context: context,
                  community: community,
                  navigationService: navigationService,
                  bottomSheetService: bottomSheetService);
        });
  }

  Widget _buildCommunityHighlightHeader(
      {BuildContext context,
      Community community,
      NavigationService navigationService,
      BottomSheetService bottomSheetService,
      UtilsService utilsService,
      LocalizationService localizationService}) {
    String created = utilsService.timeAgo(_post.created, localizationService);

    return ListTile(
        leading: OFCommunityAvatar(
          community: community,
          size: OFAvatarSize.medium,
          onPressed: () {
            navigationService.navigateToCommunity(
                community: community, context: context);
          },
        ),
        trailing: hasActions
            ? IconButton(
                icon: const OFIcon(OFIcons.moreVertical),
                onPressed: () {
                  bottomSheetService.showPostActions(
                      context: context,
                      post: _post,
                      displayContext: displayContext,
                      onCommunityExcluded: onCommunityExcluded,
                      onUndoCommunityExcluded: onUndoCommunityExcluded,
                      onPostCommunityExcludedFromProfilePosts:
                          onPostCommunityExcludedFromProfilePosts,
                      onPostDeleted: onPostDeleted,
                      onPostReported: onPostReported);
                })
            : null,
        title: GestureDetector(
          onTap: () {
            navigationService.navigateToCommunity(
                community: community, context: context);
          },
          child: OFText(
            community.title,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: GestureDetector(
          onTap: () {
            navigationService.navigateToCommunity(
                community: community, context: context);
          },
          child: Row(
            children: <Widget>[
              Expanded(
                child: OFSecondaryText(
                  'c/' + community.name + ' · $created',
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildUserHighlightHeader(
      {BuildContext context,
      Community community,
      NavigationService navigationService,
      BottomSheetService bottomSheetService}) {
    return ListTile(
      leading: OFAvatar(
        avatarUrl: _post.creator.getProfileAvatar(),
        size: OFAvatarSize.medium,
        onPressed: () {
          navigationService.navigateToUserProfile(
              user: _post.creator, context: context);
        },
      ),
      trailing: hasActions
          ? IconButton(
              icon: const OFIcon(OFIcons.moreVertical),
              onPressed: () {
                bottomSheetService.showPostActions(
                    context: context,
                    post: _post,
                    displayContext: displayContext,
                    onCommunityExcluded: onCommunityExcluded,
                    onUndoCommunityExcluded: onUndoCommunityExcluded,
                    onPostCommunityExcludedFromProfilePosts:
                        onPostCommunityExcludedFromProfilePosts,
                    onPostDeleted: onPostDeleted,
                    onPostReported: onPostReported);
              })
          : null,
      title: GestureDetector(
        onTap: () {
          navigationService.navigateToCommunity(
              community: community, context: context);
        },
        child: Row(
          children: <Widget>[
            OFCommunityAvatar(
              borderRadius: 4,
              customSize: 16,
              community: community,
              onPressed: () {
                navigationService.navigateToCommunity(
                    community: community, context: context);
              },
              size: OFAvatarSize.extraSmall,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: OFText(
                'c/' + community.name,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      subtitle: OFCommunityPostCreatorIdentifier(
        post: _post,
        onUsernamePressed: () {
          navigationService.navigateToUserProfile(
              user: _post.creator, context: context);
        },
      ),
    );
  }
}
