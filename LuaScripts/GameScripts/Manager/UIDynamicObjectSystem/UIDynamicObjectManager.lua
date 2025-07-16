local BaseManager = require("Manager/Base/BaseManager")
local UIDynamicObjectManager = class("UIDynamicObjectManager", BaseManager)
UIDynamicObjectManager.CustomLoaderType = {Spine = 1}
UIDynamicObjectManager.CustomLoaderCfg = {
  [UIDynamicObjectManager.CustomLoaderType.Spine] = {
    luaPath = "Manager/UIDynamicObjectSystem/HeroSpineDynamicLoader"
  }
}

function UIDynamicObjectManager:OnCreate()
  self.m_customLoaderTab = {}
  for _, type in pairs(UIDynamicObjectManager.CustomLoaderType) do
    local tempCfg = UIDynamicObjectManager.CustomLoaderCfg[type]
    if tempCfg then
      local loaderCom = require(tempCfg.luaPath).new()
      self.m_customLoaderTab[type] = loaderCom
    end
  end
end

function UIDynamicObjectManager:OnUpdate(dt)
end

function UIDynamicObjectManager:GetCustomLoaderByType(customLoaderType)
  if not customLoaderType then
    return
  end
  if not self.m_customLoaderTab then
    return
  end
  local tempCustomLoader = self.m_customLoaderTab[customLoaderType]
  return tempCustomLoader
end

function UIDynamicObjectManager:GetObjectByName(prefabStr, sucBackFun)
  if not prefabStr then
    return
  end
  if not sucBackFun then
    return
  end
  UIMultiTypeObjectPoolManager:GetObject(prefabStr, function(nameStr, loadObj)
    if sucBackFun then
      sucBackFun(nameStr, loadObj)
    end
  end, function(errorStr)
    log.error("UIMultiTypeObjectPoolManager GetObjectByName Fail ErrorStr: " .. errorStr)
  end)
end

function UIDynamicObjectManager:RecycleObjectByName(prefabStr, object)
  if not prefabStr then
    return
  end
  if not object then
    return
  end
  UIMultiTypeObjectPoolManager:RecycleObject(prefabStr, object)
end

function UIDynamicObjectManager:ClearPoolByPrefabStr(prefabStr)
  if not prefabStr then
    return
  end
  UIMultiTypeObjectPoolManager:ClearPoolByPrefabStr(prefabStr)
end

function UIDynamicObjectManager:ClearAllPoolObjects()
  UIMultiTypeObjectPoolManager:ClearAllPoolObjects()
end

return UIDynamicObjectManager
