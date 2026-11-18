# Echoes of Dawn — Roblox Cinematic Anime Intro

نظام افتتاحية سينمائية بأسلوب الأنمي للعبة Roblox، مكتوب بـ **Luau** بالكامل، ويعمل على جهة العميل (Client) مع كاميرا سينمائية وانتقالات وواجهة متجاوبة وصوت اختياري.

A cinematic anime-style intro system for Roblox, written in **Luau**.

---

## ✨ المميزات / Features

- **كاميرا سينمائية**: كاميرا `Scriptable` مؤقتة مع `TweenService` بين لقطات قابلة للتخصيص، دعم Zoom / Pan / FOV، اهتزاز محدود، واستعادة كاملة لإعدادات كاميرا اللاعب.
- **مشاهد متسلسلة**: 5 مشاهد موقوتة (افتتاح، تأسيس العالم، دخول البطل، الذروة، العنوان والتسليم) بإجمالي ~22 ثانية.
- **انتقالات احترافية**: Fade In/Out، Flash، Glitch قصير، Pulse لوني، Blur تدريجي، وLetterbox سينمائي.
- **مؤثرات بصرية**: `BlurEffect`، `ColorCorrectionEffect`، `BloomEffect`، `DepthOfFieldEffect` — كلها تُنشأ وتُزال تلقائيًا.
- **واجهة متجاوبة**: عنوان ونص ترحيبي بحركة كتابة، زر تخطٍ كبير مناسب للمس، وتخطٍ بلوحة المفاتيح (Space / Enter).
- **صوت اختياري**: Ambient + Music + Cues عبر معرّفات أصول تضعها أنت (لا أصول مضمّنة).
- **تنظيف آمن**: إغلاق موحّد `idempotent`، إلغاء التوينات، فصل الاتصالات، إزالة المؤثرات، واستعادة التحكم — حتى عند التخطي أو الخطأ أو خروج اللاعب.
- **منع التكرار**: Attribute على اللاعب يمنع تشغيل الافتتاحية أكثر من مرة في الجلسة.
- **Watchdog**: مؤقت أمان يحرّر الكاميرا والتحكم لو حصل أي توقف غير متوقع.

---

## 📁 هيكل المشروع / Project structure

```
src/
├── Config.lua            # كل الإعدادات: النصوص، الألوان، التوقيت، اللقطات، الأصوات، المؤثرات
├── CameraController.lua  # الكاميرا السينمائية واللقطات والاهتزاز واستعادة الحالة
├── UIManager.lua         # بناء الواجهة بالكود + الانتقالات + زر التخطي
├── EffectsManager.lua    # Blur / ColorCorrection / Bloom / DepthOfField
├── AudioManager.lua      # الموسيقى والأجواء مع تلاشي آمن
├── IntroClient.lua       # نقطة الدخول (LocalScript) وتنسيق المشاهد
└── IntroServer.lua       # اختياري: تنسيق خادمي / إعادة تشغيل للاختبار
default.project.json      # ملف Rojo للاستيراد التلقائي إلى Roblox Studio
```

---

## 🚀 التركيب / Installation

### الطريقة 1 — Rojo (موصى بها)

1. ثبّت [Rojo](https://rojo.space/) وامتداد Rojo في Roblox Studio.
2. من مجلد المشروع نفّذ:
   ```bash
   rojo serve
   ```
3. في Studio اضغط **Connect** في لوحة Rojo. سيُنشأ تلقائيًا:
   - `ReplicatedStorage.CinematicIntro` (Config + الوحدات)
   - `StarterPlayer.StarterPlayerScripts.CinematicIntroClient` (LocalScript)
   - `ServerScriptService.CinematicIntroServer` (Script)

### الطريقة 2 — يدويًا

1. في `ReplicatedStorage` أنشئ **Folder** باسم `CinematicIntro`.
2. ضع داخله **ModuleScripts** بنفس الأسماء: `Config`, `CameraController`, `UIManager`, `AudioManager`, `EffectsManager` — وانقل محتوى كل ملف.
3. في `StarterPlayer → StarterPlayerScripts` أنشئ **LocalScript** باسم `CinematicIntroClient` وضع فيه محتوى `IntroClient.lua`.
4. (اختياري) في `ServerScriptService` أنشئ **Script** باسم `CinematicIntroServer` وضع فيه محتوى `IntroServer.lua`.

---

## ⚙️ التخصيص / Customization

كل شيء تقريبًا في `src/Config.lua`:

| الإعداد | الوظيفة |
|---|---|
| `Title` / `Subtitle` | نص العنوان والترحيب (يدعم العربية) |
| `IntroDuration` | الطول الكلي بالثواني |
| `Colors` | هوية الألوان |
| `Fade` | مدد التلاشي وشدة الومضة |
| `Effects` | شدة الـBlur، التصحيح اللوني، Bloom، العمق، الاهتزاز |
| `Audio.*Id` | معرّفات أصول الصوت (0 = معطّل) |
| `Audio.SyncPoints` | نقاط المزامنة الزمنية بين المشاهد والصوت |
| `CameraShots` | اللقطات: المدة، نوع التنعيم، الإزاحة، FOV، الاهتزاز |

### لقطات الكاميرا
- بدون `attachment`: الكاميرا تُبنى حول شخصية اللاعب باستخدام `offset` و `lookOffset`.
- مع `attachment`: ضع `BasePart` أو `Attachment` في `Workspace` بنفس الاسم (مثل `IntroCamEstablish`) لتحديد لقطة ثابتة في العالم.

### الأصوات
ضع معرّفات أصول تملك حقوق استخدامها، مثال:
```lua
Config.Audio.MusicId = 1234567890
```
اتركها `0` لتعطيل الصوت تمامًا.

---

## 🧪 الاختبار / Testing

- **فحص الصياغة محليًا** (بدون Roblox):
  ```bash
  luau-analyze src/Config.lua
  ```
  ملاحظة: `luau-analyze` لا يعرف أنواع Roblox الافتراضية، لذا ستظهر تحذيرات `Unknown global 'game' / 'Enum'` — هذه متوقعة وليست أخطاء. المهم ألّا تظهر أخطاء `syntax` / `unexpected` / `unclosed`.
- **الاختبار الحقيقي** يتطلب Roblox Studio: شغّل اللعبة (Play) وراقب الكاميرا، التخطي، واستعادة التحكم بعد النهاية.

### قائمة تحقق سريعة
- [ ] الافتتاحية تعمل مرة واحدة فقط.
- [ ] زر التخطي يعمل باللمس والماوس، وSpace/Enter بالكيبورد.
- [ ] بعد التخطي أو النهاية: الكاميرا ترجع للاعب والتحكم يشتغل.
- [ ] لا يبقى أي `BlurEffect` أو `ColorCorrectionEffect` أو `ScreenGui` في المشهد.
- [ ] الواجهة مقروءة على شاشة موبايل صغيرة وعلى شاشة كبيرة.

---

## 🔒 ملاحظات وأمان / Notes & security

- الافتتاحية تعمل بالكامل على العميل، فلا تمنح العميل أي صلاحيات أو منطق لعب حساس.
- لا توجد مفاتيح أو رموز سرية في المشروع.
- لا تُضمّن أصولًا صوتية أو صورًا مجهولة الترخيص؛ استخدم أصولك أو أصول Roblox الرسمية المرخّصة.
- `IntroServer.lua` اختياري بالكامل — احذفه إن لم تحتج تنسيقًا خادميًا.

---

## 📄 الترخيص / License

الكود ملكك للاستخدام في مشاريعك. الأصول الصوتية/البصرية التي تضيفها تخضع لترخيصها الخاص.
