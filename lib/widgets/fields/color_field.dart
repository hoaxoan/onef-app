import 'package:flutter/material.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/dialog.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/widgets/theming/divider.dart';
import 'package:onef/widgets/theming/text.dart';
import 'package:pigment/pigment.dart';

class OFColorField extends StatefulWidget {
  final String initialColor;
  final String labelText;
  final String hintText;
  final OnNewColor onNewColor;

  const OFColorField(
      {Key key,
      this.initialColor,
      this.labelText,
      @required this.onNewColor,
      this.hintText})
      : super(key: key);

  @override
  OFColorFieldState createState() {
    return OFColorFieldState();
  }
}

class OFColorFieldState extends State<OFColorField> {
  String _color;
  ThemeService _themeService;
  DialogService _dialogService;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor != null
        ? widget.initialColor
        : generateRandomHexColor();
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _themeService = provider.themeService;
    _dialogService = provider.dialogService;

    return Column(
      children: <Widget>[
        MergeSemantics(
          child: ListTile(
              title: OFText(
                widget.labelText,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle:
                  widget.hintText != null ? OFText(widget.hintText) : null,
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: _color == null
                      ? const SizedBox()
                      : Pigment.fromString(_color),
                ),
                height: 30,
                width: 30,
              ),
              onTap: _pickColor),
        ),
        OFDivider(),
      ],
    );
  }

  void _pickColor() {
    _dialogService.showColorPicker(
        initialColor: Pigment.fromString(_color),
        onColorChanged: _onPickerColor,
        context: context);
  }

  void _onPickerColor(Color color) {
    String hexString = color.value.toRadixString(16);
    hexString = '#' + hexString.substring(2, hexString.length);
    widget.onNewColor('#' + hexString);
    _setColor(hexString);
  }

  void _setColor(String color) {
    setState(() {
      _color = color;
      widget.onNewColor(_color);
    });
  }

  Color generateRandomColor() {
    return Pigment.fromString(generateRandomHexColor());
  }

  String generateRandomHexColor() {
    return _themeService.generateRandomHexColor();
  }
}

typedef void OnNewColor(String color);
