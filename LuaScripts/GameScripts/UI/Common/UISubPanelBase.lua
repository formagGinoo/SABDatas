local BaseNode = require("Base/BaseNode")
local UISubPanelBase = class("UISubPanelBase", BaseNode)

function UISubPanelBase:Init(parentObj, subPanelObj, parentLua, initData, panelData, panelStr)
  self.m_parentObj = parentObj
  self.m_rootObj = subPanelObj
  self.m_parentLua = parentLua
  self.m_initData = initData
  self.m_panelStr = panelStr
  self.m_redDotItemList = {}
  self.m_subPanelList = nil
  self.m_uiVariables = nil
  local uiVariableCom = self.m_rootObj:GetComponent("UIVariable")
  if uiVariableCom then
    self.m_uiVariables = {}
    UILuaHelper.GetUIVariablesToLuaTable(self.m_rootObj, self.m_uiVariables)
  end
  self:InitSubUI()
  self:FreshData(panelData)
end

function UISubPanelBase:InitSubUI()
  if not self.m_rootObj then
    return
  end
  if self.m_parentObj == nil then
    self.m_parentObj = self.m_rootObj.transform.parent
  else
    UILuaHelper.SetParent(self.m_rootObj, self.m_parentObj, true)
  end
  UILuaHelper.BindViewObjectsManual(self, self.m_rootObj, self:getName())
  UILuaHelper.FreshViewMultiLanguage(self.m_rootObj)
  if KeyboardMappingManager then
    KeyboardMappingManager:AddSubConfig(self.m_parentLua:getName(), self.m_rootObj.name, self, true)
  end
  self:doEvent("OnInit")
end

function UISubPanelBase:FreshData(panelData)
  self.m_panelData = panelData
  self:doEvent("OnFreshData")
end

function UISubPanelBase:dispose()
  UISubPanelBase.super.dispose(self)
end

function UISubPanelBase:OnDestroy()
  self:UnRegisterAllRedDotItem()
  self:RemoveAllSubPanel()
  UILuaHelper.UnbindViewObjectsManual(self, self.m_rootObj, self:getName())
  GameObject.Destroy(self.m_rootObj)
  SubPanelManager:CheckUnloadAsset(self.m_panelStr)
  self.m_parentObj = nil
  self.m_rootObj = nil
  self.m_parentLua = nil
end

function UISubPanelBase:SetActive(isActive)
  if self.m_rootObj then
    self.m_rootObj:SetActive(isActive)
  end
  if KeyboardMappingManager then
    if isActive then
      KeyboardMappingManager:AddSubConfig(self.m_parentLua:getName(), self.m_rootObj.name, self, true)
    else
      KeyboardMappingManager:RemoveSubConfig(self.m_parentLua:getName(), self.m_rootObj.name)
    end
  end
end

function UISubPanelBase:RegisterOrUpdateRedDotItem(redDotNodeTrans, redDotType, param)
  local tempRedDotItem
  for _, redDotItem in ipairs(self.m_redDotItemList) do
    if redDotItem and redDotItem:GetRedDotTrans() ~= nil and redDotItem:GetRedDotTrans() == redDotNodeTrans then
      tempRedDotItem = redDotItem
    end
  end
  if tempRedDotItem then
    self:FreshRedDotItemData(redDotNodeTrans, redDotType, param)
  else
    self:RegisterRedDotItem(redDotNodeTrans, redDotType, param)
  end
end

function UISubPanelBase:FreshRedDotItemData(redDotNodeTrans, redDotType, param)
  if not redDotType then
    return
  end
  if not self.m_redDotItemList then
    return
  end
  if not next(self.m_redDotItemList) then
    return
  end
  for _, redDotItem in ipairs(self.m_redDotItemList) do
    if redDotItem:GetRedDotTrans() == redDotNodeTrans then
      redDotItem:FreshData(redDotType, param)
    end
  end
end

function UISubPanelBase:RegisterRedDotItem(redDotTrans, redDotType, param)
  if not redDotTrans then
    return
  end
  local retDotItem = RedDotManager:RegisterRedDotItem(redDotTrans, redDotType, param)
  if retDotItem then
    self.m_redDotItemList[#self.m_redDotItemList + 1] = retDotItem
  end
  return retDotItem
end

function UISubPanelBase:UnRegisterAllRedDotItem()
  if not self.m_redDotItemList then
    return
  end
  if not next(self.m_redDotItemList) then
    return
  end
  for _, redDotItem in ipairs(self.m_redDotItemList) do
    RedDotManager:UnRegisterRedDotItem(redDotItem)
  end
  self.m_redDotItemList = {}
end

function UISubPanelBase:CreateSubPanel(subPanelName, gameObj, parentLua, initData, paramData, loadBack)
  if not self.m_subPanelList then
    self.m_subPanelList = {}
  end
  if not SubPanelManager then
    return
  end
  if loadBack then
    SubPanelManager:LoadSubPanel(subPanelName, gameObj, parentLua, initData, paramData, function(subPanelLua)
      self.m_subPanelList[#self.m_subPanelList + 1] = subPanelLua
      loadBack(subPanelLua)
    end)
  else
    local subPanelLua = SubPanelManager:LoadSubPanelWithPanelRoot(subPanelName, gameObj, parentLua, initData, paramData)
    self.m_subPanelList[#self.m_subPanelList + 1] = subPanelLua
    return subPanelLua
  end
end

function UISubPanelBase:RemoveSubPanel(subPanelLua)
  if not subPanelLua then
    return
  end
  if not self.m_subPanelList then
    return
  end
  if not next(self.m_subPanelList) then
    return
  end
  for i, v in ipairs(self.m_subPanelList) do
    if v == subPanelLua then
      v:dispose()
      table.remove(self.m_subPanelList, i)
    end
  end
end

function UISubPanelBase:RemoveAllSubPanel()
  if not self.m_subPanelList then
    return
  end
  if not next(self.m_subPanelList) then
    return
  end
  for _, v in ipairs(self.m_subPanelList) do
    v:dispose()
  end
  self.m_subPanelList = nil
end

function UISubPanelBase:addActionLongPress(pressBtn, action1, action2)
  if pressBtn then
    local changAn_btn = pressBtn:GetComponent("LongPress")
    if changAn_btn then
      changAn_btn:RegistButtonClick(action1, action2)
    end
  end
end

function UISubPanelBase:addTrigger(luaBehaviour, name, action1, action2)
  if luaBehaviour then
    luaBehaviour:AddTrigger(name, UIUtil.Get_EventTriggerType("PointerDown"), action1)
    luaBehaviour:AddTrigger(name, UIUtil.Get_EventTriggerType("PointerUp"), action2)
  end
end

function UISubPanelBase:addTriggerEnter(luaBehaviour, name, action1, action2)
  if luaBehaviour then
    luaBehaviour:AddTrigger(name, UIUtil.Get_EventTriggerType("PointerEnter"), action1)
    luaBehaviour:AddTrigger(name, UIUtil.Get_EventTriggerType("PointerExit"), action2)
  end
end

function UISubPanelBase:GetDownloadResourceExtra()
  return nil, nil
end

return UISubPanelBase
