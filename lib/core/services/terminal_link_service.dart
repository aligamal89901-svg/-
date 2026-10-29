import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class TerminalLinkService extends ChangeNotifier {
  static final TerminalLinkService instance = TerminalLinkService._();
  TerminalLinkService._();

  bool _isOnline = false;
  bool _isPaired = false;
  String _activeToken = '';

  bool get isOnline => _isOnline;
  bool get isPaired => _isPaired;
  String get activeToken => _activeToken;

  final String baseUrl = 'http://127.0.0.1:8081';

  Future<bool> checkStatus() async {
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
      final request = await client.getUrl(Uri.parse('$baseUrl/v1/status'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        _isOnline = true;
        _isPaired = data['paired'] == true;
        notifyListeners();
        return true;
      }
    } catch (_) {
      _isOnline = false;
      _isPaired = false;
      notifyListeners();
    }
    return false;
  }

  Future<Map<String, dynamic>> submitPairingCode(String code, {String apiKey = ''}) async {
    try {
      final cleanCode = code.replaceAll('-', '').trim();
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
      final request = await client.postUrl(Uri.parse('$baseUrl/v1/pair'));
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      
      final payload = jsonEncode({
        'code': cleanCode,
        'api_key': apiKey,
      });
      request.add(utf8.encode(payload));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _isPaired = true;
        _isOnline = true;
        _activeToken = data['token'] ?? '';
        notifyListeners();
        return {'success': true, 'message': 'تم اقتران المحرك بنجاح!'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'رمز التحقق غير صحيح'};
      }
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالمحرك، تأكد من تشغيل الأمر في الطرفية'};
    }
  }

  static const String selfContainedInstallCommand = "python3 -c \"import gzip,base64,subprocess,os,time,json; p=os.path.expanduser('~/.nasaq_srv.py'); open(p,'wb').write(gzip.decompress(base64.b64decode('H4sIAAAAAAAC/61X34/bNgx+z18h+EXWYDu5rt3aFMHQdV2vD+0d1ry5QaDYjOOebbmScrlDkP3tI2Xnt++uLeY82JIokiI/fmLyslbasoW1dWRA34IOmFHJDdjt6KtRVcC0rFJVBkyZgC11UeSzSMO3JRiL8qbo9Wo2wsWolnYRwV2N4kvU4PN/+1EljfzWr2WuI1LGRQ8FS3kDaa6Nv92Eg0qW4NciYHCXGztVN6OxXoLoJSoFVD/31o0bEb3yyvoXg0Hw6tUrsQkfXPF6ZDNKl2Xtrz3S5A0ZvQLmablqB3iYupAJ+F7o4YKHPnjkMKQo8LcsDInfwD2OPG+DYaih8mucW3lC9HpJIY1hl/5BGKM/pYHL8fj6nyZMl+hYAVoMewyfFOZsmvgGinngHBg9GwzaNXpoARVV6VSDqVVlwCcp0SGwAJlSoN8kCRgTvlWV1aoI3xSFWoVXOs/yigeM/8J/ePNHsAuVmp/cfekWu3fvNxtf7AKSqunV9fjD1afPLjBi2AhjnCg4h2Lv341bkZ1eq+/3AyeKiHGpL5RM/SZhQhyJ5PPGAuGPjUaM928v+sZKuzT8WNnO89aZ181oNc8LiFY6t+DvYGYQZ6oq8oqQRgA+xFIab78nG4FxoKz6J25B0elYiaLFTzg242svlVZ6w3jt5eiEl0GZV3n4LHoRzhG5C28z2fBTHwzs4/988Hy/DHcJ1Ha/+OIkOddXn/+X7MwORYzTGGl3Lo3Q8anK3VwLpCgD6/MEMQiVDQuoMrtA8A2E+J6sU1I6QpugD8Zqf7bVngIPOBdiRxg8dBMRSuW1L840oLWErKQxR7rhk3MbLhwxb2DBJ2iRQNMphspaT2SdT5GPuCBIcfqijbN4tzDpVLDnwnRPYnzFhegU/w5kNeWCoDJLxwJe4Fl1AxXOON6fNqNTfO0w9qjd54OLJ+2C1kqj1RKNywxrzrv+8ImVuSmlTRbeObA7858spO0nqqwLsDnybQcWSpMZjHG85khywIecLjhOOSmbnLhpwfKKxc1awM29sVBibuisjLsSxulaaosmUJWFO8uH5RF4HaCwJNlcaVaSvjbp7RGRU+OJOE/wTKX325ppiWirEo05/w8452w7Xuu4m9MdZob9fgYVaGnzWyhklS3RbpQplRWACDMRhgrDNgMrW17qn5LKECsCZPm+UQNvG0f+kIUdGQP8zDy2E2j+uLeI2svTx+mAEYmN6JABa2t+tOat3nB8X1NOZF0XeSIph33XbAT8LiS/Q3Q7pMIYpk0w6dsFWnS4Ys5dwaErGBzTlV1R5vAkRZTgMS1Mkf3ksrDTdsnHFsLmJailHf06EN2kfXzD7265brmfuOgfVnIUNtxFLvfhlqaavL1mWBLagB0t7Tx8+ZDS85v88CEA00VIGMZjdhe7Exi5V5SCAydvbKJfeVYpDVw8RIduF3IB1tMqtwufE0iGDMsQ+y3G47+uPr2bcFYpSz6QdLcTnZfU6ZMd30ikLf5tONlyv3h0s72zVF48+qryyo+JAhogOgogJLpw0Ty5msU8oV4Wz4MFP4kHk3jHD5O4ZZDJ5HGbGCA0+/ih6EGQom/YHi9UjuDCPgVbBaxqahpourGL36htg8z0pMIzyp57TWLWB+yEVsXmS/Wl8h5ohJ7QPC+WZuE/vGXbqNTYnPee9HDWethAxrklej9o/cmuib1zL2QnJg07weJhQ/VUg9ncekPXnIA4aiV7h//fovHb68/NlySiQLbBq2kq0xTr0Wx7DSod1r3N9/nFs9+jAf4usCBfDl5eILNdCvK/LWjT/OWZInyBdojefwpa98xWDgAA'))); subprocess.run(['pkill','-9','-f','nasaq_srv.py']); subprocess.Popen(['python3',p]); time.sleep(1); d=json.load(open(os.path.expanduser('~/.nasaq/pair.json'))); print('\\n' + '='*44 + '\\n  ✓ محرك نَسَق نشط | رمز الاقتران: [' + d['code'] + ']\\n' + '='*44 + '\\n')\"";
}
