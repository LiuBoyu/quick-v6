
----------------------------------------
-- 文本(多语言)
----------------------------------------

-- EN_US     英语 - 美国
-- ZH_CN     汉语 - 中国

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

