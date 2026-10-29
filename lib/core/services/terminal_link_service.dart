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

  // أمر ذاتي شامل يعمل في أي مكان (Termux عادي أو داخل PRoot) ولا يعتمد على مسار مسبق
  static const String selfContainedInstallCommand = r"""bash -c "$(cat << 'NASAQ_RUNNER'
mkdir -p ~/.nasaq

# 1. تحرير المنفذ 8081 وإنهاء أي خوادم قديمة
pkill -9 -f "proxy.py" 2>/dev/null || true
pkill -9 -f "server.py" 2>/dev/null || true
pkill -9 -f "nasaq" 2>/dev/null || true
python3 -c "import subprocess; [subprocess.run(['kill', '-9', p]) for p in subprocess.run(['lsof', '-ti:8081'], capture_output=True, text=True).stdout.split()]" 2>/dev/null || true

# 2. فحص وتثبيت بايثون والأدوات تلقائياً حسب نوع البيئة
if command -v pkg >/dev/null 2>&1; then
    pkg update -y -q >/dev/null 2>&1
    pkg install -y python curl >/dev/null 2>&1
elif command -v apt-get >/dev/null 2>&1; then
    apt-get update -y -q >/dev/null 2>&1
    apt-get install -y python3 curl >/dev/null 2>&1
fi

# 3. فحص أمان بيئة PRoot (تجنب التكرار إذا كان يعمل بالفعل داخل proot)
if command -v proot-distro >/dev/null 2>&1; then
    if [ -z "$PROOT_TMP_DIR" ] && [ "$(id -u)" != "0" ] && ! grep -qa "proot" /proc/1/cmdline 2>/dev/null; then
        if ! proot-distro list 2>/dev/null | grep -q "ubuntu.*installed"; then
            echo ">> جاري تجهيز نواة Ubuntu في الخلفية..."
            proot-distro install ubuntu >/dev/null 2>&1
        fi
    fi
fi

# 4. كتابة خادم نَسَق الذكي الموحد
cat << 'PYEOF' > ~/.nasaq/server.py
import http.server, socketserver, json, random, os, string, ssl, urllib.request, subprocess

PORT = 8081
PAIR_FILE = os.path.expanduser("~/.nasaq/pair.json")

# توليد رمز سداسي جديد
RAW_PIN = f"{random.randint(100000, 999999)}"
DISPLAY_PIN = f"{RAW_PIN[:3]}-{RAW_PIN[3:]}"
TOKEN = ''.join(random.choices(string.ascii_letters + string.digits, k=32))

cur_data = {"raw_pin": RAW_PIN, "code": DISPLAY_PIN, "paired": False, "token": TOKEN, "api_key": ""}
if os.path.exists(PAIR_FILE):
    try:
        old = json.load(open(PAIR_FILE))
        if old.get("paired"):
            cur_data["paired"] = True
            cur_data["api_key"] = old.get("api_key", "")
            cur_data["token"] = old.get("token", TOKEN)
    except:
        pass

with open(PAIR_FILE, "w") as f:
    json.dump(cur_data, f)

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
        elif self.path == '/v1/models':
            self._cors(200)
            self.wfile.write(json.dumps({"data": [{"id": "gemini-2.5-flash"}]}).encode())
        else:
            self._cors(404)

    def do_POST(self):
        length = int(self.headers.get('content-length', 0))
        raw_body = self.rfile.read(length)
        
        if self.path == '/v1/pair':
            try:
                body = json.loads(raw_body.decode('utf-8'))
                input_pin = str(body.get('code', '')).replace('-', '').strip()
                data = json.load(open(PAIR_FILE))
                
                if input_pin == data.get('raw_pin') or input_pin == data.get('code', '').replace('-', ''):
                    data['paired'] = True
                    if body.get('api_key'):
                        data['api_key'] = body['api_key']
                    with open(PAIR_FILE, 'w') as f:
                        json.dump(data, f)
                    self._cors(200)
                    self.wfile.write(json.dumps({"status": "success", "token": data['token']}).encode())
                else:
                    self._cors(401)
                    self.wfile.write(json.dumps({"status": "error", "message": "رمز التحقق غير مطابق"}).encode())
            except Exception as e:
                self._cors(500)
                self.wfile.write(json.dumps({"status": "error", "message": str(e)}).encode())
                
        elif self.path == '/v1/chat/completions':
            try:
                data = json.load(open(PAIR_FILE))
                key = data.get('api_key', '')
                req_data = json.loads(raw_body.decode('utf-8'))
                
                contents = []
                for m in req_data.get('messages', []):
                    role = 'user' if m.get('role') in ['user', 'system'] else 'model'
                    contents.append({'role': role, 'parts': [{'text': m.get('content', '')}]})
                
                g_payload = {'contents': contents}
                data_bytes = json.dumps(g_payload).encode('utf-8')
                
                url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:streamGenerateContent?alt=sse"
                req = urllib.request.Request(url, data=data_bytes, method='POST')
                req.add_header('Content-Type', 'application/json; charset=utf-8')
                req.add_header('x-goog-api-key', key)
                
                ctx = ssl.create_default_context()
                resp = urllib.request.urlopen(req, context=ctx, timeout=30)
                
                self.send_response(200)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
                self.end_headers()
                
                for raw_line in resp:
                    line = raw_line.decode('utf-8', errors='ignore')
                    if line.startswith('data: '):
                        chunk_str = line[6:].strip()
                        if chunk_str and chunk_str != '[DONE]':
                            try:
                                g_chunk = json.loads(chunk_str)
                                parts = g_chunk.get('candidates', [{}])[0].get('content', {}).get('parts', [])
                                piece = "".join([p.get('text', '') for p in parts])
                                if piece:
                                    out_sse = {"choices": [{"delta": {"content": piece}}]}
                                    self.wfile.write(f"data: {json.dumps(out_sse, ensure_ascii=False)}\n\n".encode('utf-8'))
                                    self.wfile.flush()
                            except:
                                pass
                self.wfile.write(b"data: [DONE]\n\n")
                self.wfile.flush()
            except Exception as e:
                self._cors(500)
                self.wfile.write(json.dumps({"error": str(e)}).encode())

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("127.0.0.1", PORT), NASAQHandler) as httpd:
    httpd.serve_forever()
PYEOF

nohup python3 ~/.nasaq/server.py > ~/.nasaq/server.log 2>&1 &
sleep 1.5

PIN=$(python3 -c "import json, os; print(json.load(open(os.path.expanduser('~/.nasaq/pair.json')))['code'])")

clear
echo -e "\033[1;36m====================================================\033[0m"
echo -e "\033[1;32m         منظومة نَسَق | NASAQ CORE ENGINE           \033[0m"
echo -e "\033[1;36m====================================================\033[0m"
echo ""
echo -e "   ✓ المحرك يعمل بنشاط في خلفية جهازك"
echo -e "   رمز الاقتران المباشر:  \033[1;33m[  $PIN  ]\033[0m"
echo ""
echo -e ">> اكتب الرمز في تطبيق «نَسَق» لإتمام الربط فوراً."
echo -e "\033[1;36m====================================================\033[0m"
NASAQ_RUNNER
)""";
}
