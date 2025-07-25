local Base64 = {}

function Base64:encodeBase64(data)
  local base = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  return (data:gsub(".", function(x)
    local r, b = "", x:byte()
    for i = 8, 1, -1 do
      r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return r
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    if #x < 6 then
      return ""
    end
    local c = 0
    for i = 1, 6 do
      c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
    end
    return base:sub(c + 1, c + 1)
  end) .. ({
    "",
    "==",
    "="
  })[#data % 3 + 1]
end

function Base64:decodeBase64(data)
  if nil == data then
    return
  end
  local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  data = string.gsub(data, "[^" .. b .. "=]", "")
  return (data:gsub(".", function(x)
    if x == "=" then
      return ""
    end
    local r, f = "", b:find(x) - 1
    for i = 6, 1, -1 do
      r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return r
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
    if #x ~= 8 then
      return ""
    end
    local c = 0
    for i = 1, 8 do
      c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
    end
    return string.char(c)
  end))
end

function Base64:urldecode(s)
  s = string.gsub(s, "%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end)
  return s
end

function Base64:urlencode(str)
  if str then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w ])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

return Base64
