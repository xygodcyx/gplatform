extends Node

var lang_text_map = {
    "en": "English",
    "zh_CN": "中文",
    "zh_TW": "繁体",
    "ja": "日本語"
};

var all_lang: PackedStringArray = TranslationServer.get_loaded_locales()

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    if DataManager.lang_index == -1:
        var default_lang = TranslationServer.get_locale()
        TranslationServer.set_locale(default_lang)
        DataManager.lang_index = all_lang.find(default_lang)
        print("lang_index: ", DataManager.lang_index)