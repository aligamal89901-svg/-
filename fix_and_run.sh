#!/bin/bash
pkill -f proxy.py 2>/dev/null || true

cat << 'PYEOF' > /root/nasaq/proxy.py
import http.server
import json
import os
import re
import socketserver
import ssl
import subprocess
import time
import urllib.request
import urllib.error

GEMINI_KEY = "YOUR_GEMINI_KEY"
PORT = 8081
WORKSPACE_DIR = "/root/nasaq/workspace"
os.makedirs(WORKSPACE_DIR, exist_ok=True)

# استكشاف النماذج النشطة في حسابك تلقائياً
ACTIVE_MODELS = ["gemini-3.8-flash"]
try:
    ctx = ssl.create_default_context()
    req = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models?key={GEMINI_KEY}",
        headers={"x-goog-api-key": GEMINI_KEY}
    )
    with urllib.request.urlopen(req, context=ctx, timeout=10) as resp:
        m_data = json.loads(resp.read().decode('utf-8'))
        found = []
        for m in m_data.get("models", []):
            name = m.get("name", "").replace("models/", "")
            if "generateContent" in m.get("supportedGenerationMethods", []):
                if "flash" in name and "tts" not in name:
                    found.append(name)
        if found:
            ACTIVE_MODELS = found
except Exception:
    pass

print(f"[NASAQ] النماذج المتاحة في حسابك: {ACTIVE_MODELS}")

def build_payload(openai_messages):
    last_user_text = ""
    for m in reversed(openai_messages):
        if m.get("role") == "user":
            last_user_text = m.get("content", "").strip()
            break

    sys_inst = "أنت «نَسَق»، مساعد ذكي ومطور برمجيات عربي أصيل. أجب باللغة العربية الفصحى حصراً وبإيجاز دقيق ومباشر."
    
    gemini_contents = []
    recent = openai_messages[-4:] if len(openai_messages) > 4 else openai_messages
    for m in recent:
        txt = m.get("content", "").strip()
        if not txt or "error" in txt.lower() or "تعذر الاتصال" in txt:
            continue
        role = "model" if m.get("role") == "assistant" else "user"
        if gemini_contents and gemini_contents[-1]["role"] == role:
            gemini_contents[-1]["parts"][0]["text"] += f"\n{txt}"
        else:
            gemini_contents.append({"role": role, "parts": [{"text": txt}]})

    if not gemini_contents:
        gemini_contents = [{"role": "user", "parts": [{"text": "السلام عليكم"}]}]

    return {
        "systemInstruction": {"parts": [{"text": sys_inst}]},
        "contents": gemini_contents,
        "generationConfig": {"temperature": 0.3, "maxOutputTokens": 1000}
    }

class ReusableServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    allow_reuse_address = True

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def _send_cors(self, status=200, ctype="application/json; charset=utf-8"):
        self.send_response(status)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-goog-api-key')
        self.send_header('Content-Type', ctype)
        self.end_headers()

    def do_OPTIONS(self):
        self._send_cors(200)

    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length)

        if self.path == '/v1/agent/exec':
            self._handle_exec(body)
            return
        if self.path == '/v1/agent/fs':
            self._handle_fs(body)
            return

        try:
            req_data = json.loads(body.decode('utf-8'))
        except Exception:
            req_data = {}

        payload = build_payload(req_data.get('messages', []))
        data_bytes = json.dumps(payload, ensure_ascii=False).encode('utf-8')
        ctx = ssl.create_default_context()

        for model in ACTIVE_MODELS:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:streamGenerateContent?alt=sse"
            req = urllib.request.Request(url, data=data_bytes, method='POST')
            req.add_header('Content-Type', 'application/json; charset=utf-8')
            req.add_header('x-goog-api-key', GEMINI_KEY)

            try:
                resp = urllib.request.urlopen(req, context=ctx, timeout=30)
                self.send_response(200)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
                self.send_header('Cache-Control', 'no-cache')
                self.send_header('Connection', 'close')
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
                            except Exception:
                                pass

                self.wfile.write(b"data: [DONE]\n\n")
                self.wfile.flush()
                return
            except Exception as e:
                print(f"[Proxy] Model {model} failed: {e}")
                continue

        self._send_cors(503)
        self.wfile.write(json.dumps({"error": "يرجى المحاولة بعد لحظة، الخادم يستجيب الآن"}, ensure_ascii=False).encode('utf-8'))

    def _handle_exec(self, raw_body):
        try:
            data = json.loads(raw_body.decode('utf-8'))
            tool = data.get('tool', 'terminal_exec')
            cmd = data.get('command', '')
            rel_p = data.get('path', '')
            full_p = os.path.abspath(os.path.join(WORKSPACE_DIR, (rel_p or '').lstrip('/')))

            if tool == 'write_file':
                os.makedirs(os.path.dirname(full_p), exist_ok=True)
                with open(full_p, 'w', encoding='utf-8') as f: f.write(cmd)
                res = {"exit_code": 0, "output": f"تم الحفظ: {full_p}", "cwd": WORKSPACE_DIR}
            elif tool == 'read_file':
                if os.path.isfile(full_p):
                    with open(full_p, 'r', encoding='utf-8', errors='replace') as f:
                        res = {"exit_code": 0, "output": f.read(6000), "cwd": WORKSPACE_DIR}
                else: res = {"exit_code": 1, "output": "الملف غير موجود", "cwd": WORKSPACE_DIR}
            else:
                p = subprocess.run(["/bin/bash", "-c", f"cd {WORKSPACE_DIR} && {cmd}"], capture_output=True, text=True, timeout=90)
                res = {"exit_code": p.returncode, "output": p.stdout or p.stderr, "cwd": WORKSPACE_DIR}

            self._send_cors(200)
            self.wfile.write(json.dumps(res, ensure_ascii=False).encode('utf-8'))
        except Exception as e:
            self._send_cors(500)
            self.wfile.write(json.dumps({"exit_code": 1, "output": str(e)}).encode('utf-8'))

    def _handle_fs(self, raw_body):
        entries = []
        for r, dirs, files in os.walk(WORKSPACE_DIR):
            for fn in files:
                fp = os.path.join(r, fn)
                entries.append({"name": fn, "path": os.path.relpath(fp, WORKSPACE_DIR)})
        self._send_cors(200)
        self.wfile.write(json.dumps({"status": "ok", "files": entries}, ensure_ascii=False).encode('utf-8'))

    def log_message(self, format, *args): return

server = ReusableServer(('0.0.0.0', PORT), ProxyHandler)
server.serve_forever()
PYEOF

python3 /root/nasaq/proxy.py &
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
