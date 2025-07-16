local utils = require("common/utils")
local append, format, strsub, strfind, strgsub = table.insert, string.format, string.sub, string.find, string.gsub
local APPENDER = [[

__R_size = __R_size + 1; __R_table[__R_size] = ]]

local function parseDollarParen(pieces, chunk, exec_pat, newline)
  local s = 1
  for term, executed, e in chunk:gmatch(exec_pat) do
    executed = "(" .. strsub(executed, 2, -2) .. ")"
    append(pieces, APPENDER .. format("%q", strsub(chunk, s, term - 1)))
    append(pieces, APPENDER .. format("__tostring(%s or '')", executed))
    s = e
  end
  local r
  if newline then
    r = format("%q", strgsub(strsub(chunk, s), "\n", ""))
  else
    r = format("%q", strsub(chunk, s))
  end
  if r ~= "\"\"" then
    append(pieces, APPENDER .. r)
  end
end

local function parseHashLines(chunk, inline_escape, brackets, esc, newline)
  local exec_pat = "()" .. inline_escape .. "(%b" .. brackets .. ")()"
  local esc_pat = esc .. [[
+([^
]*
?)]]
  local esc_pat1, esc_pat2 = "^" .. esc_pat, "\n" .. esc_pat
  local pieces, s = {
    [[
return function()
local __R_size, __R_table, __tostring = 0, {}, __tostring]],
    n = 1
  }, 1
  while true do
    local _, e, lua = strfind(chunk, esc_pat1, s)
    if not e then
      local ss
      ss, e, lua = strfind(chunk, esc_pat2, s)
      parseDollarParen(pieces, strsub(chunk, s, ss), exec_pat, newline)
      if not e then
        break
      end
    end
    if strsub(lua, -1, -1) == "\n" then
      lua = strsub(lua, 1, -2)
    end
    append(pieces, "\n" .. lua)
    s = e + 1
  end
  append(pieces, [[

return __R_table
end]])
  local short = false
  if #pieces == 3 and pieces[2]:find(APPENDER, 1, true) == 1 then
    pieces = {
      "return " .. pieces[2]:sub(#APPENDER + 1, -1)
    }
    short = true
  end
  return table.concat(pieces), short
end

local template = {}

function template.substitute(str, env)
  env = env or {}
  local t, err = template.compile(str, {
    chunk_name = rawget(env, "_chunk_name"),
    escape = rawget(env, "_escape"),
    inline_escape = rawget(env, "_inline_escape"),
    inline_brackets = rawget(env, "_brackets"),
    newline = nil,
    debug = rawget(env, "_debug")
  })
  if not t then
    return t, err
  end
  return t:render(env, rawget(env, "_parent"), rawget(env, "_debug"))
end

local function render(self, env, parent, db)
  env = env or {}
  if parent then
    setmetatable(env, {__index = parent})
  end
  setmetatable(self.env, {__index = env})
  local res, out = xpcall(self.fn, debug.traceback)
  if not res then
    if self.code and db then
      print(self.code)
    end
    return nil, out, self.code
  end
  return table.concat(out), nil, self.code
end

function template.compile(str, opts)
  opts = opts or {}
  local chunk_name = opts.chunk_name or "TMP"
  local escape = opts.escape or "#"
  local inline_escape = opts.inline_escape or "$"
  local inline_brackets = opts.inline_brackets or "()"
  local code, short = parseHashLines(str, inline_escape, inline_brackets, escape, opts.newline)
  local env = {
    __tostring = tostring
  }
  local fn, err = utils.load(code, chunk_name, "t", env)
  if not fn then
    return nil, err, code
  end
  if short then
    local constant_string = fn()
    return {
      fn = fn(),
      env = env,
      render = function(self)
        return constant_string, nil, self.code
      end,
      code = opts.debug and code or nil
    }
  end
  return {
    fn = fn(),
    env = env,
    render = render,
    code = opts.debug and code or nil
  }
end

return template
