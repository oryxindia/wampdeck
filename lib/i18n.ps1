# WampDeck UI string dictionaries and multi-language support.
# The user picks a language from Settings; Get-WampDeckString resolves the
# active language and falls back to English when missing.

$script:WampDeckFallbackLanguage = 'en'

$script:WampDeckLanguages = @(
    @{ Code = 'ca'; Name = 'Catalan' }
    @{ Code = 'hr'; Name = 'Croatian' }
    @{ Code = 'cs'; Name = 'Czech' }
    @{ Code = 'nl'; Name = 'Dutch' }
    @{ Code = 'en'; Name = 'English' }
    @{ Code = 'fr'; Name = 'French' }
    @{ Code = 'de'; Name = 'German' }
    @{ Code = 'el'; Name = 'Greek' }
    @{ Code = 'hi'; Name = 'Hindi' }
    @{ Code = 'hu'; Name = 'Hungarian' }
    @{ Code = 'id'; Name = 'Indonesian' }
    @{ Code = 'it'; Name = 'Italiano' }
    @{ Code = 'ja'; Name = 'Japanese' }
    @{ Code = 'ko'; Name = 'Korean' }
    @{ Code = 'pl'; Name = 'Polish' }
    @{ Code = 'pt'; Name = 'Portuguese' }
    @{ Code = 'ro'; Name = 'Romanian' }
    @{ Code = 'ru'; Name = 'Russian' }
    @{ Code = 'zh-CN'; Name = 'Simplified Chinese' }
    @{ Code = 'sk'; Name = 'Slovak' }
    @{ Code = 'es'; Name = 'Spanish' }
    @{ Code = 'sr'; Name = 'Serbian' }
    @{ Code = 'sv'; Name = 'Swedish' }
    @{ Code = 'zh-TW'; Name = 'Traditional Chinese' }
    @{ Code = 'th'; Name = 'Thai' }
    @{ Code = 'tr'; Name = 'Turkish' }
    @{ Code = 'vi'; Name = 'Vietnamese' }
)

$script:UiStrings = @{
    AppTitle         = @{ en = 'WampDeck';        hi = 'वाम्पडेक' }
    AppSubtitle      = @{ en = 'Portable PHP development stack'; hi = 'पोर्टेबल PHP डेवलपमेंट स्टैक' }
    Stack            = @{ en = 'Stack';           hi = 'स्टैक' }
    Project          = @{ en = 'Project';         hi = 'प्रोजेक्ट' }
    Services         = @{ en = 'Services';        hi = 'सेवाएँ' }
    Tools            = @{ en = 'Tools';           hi = 'उपकरण' }
    Settings         = @{ en = 'Settings';        hi = 'सेटिंग्स' }
    Help             = @{ en = 'Help';            hi = 'मदद' }
    Language         = @{ en = 'Language';        hi = 'भाषा' }
    Start            = @{ en = 'Start';           hi = 'शुरू करें' }
    Stop             = @{ en = 'Stop';            hi = 'रोकें' }
    Restart          = @{ en = 'Restart';         hi = 'पुनरारंभ करें' }
    Terminal         = @{ en = '>_  Terminal';    hi = '>_  टर्मिनल' }
    TerminalHint     = @{ en = 'Open a terminal in www with PHP, Composer, Git, Node and MySQL ready'; hi = 'PHP, Composer, Git, Node और MySQL उपलब्ध होने पर www में टर्मिनल खोलें' }
    StartStack       = @{ en = 'Start stack';     hi = 'स्टैक शुरू करें' }
    StopStack        = @{ en = 'Stop stack';      hi = 'स्टैक रोकें' }
    RestartStack     = @{ en = 'Restart stack';   hi = 'स्टैक पुनरारंभ करें' }
    OpenPanelInBrowser = @{ en = 'Open panel in browser'; hi = 'ब्राउज़र में पैनल खोलें' }
    OpenWwwFolder    = @{ en = 'Open www folder'; hi = 'www फ़ोल्डर खोलें' }
    OpenLogsFolder   = @{ en = 'Open logs folder'; hi = 'लॉग फ़ोल्डर खोलें' }
    TerminalInWww   = @{ en = 'Terminal in www';  hi = 'www में टर्मिनल' }
    Quit             = @{ en = 'Quit';            hi = 'बाहर निकलें' }
    NewProject       = @{ en = 'New project...';  hi = 'नया प्रोजेक्ट...' }
    OpenInBrowser    = @{ en = 'Open in browser';  hi = 'ब्राउज़र में खोलें' }
    OpenTestUrl      = @{ en = 'Open .test URL';   hi = '.test URL खोलें' }
    OpenFolder       = @{ en = 'Open folder';      hi = 'फ़ोल्डर खोलें' }
    OpenTerminalHere = @{ en = 'Open terminal here'; hi = 'यहाँ टर्मिनल खोलें' }
    CopyLocalUrl     = @{ en = 'Copy local URL';   hi = 'लोकल URL कॉपी करें' }
    DeleteProject    = @{ en = 'Delete project...'; hi = 'प्रोजेक्ट हटाएँ...' }
    RefreshProjects  = @{ en = 'Refresh project list'; hi = 'प्रोजेक्ट सूची रिफ्रेश करें' }
    ProjectPhpVersion = @{ en = 'PHP version'; hi = 'PHP संस्करण' }
    ProjectPhpDefault = @{ en = 'Stack default ({0})'; hi = 'स्टैक डिफ़ॉल्ट ({0})' }
    ProjectPhpChanged = @{ en = '{0} now runs PHP {1}.'; hi = '{0} अब PHP {1} पर चलता है।' }
    ProjectPhpColumn  = @{ en = 'PHP'; hi = 'PHP' }
    HeidiSql         = @{ en = 'HeidiSQL';         hi = 'HeidiSQL' }
    MailpitInbox     = @{ en = 'Mailpit (web inbox)';   hi = 'मेलपिट इनबॉक्स' }
    Adminer          = @{ en = 'Adminer';          hi = 'Adminer' }
    Phpinfo          = @{ en = 'phpinfo()';        hi = 'phpinfo()' }
    Notepad          = @{ en = 'Notepad++';       hi = 'Notepad++' }
    NgrokStart       = @{ en = 'Start ngrok tunnel'; hi = 'ngrok टनल शुरू करें' }
    NgrokStop        = @{ en = 'Stop ngrok';       hi = 'ngrok रोकें' }
    NgrokNoToken     = @{ en = 'ngrok started, but no public URL yet. Add your authtoken first.'; hi = 'ngrok शुरू हो गया, पर अभी public URL नहीं है। पहले अपना authtoken दें।' }
    HostsChecking    = @{ en = 'hosts: checking'; hi = 'hosts: जाँच हो रही है' }
    HostsSyncing     = @{ en = 'Syncing the hosts file...'; hi = 'होस्ट्स फ़ाइल सिंक हो रही है...' }
    HostsOpening     = @{ en = 'Opening the hosts file...'; hi = 'होस्ट्स फ़ाइल खोल रही है...' }
    Cronical         = @{ en = 'Cronical scheduler'; hi = 'Cronical शेड्यूलर' }
    SyncHosts        = @{ en = 'Sync hosts file (UAC)'; hi = 'होस्ट्स फ़ाइल सिंक करें (UAC)' }
    EditHosts        = @{ en = 'Edit hosts file (UAC)'; hi = 'होस्ट्स फ़ाइल एडिट करें (UAC)' }
    CertificatesFolder = @{ en = 'Certificates folder'; hi = 'सर्टिफिकेट फ़ोल्डर' }
    PhpExtensions    = @{ en = 'PHP extensions...'; hi = 'PHP एक्सटेंशन...' }
    StartStackWhenPanelOpens = @{ en = 'Start stack when the panel opens'; hi = 'पैनल खुलते ही स्टैक शुरू करें' }
    StartWithWindows = @{ en = 'Start with Windows'; hi = 'Windows के साथ शुरू करें' }
    RefreshConfigs   = @{ en = 'Refresh configs';   hi = 'कॉन्फिगरेशन रिफ्रेश करें' }
    About            = @{ en = 'About WampDeck';   hi = 'WampDeck के बारे में' }
    Readme           = @{ en = 'README';           hi = 'रीडमी' }
    OpenInstallFolder = @{ en = 'Open install folder'; hi = 'इनस्टॉल फ़ोल्डर खोलें' }
    EnableHttps      = @{ en = 'Enable HTTPS';    hi = 'HTTPS चालू करें' }
    DisableHttps     = @{ en = 'Disable HTTPS';   hi = 'HTTPS बंद करें' }
    TrustCert        = @{ en = 'Trust certificate (Windows dialog)'; hi = 'सर्टिफिकेट विश्वास करें (Windows dialog)' }
    RegenerateCert   = @{ en = 'Regenerate certificate'; hi = 'सर्टिफिकेट दोबारा बनाएँ' }
    Php              = @{ en = 'PHP';              hi = 'PHP' }
    WebServer        = @{ en = 'Web server';      hi = 'वेब सर्वर' }
    Database         = @{ en = 'Database';        hi = 'डेटाबेस' }
    ExtraServices   = @{ en = 'Extra services';  hi = 'अतिरिक्त सेवाएँ' }
    MySql            = @{ en = 'MySQL';           hi = 'MySQL' }
    Running          = @{ en = 'running';        hi = 'चालू' }
    Stopped          = @{ en = 'stopped';        hi = 'बंद' }
    Starting         = @{ en = 'starting...';    hi = 'शुरू हो रहा है...' }
    Stopping         = @{ en = 'stopping...';    hi = 'रुक रहा है...' }
    StartingService  = @{ en = 'Starting service...'; hi = 'सेवा शुरू हो रही है...' }
    StoppingService  = @{ en = 'Stopping service...'; hi = 'सेवा रुक रही है...' }
    Ready            = @{ en = 'Ready';           hi = 'तैयार' }
    StartingTheStack = @{ en = 'Starting the stack...'; hi = 'स्टैक शुरू हो रहा है...' }
    StoppingTheStack  = @{ en = 'Stopping the stack...'; hi = 'स्टैक रुक रहा है...' }
    RestartingTheStack = @{ en = 'Restarting the stack...'; hi = 'स्टैक पुनरारंभ हो रहा है...' }
    AnotherTaskRunning = @{ en = 'Another WampDeck task is still running. Wait for it to finish.'; hi = 'एक और WampDeck कार्य अभी चल रहा है. कृपया इंतज़ार करें।' }
    TaskFailed       = @{ en = 'WampDeck task failed (exit {0}).'; hi = 'WampDeck कार्य विफल रहा (exit {0})।' }
    CheckStatus      = @{ en = 'CHECKING';       hi = 'जाँच हो रही है...' }
    SslChecking      = @{ en = 'ssl: checking';  hi = 'ssl: जाँच हो रही है' }
    SslOn            = @{ en = 'ssl: on, trusted'; hi = 'ssl: चालू, विश्वासित' }
    SslOnCaUntrusted = @{ en = 'ssl: on, CA not trusted'; hi = 'ssl: चालू, CA विश्वासित नहीं' }
    SslOff           = @{ en = 'ssl: off';       hi = 'ssl: बंद' }
    Online           = @{ en = 'ONLINE';         hi = 'ऑनलाइन' }
    Offline          = @{ en = 'OFFLINE';        hi = 'ऑफ़लाइन' }
    PortsBusy        = @{ en = 'The ports are still busy. Stop the other program or change the ports.'; hi = 'पोर्ट अभी भी व्यस्त हैं। कृपया अन्य प्रोग्राम रोकें या पोर्ट बदलें।' }
    WwwHint          = @{ en = 'Double-click a project to open it. Every folder in www\ gets a local URL automatically.'; hi = 'प्रोजेक्ट को डबल-क्लिक करें खोलने के लिए। www\ के हर फ़ोल्डर को अपने आप लोकल URL मिल जाता है।' }
    ServicesHint     = @{ en = 'Core services always run. Enable Mailpit, Redis or Memcached in Settings. Double-click to start or stop.'; hi = 'कोर सेवाएँ हमेशा चलती हैं। मेलपिट, Redis या Memcached को सेटिंग्स में चालू करें। डबल-क्लिक से शुरू/रोकें।' }
    AutoStartInfo    = @{ en = 'WampDeck will start with Windows (in the notification area).'; hi = 'WampDeck Windows के साथ शुरू होगा (notification area में)।' }
    AutoStartOffInfo = @{ en = 'WampDeck will no longer start with Windows.'; hi = 'WampDeck अब Windows के साथ शुरू होगा नहीं।' }
    EnablingHttps    = @{ en = 'Enabling HTTPS...'; hi = 'HTTPS चालू हो रहा है...' }
    DisablingHttps   = @{ en = 'Disabling HTTPS...'; hi = 'HTTPS बंद हो रहा है...' }
    WaitingForTrust  = @{ en = 'Waiting for the Windows confirmation...'; hi = 'Windows confirmation इंतज़ार कर रहा है...' }
    RegeneratingCert = @{ en = 'Regenerating certificates...'; hi = 'सर्टिफिकेट दोबारा बन रहे हैं...' }
    ServiceStart     = @{ en = 'Start';   hi = 'शुरू करें' }
    ServiceStop      = @{ en = 'Stop';    hi = 'रोकें' }
    ServiceStartAll  = @{ en = 'Start all';   hi = 'सब शुरू करें' }
    ServiceStopAll   = @{ en = 'Stop all';    hi = 'सब रोकें' }
    ServiceToggleStartup = @{ en = 'Toggle startup'; hi = 'शुरुआत टॉगल करें' }
    ServiceAlways    = @{ en = 'always'; hi = 'हमेशा' }
    ServiceOff       = @{ en = 'off';    hi = 'बंद' }
    TabProjects     = @{ en = 'Projects';   hi = 'प्रोजेक्ट' }
    TabServices     = @{ en = 'Services';   hi = 'सेवाएँ' }
    TabTools        = @{ en = 'Tools';      hi = 'उपकरण' }
    TabNewProject   = @{ en = 'New project'; hi = 'नया प्रोजेक्ट' }
    TabOpen         = @{ en = 'Open';       hi = 'खोलें' }
    TabTestUrl      = @{ en = '.test URL';  hi = '.test URL' }
    TabFolder       = @{ en = 'Folder';     hi = 'फ़ोल्डर' }
    TabCopyUrl      = @{ en = 'Copy URL';   hi = 'कॉपी करें' }
    TabDelete       = @{ en = 'Delete';     hi = 'हटाएँ' }
    TabRefresh      = @{ en = 'Refresh';    hi = 'रिफ्रेश' }
    TabTerminal     = @{ en = 'Terminal';   hi = 'टर्मिनल' }
    ProjectCount    = @{ en = '{0} project';     hi = '{0} प्रोजेक्ट' }
    ProjectCountPlural = @{ en = '{0} projects'; hi = '{0} प्रोजेक्ट' }
    TrayBalloon      = @{ en = 'Still running in the notification area.'; hi = 'अभी notification area में चल रहा है।' }
}

function Get-WampDeckLanguageCodes {
    return @($script:WampDeckLanguages | ForEach-Object { [string]$_.Code })
}

function Get-WampDeckLanguage {
    $code = [string]$script:WampDeckFallbackLanguage
    if ($null -ne $State -and $State.Contains('language')) {
        $saved = $State['language']
        if ($saved) { $code = [string]$saved }
    }
    if (@($script:WampDeckLanguages | ForEach-Object { [string]$_.Code }) -notcontains $code) { $code = [string]$script:WampDeckFallbackLanguage }
    return $code
}

function Set-WampDeckLanguage {
    param([string]$Code)
    $valid = @($script:WampDeckLanguages | ForEach-Object { [string]$_.Code })
    if ($valid -notcontains $Code) { $Code = [string]$script:WampDeckFallbackLanguage }
    $State['language'] = $Code
    Save-StackState
    return $Code
}

function Get-WampDeckString {
    param(
        [string]$Key,
        [string]$Language,
        [string]$Format
    )
    $text = $Key
    if ($null -ne $script:UiStrings -and $script:UiStrings.ContainsKey($Key)) {
        $entry = $script:UiStrings[$Key]
        $value = $null
        if ($entry -is [hashtable]) { $value = $entry[$Language] }
        if ([string]::IsNullOrEmpty([string]$value)) { $value = $entry[$script:WampDeckFallbackLanguage] }
        $text = [string]$value
    }
    if (-not [string]::IsNullOrEmpty($Format)) { $text = $text -f $Format }
    return $text
}

function Get-WampDeckLanguageNames {
    $names = @()
    foreach ($entry in @($script:WampDeckLanguages)) { $names += [string]$entry.Name }
    return $names
}
