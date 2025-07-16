local Form_LegacyActivityCubePop = class("Form_LegacyActivityCubePop", require("UI/UIFrames/Form_LegacyActivityCubePopUI"))
local LegacyStageCharacterIns = ConfigManager:GetConfigInsByName("LegacyStageCharacter")

function Form_LegacyActivityCubePop:SetInitParam(param)
end

function Form_LegacyActivityCubePop:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnHeroIconClk(itemIndex)
    end
  }
  self.m_luaHeroInfinityGrid = self:CreateInfinityGrid(self.m_list_hero_InfinityGrid, "LegacyActivity/UILegacyLevelDetailHeroItem", initGridData)
  local initItemGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnItemClk(itemIndex)
    end
  }
  self.m_luaItemInfinityGrid = self:CreateInfinityGrid(self.m_list_item_InfinityGrid, "LegacyActivity/UILegacyRewardItem", initItemGridData)
  self.m_levelCfg = nil
  self.m_showHeroItemDataList = nil
  self.m_showRewardItemDataList = nil
  self.m_isHavePass = nil
end

function Form_LegacyActivityCubePop:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(35)
end

function Form_LegacyActivityCubePop:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_LegacyActivityCubePop:OnDestroy()
  self.super.OnDestroy(self)
  for i = 1, self.m_itemInitShowNum do
    if self["ItemInitTimer" .. i] then
      TimeService:KillTimer(self["ItemInitTimer" .. i])
      self["ItemInitTimer" .. i] = nil
    end
  end
  for i = 1, self.m_heroItemInitShowNum do
    if self["HeroItemInitTimer" .. i] then
      TimeService:KillTimer(self["HeroItemInitTimer" .. i])
      self["HeroItemInitTimer" .. i] = nil
    end
  end
end

function Form_LegacyActivityCubePop:FreshData()
  self.m_levelCfg = nil
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_levelCfg = tParam.levelCfg
    self.m_isHavePass = LegacyLevelManager:IsLevelHavePass(self.m_levelCfg.m_LevelID)
    self:FreshCharacterDataList()
    self:FreshRewardDataList()
    self.m_csui.m_param = nil
  end
end

function Form_LegacyActivityCubePop:ClearCacheData()
  self.m_levelCfg = nil
end

function Form_LegacyActivityCubePop:FreshCharacterDataList()
  if not self.m_levelCfg then
    return
  end
  self.m_showHeroItemDataList = {}
  local characterNumArray = self.m_levelCfg.m_CharacterID
  local arrayLen = characterNumArray.Length
  if arrayLen == 0 then
    return
  end
  for i = 1, arrayLen do
    local characterID = characterNumArray[i - 1]
    local tempChapterCfg = LegacyStageCharacterIns:GetValue_ByID(characterID)
    if tempChapterCfg and tempChapterCfg:GetError() ~= true then
      self.m_showHeroItemDataList[#self.m_showHeroItemDataList + 1] = tempChapterCfg
    end
  end
end

function Form_LegacyActivityCubePop:FreshRewardDataList()
  if not self.m_levelCfg then
    return
  end
  self.m_showRewardItemDataList = {}
  local rewardArray = self.m_levelCfg.m_LevelReward
  local rewardLen = rewardArray.Length
  if rewardLen <= 0 then
    return
  end
  for i = 1, rewardLen do
    local rewardNumArray = rewardArray[i - 1]
    local itemID = rewardNumArray[0]
    local itemNum = rewardNumArray[1]
    local tempReward = ResourceUtil:GetProcessRewardData({iID = itemID, iNum = itemNum})
    local itemData = {
      itemData = tempReward,
      isHaveGet = self.m_isHavePass
    }
    self.m_showRewardItemDataList[#self.m_showRewardItemDataList + 1] = itemData
  end
end

function Form_LegacyActivityCubePop:AddEventListeners()
end

function Form_LegacyActivityCubePop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LegacyActivityCubePop:FreshUI()
  if not self.m_levelCfg then
    return
  end
  self.m_luaHeroInfinityGrid:ShowItemList(self.m_showHeroItemDataList)
  self.m_luaHeroInfinityGrid:LocateTo()
  self.m_luaItemInfinityGrid:ShowItemList(self.m_showRewardItemDataList)
  self.m_luaItemInfinityGrid:LocateTo()
  self:CheckShowEnterAnim()
end

function Form_LegacyActivityCubePop:CheckShowEnterAnim()
  local showLuaInfinityGrid = self.m_luaHeroInfinityGrid
  local showItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_heroItemInitShowNum = #showItemList
  for i, tempHeroItem in ipairs(showItemList) do
    local tempObj = tempHeroItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
  end
  TimeService:SetTimer(self.m_uiVariables.ItemListDelayTime, 1, function()
    self:ShowHeroItemListAnim()
  end)
  showLuaInfinityGrid = self.m_luaItemInfinityGrid
  showItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempHeroItem in ipairs(showItemList) do
    local tempObj = tempHeroItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
  end
  TimeService:SetTimer(self.m_uiVariables.ItemListDelayTime, 1, function()
    self:ShowItemListAnim()
  end)
end

function Form_LegacyActivityCubePop:ShowHeroItemListAnim()
  local itemDeltaTime = self.m_uiVariables.ItemDeltaTime
  local showLuaInfinityGrid = self.m_luaHeroInfinityGrid
  local showItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_heroItemInitShowNum = #showItemList
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    if i == 1 then
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      tempItem:PlayAnim()
    else
      do
        local leftIndex = i - 1
        self["HeroItemInitTimer" .. i] = TimeService:SetTimer(leftIndex * itemDeltaTime, 1, function()
          UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
          tempItem:PlayAnim()
        end)
      end
    end
  end
end

function Form_LegacyActivityCubePop:ShowItemListAnim()
  local itemDeltaTime = self.m_uiVariables.ItemDeltaTime
  local showLuaInfinityGrid = self.m_luaItemInfinityGrid
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

function Form_LegacyActivityCubePop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_LegacyActivityCubePop:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_LegacyActivityCubePop:OnHeroIconClk(i)
end

function Form_LegacyActivityCubePop:OnItemClk(itemIndex)
  if not itemIndex then
    return
  end
  local itemData = self.m_showRewardItemDataList[itemIndex + 1]
  if not itemData then
    return
  end
  utils.openItemDetailPop({
    iID = itemData.itemData.data_id,
    iNum = itemData.itemData.data_num
  })
end

function Form_LegacyActivityCubePop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_LegacyActivityCubePop", Form_LegacyActivityCubePop)
return Form_LegacyActivityCubePop
