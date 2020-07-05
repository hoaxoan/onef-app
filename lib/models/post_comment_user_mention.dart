import 'package:onef/models/post_comment.dart';
import 'package:onef/models/user.dart';

class PostCommentUserMention {
  final int id;
  final User user;
  final PostComment postComment;

  PostCommentUserMention({
    this.id,
    this.user,
    this.postComment,
  });

  factory PostCommentUserMention.fromJSON(Map<String, dynamic> parsedJson) {
    return PostCommentUserMention(
      id: parsedJson['id'],
      user: parseUser(parsedJson['user']),
      postComment: parsePostComment(parsedJson['post_comment']),
    );
  }

  static User parseUser(Map userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  static PostComment parsePostComment(Map postCommentData) {
    if (postCommentData == null) return null;
    return PostComment.fromJSON(postCommentData);
  }
}
