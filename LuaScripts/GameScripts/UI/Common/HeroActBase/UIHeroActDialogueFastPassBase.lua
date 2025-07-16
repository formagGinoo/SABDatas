local UIHeroActDialogueFastPassBase = class("UIHeroActDialogueFastPassBase", require("UI/Common/UIBase"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local ActLamiaBonusChaIns = ConfigManager:GetConfigInsByName("ActLamiaBonusCha")
local DefaultSweepNum = 1

function UIHeroActDialogueFastPassBase:AfterInit()
  UIHeroActDialogueFastPassBase.super.AfterInit(self)
  self.m_levelType = nil
  self.m_activityID = nil
  self.m_subActivityID = nil
  self.m_curLevelID = nil
  self.m_levelCfg = nil
  self.m_heroAddExtraCfgDic = nil
  self.m_heroTopBonus = nil
  self.m_heroNodes = {}
  self:InitHeroWidgets()
  self.m_curAddBonus = nil
  self.m_ItemWidgetList = {}
  local itemNode = self:InitRewardItem(self.m_reward_item.transform)
  self.m_itemNameStr = self.m_reward_item.name
  self.m_reward_item.name = self.m_itemNameStr .. 1
  self.m_ItemWidgetList[#self.m_ItemWidgetList + 1] = itemNode
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.m_numStepper = self:createNumStepper(self.m_stepper)
  self.m_numStepper:SetNumChangeCB(function(curNum, numberChange, tag)
    self:OnStepperChange(curNum)
  end)
  self.m_curSweepNum = DefaultSweepNum
end

function UIHeroActDialogueFastPassBase:OnActive()
  UIHeroActDialogueFastPassBase.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function UIHeroActDialogueFastPassBase:OnInactive()
  UIHeroActDialogueFastPassBase.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function UIHeroActDialogueFastPassBase:OnDestroy()
  UIHeroActDialogueFastPassBase.super.OnDestroy(self)
end

function UIHeroActDialogueFastPassBase:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_activityID = tParam.activityID
    self.m_subActivityID = tParam.subActivityID
    self.m_curLevelID = tParam.levelID
    self.m_levelType = HeroActivityManager:GetLevelTypeByActivityID(self.m_activityID)
    self.m_levelCfg = LevelHeroLamiaActivityManager:GetLevelCfgByID(self.m_curLevelID)
    self:FreshHeroBonusData()
    self.m_csui.m_param = nil
  end
end

function UIHeroActDialogueFastPassBase:ClearData()
end

function UIHeroActDialogueFastPassBase:ClearCacheData()
  self.m_activityID = nil
  self.m_subActivityID = nil
  self.m_curLevelID = nil
end

function UIHeroActDialogueFastPassBase:InsertTopFive(bonusData)
  if not bonusData then
    return
  end
  local insertIndex = 1
  for i, tempBonusData in ipairs(self.m_heroTopBonus) do
    if bonusData.sort < tempBonusData.sort then
      insertIndex = i
      break
    end
  end
  table.insert(self.m_heroTopBonus, insertIndex, bonusData)
  local totalLen = #self.m_heroTopBonus
  if totalLen > FormPlotMaxNum then
    table.remove(self.m_heroTopBonus, FormPlotMaxNum)
  end
end

function UIHeroActDialogueFastPassBase:FreshHeroBonusData()
  if not self.m_activityID then
    return
  end
  self.m_heroAddExtraCfgDic = {}
  local actHeroBonusCfg = ActLamiaBonusChaIns:GetValue_ByActivityID(self.m_activityID)
  for _, v in pairs(actHeroBonusCfg) do
    local tempHeroID = v.m_Character
    local tempData = {
      heroID = tempHeroID,
      sort = v.m_Sort,
      rate = v.m_Rate,
      config = v,
      heroData = nil
    }
    self.m_heroAddExtraCfgDic[tempHeroID] = tempData
  end
  local allHeroList = HeroManager:GetHeroList()
  self.m_heroTopBonus = {}
  for i, heroData in ipairs(allHeroList) do
    local heroCfg = heroData.characterCfg
    local heroID = heroCfg.m_HeroID
    local tempBonusData = self.m_heroAddExtraCfgDic[heroID]
    if tempBonusData then
      tempBonusData.heroData = heroData
      self:InsertTopFive(tempBonusData)
    end
  end
end

function UIHeroActDialogueFastPassBase:CombineBaseAndExtraRewards(baseRewardArray, extraRewardArray, isHaveExtra)
  local showItemList = {}
  if not baseRewardArray then
    return
  end
  local baseLen = baseRewardArray.Length
  for i = 1, baseLen do
    local tempBaseReward = baseRewardArray[i - 1]
    local tempItem = {
      itemID = tonumber(tempBaseReward[0]),
      itemNum = tonumber(tempBaseReward[1]),
      isExtra = false
    }
    showItemList[#showItemList + 1] = tempItem
  end
  if isHaveExtra then
    local firstLen = extraRewardArray.Length
    for i = 1, firstLen do
      local tempBaseReward = extraRewardArray[i - 1]
      local tempItem = {
        itemID = tonumber(tempBaseReward[0]),
        itemNum = tonumber(tempBaseReward[1]),
        isExtra = true
      }
      showItemList[#showItemList + 1] = tempItem
    end
  end
  return showItemList
end

function UIHeroActDialogueFastPassBase:GetLeftFreeTimes()
  local curUseTimes = self.m_levelHelper:GetDailyTimesBySubActivityAndSubID(self.m_activityID, self.m_subActivityID) or 0
  local totalFreeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ActLamiaPassDailyLimit") or 0)
  return totalFreeNum - curUseTimes
end

function UIHeroActDialogueFastPassBase:GetCostItemNum()
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_activityID)
  local costItemID = mainActInfoCfg.m_PassItem
  local costItemNum = ItemManager:GetItemNum(costItemID)
  return costItemNum
end

function UIHeroActDialogueFastPassBase:GetTotalLeftTimes()
  local leftTimes = self:GetLeftFreeTimes() or 0
  local itemNum = self:GetCostItemNum() or 0
  return leftTimes + itemNum
end

function UIHeroActDialogueFastPassBase:AddEventListeners()
  self:addEventListener("eGameEvent_Level_Lamia_Sweep", handler(self, self.OnEventLamiaSweep))
end

function UIHeroActDialogueFastPassBase:RemoveAllEventListeners()
  self:clearEventListener()
end

function UIHeroActDialogueFastPassBase:OnEventLamiaSweep(param)
  if param.activityID ~= self.m_activityID or param.levelID ~= self.m_curLevelID then
    return
  end
  self:CloseForm()
end

function UIHeroActDialogueFastPassBase:InitHeroWidgets()
  for i = 1, FormPlotMaxNum do
    local tempHeroNode = {}
    local heroNode = self["m_common_hero_middle" .. i]
    local heroIconWidget = self:createHeroIcon(heroNode)
    tempHeroNode.heroIconWidget = heroIconWidget
    heroIconWidget:SetHeroIconClickCB(function()
      self:OnHeroIconClk(i)
    end)
    local txtBonus = heroNode.transform:Find("bg_bonus/txt_bonus"):GetComponent(T_TextMeshProUGUI)
    tempHeroNode.txtBonus = txtBonus
    tempHeroNode.heroNode = heroNode
    self.m_heroNodes[i] = tempHeroNode
  end
end

function UIHeroActDialogueFastPassBase:FreshUI()
  if self.m_levelType ~= LevelHeroLamiaActivityManager.LevelType.Lamia then
    return
  end
  self.m_txt_title_Text.text = self.m_levelCfg.m_LevelRef .. " " .. self.m_levelCfg.m_mLevelName
  self:FreshHeroBonusShow()
  self:FreshShowRewardItems()
  self:FreshShowCostItemIcon()
  self.m_curSweepNum = DefaultSweepNum
  self:FreshStepperShow()
  self:FreshCostShow()
end

function UIHeroActDialogueFastPassBase:FreshHeroBonusShow()
  local totalLen = #self.m_heroTopBonus
  local addBonusNum = 0
  local isEmpty = totalLen <= 0
  UILuaHelper.SetActive(self.m_heroNo, isEmpty)
  UILuaHelper.SetActive(self.m_hero_list, not isEmpty)
  if not isEmpty then
    for i = 1, FormPlotMaxNum do
      local tempBonusData = self.m_heroTopBonus[i]
      UILuaHelper.SetActive(self["m_common_hero_middle" .. i], tempBonusData ~= nil)
      if tempBonusData then
        local heroNode = self.m_heroNodes[i]
        heroNode.heroIconWidget:SetHeroData(tempBonusData.heroData.serverData, nil, true)
        heroNode.txtBonus.text = tempBonusData.rate .. "%"
        addBonusNum = addBonusNum + tempBonusData.rate
      end
    end
  end
  self.m_curAddBonus = addBonusNum
  local isBelowMax = self.m_curAddBonus < 100
  UILuaHelper.SetActive(self.m_bonus_normal, isBelowMax)
  UILuaHelper.SetActive(self.m_bonus_max, not isBelowMax)
  if self.m_curAddBonus < 100 then
    self.m_txt_bonus_Text.text = self.m_curAddBonus .. "%"
  end
end

function UIHeroActDialogueFastPassBase:FreshShowRewardItems()
  local levelCfg = self.m_levelCfg
  local rewardItemList = self:CombineBaseAndExtraRewards(levelCfg.m_Rewards, levelCfg.m_Bonus, self.m_curAddBonus > 0)
  self:FreshRewardList(rewardItemList)
end

function UIHeroActDialogueFastPassBase:FreshRewardList(rewardArray)
  if not rewardArray or #rewardArray <= 0 then
    return
  end
  local itemWidgets = self.m_ItemWidgetList
  local dataLen = #rewardArray
  local parentTrans = self.m_reward_root
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemWidgets[i]
      local itemData = rewardArray[i]
      self:FreshRewardItem(itemNode, itemData)
      local itemWidget = itemNode.itemWidget
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemRoot = GameObject.Instantiate(self.m_reward_item, parentTrans.transform)
      itemRoot.name = self.m_itemNameStr .. i
      local itemNode = self:InitRewardItem(itemRoot.transform)
      itemWidgets[#itemWidgets + 1] = itemNode
      local itemData = rewardArray[i]
      self:FreshRewardItem(itemNode, itemData)
      itemNode.itemWidget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemWidgets[i]:SetActive(false)
    end
  end
end

function UIHeroActDialogueFastPassBase:InitRewardItem(rootTrans)
  if not rootTrans then
    return
  end
  local itemWidget = self:createCommonItem(rootTrans.gameObject)
  local nodeBonus = rootTrans:Find("bg_item_bonus")
  local txtItemBonus = rootTrans:Find("bg_item_bonus/txt_item_bonus"):GetComponent(T_TextMeshProUGUI)
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  return {
    itemWidget = itemWidget,
    nodeBonus = nodeBonus,
    txtItemBonus = txtItemBonus
  }
end

function UIHeroActDialogueFastPassBase:FreshRewardItem(itemNode, itemData)
  if not itemNode then
    return
  end
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = itemData.itemID,
    iNum = itemData.itemNum
  })
  local itemWidget = itemNode.itemWidget
  itemWidget:SetItemInfo(processItemData)
  local isExtra = itemData.isExtra
  UILuaHelper.SetActive(itemNode.nodeBonus, isExtra)
  if isExtra then
    local showAdd = self.m_curAddBonus < 100 and self.m_curAddBonus or 100
    itemNode.txtItemBonus.text = "+" .. showAdd .. "%"
  end
end

function UIHeroActDialogueFastPassBase:FreshStepperShow()
  if not self.m_numStepper then
    return
  end
  local totalLeftNum = self:GetTotalLeftTimes()
  self.m_numStepper:SetNumShowMax(true)
  self.m_numStepper:SetNumMax(totalLeftNum)
  self.m_numStepper:SetNumCur(self.m_curSweepNum)
end

function UIHeroActDialogueFastPassBase:FreshShowCostItemIcon()
  if not self.m_activityID then
    return
  end
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_activityID)
  local costItemID = mainActInfoCfg.m_PassItem
  local iconPath = ItemManager:GetItemIconPathByID(costItemID)
  if iconPath then
    UILuaHelper.SetAtlasSprite(self.m_icon2_Image, iconPath)
  end
end

function UIHeroActDialogueFastPassBase:FreshCostShow()
  local freeNum = self:GetLeftFreeTimes()
  if freeNum >= self.m_curSweepNum then
    UILuaHelper.SetActive(self.m_icon2, false)
    UILuaHelper.SetActive(self.m_txt_num2, false)
    self.m_txt_num1_Text.text = self.m_curSweepNum
  else
    UILuaHelper.SetActive(self.m_icon2, true)
    UILuaHelper.SetActive(self.m_txt_num2, true)
    self.m_txt_num1_Text.text = freeNum
    local itemNum = self.m_curSweepNum - freeNum
    self.m_txt_num2_Text.text = itemNum
  end
end

function UIHeroActDialogueFastPassBase:OnBtncloseClicked()
  self:CloseForm()
end

function UIHeroActDialogueFastPassBase:OnBtncancelClicked()
  self:CloseForm()
end

function UIHeroActDialogueFastPassBase:OnBtnclearClicked()
  if self.m_curSweepNum < 1 then
    return
  end
  LevelHeroLamiaActivityManager:ReqLamiaStageSweep(self.m_activityID, self.m_curLevelID, self.m_curSweepNum)
end

function UIHeroActDialogueFastPassBase:OnHeroIconClk(i)
  if self.m_heroTopBonus[i] == nil then
    return
  end
end

function UIHeroActDialogueFastPassBase:OnStepperChange(curNum)
  self.m_curSweepNum = curNum
  self:FreshCostShow()
end

function UIHeroActDialogueFastPassBase:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function UIHeroActDialogueFastPassBase:IsOpenGuassianBlur()
  return true
end

return UIHeroActDialogueFastPassBase
