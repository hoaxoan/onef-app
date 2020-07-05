import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onef/plugins/share/share.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/media.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/validation.dart';

class ShareService {
  static const _stream = const EventChannel('openbook.social/receive_share');

  ToastService _toastService;
  MediaService _mediaService;
  ValidationService _validationService;
  LocalizationService _localizationService;

  StreamSubscription _shareReceiveSubscription;
  List<Share> _shareQueue;
  List<Future<bool> Function({String text, File image, File video})>
      _subscribers;

  BuildContext _context;

  ShareService() {
    _shareQueue = [];
    _subscribers = [];

    if (Platform.isAndroid) {
      if (_shareReceiveSubscription == null) {
        _shareReceiveSubscription =
            _stream.receiveBroadcastStream().listen(_onReceiveShare);
      }
    }
  }

  void setToastService(ToastService toastService) {
    _toastService = toastService;
  }

  void setValidationService(ValidationService validationService) {
    _validationService = validationService;
  }

  void setLocalizationService(LocalizationService localizationService) {
    _localizationService = localizationService;
  }

  void setMediaService(MediaService mediaService) {
    _mediaService = mediaService;
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  /// Subscribe to share events.
  ///
  /// [onShare] should return [true] if it consumes the share. If [false] is
  /// returned, the next subscriber will be sent the share as well!
  void subscribe(
      Future<bool> Function({String text, File image, File video}) onShare) {
    _subscribers.add(onShare);

    if (_subscribers.length == 1) {
      _emptyQueue();
    }
  }

  void unsubscribe(
      Future<bool> Function({String text, File image, File video}) subscriber) {
    _subscribers.remove(subscriber);
  }

  Future<void> _emptyQueue() async {
    var consumed = <Share>[];
    for (Share share in _shareQueue) {
      if (await _onShare(share)) {
        consumed.add(share);
      }
    }

    consumed.forEach((e) => _shareQueue.remove(e));
  }

  void _onReceiveShare(dynamic shared) async {
    var share = Share.fromReceived(shared);

    if (_subscribers.isEmpty) {
      _shareQueue.add(share);
    } else {
      await _onShare(share);
    }
  }

  Future<bool> _onShare(Share share) async {
    String text;
    File image;
    File video;
    if (share.error != null) {
      _toastService.error(
          message: _localizationService.trans(share.error), context: _context);
      if (share.error.contains('uri_scheme')) {
        throw share.error;
      }
      return true;
    }

    if (share.image != null) {
      image = File.fromUri(Uri.parse(share.image));
      image = await _mediaService.processImage(image);
      if (!await _validationService.isImageAllowedSize(
          image, OFImageType.post)) {
        _showFileTooLargeToast(
            _validationService.getAllowedImageSize(OFImageType.post));
        return true;
      }
    }

    if (share.video != null) {
      video = File.fromUri(Uri.parse(share.video));

      if (!await _validationService.isVideoAllowedSize(video)) {
        _showFileTooLargeToast(_validationService.getAllowedVideoSize());
        return true;
      }
    }

    if (share.text != null) {
      text = share.text;
      if (!_validationService.isPostTextAllowedLength(text)) {
        _toastService.error(
            message:
                'Text too long (limit: ${ValidationService.POST_MAX_LENGTH} characters)',
            context: _context);
        return true;
      }
    }

    for (var sub in _subscribers.reversed) {
      if (await sub(text: text, image: image, video: video)) {
        return true;
      }
    }

    return false;
  }

  Future _showFileTooLargeToast(int limitInBytes) async {
    _toastService.error(
        message: _localizationService
            .image_picker__error_too_large(limitInBytes ~/ 1048576),
        context: _context);
  }
}
