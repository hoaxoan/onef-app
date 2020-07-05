import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:meta/meta.dart';
import 'package:onef/plugins/image_converter/image_converter.dart';
import 'package:onef/services/bottom_sheet.dart';
import 'package:onef/services/localization.dart';
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

  Future<File> pickImage(
      {@required OFImageType imageType,
      @required BuildContext context,
      bool flattenGifs = true}) async {
    File pickedImage =
        await _bottomSheetService.showImagePicker(context: context);

    if (pickedImage == null) return null;
    final tempPath = await _getTempPath();

    final String processedImageUuid = _uuid.v4();
    String imageExtension = basename(pickedImage.path);

    // The image picker gives us the real image, lets copy it into a temp path
    pickedImage =
        pickedImage.copySync('$tempPath/$processedImageUuid$imageExtension');

    File processedPickedImage;

    bool pickedImageIsGif = await isGif(pickedImage);

    if (!pickedImageIsGif || flattenGifs) {
      String processedImageName = processedImageUuid + '.jpg';
      processedPickedImage = File('$tempPath/$processedImageName');
      List<int> convertedImageData =
          await ImageConverter.convertImage(pickedImage.readAsBytesSync());
      processedPickedImage.writeAsBytesSync(convertedImageData);
    } else {
      String processedImageName = processedImageUuid + '.gif';
      processedPickedImage =
          pickedImage.copySync('$tempPath/$processedImageName');
    }

    // We now have a processed one
    pickedImage.deleteSync();

    if (!await _validationService.isImageAllowedSize(
        processedPickedImage, imageType)) {
      throw FileTooLargeException(
          _validationService.getAllowedImageSize(imageType));
    }

    processedPickedImage = !pickedImageIsGif || flattenGifs
        ? await processImage(processedPickedImage)
        : processedPickedImage;

    if (imageType == OFImageType.post) return processedPickedImage;

    double ratioX = IMAGE_RATIOS[imageType]['x'];
    double ratioY = IMAGE_RATIOS[imageType]['y'];

    File croppedFile =
        await cropImage(processedPickedImage, ratioX: ratioX, ratioY: ratioY);

    return croppedFile;
  }

  Future<File> pickVideo({@required BuildContext context}) async {
    File pickedVideo =
        await _bottomSheetService.showVideoPicker(context: context);

    if (pickedVideo == null) return null;

    String videoExtension = basename(pickedVideo.path);
    String tmpImageName = _uuid.v4() + videoExtension;
    final path = await _getTempPath();
    final String pickedVideoCopyPath = '$path/$tmpImageName';
    File pickedVideoCopy = pickedVideo.copySync(pickedVideoCopyPath);

    if (!await _validationService.isVideoAllowedSize(pickedVideoCopy)) {
      throw FileTooLargeException(_validationService.getAllowedVideoSize());
    }

    return pickedVideoCopy;
  }

  Future<File> processImage(File image) async {
    // This is supposed to solve the rotated images bug from flutter
    // https://github.com/flutter/flutter/issues/35334
    final imageBytes = await image.readAsBytes();
    await image.delete();
    final compressedImageBytes =
        await FlutterImageCompress.compressWithList(imageBytes);
    await image.writeAsBytes(compressedImageBytes);
    return image;
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

  Future<File> convertGifToVideo(File gif) async {
    File resultFile;

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

    String resultFileName = _uuid.v4() + '.mp4';
    final path = await _getTempPath();
    final String sourceFilePath = gif.path;
    final String resultFilePath = '$path/$resultFileName';

    int exitCode = await _flutterFFmpeg.execute(
        '-f gif -i $sourceFilePath -pix_fmt yuv420p -c:v libx264 -movflags +faststart -filter:v crop=\'floor(in_w/2)*2:floor(in_h/2)*2\' $resultFilePath');

    if (exitCode == 0) {
      resultFile = File(resultFilePath);
    } else {
      throw (Exception('Gif couldn\'t be converted to video'));
    }

    return resultFile;
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
