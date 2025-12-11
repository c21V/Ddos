#!/bin/bash
#
# GyOu Setup Script (setup.sh)
# المؤلف: gyou
# الوظيفة: إعداد بيئة التشغيل وتثبيت المتطلبات لأداة GyOu-Async-Strong.py

# تعريف متغيرات الأداة
PYTHON_SCRIPT="GyOu-Async-Strong.py"
PROXY_FILE="proxies.txt"
CONFIG_FILE="gyou_config.yml"
REQUIRED_LIBS="aiohttp pyyaml"

echo "=================================================="
echo "      [GyOu] Automated Setup Initialized"
echo "=================================================="

# --- 1. التحقق من وجود Python 3 ---
echo "[SETUP] 1. التحقق من Python 3 و pip3..."
if ! command -v python3 &> /dev/null
then
    echo "[ERROR] Python 3 غير مثبت. الرجاء تثبيته."
    exit 1
fi

if ! command -v pip3 &> /dev/null
then
    echo "[ERROR] pip3 غير مثبت. الرجاء تثبيته."
    exit 1
fi

# --- 2. تثبيت المكتبات المطلوبة ---
echo "[SETUP] 2. تثبيت المكتبات المطلوبة ($REQUIRED_LIBS)..."
# استخدام خيار --break-system-packages لضمان التثبيت حتى في البيئات المقيدة (Debian/Ubuntu)
pip3 install $REQUIRED_LIBS --break-system-packages

if [ $? -eq 0 ]; then
    echo "[SUCCESS] تم تثبيت جميع المكتبات بنجاح."
else
    echo "[ERROR] فشل تثبيت المكتبات. يرجى التحقق من المشكلات."
    exit 1
fi

# --- 3. إعداد صلاحيات التنفيذ ---
echo "[SETUP] 3. إعطاء صلاحيات التنفيذ للملفات..."
if [ -f "$PYTHON_SCRIPT" ]; then
    chmod +x "$PYTHON_SCRIPT"
    echo "[SUCCESS] تم تعيين صلاحية التنفيذ لـ $PYTHON_SCRIPT."
else
    echo "[ERROR] لم يتم العثور على ملف الأداة $PYTHON_SCRIPT."
fi

chmod +x "$0" # يعطي صلاحية التنفيذ لملف setup.sh نفسه
echo "[SUCCESS] تم تعيين صلاحية التنفيذ لـ setup.sh."

# --- 4. التحقق من ملفات الإعدادات ---
echo "[SETUP] 4. التحقق من ملفات الإعدادات الأساسية..."
if [ ! -f "$PROXY_FILE" ]; then
    echo "[INFO] إنشاء ملف بروكسيات فارغ: $PROXY_FILE"
    touch "$PROXY_FILE"
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[INFO] إنشاء ملف إعدادات YML افتراضي: $CONFIG_FILE"
    # إنشاء هيكل YML بسيط ليكون مرجعاً للمستخدم
    cat << EOF > "$CONFIG_FILE"
# GyOu Configuration File (gyou_config.yml)

attack_settings:
  global_concurrency: 2000
  default_method: "GET"
  timeout_seconds: 15
  sleep_between_tasks: 0.01

proxy_settings:
  proxy_file: "$PROXY_FILE"
  use_rotation: true
  
# إضافة أهداف (يمكن تعديل هذا القسم لاحقاً)
target_profiles:
  - name: "Default_Target"
    url: "http://example.com"
    method_override: "GET"

EOF
fi

# --- 5. التنظيف (إزالة ملفات التخزين المؤقت) ---
echo "[SETUP] 5. إزالة ملفات التخزين المؤقت لـ Python..."
find . -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null
echo "[SUCCESS] تم تنظيف ملفات الذاكرة المؤقتة."

echo ""
echo "=================================================="
echo "[SUCCESS] إعداد أداة GyOu اكتمل بنجاح!"
echo "الآن يمكنك تشغيل الأداة عبر:"
echo "./$PYTHON_SCRIPT -t <الهدف> -c <القوة>"
echo "=================================================="
