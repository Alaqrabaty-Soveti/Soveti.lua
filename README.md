# Echoes of Dawn — Roblox Cinematic Intro

افتتاحية سينمائية فخمة للعبة Roblox، مكتوبة بـ **Luau** بالكامل، تعمل على جهة العميل مع:
كاميرا سينمائية (6 مشاهد)، انتقالات احترافية، **VFX إجرائية** (جزيئات / موجة صدمة / أشعة / خطوط سرعة / جمرات)،
**SFX** قابلة للتفعيل بمعرفاتك، ومخرج **تايم‑لاين** واحد يدير كل شيء.

A cinematic intro system for Roblox, written in **Luau**: procedural VFX, SFX cues,
a director timeline, and a fully interruptible, self-cleaning sequence.

---

## ✨ المميزات / Features

- **كاميرا سينمائية**: `Scriptable` مع TweenService بين 6 لقطات، Dutch Roll (زوايا مائلة)،
  Handheld Sway (اهتزاز يدوي عضوي)، Noise Shake عالي التردد، وDolly FOV.
- **انتقالات احترافية**: Fade In/Out، Flash، Glitch (scanlines)، Letterbox سينمائي، Vignette،
  وتلاشٍ لوني (Tint Pulse).
- **VFX إجرائية (VFXManager)** — بلا أي أصول خارجية:
  - جزيئات جمرات عائمة دائمًا (Ambient Dust).
  - Burst جزيئات عند الذروة (160+ جزيء).
  - موجة صدمة (Neon Ball تتوسع + جزيئات حلقة).
  - أشعة نيون (6 Beams تدور حول الكاميرا).
  - خطوط سرعة (26+ خط متحرك).
- **SFX (AudioManager)**: Music + Ambience مع Fade، و6 قوائم صوتية جاهزة
  (Whoosh / Riser / Impact / Heartbeat / Shimmer / Title) — ضع معرّفاتك في `Config.Audio.Cues`.
- **مخرج تايم‑لاين (Timeline)**: كل حدث في `Config.Timeline` بوقت بالثانية —
  flash عند 14.5s، glitch، burst، title عند 18.5s… عدّل التوقيت من مكان واحد.
- **واجهة سينمائية**: عنوان بتأثير Stroke ذهبي، Tagline، شريط تقدم، زر تخطّي (مسافة / Enter / Escape).
- **تنظيف آمن**: إغلاق موحّد `idempotent`، إلغاء التوينات، فصل الاتصالات، إزالة كل المؤثرات
  (حتى SunRays)، واستعادة الكاميرا والتحكم — عند التخطي أو الخطأ أو خروج اللاعب.
- **Watchdog**: مؤقت أمان يحرّر الكاميرا والتحكم لو حدث توقف غير متوقع.
- **منع التكرار**: Attribute على اللاعب يمنع تشغيل الافتتاحية أكثر من مرة في الجلسة.

---

## 📁 هيكل المشروع / Project structure

```
src/
├── Config.lua            # كل الإعدادات: النصوص، الألوان، التوقيت، اللقطات، الأصوات، التايم-لاين
├── CameraController.lua  # الكاميرا: اللقطات، Dutch Roll، Sway، Shake، FOV، استعادة الحالة
├── UIManager.lua         # الواجهة بالكود: Letterbox، Vignette، Glitch، Flash، العنوان، التقدم
├── VFXManager.lua        # الجزيئات، موجة الصدمة، الأشعة، خطوط السرعة، الجمرات
├── EffectsManager.lua    # Blur / ColorCorrection / Bloom / DepthOfField / SunRays
├── AudioManager.lua      # الموسيقى والأجواء + قوائم SFX المسمّاة
├── IntroClient.lua       # المخرج: LocalScript يشغّل التايم-لاين والتنظيف
└── IntroServer.lua       # اختياري: تنسيق خادمي / إعادة تشغيل للاختبار
default.project.json      # ملف Rojo — يرفع كل شيء تلقائيًا
```

---

## 🚀 التركيب / Installation

### الطريقة 1 — Rojo (موصى بها)

```bash
rojo serve default.project.json
```

في Studio اضغط **Connect** في لوحة Rojo. سيُنشأ تلقائيًا:
- `ReplicatedStorage.CinematicIntro` (Config + 5 وحدات + VFXManager)
- `StarterPlayer.StarterPlayerScripts.CinematicIntroClient` (LocalScript)
- `ServerScriptService.CinematicIntroServer` (Script)

### الطريقة 2 — يدويًا

1. في `ReplicatedStorage` أنشئ **Folder** باسم `CinematicIntro`.
2. ضع داخله **ModuleScripts** بنفس الأسماء: `Config`, `CameraController`, `UIManager`,
   `AudioManager`, `EffectsManager`, `VFXManager` — وانقل محتوى كل ملف.
3. في `StarterPlayer → StarterPlayerScripts` أنشئ **LocalScript** باسم `CinematicIntroClient`
   وضع فيه محتوى `IntroClient.lua`.
4. (اختياري) في `ServerScriptService` أنشئ **Script** باسم `CinematicIntroServer`.

---

## ⚙️ التخصيص / Customization

كل شيء في `src/Config.lua`:

| الإعداد | الوظيفة |
|---|---|
| `Title` / `Subtitle` / `Tagline` | نصوص الافتتاحية (يدعم العربية) |
| `IntroDuration` | الطول الكلي بالثواني (يجب = مجموع `CameraShots`) |
| `Colors` | هوية الألوان |
| `Fade` | مدد التلاشي وشدة الومضة |
| `Effects` | Blur، التصحيح اللوني، Bloom، العمق، SunRays، الاهتزاز |
| `Audio.*Id` / `Audio.Cues` | معرّفات أصول الصوت (0 = معطّل) |
| `CameraShots` | اللقطات: المدة، التنعيم، الإزاحة، FOV، roll، sway، shake |
| `Timeline` | **المخرج**: كل حدث بالثانية (flash / burst / sfx / title…) |

### لقطات الكاميرا
- بدون `attachment`: الكاميرا تُبنى حول شخصية اللاعب باستخدام `offset` و `lookOffset`.
- مع `attachment`: ضع `BasePart` أو `Attachment` في `Workspace` بنفس الاسم
  (مثل `IntroCamEstablish`) لقطة ثابتة في العالم.

### التايم‑لاين — أمثلة سريعة
```lua
-- ومضة عند 10 ثوانٍ:
{ t = 10.0, action = "flash" },
-- صوت Impact + انفجار جزيئات:
{ t = 12.0, action = "impact" },
{ t = 12.0, action = "burst", args = { 1.0 } },
-- عنوان:
{ t = 15.0, action = "title" },
```

### الأصوات
ضع معرّفات أصول تملك حقوق استخدامها، مثال:
```lua
Config.Audio.Cues.Impact = { id = 1234567890, volume = 0.85, pitch = 1.0 }
```
اتركها `0` لتعطيل الصوت تمامًا — لا شيء ينكسر.

---

## 🧪 الاختبار / Testing

- **فحص الصياغة محليًا**:
  ```bash
  luau-analyze src/IntroClient.lua
  ```
  ملاحظة: تحذيرات `Unknown global 'game'/'Enum'` متوقعة (luau-analyze لا يعرف أنواع Roblox).
  الأخطاء الحقيقية فقط: `syntax` / `unexpected` / `unclosed`.
- **الاختبار الحقيقي** في Roblox Studio: شغّل (Play) وراقب المشاهد والانتقالات والتخطي.

### قائمة تحقق
- [ ] الافتتاحية تعمل مرة واحدة فقط.
- [ ] التخطي يعمل باللمس/الماوس و Space / Enter / Escape.
- [ ] بعد التخطي أو النهاية: الكاميرا تعود والتحكم يشتغل.
- [ ] لا تبقى مؤثرات (`BlurEffect` / `ScreenGui` / أجزاء VFX) في المشهد.
- [ ] الواجهة مقروءة على موبايل صغير وشاشة كبيرة.

---

## 🔒 ملاحظات / Notes

- الافتتاحية تعمل بالكامل على العميل — لا تمنح العميل أي منطق حساس.
- لا أصول مضمّنة: كل VFX إجرائية، والصوت يُفعّل بمعرفاتك.
- `IntroServer.lua` اختياري — احذفه إن لم تحتج تنسيقًا خادميًا.

---

## 📄 الترخيص / License

الكود ملكك للاستخدام في مشاريعك. الأصول الصوتية/البصرية التي تضيفها تخضع لترخيصها الخاص.
