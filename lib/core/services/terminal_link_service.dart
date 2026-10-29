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

  static const String selfContainedInstallCommand =
      'mkdir -p ~/.nasaq && python3 -c "'
      'import http.server, socketserver, json, random, os, string, ssl, urllib.request, subprocess; '
      'PORT=8081; '
      'PIN_RAW=str(random.randint(100000, 999999)); '
      'PAIR_FILE=os.path.expanduser(\'~/.nasaq/pair.json\'); '
      'TOKEN=\'\'.join(random.choices(string.ascii_letters + string.digits, k=32)); '
      'json.dump({\'raw_pin\': PIN_RAW, \'code\': f\'{PIN_RAW[:3]}-{PIN_RAW[3:]}\', \'paired\': False, \'token\': TOKEN, \'api_key\': \'\'}, open(PAIR_FILE, \'w\')); '
      'f=open(os.path.expanduser(\'~/.nasaq/srv.py\'), \'w\'); '
      'f.write(\'\'\'import http.server, socketserver, json, os, ssl, urllib.request, subprocess\\n'
      'PORT = 8081\\n'
      'PFILE = os.path.expanduser("~/.nasaq/pair.json")\\n'
      'class H(http.server.BaseHTTPRequestHandler):\\n'
      '    def _c(self, code=200):\\n'
      '        self.send_response(code)\\n'
      '        self.send_header("Access-Control-Allow-Origin", "*")\\n'
      '        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")\\n'
      '        self.send_header("Access-Control-Allow-Headers", "Content-Type")\\n'
      '        self.end_headers()\\n'
      '    def do_OPTIONS(self): self._c(200)\\n'
      '    def do_GET(self):\\n'
      '        if self.path == "/v1/status":\\n'
      '            try: d=json.load(open(PFILE)); self._c(200); self.wfile.write(json.dumps({"online": True, "paired": d.get("paired", False)}).encode())\\n'
      '            except: self._c(500)\\n'
      '        elif self.path == "/v1/models": self._c(200); self.wfile.write(b"{\\\\"data\\\\": [{\\\\"id\\\\": \\\\"gemini-2.5-flash\\\\"}]}")\\n'
      '        else: self._c(404)\\n'
      '    def do_POST(self):\\n'
      '        l = int(self.headers.get("content-length", 0))\\n'
      '        b = self.rfile.read(l)\\n'
      '        if self.path == "/v1/pair":\\n'
      '            body = json.loads(b.decode())\\n'
      '            pin = str(body.get("code", "")).replace("-", "").strip()\\n'
      '            d = json.load(open(PFILE))\\n'
      '            if pin == d.get("raw_pin"):\\n'
      '                d["paired"] = True\\n'
      '                if body.get("api_key"): d["api_key"] = body["api_key"]\\n'
      '                json.dump(d, open(PFILE, "w"))\\n'
      '                self._c(200); self.wfile.write(json.dumps({"status": "success", "token": d["token"]}).encode())\\n'
      '            else: self._c(401); self.wfile.write(b"{\\\\"status\\\\": \\\\"error\\\\", \\\\"message\\\\": \\\\"PIN mismatch\\\\"}")\\n'
      '        elif self.path == "/v1/chat/completions":\\n'
      '            try:\\n'
      '                d = json.load(open(PFILE))\\n'
      '                key = d.get("api_key", "")\\n'
      '                req = json.loads(b.decode())\\n'
      '                contents = [{"role": "user" if m.get("role") in ["user","system"] else "model", "parts": [{"text": m.get("content","")}]} for m in req.get("messages",[])]\\n'
      '                data_b = json.dumps({"contents": contents}).encode()\\n'
      '                url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:streamGenerateContent?alt=sse"\\n'
      '                r = urllib.request.Request(url, data=data_b, headers={"Content-Type": "application/json", "x-goog-api-key": key})\\n'
      '                resp = urllib.request.urlopen(r, context=ssl.create_default_context(), timeout=30)\\n'
      '                self.send_response(200)\\n'
      '                self.send_header("Access-Control-Allow-Origin", "*")\\n'
      '                self.send_header("Content-Type", "text/event-stream; charset=utf-8")\\n'
      '                self.end_headers()\\n'
      '                for raw in resp:\\n'
      '                    line = raw.decode(errors="ignore")\\n'
      '                    if line.startswith("data: "):\\n'
      '                        c = line[6:].strip()\\n'
      '                        if c and c != "[DONE]":\\n'
      '                            try:\\n'
      '                                g = json.loads(c)\\n'
      '                                t = \\\'\\\'.join([p.get("text","") for p in g.get("candidates",[{}])[0].get("content",{}).get("parts",[])])\\n'
      '                                if t:\\n'
      '                                    self.wfile.write(f"data: {json.dumps({\\\'choices\\\': [{\\\'delta\\\': {\\\'content\\\': t}}]})}\\n\\n".encode())\\n'
      '                                    self.wfile.flush()\\n'
      '                            except: pass\\n'
      '                self.wfile.write(b"data: [DONE]\\n\\n"); self.wfile.flush()\\n'
      '            except Exception as e: self._c(500); self.wfile.write(json.dumps({"error": str(e)}).encode())\\n'
      'socketserver.TCPServer.allow_reuse_address = True\\n'
      'with socketserver.TCPServer(("127.0.0.1", PORT), H) as srv: srv.serve_forever()\\n\'\'\'); '
      'f.close(); '
      'subprocess.run([\'pkill\', \'-9\', \'-f\', \'nasaq/srv.py\']); '
      'subprocess.Popen([\'python3\', os.path.expanduser(\'~/.nasaq/srv.py\')]); '
      'print(\'\\n====================================================\'); '
      'print(\'         منظومة نَسَق | NASAQ CORE ENGINE           \'); '
      'print(\'====================================================\\n\'); '
      'print(f\'   ✓ المحرك يعمل بنشاط في الخلفية\'); '
      'print(f\'   رمز الاقتران المباشر:  [  {PIN_RAW[:3]}-{PIN_RAW[3:]}  ]\\n\'); '
      'print(\'>> ارجع لتطبيق نَسَق وأدخل هذا الرمز لإتمام الربط.\'); '
      'print(\'====================================================\')'
      '"';
}
