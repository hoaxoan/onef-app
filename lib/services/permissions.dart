import 'package:flutter/material.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';

class PermissionsService {
  ToastService _toastService;
  LocalizationService _localizationService;

  void setToastService(toastService) {
    _toastService = toastService;
  }

  void setLocalizationService(localizationService) {
    _localizationService = localizationService;
  }

  Future<bool> requestStoragePermissions(
      {@required BuildContext context}) async {
    return _requestPermissionWithErrorMessage(
        permission: null,
        errorMessage:
            _localizationService.permissions_service__storage_permission_denied,
        context: context);
  }

  Future<bool> requestCameraPermissions(
      {@required BuildContext context}) async {
    return _requestPermissionWithErrorMessage(
        permission: null,
        errorMessage:
            _localizationService.permissions_service__camera_permission_denied,
        context: context);
  }

  Future<bool> _requestPermissionWithErrorMessage(
      {@required dynamic permission,
      @required String errorMessage,
      @required BuildContext context}) async {
    return true;
  }
}
