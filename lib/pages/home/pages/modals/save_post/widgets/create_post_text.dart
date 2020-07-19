import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/widgets/fields/text_field.dart';

class OFCreatePostText extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;

  OFCreatePostText({this.controller, this.focusNode, this.hintText});

  @override
  Widget build(BuildContext context) {
    return OFTextField(
      textInputAction: TextInputAction.newline,
      controller: controller,
      autofocus: true,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: this.hintText != null ? this.hintText : 'What\'s going on?',
      ),
      autocorrect: true,
    );
  }
}
