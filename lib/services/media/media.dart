import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:onef/plugins/image_converter/image_converter.dart';
import 'package:onef/services/bottom_sheet.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/media/models/media_file.dart';
import 'package:onef/services/permissions.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/utils_service.dart';
import 'package:onef/services/validation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

export 'package:image_picker/image_picker.dart';

class MediaService {
  static Uuid _uuid = new Uuid();

  static const Map IMAGE_RATIOS = {
    OFImageType.avatar: {'x': 1.0, 'y': 1.0},
    OFImageType.cover: {'x': 16.0, 'y': 9.0}
  };

  Map _thumbnail_cache = {};

  ValidationService _validationService;
  BottomSheetService _bottomSheetService;
  LocalizationService _localizationService;
  ToastService _toastService;
  PermissionsService _permissionsService;
  UtilsService _utilsService;

  void setLocalizationService(LocalizationService localizationService) {
    _localizationService = localizationService;
  }

  void setUtilsService(UtilsService utilsService) {
    _utilsService = utilsService;
  }

  void setValidationService(ValidationService validationService) {
    _validationService = validationService;
  }

  void setBottomSheetService(BottomSheetService modalService) {
    _bottomSheetService = modalService;
  }

  void setToastService(ToastService toastService) {
    _toastService = toastService;
  }

  void setPermissionsService(PermissionsService permissionsService) {
    _permissionsService = permissionsService;
  }

  /// Opens a bottom sheet with the options to pick either an image or a video.
  /// The media is picked from the gallery or camera (determined by [source]).
  ///
  /// If a GIF is picked it will be converted to a video file before being returned.
  ///
  /// The returned file may be either an image or a video. Use [MediaFile.type]
  /// to determine which one it is.
  Future<MediaFile> pickMedia(
      {@required BuildContext context,
      @required ImageSource source,
      bool flattenGifs}) async {
    MediaFile media;

    if (source == ImageSource.gallery) {
      bool permissionGranted =
          await _permissionsService.requestStoragePermissions(context: context);
      if (permissionGranted) {
        File file = await FilePicker.getFile(type: FileType.media);

        if (file != null) {
          FileType type = await getMediaType(file);
          media = MediaFile(file, type);
        }
      }
    } else if (source == ImageSource.camera) {
      media = await _bottomSheetService.showCameraPicker(context: context);
    } else {
      throw 'Unsupported media source: $source';
    }

    if (media == null) {
      return null;
    }

    media = await processMedia(
      media: media,
      context: context,
      flattenGifs: flattenGifs,
    );

    return media;
  }

  /// Opens a bottom sheet with the option to pick an image from gallery or snap
  /// a new one with the camera.
  ///
  /// The returned file should always point to an image. If a GIF is picked it will
  /// be flattened.
  Future<File> pickImage(
      {@required OFImageType imageType, @required BuildContext context}) async {
    File pickedImage =
        await _bottomSheetService.showImagePicker(context: context);

    if (pickedImage == null) return null;

    var media = await processMedia(
      media: MediaFile(pickedImage, FileType.image),
      context: context,
      flattenGifs: true,
      imageType: imageType,
    );

    return media.file;
  }

  /// Opens a bottom sheet with the option to pick a video from gallery or take
  /// a new one with the camera.
  ///
  /// The returned file should always point to a video.
  Future<File> pickVideo({@required BuildContext context}) async {
    File pickedVideo =
        await _bottomSheetService.showVideoPicker(context: context);

    if (pickedVideo == null) return null;

    var media = await processMedia(
      media: MediaFile(pickedVideo, FileType.video),
      context: context,
    );

    return media.file;
  }

  Future<MediaFile> processMedia(
      {@required MediaFile media,
      @required BuildContext context,
      bool flattenGifs = false,
      OFImageType imageType = OFImageType.post}) async {
    var mediaType = media.type;
    MediaFile result;

    // Copy the media to a temporary location.
    final tempPath = await _getTempPath();
    final String mediaUuid = _uuid.v4();
    String mediaExtension = basename(media.file.path);
    var copiedFile = media.file.copySync('$tempPath/$mediaUuid$mediaExtension');

    if (await isGif(media.file) && !flattenGifs) {
      mediaType = FileType.video;

      Completer<File> completer = Completer();
      convertGifToVideo(copiedFile).then((file) => completer.complete(file),
          onError: (error, trace) {
        print(error);
        _toastService.error(
            message: _localizationService.error__unknown_error,
            context: context);
      });
      copiedFile = await completer.future;
    }

    MediaFile copiedMedia = MediaFile(copiedFile, mediaType);
    if (mediaType == FileType.image) {
      result = await _processImage(copiedMedia, tempPath, mediaUuid, imageType);
    } else if (mediaType == FileType.video) {
      result = await _processVideo(copiedMedia);
    } else {
      throw 'Unsupported media type: ${media.type}';
    }

    return result;
  }

  Future<MediaFile> _processImage(MediaFile media, String tempPath,
      String mediaUuid, OFImageType imageType) async {
    var image = await fixExifRotation(media.file, deleteOriginal: true);
    String processedImageName = mediaUuid + '.jpg';
    File processedImage = File('$tempPath/$processedImageName');
    List<int> convertedImageData =
        await ImageConverter.convertImage(image.readAsBytesSync());
    processedImage.writeAsBytesSync(convertedImageData);

    // We have a new processed copy, so we can delete our first copy.
    image.deleteSync();

    if (!await _validationService.isImageAllowedSize(
        processedImage, imageType)) {
      throw FileTooLargeException(
          _validationService.getAllowedImageSize(imageType));
    }
    
    MediaFile result;
    if (imageType == OFImageType.post) {
      result = MediaFile(processedImage, media.type);
    } else {
      double ratioX = IMAGE_RATIOS[imageType]['x'];
      double ratioY = IMAGE_RATIOS[imageType]['y'];

      File croppedFile =
          await cropImage(processedImage, ratioX: ratioX, ratioY: ratioY);

      result = MediaFile(croppedFile, media.type);
    }

    return result;
  }

  Future<MediaFile> _processVideo(MediaFile media) async {
    if (!await _validationService.isVideoAllowedSize(media.file)) {
      throw FileTooLargeException(_validationService.getAllowedVideoSize());
    }

    return media;
  }


  Future<File> fixExifRotation(File image, {deleteOriginal: false}) async {
    List<int> imageBytes = await image.readAsBytes();

    List<int> result = await FlutterImageCompress.compressWithList(imageBytes,
        quality: 100, rotate: 0);

    final String processedImageUuid = _uuid.v4();
    String imageExtension = basename(image.path);

    final tempPath = await _getTempPath();

    File fixedImage = File('$tempPath/$processedImageUuid$imageExtension');

    await fixedImage.writeAsBytes(result);

    if (deleteOriginal) await image.delete();

    return fixedImage;
  }

  Future<File> copyMediaFile(File mediaFile, {deleteOriginal: true}) async {
    final String processedImageUuid = _uuid.v4();
    String imageExtension = basename(mediaFile.path);

    final tempPath = await _getTempPath();

    // The image picker gives us the real image, lets copy it into a temp path
    File fileCopy =
        mediaFile.copySync('$tempPath/$processedImageUuid$imageExtension');

    if (deleteOriginal) await mediaFile.delete();

    return fileCopy;
  }

  Future<String> _getTempPath() async {
    Directory applicationsDocumentsDir = await getTemporaryDirectory();
    Directory mediaCacheDir =
        Directory(join(applicationsDocumentsDir.path, 'mediaCache'));

    if (await mediaCacheDir.exists()) return mediaCacheDir.path;

    mediaCacheDir = await mediaCacheDir.create();

    return mediaCacheDir.path;
  }

  Future<File> getVideoThumbnail(File videoFile) async {
    final thumbnailData = await VideoThumbnail.thumbnailData(
      video: videoFile.path,
      imageFormat: ImageFormat.JPEG,
      maxHeightOrWidth: 500,
      quality: 100,
    );

    String videoExtension = basename(videoFile.path);
    String tmpImageName = 'thumbnail_' + _uuid.v4() + videoExtension;
    final tempPath = await _getTempPath();
    final String thumbnailPath = '$tempPath/$tmpImageName';
    final file = File(thumbnailPath);
    _thumbnail_cache[videoFile.path] = file;
    file.writeAsBytesSync(thumbnailData);

    return file;
  }

  Future<File> compressVideo(File video) async {
    File resultFile;

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

    String resultFileName = 'compressed_video_' + _uuid.v4() + '.mp4';
    final path = await _getTempPath();
    final String resultFilePath = '$path/$resultFileName';

    int exitCode = await _flutterFFmpeg.execute(
        '-i ${video.path} -filter:v scale=720:-2 -vcodec libx264 -crf 23 -preset veryfast ${resultFilePath}');

    if (exitCode == 0) {
      resultFile = File(resultFilePath);
    } else {
      debugPrint('Failed to compress video, using original file');
      resultFile = video;
    }

    return resultFile;
  }

  Future<File> compressImage(File image) async {
    List<int> compressedImageData = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      quality: 80,
    );

    String imageExtension = basename(image.path);
    String tmpImageName = 'compressed_image_' + _uuid.v4() + imageExtension;
    final tempPath = await _getTempPath();
    final String thumbnailPath = '$tempPath/$tmpImageName';
    final file = File(thumbnailPath);
    file.writeAsBytesSync(compressedImageData);

    return file;
  }

  CancelableOperation<File> convertGifToVideo(File gif) {
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

    // Set a cancel flag which we can use if we need to cancel before the ffmpeg
    // process is started (can happen for two gif shares with a short time between,
    // since we have to wait for _getTempPath() before we can start ffmpeg.
    var isCancelled = false;
    var ffmpegFuture =
        _convertGifToVideo(_flutterFFmpeg, gif, () => isCancelled);
    return CancelableOperation.fromFuture(ffmpegFuture, onCancel: () {
      isCancelled = true;
      _flutterFFmpeg.cancel();
    });
  }

  Future<File> _convertGifToVideo(
      FlutterFFmpeg flutterFFmpeg, File gif, bool Function() doCancel) async {
    String resultFileName = _uuid.v4() + '.mp4';
    final path = await _getTempPath();
    final String sourceFilePath = gif.path;
    final String resultFilePath = '$path/$resultFileName';

    var exitCode;
    if (!doCancel()) {
      exitCode = await flutterFFmpeg.execute(
          ' -loglevel debug -f gif -i $sourceFilePath -pix_fmt yuv420p -c:v libx264 -movflags +faststart -filter:v crop=\'floor(in_w/2)*2:floor(in_h/2)*2\' $resultFilePath');
    }

    if (exitCode == 0) {
      return File(resultFilePath);
    } else {
      throw 'Gif couldn\'t be converted to video';
    }
  }

  void clearThumbnailForFile(File videoFile) {
    if (_thumbnail_cache[videoFile.path] != null) {
      File thumbnail = _thumbnail_cache[videoFile.path];
      debugPrint('Clearing thumbnail');
      thumbnail.delete();
      _thumbnail_cache.remove(videoFile.path);
    }
  }

  Future<bool> isGif(File file) async {
    String mediaMime = await _utilsService.getFileMimeType(file);

    String mediaMimeSubtype = mediaMime.split('/')[1];

    return mediaMimeSubtype == 'gif';
  }

  Future<FileType> getMediaType(File file) async {
    String mediaMime = await _utilsService.getFileMimeType(file);

    String mediaMimeType = mediaMime.split('/')[0];

    if (mediaMimeType == 'video') {
      return FileType.video;
    } else if (mediaMimeType == 'image') {
      return FileType.image;
    } else if (mediaMimeType == 'audio') {
      return FileType.audio;
    } else {
      return null;
    }
  }

  Future<File> cropImage(File image, {double ratioX, double ratioY}) async {
    return ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: ratioX != null && ratioY != null
            ? CropAspectRatio(ratioX: ratioX, ratioY: ratioY)
            : null,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: _localizationService.media_service__crop_image,
          toolbarColor: Colors.black,
          statusBarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
        ));
  }
}

class FileTooLargeException implements Exception {
  final int limit;

  const FileTooLargeException(this.limit);

  String toString() =>
      'FileToLargeException: Images can\'t be larger than $limit';

  int getLimitInMB() {
    return limit ~/ 1048576;
  }
}

enum OFImageType { avatar, cover, post }
