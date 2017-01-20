
----------------
-- 文本(多语言)
----------------

local M = {}

setmetatable(M, { __call = function(self, id, language)
    return self[language or LANGUAGE or "EN_US"][id] or id
end })

M["EN_US"] = {} -- 英语 - 美国
M["ZH_CN"] = {} -- 汉语 - 中国

----------------
-- language
----------------

M["EN_US"]["LANGUAGE"] = "ENGLISH"
M["ZH_CN"]["LANGUAGE"] = "简体中文"

return M

