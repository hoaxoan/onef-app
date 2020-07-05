
import 'package:onef/models/post.dart';
import 'package:onef/models/user.dart';

class PostUserMention {
  final int id;
  final User user;
  final Post post;

  PostUserMention({
    this.id,
    this.user,
    this.post,
  });

  factory PostUserMention.fromJSON(Map<String, dynamic> parsedJson) {
    return PostUserMention(
      id: parsedJson['id'],
      user: parseUser(parsedJson['user']),
      post: parsePost(parsedJson['post']),
    );
  }

  static User parseUser(Map userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  static Post parsePost(Map postData) {
    if (postData == null) return null;
    return Post.fromJson(postData);
  }
}
