import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onef/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/media/models/media_file.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFCameraPickerBottomSheet extends StatelessWidget {
  const OFCameraPickerBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);

    LocalizationService localizationService = provider.localizationService;

    List<Widget> cameraPickerActions = [
      ListTile(
        leading: const OFIcon(OFIcons.camera),
        title: OFText(
          localizationService.post__create_photo,
        ),
        onTap: () async {
          bool permissionGranted = await provider.permissionService
              .requestStoragePermissions(context: context);
          if (permissionGranted) {
            File file = await ImagePicker.pickImage(source: ImageSource.camera);
            Navigator.pop(
                context, file != null ? MediaFile(file, FileType.image) : null);
          }
        },
      ),
      ListTile(
        leading: const OFIcon(OFIcons.camera),
        title: OFText(
          localizationService.post__create_video,
        ),
        onTap: () async {
          bool permissionGranted = await provider.permissionService
              .requestStoragePermissions(context: context);
          if (permissionGranted) {
            File file = await ImagePicker.pickVideo(source: ImageSource.camera);
            Navigator.pop(
                context, file != null ? MediaFile(file, FileType.video) : null);
          }
        },
      ),
    ];

    return OFRoundedBottomSheet(
        child: Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: cameraPickerActions,
        mainAxisSize: MainAxisSize.min,
      ),
    ));
  }
}
