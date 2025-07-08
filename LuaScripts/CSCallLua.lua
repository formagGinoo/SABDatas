function CSCallLuaInit()
  CS.UI.UIBase.SetLuaBinder(BindLuaUI)
end

local function ClearAllJobGraph()
  if __JobGraphs == nil then
    return
  end
  for _, v in pairs(__JobGraphs) do
    v:Dispose()
  end
end

function CSCallLuaReset()
  CS.UI.UISystem.Instance:ClearLuaDelegate()
  CS.UI.UIBase.SetLuaBinder(nil)
  ClearAllJobGraph()
end

function CSCallLuaTest()
  log.info("CSCallLuaTest........................................")
end
