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

$script:ExtraUiStrings3 = @{
    ColumnProject  = @{ en='Project';       ur='پروجیکٹ';  ar='المشروع';   'zh-CN'='项目';     fr='Projet';      de='Projekt';     cs='Projekt' }
    ColumnPhp      = @{ en='PHP';           ur='PHP';       ar='PHP';      'zh-CN'='PHP';      fr='PHP';         de='PHP';         cs='PHP' }
    ColumnLocalUrl = @{ en='Local URL';     ur='لوکل URL';  ar='رابط محلي'; 'zh-CN'='本地网址'; fr='URL locale';  de='Lokale URL';  cs='Místní URL' }
    ColumnTestUrl  = @{ en='.test URL';     ur='.test URL'; ar='رابط .test';'zh-CN'='.test 网址';fr='URL .test';   de='.test-URL';   cs='.test URL' }
    ColumnFolder   = @{ en='Folder';        ur='فولڈر';     ar='مجلد';      'zh-CN'='文件夹';   fr='Dossier';     de='Ordner';      cs='Složka' }
    ServiceCount   = @{ en='{0} service';   ur='{0} سروس';   ar='{0} خدمة';   'zh-CN'='{0} 个服务'; fr='{0} service'; de='{0} Dienst'; cs='{0} služba' }
    ServiceCountPl = @{ en='{0} services';  ur='{0} سروسز';  ar='{0} خدمات'; 'zh-CN'='{0} 个服务'; fr='{0} services'; de='{0} Dienste'; cs='{0} služby' }
    FrontendTitle  = @{ en='PHP Frameworks - one-click install'; ur='PHP فریم ورک - ایک کلک میں انسٹال'; ar='أطر PHP - تثبيت بنقرة واحدة'; 'zh-CN'='PHP 框架 - 一键安装'; fr='Frameworks PHP - installation en un clic'; de='PHP-Frameworks - Installation mit einem Klick'; cs='PHP frameworky - instalace jedním klikem' }
    InstallLabel   = @{ en='Install';       ur='انسٹال';    ar='تثبيت';    'zh-CN'='安装';     fr='Installer';   de='Installieren'; cs='Instalovat' }
    FolderLabel    = @{ en='Project folder name'; ur='پروجیکٹ فولڈر کا نام'; ar='اسم مجلد المشروع'; 'zh-CN'='项目文件夹名称'; fr='Nom du dossier du projet'; de='Projektordnername'; cs='Název složky projektu' }
    FrameworkHint2 = @{ en='One-click PHP framework install - free in WampDeck.'; ur='ایک کلک میں PHP فریم ورک انسٹال - WampDeck میں مفت۔'; ar='تثبيت أطر PHP بنقرة واحدة - مجاني في WampDeck.'; 'zh-CN'='一键安装 PHP 框架 - WampDeck 免费提供。'; fr='Installation des frameworks PHP en un clic - gratuit dans WampDeck.'; de='PHP-Frameworks mit einem Klick - kostenlos in WampDeck.'; cs='Instalace PHP frameworků jedním klikem - zdarma ve WampDeck.' }
}
foreach ($key in $script:ExtraUiStrings3.Keys) {
    if (-not $script:UiStrings.ContainsKey($key)) { $script:UiStrings[$key] = @{} }
    foreach ($lang in $script:ExtraUiStrings3[$key].Keys) { $script:UiStrings[$key][$lang] = $script:ExtraUiStrings3[$key][$lang] }
}

# WampDeck UI translations - Phase 2: French, German, Czech.
# Loaded after i18n.ps1 and i18n-extra.ps1.

$script:Phase2Strings = @{
    AppTitle         = @{ fr='WampDeck'; de='WampDeck'; cs='WampDeck'; hi='वाम्पडेक'; ur='ویمپ ڈیک'; ar='ويمب ديك'; 'zh-CN'='WampDeck' }
    AppSubtitle      = @{ fr='Pile de développement PHP portable'; de='Portable PHP-Entwicklungsumgebung'; cs='Přenosné PHP vývojové prostředí'; hi='पोर्टेबल PHP डेवलपमेंट स्टैक' }
    Stack            = @{ fr='Pile'; de='Umgebung'; cs='Prostředí'; hi='स्टैक' }
    Project          = @{ fr='Projet'; de='Projekt'; cs='Projekt'; hi='प्रोजेक्ट' }
    Services         = @{ fr='Services'; de='Dienste'; cs='Služby'; hi='सेवाएँ' }
    Tools            = @{ fr='Outils'; de='Werkzeuge'; cs='Nástroje'; hi='उपकरण' }
    Settings         = @{ fr='Paramètres'; de='Einstellungen'; cs='Nastavení'; hi='सेटिंग्स' }
    Help             = @{ fr='Aide'; de='Hilfe'; cs='Nápověda'; hi='मदद' }
    Language         = @{ fr='Langue'; de='Sprache'; cs='Jazyk'; hi='भाषा' }
    Start            = @{ fr='Démarrer'; de='Start'; cs='Spustit'; hi='शुरू करें' }
    Stop             = @{ fr='Arrêter'; de='Stopp'; cs='Zastavit'; hi='रोकें' }
    Restart          = @{ fr='Redémarrer'; de='Neustart'; cs='Restartovat'; hi='पुनरारंभ करें' }
    Terminal         = @{ fr='>_  Terminal'; de='>_  Terminal'; cs='>_  Terminál'; hi='>_  टर्मिनल' }
    TerminalHint     = @{ fr='Ouvrir un terminal dans www avec PHP, Composer, Git, Node et MySQL prêts'; de='Terminal in www öffnen - PHP, Composer, Git, Node und MySQL bereit'; cs='Otevřít terminál ve www s PHP, Composer, Git, Node a MySQL'; hi='PHP, Composer, Git, Node और MySQL उपलब्ध होने पर www में टर्मिनल खोलें' }
    StartStack       = @{ fr='Démarrer la pile'; de='Umgebung starten'; cs='Spustit prostředí'; hi='स्टैक शुरू करें' }
    StopStack        = @{ fr='Arrêter la pile'; de='Umgebung stoppen'; cs='Zastavit prostředí'; hi='स्टैक रोकें' }
    RestartStack     = @{ fr='Redémarrer la pile'; de='Umgebung neu starten'; cs='Restartovat prostředí'; hi='स्टैक पुनरारंभ करें' }
    OpenPanelInBrowser = @{ fr='Ouvrir le panneau dans le navigateur'; de='Panel im Browser öffnen'; cs='Otevřít panel v prohlížeči'; hi='ब्राउज़र में पैनल खोलें' }
    OpenWwwFolder    = @{ fr='Ouvrir le dossier www'; de='www-Ordner öffnen'; cs='Otevřít složku www'; hi='www फ़ोल्डर खोलें' }
    OpenLogsFolder   = @{ fr='Ouvrir le dossier des journaux'; de='Protokollordner öffnen'; cs='Otevřít složku logů'; hi='लॉग फ़ोल्डर खोलें' }
    TerminalInWww   = @{ fr='Terminal dans www'; de='Terminal in www'; cs='Terminál ve www'; hi='www में टर्मिनल' }
    Quit             = @{ fr='Quitter'; de='Beenden'; cs='Ukončit'; hi='बाहर निकलें' }
    NewProject       = @{ fr='Nouveau projet...'; de='Neues Projekt...'; cs='Nový projekt...'; hi='नया प्रोजेक्ट...' }
    OpenInBrowser    = @{ fr='Ouvrir dans le navigateur'; de='Im Browser öffnen'; cs='Otevřít v prohlížeči'; hi='ब्राउज़र में खोलें' }
    OpenTestUrl      = @{ fr='Ouvrir l URL .test'; de='.test-URL öffnen'; cs='Otevřít .test URL'; hi='.test URL खोलें' }
    OpenFolder       = @{ fr='Ouvrir le dossier'; de='Ordner öffnen'; cs='Otevřít složku'; hi='फ़ोल्डर खोलें' }
    OpenTerminalHere = @{ fr='Ouvrir un terminal ici'; de='Hier Terminal öffnen'; cs='Otevřít terminál zde'; hi='यहाँ टर्मिनल खोलें' }
    CopyLocalUrl     = @{ fr='Copier l URL locale'; de='Lokale URL kopieren'; cs='Kopírovat místní URL'; hi='लोकल URL कॉपी करें' }
    DeleteProject    = @{ fr='Supprimer le projet...'; de='Projekt löschen...'; cs='Odstranit projekt...'; hi='प्रोजेक्ट हटाएँ...' }
    RefreshProjects  = @{ fr='Actualiser la liste des projets'; de='Projektliste aktualisieren'; cs='Obnovit seznam projektů'; hi='प्रोजेक्ट सूची रिफ्रेश करें' }
    ProjectPhpVersion = @{ fr='Version de PHP'; de='PHP-Version'; cs='Verze PHP'; hi='PHP संस्करण' }
    ProjectPhpDefault = @{ fr='Pile par défaut ({0})'; de='Standardumgebung ({0})'; cs='Výchozí prostředí ({0})'; hi='स्टैक डिफ़ॉल्ट ({0})' }
    ProjectPhpChanged = @{ fr='{0} utilise maintenant PHP {1}.'; de='{0} läuft jetzt mit PHP {1}.'; cs='{0} nyní běží na PHP {1}.'; hi='{0} अब PHP {1} पर चलता है।' }
    ProjectPhpColumn  = @{ fr='PHP'; de='PHP'; cs='PHP' }
    HeidiSql         = @{ fr='HeidiSQL'; de='HeidiSQL'; cs='HeidiSQL' }
    MailpitInbox     = @{ fr='Mailpit (boîte web)'; de='Mailpit (Web-Postfach)'; cs='Mailpit (webová schránka)'; hi='मेलपिट इनबॉक्स' }
    Adminer          = @{ fr='Adminer'; de='Adminer'; cs='Adminer' }
    Phpinfo          = @{ fr='phpinfo()'; de='phpinfo()'; cs='phpinfo()' }
    Notepad          = @{ fr='Notepad++'; de='Notepad++'; cs='Notepad++' }
    NgrokStart       = @{ fr='Démarrer le tunnel ngrok'; de='ngrok-Tunnel starten'; cs='Spustit ngrok tunel'; hi='ngrok टनल शुरू करें' }
    NgrokStop        = @{ fr='Arrêter ngrok'; de='ngrok stoppen'; cs='Zastavit ngrok'; hi='ngrok रोकें' }
    NgrokNoToken     = @{ fr='ngrok démarré, mais aucune URL publique. Ajoutez d abord votre authtoken.'; de='ngrok gestartet, aber noch keine öffentliche URL. Zuerst authtoken hinzufügen.'; cs='ngrok spuštěn, ale zatím bez veřejné URL. Nejprve přidejte authtoken.'; hi='ngrok शुरू हो गया, पर अभी public URL नहीं है। पहले authtoken दें।' }
    HostsChecking    = @{ fr='hosts : vérification'; de='hosts: Prüfung läuft'; cs='hosts: kontrola'; hi='hosts: जाँच हो रही है' }
    HostsSyncing     = @{ fr='Synchronisation du fichier hosts...'; de='hosts-Datei wird synchronisiert...'; cs='Synchronizace souboru hosts...'; hi='होस्ट्स फ़ाइल सिंक हो रही है...' }
    HostsOpening     = @{ fr='Ouverture du fichier hosts...'; de='hosts-Datei wird geöffnet...'; cs='Otevírání souboru hosts...'; hi='होस्ट्स फ़ाइल खोल रही है...' }
    Cronical         = @{ fr='Planificateur Cronical'; de='Cronical-Planer'; cs='Plánovač Cronical'; hi='Cronical शेड्यूलर' }
    SyncHosts        = @{ fr='Synchroniser hosts (UAC)'; de='hosts synchronisieren (UAC)'; cs='Synchronizovat hosts (UAC)'; hi='होस्ट्स फ़ाइल सिंक करें (UAC)' }
    EditHosts        = @{ fr='Modifier hosts (UAC)'; de='hosts bearbeiten (UAC)'; cs='Upravit hosts (UAC)'; hi='होस्ट्स फ़ाइल एडिट करें (UAC)' }
    CertificatesFolder = @{ fr='Dossier des certificats'; de='Zertifikatsordner'; cs='Složka certifikátů'; hi='सर्टिफिकेट फ़ोल्डर' }
    PhpExtensions    = @{ fr='Extensions PHP...'; de='PHP-Erweiterungen...'; cs='PHP rozšíření...'; hi='PHP एक्सटेंशन...' }
    StartStackWhenPanelOpens = @{ fr='Démarrer la pile à l ouverture du panneau'; de='Umgebung beim Öffnen des Panels starten'; cs='Spustit prostředí při otevření panelu'; hi='पैनल खुलते ही स्टैक शुरू करें' }
    StartWithWindows = @{ fr='Démarrer avec Windows'; de='Mit Windows starten'; cs='Spustit s Windows'; hi='Windows के साथ शुरू करें' }
    RefreshConfigs   = @{ fr='Actualiser la configuration'; de='Konfiguration aktualisieren'; cs='Obnovit konfiguraci'; hi='कॉन्फिगरेशन रिफ्रेश करें' }
    About            = @{ fr='À propos de WampDeck'; de='Über WampDeck'; cs='O WampDeck'; hi='WampDeck के बारे में' }
    Readme           = @{ fr='README'; de='README'; cs='README' }
    OpenInstallFolder = @{ fr='Ouvrir le dossier d installation'; de='Installationsordner öffnen'; cs='Otevřít instalační složku'; hi='इनस्टॉल फ़ोल्डर खोलें' }
    EnableHttps      = @{ fr='Activer HTTPS'; de='HTTPS aktivieren'; cs='Povolit HTTPS'; hi='HTTPS चालू करें' }
    DisableHttps     = @{ fr='Désactiver HTTPS'; de='HTTPS deaktivieren'; cs='Zakázat HTTPS'; hi='HTTPS बंद करें' }
    TrustCert        = @{ fr='Approuver le certificat (fenêtre Windows)'; de='Zertifikat vertrauen (Windows-Dialog)'; cs='Důvěryhodný certifikát (dialog Windows)'; hi='सर्टिफिकेट विश्वास करें' }
    RegenerateCert   = @{ fr='Régénérer le certificat'; de='Zertifikat neu erzeugen'; cs='Znovu vygenerovat certifikát'; hi='सर्टिफिकेट दोबारा बनाएँ' }
    Php              = @{ fr='PHP'; de='PHP'; cs='PHP' }
    WebServer        = @{ fr='Serveur web'; de='Webserver'; cs='Webový server'; hi='वेब सर्वर' }
    Database         = @{ fr='Base de données'; de='Datenbank'; cs='Databáze'; hi='डेटाबेस' }
    ExtraServices   = @{ fr='Services supplémentaires'; de='Zusätzliche Dienste'; cs='Další služby'; hi='अतिरिक्त सेवाएँ' }
    MySql            = @{ fr='MySQL'; de='MySQL'; cs='MySQL' }
    Running          = @{ fr='en cours'; de='läuft'; cs='spusteno'; hi='चालू' }
    Stopped          = @{ fr='arrêté'; de='gestoppt'; cs='zastaveno'; hi='बंद' }
    Starting         = @{ fr='démarrage...'; de='startet...'; cs='spouští se...'; hi='शुरू हो रहा है...' }
    Stopping         = @{ fr='arrêt...'; de='stoppt...'; cs='zastavuje se...'; hi='रुक रहा है...' }
    StartingService  = @{ fr='Démarrage du service...'; de='Dienst startet...'; cs='Spouštění služby...'; hi='सेवा शुरू हो रही है...' }
    StoppingService  = @{ fr='Arrêt du service...'; de='Dienst stoppt...'; cs='Zastavování služby...'; hi='सेवा रुक रही है...' }
    Ready            = @{ fr='Prêt'; de='Bereit'; cs='Připraveno'; hi='तैयार' }
    StartingTheStack = @{ fr='Démarrage de la pile...'; de='Umgebung startet...'; cs='Spouštění prostředí...'; hi='स्टैक शुरू हो रहा है...' }
    StoppingTheStack  = @{ fr='Arrêt de la pile...'; de='Umgebung stoppt...'; cs='Zastavování prostředí...'; hi='स्टैक रुक रहा है...' }
    RestartingTheStack = @{ fr='Redémarrage de la pile...'; de='Umgebung startet neu...'; cs='Restartování prostředí...'; hi='स्टैक पुनरारंभ हो रहा है...' }
    AnotherTaskRunning = @{ fr='Une autre tâche WampDeck est encore en cours. Veuillez patienter.'; de='Eine andere WampDeck-Aufgabe läuft noch. Bitte warten.'; cs='Další úloha WampDeck stále běží. Počkejte prosím.'; hi='एक और WampDeck कार्य अभी चल रहा है।' }
    TaskFailed       = @{ fr='Tâche WampDeck échouée (exit {0}).'; de='WampDeck-Aufgabe fehlgeschlagen (exit {0}).'; cs='Úloha WampDeck selhala (exit {0}).'; hi='WampDeck कार्य विफल रहा (exit {0})।' }
    CheckStatus      = @{ fr='VÉRIFICATION'; de='PRÜFUNG'; cs='KONTROLA'; hi='जाँच हो रही है' }
    SslChecking      = @{ fr='ssl : vérification'; de='ssl: Prüfung'; cs='ssl: kontrola'; hi='ssl: जाँच हो रही है' }
    SslOn            = @{ fr='ssl : activé, approuvé'; de='ssl: aktiv, vertraut'; cs='ssl: zapnuto, důvěryhodné'; hi='ssl: चालू, विश्वासित' }
    SslOnCaUntrusted = @{ fr='ssl : activé, CA non approuvé'; de='ssl: aktiv, CA nicht vertraut'; cs='ssl: zapnuto, CA nedůvěryhodná'; hi='ssl: चालू, CA विश्वासित नहीं' }
    SslOff           = @{ fr='ssl : désactivé'; de='ssl: aus'; cs='ssl: vypnuto'; hi='ssl: बंद' }
    Online           = @{ fr='EN LIGNE'; de='ONLINE'; cs='ONLINE'; hi='ऑनलाइन' }
    Offline          = @{ fr='HORS LIGNE'; de='OFFLINE'; cs='OFFLINE'; hi='ऑफ़लाइन' }
    PortsBusy        = @{ fr='Les ports sont encore occupés. Arrêtez l autre programme ou changez les ports.'; de='Ports sind noch belegt. Anderes Programm stoppen oder Ports ändern.'; cs='Porty jsou stále obsazeny. Zastavte jiný program nebo změňte porty.'; hi='पोर्ट अभी भी व्यस्त हैं।' }
    WwwHint          = @{ fr='Double-cliquez sur un projet pour l ouvrir. Chaque dossier dans www\ reçoit une URL locale automatiquement.'; de='Projekt mit Doppelklick öffnen. Jeder Ordner in www\ erhält automatisch eine lokale URL.'; cs='Dvojklikem otevřete projekt. Každá složka ve www\ automaticky získá místní URL.'; hi='प्रोजेक्ट को डबल-क्लिक करें खोलने के लिए।' }
    ServicesHint     = @{ fr='Les services de base tournent toujours. Activez Mailpit, Redis ou Memcached dans Paramètres.'; de='Kerndienste laufen immer. Mailpit, Redis oder Memcached in den Einstellungen aktivieren.'; cs='Základní služby jsou vždy spuštěny. Mailpit, Redis nebo Memcached povolte v nastavení.'; hi='कोर सेवाएँ हमेशा चलती हैं।' }
    AutoStartInfo    = @{ fr='WampDeck démarrera avec Windows (dans la zone de notification).'; de='WampDeck startet mit Windows (im Benachrichtigungsbereich).'; cs='WampDeck se spustí s Windows (v oznamovací oblasti).'; hi='WampDeck Windows के साथ शुरू होगा।' }
    AutoStartOffInfo = @{ fr='WampDeck ne démarrera plus avec Windows.'; de='WampDeck startet nicht mehr mit Windows.'; cs='WampDeck se už nebude spouštět s Windows.'; hi='WampDeck अब Windows के साथ शुरू होगा नहीं।' }
    EnablingHttps    = @{ fr='Activation de HTTPS...'; de='HTTPS wird aktiviert...'; cs='Povolování HTTPS...'; hi='HTTPS चालू हो रहा है...' }
    DisablingHttps   = @{ fr='Désactivation de HTTPS...'; de='HTTPS wird deaktiviert...'; cs='Zakazování HTTPS...'; hi='HTTPS बंद हो रहा है...' }
    WaitingForTrust  = @{ fr='En attente de la confirmation Windows...'; de='Warte auf Windows-Bestätigung...'; cs='Čekání na potvrzení Windows...'; hi='Windows confirmation इंतज़ार कर रहा है...' }
    RegeneratingCert = @{ fr='Régénération des certificats...'; de='Zertifikate werden neu erzeugt...'; cs='Obnovování certifikátů...'; hi='सर्टिफिकेट दोबारा बन रहे हैं...' }
    ServiceStart     = @{ fr='Démarrer'; de='Start'; cs='Spustit'; hi='शुरू करें' }
    ServiceStop      = @{ fr='Arrêter'; de='Stopp'; cs='Zastavit'; hi='रोकें' }
    ServiceStartAll  = @{ fr='Tout démarrer'; de='Alle starten'; cs='Spustit vše'; hi='सब शुरू करें' }
    ServiceStopAll   = @{ fr='Tout arrêter'; de='Alle stoppen'; cs='Zastavit vše'; hi='सब रोकें' }
    ServiceToggleStartup = @{ fr='Basculer le démarrage'; de='Autostart umschalten'; cs='Přepnout automatické spuštění'; hi='शुरुआत टॉगल करें' }
    ServiceAlways    = @{ fr='toujours'; de='immer'; cs='vždy'; hi='हमेशा' }
    ServiceOff       = @{ fr='désactivé'; de='aus'; cs='vypnuto'; hi='बंद' }
    TabProjects     = @{ fr='Projets'; de='Projekte'; cs='Projekty'; hi='प्रोजेक्ट' }
    TabServices     = @{ fr='Services'; de='Dienste'; cs='Služby'; hi='सेवाएँ' }
    TabTools        = @{ fr='Outils'; de='Werkzeuge'; cs='Nástroje'; hi='उपकरण' }
    TabNewProject   = @{ fr='Nouveau projet'; de='Neues Projekt'; cs='Nový projekt'; hi='नया प्रोजेक्ट' }
    TabOpen         = @{ fr='Ouvrir'; de='Öffnen'; cs='Otevřít'; hi='खोलें' }
    TabTestUrl      = @{ fr='URL .test'; de='.test-URL'; cs='.test URL' }
    TabFolder       = @{ fr='Dossier'; de='Ordner'; cs='Složka'; hi='फ़ोल्डर' }
    TabCopyUrl      = @{ fr='Copier URL'; de='URL kopieren'; cs='Kopírovat URL'; hi='URL कॉपी करें' }
    TabDelete       = @{ fr='Supprimer'; de='Löschen'; cs='Odstranit'; hi='हटाएँ' }
    TabRefresh      = @{ fr='Actualiser'; de='Aktualisieren'; cs='Obnovit'; hi='रिफ्रेश' }
    TabTerminal     = @{ fr='Terminal'; de='Terminal'; cs='Terminál'; hi='टर्मिनल' }
    ProjectCount    = @{ fr='{0} projet'; de='{0} Projekt'; cs='{0} projekt'; hi='{0} प्रोजेक्ट' }
    ProjectCountPlural = @{ fr='{0} projets'; de='{0} Projekte'; cs='{0} projektů'; hi='{0} प्रोजेक्ट' }
    TrayBalloon      = @{ fr='Toujours actif dans la zone de notification.'; de='Läuft weiter im Benachrichtigungsbereich.'; cs='Stále běží v oznamovací oblasti.'; hi='अभी notification area में चल रहा है।' }
    ColumnProject   = @{ fr='Projet'; de='Projekt'; cs='Projekt' }
    ColumnPhp       = @{ fr='PHP'; de='PHP'; cs='PHP' }
    ColumnLocalUrl  = @{ fr='URL locale'; de='Lokale URL'; cs='Místní URL' }
    ColumnTestUrl   = @{ fr='URL .test'; de='.test-URL'; cs='.test URL' }
    ColumnFolder    = @{ fr='Dossier'; de='Ordner'; cs='Složka' }
    ServiceCount    = @{ fr='{0} service'; de='{0} Dienst'; cs='{0} služba' }
    ServiceCountPl  = @{ fr='{0} services'; de='{0} Dienste'; cs='{0} služby' }
    FrontendTitle   = @{ fr='Frameworks PHP - installation en un clic'; de='PHP-Frameworks - Installation mit einem Klick'; cs='PHP frameworky - instalace jedním klikem' }
    InstallLabel    = @{ fr='Installer'; de='Installieren'; cs='Instalovat' }
    FolderLabel     = @{ fr='Nom du dossier du projet'; de='Projektordnername'; cs='Název složky projektu' }
    FrameworkHint2  = @{ fr='Installation des frameworks PHP en un clic - gratuit dans WampDeck.'; de='PHP-Frameworks mit einem Klick - kostenlos in WampDeck.'; cs='Instalace PHP frameworků jedním klikem - zdarma ve WampDeck.' }
    DatabaseClient  = @{ fr='Client de base de données'; de='Datenbankclient'; cs='Databázový klient' }
    CapturedMail    = @{ fr='Courrier capturé'; de='Abgefangene Mails'; cs='Zachycená pošta' }
    WebDatabase     = @{ fr='Base de données web'; de='Web-Datenbank'; cs='Webová databáze' }
    PhpSettings     = @{ fr='Paramètres PHP'; de='PHP-Einstellungen'; cs='Nastavení PHP' }
    TextEditor      = @{ fr='Éditeur de texte'; de='Texteditor'; cs='Textový editor' }
    VersionCheck    = @{ fr='Vérification de version'; de='Versionsprüfung'; cs='Kontrola verze' }
    CronScheduler   = @{ fr='Planificateur de tâches'; de='Aufgabenplaner'; cs='Plánovač úloh' }
    CloseTunnel     = @{ fr='Fermer le tunnel'; de='Tunnel schließen'; cs='Zavřít tunel' }
    HostsFile       = @{ fr='Fichier hosts'; de='hosts-Datei'; cs='Soubor hosts' }
    EditUac         = @{ fr='Modifier avec UAC'; de='Mit UAC bearbeiten'; cs='Upravit s UAC' }
    SslFiles        = @{ fr='Fichiers SSL'; de='SSL-Dateien'; cs='Soubory SSL' }
    RebuildVhosts   = @{ fr='Recréer les hôtes virtuels'; de='VHosts neu erstellen'; cs='Znovu vytvořit virtuální hosty' }
    Versions        = @{ fr='Versions'; de='Versionen'; cs='Verze' }
    TabPhpFramework = @{ fr='Frameworks PHP'; de='PHP-Frameworks'; cs='PHP frameworky' }
    Install         = @{ fr='Installer'; de='Installieren'; cs='Instalovat' }
    FrameworkHint   = @{ fr='Installation de frameworks PHP en un clic - gratuit dans WampDeck.'; de='PHP-Frameworks mit einem Klick - kostenlos in WampDeck.'; cs='Instalace PHP frameworků jedním klikem - zdarma ve WampDeck.' }
    ProjectFolderName = @{ fr='Nom du dossier du projet'; de='Projektordnername'; cs='Název složky projektu' }
    FirstRunTitle   = @{ fr='Bienvenue dans WampDeck - choisissez votre langue'; de='Willkommen bei WampDeck - Sprache wählen'; cs='Vítejte ve WampDeck - vyberte jazyk' }
    FirstRunHint    = @{ fr='Choisissez la langue de l interface WampDeck.'; de='Wählen Sie die Sprache der WampDeck-Oberfläche.'; cs='Vyberte jazyk rozhraní WampDeck.' }
    FirstRunRtlNote = @{ fr='L arabe utilise une disposition de droite à gauche. Définie une fois à l installation, elle ne change pas quand vous changez de langue dans Paramètres.'; de='Arabisch verwendet Rechts-nach-Links-Layout. Es wird einmal bei der Installation festgelegt und ändert sich nicht beim Sprachwechsel in den Einstellungen.'; cs='Arabština používá rozvržení zprava doleva. Nastavuje se jednou při instalaci a při změně jazyka v nastavení se nemění.' }
    ProTitle        = @{ fr='WampDeck Pro - Boîte à outils développeur pour agences'; de='WampDeck Pro - Entwickler-Toolkit für Agenturen'; cs='WampDeck Pro - Vývojářská sada pro agentury' }
    ProHealth       = @{ fr='Tableau de bord santé'; de='Health-Dashboard'; cs='Panel stavu' }
    ProBackups      = @{ fr='Sauvegardes et planification'; de='Backups und Zeitplan'; cs='Zálohy a plánování' }
    ProXdebug       = @{ fr='Bascule Xdebug'; de='Xdebug umschalten'; cs='Přepnout Xdebug' }
    ProGit          = @{ fr='Outils Git'; de='Git-Werkzeuge'; cs='Git nástroje' }
    ProMailpit      = @{ fr='Mailpit Pro'; de='Mailpit Pro'; cs='Mailpit Pro' }
    ProMore         = @{ fr='Modules complémentaires, coffre et équipe'; de='Add-ons, Tresor und Team'; cs='Doplňky, trezor a tým' }
    ProInstallSelected = @{ fr='Installer la sélection...'; de='Auswahl installieren...'; cs='Instalovat vybrané...' }
    Cancel          = @{ fr='Annuler'; de='Abbrechen'; cs='Zrušit' }
    ProBadge        = @{ fr='PRO'; de='PRO'; cs='PRO' }
    CheckingShort   = @{ fr='VÉRIF.'; de='PRÜFE'; cs='KONTROLA' }
}
foreach ($key in $script:Phase2Strings.Keys) {
    if (-not $script:UiStrings.ContainsKey($key)) { $script:UiStrings[$key] = @{} }
    foreach ($lang in $script:Phase2Strings[$key].Keys) { $script:UiStrings[$key][$lang] = $script:Phase2Strings[$key][$lang] }
}
$script:ExtraUiStrings4 = @{
    ProBadge      = @{ en='PRO'; ur='PRO'; ar='PRO'; 'zh-CN'='PRO'; fr='PRO'; de='PRO'; cs='PRO' }
    CheckingShort = @{ en='CHECKING'; ur='چیک'; ar='فحص'; 'zh-CN'='检查中'; fr='VÉRIF.'; de='PRÜFE'; cs='KONTROLA' }
}
foreach ($key in $script:ExtraUiStrings4.Keys) {
    if (-not $script:UiStrings.ContainsKey($key)) { $script:UiStrings[$key] = @{} }
    foreach ($lang in $script:ExtraUiStrings4[$key].Keys) { $script:UiStrings[$key][$lang] = $script:ExtraUiStrings4[$key][$lang] }
}
$script:CompleteLanguages = @(
    @{ Code = 'en';    Name = 'English' }
    @{ Code = 'hi';    Name = 'हिन्दी (Hindi)' }
    @{ Code = 'ur';    Name = 'اردو (Urdu)' }
    @{ Code = 'ar';    Name = 'العربية (Arabic)' }
    @{ Code = 'zh-CN'; Name = '简体中文 (Chinese)' }
    @{ Code = 'fr';    Name = 'Français (French)' }
    @{ Code = 'de';    Name = 'Deutsch (German)' }
    @{ Code = 'cs';    Name = 'Čeština (Czech)' }
)
