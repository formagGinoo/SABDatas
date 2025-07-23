local BaseManager = require("Manager/Base/BaseManager")
local ModuleManager = class("ModuleManager", BaseManager)
local pairs = _ENV.pairs
local ipairs = _ENV.ipairs
local OtherModuleName = "OtherModule"
local ModuleMustPanelCfg = {
  MainModule = {
    UIDefines.ID_FORM_HALL
  },
  MailModule = {
    UIDefines.ID_FORM_EMAIL
  },
  CardModule = {
    UIDefines.ID_FORM_TEAM,
    UIDefines.ID_FORM_TEAMHEROLIST
  },
  BagModule = {
    UIDefines.ID_FORM_BAG
  },
  LevelModule = {
    UIDefines.ID_FORM_STAGESELECT_NEW
  },
  HeroModule = {
    UIDefines.ID_FORM_HERODETAIL,
    UIDefines.ID_FORM_HEROLIST,
    UIDefines.ID_FORM_HEROCHECK,
    UIDefines.ID_FORM_HEROUPGRADE,
    UIDefines.ID_FORM_HEROEQUIPREPLACEPOP,
    UIDefines.ID_FORM_HEROSHOW,
    UIDefines.ID_FORM_ATTRACTMAIN2,
    UIDefines.ID_FORM_ATTRACTLEVELUP,
    UIDefines.ID_FORM_ATTRACTBOOK2,
    UIDefines.ID_FORM_HEROPREVIEW
  },
  CastleModule = {
    UIDefines.ID_FORM_CASTLEMAIN,
    UIDefines.ID_FORM_CASTLEMAINLOCK
  },
  BossModule = {
    UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE,
    UIDefines.ID_FORM_EQUIPMENTCOPYMAIN,
    UIDefines.ID_FORM_BOSSSHOW
  }
}

function ModuleManager:OnCreate()
  self.m_vActiveModule = {}
  self.m_PanelMustModuleConfig = {}
  self:ProcessModuleMustPanelCfg()
end

function ModuleManager:OnInitNetwork()
end

function ModuleManager:OnUpdate(dt)
end

function ModuleManager:ProcessModuleMustPanelCfg()
  for moduleKeyName, uidList in pairs(ModuleMustPanelCfg) do
    if uidList then
      for _, uid in ipairs(uidList) do
        if not self.m_PanelMustModuleConfig[uid] then
          self.m_PanelMustModuleConfig[uid] = moduleKeyName
        else
          log.warn("ModuleManager ProcessModuleMustPanelCfg 存在重复的FormID 检查 ModuleMustPanelCfg配置")
        end
      end
    end
  end
end

function ModuleManager:GetMustModuleNameByUID(uid)
  if not uid then
    return
  end
  return self.m_PanelMustModuleConfig[uid]
end

function ModuleManager:AddModuleInActive(moduleName)
  if not moduleName then
    return
  end
  local tempModule = self:GetActiveModuleByName(moduleName)
  if tempModule then
    return tempModule
  end
  tempModule = require("Module/" .. moduleName)
  if not tempModule then
    log.error("ModuleManager AddModuleInActive moduleName require fail")
    return
  end
  local curModule = tempModule.new()
  self.m_vActiveModule[#self.m_vActiveModule + 1] = curModule
  return curModule
end

function ModuleManager:IsModuleActive(moduleName)
  if not moduleName then
    return
  end
  for _, v in ipairs(self.m_vActiveModule) do
    if v:getName() == moduleName then
      return true
    end
  end
  return false
end

function ModuleManager:GetActiveModuleByName(moduleName)
  if not moduleName then
    return
  end
  for _, v in ipairs(self.m_vActiveModule) do
    if v:getName() == moduleName then
      return v
    end
  end
  return nil
end

function ModuleManager:GetModuleByName(moduleName)
  if not moduleName then
    return
  end
  local tempModule = self:GetActiveModuleByName(moduleName)
  tempModule = tempModule or self:AddModuleInActive(moduleName)
  return tempModule
end

function ModuleManager:ShowUI(uid, param, uiStack)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  local moduleName = self:GetMustModuleNameByUID(uid)
  moduleName = moduleName or OtherModuleName
  local tempModule = self:GetActiveModuleByName(moduleName)
  tempModule = tempModule or self:AddModuleInActive(moduleName)
  tempModule:PushUIByMgr(uid, param, uiStack)
end

function ModuleManager:HideUIFormStack(uid, uiStack)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  local moduleName = self:GetMustModuleNameByUID(uid)
  moduleName = moduleName or OtherModuleName
  local tempModule = self:GetActiveModuleByName(moduleName)
  if not tempModule then
    return
  end
  tempModule:HideUIFormStackByMgr(uid, uiStack)
end

function ModuleManager:DestroyUIByModuleMgr(uid, uiStack)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  local moduleName = self:GetMustModuleNameByUID(uid)
  moduleName = moduleName or OtherModuleName
  local tempModule = self:GetActiveModuleByName(moduleName)
  if not tempModule then
    return
  end
  tempModule:DestroyUIByModuleMgr(uid, uiStack)
end

function ModuleManager:AfterInitUI(uid, uiStack, panelLuaCom)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  local moduleName = self:GetMustModuleNameByUID(uid)
  moduleName = moduleName or OtherModuleName
  local tempModule = self:GetActiveModuleByName(moduleName)
  tempModule = tempModule or self:AddModuleInActive(moduleName)
  tempModule:AfterInitUI(uid, uiStack, panelLuaCom)
end

function ModuleManager:RemoveModuleByName(moduleName)
  if not moduleName then
    return
  end
  local tempModule = self:GetActiveModuleByName(moduleName)
  if not tempModule then
    return
  end
  tempModule:dispose()
end

return ModuleManager
