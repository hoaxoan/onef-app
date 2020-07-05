import 'package:flutter/material.dart';
import 'package:onef/widgets/progress_indicator.dart';

class OFLoadingIndicatorTile extends StatelessWidget {
  const OFLoadingIndicatorTile();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Center(
        child: OFProgressIndicator(),
      ),
    );
  }
}
