import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onef/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFImagePickerBottomSheet extends StatelessWidget {
  const OFImagePickerBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);

    LocalizationService localizationService = provider.localizationService;

    List<Widget> imagePickerActions = [
      ListTile(
        leading: const OFIcon(OFIcons.gallery),
        title: OFText(
          localizationService.image_picker__from_gallery,
        ),
        onTap: () async {
          bool permissionGranted = await provider.permissionService
              .requestStoragePermissions(context: context);
          if (permissionGranted) {
            File file = await FilePicker.getFile(type: FileType.image);
            Navigator.pop(context, file);
          }
        },
      ),
      ListTile(
        leading: const OFIcon(OFIcons.camera),
        title: OFText(
          localizationService.image_picker__from_camera,
        ),
        onTap: () async {
          bool permissionGranted = await provider.permissionService
              .requestCameraPermissions(context: context);
          if (permissionGranted) {
            File pickedImage =
            await ImagePicker.pickImage(source: ImageSource.camera);
            Navigator.pop(context, pickedImage);
          }
        },
      )
    ];

    return OFRoundedBottomSheet(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            children: imagePickerActions,
            mainAxisSize: MainAxisSize.min,
          ),
        ));
  }
}
