local Form_LegacyActivityGuide = class("Form_LegacyActivityGuide", require("UI/UIFrames/Form_LegacyActivityGuideUI"))

function Form_LegacyActivityGuide:SetInitParam(param)
end

function Form_LegacyActivityGuide:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1168)
  self.m_legacyGuideDataList = LegacyLevelManager:GetLegacyGuideDataList()
  self.m_legacyGuideItemList = nil
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnLegacyClk(itemIndex)
    end
  }
  self.m_luaLegacyInfinityGrid = self:CreateInfinityGrid(self.m_legacy_guide_list_InfinityGrid, "LegacyActivity/UILegacyLevelGuideItem", initGridData)
  self.m_legacyCfgList = nil
end

function Form_LegacyActivityGuide:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(168)
end

function Form_LegacyActivityGuide:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_LegacyActivityGuide:OnUncoverd()
  self:FreshUI(false)
end

function Form_LegacyActivityGuide:OnOpen()
  self:FreshUI(true)
end

function Form_LegacyActivityGuide:OnDestroy()
  self.super.OnDestroy(self)
  for i = 1, self.m_itemInitShowNum do
    if self["ItemInitTimer" .. i] then
      TimeService:KillTimer(self["ItemInitTimer" .. i])
      self["ItemInitTimer" .. i] = nil
    end
  end
end

function Form_LegacyActivityGuide:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_csui.m_param = nil
  end
  self:FreshLegacyItemListData()
end

function Form_LegacyActivityGuide:ClearCacheData()
  self.m_legacyGuideItemList = nil
end

function Form_LegacyActivityGuide:FreshLegacyItemListData()
  self.m_legacyGuideItemList = {}
  if not self.m_legacyGuideDataList then
    return
  end
  for _, legacyGuideData in ipairs(self.m_legacyGuideDataList) do
    local tempLegacyItemData = {
      legacyGuideData = legacyGuideData,
      isHave = LegacyManager:GetLegacyDataByID(legacyGuideData.legacyCfg.m_ID) ~= nil
    }
    self.m_legacyGuideItemList[#self.m_legacyGuideItemList + 1] = tempLegacyItemData
  end
end

function Form_LegacyActivityGuide:GetLegacyOpenCfgListAndIndex(legacyGuideItemData)
  if not self.m_legacyGuideItemList then
    return
  end
  local tempLegacyID = legacyGuideItemData.legacyGuideData.legacyCfg.m_ID
  local legacyCfgList = {}
  local chooseIndex
  for index, tempLegacyGuideItemData in ipairs(self.m_legacyGuideItemList) do
    if tempLegacyGuideItemData.isHave then
      local tempLegacyCfg = tempLegacyGuideItemData.legacyGuideData.legacyCfg
      legacyCfgList[#legacyCfgList + 1] = tempLegacyCfg
      if tempLegacyCfg.m_ID == tempLegacyID then
        chooseIndex = index
      end
    end
  end
  return legacyCfgList, chooseIndex
end

function Form_LegacyActivityGuide:AddEventListeners()
end

function Form_LegacyActivityGuide:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LegacyActivityGuide:FreshUI(isMoveInit)
  if not self.m_legacyGuideItemList then
    return
  end
  self.m_luaLegacyInfinityGrid:ShowItemList(self.m_legacyGuideItemList, true)
  if isMoveInit then
    self.m_luaLegacyInfinityGrid:LocateTo()
  end
  self:CheckShowEnterAnim()
end

function Form_LegacyActivityGuide:CheckShowEnterAnim()
  local showLuaInfinityGrid = self.m_luaLegacyInfinityGrid
  local showItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempHeroItem in ipairs(showItemList) do
    local tempObj = tempHeroItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
  end
  TimeService:SetTimer(self.m_uiVariables.ItemListDelayTime, 1, function()
    self:ShowItemListAnim()
  end)
end

function Form_LegacyActivityGuide:ShowItemListAnim()
  local itemDeltaTime = self.m_uiVariables.ItemDeltaTime
  local showLuaInfinityGrid = self.m_luaLegacyInfinityGrid
  local showItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    if i == 1 then
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      tempItem:PlayAnim()
    else
      do
        local leftIndex = i - 1
        self["ItemInitTimer" .. i] = TimeService:SetTimer(leftIndex * itemDeltaTime, 1, function()
          UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
          tempItem:PlayAnim()
        end)
      end
    end
  end
end

function Form_LegacyActivityGuide:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_LegacyActivityGuide:OnLegacyClk(i)
  local legacyGuideItemData = self.m_legacyGuideItemList[i]
  if not legacyGuideItemData then
    return
  end
  local legacyOpenCfgList, chooseIndex = self:GetLegacyOpenCfgListAndIndex(legacyGuideItemData)
  if not legacyOpenCfgList then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_LEGACYUSERINFO, {legacyCfgList = legacyOpenCfgList, legacyIndex = chooseIndex})
end

function Form_LegacyActivityGuide:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_LegacyActivityGuide", Form_LegacyActivityGuide)
return Form_LegacyActivityGuide
