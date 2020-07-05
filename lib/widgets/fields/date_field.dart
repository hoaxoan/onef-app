import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFDateField extends StatefulWidget {
  final String title;
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;
  final DateTime minimumDate;
  final DateTime maximumDate;

  const OFDateField(
      {Key key,
      @required this.title,
      @required this.initialDate,
      this.onChanged,
      @required this.minimumDate,
      @required this.maximumDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFDateFieldState();
  }
}

class OFDateFieldState extends State<OFDateField> {
  DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var datePickerService = provider.datePickerService;

    return MergeSemantics(
      child: ListTile(
        leading: const OFIcon(OFIcons.cake),
        title: OFText(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: OFText(DateFormat.yMMMMd().format(_currentDate)),
        onTap: () {
          datePickerService.pickDate(
              maximumDate: widget.maximumDate,
              minimumDate: widget.minimumDate,
              context: context,
              initialDate: widget.initialDate,
              onDateChanged: (DateTime newDate) {
                setState(() {
                  _currentDate = newDate;
                });

                widget.onChanged(newDate);
              });
        },
      ),
    );
  }
}
