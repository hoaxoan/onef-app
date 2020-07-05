import 'package:onef/models/follows_list.dart';

class FollowsListsList {
  final List<FollowsList> lists;

  FollowsListsList({
    this.lists,
  });

  factory FollowsListsList.fromJson(List<dynamic> parsedJson) {
    List<FollowsList> lists =
        parsedJson.map((listJson) => FollowsList.fromJSON(listJson)).toList();

    return FollowsListsList(
      lists: lists,
    );
  }
}
