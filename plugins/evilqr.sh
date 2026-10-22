#!/usr/bin/env bash

#Global shellcheck disabled warnings
#shellcheck disable=SC2034,SC2154

###### GENERIC PLUGIN VARS ######

plugin_name="EvilQR"
plugin_description="Generate a WiFi join QR code for the Evil Twin access point so victims can be associated by scanning instead of deauthentication"
plugin_author="skinnypuppy"
plugin_enabled=1

###### PLUGIN REQUIREMENTS ######

plugin_minimum_ag_affected_version="11.51"
plugin_maximum_ag_affected_version=""

plugin_distros_supported=("*")

###### CUSTOM FUNCTIONS ######

#Language strings for EvilQR
function evilqr_prehook_hookable_for_languages() {

	arr["ENGLISH","evilqr_1"]="EvilQR plugin [Evil Twin association without deauthentication]. Have the victim scan this QR code to join the Evil Twin access point (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["SPANISH","evilqr_1"]="Plugin EvilQR [Asociación al Evil Twin sin desautenticación]. Haz que la víctima escanee este código QR para unirse al punto de acceso Evil Twin (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["FRENCH","evilqr_1"]="\${pending_of_translation} Plugin EvilQR [Connexion à l'Evil Twin sans désauthentification]. Fais scanner ce code QR à la victime pour rejoindre le point d'accès Evil Twin (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["CATALAN","evilqr_1"]="\${pending_of_translation} Plugin EvilQR [Associació a l'Evil Twin sense desautenticació]. Fes que la víctima escanegi aquest codi QR per connectar-se al punt d'accés Evil Twin (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["PORTUGUESE","evilqr_1"]="\${pending_of_translation} Plugin EvilQR [Associação ao Evil Twin sem desautenticação]. Faz com que a vítima leia este código QR para se ligar ao ponto de acesso Evil Twin (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["RUSSIAN","evilqr_1"]="\${pending_of_translation} Плагин EvilQR [Подключение к Evil Twin без деаутентификации]. Попроси жертву отсканировать этот QR-код для подключения к точке доступа Evil Twin (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["GREEK","evilqr_1"]="\${pending_of_translation} Πρόσθετο EvilQR [Σύνδεση στο Evil Twin χωρίς αποαυθεντικοποίηση]. Ζήτησε από το θύμα να σαρώσει αυτόν τον κωδικό QR για να συνδεθεί στο σημείο πρόσβασης Evil Twin (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["ITALIAN","evilqr_1"]="\${pending_of_translation} Plugin EvilQR [Associazione all'Evil Twin senza deautenticazione]. Fai scansionare questo codice QR alla vittima per connettersi al punto di accesso Evil Twin (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["POLISH","evilqr_1"]="\${pending_of_translation} Wtyczka EvilQR [Łączenie z Evil Twin bez deautentykacji]. Poproś ofiarę o zeskanowanie tego kodu QR, aby połączyć się z punktem dostępowym Evil Twin (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["GERMAN","evilqr_1"]="\${pending_of_translation} EvilQR-Plugin [Verbindung mit dem Evil Twin ohne Deauthentifizierung]. Lass das Opfer diesen QR-Code scannen, um sich mit dem Evil-Twin-Zugangspunkt zu verbinden (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["TURKISH","evilqr_1"]="\${pending_of_translation} EvilQR eklentisi [Kimlik doğrulamayı sonlandırmadan Evil Twin bağlantısı]. Kurbanın Evil Twin erişim noktasına bağlanması için bu QR kodunu taramasını sağla (ESSID: \${normal_color}\${et_essid}\${green_color}):"
	arr["ARABIC","evilqr_1"]="\${pending_of_translation} :(\${normal_color}\${et_essid}\${green_color} :ESSID) Evil Twin للاتصال بنقطة الوصول QR اطلب من الضحية مسح رمز .[بدون إلغاء المصادقة Evil Twin الاتصال بـ] \${blue_color}EvilQR إضافة"
	arr["CHINESE","evilqr_1"]="\${pending_of_translation} EvilQR 插件 [无需取消认证即可连接 Evil Twin]. 让受害者扫描此二维码以连接 Evil Twin 接入点 (ESSID: \${normal_color}\${et_essid}\${green_color}):"

	arr["ENGLISH","evilqr_2"]="The QR code was also saved as \${normal_color}\${qr_file}\${yellow_color}"
	arr["SPANISH","evilqr_2"]="El código QR también se ha guardado como \${normal_color}\${qr_file}\${yellow_color}"
	arr["FRENCH","evilqr_2"]="\${pending_of_translation} Le code QR a également été enregistré sous \${normal_color}\${qr_file}\${yellow_color}"
	arr["CATALAN","evilqr_2"]="\${pending_of_translation} El codi QR també s'ha desat com a \${normal_color}\${qr_file}\${yellow_color}"
	arr["PORTUGUESE","evilqr_2"]="\${pending_of_translation} O código QR também foi guardado como \${normal_color}\${qr_file}\${yellow_color}"
	arr["RUSSIAN","evilqr_2"]="\${pending_of_translation} QR-код также сохранён в файле \${normal_color}\${qr_file}\${yellow_color}"
	arr["GREEK","evilqr_2"]="\${pending_of_translation} Ο κωδικός QR αποθηκεύτηκε επίσης ως \${normal_color}\${qr_file}\${yellow_color}"
	arr["ITALIAN","evilqr_2"]="\${pending_of_translation} Il codice QR è stato salvato anche come \${normal_color}\${qr_file}\${yellow_color}"
	arr["POLISH","evilqr_2"]="\${pending_of_translation} Kod QR został również zapisany jako \${normal_color}\${qr_file}\${yellow_color}"
	arr["GERMAN","evilqr_2"]="\${pending_of_translation} Der QR-Code wurde auch als \${normal_color}\${qr_file}\${yellow_color} gespeichert"
	arr["TURKISH","evilqr_2"]="\${pending_of_translation} QR kodu ayrıca \${normal_color}\${qr_file}\${yellow_color} olarak kaydedildi"
	arr["ARABIC","evilqr_2"]="\${pending_of_translation} \${normal_color}\${qr_file}\${yellow_color} أيضًا باسم QR تم حفظ رمز"
	arr["CHINESE","evilqr_2"]="\${pending_of_translation} 二维码也已保存为 \${normal_color}\${qr_file}\${yellow_color}"

	arr["ENGLISH","evilqr_3"]="EvilQR plugin [WPA-Enterprise mode detected]. Skipping WiFi join QR generation"
	arr["SPANISH","evilqr_3"]="Plugin EvilQR [modo WPA-Enterprise detectado]. Omitiendo la generación del código QR de conexión"
	arr["FRENCH","evilqr_3"]="\${pending_of_translation} Plugin EvilQR [mode WPA-Enterprise détecté]. Génération du code QR de connexion WiFi ignorée"
	arr["CATALAN","evilqr_3"]="\${pending_of_translation} Plugin EvilQR [mode WPA-Enterprise detectat]. S'omet la generació del codi QR de connexió WiFi"
	arr["PORTUGUESE","evilqr_3"]="\${pending_of_translation} Plugin EvilQR [modo WPA-Enterprise detetado]. A geração do código QR de ligação WiFi foi ignorada"
	arr["RUSSIAN","evilqr_3"]="\${pending_of_translation} Плагин EvilQR [обнаружен режим WPA-Enterprise]. Создание QR-кода для подключения к WiFi пропущено"
	arr["GREEK","evilqr_3"]="\${pending_of_translation} Πρόσθετο EvilQR [εντοπίστηκε λειτουργία WPA-Enterprise]. Παράλειψη δημιουργίας κωδικού QR σύνδεσης WiFi"
	arr["ITALIAN","evilqr_3"]="\${pending_of_translation} Plugin EvilQR [modalità WPA-Enterprise rilevata]. Generazione del codice QR di connessione WiFi saltata"
	arr["POLISH","evilqr_3"]="\${pending_of_translation} Wtyczka EvilQR [wykryto tryb WPA-Enterprise]. Pominięto generowanie kodu QR do połączenia z WiFi"
	arr["GERMAN","evilqr_3"]="\${pending_of_translation} EvilQR-Plugin [WPA-Enterprise-Modus erkannt]. Erstellung des QR-Codes für die WLAN-Verbindung übersprungen"
	arr["TURKISH","evilqr_3"]="\${pending_of_translation} EvilQR eklentisi [WPA-Enterprise modu algılandı]. WiFi bağlantısı için QR kodu oluşturma atlanıyor"
	arr["ARABIC","evilqr_3"]="\${pending_of_translation} WiFi للاتصال بشبكة QR يتم تخطي إنشاء رمز .[WPA-Enterprise تم اكتشاف وضع] EvilQR إضافة"
	arr["CHINESE","evilqr_3"]="\${pending_of_translation} EvilQR 插件 [检测到 WPA-Enterprise 模式]. 跳过生成 WiFi 连接二维码"

	arr["ENGLISH","evilqr_4"]="EvilQR plugin: \${normal_color}qrencode\${red_color} is not installed. QR code generation disabled. Please install the \${normal_color}qrencode\${red_color} package for your distro"
	arr["SPANISH","evilqr_4"]="Plugin EvilQR: \${normal_color}qrencode\${red_color} no está instalado. Generación de código QR deshabilitada. Por favor instala el paquete \${normal_color}qrencode\${red_color} de tu distribución"
	arr["FRENCH","evilqr_4"]="\${pending_of_translation} Plugin EvilQR: \${normal_color}qrencode\${red_color} n'est pas installé. Génération du code QR désactivée. Installe le paquet \${normal_color}qrencode\${red_color} de ta distribution"
	arr["CATALAN","evilqr_4"]="\${pending_of_translation} Plugin EvilQR: \${normal_color}qrencode\${red_color} no està instal·lat. Generació de codi QR desactivada. Instal·la el paquet \${normal_color}qrencode\${red_color} de la teva distribució"
	arr["PORTUGUESE","evilqr_4"]="\${pending_of_translation} Plugin EvilQR: \${normal_color}qrencode\${red_color} não está instalado. Geração de código QR desativada. Instala o pacote \${normal_color}qrencode\${red_color} da tua distribuição"
	arr["RUSSIAN","evilqr_4"]="\${pending_of_translation} Плагин EvilQR: \${normal_color}qrencode\${red_color} не установлен. Создание QR-кода отключено. Установи пакет \${normal_color}qrencode\${red_color} для своего дистрибутива"
	arr["GREEK","evilqr_4"]="\${pending_of_translation} Πρόσθετο EvilQR: το \${normal_color}qrencode\${red_color} δεν είναι εγκατεστημένο. Η δημιουργία κωδικού QR απενεργοποιήθηκε. Εγκατάστησε το πακέτο \${normal_color}qrencode\${red_color} της διανομής σου"
	arr["ITALIAN","evilqr_4"]="\${pending_of_translation} Plugin EvilQR: \${normal_color}qrencode\${red_color} non è installato. Generazione del codice QR disabilitata. Installa il pacchetto \${normal_color}qrencode\${red_color} della tua distribuzione"
	arr["POLISH","evilqr_4"]="\${pending_of_translation} Wtyczka EvilQR: \${normal_color}qrencode\${red_color} nie jest zainstalowany. Generowanie kodu QR jest wyłączone. Zainstaluj pakiet \${normal_color}qrencode\${red_color} dla swojej dystrybucji"
	arr["GERMAN","evilqr_4"]="\${pending_of_translation} EvilQR-Plugin: \${normal_color}qrencode\${red_color} ist nicht installiert. Erstellung des QR-Codes deaktiviert. Installiere das Paket \${normal_color}qrencode\${red_color} für deine Distribution"
	arr["TURKISH","evilqr_4"]="\${pending_of_translation} EvilQR eklentisi: \${normal_color}qrencode\${red_color} kurulu değil. QR kodu oluşturma devre dışı bırakıldı. Lütfen dağıtımın için \${normal_color}qrencode\${red_color} paketini kur"
	arr["ARABIC","evilqr_4"]="\${pending_of_translation} لتوزيعتك \${normal_color}qrencode\${red_color} يرجى تثبيت حزمة .QR غير مثبت. تم تعطيل إنشاء رمز \${normal_color}qrencode\${red_color} :EvilQR إضافة"
	arr["CHINESE","evilqr_4"]="\${pending_of_translation} EvilQR 插件: 未安装 \${normal_color}qrencode\${red_color}。已禁用二维码生成。请安装你的发行版提供的 \${normal_color}qrencode\${red_color} 软件包"
}

#Escape a string for inclusion in a WIFI: QR payload
#The special characters of the WIFI: format (\ ; , : ") must be backslash-escaped
function evilqr_escape_wifi_string() {

	local escaped_string

	escaped_string="${1}"
	escaped_string="${escaped_string//\\/\\\\}"
	escaped_string="${escaped_string//;/\\;}"
	escaped_string="${escaped_string//,/\\,}"
	escaped_string="${escaped_string//:/\\:}"
	escaped_string="${escaped_string//\"/\\\"}"

	printf '%s' "${escaped_string}"
}

#Generate the WiFi join QR code for the Evil Twin access point
#The QR payload follows the WIFI: network config format understood by the
#built-in scanners of Android and iOS. The Evil Twin is an open access point
#(wpa=0), so T:nopass makes scanning devices join it with no interaction.
#Note: et_essid is used verbatim, including the zero width space character
#appended by generate_fake_essid, so that joining devices reach the Evil
#Twin and not the original access point.
function evilqr_generate_join_qr() {

	debug_print

	if ! command -v qrencode > /dev/null 2>&1; then
		language_strings "${language}" "evilqr_4" "red"
		return 1
	fi

	if [ -n "${enterprise_mode}" ]; then
		language_strings "${language}" "evilqr_3" "blue"
		return 1
	fi

	local qr_payload
	local qr_ssid

	qr_ssid=$(evilqr_escape_wifi_string "${et_essid}")
	qr_payload="WIFI:S:${qr_ssid};T:nopass;;"

	qr_file="${PWD%/}/evilqr_$(printf '%s' "${et_essid}" | tr -cd '[:alnum:]_-').png"

	echo
	language_strings "${language}" "evilqr_1" "blue"

	if ! qrencode -t ANSIUTF8 -m 2 -l M "${qr_payload}"; then
		return 1
	fi

	if ! qrencode -t PNG -m 4 -s 6 -l M -o "${qr_file}" "${qr_payload}"; then
		return 1
	fi

	return 0
}

###### FUNCTION HOOKING: POSTHOOK ######

#After the Evil Twin access point is launched, print a scannable WiFi join
#QR code and save it as a PNG file next to airgeddon's other attack outputs
function evilqr_posthook_launch_fake_ap() {

	debug_print

	if evilqr_generate_join_qr; then
		echo
		language_strings "${language}" "evilqr_2" "yellow"
	fi

	return 0
}
