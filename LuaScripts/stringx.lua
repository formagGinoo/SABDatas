local utils = require("common/utils")
local is_callable = require("common/types").is_callable
local string = _ENV.string
local find = string.find
local type, setmetatable, ipairs = type, setmetatable, _ENV.ipairs
local error = _ENV.error
local gsub = string.gsub
local rep = string.rep
local sub = string.sub
local reverse = string.reverse
local concat = table.concat
local append = table.insert
local remove = table.remove
local escape = utils.escape
local ceil, max = math.ceil, math.max
local assert_arg, usplit = utils.assert_arg, utils.split
local lstrip
local unpack = utils.unpack
local pack = utils.pack

local function assert_string(n, s)
  assert_arg(n, s, "string")
end

local function non_empty(s)
  return 0 < #s
end

local function assert_nonempty_string(n, s)
  assert_arg(n, s, "string", non_empty, "must be a non-empty string")
end

local function makelist(l)
  return setmetatable(l, require("common/List"))
end

function string.isalpha(s)
  assert_string(1, s)
  return find(s, "^%a+$") == 1
end

function string.isdigit(s)
  assert_string(1, s)
  return find(s, "^%d+$") == 1
end

function string.isalnum(s)
  assert_string(1, s)
  return find(s, "^%w+$") == 1
end

function string.isspace(s)
  assert_string(1, s)
  return find(s, "^%s+$") == 1
end

function string.islower(s)
  assert_string(1, s)
  return find(s, "^[%l%s]+$") == 1
end

function string.isupper(s)
  assert_string(1, s)
  return find(s, "^[%u%s]+$") == 1
end

local function raw_startswith(s, prefix)
  return find(s, prefix, 1, true) == 1
end

local function raw_endswith(s, suffix)
  return #s >= #suffix and find(s, suffix, #s - #suffix + 1, true) and true or false
end

local function test_affixes(s, affixes, fn)
  if type(affixes) == "string" then
    return fn(s, affixes)
  elseif type(affixes) == "table" then
    for _, affix in ipairs(affixes) do
      if fn(s, affix) then
        return true
      end
    end
    return false
  else
    error(("argument #2 expected a 'string' or a 'table', got a '%s'"):format(type(affixes)))
  end
end

function string.startswith(s, prefix)
  assert_string(1, s)
  return test_affixes(s, prefix, raw_startswith)
end

function string.endswith(s, suffix)
  assert_string(1, s)
  return test_affixes(s, suffix, raw_endswith)
end

function string.join(s, seq)
  assert_string(1, s)
  return concat(seq, s)
end

function string.splitlines(s, keep_ends)
  assert_string(1, s)
  local res = {}
  local pos = 1
  while true do
    local line_end_pos = find(s, "[\r\n]", pos)
    if not line_end_pos then
      break
    end
    local line_end = sub(s, line_end_pos, line_end_pos)
    if line_end == "\r" and sub(s, line_end_pos + 1, line_end_pos + 1) == "\n" then
      line_end = "\r\n"
    end
    local line = sub(s, pos, line_end_pos - 1)
    if keep_ends then
      line = line .. line_end
    end
    append(res, line)
    pos = line_end_pos + #line_end
  end
  if pos <= #s then
    append(res, sub(s, pos))
  end
  return makelist(res)
end

function string.split(s, re, n)
  assert_string(1, s)
  local plain = true
  if not re then
    s = lstrip(s)
    plain = false
  end
  local res = usplit(s, re, plain, n)
  if re and re ~= "" and find(s, re, -#re, true) and (n or math.huge) > #res then
    res[#res + 1] = ""
  end
  return makelist(res)
end

function string.expandtabs(s, tabsize)
  assert_string(1, s)
  tabsize = tabsize or 8
  return (s:gsub("([^\t\r\n]*)\t", function(before_tab)
    if tabsize == 0 then
      return before_tab
    else
      return before_tab .. (" "):rep(tabsize - #before_tab % tabsize)
    end
  end))
end

local function _find_all(s, sub, first, last, allow_overlap)
  first = first or 1
  last = last or #s
  if sub == "" then
    return last + 1, last - first + 1
  end
  local i1, i2 = find(s, sub, first, true)
  local res
  local k = 0
  while i1 and (not last or not (last < i2)) do
    res = i1
    k = k + 1
    if allow_overlap then
      i1, i2 = find(s, sub, i1 + 1, true)
    else
      i1, i2 = find(s, sub, i2 + 1, true)
    end
  end
  return res, k
end

function string.lfind(s, sub, first, last)
  assert_string(1, s)
  assert_string(2, sub)
  local i1, i2 = find(s, sub, first, true)
  if i1 and (not last or last >= i2) then
    return i1
  else
    return nil
  end
end

function string.rfind(s, sub, first, last)
  assert_string(1, s)
  assert_string(2, sub)
  return (_find_all(s, sub, first, last, true))
end

function string.replace(s, old, new, n)
  assert_string(1, s)
  assert_string(2, old)
  assert_string(3, new)
  return (gsub(s, escape(old), new:gsub("%%", "%%%%"), n))
end

function string.count(s, sub, allow_overlap)
  assert_string(1, s)
  local _, k = _find_all(s, sub, 1, false, allow_overlap)
  return k
end

local function _just(s, w, ch, left, right)
  local n = #s
  if w > n then
    ch = ch or " "
    local f1, f2
    if left and right then
      local rn = ceil((w - n) / 2)
      local ln = w - n - rn
      f1 = rep(ch, ln)
      f2 = rep(ch, rn)
    elseif right then
      f1 = rep(ch, w - n)
      f2 = ""
    else
      f2 = rep(ch, w - n)
      f1 = ""
    end
    return f1 .. s .. f2
  else
    return s
  end
end

function string.ljust(s, w, ch)
  assert_string(1, s)
  assert_arg(2, w, "number")
  return _just(s, w, ch, true, false)
end

function string.rjust(s, w, ch)
  assert_string(1, s)
  assert_arg(2, w, "number")
  return _just(s, w, ch, false, true)
end

function string.center(s, w, ch)
  assert_string(1, s)
  assert_arg(2, w, "number")
  return _just(s, w, ch, true, true)
end

local function _strip(s, left, right, chrs)
  if not chrs then
    chrs = "%s"
  else
    chrs = "[" .. escape(chrs) .. "]"
  end
  local f = 1
  local t
  if left then
    local i1, i2 = find(s, "^" .. chrs .. "*")
    if i1 <= i2 then
      f = i2 + 1
    end
  end
  if right then
    if #s < 200 then
      local i1, i2 = find(s, chrs .. "*$", f)
      if i1 <= i2 then
        t = i1 - 1
      end
    else
      local rs = reverse(s)
      local i1, i2 = find(rs, "^" .. chrs .. "*")
      if i1 <= i2 then
        t = -i2 - 1
      end
    end
  end
  return sub(s, f, t)
end

function string.lstrip(s, chrs)
  assert_string(1, s)
  return _strip(s, true, false, chrs)
end

lstrip = string.lstrip

function string.rstrip(s, chrs)
  assert_string(1, s)
  return _strip(s, false, true, chrs)
end

function string.strip(s, chrs)
  assert_string(1, s)
  return _strip(s, true, true, chrs)
end

function string.splitv(s, re)
  assert_string(1, s)
  return utils.splitv(s, re)
end

local function _partition(p, delim, fn)
  local i1, i2 = fn(p, delim)
  if not i1 or i1 == -1 then
    return p, "", ""
  else
    i2 = i2 or i1
    return sub(p, 1, i1 - 1), sub(p, i1, i2), sub(p, i2 + 1)
  end
end

function string.partition(s, ch)
  assert_string(1, s)
  assert_nonempty_string(2, ch)
  return _partition(s, ch, string.lfind)
end

function string.rpartition(s, ch)
  assert_string(1, s)
  assert_nonempty_string(2, ch)
  local a, b, c = _partition(s, ch, string.rfind)
  if a == s then
    return c, b, a
  end
  return a, b, c
end

function string.at(s, idx)
  assert_string(1, s)
  assert_arg(2, idx, "number")
  return sub(s, idx, idx)
end

function string.indent(s, n, ch)
  assert_arg(1, s, "string")
  assert_arg(2, n, "number")
  local lines = usplit(s, "\n")
  local prefix = string.rep(ch or " ", n)
  for i, line in ipairs(lines) do
    lines[i] = prefix .. line
  end
  return concat(lines, "\n") .. "\n"
end

function string.dedent(s)
  assert_arg(1, s, "string")
  local lst = usplit(s, "\n")
  if 0 < #lst then
    local ind_size = math.huge
    for i, line in ipairs(lst) do
      local i1, i2 = lst[i]:find("^%s*[^%s]")
      if i1 and ind_size > i2 then
        ind_size = i2
      end
    end
    for i, line in ipairs(lst) do
      lst[i] = lst[i]:sub(ind_size, -1)
    end
  end
  return concat(lst, "\n") .. "\n"
end

do
  local function buildline(words, size, breaklong)
    local line = {}
    
    if size < #words[1] then
      if not breaklong then
        line[1] = words[1]
        remove(words, 1)
      else
        line[1] = words[1]:sub(1, size)
        words[1] = words[1]:sub(size + 1, -1)
      end
    else
      local len = 0
      while words[1] and size >= len + #words[1] or len == 0 and #words[1] == size do
        if words[1] ~= "" then
          line[#line + 1] = words[1]
          len = len + #words[1] + 1
        end
        remove(words, 1)
      end
    end
    return string.strip(concat(line, " ")), words
  end
  
  function string.wrap(s, width, breaklong)
    s = s:gsub("\n", " ")
    s = string.strip(s)
    if s == "" then
      return {""}
    end
    width = width or 70
    local out = {}
    local words = usplit(s, "%s")
    while words[1] do
      out[#out + 1], words = buildline(words, width, breaklong)
    end
    return makelist(out)
  end
end

function string.fill(s, width, breaklong)
  return concat(string.wrap(s, width, breaklong), "\n") .. "\n"
end

local function _substitute(s, tbl, safe)
  local subst
  if is_callable(tbl) then
    subst = tbl
  else
    function subst(f)
      local s = tbl[f]
      
      if not s then
        if safe then
          return f
        else
          error("not present in table " .. f)
        end
      else
        return s
      end
    end
  end
  local res = gsub(s, "%${([%w_]+)}", subst)
  return (gsub(res, "%$([%w_]+)", subst))
end

local Template = {}
string.Template = Template
Template.__index = Template
setmetatable(Template, {
  __call = function(obj, tmpl)
    return Template.new(tmpl)
  end
})

function Template.new(tmpl)
  assert_arg(1, tmpl, "string")
  local res = {}
  res.tmpl = tmpl
  setmetatable(res, Template)
  return res
end

function Template:substitute(tbl)
  assert_arg(1, tbl, "table")
  return _substitute(self.tmpl, tbl, false)
end

function Template:safe_substitute(tbl)
  assert_arg(1, tbl, "table")
  return _substitute(self.tmpl, tbl, true)
end

function Template:indent_substitute(tbl)
  assert_arg(1, tbl, "table")
  if not self.strings then
    self.strings = usplit(self.tmpl, "\n")
  end
  
  local function subst(line)
    return line:gsub("(%s*)%$([%w_]+)", function(sp, f)
      local subtmpl
      local s = tbl[f]
      if not s then
        error("not present in table " .. f)
      end
      if getmetatable(s) == Template then
        subtmpl = s
        s = s.tmpl
      else
        s = tostring(s)
      end
      if s:find("\n") then
        local lines = usplit(s, "\n")
        for i, line in ipairs(lines) do
          lines[i] = sp .. line
        end
        s = concat(lines, "\n") .. "\n"
      end
      if subtmpl then
        return _substitute(s, tbl)
      else
        return s
      end
    end)
  end
  
  local lines = {}
  for i, line in ipairs(self.strings) do
    lines[i] = subst(line)
  end
  return concat(lines, "\n") .. "\n"
end

function string.lines(s)
  assert_string(1, s)
  if not s:find([[

$]]) then
    s = s .. "\n"
  end
  return s:gmatch([[
([^
]*)
]])
end

function string.title(s)
  assert_string(1, s)
  return (s:gsub("(%S)(%S*)", function(f, r)
    return f:upper() .. r:lower()
  end))
end

string.capitalize = string.title
do
  local ellipsis = "..."
  local n_ellipsis = #ellipsis
  
  function string.shorten(s, w, tail)
    assert_string(1, s)
    if w < #s then
      if w < n_ellipsis then
        return ellipsis:sub(1, w)
      end
      if tail then
        local i = #s - w + 1 + n_ellipsis
        return ellipsis .. s:sub(i)
      else
        return s:sub(1, w - n_ellipsis) .. ellipsis
      end
    end
    return s
  end
end
do
  local function has_lquote(s)
    local lstring_pat = "([%[%]])(=*)%1"
    
    local equals, new_equals, _
    local finish = 1
    repeat
      _, finish, _, new_equals = s:find(lstring_pat, finish)
      if new_equals then
        equals = max(equals or 0, #new_equals)
      end
    until not new_equals
    return equals
  end
  
  function string.quote_string(s)
    assert_string(1, s)
    local equal_signs = has_lquote(s .. "]")
    if (s:find("\n") or equal_signs) and not s:find("\r") then
      equal_signs = ("="):rep((equal_signs or -1) + 1)
      if s:find("^\n") then
        s = "\n" .. s
      end
      local lbracket, rbracket = "[" .. equal_signs .. "[", "]" .. equal_signs .. "]"
      s = lbracket .. s .. rbracket
    else
      s = ("%q"):format(s):gsub("\r", "\\r")
    end
    return s
  end
end

function string.format_operator()
  local format = string.format
  
  local function formatx(fmt, ...)
    local args = pack(...)
    local i = 1
    for p in fmt:gmatch("%%.") do
      if p == "%s" and type(args[i]) ~= "string" then
        args[i] = tostring(args[i])
      end
      i = i + 1
    end
    return format(fmt, unpack(args))
  end
  
  local function basic_subst(s, t)
    return (s:gsub("%$([%w_]+)", t))
  end
  
  getmetatable("").__mod = function(a, b)
    if b == nil then
      return a
    elseif type(b) == "table" and getmetatable(b) == nil then
      if #b == 0 then
        return _substitute(a, b, true)
      else
        return formatx(a, unpack(b))
      end
    elseif type(b) == "function" then
      return basic_subst(a, b)
    else
      return formatx(a, b)
    end
  end
end

string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.htmlspecialchars(input)
  for k, v in pairs(string._htmlspecialchars_set) do
    input = string.gsub(input, k, v)
  end
  return input
end

function string.restorehtmlspecialchars(input)
  for k, v in pairs(string._htmlspecialchars_set) do
    input = string.gsub(input, v, k)
  end
  return input
end

function string.nl2br(input)
  return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
  input = string.gsub(input, "\t", "    ")
  input = string.htmlspecialchars(input)
  input = string.gsub(input, " ", "&nbsp;")
  input = string.nl2br(input)
  return input
end

function string.ltrim(input)
  return string.gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
  return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
  input = string.gsub(input, "^[ \t\n\r]+", "")
  return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.strtrim(str)
  if str == nil or str == "" then
    return str
  end
  local str2 = string.trim(str)
  return st
end

function string.ucfirst(input)
  return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
  return "%" .. string.format("%02X", string.byte(char))
end

function string.urlencode(input)
  input = string.gsub(tostring(input), "\n", "\r\n")
  input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
  return string.gsub(input, " ", "+")
end

function string.urldecode(input)
  input = string.gsub(input, "+", " ")
  input = string.gsub(input, "%%(%x%x)", function(h)
    return string.char(math.checknumber(h, 16))
  end)
  input = string.gsub(input, "\r\n", "\n")
  return input
end

function string.utf8len(input)
  local len = string.len(input)
  local left = len
  local cnt = 0
  local arr = {
    0,
    192,
    224,
    240,
    248,
    252
  }
  while left ~= 0 do
    local tmp = string.byte(input, -left)
    local i = #arr
    while arr[i] do
      if tmp >= arr[i] then
        left = left - i
        break
      end
      i = i - 1
    end
    cnt = cnt + 1
  end
  return cnt
end

function string.formatnumberthousands(num)
  local formatted = tostring(tonumber(num) or 0)
  local k
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    if k == 0 then
      break
    end
  end
  return formatted
end

function string.isnullorempty(str)
  return str == nil or str == ""
end

function string.splitarr(input, sep1, sep2)
  local retArr = {}
  sep1 = sep1 or ";"
  sep2 = sep2 or ","
  local sep1arr = string.split(input, sep1)
  local index = 1
  for _, v in pairs(sep1arr) do
    local sep2arr = string.split(v, sep2)
    retArr[index] = sep2arr
    index = index + 1
  end
  return retArr
end

function string.gsubnumberreplace(str, ...)
  local arg = {
    ...
  }
  str = string.gsub(str, "{(%d+)}", function(idx)
    return arg[idx + 1]
  end)
  return str
end

function string.customizereplace(str, seps, ...)
  local arg = {
    ...
  }
  for i, v in ipairs(seps) do
    str = string.gsub(str, v, arg[i])
  end
  return str
end

function string.formatnumber(str)
  if string.len(str) <= 3 then
    return str
  else
    return string.formatnumber(string.sub(str, 1, string.len(str) - 3)) .. "," .. string.sub(str, string.len(str) - 3 + 1, -1)
  end
end

function string.resourcenumformat(num)
  if 1000000000 <= num then
    return string.format("%.2fB", num / 1000000000)
  elseif 1000000 <= num then
    local value = num / 1000000
    if 100 < value then
      return string.format("%dM", math.floor(value))
    elseif 10 < value then
      return string.format("%.1fM", value)
    else
      return string.format("%.2fM", value)
    end
  elseif 10000 <= num then
    local value = num / 1000
    if 100 < value then
      return string.format("%dK", math.floor(value))
    else
      return string.format("%.1fK", value)
    end
  else
    return tostring(num)
  end
end

function string.GetLetterNumberChar(str)
  local resultChar = {}
  local i = 1
  while true do
    local curByte = string.byte(str, i)
    local byteCount = 1
    if 239 < curByte then
      byteCount = 4
    elseif 223 < curByte then
      byteCount = 3
    elseif 128 < curByte then
      byteCount = 2
    elseif curByte == 10 then
      byteCount = 1
    else
      byteCount = 1
    end
    local subStr = string.sub(str, i, i + byteCount - 1)
    if 47 < curByte and curByte < 58 or 96 < curByte and curByte < 123 or 64 < curByte and curByte < 91 then
      table.insert(resultChar, subStr)
    end
    local charUnicodeNum = string.utf8_to_unicode(subStr)
    if 19968 <= charUnicodeNum and charUnicodeNum <= 40891 then
      table.insert(resultChar, subStr)
    elseif 12352 <= charUnicodeNum and charUnicodeNum <= 12447 then
      table.insert(resultChar, subStr)
    elseif 12448 <= charUnicodeNum and charUnicodeNum <= 12543 then
      table.insert(resultChar, subStr)
    elseif 12784 <= charUnicodeNum and charUnicodeNum <= 12799 then
      table.insert(resultChar, subStr)
    elseif charUnicodeNum == 183 then
      table.insert(resultChar, subStr)
    end
    i = i + byteCount
    if i > #str then
      return table.concat(resultChar)
    end
  end
end

local blockedUnicode = {
  125,
  376,
  402,
  710,
  732,
  8211,
  8212,
  8216,
  8217,
  8218,
  8220,
  8221,
  8224,
  8225,
  8226,
  8222,
  8230,
  8240,
  8249,
  8250,
  8364,
  8482,
  338,
  339,
  352,
  353,
  381,
  382,
  215,
  247
}

function string.GetIsBlocked(value)
  for _, v in ipairs(blockedUnicode) do
    if v == value then
      return true
    end
  end
  return false
end

function string.GetTextualNorms(str)
  local resultChar = {}
  local i = 1
  while true do
    local curByte = string.byte(str, i)
    local byteCount = 1
    if 239 < curByte then
      byteCount = 4
    elseif 223 < curByte then
      byteCount = 3
    elseif 128 < curByte then
      byteCount = 2
    elseif curByte == 10 then
      byteCount = 1
    else
      byteCount = 1
    end
    local subStr = string.sub(str, i, i + byteCount - 1)
    local charUnicodeNum = string.utf8_to_unicode(subStr)
    if 33 <= charUnicodeNum and charUnicodeNum <= 47 or 58 <= charUnicodeNum and charUnicodeNum <= 64 or 91 <= charUnicodeNum and charUnicodeNum <= 96 or 123 <= charUnicodeNum and charUnicodeNum <= 191 or string.GetIsBlocked(charUnicodeNum) then
    else
      table.insert(resultChar, subStr)
    end
    i = i + byteCount
    if i > #str then
      return table.concat(resultChar)
    end
  end
end

function string.GetTextualNormsGuildNotice(str)
  local resultChar = {}
  local i = 1
  while true do
    local curByte = string.byte(str, i)
    local byteCount = 1
    if 239 < curByte then
      byteCount = 4
    elseif 223 < curByte then
      byteCount = 3
    elseif 128 < curByte then
      byteCount = 2
    elseif curByte == 10 then
      byteCount = 1
    else
      byteCount = 1
    end
    local subStr = string.sub(str, i, i + byteCount - 1)
    local charUnicodeNum = string.utf8_to_unicode(subStr)
    if 60 <= charUnicodeNum and charUnicodeNum < 63 or 123 <= charUnicodeNum and charUnicodeNum < 183 or charUnicodeNum == 215 or charUnicodeNum == 247 or 183 < charUnicodeNum and charUnicodeNum <= 191 then
    else
      table.insert(resultChar, subStr)
    end
    i = i + byteCount
    if i > #str then
      return table.concat(resultChar)
    end
  end
end

function string.utf8_to_unicode(convertStr)
  if type(convertStr) ~= "string" then
    return convertStr
  end
  local resultDec = 0
  local i = 1
  local num1 = string.byte(convertStr, i)
  if num1 ~= nil then
    local tempVar1, tempVar2 = 0, 0
    if 0 <= num1 and num1 <= 127 then
      tempVar1 = num1
      tempVar2 = 0
    elseif num1 & 224 == 192 then
      local t1 = 0
      local t2 = 0
      t1 = num1 & 31
      i = i + 1
      num1 = string.byte(convertStr, i)
      t2 = num1 & 63
      tempVar1 = t2 | (t1 & 3) << 6
      tempVar2 = t1 >> 2
    elseif num1 & 240 == 224 then
      local t1 = 0
      local t2 = 0
      local t3 = 0
      t1 = num1 & 31
      i = i + 1
      num1 = string.byte(convertStr, i)
      t2 = num1 & 63
      i = i + 1
      num1 = string.byte(convertStr, i)
      t3 = num1 & 63
      tempVar1 = (t2 & 3) << 6 | t3
      tempVar2 = t1 << 4 | t2 >> 2
    end
    resultDec = tempVar2 * 256 + tempVar1
  end
  return resultDec
end

function string.getChrSize(char)
  if not char then
    return 0
  elseif 240 <= char then
    return 4
  elseif 224 <= char then
    return 3
  elseif 192 <= char then
    return 2
  elseif 0 <= char then
    return 1
  end
end

function string.utf8len_ChineseInTwo(str)
  local len = 0
  local currentIndex = 1
  while currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    local charLength = string.getChrSize(char)
    currentIndex = currentIndex + charLength
    if 2 < charLength then
      len = len + 2
    else
      len = len + 1
    end
  end
  return len
end

function string.checkFirstCharIsSpacing(str)
  local curByte = string.byte(str, 1)
  local flag = false
  if not curByte then
    return flag
  end
  local byteCount = 1
  if 239 < curByte then
    byteCount = 4
  elseif 223 < curByte then
    byteCount = 3
  elseif 128 < curByte then
    byteCount = 2
  elseif curByte == 10 then
    byteCount = 1
  else
    byteCount = 1
  end
  local subStr = string.sub(str, 1, 1 + byteCount - 1)
  local charUnicodeNum = string.utf8_to_unicode(subStr)
  if charUnicodeNum == 32 or charUnicodeNum == 12288 then
    flag = true
  end
  return flag
end

function string.utf8len_WordCount(str)
  local len = 0
  local currentIndex = 1
  while currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    local charLength = string.getChrSize(char)
    currentIndex = currentIndex + charLength
    len = len + 1
  end
  return len
end

function string.CS_Format(str, ...)
  local args = {
    ...
  }
  if #args <= 0 then
    return
  end
  if type(args[1]) == "table" then
    args = args[1]
  end
  local formatted = str:gsub("{(%d+)}", function(match)
    local index = tonumber(match) + 1
    return tostring(args[index])
  end)
  return formatted
end

function string.trim_leading_zeros(str)
  return tostring(str):match("^0*(%d+)$") or "0"
end

function string.compare_numeric_strings(a, b, ascending)
  a = string.trim_leading_zeros(a)
  b = string.trim_leading_zeros(b)
  if #a ~= #b then
    return ascending and #a < #b or #a > #b
  else
    return ascending and a < b or a > b
  end
end
