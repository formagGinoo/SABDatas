local SC_MemLeakDetector = {}
local memStat = {}
local currentMem = 0
local statLine = true

local function RecordAlloc(event, lineNo)
  local memInc = collectgarbage("count") - currentMem
  if memInc <= 1.0E-6 then
    currentMem = collectgarbage("count")
    return
  end
  local s = debug.getinfo(2, "S").source
  if statLine then
    s = string.format("%s__%d", s, lineNo - 1)
  end
  local item = memStat[s]
  if not item then
    memStat[s] = {
      s,
      1,
      memInc
    }
  else
    item[2] = item[2] + 1
    item[3] = item[3] + memInc
  end
  currentMem = collectgarbage("count")
end

function SC_MemLeakDetector.start(igoreLine)
  if debug.gethook() then
    SC_MemLeakDetector.SC_StopRecordAllocAndDumpStat()
    return
  end
  memStat = {}
  currentMem = collectgarbage("count")
  statLine = not igoreLine
  debug.sethook(RecordAlloc, "l")
end

function SC_MemLeakDetector.stop(filename)
  debug.sethook()
  if not memStat then
    return
  end
  local sorted = {}
  for k, v in pairs(memStat) do
    table.insert(sorted, v)
  end
  table.sort(sorted, function(a, b)
    return a[3] > b[3]
  end)
  filename = filename or "memAlloc.csv"
  local file = io.open(filename, "w")
  if not file then
    logw.error("can't open file:", filename)
    return
  end
  file:write("fileLine, count, mem K, avg K\n")
  for k, v in ipairs(sorted) do
    file:write(string.format("%s, %d, %f, %f\n", v[1], v[2], v[3], v[3] / v[2]))
  end
  file:close()
  memStat = nil
end

return SC_MemLeakDetector
