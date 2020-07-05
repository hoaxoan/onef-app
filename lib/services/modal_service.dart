import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/pages/home/pages/task/widgets/create_task.dart';
import 'package:onef/widgets/new_task_data_uploader.dart';

import 'localization.dart';

class ModalService {
  LocalizationService localizationService;

  void setLocalizationService(localizationService) {
    this.localizationService = localizationService;
  }

  Future<OFNewTaskData> openCreateTask({@required BuildContext context}) async {
    OFNewTaskData createTaskData =
        await Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<OFNewTaskData>(
                fullscreenDialog: false,
                builder: (BuildContext context) {
                  return Material(
                    child: OFSaveTaskModal(),
                  );
                }));

    return createTaskData;
  }
}
