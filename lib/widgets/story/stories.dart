import 'package:flutter/material.dart';
import 'package:onef/models/story.dart';
import 'package:onef/widgets/story/history_story_card.dart';
import 'package:onef/widgets/story/new_story_card.dart';

class OFStories extends StatefulWidget {
  final List<Story> items;
  final ValueChanged<Story> dismissed;
  final ValueChanged<Story> navigateToDetail;
  final ValueChanged<Story> favorite;
  final VoidCallback listRefresh;
  final VoidCallback navigateToNewStory;

  OFStories(
      {this.items,
        this.dismissed,
        this.navigateToDetail,
        this.favorite,
        this.listRefresh,
        this.navigateToNewStory});

  @override
  OFStoriesState createState() => OFStoriesState(
      this.items,
      this.dismissed,
      this.navigateToDetail,
      this.favorite,
      this.listRefresh,
      this.navigateToNewStory);
}

class OFStoriesState extends State<OFStories> with SingleTickerProviderStateMixin {
  final List<Story> items;
  final ValueChanged<Story> dismissed;
  final ValueChanged<Story> navigateToDetail;
  final ValueChanged<Story> favorite;
  final VoidCallback listRefresh;
  final VoidCallback navigateToNewStory;

  OFStoriesState(this.items, this.dismissed, this.navigateToDetail, this.favorite,
      this.listRefresh, this.navigateToNewStory);

  PageController _controller;
  double _normalizedOffset = 0;
  double _prevScrollX = 0;
  bool _isScrolling = false;

  AnimationController _tweenController;
  Tween<double> _tween;
  Animation<double> _tweenAnim;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {

    _controller = PageController(viewportFraction: 0.8);
   /* _controller.animateToPage(
      currentPage,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );*/

    if (items == null || items.length == 0) {
      return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double factor = 1.0;
            factor = (1 - (factor.abs() * .2)).clamp(0.8, 1.0);
            return Transform.scale(
              scale: Curves.easeOut.transform(1.0),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0),
            child: OFNewStoryCard(navigateToNewStory: navigateToNewStory),
          ));
    }

    //Create our main list
    Widget content = PageView.builder(
      controller: _controller,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      onPageChanged: (page) async {
        setState(() {
          currentPage = page;
        });

        _controller.animateToPage(
          page,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      },
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double factor = 1.0;
            if (_controller.position.haveDimensions) {
              factor = _controller.page - index;
              factor = (1 - (factor.abs() * .2)).clamp(0.8, 1.0);
            }
            return Transform.scale(
              scale: Curves.easeOut.transform(factor),
              child: child,
            );
          },
          child: OFHistoryStoryCard(
              story: items[index],
              favorite: favorite,
              navigateToDetail: navigateToDetail),
        );
      },
    );

    //Wrap our list content in a Listener to detect PointerUp events, and a NotificationListener to detect ScrollStart and ScrollUpdate
    //We have to use both, because NotificationListener does not inform us when the user has lifted their finger.
    //We can not use GestureDetector like we normally would, ListView suppresses it while scrolling.
    /*return Listener(
      onPointerUp: _handlePointerUp,
      child: NotificationListener(
        onNotification: _handleScrollNotifications,
        child: content,
      ),
    );*/

    return content;
  }

  //Check the notifications bubbling up from the ListView, use them to update our currentOffset and isScrolling state
  bool _handleScrollNotifications(Notification notification) {
    //Scroll Update, add to our current offset, but clamp to -1 and 1
    if (notification is ScrollUpdateNotification) {
      if (_isScrolling) {
        double dx = notification.metrics.pixels - _prevScrollX;
        double scrollFactor = .01;
        double newOffset = (_normalizedOffset + dx * scrollFactor);
        _setOffset(newOffset.clamp(-1.0, 1.0));
      }
      _prevScrollX = notification.metrics.pixels;
      //Calculate the index closest to middle
      //_focusedIndex = (_prevScrollX / (_itemWidth + _listItemPadding)).round();
    }
    //Scroll Start
    else if (notification is ScrollStartNotification) {
      _isScrolling = true;
      _prevScrollX = notification.metrics.pixels;
      if (_tween != null) {
        _tweenController.stop();
      }
    }
    return true;
  }

  //If the user has released a pointer, and is currently scrolling, we'll assume they're done scrolling and tween our offset to zero.
  //This is a bit of a hack, we can't be sure this event actually came from the same finger that was scrolling, but should work most of the time.
  void _handlePointerUp(PointerUpEvent event) {
    if (_isScrolling) {
      _isScrolling = false;
      _startOffsetTweenToZero();
    }
  }

  //Helper function, any time we change the offset, we want to rebuild the widget tree, so all the renderers get the new value.
  void _setOffset(double value) {
    setState(() {
      _normalizedOffset = value;
    });
  }

  //Tweens our offset from the current value, to 0
  void _startOffsetTweenToZero() {
    //The first time this runs, setup our controller, tween and animation. All 3 are required to control an active animation.
    int tweenTime = 1000;
    if (_tweenController == null) {
      //Create Controller, which starts/stops the tween, and rebuilds this widget while it's running
      _tweenController = AnimationController(
          vsync: this, duration: Duration(milliseconds: tweenTime));
      //Create Tween, which defines our begin + end values
      _tween = Tween<double>(begin: -1, end: 0);
      //Create Animation, which allows us to access the current tween value and the onUpdate() callback.
      _tweenAnim = _tween.animate(new CurvedAnimation(
          parent: _tweenController, curve: Curves.elasticOut))
      //Set our offset each time the tween fires, triggering a rebuild
        ..addListener(() {
          _setOffset(_tweenAnim.value);
        });
    }
    //Restart the tweenController and inject a new start value into the tween
    _tween.begin = _normalizedOffset;
    _tweenController.reset();
    _tween.end = 0;
    _tweenController.forward();
  }
}
