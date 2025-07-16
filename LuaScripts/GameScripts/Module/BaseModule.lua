local BaseObject = require("Base/BaseObject")
local BaseModule = class("BaseModule", BaseObject)
local ipairs = _ENV.ipairs
local table_Remove = table.remove

function BaseModule:ctor(...)
  BaseModule.super.ctor(self, ...)
  self.m_vSubPanel = {}
  self.m_bVisible = true
  self:initComponent()
end

function BaseModule:initComponent()
  BaseModule.super.initComponent(self)
  self:addComponent("GameEvent")
end

function BaseModule:viewUpdate(dt, times)
end

function BaseModule:reset(...)
  self:doEvent("onReset", ...)
end

function BaseModule:IsPanelHaveShow(uid, uiStack)
  uiStack = uiStack or StackFlow
  for _, v in ipairs(self.m_vSubPanel) do
    if v.uid == uid and v.uiStack == uiStack then
      return true
    end
  end
  return false
end

function BaseModule:PushUIByMgr(uid, param, uiStack)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  uiStack:Push(uid, param)
  self:doEvent("onPushUI", uid, uiStack)
end

function BaseModule:AfterInitUI(uid, uiStack, panelLuaCom)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  local isHavePanel = self:IsPanelHaveShow(uid, uiStack)
  if isHavePanel then
    for _, v in ipairs(self.m_vSubPanel) do
      if v.uid == uid and v.uiStack == uiStack then
        v.panelCom = panelLuaCom
      end
    end
  else
    local panelTempData = {
      uid = uid,
      uiStack = uiStack,
      panelCom = panelLuaCom
    }
    self.m_vSubPanel[#self.m_vSubPanel + 1] = panelTempData
  end
  panelLuaCom:SetRegisterInModule(self)
  self:doEvent("onAfterInitUI", uid, uiStack)
end

function BaseModule:OnActiveUI(uid, uiStack)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  for _, v in ipairs(self.m_vSubPanel) do
    if v.uid == uid and v.uiStack == uiStack then
      self:doEvent("onActiveUI", uid, uiStack)
      break
    end
  end
end

function BaseModule:OnInActiveUI(uid, uiStack)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  for _, v in ipairs(self.m_vSubPanel) do
    if v.uid == uid and v.uiStack == uiStack then
      self:doEvent("onInActiveUI", uid, uiStack)
      break
    end
  end
end

function BaseModule:HideUIFormStackByMgr(uid, uiStack)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  for _, v in ipairs(self.m_vSubPanel) do
    if v.uid == uid and v.uiStack == uiStack then
      v.uiStack:RemoveUIFromStack(v.uid)
      break
    end
  end
end

function BaseModule:OnDestroyUI(uid, uiStack)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  for i, v in ipairs(self.m_vSubPanel) do
    if v.uid == uid and v.uiStack == uiStack then
      if v.panelCom then
        v.panelCom:RemoveRegisterInModule()
      end
      table_Remove(self.m_vSubPanel, i)
    end
  end
  self:doEvent("onDestroyUI", uid, uiStack)
end

function BaseModule:DestroyUIByModuleMgr(uid, uiStack)
  if not uid then
    return
  end
  uiStack = uiStack or StackFlow
  for i, v in ipairs(self.m_vSubPanel) do
    if v.uid == uid and v.uiStack == uiStack then
      v.uiStack:DestroyUI(v.uid)
      if v.panelCom then
        v.panelCom:RemoveRegisterInModule()
      end
      table_Remove(self.m_vSubPanel, i)
    end
  end
  self:doEvent("onDestroyUI", uid, uiStack)
end

function BaseModule:getTopPanel()
  local topPanel
  local panelCount = #self.m_vSubPanel
  if panelCount <= 0 then
    return
  end
  topPanel = self.m_vSubPanel[#self.m_vSubPanel].panelCom
  if not topPanel then
    return
  end
  return topPanel
end

function BaseModule:setVisible(bVisible)
  self.m_bVisible = bVisible
  for _, v in ipairs(self.m_vSubPanel) do
    if v.panelCom and v.panelCom.setVisible then
      v.panelCom:setVisible(bVisible)
    end
  end
  self:doEvent("onSetVisible", bVisible)
end

function BaseModule:isVisible()
  return self.m_bVisible
end

function BaseModule:clearAllSubPanel()
  if self.m_vSubPanel then
    for index = #self.m_vSubPanel, 1, -1 do
      local subPanelData = self.m_vSubPanel[index]
      if subPanelData and subPanelData.panelCom then
        local uiStack = subPanelData.uiStack
        local uid = subPanelData.uid
        uiStack:DestroyUI(uid)
      end
    end
  end
  self.m_vSubPanel = {}
end

function BaseModule:shutdown()
  self:dispose()
end

function BaseModule:dispose()
  if not self._disposed then
    self._disposed = true
    self:removeAllComponent()
    self:doEvent("onDestroyUI")
    self:clearAllSubPanel()
  end
end

function BaseObject:IsSubPanelEmpty()
  return #self.m_vSubPanel == 0
end

return BaseModule
