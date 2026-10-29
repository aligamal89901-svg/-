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
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
      final request = await client.postUrl(Uri.parse('$baseUrl/v1/pair'));
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      
      final payload = jsonEncode({
        'code': code.trim(),
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
      return {'success': false, 'message': 'تعذر الاتصال بمحرك Termux، تأكد من تشغيله'};
    }
  }

  static const String selfContainedInstallCommand = r"""mkdir -p ~/.nasaq && cat << 'INLINE_INIT' > ~/.nasaq/init.sh
#!/data/data/com.termux/files/usr/bin/bash
clear
echo -e "\033[1;36m====================================================\033[0m"
echo -e "\033[1;32m         منظومة نَسَق | NASAQ TERMINAL ENGINE        \033[0m"
echo -e "\033[1;36m====================================================\033[0m"
echo -e "[1/3] فحص الحزم وتحديث الأدوات..."
pkg update -y -q > /dev/null 2>&1
pkg install -y python proot-distro curl > /dev/null 2>&1

echo -e "[2/3] فحص بيئة PRoot المعزولة..."
if ! proot-distro list | grep -q "ubuntu.*installed"; then
    echo ">> جاري إعداد بيئة Ubuntu لأول مرة..."
    proot-distro install ubuntu
fi

echo -e "[3/3] تشغيل خادم الربط المحلي..."
cat << 'INLINE_PY' > ~/.nasaq/server.py
import http.server, socketserver, json, random, os, string

PORT = 8081
PAIR_FILE = os.path.expanduser("~/.nasaq/pair.json")
CODE = f"{random.randint(100, 999)}-{random.randint(100, 999)}"
TOKEN = ''.join(random.choices(string.ascii_letters + string.digits, k=24))

with open(PAIR_FILE, "w") as f:
    json.dump({"code": CODE, "paired": False, "token": TOKEN, "api_key": ""}, f)

class NASAQHandler(http.server.BaseHTTPRequestHandler):
    def _cors(self, code=200):
        self.send_response(code)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()

    def do_OPTIONS(self):
        self._cors(200)

    def do_GET(self):
        if self.path == '/v1/status':
            try:
                data = json.load(open(PAIR_FILE))
                self._cors(200)
                self.wfile.write(json.dumps({"online": True, "paired": data.get("paired", False)}).encode())
            except:
                self._cors(500)
        else:
            self._cors(404)

    def do_POST(self):
        length = int(self.headers.get('content-length', 0))
        body = json.loads(self.rfile.read(length).decode('utf-8'))
        if self.path == '/v1/pair':
            data = json.load(open(PAIR_FILE))
            if body.get('code') == data['code']:
                data['paired'] = True
                if body.get('api_key'):
                    data['api_key'] = body['api_key']
                json.dump(data, open(PAIR_FILE, 'w'))
                self._cors(200)
                self.wfile.write(json.dumps({"status": "success", "token": data['token']}).encode())
            else:
                self._cors(401)
                self.wfile.write(json.dumps({"status": "error", "message": "رمز التحقق غير صحيح"}).encode())
        elif self.path == '/v1/chat/completions':
            self.send_response(200)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
            self.end_headers()
            msg = {"choices": [{"delta": {"content": "تم ربط نَسَق بمحرك جهازك بنجاح! الوكيل جاهز الآن للعمل معك."}}]}
            self.wfile.write(f"data: {json.dumps(msg, ensure_ascii=False)}\n\n".encode())
            self.wfile.write(b"data: [DONE]\n\n")

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("127.0.0.1", PORT), NASAQHandler) as httpd:
    httpd.serve_forever()
INLINE_PY

pkill -f "python.*server.py" 2>/dev/null || true
nohup python3 ~/.nasaq/server.py > ~/.nasaq/server.log 2>&1 &
sleep 2

PIN=$(python3 -c "import json, os; print(json.load(open(os.path.expanduser('~/.nasaq/pair.json')))['code'])")

echo -e "\033[1;32m====================================================\033[0m"
echo -e "\033[1;37m        ✓ تم تشغيل محرك نَسَق بنجاح في الخلفية       \033[0m"
echo -e "\033[1;32m====================================================\033[0m"
echo ""
echo -e "   رمز الاقتران الخاص بجهازك:  \033[1;33m[ $PIN ]\033[0m"
echo ""
echo -e ">> ارجع الآن لتطبيق «نَسَق» واكتب هذا الرمز في الشاشة."
echo -e "\033[1;36m====================================================\033[0m"
INLINE_INIT
bash ~/.nasaq/init.sh""";
}
