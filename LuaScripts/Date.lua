local class = require("common/class")
local os_time, os_date = os.time, os.date
local stringx = require("common/stringx")
local utils = require("common/utils")
local assert_arg, assert_string = utils.assert_arg, utils.assert_string
utils.raise_deprecation({
  source = "Penlight " .. utils._VERSION,
  message = "the 'Date' module is deprecated, see https://github.com/lunarmodules/Penlight/issues/285",
  version_removed = "2.0.0",
  version_deprecated = "1.9.2"
})
local Date = class()
Date.Format = class()

function Date:_init(t, ...)
  local time
  local nargs = select("#", ...)
  if 2 < nargs then
    local extra = {
      ...
    }
    local year = t
    t = {
      year = year,
      month = extra[1],
      day = extra[2],
      hour = extra[3],
      min = extra[4],
      sec = extra[5]
    }
  end
  if nargs == 1 then
    self.utc = select(1, ...) == true
  end
  if t == nil or t == "utc" then
    time = os_time()
    self.utc = t == "utc"
  elseif type(t) == "number" then
    time = t
    if self.utc == nil then
      self.utc = true
    end
  elseif type(t) == "table" then
    if getmetatable(t) == Date then
      time = t.time
      self.utc = t.utc
    else
      if not t.year or not t.month then
        local lt = os_date("*t")
        if not t.year and not t.month and not t.day then
          t.year = lt.year
          t.month = lt.month
          t.day = lt.day
        else
          t.year = t.year or lt.year
          t.month = t.month or t.day and lt.month or 1
          t.day = t.day or 1
        end
      end
      t.day = t.day or 1
      time = os_time(t)
    end
  else
    error("bad type for Date constructor: " .. type(t), 2)
  end
  self:set(time)
end

function Date:set(t)
  self.time = t
  if self.utc then
    self.tab = os_date("!*t", t)
  else
    self.tab = os_date("*t", t)
  end
end

function Date.tzone(ts)
  if ts == nil then
    ts = os_time()
  elseif type(ts) == "table" then
    if getmetatable(ts) == Date then
      ts = ts.time
    else
      ts = Date(ts).time
    end
  end
  local utc = os_date("!*t", ts)
  local lcl = os_date("*t", ts)
  lcl.isdst = false
  return os.difftime(os_time(lcl), os_time(utc))
end

function Date:toUTC()
  local ndate = Date(self)
  if not self.utc then
    ndate.utc = true
    ndate:set(ndate.time)
  end
  return ndate
end

function Date:toLocal()
  local ndate = Date(self)
  if self.utc then
    ndate.utc = false
    ndate:set(ndate.time)
  end
  return ndate
end

for _, c in ipairs({
  "year",
  "month",
  "day",
  "hour",
  "min",
  "sec",
  "yday"
}) do
  Date[c] = function(self, val)
    if val then
      assert_arg(1, val, "number")
      self.tab[c] = val
      self:set(os_time(self.tab))
      return self
    else
      return self.tab[c]
    end
  end
end

function Date:weekday_name(full)
  return os_date(full and "%A" or "%a", self.time)
end

function Date:month_name(full)
  return os_date(full and "%B" or "%b", self.time)
end

function Date:is_weekend()
  return self.tab.wday == 1 or self.tab.wday == 7
end

function Date:add(t)
  local old_dst = self.tab.isdst
  local key, val = next(t)
  self.tab[key] = self.tab[key] + val
  self:set(os_time(self.tab))
  if old_dst ~= self.tab.isdst then
    self.tab.hour = self.tab.hour - (old_dst and 1 or -1)
    self:set(os_time(self.tab))
  end
  return self
end

function Date:last_day()
  local d = 28
  local m = self.tab.month
  while self.tab.month == m do
    d = d + 1
    self:add({day = 1})
  end
  self:add({day = -1})
  return self
end

function Date:diff(other)
  local dt = self.time - other.time
  if dt < 0 then
    error("date difference is negative!", 2)
  end
  return Date.Interval(dt)
end

function Date:__tostring()
  local fmt = "%Y-%m-%dT%H:%M:%S"
  if self.utc then
    fmt = "!" .. fmt
  end
  local t = os_date(fmt, self.time)
  if self.utc then
    return t .. "Z"
  else
    local offs = self:tzone()
    if offs == 0 then
      return t .. "Z"
    end
    local sign = 0 < offs and "+" or "-"
    local h = math.ceil(offs / 3600)
    local m = offs % 3600 / 60
    if m == 0 then
      return t .. ("%s%02d"):format(sign, h)
    else
      return t .. ("%s%02d:%02d"):format(sign, h, m)
    end
  end
end

function Date:__eq(other)
  return self.time == other.time
end

function Date:__lt(other)
  return self.time < other.time
end

Date.__sub = Date.diff

function Date:__add(other)
  local nd = Date(self)
  if Date.Interval:class_of(other) then
    other = {
      sec = other.time
    }
  end
  nd:add(other)
  return nd
end

Date.Interval = class(Date)

function Date.Interval:_init(t)
  self:set(t)
end

function Date.Interval:set(t)
  self.time = t
  self.tab = os_date("!*t", self.time)
end

local function ess(n)
  if 1 < n then
    return "s "
  else
    return " "
  end
end

function Date.Interval:__tostring()
  local t, res = self.tab, ""
  local y, m, d = t.year - 1970, t.month - 1, t.day - 1
  if 0 < y then
    res = res .. y .. " year" .. ess(y)
  end
  if 0 < m then
    res = res .. m .. " month" .. ess(m)
  end
  if 0 < d then
    res = res .. d .. " day" .. ess(d)
  end
  if y == 0 and m == 0 then
    local h = t.hour
    if 0 < h then
      res = res .. h .. " hour" .. ess(h)
    end
    if 0 < t.min then
      res = res .. t.min .. " min "
    end
    if 0 < t.sec then
      res = res .. t.sec .. " sec "
    end
  end
  if res == "" then
    res = "zero"
  end
  return res
end

local formats = {
  d = {
    "day",
    {true, true}
  },
  y = {
    "year",
    {
      false,
      true,
      false,
      true
    }
  },
  m = {
    "month",
    {true, true}
  },
  H = {
    "hour",
    {true, true}
  },
  M = {
    "min",
    {true, true}
  },
  S = {
    "sec",
    {true, true}
  }
}

function Date.Format:_init(fmt)
  if not fmt then
    self.fmt = "%Y-%m-%d %H:%M:%S"
    self.outf = self.fmt
    self.plain = true
    return
  end
  local append = table.insert
  local D, PLUS, OPENP, CLOSEP = "\001", "\002", "\003", "\004"
  local vars, used = {}, {}
  local patt, outf = {}, {}
  local i = 1
  while i < #fmt do
    local ch = fmt:sub(i, i)
    local df = formats[ch]
    if df then
      if used[ch] then
        error("field appeared twice: " .. ch, 4)
      end
      used[ch] = true
      local _, inext = fmt:find(ch .. "+", i + 1)
      local cnt = not _ and 1 or inext - i + 1
      if not df[2][cnt] then
        error("wrong number of fields: " .. ch, 4)
      end
      local p = cnt == 1 and D .. PLUS or D:rep(cnt)
      append(patt, OPENP .. p .. CLOSEP)
      append(vars, ch)
      if ch == "y" then
        append(outf, cnt == 2 and "%y" or "%Y")
      else
        append(outf, "%" .. ch)
      end
      i = i + cnt
    else
      append(patt, ch)
      append(outf, ch)
      i = i + 1
    end
  end
  fmt = utils.escape(table.concat(patt))
  fmt = fmt:gsub(D, "%%d"):gsub(PLUS, "+"):gsub(OPENP, "("):gsub(CLOSEP, ")")
  self.fmt = fmt
  self.outf = table.concat(outf)
  self.vars = vars
end

local parse_date

function Date.Format:parse(str)
  assert_string(1, str)
  if self.plain then
    return parse_date(str, self.us)
  end
  local res = {
    str:match(self.fmt)
  }
  if #res == 0 then
    return nil, "cannot parse " .. str
  end
  local tab = {}
  for i, v in ipairs(self.vars) do
    local name = formats[v][1]
    tab[name] = tonumber(res[i])
  end
  if not (tab.year and tab.month) or not tab.day then
    local today = Date()
    tab.year = tab.year or today:year()
    tab.month = tab.month or today:month()
    tab.day = tab.day or today:day()
  end
  local Y = tab.year
  if Y < 100 then
    tab.year = Y + (Y < 35 and 2000 or 1999)
  elseif not Y then
    tab.year = 1970
  end
  return Date(tab)
end

function Date.Format:tostring(d)
  local tm
  local fmt = self.outf
  if type(d) == "number" then
    tm = d
  else
    tm = d.time
    if d.utc then
      fmt = "!" .. fmt
    end
  end
  return os_date(fmt, tm)
end

function Date.Format:US_order(yesno)
  self.us = yesno
end

local months, parse_date_unsafe

local function create_months()
  local ld, day1 = parse_date_unsafe("2000-12-31"), {day = 1}
  months = {}
  for i = 1, 12 do
    ld = ld:last_day()
    ld:add(day1)
    local mon = ld:month_name():lower()
    months[mon] = i
  end
end

local function looks_like_a_month(w)
  return w:match("^%a+,*$") ~= nil
end

local is_number = string.isdigit

local function tonum(s, l1, l2, kind)
  kind = kind or ""
  local n = tonumber(s)
  if not n then
    error(("%snot a number: '%s'"):format(kind, s))
  end
  if l1 > n or l2 < n then
    error(("%s out of range: %s is not between %d and %d"):format(kind, s, l1, l2))
  end
  return n
end

local function parse_iso_end(p, ns, sec)
  local _, nfrac, secfrac = p:find("^%.%d+", ns + 1)
  if secfrac then
    sec = sec .. secfrac
    p = p:sub(nfrac + 1)
  else
    p = p:sub(ns + 1)
  end
  if p:match("z$") then
    return sec, {h = 0, m = 0}
  end
  p = p:gsub(":", "")
  local _, _, sign, offs = p:find("^([%+%-])(%d+)")
  if not sign then
    return sec, nil
  end
  if #offs == 2 then
    offs = offs .. "00"
  end
  local tz = {
    h = tonumber(offs:sub(1, 2)),
    m = tonumber(offs:sub(3, 4))
  }
  if sign == "-" then
    tz.h = -tz.h
    tz.m = -tz.m
  end
  return sec, tz
end

function parse_date_unsafe(s, US)
  s = s:gsub("T", " ")
  local parts = string.split(s:lower())
  local i, p = 1, parts[1]
  
  local function nextp()
    i = i + 1
    p = parts[i]
  end
  
  local year, min, hour, sec, apm, tz
  local _, nxt, day, month = p:find("^(%d+)/(%d+)")
  if day then
    if US then
      day, month = month, day
    end
    _, _, year = p:find("^/(%d+)", nxt + 1)
    nextp()
  else
    year, month, day = p:match("^(%d+)%-(%d+)%-(%d+)")
    if year then
      nextp()
    end
  end
  if p and not year and is_number(p) then
    if #p < 4 then
      day = p
      nextp()
    else
      year = true
    end
  end
  if p and looks_like_a_month(p) then
    p = p:sub(1, 3)
    if not months then
      create_months()
    end
    local mon = months[p]
    if mon then
      month = mon
    else
      error("not a month: " .. p)
    end
    nextp()
  end
  if p and not year and is_number(p) then
    year = p
    nextp()
  end
  if p then
    _, nxt, hour, min = p:find("^(%d+):(%d+)")
    local ns
    if nxt then
      _, ns, sec = p:find("^:(%d+)", nxt + 1)
      sec, tz = parse_iso_end(p, ns or nxt, sec)
    else
      _, ns, hour, min = p:find("^(%d+)%.(%d+)")
      if ns then
        apm = p:match("[ap]m$")
      else
        local hourmin
        _, nxt, hourmin = p:find("^(%d+)")
        if nxt then
          hour = hourmin:sub(1, 2)
          min = hourmin:sub(3, 4)
          sec = hourmin:sub(5, 6)
          if #sec == 0 then
            sec = nil
          end
          sec, tz = parse_iso_end(p, nxt, sec)
        end
      end
    end
  end
  local today
  if year == true then
    year = nil
  end
  if not (year and month) or not day then
    today = Date()
  end
  day = day and tonum(day, 1, 31, "day") or month and 1 or today:day()
  month = month and tonum(month, 1, 12, "month") or today:month()
  year = year and tonumber(year) or today:year()
  if year < 100 then
    year = year + (year < 35 and 2000 or 1900)
  end
  hour = hour and tonum(hour, 0, apm and 12 or 24, "hour") or 12
  if apm == "pm" then
    hour = hour + 12
  end
  min = min and tonum(min, 0, 59) or 0
  sec = sec and tonum(sec, 0, 60) or 0
  local res = Date({
    year = year,
    month = month,
    day = day,
    hour = hour,
    min = min,
    sec = sec
  })
  if tz then
    local corrected = false
    if tz.h ~= 0 then
      res:add({
        hour = -tz.h
      })
      corrected = true
    end
    if tz.m ~= 0 then
      res:add({
        min = -tz.m
      })
      corrected = true
    end
    res.utc = true
    if corrected then
      res = res:toLocal()
    end
  end
  return res
end

function parse_date(s)
  local ok, d = pcall(parse_date_unsafe, s)
  if not ok then
    d = d:gsub(".-:%d+: ", "")
    return nil, d
  else
    return d
  end
end

return Date
