local Form_LegacyActivityChangePop = class("Form_LegacyActivityChangePop", require("UI/UIFrames/Form_LegacyActivityChangePopUI"))
local ChangeType = {
  Replace = 1,
  Add = 2,
  Reduce = 3
}

function Form_LegacyActivityChangePop:SetInitParam(param)
end

function Form_LegacyActivityChangePop:AfterInit()
  self.super.AfterInit(self)
  self.m_curLegacyData = nil
  self.m_chooseHeroIDList = {}
  self.m_showChangeLegacyList = nil
  self.m_luaChangePopListInfinityGrid = self:CreateInfinityGrid(self.m_list_InfinityGrid, "LegacyActivity/UILegacyChangePopItem")
end

function Form_LegacyActivityChangePop:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(35)
end

function Form_LegacyActivityChangePop:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_LegacyActivityChangePop:OnDestroy()
  self.super.OnDestroy(self)
  for i = 1, self.m_itemInitShowNum do
    if self["ItemInitTimer" .. i] then
      TimeService:KillTimer(self["ItemInitTimer" .. i])
      self["ItemInitTimer" .. i] = nil
    end
  end
end

function Form_LegacyActivityChangePop:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curLegacyData = tParam.legacyData
    self.m_chooseHeroIDList = tParam.chooseHeroIDList
    self.m_csui.m_param = nil
  end
  self:FreshLegacyChangeDataList()
  self:SortLegacyChangeDataList()
end

function Form_LegacyActivityChangePop:ClearCacheData()
end

function Form_LegacyActivityChangePop:FreshLegacyChangeDataList()
  if not self.m_curLegacyData then
    return
  end
  if not self.m_chooseHeroIDList then
    return
  end
  local lastChooseHeroIDList = self.m_curLegacyData.serverData.vEquipBy
  local curChooseHeroIDList = self.m_chooseHeroIDList
  local showChangeLegacyList = {}
  for _, lastHeroID in ipairs(lastChooseHeroIDList) do
    local isReduce = true
    for _, curHeroID in ipairs(curChooseHeroIDList) do
      if curHeroID == lastHeroID then
        isReduce = false
        break
      end
    end
    if isReduce then
      local tempHeroData = HeroManager:GetHeroDataByID(lastHeroID)
      if tempHeroData then
        local tempChangeLegacyData = {
          heroData = tempHeroData,
          beforeLegacyData = self.m_curLegacyData,
          afterLegacyData = nil,
          changeType = ChangeType.Reduce
        }
        showChangeLegacyList[#showChangeLegacyList + 1] = tempChangeLegacyData
      end
    end
  end
  for _, curHeroID in ipairs(curChooseHeroIDList) do
    local isAdd = true
    for _, lastHeroID in ipairs(lastChooseHeroIDList) do
      if curHeroID == lastHeroID then
        isAdd = false
        break
      end
    end
    if isAdd then
      local tempHeroData = HeroManager:GetHeroDataByID(curHeroID)
      if tempHeroData then
        local legacyTab = tempHeroData.serverData.stLegacy or {}
        local beforeLegacyID = legacyTab.iLegacyId
        local beforeLegacyData = LegacyManager:GetLegacyDataByID(beforeLegacyID)
        local changeType = beforeLegacyData == nil and ChangeType.Add or ChangeType.Replace
        local tempChangeLegacyData = {
          heroData = tempHeroData,
          beforeLegacyData = beforeLegacyData,
          afterLegacyData = self.m_curLegacyData,
          changeType = changeType
        }
        showChangeLegacyList[#showChangeLegacyList + 1] = tempChangeLegacyData
      end
    end
  end
  self.m_showChangeLegacyList = showChangeLegacyList
end

function Form_LegacyActivityChangePop:SortLegacyChangeDataList()
  if not self.m_showChangeLegacyList then
    return
  end
  if #self.m_showChangeLegacyList <= 1 then
    return
  end
  table.sort(self.m_showChangeLegacyList, function(a, b)
    if a.changeType ~= b.changeType then
      return a.changeType < b.changeType
    else
      return a.heroData.serverData.iHeroId > b.heroData.serverData.iHeroId
    end
  end)
end

function Form_LegacyActivityChangePop:AddEventListeners()
  self:addEventListener("eGameEvent_Legacy_InstallBatch", handler(self, self.OnInstallBatchBack))
end

function Form_LegacyActivityChangePop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LegacyActivityChangePop:OnInstallBatchBack(param)
  if not param then
    return
  end
  local legacyID = param.legacyID
  if legacyID == self.m_curLegacyData.serverData.iLegacyId then
    local showStr = ConfigManager:GetCommonTextById(100507)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, showStr)
    self:CloseForm()
  end
end

function Form_LegacyActivityChangePop:FreshUI()
  if not self.m_curLegacyData then
    return
  end
  self.m_luaChangePopListInfinityGrid:ShowItemList(self.m_showChangeLegacyList, true)
  self:CheckShowEnterAnim()
end

function Form_LegacyActivityChangePop:CheckShowEnterAnim()
  local showLuaInfinityGrid = self.m_luaChangePopListInfinityGrid
  local showItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
  end
  TimeService:SetTimer(self.m_uiVariables.ItemListDelayTime, 1, function()
    self:ShowItemListAnim()
  end)
end

function Form_LegacyActivityChangePop:ShowItemListAnim()
  local itemAnimStr = self.m_uiVariables.ItemAnimStr
  local itemDeltaTime = self.m_uiVariables.ItemDeltaTime
  local showLuaInfinityGrid = self.m_luaChangePopListInfinityGrid
  local showItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    if i == 1 then
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, itemAnimStr)
    else
      do
        local leftIndex = i - 1
        self["ItemInitTimer" .. i] = TimeService:SetTimer(leftIndex * itemDeltaTime, 1, function()
          UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
          UILuaHelper.PlayAnimationByName(tempObj, itemAnimStr)
        end)
      end
    end
  end
end

function Form_LegacyActivityChangePop:OnBtnCloseClicked()
  self:CloseForm()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(31)
end

function Form_LegacyActivityChangePop:OnBtnReturnClicked()
  self:CloseForm()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(31)
end

function Form_LegacyActivityChangePop:OnBtnyesClicked()
  if not self.m_curLegacyData then
    return
  end
  if not next(self.m_showChangeLegacyList) then
    return
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(36)
  LegacyManager:ReqLegacyInstallBatch(self.m_chooseHeroIDList, self.m_curLegacyData.serverData.iLegacyId)
end

local fullscreen = true
ActiveLuaUI("Form_LegacyActivityChangePop", Form_LegacyActivityChangePop)
return Form_LegacyActivityChangePop
