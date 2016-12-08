
----------------------------------------
-- 文本(多语言)
----------------------------------------

-- EN_US     英语 - 美国
-- ZH_CN     汉语 - 中国

-- HI_IN     印地语 - 印度
-- BN_IN     孟加拉语 - 印度
-- MR_IN     马拉地语 - 印度
-- GU_IN     古吉拉特语 - 印度

----------------------------------------
-- 文本(多语言)
----------------------------------------

Text = {}

setmetatable(Text, { __call = function(self, id, language)
    return self[id .. "_" .. (language or LANGUAGE or "EN_US")] or self[id .. "_" .. "EN_US"] or "???"
end })

----------------
-- language
----------------

Text.LANGUAGE_EN_US = "ENGLISH"
Text.LANGUAGE_ZH_CN = "简体中文"

Text.LANGUAGE_HI_IN = "हिन्दी"
Text.LANGUAGE_BN_IN = "বাংলা"
Text.LANGUAGE_MR_IN = "मराठी"
Text.LANGUAGE_GU_IN = "ગુજરાતી"

