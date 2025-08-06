require("common/functions")
local BaseNode = require("Base/BaseNode")
local UIBase = class("UIBase", BaseNode)

function UIBase:Push(uiid)
  self.m_csui:Push(uiid)
end

function UIBase:AfterInit()
  self.m_ownerModule = nil
  local moduleManager = ModuleManager
  if moduleManager then
    moduleManager:AfterInitUI(self:GetID(), self:OwnerStack(), self)
  end
  self.m_redDotItemList = {}
  self.m_systemOpenTime = 0
  self.m_subPanelList = nil
  self:CheckCreateVariable(self.m_csui)
end

function UIBase:OnOpen()
end

function UIBase:OnActive()
  if self.m_ownerModule then
    self.m_ownerModule:OnActiveUI(self:GetID(), self:OwnerStack())
  end
end

function UIBase:OnActiveEx()
  if self.m_ownerModule and GlobalConfig.REPORT_SYSTEM_ID_MAP[self:GetID()] then
    self.m_systemOpenTime = TimeUtil:GetServerTimeS()
    ReportManager:ReportSystemOpen(GlobalConfig.REPORT_SYSTEM_ID_MAP[self:GetID()], self.m_systemOpenTime)
  end
  if KeyboardMappingManager then
    KeyboardMappingManager:SetActiveConfig(self:GetFramePrefabName(), self, true)
  end
end

function UIBase:OnInactive()
  if self.m_ownerModule then
    self.m_ownerModule:OnInActiveUI(self:GetID(), self:OwnerStack())
  end
end

function UIBase:OnInactiveEx()
  if self.m_ownerModule and GlobalConfig.REPORT_SYSTEM_ID_MAP[self:GetID()] then
    ReportManager:ReportSystemClose(GlobalConfig.REPORT_SYSTEM_ID_MAP[self:GetID()], self.m_systemOpenTime)
  end
  if KeyboardMappingManager then
    KeyboardMappingManager:DeActiveConfig(self:GetFramePrefabName())
  end
end

function UIBase:OnDestroy()
  if self.m_ownerModule then
    self.m_ownerModule:OnDestroyUI(self:GetID(), self:OwnerStack())
  end
  self:UnRegisterAllRedDotItem()
  self:RemoveAllSubPanel()
  self.m_systemOpenTime = nil
end

function UIBase:SetRegisterInModule(moduleTab)
  self.m_ownerModule = moduleTab
end

function UIBase:RemoveRegisterInModule()
  self.m_ownerModule = nil
end

function UIBase:CheckCreateVariable(csUI)
  if not csUI then
    return
  end
  if self.m_uiVariables then
    return
  end
  self.m_uiVariables = nil
  local tempRootTrans = csUI.m_uiGameObject.transform
  local uiVariableCom = tempRootTrans:GetComponent("UIVariable")
  if uiVariableCom then
    self.m_uiVariables = {}
    UILuaHelper.GetUIVariablesToLuaTable(tempRootTrans, self.m_uiVariables)
  end
end

function UIBase:RegisterOrUpdateRedDotItem(redDotNodeTrans, redDotType, param)
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

function UIBase:FreshRedDotItemData(redDotNodeTrans, redDotType, param)
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

function UIBase:RegisterRedDotItem(redDotTrans, redDotType, param)
  if not redDotTrans then
    return
  end
  local retDotItem = RedDotManager:RegisterRedDotItem(redDotTrans, redDotType, param)
  if retDotItem then
    self.m_redDotItemList[#self.m_redDotItemList + 1] = retDotItem
  end
  return retDotItem
end

function UIBase:UnRegisterAllRedDotItem()
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

function UIBase:CreateSubPanel(subPanelName, gameObj, parentLua, initData, paramData, loadBack)
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

function UIBase:RemoveSubPanel(subPanelLua)
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

function UIBase:RemoveAllSubPanel()
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

function UIBase:addActionLongPress(pressBtn, action1, action2)
  if pressBtn then
    local changAn_btn = pressBtn:GetComponent("LongPress")
    if changAn_btn then
      changAn_btn:RegistButtonClick(action1, action2)
    end
  end
end

function UIBase:addTrigger(luaBehaviour, name, action1, action2)
  if luaBehaviour then
    luaBehaviour:AddTrigger(name, UIUtil.Get_EventTriggerType("PointerDown"), action1)
    luaBehaviour:AddTrigger(name, UIUtil.Get_EventTriggerType("PointerUp"), action2)
  end
end

function UIBase:addTriggerEnter(luaBehaviour, name, action1, action2)
  if luaBehaviour then
    luaBehaviour:AddTrigger(name, UIUtil.Get_EventTriggerType("PointerEnter"), action1)
    luaBehaviour:AddTrigger(name, UIUtil.Get_EventTriggerType("PointerExit"), action2)
  end
end

function UIBase:Pop()
  self.m_csui:Pop()
end

function UIBase:Replace(uiid)
  self.m_csui:Replace(uiid)
end

function UIBase:OnDefaultBack()
  self:Pop()
end

function UIBase:OwnerStack()
  return self.m_csui.OwnerStack
end

function UIBase:IsActive()
  return self.m_csui.IsActive
end

function UIBase:IsFullScreen()
  return false
end

function UIBase:IsOpenGuassianBlur()
  return false
end

function UIBase:Dock(uiid, parent)
  self.m_csui:Dock(uiid, parent)
end

function UIBase:BindCallback(btn, callback)
  self.m_csui:BindCallback(btn, callback)
end

function UIBase:UnBindCallback(btn)
  self.m_csui:UnBindCallback(btn)
end

function UIBase:GetSpriteCamp()
  return self.m_csui:GetSpriteCamp()
end

function UIBase:CloseForm()
  self:OwnerStack():RemoveUIFromStack(self:GetID())
end

function UIBase:DestroyForm()
  self:OwnerStack():DestroyUI(self:GetID())
end

function UIBase:DestroyBigSystemUIImmediately()
  if CS.GameQualityManager.DestroyBigSystemUIImmediately then
    self:DestroyForm()
  end
end

function UIBase:SetConsistentActive(isConsistentActive)
  self.m_csui.IsConsistentActive = isConsistentActive
end

function UIBase:OnPlayerCancelDownload()
end

function UIBase:DownloadResource(tParam, fCompleteCB)
  if DownloadManager == nil then
    if fCompleteCB then
      fCompleteCB()
    end
    return
  end
  if self:GetFramePrefabName() == "Form_DownloadTips" then
    if fCompleteCB then
      fCompleteCB()
    end
    return
  end
  local vPackage = {
    {
      sName = self:GetFramePrefabName(),
      eType = DownloadManager.ResourcePackageType.UI
    }
  }
  local vPackageExtra, vResourceExtra = self:GetDownloadResourceExtra(tParam)
  if vPackageExtra ~= nil then
    for _, v in ipairs(vPackageExtra) do
      table.insert(vPackage, v)
    end
  end
  
  local function OnDownloadComplete(ret)
    log.info(string.format("Download UI %s Complete: %s", self:GetFramePrefabName(), tostring(ret)))
    if fCompleteCB then
      fCompleteCB()
    end
  end
  
  DownloadManager:DownloadResourceWithUI(vPackage, vResourceExtra, "UI_" .. self:GetFramePrefabName(), nil, nil, OnDownloadComplete, nil, self:GetDownloadResourceNetworkStatus(), nil, nil, handler(self, self.OnPlayerCancelDownload))
end

function UIBase:GetDownloadResourceExtra(tParam)
  return nil, nil
end

function UIBase:GetDownloadResourceNetworkStatus()
  return DownloadManager.NetworkStatus.Wifi
end

function UIBase:OnBtnCloseClicked()
  self:CloseForm()
end

function UIBase:OnBtnReturnClicked()
  self:CloseForm()
end

function UIBase:GoBackFormHall()
  local luaIns = StackFlow:GetUIInstanceLua(UIDefines.ID_FORM_HALL)
  if not (luaIns and luaIns.m_csui) or not luaIns.m_csui.m_uiGameObject then
    if BattleFlowManager:IsInBattle() == true then
      BattleFlowManager:FromBattleToHall()
    else
      StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    end
  end
end

return UIBase
