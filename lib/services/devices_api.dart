import 'package:meta/meta.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/string_template.dart';

class DevicesApiService {
  HttpieService _httpService;
  StringTemplateService _stringTemplateService;

  String apiURL;

  static const DEVICES_PATH = 'devices';
  static const DEVICE_PATH = 'devices/{deviceUuid}';

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getDevices() {
    String url = _makeApiUrl(DEVICES_PATH);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deleteDevices() {
    String url = _makeApiUrl(DEVICES_PATH);
    return _httpService.delete(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> createDevice({@required String uuid, String name}) {
    String url = _makeApiUrl(DEVICES_PATH);
    Map<String, dynamic> body = {'uuid': uuid};

    if (name != null) body['name'] = name;

    return _httpService.postJSON(url,
        appendAuthorizationToken: true, body: body);
  }

  Future<HttpieResponse> updateDeviceWithUuid(String deviceUuid,
      {String name}) {
    String url = _makeDevicePath(deviceUuid);

    Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;

    return _httpService.patchJSON(url,
        appendAuthorizationToken: true, body: body);
  }

  Future<HttpieResponse> deleteDeviceWithUuid(String deviceUuid) {
    String url = _makeDevicePath(deviceUuid);
    return _httpService.delete(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getDeviceWithUuid(String deviceUuid) {
    String url = _makeDevicePath(deviceUuid);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  String _makeDevicePath(String deviceUuid) {
    return _stringTemplateService
        .parse('$apiURL$DEVICE_PATH', {'deviceUuid': deviceUuid});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
