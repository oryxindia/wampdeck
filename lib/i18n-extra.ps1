# Extra UI translations for WampDeck (phase 1: ur, ar, zh-CN).
# Loaded after lib\i18n.ps1. Technical names (PHP, MySQL, URL, SSL, hosts,
# WampDeck, HeidiSQL, Adminer, Notepad++, ngrok, Mailpit) stay unchanged.

$script:WampDeckLanguages += @(
    @{ Code = 'ur'; Name = 'Urdu' }
    @{ Code = 'ar'; Name = 'Arabic' }
)

$script:ExtraUiStrings = @{
    AppTitle         = @{ ur = 'ویمپ ڈیک'; ar = 'ويمب ديك'; 'zh-CN' = 'WampDeck' }
    AppSubtitle      = @{ ur = 'پورٹ ایبل PHP ڈویلپمنٹ اسٹیک'; ar = 'حزمة تطوير PHP محمولة'; 'zh-CN' = '便携式 PHP 开发环境' }
    Stack            = @{ ur = 'اسٹیک'; ar = 'الحزمة'; 'zh-CN' = '环境' }
    Project          = @{ ur = 'پروجیکٹ'; ar = 'المشروع'; 'zh-CN' = '项目' }
    Services         = @{ ur = 'سروسز'; ar = 'الخدمات'; 'zh-CN' = '服务' }
    Tools            = @{ ur = 'ٹولز'; ar = 'الأدوات'; 'zh-CN' = '工具' }
    Settings         = @{ ur = 'سیٹنگز'; ar = 'الإعدادات'; 'zh-CN' = '设置' }
    Help             = @{ ur = 'مدد'; ar = 'المساعدة'; 'zh-CN' = '帮助' }
    Language         = @{ ur = 'زبان'; ar = 'اللغة'; 'zh-CN' = '语言' }
    Start            = @{ ur = 'شروع کریں'; ar = 'ابدأ'; 'zh-CN' = '启动' }
    Stop             = @{ ur = 'روکیں'; ar = 'إيقاف'; 'zh-CN' = '停止' }
    Restart          = @{ ur = 'دوبارہ شروع'; ar = 'إعادة تشغيل'; 'zh-CN' = '重启' }
    Terminal         = @{ ur = '>_  ٹرمینل'; ar = '>_  الطرفية'; 'zh-CN' = '>_  终端' }
    TerminalHint     = @{ ur = 'www میں ٹرمینل کھولیں جہاں PHP، Composer، Git، Node اور MySQL تیار ہوں'; ar = 'افتح الطرفية في www مع PHP وComposer وGit وNode وMySQL'; 'zh-CN' = '在 www 中打开终端，PHP、Composer、Git、Node 和 MySQL 已就绪' }
    StartStack       = @{ ur = 'اسٹیک شروع کریں'; ar = 'بدء الحزمة'; 'zh-CN' = '启动环境' }
    StopStack        = @{ ur = 'اسٹیک روکیں'; ar = 'إيقاف الحزمة'; 'zh-CN' = '停止环境' }
    RestartStack     = @{ ur = 'اسٹیک دوبارہ شروع کریں'; ar = 'إعادة تشغيل الحزمة'; 'zh-CN' = '重启环境' }
    OpenPanelInBrowser = @{ ur = 'پینل براؤزر میں کھولیں'; ar = 'فتح اللوحة في المتصفح'; 'zh-CN' = '在浏览器中打开面板' }
    OpenWwwFolder    = @{ ur = 'www فولڈر کھولیں'; ar = 'فتح مجلد www'; 'zh-CN' = '打开 www 文件夹' }
    OpenLogsFolder   = @{ ur = 'لاگ فولڈر کھولیں'; ar = 'فتح مجلد السجلات'; 'zh-CN' = '打开日志文件夹' }
    TerminalInWww   = @{ ur = 'www میں ٹرمینل'; ar = 'الطرفية في www'; 'zh-CN' = 'www 中的终端' }
    Quit             = @{ ur = 'بाहر نکلیں'; ar = 'خروج'; 'zh-CN' = '退出' }
    NewProject       = @{ ur = 'نیا پروجیکٹ...'; ar = 'مشروع جديد...'; 'zh-CN' = '新建项目...' }
    OpenInBrowser    = @{ ur = 'براؤزر میں کھولیں'; ar = 'فتح في المتصفح'; 'zh-CN' = '在浏览器中打开' }
    OpenTestUrl      = @{ ur = '.test URL کھولیں'; ar = 'فتح رابط .test'; 'zh-CN' = '打开 .test 网址' }
    OpenFolder       = @{ ur = 'فولڈر کھولیں'; ar = 'فتح المجلد'; 'zh-CN' = '打开文件夹' }
    OpenTerminalHere = @{ ur = 'یہاں ٹرمینل کھولیں'; ar = 'افتتاح الطرفية هنا'; 'zh-CN' = '在此打开终端' }
    CopyLocalUrl     = @{ ur = 'لوکل URL کاپی کریں'; ar = 'نسخ الرابط المحلي'; 'zh-CN' = '复制本地网址' }
    DeleteProject    = @{ ur = 'پروجیکٹ حذف کریں...'; ar = 'حذف المشروع...'; 'zh-CN' = '删除项目...' }
    RefreshProjects  = @{ ur = 'پروجیکٹ لسٹ ریفریش کریں'; ar = 'تحديث قائمة المشاريع'; 'zh-CN' = '刷新项目列表' }
    ProjectPhpVersion = @{ ur = 'PHP ورژن'; ar = 'إصدار PHP'; 'zh-CN' = 'PHP 版本' }
    ProjectPhpDefault = @{ ur = 'اسٹیک ڈیفالٹ ({0})'; ar = 'الافتراضي ({0})'; 'zh-CN' = '默认环境 ({0})' }
    ProjectPhpChanged = @{ ur = '{0} اب PHP {1} چلاتا ہے۔'; ar = '{0} يعمل الآن بـ PHP {1}.'; 'zh-CN' = '{0} 现在运行 PHP {1}。' }
    ProjectPhpColumn  = @{ ur = 'PHP'; ar = 'PHP'; 'zh-CN' = 'PHP' }
    HeidiSql         = @{ ur = 'HeidiSQL'; ar = 'HeidiSQL'; 'zh-CN' = 'HeidiSQL' }
    MailpitInbox     = @{ ur = 'Mailpit (ویب ان باکس)'; ar = 'Mailpit (صندوق الويب)'; 'zh-CN' = 'Mailpit（网页邮箱）' }
    Adminer          = @{ ur = 'Adminer'; ar = 'Adminer'; 'zh-CN' = 'Adminer' }
    Phpinfo          = @{ ur = 'phpinfo()'; ar = 'phpinfo()'; 'zh-CN' = 'phpinfo()' }
    Notepad          = @{ ur = 'Notepad++'; ar = 'Notepad++'; 'zh-CN' = 'Notepad++' }
    NgrokStart       = @{ ur = 'ngrok ٹنل شروع کریں'; ar = 'بدء نفق ngrok'; 'zh-CN' = '启动 ngrok 隧道' }
    NgrokStop        = @{ ur = 'ngrok روکیں'; ar = 'إيقاف ngrok'; 'zh-CN' = '停止 ngrok' }
    NgrokNoToken     = @{ ur = 'ngrok شروع ہو گیا، مگر ابھی پبلک URL نہیں۔ پہلے authtoken شامل کریں۔'; ar = 'بدأ ngrok لكن لا يوجد رابط عام بعد. أضف authtoken أولاً.'; 'zh-CN' = 'ngrok 已启动，但尚无公开网址。请先添加 authtoken。' }
    HostsChecking    = @{ ur = 'hosts: چیک ہو رہا ہے'; ar = 'hosts: جارٍ الفحص'; 'zh-CN' = 'hosts: 检查中' }
    HostsSyncing     = @{ ur = 'hosts فائل سنک ہو رہی ہے...'; ar = 'جارٍ مزامنة ملف hosts...'; 'zh-CN' = '正在同步 hosts 文件...' }
    HostsOpening     = @{ ur = 'hosts فائل کھل رہی ہے...'; ar = 'جارٍ فتح ملف hosts...'; 'zh-CN' = '正在打开 hosts 文件...' }
    Cronical         = @{ ur = 'Cronical شیڈیولر'; ar = 'جدول Cronical'; 'zh-CN' = 'Cronical 计划任务' }
    SyncHosts        = @{ ur = 'hosts فائل سنک کریں (UAC)'; ar = 'زامنة ملف hosts (UAC)'; 'zh-CN' = '同步 hosts 文件 (UAC)' }
    EditHosts        = @{ ur = 'hosts فائل ایڈٹ کریں (UAC)'; ar = 'تعديل ملف hosts (UAC)'; 'zh-CN' = '编辑 hosts 文件 (UAC)' }
    CertificatesFolder = @{ ur = 'سرٹیفیکیٹ فولڈر'; ar = 'مجلد الشهادات'; 'zh-CN' = '证书文件夹' }
    PhpExtensions    = @{ ur = 'PHP ایکسٹینشنز...'; ar = 'إضافات PHP...'; 'zh-CN' = 'PHP 扩展...' }
    StartStackWhenPanelOpens = @{ ur = 'پینل کھلتے ہی اسٹیک شروع کریں'; ar = 'بدء الحزمة عند فتح اللوحة'; 'zh-CN' = '打开面板时启动环境' }
    StartWithWindows = @{ ur = 'Windows کے ساتھ شروع کریں'; ar = 'البدء مع Windows'; 'zh-CN' = '随 Windows 启动' }
    RefreshConfigs   = @{ ur = 'کنفیگ ریفریش کریں'; ar = 'تحديث الإعدادات'; 'zh-CN' = '刷新配置' }
    About            = @{ ur = 'WampDeck کے بارے میں'; ar = 'حول WampDeck'; 'zh-CN' = '关于 WampDeck' }
    Readme           = @{ ur = 'README'; ar = 'README'; 'zh-CN' = 'README' }
    OpenInstallFolder = @{ ur = 'انسٹال فولڈر کھولیں'; ar = 'فتح مجلد التثبيت'; 'zh-CN' = '打开安装文件夹' }
    EnableHttps      = @{ ur = 'HTTPS چالو کریں'; ar = 'تفعيل HTTPS'; 'zh-CN' = '启用 HTTPS' }
    DisableHttps     = @{ ur = 'HTTPS بند کریں'; ar = 'تعطيل HTTPS'; 'zh-CN' = '禁用 HTTPS' }
    TrustCert        = @{ ur = 'سرٹیفیکیٹ پر بھروسہ کریں (Windows ڈائیلاگ)'; ar = 'الوثوق بالشهادة (نافذة Windows)'; 'zh-CN' = '信任证书 (Windows 对话框)' }
    RegenerateCert   = @{ ur = 'سرٹیفیکیٹ دوبارہ بنائیں'; ar = 'إعادة توليد الشهادة'; 'zh-CN' = '重新生成证书' }
    Php              = @{ ur = 'PHP'; ar = 'PHP'; 'zh-CN' = 'PHP' }
    WebServer        = @{ ur = 'ویب سرور'; ar = 'خادم الويب'; 'zh-CN' = 'Web 服务器' }
    Database         = @{ ur = 'ڈیٹابیس'; ar = 'قاعدة البيانات'; 'zh-CN' = '数据库' }
    ExtraServices   = @{ ur = 'اضافی سروسز'; ar = 'خدمات إضافية'; 'zh-CN' = '其他服务' }
    MySql            = @{ ur = 'MySQL'; ar = 'MySQL'; 'zh-CN' = 'MySQL' }
    Running          = @{ ur = 'چالو'; ar = 'يعمل'; 'zh-CN' = '运行中' }
    Stopped          = @{ ur = 'بند'; ar = 'متوقف'; 'zh-CN' = '已停止' }
    Starting         = @{ ur = 'شروع ہو رہا ہے...'; ar = 'جارٍ البدء...'; 'zh-CN' = '启动中...' }
    Stopping         = @{ ur = 'رک رہا ہے...'; ar = 'جارٍ الإيقاف...'; 'zh-CN' = '停止中...' }
    StartingService  = @{ ur = 'سروش شروع ہو رہی ہے...'; ar = 'جارء بدء الخدمة...'; 'zh-CN' = '正在启动服务...' }
    StoppingService  = @{ ur = 'سروس رک رہی ہے...'; ar = 'جارٍ إيقاف الخدمة...'; 'zh-CN' = '正在停止服务...' }
    Ready            = @{ ur = 'تیار'; ar = 'جاهز'; 'zh-CN' = '就绪' }
    StartingTheStack = @{ ur = 'اسٹیک شروع ہو رہا ہے...'; ar = 'جارٍ بدء الحزمة...'; 'zh-CN' = '正在启动环境...' }
    StoppingTheStack  = @{ ur = 'اسٹیک رک رہا ہے...'; ar = 'جارٍ إيقاف الحزمة...'; 'zh-CN' = '正在停止环境...' }
    RestartingTheStack = @{ ur = 'اسٹیک دوبارہ شروع ہو رہا ہے...'; ar = 'جارٍ إعادة تشغيل الحزمة...'; 'zh-CN' = '正在重启环境...' }
    AnotherTaskRunning = @{ ur = 'ایک اور WampDeck کام ابھی چل رہا ہے۔ براہِ کرم انتظار کریں۔'; ar = 'مهام WampDeck أخرى لا تزال تعمل. يرجى الانتظار.'; 'zh-CN' = '另一个 WampDeck 任务仍在运行，请稍候。' }
    TaskFailed       = @{ ur = 'WampDeck کام ناکام ہو گیا (exit {0})۔'; ar = 'فشلت مهمة WampDeck (exit {0}).'; 'zh-CN' = 'WampDeck 任务失败 (exit {0})。' }
    CheckStatus      = @{ ur = 'چیک ہو رہا ہے'; ar = 'جارٍ الفحص'; 'zh-CN' = '检查中' }
    SslChecking      = @{ ur = 'ssl: چیک ہو رہا ہے'; ar = 'ssl: جارٍ الفحص'; 'zh-CN' = 'ssl: 检查中' }
    SslOn            = @{ ur = 'ssl: چالو، قابلِ اعتماد'; ar = 'ssl: مفعّل، موثوق'; 'zh-CN' = 'ssl: 已启用，受信任' }
    SslOnCaUntrusted = @{ ur = 'ssl: چالو، CA قابلِ اعتماد نہیں'; ar = 'ssl: مفعّل، CA غير موثوق'; 'zh-CN' = 'ssl: 已启用，CA 不受信任' }
    SslOff           = @{ ur = 'ssl: بند'; ar = 'ssl: متوقف'; 'zh-CN' = 'ssl: 已关闭' }
    Online           = @{ ur = 'آن لائن'; ar = 'متصل'; 'zh-CN' = '在线' }
    Offline          = @{ ur = 'آف لائن'; ar = 'غير متصل'; 'zh-CN' = '离线' }
    PortsBusy        = @{ ur = 'پورٹ ابھی بھی مصروف ہیں۔ دوسرا پروگرام روکیں یا پورٹ بدلیں۔'; ar = 'المنافذ لا تزال مشغولة. أوقف البرنامج الآخر أو غيّر المنافذ.'; 'zh-CN' = '端口仍被占用。请停止其他程序或更换端口。' }
    WwwHint          = @{ ur = 'پروجیکٹ کو ڈبل کلک کر کے کھولیں۔ www\ کی ہر فولڈر کو خودکار لوکل URL ملتا ہے۔'; ar = 'انقر مرتين على المشروع لفتحه. كل مجلد في www\ يحصل على رابط محلي تلقائياً.'; 'zh-CN' = '双击项目即可打开。www\ 中的每个文件夹都会自动获得本地网址。' }
    ServicesHint     = @{ ur = 'کور سروسز ہمیشہ چلتی ہیں۔ Mailpit، Redis یا Memcached کو Settings میں چالو کریں۔'; ar = 'الخدمات الأساسية تعمل دائماً. فعّل Mailpit أو Redis أو Memcached من الإعدادات.'; 'zh-CN' = '核心服务始终运行。可在设置中启用 Mailpit、Redis 或 Memcached。' }
    AutoStartInfo    = @{ ur = 'WampDeck Windows کے ساتھ شروع ہوگا (notification area میں)۔'; ar = 'سيبدأ WampDeck مع Windows (في منطقة الإشعارات).'; 'zh-CN' = 'WampDeck 将随 Windows 启动（在通知区域）。' }
    AutoStartOffInfo = @{ ur = 'WampDeck اب Windows کے ساتھ شروع نہیں ہوگا۔'; ar = 'لن يبدأ WampDeck مع Windows بعد الآن.'; 'zh-CN' = 'WampDeck 将不再随 Windows 启动。' }
    EnablingHttps    = @{ ur = 'HTTPS چالو ہو رہا ہے...'; ar = 'جارٍ تفعيل HTTPS...'; 'zh-CN' = '正在启用 HTTPS...' }
    DisablingHttps   = @{ ur = 'HTTPS بند ہو رہا ہے...'; ar = 'جارٍ تعطيل HTTPS...'; 'zh-CN' = '正在禁用 HTTPS...' }
    WaitingForTrust  = @{ ur = 'Windows تصدیق کا انتظار ہے...'; ar = 'في انتظار تأكيد Windows...'; 'zh-CN' = '正在等待 Windows 确认...' }
    RegeneratingCert = @{ ur = 'سرٹیفیکیٹ دوبارہ بن رہے ہیں...'; ar = 'جارٍ إعادة توليد الشهادات...'; 'zh-CN' = '正在重新生成证书...' }
    ServiceStart     = @{ ur = 'شروع کریں'; ar = 'بدء'; 'zh-CN' = '启动' }
    ServiceStop      = @{ ur = 'روکیں'; ar = 'إيقاف'; 'zh-CN' = '停止' }
    ServiceStartAll  = @{ ur = 'سب شروع کریں'; ar = 'بدء الكل'; 'zh-CN' = '全部启动' }
    ServiceStopAll   = @{ ur = 'سب روکیں'; ar = 'إيقاف الكل'; 'zh-CN' = '全部停止' }
    ServiceToggleStartup = @{ ur = 'اسٹارٹ اپ ٹوگل کریں'; ar = 'تبديل بدء التشغيل'; 'zh-CN' = '切换启动项' }
    ServiceAlways    = @{ ur = 'ہمیشہ'; ar = 'دائماً'; 'zh-CN' = '始终' }
    ServiceOff       = @{ ur = 'بند'; ar = 'متوقف'; 'zh-CN' = '关闭' }
    TabProjects     = @{ ur = 'پروجیکٹس'; ar = 'المشاريع'; 'zh-CN' = '项目' }
    TabServices     = @{ ur = 'سروسز'; ar = 'الخدمات'; 'zh-CN' = '服务' }
    TabTools        = @{ ur = 'ٹولز'; ar = 'الأدوات'; 'zh-CN' = '工具' }
    TabNewProject   = @{ ur = 'نیا پروجیکٹ'; ar = 'مشروع جديد'; 'zh-CN' = '新建项目' }
    TabOpen         = @{ ur = 'کھولیں'; ar = 'فتح'; 'zh-CN' = '打开' }
    TabTestUrl      = @{ ur = '.test URL'; ar = 'رابط .test'; 'zh-CN' = '.test 网址' }
    TabFolder       = @{ ur = 'فولڈر'; ar = 'مجلد'; 'zh-CN' = '文件夹' }
    TabCopyUrl      = @{ ur = 'URL کاپی کریں'; ar = 'نسخ الرابط'; 'zh-CN' = '复制网址' }
    TabDelete       = @{ ur = 'حذف کریں'; ar = 'حذف'; 'zh-CN' = '删除' }
    TabRefresh      = @{ ur = 'ریفریش'; ar = 'تحديث'; 'zh-CN' = '刷新' }
    TabTerminal     = @{ ur = 'ٹرمینل'; ar = 'الطرفية'; 'zh-CN' = '终端' }
    ProjectCount    = @{ ur = '{0} پروجیکٹ'; ar = '{0} مشروع'; 'zh-CN' = '{0} 个项目' }
    ProjectCountPlural = @{ ur = '{0} پروجیکٹس'; ar = '{0} مشاريع'; 'zh-CN' = '{0} 个项目' }
    TrayBalloon      = @{ ur = 'ابھی notification area میں چل رہا ہے۔'; ar = 'لا يزال يعمل في منطقة الإشعارات.'; 'zh-CN' = '仍在通知区域中运行。' }

    # ---- new keys: first-run picker, CMS/framework tab, Pro toolkit ----
    TabPhpFramework  = @{ en = 'Php Framework'; hi = 'PHP.framework'; ur = 'PHP.frime ورک'; ar = 'أطر PHP'; 'zh-CN' = 'PHP 框架' }
    Install          = @{ en = 'Install'; hi = 'انسٹال'; ur = 'انسٹال کریں'; ar = 'تثبيت'; 'zh-CN' = '安装' }
    FrameworkHint    = @{ en = 'One-click PHP framework install - free in WampDeck.'; hi = 'एक क्लिक में PHP फ्रेमवर्क इंस्टॉल - WampDeck में मुफ्त।'; ur = 'ایک کلک میں PHP فریم ورک انسٹال - WampDeck میں مفت۔'; ar = 'تثبيت أطر PHP بنقرة واحدة - مجاني في WampDeck.'; 'zh-CN' = '一键安装 PHP 框架 - WampDeck 免费提供。' }
    ProjectFolderName = @{ en = 'Project folder name'; hi = 'प्रोजेक्ट फ़ोल्डर का नाम'; ur = 'پروجیکٹ فولڈر کا نام'; ar = 'اسم مجلد المشروع'; 'zh-CN' = '项目文件夹名称' }
    FirstRunTitle    = @{ en = 'Welcome to WampDeck - choose your language'; hi = 'WampDeck में आपका स्वागत है - अपनी भाषा चुनें'; ur = 'WampDeck میں خوش آمدید - اپنی زبان منتخب کریں'; ar = 'مرحباً بك في WampDeck - اختر لغتك'; 'zh-CN' = '欢迎使用 WampDeck - 请选择语言' }
    FirstRunHint     = @{ en = 'Choose the language for the WampDeck interface.'; hi = 'WampDeck इंटरफ़ेस के लिए भाषा चुनें।'; ur = 'WampDeck انٹرفیس کے لیے زبان منتخب کریں۔'; ar = 'اختر اللغة لواجهة WampDeck.'; 'zh-CN' = '选择 WampDeck 界面语言。' }
    FirstRunRtlNote  = @{ en = 'Arabic uses right-to-left layout. This is set once during installation and will not change when you switch languages in Settings.'; hi = 'अरबी दाएँ से बाएँ लेआउट 사용 करती है। यह इंस्टॉलेशन के समय एक बार सेट होता है और Settings में भाषा बदलने पर नहीं बदलता।'; ur = 'عربی دائیں سے بائیں لے آؤٹ استعمال کرتی ہے۔ یہ انسٹالیشن کے وقت ایک بار طے ہوتا ہے اور Settings میں زبان بدلنے پر تبدیل نہیں ہوتا۔'; ar = 'العربية تستخدم تخطيطاً من اليمين إلى اليسار. يُضبط مرة واحدة أثناء التثبيت ولا يتغير عند تبديل اللغة من الإعدادات.'; 'zh-CN' = '阿拉伯语使用从右到左布局。此布局在安装时设定一次，在设置中切换语言时不会改变。' }
    ProTitle         = @{ en = 'WampDeck Pro - Developer toolkit for agencies'; hi = 'WampDeck Pro - एजेंसियों के लिए डेवलपर टूलकिट'; ur = 'WampDeck Pro - ایجنسیوں کے لیے ڈویلپر ٹول کٹ'; ar = 'WampDeck Pro - مجموعة أدوات المطورين للوكالات'; 'zh-CN' = 'WampDeck Pro - 面向团队的开发者工具包' }
    ProHealth        = @{ en = 'Health Dashboard'; hi = 'हेल्थ डैशबोर्ड'; ur = 'ہیلتھ ڈیش بورڈ'; ar = 'لوحة الصحة'; 'zh-CN' = '健康仪表盘' }
    ProBackups       = @{ en = 'Backups & Schedule'; hi = 'बैकअप और शेड्यूल'; ur = 'بیک اپ اور شیڈیول'; ar = 'النسخ الاحتياطي والجدولة'; 'zh-CN' = '备份与计划' }
    ProXdebug        = @{ en = 'Xdebug Toggle'; hi = 'Xdebug टॉगल'; ur = 'Xdebug ٹوگل'; ar = 'تبديل Xdebug'; 'zh-CN' = 'Xdebug 切换' }
    ProGit           = @{ en = 'Git Tools'; hi = 'Git टूल्स'; ur = 'Git ٹولز'; ar = 'أدوات Git'; 'zh-CN' = 'Git 工具' }
    ProMailpit       = @{ en = 'Mailpit Pro'; hi = 'Mailpit Pro'; ur = 'Mailpit Pro'; ar = 'Mailpit Pro'; 'zh-CN' = 'Mailpit Pro' }
    ProMore          = @{ en = 'Add-ons, Vault & Team'; hi = 'एड-ऑन, वॉल्ट और टीम'; ur = 'ایڈ آنز، والٹ اور ٹیم'; ar = 'الإضافات والخزنة والفريق'; 'zh-CN' = '附加组件、保险库与团队' }
    ProInstallSelected = @{ en = 'Install selected...'; hi = 'चुना हुआ इंस्टॉल करें...'; ur = 'منتخب انسٹال کریں...'; ar = 'تثبيت المحدد...'; 'zh-CN' = '安装所选...' }
    Cancel           = @{ en = 'Cancel'; hi = 'रद्द करें'; ur = 'منسوخ کریں'; ar = 'إلغاء'; 'zh-CN' = '取消' }
}

foreach ($key in $script:ExtraUiStrings.Keys) {
    if (-not $script:UiStrings.ContainsKey($key)) { $script:UiStrings[$key] = @{} }
    foreach ($lang in $script:ExtraUiStrings[$key].Keys) {
        $script:UiStrings[$key][$lang] = $script:ExtraUiStrings[$key][$lang]
    }
}

$script:ExtraUiStrings2 = @{
    DatabaseClient  = @{ en = 'Database client'; hi = 'डेटाबेस क्लाइंट'; ur = 'ڈیٹابیس کلائنٹ'; ar = 'عميل قاعدة البيانات'; 'zh-CN' = '数据库客户端' }
    CapturedMail    = @{ en = 'Captured mail'; hi = 'कैप्चर किया मेल'; ur = 'پکڑا گیا میل'; ar = 'البريد الملتقط'; 'zh-CN' = '捕获的邮件' }
    WebDatabase     = @{ en = 'Web database'; hi = 'वेब डेटाबेस'; ur = 'ویب ڈیٹابیس'; ar = 'قاعدة بيانات الويب'; 'zh-CN' = '网页数据库' }
    PhpSettings     = @{ en = 'PHP settings'; hi = 'PHP सेटिंग्स'; ur = 'PHP سیٹنگز'; ar = 'إعدادات PHP'; 'zh-CN' = 'PHP 设置' }
    TextEditor      = @{ en = 'Text editor'; hi = 'टेक्स्ट एडिटर'; ur = 'ٹیکسٹ ایڈیٹر'; ar = 'محرر النصوص'; 'zh-CN' = '文本编辑器' }
    VersionCheck    = @{ en = 'Version check'; hi = 'वर्जन जाँच'; ur = 'ورژن چیک'; ar = 'فحص الإصدار'; 'zh-CN' = '版本检查' }
    CronScheduler   = @{ en = 'Task scheduler'; hi = 'टास्क शेड्यूलर'; ur = 'ٹاسک شیڈیولر'; ar = 'جدول المهام'; 'zh-CN' = '计划任务' }
    CloseTunnel     = @{ en = 'Close the tunnel'; hi = 'टनल बंद करें'; ur = 'ٹنل بند کریں'; ar = 'إغلاق النفق'; 'zh-CN' = '关闭隧道' }
    HostsFile       = @{ en = 'Hosts file'; hi = 'होस्ट्स फ़ाइल'; ur = 'ہوسٹس فائل'; ar = 'ملف hosts'; 'zh-CN' = 'hosts 文件' }
    EditUac         = @{ en = 'Edit with UAC'; hi = 'UAC से एडिट'; ur = 'UAC کے ساتھ ایڈٹ'; ar = 'تعديل مع UAC'; 'zh-CN' = '使用 UAC 编辑' }
    SslFiles        = @{ en = 'SSL files'; hi = 'SSL फ़ाइलें'; ur = 'SSL فائلیں'; ar = 'ملفات SSL'; 'zh-CN' = 'SSL 文件' }
    RebuildVhosts   = @{ en = 'Rebuild vhosts'; hi = 'वर्चुअल होस्ट दोबारा बनाएँ'; ur = 'ورچوئل ہوسٹ دوبارہ بنائیں'; ar = 'إعادة بناء المضيفات الافتراضية'; 'zh-CN' = '重建虚拟主机' }
    Versions        = @{ en = 'Versions'; hi = 'वर्जन'; ur = 'ورژنز'; ar = 'الإصدارات'; 'zh-CN' = '版本' }
}
foreach ($key in $script:ExtraUiStrings2.Keys) {
    if (-not $script:UiStrings.ContainsKey($key)) { $script:UiStrings[$key] = @{} }
    foreach ($lang in $script:ExtraUiStrings2[$key].Keys) { $script:UiStrings[$key][$lang] = $script:ExtraUiStrings2[$key][$lang] }
}
