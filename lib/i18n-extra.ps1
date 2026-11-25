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

$script:Phase1Strings = @{    AppTitle = @{ es='WampDeck'; ru='WampDeck'; ja='WampDeck'; ko='WampDeck'; pt='WampDeck'; it='WampDeck'; tr='WampDeck'; nl='WampDeck'; pl='WampDeck' }
    AppSubtitle = @{ es='Pila de desarrollo PHP portátil'; ru='Портативная среда разработки PHP'; ja='ポータブルPHP開発環境'; ko='휴대용 PHP 개발 환경'; pt='Pilha de desenvolvimento PHP portátil'; it='Pila di sviluppo PHP portabile'; tr='Taşınabilir PHP geliştirme yığını'; nl='Draagbare PHP-ontwikkelomgeving'; pl='Přenosné PHP vývojové prostředí' }
    Stack = @{ es='Pila'; ru='Среда'; ja='環境'; ko='환경'; pt='Pilha'; it='Pila'; tr='Yığın'; nl='Stapel'; pl='Prostředí' }
    Project = @{ es='Proyecto'; ru='Проект'; ja='プロジェクト'; ko='프로젝트'; pt='Projeto'; it='Progetto'; tr='Proje'; nl='Project'; pl='Projekt' }
    Services = @{ es='Servicios'; ru='Службы'; ja='サービス'; ko='서비스'; pt='Serviços'; it='Servizi'; tr='Servisler'; nl='Dienste'; pl='Služby' }
    Tools = @{ es='Herramientas'; ru='Инструменты'; ja='ツール'; ko='도구'; pt='Ferramentas'; it='Strumenti'; tr='Araçlar'; nl='Werkzeuge'; pl='Nástroje' }
    Settings = @{ es='Configuración'; ru='Настройки'; ja='設定'; ko='설정'; pt='Configurações'; it='Impostazioni'; tr='Ayarlar'; nl='Instellingen'; pl='Nastavení' }
    Help = @{ es='Ayuda'; ru='Справка'; ja='ヘルプ'; ko='도움말'; pt='Ajuda'; it='Aiuto'; tr='Yardım'; nl='Hulp'; pl='Nápověda' }
    Language = @{ es='Idioma'; ru='Язык'; ja='言語'; ko='언어'; pt='Idioma'; it='Lingua'; tr='Dil'; nl='Taal'; pl='Jazyk' }
    Start = @{ es='Iniciar'; ru='Пуск'; ja='開始'; ko='시작'; pt='Iniciar'; it='Avvia'; tr='Başlat'; nl='Start'; pl='Spustit' }
    Stop = @{ es='Detener'; ru='Стоп'; ja='停止'; ko='중지'; pt='Parar'; it='Ferma'; tr='Durdur'; nl='Stopp'; pl='Zastavit' }
    Restart = @{ es='Reiniciar'; ru='Перезапуск'; ja='再起動'; ko='다시 시작'; pt='Reiniciar'; it='Riavvia'; tr='Yeniden başlat'; nl='Herstart'; pl='Restartovat' }
    Terminal = @{ es='>_  Terminal'; ru='>_  Терминал'; ja='>_  ターミナル'; ko='>_  터미널'; pt='>_  Terminal'; it='>_  Terminale'; tr='>_  Terminal'; nl='>_  Terminal'; pl='>_  Terminál' }
    TerminalHint = @{ es='Abrir una terminal en www con PHP, Composer, Git, Node y MySQL listos'; ru='Открыть терминал в www: PHP, Composer, Git, Node и MySQL готовы'; ja='wwwでターミナルを開きます。PHP、Composer、Git、Node、MySQLが利用可能です'; ko='www에서 터미널 열기 - PHP, Composer, Git, Node, MySQL 준비 완료'; pt='Abrir terminal em www com PHP, Composer, Git, Node e MySQL prontos'; it='Apri un terminale in www con PHP, Composer, Git, Node e MySQL pronti'; tr='www içinde terminal aç - PHP, Composer, Git, Node ve MySQL hazır'; nl='Terminal openen in www met PHP, Composer, Git, Node en MySQL klaar'; pl='Otevřít terminál ve www s PHP, Composer, Git, Node a MySQL' }
    StartStack = @{ es='Iniciar pila'; ru='Запустить среду'; ja='環境を起動'; ko='환경 시작'; pt='Iniciar pilha'; it='Avvia pila'; tr='Yığını başlat'; nl='Stapel starten'; pl='Spustit prostředí' }
    StopStack = @{ es='Detener pila'; ru='Остановить среду'; ja='環境を停止'; ko='환경 중지'; pt='Parar pilha'; it='Ferma pila'; tr='Yığını durdur'; nl='Stapel stoppen'; pl='Zastavit prostředí' }
    RestartStack = @{ es='Reiniciar pila'; ru='Перезапустить среду'; ja='環境を再起動'; ko='환경 다시 시작'; pt='Reiniciar pilha'; it='Riavvia pila'; tr='Yığını yeniden başlat'; nl='Stapel herstarten'; pl='Restartovat prostředí' }
    OpenPanelInBrowser = @{ es='Abrir panel en el navegador'; ru='Открыть панель в браузере'; ja='ブラウザでパネルを開く'; ko='브라우저에서 패널 열기'; pt='Abrir painel no navegador'; it='Apri il pannello nel browser'; tr='Paneli tarayıcıda aç'; nl='Panel openen in browser'; pl='Otevřít panel v prohlížeči' }
    OpenWwwFolder = @{ es='Abrir carpeta www'; ru='Открыть папку www'; ja='wwwフォルダーを開く'; ko='www 폴더 열기'; pt='Abrir pasta www'; it='Apri cartella www'; tr='www klasörünü aç'; nl='www-map openen'; pl='Otevřít složku www' }
    OpenLogsFolder = @{ es='Abrir carpeta de logs'; ru='Открыть папку логов'; ja='ログフォルダーを開く'; ko='로그 폴더 열기'; pt='Abrir pasta de logs'; it='Apri cartella log'; tr='Log klasörünü aç'; nl='Logmap openen'; pl='Otevřít složku logů' }
    TerminalInWww = @{ es='Terminal en www'; ru='Терминал в www'; ja='wwwのターミナル'; ko='www 터미널'; pt='Terminal em www'; it='Terminale in www'; tr='www terminali'; nl='Terminal in www'; pl='Terminál ve www' }
    Quit = @{ es='Salir'; ru='Выход'; ja='終了'; ko='종료'; pt='Sair'; it='Esci'; tr='Çık'; nl='Afsluiten'; pl='Ukončit' }
    NewProject = @{ es='Nuevo proyecto...'; ru='Новый проект...'; ja='新しいプロジェクト...'; ko='새 프로젝트...'; pt='Novo projeto...'; it='Nuovo progetto...'; tr='Yeni proje...'; nl='Nieuw project...'; pl='Nový projekt...' }
    OpenInBrowser = @{ es='Abrir en el navegador'; ru='Открыть в браузере'; ja='ブラウザで開く'; ko='브라우저에서 열기'; pt='Abrir no navegador'; it='Apri nel browser'; tr='Tarayıcıda aç'; nl='Openen in browser'; pl='Otevřít v prohlížeči' }
    OpenTestUrl = @{ es='Abrir URL .test'; ru='Открыть .test URL'; ja='.test URLを開く'; ko='.test URL 열기'; pt='Abrir URL .test'; it='Apri URL .test'; tr='.test URL aç'; nl='.test-URL openen'; pl='Otevřít .test URL' }
    OpenFolder = @{ es='Abrir carpeta'; ru='Открыть папку'; ja='フォルダーを開く'; ko='폴더 열기'; pt='Abrir pasta'; it='Apri cartella'; tr='Klasörü aç'; nl='Map openen'; pl='Otevřít složku' }
    OpenTerminalHere = @{ es='Abrir terminal aquí'; ru='Открыть терминал здесь'; ja='ここでターミナルを開く'; ko='여기서 터미널 열기'; pt='Abrir terminal aqui'; it='Apri terminale qui'; tr='Burada terminal aç'; nl='Hier terminal openen'; pl='Otevřít terminál zde' }
    CopyLocalUrl = @{ es='Copiar URL local'; ru='Копировать локальный URL'; ja='ローカルURLをコピー'; ko='로컬 URL 복사'; pt='Copiar URL local'; it='Copia URL locale'; tr='Yerel URL kopyala'; nl='Lokale URL kopiëren'; pl='Kopírovat místní URL' }
    DeleteProject = @{ es='Eliminar proyecto...'; ru='Удалить проект...'; ja='プロジェクトを削除...'; ko='프로젝트 삭제...'; pt='Excluir projeto...'; it='Elimina progetto...'; tr='Projeyi sil...'; nl='Project verwijderen...'; pl='Odstranit projekt...' }
    RefreshProjects = @{ es='Actualizar lista de proyectos'; ru='Обновить список проектов'; ja='プロジェクト一覧を更新'; ko='프로젝트 목록 새로고침'; pt='Atualizar lista de projetos'; it='Aggiorna elenco progetti'; tr='Proje listesini yenile'; nl='Projectlijst vernieuwen'; pl='Obnovit seznam projektů' }
    ProjectPhpVersion = @{ es='Versión de PHP'; ru='Версия PHP'; ja='PHPバージョン'; ko='PHP 버전'; pt='Versão do PHP'; it='Versione PHP'; tr='PHP sürümü'; nl='PHP-versie'; pl='Verze PHP' }
    ProjectPhpDefault = @{ es='Predeterminado de la pila ({0})'; ru='По умолчанию среды ({0})'; ja='環境のデフォルト ({0})'; ko='환경 기본값 ({0})'; pt='Padrão da pilha ({0})'; it='Predefinito della pila ({0})'; tr='Yığın varsayılanı ({0})'; nl='Standaard van de stapel ({0})'; pl='Výchozí prostředí ({0})' }
    ProjectPhpChanged = @{ es='{0} ahora usa PHP {1}.'; ru='{0} теперь использует PHP {1}.'; ja='{0}はPHP {1}を使用します。'; ko='{0}이(가) 이제 PHP {1}을(를) 사용합니다.'; pt='{0} agora usa PHP {1}.'; it='{0} usa ora PHP {1}.'; tr='{0} artık PHP {1} kullanıyor.'; nl='{0} gebruikt nu PHP {1}.'; pl='{0} nyní běží na PHP {1}.' }
    ProjectPhpColumn = @{ es='PHP'; ru='PHP'; ja='PHP'; ko='PHP'; pt='PHP'; it='PHP'; tr='PHP'; nl='PHP'; pl='PHP' }
    HeidiSql = @{ es='HeidiSQL'; ru='HeidiSQL'; ja='HeidiSQL'; ko='HeidiSQL'; pt='HeidiSQL'; it='HeidiSQL'; tr='HeidiSQL'; nl='HeidiSQL'; pl='HeidiSQL' }
    MailpitInbox = @{ es='Mailpit (bandeja web)'; ru='Mailpit (веб-почта)'; ja='Mailpit (Webメール)'; ko='Mailpit (웹 메일)'; pt='Mailpit (caixa web)'; it='Mailpit (posta web)'; tr='Mailpit (web postası)'; nl='Mailpit (web inbox)'; pl='Mailpit (webová schránka)' }
    Adminer = @{ es='Adminer'; ru='Adminer'; ja='Adminer'; ko='Adminer'; pt='Adminer'; it='Adminer'; tr='Adminer'; nl='Adminer'; pl='Adminer' }
    Phpinfo = @{ es='phpinfo()'; ru='phpinfo()'; ja='phpinfo()'; ko='phpinfo()'; pt='phpinfo()'; it='phpinfo()'; tr='phpinfo()'; nl='phpinfo()'; pl='phpinfo()' }
    Notepad = @{ es='Notepad++'; ru='Notepad++'; ja='Notepad++'; ko='Notepad++'; pt='Notepad++'; it='Notepad++'; tr='Notepad++'; nl='Notepad++'; pl='Notepad++' }
    NgrokStart = @{ es='Iniciar túnel ngrok'; ru='Запустить туннель ngrok'; ja='ngrokトンネルを起動'; ko='ngrok 터널 시작'; pt='Iniciar túnel ngrok'; it='Avvia tunnel ngrok'; tr='ngrok tünelini başlat'; nl='ngrok-tunnel starten'; pl='Spustit ngrok tunel' }
    NgrokStop = @{ es='Detener ngrok'; ru='Остановить ngrok'; ja='ngrokを停止'; ko='ngrok 중지'; pt='Parar ngrok'; it='Ferma ngrok'; tr='ngrok''u durdur'; nl='ngrok stoppen'; pl='Zastavit ngrok' }
    NgrokNoToken = @{ es='ngrok iniciado, pero aún no hay URL pública. Añade primero tu authtoken.'; ru='ngrok запущен, но публичного URL пока нет. Сначала добавьте authtoken.'; ja='ngrokが起動しましたが、公開URLがありません。先にauthtokenを追加してください。'; ko='ngrok가 시작되었지만 공개 URL이 없습니다. 먼저 authtoken을 추가하세요.'; pt='ngrok iniciado, mas ainda sem URL pública. Adicione o authtoken primeiro.'; it='ngrok avviato, ma nessun URL pubblico. Aggiungi prima l''authtoken.'; tr='ngrok başlatıldı ama henüz genel URL yok. Önce authtoken ekleyin.'; nl='ngrok gestartet maar nog geen publieke URL. Voeg eerst authtoken toe.'; pl='ngrok spuštěn, ale zatím bez veřejné URL. Nejprve přidejte authtoken.' }
    HostsChecking = @{ es='hosts: comprobando'; ru='hosts: проверка'; ja='hosts: 確認中'; ko='hosts: 확인 중'; pt='hosts: verificando'; it='hosts: verifica'; tr='hosts: kontrol ediliyor'; nl='hosts: controleren'; pl='hosts: kontrola' }
    HostsSyncing = @{ es='Sincronizando el archivo hosts...'; ru='Синхронизация файла hosts...'; ja='hostsファイルを同期中...'; ko='hosts 파일 동기화 중...'; pt='Sincronizando o arquivo hosts...'; it='Sincronizzazione del file hosts...'; tr='hosts dosyası eşitleniyor...'; nl='hosts-bestand synchroniseren...'; pl='Synchronizace souboru hosts...' }
    HostsOpening = @{ es='Abriendo el archivo hosts...'; ru='Открытие файла hosts...'; ja='hostsファイルを開いています...'; ko='hosts 파일 여는 중...'; pt='Abrindo o arquivo hosts...'; it='Apertura del file hosts...'; tr='hosts dosyası açılıyor...'; nl='hosts-bestand openen...'; pl='Otevírání souboru hosts...' }
    Cronical = @{ es='Planificador Cronical'; ru='Планировщик Cronical'; ja='Cronicalスケジューラ'; ko='Cronical 스케줄러'; pt='Agendador Cronical'; it='Utilità Cronical'; tr='Cronical zamanlayıcı'; nl='Cronical-planner'; pl='Plánovač Cronical' }
    SyncHosts = @{ es='Sincronizar hosts (UAC)'; ru='Синхронизировать hosts (UAC)'; ja='hostsを同期 (UAC)'; ko='hosts 동기화 (UAC)'; pt='Sincronizar hosts (UAC)'; it='Sincronizza hosts (UAC)'; tr='hosts eşitle (UAC)'; nl='hosts synchroniseren (UAC)'; pl='Synchronizovat hosts (UAC)' }
    EditHosts = @{ es='Editar hosts (UAC)'; ru='Редактировать hosts (UAC)'; ja='hostsを編集 (UAC)'; ko='hosts 편집 (UAC)'; pt='Editar hosts (UAC)'; it='Modifica hosts (UAC)'; tr='hosts düzenle (UAC)'; nl='hosts bewerken (UAC)'; pl='Upravit hosts (UAC)' }
    CertificatesFolder = @{ es='Carpeta de certificados'; ru='Папка сертификатов'; ja='証明書フォルダー'; ko='인증서 폴더'; pt='Pasta de certificados'; it='Cartella certificati'; tr='Sertifika klasörü'; nl='Certificatenmap'; pl='Složka certifikátů' }
    PhpExtensions = @{ es='Extensiones PHP...'; ru='Расширения PHP...'; ja='PHP拡張機能...'; ko='PHP 확장...'; pt='Extensões PHP...'; it='Estensioni PHP...'; tr='PHP uzantıları...'; nl='PHP-extensies...'; pl='PHP rozšíření...' }
    StartStackWhenPanelOpens = @{ es='Iniciar pila al abrir el panel'; ru='Запускать среду при открытии панели'; ja='パネルを開くときに環境を起動'; ko='패널을 열 때 환경 시작'; pt='Iniciar pilha ao abrir o painel'; it='Avvia pila all''apertura del pannello'; tr='Panel açılırken yığını başlat'; nl='Stapel starten bij openen panel'; pl='Spustit prostředí při otevření panelu' }
    StartWithWindows = @{ es='Iniciar con Windows'; ru='Запускать с Windows'; ja='Windowsと共に起動'; ko='Windows와 함께 시작'; pt='Iniciar com Windows'; it='Avvia con Windows'; tr='Windows ile başlat'; nl='Starten met Windows'; pl='Spustit s Windows' }
    RefreshConfigs = @{ es='Actualizar configuración'; ru='Обновить конфигурацию'; ja='設定を更新'; ko='구성 새로고침'; pt='Atualizar configuração'; it='Aggiorna configurazione'; tr='Yapılandırmayı yenile'; nl='Configuratie vernieuwen'; pl='Obnovit konfiguraci' }
    About = @{ es='Acerca de WampDeck'; ru='О WampDeck'; ja='WampDeckについて'; ko='WampDeck 정보'; pt='Sobre o WampDeck'; it='Informazioni su WampDeck'; tr='WampDeck hakkında'; nl='Over WampDeck'; pl='O WampDeck' }
    Readme = @{ es='README'; ru='README'; ja='README'; ko='README'; pt='README'; it='README'; tr='README'; nl='README'; pl='README' }
    OpenInstallFolder = @{ es='Abrir carpeta de instalación'; ru='Открыть папку установки'; ja='インストールフォルダーを開く'; ko='설치 폴더 열기'; pt='Abrir pasta de instalação'; it='Apri cartella di installazione'; tr='Kurulum klasörünü aç'; nl='Installatiemap openen'; pl='Otevřít instalační složku' }
    EnableHttps = @{ es='Activar HTTPS'; ru='Включить HTTPS'; ja='HTTPSを有効化'; ko='HTTPS 활성화'; pt='Ativar HTTPS'; it='Attiva HTTPS'; tr='HTTPS''i etkinleştir'; nl='HTTPS inschakelen'; pl='Povolit HTTPS' }
    DisableHttps = @{ es='Desactivar HTTPS'; ru='Отключить HTTPS'; ja='HTTPSを無効化'; ko='HTTPS 비활성화'; pt='Desativar HTTPS'; it='Disattiva HTTPS'; tr='HTTPS''yi devre dışı bırak'; nl='HTTPS uitschakelen'; pl='Zakázat HTTPS' }
    TrustCert = @{ es='Confiar en el certificado (diálogo de Windows)'; ru='Доверять сертификату (диалог Windows)'; ja='証明書を信頼する (Windowsダイアログ)'; ko='인증서 신뢰 (Windows 대화상자)'; pt='Confiar no certificado (diálogo do Windows)'; it='Considera attendibile il certificato (finestra Windows)'; tr='Sertifikata güven (Windows penceresi)'; nl='Certificaat vertrouwen (Windows-dialoog)'; pl='Důvěryhodný certifikát (dialog Windows)' }
    RegenerateCert = @{ es='Regenerar certificado'; ru='Пересоздать сертификат'; ja='証明書を再生成'; ko='인증서 다시 생성'; pt='Regenerar certificado'; it='Rigenera certificato'; tr='Sertifikayı yeniden oluştur'; nl='Certificaat opnieuw genereren'; pl='Znovu vygenerovat certifikát' }
    Php = @{ es='PHP'; ru='PHP'; ja='PHP'; ko='PHP'; pt='PHP'; it='PHP'; tr='PHP'; nl='PHP'; pl='PHP' }
    WebServer = @{ es='Servidor web'; ru='Веб-сервер'; ja='Webサーバー'; ko='웹 서버'; pt='Servidor web'; it='Server web'; tr='Web sunucusu'; nl='Webserver'; pl='Webový server' }
    Database = @{ es='Base de datos'; ru='База данных'; ja='データベース'; ko='데이터베이스'; pt='Banco de dados'; it='Database'; tr='Veritabanı'; nl='Database'; pl='Databáze' }
    ExtraServices = @{ es='Servicios adicionales'; ru='Дополнительные службы'; ja='追加サービス'; ko='추가 서비스'; pt='Serviços adicionais'; it='Servizi aggiuntivi'; tr='Ek hizmetler'; nl='Extra dienste'; pl='Další služby' }
    MySql = @{ es='MySQL'; ru='MySQL'; ja='MySQL'; ko='MySQL'; pt='MySQL'; it='MySQL'; tr='MySQL'; nl='MySQL'; pl='MySQL' }
    Running = @{ es='en ejecución'; ru='работает'; ja='実行中'; ko='실행 중'; pt='em execução'; it='in esecuzione'; tr='çalışıyor'; nl='actief'; pl='spusteno' }
    Stopped = @{ es='detenido'; ru='остановлено'; ja='停止'; ko='중지'; pt='parado'; it='fermo'; tr='durduruldu'; nl='gestopt'; pl='zastaveno' }
    Starting = @{ es='iniciando...'; ru='запуск...'; ja='起動中...'; ko='시작 중...'; pt='iniciando...'; it='avvio...'; tr='başlatılıyor...'; nl='starten...'; pl='spouští se...' }
    Stopping = @{ es='deteniendo...'; ru='остановка...'; ja='停止中...'; ko='중지 중...'; pt='parando...'; it='arresto...'; tr='durduruluyor...'; nl='stoppen...'; pl='zastavuje se...' }
    StartingService = @{ es='Iniciando servicio...'; ru='Запуск службы...'; ja='サービスを起動中...'; ko='서비스 시작 중...'; pt='Iniciando serviço...'; it='Avvio servizio...'; tr='Servis başlatılıyor...'; nl='Dienst starten...'; pl='Spouštění služby...' }
    StoppingService = @{ es='Deteniendo servicio...'; ru='Остановка службы...'; ja='サービスを停止中...'; ko='서비스 중지 중...'; pt='Parando serviço...'; it='Arresto servizio...'; tr='Servis durduruluyor...'; nl='Dienst stoppen...'; pl='Zastavování služby...' }
    Ready = @{ es='Listo'; ru='Готово'; ja='準備完了'; ko='준비됨'; pt='Pronto'; it='Pronto'; tr='Hazır'; nl='Klaar'; pl='Připraveno' }
    StartingTheStack = @{ es='Iniciando la pila...'; ru='Запуск среды...'; ja='環境を起動中...'; ko='환경 시작 중...'; pt='Iniciando a pilha...'; it='Avvio della pila...'; tr='Yığın başlatılıyor...'; nl='Stapel starten...'; pl='Spouštění prostředí...' }
    StoppingTheStack = @{ es='Deteniendo la pila...'; ru='Остановка среды...'; ja='環境を停止中...'; ko='환경 중지 중...'; pt='Parando a pilha...'; it='Arresto della pila...'; tr='Yığın durduruluyor...'; nl='Stapel stoppen...'; pl='Zastavování prostředí...' }
    RestartingTheStack = @{ es='Reiniciando la pila...'; ru='Перезапуск среды...'; ja='環境を再起動中...'; ko='환경 다시 시작 중...'; pt='Reiniciando a pilha...'; it='Riavvio della pila...'; tr='Yığın yeniden başlatılıyor...'; nl='Stapel herstarten...'; pl='Restartování prostředí...' }
    AnotherTaskRunning = @{ es='Otra tarea de WampDeck aún está en ejecución. Espere a que termine.'; ru='Другая задача WampDeck ещё выполняется. Подождите.'; ja='別のWampDeckタスクが実行中です。完了までお待ちください。'; ko='다른 WampDeck 작업이 실행 중입니다. 완료될 때까지 기다리세요.'; pt='Outra tarefa do WampDeck ainda está em execução. Aguarde.'; it='Un''altra attività di WampDeck è ancora in corso. Attendere.'; tr='Başka bir WampDeck görevi hâlâ çalışıyor. Lütfen bekleyin.'; nl='Een andere WampDeck-taak draait nog. Wacht alstublieft.'; pl='Další úloha WampDeck stále běží. Počkejte prosím.' }
    TaskFailed = @{ es='Tarea de WampDeck fallida (exit {0}).'; ru='Задача WampDeck завершилась ошибкой (exit {0}).'; ja='WampDeckタスクが失敗しました (exit {0})。'; ko='WampDeck 작업 실패 (exit {0}).'; pt='Tarefa do WampDeck falhou (exit {0}).'; it='Attività WampDeck non riuscita (exit {0}).'; tr='WampDeck görevi başarısız (exit {0}).'; nl='WampDeck-taak mislukt (exit {0}).'; pl='Úloha WampDeck selhala (exit {0}).' }
    CheckStatus = @{ es='COMPROBANDO'; ru='ПРОВЕРКА'; ja='確認中'; ko='확인 중'; pt='VERIFICANDO'; it='VERIFICA'; tr='KONTROL'; nl='CONTROLEREN'; pl='KONTROLA' }
    SslChecking = @{ es='ssl: comprobando'; ru='ssl: проверка'; ja='ssl: 確認中'; ko='ssl: 확인 중'; pt='ssl: verificando'; it='ssl: verifica'; tr='ssl: kontrol ediliyor'; nl='ssl: controleren'; pl='ssl: kontrola' }
    SslOn = @{ es='ssl: activo, de confianza'; ru='ssl: активен, доверенный'; ja='ssl: 有効、信頼済み'; ko='ssl: 활성, 신뢰됨'; pt='ssl: ativo, confiável'; it='ssl: attivo, attendibile'; tr='ssl: etkin, güvenilir'; nl='ssl: actief, vertrouwd'; pl='ssl: zapnuto, důvěryhodné' }
    SslOnCaUntrusted = @{ es='ssl: activo, CA no fiable'; ru='ssl: активен, CA не доверен'; ja='ssl: 有効、CAが未信頼'; ko='ssl: 활성, CA 신뢰 안 됨'; pt='ssl: ativo, CA não confiável'; it='ssl: attivo, CA non attendibile'; tr='ssl: etkin, CA güvenilmez'; nl='ssl: actief, CA niet vertrouwd'; pl='ssl: zapnuto, CA nedůvěryhodná' }
    SslOff = @{ es='ssl: desactivado'; ru='ssl: выключен'; ja='ssl: 無効'; ko='ssl: 꺼짐'; pt='ssl: desativado'; it='ssl: disattivato'; tr='ssl: kapalı'; nl='ssl: uit'; pl='ssl: vypnuto' }
    Online = @{ es='EN LÍNEA'; ru='ОНЛАЙН'; ja='オンライン'; ko='온라인'; pt='ONLINE'; it='ONLINE'; tr='ÇEVRİMİÇİ'; nl='ONLINE'; pl='ONLINE' }
    Offline = @{ es='SIN LÍNEA'; ru='НЕ В СЕТИ'; ja='オフライン'; ko='오프라인'; pt='OFFLINE'; it='OFFLINE'; tr='ÇEVRİMDIŞI'; nl='OFFLINE'; pl='OFFLINE' }
    PortsBusy = @{ es='Los puertos siguen ocupados. Detén el otro programa o cambia los puertos.'; ru='Порты всё ещё заняты. Остановите другую программу или измените порты.'; ja='ポートがまだ使用中です。他のプログラムを停止するか、ポートを変更してください。'; ko='포트가 아직 사용 중입니다. 다른 프로그램을 중지하거나 포트를 변경하세요.'; pt='As portas ainda estão ocupadas. Pare o outro programa ou altere as portas.'; it='Le porte sono ancora occupate. Ferma l''altro programma o cambia le porte.'; tr='Portlar hâlâ meşgul. Diğer programı durdurun veya portları değiştirin.'; nl='Poorten zijn nog bezet. Stop het andere programma of wijzig de poorten.'; pl='Porty jsou stále obsazeny. Zastavte jiný program nebo změňte porty.' }
    WwwHint = @{ es='Haz doble clic en un proyecto para abrirlo. Cada carpeta en www\ obtiene una URL local automáticamente.'; ru='Двойной щелчок открывает проект. Каждая папка в www\ автоматически получает локальный URL.'; ja='プロジェクトをダブルクリックして開きます。www\の各フォルダーには自動的にローカルURLが割り当てられます。'; ko='프로젝트를 더블클릭해 여세요. www\의 모든 폴더는 자동으로 로컬 URL을 받습니다.'; pt='Clique duas vezes em um projeto para abri-lo. Cada pasta em www\ recebe uma URL local automaticamente.'; it='Fai doppio clic su un progetto per aprirlo. Ogni cartella in www\ ottiene automaticamente un URL locale.'; tr='Bir projeyi açmak için çift tıklayın. www\ içindeki her klasör otomatik olarak yerel URL alır.'; nl='Dubbelklik op een project om het te openen. Elke map in www\ krijgt automatisch een lokale URL.'; pl='Dvojklikem otevřete projekt. Každá složka ve www\ automaticky získá místní URL.' }
    ServicesHint = @{ es='Los servicios principales siempre se ejecutan. Activa Mailpit, Redis o Memcached en Configuración.'; ru='Основные службы всегда работают. Включите Mailpit, Redis или Memcached в настройках.'; ja='コアサービスは常に実行されます。設定でMailpit、Redis、Memcachedを有効にしてください。'; ko='핵심 서비스는 항상 실행됩니다. 설정에서 Mailpit, Redis 또는 Memcached를 활성화하세요.'; pt='Os serviços principais sempre executam. Ative Mailpit, Redis ou Memcached nas configurações.'; it='I servizi principali sono sempre attivi. Attiva Mailpit, Redis o Memcached nelle impostazioni.'; tr='Ana servisler her zaman çalışır. Ayarlardan Mailpit, Redis veya Memcached''i etkinleştirin.'; nl='Kernservices draaien altijd. Schakel Mailpit, Redis of Memcached in via Instellingen.'; pl='Základní služby jsou vždy spuštěny. Mailpit, Redis nebo Memcached povolte v nastavení.' }
    AutoStartInfo = @{ es='WampDeck se iniciará con Windows (en el área de notificación).'; ru='WampDeck будет запускаться с Windows (в области уведомлений).'; ja='WampDeckはWindowsと共に起動します（通知領域）。'; ko='WampDeck가 Windows와 함께 시작됩니다(알림 영역).'; pt='O WampDeck iniciará com o Windows (na área de notificação).'; it='WampDeck si avvierà con Windows (nell''area di notifica).'; tr='WampDeck Windows ile başlayacak (bildirim alanında).'; nl='WampDeck start met Windows (in het meldingengebied).'; pl='WampDeck se spustí s Windows (v oznamovací oblasti).' }
    AutoStartOffInfo = @{ es='WampDeck ya no se iniciará con Windows.'; ru='WampDeck больше не будет запускаться с Windows.'; ja='WampDeckはWindowsと共に起動しなくなります。'; ko='WampDeck가 더 이상 Windows와 함께 시작되지 않습니다.'; pt='O WampDeck não iniciará mais com o Windows.'; it='WampDeck non si avvierà più con Windows.'; tr='WampDeck artık Windows ile başlamayacak.'; nl='WampDeck start niet meer met Windows.'; pl='WampDeck se už nebude spouštět s Windows.' }
    EnablingHttps = @{ es='Activando HTTPS...'; ru='Включение HTTPS...'; ja='HTTPSを有効化中...'; ko='HTTPS 활성화 중...'; pt='Ativando HTTPS...'; it='Attivazione HTTPS...'; tr='HTTPS etkinleştiriliyor...'; nl='HTTPS inschakelen...'; pl='Povolování HTTPS...' }
    DisablingHttps = @{ es='Desactivando HTTPS...'; ru='Отключение HTTPS...'; ja='HTTPSを無効化中...'; ko='HTTPS 비활성화 중...'; pt='Desativando HTTPS...'; it='Disattivazione HTTPS...'; tr='HTTPS devre dışı bırakılıyor...'; nl='HTTPS uitschakelen...'; pl='Zakazování HTTPS...' }
    WaitingForTrust = @{ es='Esperando la confirmación de Windows...'; ru='Ожидание подтверждения Windows...'; ja='Windowsの確認を待っています...'; ko='Windows 확인 대기 중...'; pt='Aguardando a confirmação do Windows...'; it='In attesa della conferma di Windows...'; tr='Windows onayı bekleniyor...'; nl='Wachten op Windows-bevestiging...'; pl='Čekání na potvrzení Windows...' }
    RegeneratingCert = @{ es='Regenerando certificados...'; ru='Пересоздание сертификатов...'; ja='証明書を再生成中...'; ko='인증서 다시 생성 중...'; pt='Regenerando certificados...'; it='Rigenerazione certificati...'; tr='Sertifikalar yeniden oluşturuluyor...'; nl='Certificaten opnieuw genereren...'; pl='Obnovování certifikátů...' }
    ServiceStart = @{ es='Iniciar'; ru='Пуск'; ja='開始'; ko='시작'; pt='Iniciar'; it='Avvia'; tr='Başlat'; nl='Start'; pl='Spustit' }
    ServiceStop = @{ es='Detener'; ru='Стоп'; ja='停止'; ko='중지'; pt='Parar'; it='Ferma'; tr='Durdur'; nl='Stopp'; pl='Zastavit' }
    ServiceStartAll = @{ es='Iniciar todo'; ru='Запустить все'; ja='すべて起動'; ko='모두 시작'; pt='Iniciar tudo'; it='Avvia tutto'; tr='Tümünü başlat'; nl='Alles starten'; pl='Spustit vše' }
    ServiceStopAll = @{ es='Detener todo'; ru='Остановить все'; ja='すべて停止'; ko='모두 중지'; pt='Parar tudo'; it='Ferma tutto'; tr='Tümünü durdur'; nl='Alles stoppen'; pl='Zastavit vše' }
    ServiceToggleStartup = @{ es='Alternar inicio'; ru='Переключить автозапуск'; ja='自動起動を切り替え'; ko='자동 시작 전환'; pt='Alternar inicialização'; it='Attiva/disattiva avvio'; tr='Başlangıcı değiştir'; nl='Autostart wisselen'; pl='Přepnout automatické spuštění' }
    ServiceAlways = @{ es='siempre'; ru='всегда'; ja='常に'; ko='항상'; pt='sempre'; it='sempre'; tr='her zaman'; nl='altijd'; pl='vždy' }
    ServiceOff = @{ es='desactivado'; ru='выключено'; ja='オフ'; ko='꺼짐'; pt='desativado'; it='disattivato'; tr='kapalı'; nl='uit'; pl='vypnuto' }
    TabProjects = @{ es='Proyectos'; ru='Проекты'; ja='プロジェクト'; ko='프로젝트'; pt='Projetos'; it='Progetti'; tr='Projeler'; nl='Projecten'; pl='Projekty' }
    TabServices = @{ es='Servicios'; ru='Службы'; ja='サービス'; ko='서비스'; pt='Serviços'; it='Servizi'; tr='Servisler'; nl='Dienste'; pl='Služby' }
    TabTools = @{ es='Herramientas'; ru='Инструменты'; ja='ツール'; ko='도구'; pt='Ferramentas'; it='Strumenti'; tr='Araçlar'; nl='Werkzeuge'; pl='Nástroje' }
    TabNewProject = @{ es='Nuevo proyecto'; ru='Новый проект'; ja='新しいプロジェクト'; ko='새 프로젝트'; pt='Novo projeto'; it='Nuovo progetto'; tr='Yeni proje'; nl='Nieuw project'; pl='Nový projekt' }
    TabOpen = @{ es='Abrir'; ru='Открыть'; ja='開く'; ko='열기'; pt='Abrir'; it='Apri'; tr='Aç'; nl='Openen'; pl='Otevřít' }
    TabTestUrl = @{ es='URL .test'; ru='URL .test'; ja='.test URL'; ko='.test URL'; pt='URL .test'; it='URL .test'; tr='.test URL'; nl='.test-URL'; pl='.test URL' }
    TabFolder = @{ es='Carpeta'; ru='Папка'; ja='フォルダー'; ko='폴더'; pt='Pasta'; it='Cartella'; tr='Klasör'; nl='Map'; pl='Složka' }
    TabCopyUrl = @{ es='Copiar URL'; ru='Копировать URL'; ja='URLをコピー'; ko='URL 복사'; pt='Copiar URL'; it='Copia URL'; tr='URL kopyala'; nl='URL kopiëren'; pl='Kopírovat URL' }
    TabDelete = @{ es='Eliminar'; ru='Удалить'; ja='削除'; ko='삭제'; pt='Excluir'; it='Elimina'; tr='Sil'; nl='Verwijderen'; pl='Odstranit' }
    TabRefresh = @{ es='Actualizar'; ru='Обновить'; ja='更新'; ko='새로고침'; pt='Atualizar'; it='Aggiorna'; tr='Yenile'; nl='Vernieuwen'; pl='Obnovit' }
    TabTerminal = @{ es='Terminal'; ru='Терминал'; ja='ターミナル'; ko='터미널'; pt='Terminal'; it='Terminale'; tr='Terminal'; nl='Terminal'; pl='Terminál' }
    ProjectCount = @{ es='{0} proyecto'; ru='{0} проект'; ja='{0}件のプロジェクト'; ko='프로젝트 {0}개'; pt='{0} projeto'; it='{0} progetto'; tr='{0} proje'; nl='{0} project'; pl='{0} projekt' }
    ProjectCountPlural = @{ es='{0} proyectos'; ru='{0} проектов'; ja='{0}件のプロジェクト'; ko='프로젝트 {0}개'; pt='{0} projetos'; it='{0} progetti'; tr='{0} proje'; nl='{0} projecten'; pl='{0} projektů' }
    TrayBalloon = @{ es='Siguen ejecutándose en el área de notificación.'; ru='Продолжает работать в области уведомлений.'; ja='通知領域で引き続き実行中です。'; ko='알림 영역에서 계속 실행 중입니다.'; pt='Continua executando na área de notificação.'; it='Continua a essere eseguito nell''area di notifica.'; tr='Bildirim alanında çalışmaya devam ediyor.'; nl='Draait nog steeds in het meldingengebied.'; pl='Stále běží v oznamovací oblasti.' }
    ColumnProject = @{ es='Proyecto'; ru='Проект'; ja='プロジェクト'; ko='프로젝트'; pt='Projeto'; it='Progetto'; tr='Proje'; nl='Project'; pl='Projekt' }
    ColumnPhp = @{ es='PHP'; ru='PHP'; ja='PHP'; ko='PHP'; pt='PHP'; it='PHP'; tr='PHP'; nl='PHP'; pl='PHP' }
    ColumnLocalUrl = @{ es='URL local'; ru='Локальный URL'; ja='ローカルURL'; ko='로컬 URL'; pt='URL local'; it='URL locale'; tr='Yerel URL'; nl='Lokale URL'; pl='Místní URL' }
    ColumnTestUrl = @{ es='URL .test'; ru='URL .test'; ja='.test URL'; ko='.test URL'; pt='URL .test'; it='URL .test'; tr='.test URL'; nl='.test-URL'; pl='.test URL' }
    ColumnFolder = @{ es='Carpeta'; ru='Папка'; ja='フォルダー'; ko='폴더'; pt='Pasta'; it='Cartella'; tr='Klasör'; nl='Map'; pl='Složka' }
    ServiceCount = @{ es='{0} servicio'; ru='{0} служба'; ja='{0}件のサービス'; ko='서비스 {0}개'; pt='{0} serviço'; it='{0} servizio'; tr='{0} servis'; nl='{0} Dienst'; pl='{0} služba' }
    ServiceCountPl = @{ es='{0} servicios'; ru='{0} служб'; ja='{0}件のサービス'; ko='서비스 {0}개'; pt='{0} serviços'; it='{0} servizi'; tr='{0} servis'; nl='{0} Dienste'; pl='{0} služby' }
    FrontendTitle = @{ es='Frameworks PHP - instalación con un clic'; ru='PHP-фреймворки - установка в один клик'; ja='PHPフレームワーク - ワンクリックインストール'; ko='PHP 프레임워크 - 원클릭 설치'; pt='Frameworks PHP - instalação com um clique'; it='Framework PHP - installazione con un clic'; tr='PHP framework''leri - tek tıkla kurulum'; nl='PHP-frameworks - installatie met één klik'; pl='PHP frameworky - instalace jedním klikem' }
    InstallLabel = @{ es='Instalar'; ru='Установить'; ja='インストール'; ko='설치'; pt='Instalar'; it='Installa'; tr='Yükle'; nl='Installeren'; pl='Instalovat' }
    FolderLabel = @{ es='Nombre de la carpeta del proyecto'; ru='Имя папки проекта'; ja='プロジェクトフォルダー名'; ko='프로젝트 폴더 이름'; pt='Nome da pasta do projeto'; it='Nome della cartella del progetto'; tr='Proje klasörü adı'; nl='Naam projectmap'; pl='Název složky projektu' }
    FrameworkHint2 = @{ es='Instalación de frameworks PHP con un clic: gratis en WampDeck.'; ru='Установка PHP-фреймворков в один клик — бесплатно в WampDeck.'; ja='PHPフレームワークをワンクリックでインストール - WampDeckでは無料。'; ko='PHP 프레임워크 원클릭 설치 - WampDeck에서 무료.'; pt='Instalação de frameworks PHP com um clique - gratuito no WampDeck.'; it='Installazione framework PHP con un clic - gratuita in WampDeck.'; tr='PHP framework''leri tek tıkla kurulum - WampDeck''te ücretsiz.'; nl='PHP-frameworks met één klik - gratis in WampDeck.'; pl='Instalace PHP frameworků jedním klikem - zdarma ve WampDeck.' }
    DatabaseClient = @{ es='Cliente de base de datos'; ru='Клиент базы данных'; ja='データベースクライアント'; ko='데이터베이스 클라이언트'; pt='Cliente de banco de dados'; it='Client database'; tr='Veritabanı istemcisi'; nl='Databaseclient'; pl='Databázový klient' }
    CapturedMail = @{ es='Correo capturado'; ru='Перехваченные письма'; ja='キャプチャしたメール'; ko='캡처된 메일'; pt='E-mail capturado'; it='Posta acquisita'; tr='Yakalanan e-posta'; nl='Opgevangen mail'; pl='Zachycená pošta' }
    WebDatabase = @{ es='Base de datos web'; ru='Веб-база данных'; ja='Webデータベース'; ko='웹 데이터베이스'; pt='Banco de dados web'; it='Database web'; tr='Web veritabanı'; nl='Webdatabase'; pl='Webová databáze' }
    PhpSettings = @{ es='Configuración de PHP'; ru='Настройки PHP'; ja='PHP設定'; ko='PHP 설정'; pt='Configurações do PHP'; it='Impostazioni PHP'; tr='PHP ayarları'; nl='PHP-instellingen'; pl='Nastavení PHP' }
    TextEditor = @{ es='Editor de texto'; ru='Текстовый редактор'; ja='テキストエディター'; ko='텍스트 편집기'; pt='Editor de texto'; it='Editor di testo'; tr='Metin düzenleyici'; nl='Teksteditor'; pl='Textový editor' }
    VersionCheck = @{ es='Comprobación de versión'; ru='Проверка версии'; ja='バージョン確認'; ko='버전 확인'; pt='Verificação de versão'; it='Controllo versione'; tr='Sürüm kontrolü'; nl='Versiecontrole'; pl='Kontrola verze' }
    CronScheduler = @{ es='Programador de tareas'; ru='Планировщик задач'; ja='タスクスケジューラー'; ko='작업 스케줄러'; pt='Agendador de tarefas'; it='Utilità di pianificazione'; tr='Görev zamanlayıcı'; nl='Taakplanner'; pl='Plánovač úloh' }
    CloseTunnel = @{ es='Cerrar el túnel'; ru='Закрыть туннель'; ja='トンネルを閉じる'; ko='터널 닫기'; pt='Fechar o túnel'; it='Chiudi il tunnel'; tr='Tüneli kapat'; nl='Tunnel sluiten'; pl='Zavřít tunel' }
    HostsFile = @{ es='Archivo hosts'; ru='Файл hosts'; ja='hostsファイル'; ko='hosts 파일'; pt='Arquivo hosts'; it='File hosts'; tr='hosts dosyası'; nl='hosts-bestand'; pl='Soubor hosts' }
    EditUac = @{ es='Editar con UAC'; ru='Редактировать с UAC'; ja='UACで編集'; ko='UAC로 편집'; pt='Editar com UAC'; it='Modifica con UAC'; tr='UAC ile düzenle'; nl='Bewerken met UAC'; pl='Upravit s UAC' }
    SslFiles = @{ es='Archivos SSL'; ru='Файлы SSL'; ja='SSLファイル'; ko='SSL 파일'; pt='Arquivos SSL'; it='File SSL'; tr='SSL dosyaları'; nl='SSL-bestanden'; pl='Soubory SSL' }
    RebuildVhosts = @{ es='Recrear hosts virtuales'; ru='Пересоздать виртуальные хосты'; ja='バーチャルホストを再作成'; ko='가상 호스트 다시 만들기'; pt='Recriar hosts virtuais'; it='Ricrea gli host virtuali'; tr='Sanal host''ları yeniden oluştur'; nl='Virtuele hosts opnieuw opbouwen'; pl='Znovu vytvořit virtuální hosty' }
    Versions = @{ es='Versiones'; ru='Версии'; ja='バージョン'; ko='버전'; pt='Versões'; it='Versioni'; tr='Sürümler'; nl='Versies'; pl='Verze' }
    TabPhpFramework = @{ es='Frameworks PHP'; ru='PHP-фреймворки'; ja='PHPフレームワーク'; ko='PHP 프레임워크'; pt='Frameworks PHP'; it='Framework PHP'; tr='PHP framework''leri'; nl='PHP-frameworks'; pl='PHP frameworky' }
    Install = @{ es='Instalar'; ru='Установить'; ja='インストール'; ko='설치'; pt='Instalar'; it='Installa'; tr='Yükle'; nl='Installeren'; pl='Instalovat' }
    FrameworkHint = @{ es='Instalación de frameworks PHP con un clic: gratis en WampDeck.'; ru='Установка PHP-фреймворков в один клик — бесплатно в WampDeck.'; ja='PHPフレームワークをワンクリックでインストール - WampDeckでは無料。'; ko='PHP 프레임워크 원클릭 설치 - WampDeck에서 무료.'; pt='Instalação de frameworks PHP com um clique - gratuito no WampDeck.'; it='Installazione framework PHP con un clic - gratuita in WampDeck.'; tr='PHP framework''leri tek tıkla kurulum - WampDeck''te ücretsiz.'; nl='PHP-frameworks met één klik - gratis in WampDeck.'; pl='Instalace PHP frameworků jedním klikem - zdarma ve WampDeck.' }
    ProjectFolderName = @{ es='Nombre de la carpeta del proyecto'; ru='Имя папки проекта'; ja='プロジェクトフォルダー名'; ko='프로젝트 폴더 이름'; pt='Nome da pasta do projeto'; it='Nome della cartella del progetto'; tr='Proje klasörü adı'; nl='Naam projectmap'; pl='Název složky projektu' }
    FirstRunTitle = @{ es='Bienvenido a WampDeck: elige tu idioma'; ru='Добро пожаловать в WampDeck — выберите язык'; ja='WampDeckへようこそ - 言語を選択'; ko='WampDeck에 오신 것을 환영합니다 - 언어 선택'; pt='Bem-vindo ao WampDeck - escolha seu idioma'; it='Benvenuto in WampDeck - scegli la lingua'; tr='WampDeck''e hoş geldiniz - dilinizi seçin'; nl='Welkom bij WampDeck - kies je taal'; pl='Vítejte ve WampDeck - vyberte jazyk' }
    FirstRunHint = @{ es='Elige el idioma de la interfaz de WampDeck.'; ru='Выберите язык интерфейса WampDeck.'; ja='WampDeckのインターフェース言語を選択してください。'; ko='WampDeck 인터페이스 언어를 선택하세요.'; pt='Escolha o idioma da interface do WampDeck.'; it='Scegli la lingua dell''interfaccia di WampDeck.'; tr='WampDeck arayüzünün dilini seçin.'; nl='Kies de taal van de WampDeck-interface.'; pl='Vyberte jazyk rozhraní WampDeck.' }
    FirstRunRtlNote = @{ es='El árabe usa diseño de derecha a izquierda. Se configura una vez durante la instalación y no cambia al cambiar de idioma en Configuración.'; ru='Арабский использует направления справа налево. Устанавливается один раз при установке и не меняется при смене языка в настройках.'; ja='アラビア語は右から左へのレイアウトを使用します。インストール時に一度設定され、設定で言語を変更しても変わりません。'; ko='아랍어는 오른쪽에서 왼쪽 레이아웃을 사용합니다. 설치 시 한 번 설정되며 설정에서 언어를 바꿔도 변경되지 않습니다.'; pt='O árabe usa layout da direita para a esquerda. Definido na instalação, não muda ao trocar o idioma nas configurações.'; it='L''arabo usa un layout da destra a sinistra. Impostato una volta all''installazione e non cambia cambiando lingua nelle impostazioni.'; tr='Arapça sağdan sola düzen kullanır. Kurulumda bir kez ayarlanır ve ayarlardan dil değiştirilince değişmez.'; nl='Arabisch gebruikt rechts-naar-links-layout. Eenmalig bij installatie ingesteld en verandert niet bij taalwissel in Instellingen.'; pl='Arabština používá rozvržení zprava doleva. Nastavuje se jednou při instalaci a při změně jazyka v nastavení se nemění.' }
    ProTitle = @{ es='WampDeck Pro - Kit de herramientas para agencias'; ru='WampDeck Pro — набор инструментов для агентств'; ja='WampDeck Pro - エージェンシー向け開発ツールキット'; ko='WampDeck Pro - 에이전시용 개발자 도구 키트'; pt='WampDeck Pro - Kit de ferramentas para agências'; it='WampDeck Pro - Strumenti per agenzie'; tr='WampDeck Pro - Ajanslar için geliştirici araç seti'; nl='WampDeck Pro - Ontwikkelaarstoolkit voor bureaus'; pl='WampDeck Pro - Vývojářská sada pro agentury' }
    ProHealth = @{ es='Panel de salud'; ru='Панель состояния'; ja='ヘルスダッシュボード'; ko='상태 대시보드'; pt='Painel de saúde'; it='Pannello salute'; tr='Sağlık paneli'; nl='Statusdashboard'; pl='Panel stavu' }
    ProBackups = @{ es='Copias de seguridad y programación'; ru='Резервные копии и расписание'; ja='バックアップとスケジュール'; ko='백업 및 예약'; pt='Backups e agendamento'; it='Backup e pianificazione'; tr='Yedekleme ve planlama'; nl='Back-ups en planning'; pl='Zálohy a plánování' }
    ProXdebug = @{ es='Alternar Xdebug'; ru='Переключить Xdebug'; ja='Xdebug切り替え'; ko='Xdebug 전환'; pt='Alternar Xdebug'; it='Attiva/disattiva Xdebug'; tr='Xdebug aç/kapat'; nl='Xdebug wisselen'; pl='Přepnout Xdebug' }
    ProGit = @{ es='Herramientas Git'; ru='Инструменты Git'; ja='Gitツール'; ko='Git 도구'; pt='Ferramentas Git'; it='Strumenti Git'; tr='Git araçları'; nl='Git-tools'; pl='Git nástroje' }
    ProMailpit = @{ es='Mailpit Pro'; ru='Mailpit Pro'; ja='Mailpit Pro'; ko='Mailpit Pro'; pt='Mailpit Pro'; it='Mailpit Pro'; tr='Mailpit Pro'; nl='Mailpit Pro'; pl='Mailpit Pro' }
    ProMore = @{ es='Complementos, bóveda y equipo'; ru='Дополнения, хранилище и команда'; ja='アドオン、ボルト、チーム'; ko='애드온, 볼트, 팀'; pt='Complementos, cofre e equipe'; it='Componenti aggiuntivi, vault e team'; tr='Eklentiler, kasa ve ekip'; nl='Add-ons, kluis en team'; pl='Doplňky, trezor a tým' }
    ProInstallSelected = @{ es='Instalar seleccionado...'; ru='Установить выбранное...'; ja='選択したものをインストール...'; ko='선택한 항목 설치...'; pt='Instalar selecionado...'; it='Installa selezionato...'; tr='Seçili olanı yükle...'; nl='Geselecteerde installeren...'; pl='Instalovat vybrané...' }
    Cancel = @{ es='Cancelar'; ru='Отмена'; ja='キャンセル'; ko='취소'; pt='Cancelar'; it='Annulla'; tr='İptal'; nl='Annuleren'; pl='Zrušit' }
    ProBadge = @{ es='PRO'; ru='PRO'; ja='PRO'; ko='PRO'; pt='PRO'; it='PRO'; tr='PRO'; nl='PRO'; pl='PRO' }
    CheckingShort = @{ es='COMPROBANDO'; ru='ПРОВЕРКА'; ja='確認中'; ko='확인 중'; pt='VERIFICANDO'; it='VERIFICA'; tr='KONTROL'; nl='CONTROLEREN'; pl='KONTROLA' }}
foreach ($key in $script:Phase1Strings.Keys) {
    if (-not $script:UiStrings.ContainsKey($key)) { $script:UiStrings[$key] = @{} }
    foreach ($lang in $script:Phase1Strings[$key].Keys) { $script:UiStrings[$key][$lang] = $script:Phase1Strings[$key][$lang] }
}

$script:CompleteLanguages += @(
    @{ Code = 'es'; Name = 'Español (Spanish)' }
    @{ Code = 'ru'; Name = 'Русский (Russian)' }
    @{ Code = 'ja'; Name = '日本語 (Japanese)' }
    @{ Code = 'ko'; Name = '한국어 (Korean)' }
    @{ Code = 'pt'; Name = 'Português (Portuguese)' }
    @{ Code = 'it'; Name = 'Italiano (Italian)' }
    @{ Code = 'tr'; Name = 'Türkçe (Turkish)' }
    @{ Code = 'nl'; Name = 'Nederlands (Dutch)' }
    @{ Code = 'pl'; Name = 'Polski (Polish)' }
)

$script:ExtraUiStringsHi = @{
    ProBadge       = @{ hi = 'PRO' }
    ColumnPhp      = @{ hi = 'PHP' }
    ColumnLocalUrl = @{ hi = 'लोकल URL' }
    CheckingShort  = @{ hi = 'जाँच' }
    InstallLabel   = @{ hi = 'इंस्टॉल' }
    FrontendTitle  = @{ hi = 'PHP फ्रेमवर्क - एक क्लिक में इंस्टॉल' }
    ColumnProject  = @{ hi = 'प्रोजेक्ट' }
    FolderLabel    = @{ hi = 'प्रोजेक्ट फ़ोल्डर का नाम' }
    FrameworkHint2 = @{ hi = 'एक क्लिक में PHP फ्रेमवर्क इंस्टॉल - WampDeck में मुफ्त।' }
    ServiceCountPl = @{ hi = '{0} सेवाएँ' }
    ColumnTestUrl  = @{ hi = '.test URL' }
    ServiceCount   = @{ hi = '{0} सेवा' }
    ColumnFolder   = @{ hi = 'फ़ोल्डर' }
}
foreach ($key in $script:ExtraUiStringsHi.Keys) {
    if (-not $script:UiStrings.ContainsKey($key)) { $script:UiStrings[$key] = @{} }
    foreach ($lang in $script:ExtraUiStringsHi[$key].Keys) { $script:UiStrings[$key][$lang] = $script:ExtraUiStringsHi[$key][$lang] }
}
