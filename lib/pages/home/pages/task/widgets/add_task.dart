import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/task.dart';
import 'package:onef/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/fields/text_field.dart';
import 'package:onef/widgets/theming/text.dart';

class OFAddTaskBottomSheet extends StatefulWidget {
  @override
  OFAddTaskBottomSheetState createState() => OFAddTaskBottomSheetState();
}

class OFAddTaskBottomSheetState extends State<OFAddTaskBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerDetails = TextEditingController();
  final FocusNode _detailsFocus = FocusNode();
  bool _showDetails = false;
  DateTime _date;

  UserService _userService;
  ToastService _toastService;

  bool _isAddInProgress;
  CancelableOperation _addOperation;

  @override
  void initState() {
    super.initState();
    _showDetails = false;
    _controller.clear();
    _controllerDetails.clear();

    _isAddInProgress = false;
  }

  @override
  void dispose() {
    super.dispose();
    _detailsFocus.dispose();
    if (_addOperation != null) _addOperation.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _userService = provider.userService;
    _toastService = provider.toastService;

    double screenHeight = MediaQuery.of(context).size.height;

    return OFRoundedBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: screenHeight / 3,
            child: IgnorePointer(
              ignoring: _isAddInProgress,
              child: Opacity(
                opacity: _isAddInProgress ? 0.5 : 1,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: new Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        OFTextField(
                          controller: _controller,
                          autofocus: true,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "New Task",
                              hintStyle:
                                  TextStyle(fontWeight: FontWeight.w500)),
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: "GoogleSans"),
                        ),
                        _showDetails
                            ? OFTextField(
                                controller: _controllerDetails,
                                focusNode: _detailsFocus,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Description",
                                  hintStyle: TextStyle(fontSize: 16.0),
                                ),
                                autocorrect: false,
                                keyboardType: TextInputType.text,
                                style: TextStyle(fontSize: 16.0),
                              )
                            : Container(
                                height: 0.0,
                              ),
                        /*    _date == null
                            ? Container(height: 0.0)
                            : DateViewWidget(
                                date: _date,
                                onClose: () {
                                  setState(() {
                                    _date = null;
                                  });
                                },
                              ),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            /*FancyFab(
                              icon: Icons.add,
                              detailsPressed: () {
                                setState(() => _showDetails = true);
                                // FocusScope.of(context).requestFocus(_detailsFocus);
                              },
                              datePressed: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: _date ?? DateTime.now(),
                                  firstDate: (_date ?? DateTime.now())
                                      .subtract(Duration(days: 30)),
                                  lastDate: (_date ?? DateTime.now())
                                      .add(Duration(days: 365)),
                                ).then((value) {
                                  if (value == null) return;
                                  print("Date: ${value.toIso8601String()}");
                                  setState(() {
                                    _date = value;
                                  });
                                }).catchError((error) {
                                  print(error.toString());
                                });
                              },
                            ),*/
                            FlatButton(
                              child: OFText(
                                "Save",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.pop(
                                    context,
                                    Task(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch,
                                        name: _controller.text.toString(),
                                        description: _controllerDetails.text
                                            .toString()));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
