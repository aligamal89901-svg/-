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

  static const String selfContainedInstallCommand = 'echo 'IyEvZGF0YS9kYXRhL2NvbS50ZXJtdXgvZmlsZXMvdXNyL2Jpbi9iYXNoCm1rZGlyIC1wIH4vLm5hc2FxCgojINil2YbZh9in2KEg2KPZiiDYudmF2YTZitin2Kog2LPYp9io2YLYqSDYudmE2Ykg2KfZhNmF2YbZgdiwCnB5dGhvbjMgLWMgImltcG9ydCBzdWJwcm9jZXNzOyBbc3VicHJvY2Vzcy5ydW4oWydraWxsJywgJy05JywgcF0pIGZvciBwIGluIHN1YnByb2Nlc3MucnVuKFsnbHNvZicsICctdGk6ODA4MSddLCBjYXB0dXJlX291dHB1dD1UcnVlLCB0ZXh0PVRydWUpLnN0ZG91dC5zcGxpdCgpXSIgMj4vZGV2L251bGwgfHwgdHJ1ZQpwa2lsbCAtOSAtZiAibmFzYXFfc2VydmVyLnB5IiAyPi9kZXYvbnVsbCB8fCB0cnVlCgojINmD2KrYp9io2Kkg2K7Yp9iv2YUg2YbZjtiz2Y7ZgiDYp9mE2LDZg9mKCmNhdCA8PCAnUFlFT0YnID4gfi8ubmFzYXEvbmFzYXFfc2VydmVyLnB5CmltcG9ydCBodHRwLnNlcnZlciwgc29ja2V0c2VydmVyLCBqc29uLCByYW5kb20sIG9zLCBzdHJpbmcsIHVybGxpYi5yZXF1ZXN0LCBzc2wKClBPUlQgPSA4MDgxClBGSUxFID0gb3MucGF0aC5leHBhbmR1c2VyKCd+Ly5uYXNhcS9wYWlyLmpzb24nKQpSQVdfUElOID0gc3RyKHJhbmRvbS5yYW5kaW50KDEwMDAwMCwgOTk5OTk5KSkKUElOX0NPREUgPSBmIntSQVdfUElOWzozXX0te1JBV19QSU5bMzpdfSIKCmN1cl9kYXRhID0geydyYXdfcGluJzogUkFXX1BJTiwgJ2NvZGUnOiBQSU5fQ09ERSwgJ3BhaXJlZCc6IEZhbHNlLCAndG9rZW4nOiAnJy5qb2luKHJhbmRvbS5jaG9pY2VzKHN0cmluZy5hc2NpaV9sZXR0ZXJzLCBrPTI0KSksICdhcGlfa2V5JzogJyd9CndpdGggb3BlbihQRklMRSwgJ3cnKSBhcyBmOgogICAganNvbi5kdW1wKGN1cl9kYXRhLCBmKQoKY2xhc3MgSChodHRwLnNlcnZlci5CYXNlSFRUUFJlcXVlc3RIYW5kbGVyKToKICAgIGRlZiBfYyhzZWxmLCBjPTIwMCk6CiAgICAgICAgc2VsZi5zZW5kX3Jlc3BvbnNlKGMpCiAgICAgICAgc2VsZi5zZW5kX2hlYWRlcignQWNjZXNzLUNvbnRyb2wtQWxsb3ctT3JpZ2luJywgJyonKQogICAgICAgIHNlbGYuc2VuZF9oZWFkZXIoJ0FjY2Vzcy1Db250cm9sLUFsbG93LU1ldGhvZHMnLCAnR0VULCBQT1NULCBPUFRJT05TJykKICAgICAgICBzZWxmLnNlbmRfaGVhZGVyKCdBY2Nlc3MtQ29udHJvbC1BbGxvdy1IZWFkZXJzJywgJ0NvbnRlbnQtVHlwZScpCiAgICAgICAgc2VsZi5lbmRfaGVhZGVycygpCgogICAgZGVmIGRvX09QVElPTlMoc2VsZik6CiAgICAgICAgc2VsZi5fYygyMDApCgogICAgZGVmIGRvX0dFVChzZWxmKToKICAgICAgICBpZiBzZWxmLnBhdGggPT0gJy92MS9zdGF0dXMnOgogICAgICAgICAgICB0cnk6CiAgICAgICAgICAgICAgICBkID0ganNvbi5sb2FkKG9wZW4oUEZJTEUpKQogICAgICAgICAgICAgICAgc2VsZi5fYygyMDApCiAgICAgICAgICAgICAgICBzZWxmLndmaWxlLndyaXRlKGpzb24uZHVtcHMoeydvbmxpbmUnOiBUcnVlLCAncGFpcmVkJzogZC5nZXQoJ3BhaXJlZCcsIEZhbHNlKX0pLmVuY29kZSgpKQogICAgICAgICAgICBleGNlcHQ6CiAgICAgICAgICAgICAgICBzZWxmLl9jKDUwMCkKICAgICAgICBlbGlmIHNlbGYucGF0aCA9PSAnL3YxL21vZGVscyc6CiAgICAgICAgICAgIHNlbGYuX2MoMjAwKQogICAgICAgICAgICBzZWxmLndmaWxlLndyaXRlKGIneyJkYXRhIjogW3siaWQiOiAiZ2VtaW5pLTIuNS1mbGFzaCJ9XX0nKQogICAgICAgIGVsc2U6CiAgICAgICAgICAgIHNlbGYuX2MoNDA0KQoKICAgIGRlZiBkb19QT1NUKHNlbGYpOgogICAgICAgIGIgPSBzZWxmLnJmaWxlLnJlYWQoaW50KHNlbGYuaGVhZGVycy5nZXQoJ2NvbnRlbnQtbGVuZ3RoJywgMCkpKQogICAgICAgIGlmIHNlbGYucGF0aCA9PSAnL3YxL3BhaXInOgogICAgICAgICAgICBkID0ganNvbi5sb2FkKG9wZW4oUEZJTEUpKQogICAgICAgICAgICByZXEgPSBqc29uLmxvYWRzKGIuZGVjb2RlKCd1dGYtOCcpKQogICAgICAgICAgICBwaW4gPSBzdHIocmVxLmdldCgnY29kZScsICcnKSkucmVwbGFjZSgnLScsICcnKS5zdHJpcCgpCiAgICAgICAgICAgIGlmIHBpbiA9PSBkLmdldCgncmF3X3BpbicpOgogICAgICAgICAgICAgICAgZFsncGFpcmVkJ10gPSBUcnVlCiAgICAgICAgICAgICAgICBpZiByZXEuZ2V0KCdhcGlfa2V5Jyk6CiAgICAgICAgICAgICAgICAgICAgZFsnYXBpX2tleSddID0gcmVxWydhcGlfa2V5J10KICAgICAgICAgICAgICAgIGpzb24uZHVtcChkLCBvcGVuKFBGSUxFLCAndycpKQogICAgICAgICAgICAgICAgc2VsZi5fYygyMDApCiAgICAgICAgICAgICAgICBzZWxmLndmaWxlLndyaXRlKGpzb24uZHVtcHMoeydzdGF0dXMnOiAnc3VjY2VzcycsICd0b2tlbic6IGRbJ3Rva2VuJ119KS5lbmNvZGUoKSkKICAgICAgICAgICAgZWxzZToKICAgICAgICAgICAgICAgIHNlbGYuX2MoNDAxKQogICAgICAgICAgICAgICAgc2VsZi53ZmlsZS53cml0ZShiJ3sic3RhdHVzIjogImVycm9yIiwgIm1lc3NhZ2UiOiAi2LHZhdiyINin2YTYqtit2YLZgiDYutmK2LEg2LXYrdmK2K0ifScpCgogICAgICAgIGVsaWYgc2VsZi5wYXRoID09ICcvdjEvY2hhdC9jb21wbGV0aW9ucyc6CiAgICAgICAgICAgIHRyeToKICAgICAgICAgICAgICAgIGQgPSBqc29uLmxvYWQob3BlbihQRklMRSkpCiAgICAgICAgICAgICAgICByZXEgPSBqc29uLmxvYWRzKGIuZGVjb2RlKCd1dGYtOCcpKQogICAgICAgICAgICAgICAgY29udGVudHMgPSBbeydyb2xlJzogJ3VzZXInIGlmIG0uZ2V0KCdyb2xlJykgaW4gWyd1c2VyJywgJ3N5c3RlbSddIGVsc2UgJ21vZGVsJywgJ3BhcnRzJzogW3sndGV4dCc6IG0uZ2V0KCdjb250ZW50JywgJycpfV19IGZvciBtIGluIHJlcS5nZXQoJ21lc3NhZ2VzJywgW10pXQogICAgICAgICAgICAgICAgcGF5bG9hZCA9IGpzb24uZHVtcHMoeydjb250ZW50cyc6IGNvbnRlbnRzfSkuZW5jb2RlKCd1dGYtOCcpCiAgICAgICAgICAgICAgICB1cmwgPSAnaHR0cHM6Ly9nZW5lcmF0aXZlbGFuZ3VhZ2UuZ29vZ2xlYXBpcy5jb20vdjFiZXRhL21vZGVscy9nZW1pbmktMi41LWZsYXNoOnN0cmVhbUdlbmVyYXRlQ29udGVudD9hbHQ9c3NlJwogICAgICAgICAgICAgICAgciA9IHVybGxpYi5yZXF1ZXN0LlJlcXVlc3QodXJsLCBkYXRhPXBheWxvYWQsIGhlYWRlcnM9eydDb250ZW50LVR5cGUnOiAnYXBwbGljYXRpb24vanNvbicsICd4LWdvb2ctYXBpLWtleSc6IGQuZ2V0KCdhcGlfa2V5JywgJycpfSkKICAgICAgICAgICAgICAgIHJlc3AgPSB1cmxsaWIucmVxdWVzdC51cmxvcGVuKHIsIGNvbnRleHQ9c3NsLmNyZWF0ZV9kZWZhdWx0X2NvbnRleHQoKSwgdGltZW91dD0zMCkKICAgICAgICAgICAgICAgIHNlbGYuc2VuZF9yZXNwb25zZSgyMDApCiAgICAgICAgICAgICAgICBzZWxmLnNlbmRfaGVhZGVyKCdBY2Nlc3MtQ29udHJvbC1BbGxvdy1PcmlnaW4nLCAnKicpCiAgICAgICAgICAgICAgICBzZWxmLnNlbmRfaGVhZGVyKCdDb250ZW50LVR5cGUnLCAndGV4dC9ldmVudC1zdHJlYW07IGNoYXJzZXQ9dXRmLTgnKQogICAgICAgICAgICAgICAgc2VsZi5lbmRfaGVhZGVycygpCiAgICAgICAgICAgICAgICBmb3IgbGluZSBpbiByZXNwOgogICAgICAgICAgICAgICAgICAgIGwgPSBsaW5lLmRlY29kZShlcnJvcnM9J2lnbm9yZScpCiAgICAgICAgICAgICAgICAgICAgaWYgbC5zdGFydHN3aXRoKCdkYXRhOiAnKSBhbmQgbC5zdHJpcCgpICE9ICdkYXRhOiBbRE9ORV0nOgogICAgICAgICAgICAgICAgICAgICAgICB0cnk6CiAgICAgICAgICAgICAgICAgICAgICAgICAgICB0ID0gJycuam9pbihbcC5nZXQoJ3RleHQnLCAnJykgZm9yIHAgaW4ganNvbi5sb2FkcyhsWzY6XSkuZ2V0KCdjYW5kaWRhdGVzJywgW3t9XSlbMF0uZ2V0KCdjb250ZW50Jywge30pLmdldCgncGFydHMnLCBbXSldKQogICAgICAgICAgICAgICAgICAgICAgICAgICAgaWYgdDoKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzZWxmLndmaWxlLndyaXRlKGYnZGF0YToge2pzb24uZHVtcHMoeyJjaG9pY2VzIjogW3siZGVsdGEiOiB7ImNvbnRlbnQiOiB0fX1dfSl9XG5cbicuZW5jb2RlKCkpCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgc2VsZi53ZmlsZS5mbHVzaCgpCiAgICAgICAgICAgICAgICAgICAgICAgIGV4Y2VwdDogcGFzcwogICAgICAgICAgICAgICAgc2VsZi53ZmlsZS53cml0ZShiJ2RhdGE6IFtET05FXVxuXG4nKQogICAgICAgICAgICAgICAgc2VsZi53ZmlsZS5mbHVzaCgpCiAgICAgICAgICAgIGV4Y2VwdCBFeGNlcHRpb24gYXMgZToKICAgICAgICAgICAgICAgIHNlbGYuX2MoNTAwKQogICAgICAgICAgICAgICAgc2VsZi53ZmlsZS53cml0ZShqc29uLmR1bXBzKHsnZXJyb3InOiBzdHIoZSl9KS5lbmNvZGUoKSkKCnNvY2tldHNlcnZlci5UQ1BTZXJ2ZXIuYWxsb3dfcmV1c2VfYWRkcmVzcyA9IFRydWUKd2l0aCBzb2NrZXRzZXJ2ZXIuVENQU2VydmVyKCgnMTI3LjAuMC4xJywgUE9SVCksIEgpIGFzIHM6CiAgICBzLnNlcnZlX2ZvcmV2ZXIoKQpQWUVPRgoKbm9odXAgcHl0aG9uMyB+Ly5uYXNhcS9uYXNhcV9zZXJ2ZXIucHkgPiB+Ly5uYXNhcS9uYXNhcV9zZXJ2ZXIubG9nIDI+JjEgJgpzbGVlcCAxLjUKClBJTj0kKHB5dGhvbjMgLWMgImltcG9ydCBqc29uLCBvczsgcHJpbnQoanNvbi5sb2FkKG9wZW4ob3MucGF0aC5leHBhbmR1c2VyKCd+Ly5uYXNhcS9wYWlyLmpzb24nKSkpWydjb2RlJ10pIikKCmNsZWFyCmVjaG8gLWUgIlwwMzNbMTszNm09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XDAzM1swbSIKZWNobyAtZSAiXDAzM1sxOzMybSAgICAgICAgINmF2YbYuNmI2YXYqSDZhtmO2LPZjtmCIHwgTkFTQVEgQ09SRSBFTkdJTkUgICAgICAgICAgIFwwMzNbMG0iCmVjaG8gLWUgIlwwMzNbMTszNm09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XDAzM1swbSIKZWNobyAiIgplY2hvIC1lICIgICDinJMg2KfZhNmF2K3YsdmDINmK2LnZhdmEINio2YbYtNin2Lcg2YHZiiDYp9mE2K7ZhNmB2YrYqSIKZWNobyAtZSAiICAg2LHZhdiyINin2YTYp9mC2KrYsdin2YYg2KfZhNmF2KjYp9i02LE6ICBcMDMzWzE7MzNtWyAgJFBJTiAgXVwwMzNbMG0iCmVjaG8gIiIKZWNobyAtZSAiPj4g2KfZg9iq2Kgg2KfZhNix2YXYsiDZgdmKINiq2LfYqNmK2YIgwqvZhtmO2LPZjtmCwrsg2YTYpdiq2YXYp9mFINin2YTYsdio2Lcg2YHZiNix2KfZiy4iCmVjaG8gLWUgIlwwMzNbMTszNm09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XDAzM1swbSIK' | base64 -d | bash'; '
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
