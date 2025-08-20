local UISubPanelBase = require("UI/Common/UISubPanelBase")
local LevelDetailLamiaSubPanel = class("LevelDetailLamiaSubPanel", UISubPanelBase)
local MonsterGroupIns = ConfigManager:GetConfigInsByName("MonsterGroup")
local MonsterIns = ConfigManager:GetConfigInsByName("Monster")
local ResultConditionTypeIns = ConfigManager:GetConfigInsByName("ResultConditionType")
local HeroModifyIns = ConfigManager:GetConfigInsByName("HeroModify")
local string_format = string.format
local ipairs = _ENV.ipairs
local EnterAnimStr = "level_panel_detail_in"
local OutAnimStr = "level_panel_detail_out"
local ColorEnum = {
  red = Color(0.5411764705882353, 0.023529411764705882, 0.19607843137254902),
  gray = Color(0.3215686274509804, 0.34509803921568627, 0.3411764705882353)
}

function LevelDetailLamiaSubPanel:OnInit()
  self.m_levelType = nil
  self.m_activityID = nil
  self.m_subActivityID = nil
  self.m_actSubType = nil
  self.m_curLevelID = nil
  self.m_levelRefStr = nil
  if self.m_initData then
    self.m_bgClkBack = self.m_initData.bgBackFun
  end
  UILuaHelper.SetActive(self.m_btn_detail_bg, self.m_bgClkBack ~= nil)
  self.m_ItemNodeList = {}
  local itemNode = self:CreateItemNode(self.m_reward_item)
  self.m_itemNameStr = self.m_reward_item.name
  self.m_reward_item.name = self.m_itemNameStr .. 1
  self.m_ItemNodeList[#self.m_ItemNodeList + 1] = itemNode
  self.m_ItemExtraWidgetList = {}
  local extraItemWidget = self:createCommonItem(self.m_reward_item_extra)
  extraItemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  self.m_itemExtraNameStr = self.m_reward_item_extra.name
  self.m_reward_item_extra.name = self.m_itemExtraNameStr .. 1
  self.m_ItemExtraWidgetList[#self.m_ItemExtraWidgetList + 1] = extraItemWidget
  self.m_mainInfoCfg = nil
  self.m_curBattleWorldCfg = nil
  local initEnemyGridData = {
    itemClkBackFun = handler(self, self.OnEnemyIconClk)
  }
  self.m_enemy_listInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_enemy_list_InfinityGrid, "Monster/UIMonsterSmallItem", initEnemyGridData)
  self.m_enemyList = {}
  UILuaHelper.SetCanvasGroupAlpha(self.m_level_panel_detail, 0)
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
end

function LevelDetailLamiaSubPanel:OnFreshData()
  self.m_activityID = self.m_panelData.activityID
  self.m_mainInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_activityID)
  self.m_levelType = HeroActivityManager:GetLevelTypeByActivityID(self.m_activityID)
  self.m_curLevelID = self.m_panelData.levelID
  self.m_levelCfg = LevelHeroLamiaActivityManager:GetLevelCfgByID(self.m_curLevelID)
  self.m_subActivityID = self.m_levelCfg.m_ActivitySubID
  self.m_actSubType = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(self.m_curLevelID)
  self:FreshLevelInfo()
  self:FreshCostItemShow()
  self:FreshEnterBattle()
  self:FreshForceLevel()
  self:FreshBuffHeroEnterButtons()
  self:CheckShowAnimIn()
end

function LevelDetailLamiaSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Level_Lamia_Sweep", handler(self, self.OnEventLamiaSweep))
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.OnEventItemChange))
  self:addEventListener("eGameEvent_HeroAct_DailyReset", handler(self, self.OnHeroActDailyReset))
end

function LevelDetailLamiaSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function LevelDetailLamiaSubPanel:OnEventLamiaSweep(param)
  if param.activityID ~= self.m_activityID or param.levelID ~= self.m_curLevelID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_VICTORY, {
    levelType = LevelHeroLamiaActivityManager.LevelType.Lamia,
    activityID = self.m_activityID,
    levelID = self.m_curLevelID,
    rewardData = param.reward,
    extraReward = param.extraReward,
    isSweep = true
  })
end

function LevelDetailLamiaSubPanel:OnEventItemChange(param)
  self:FreshEnterBattle()
end

function LevelDetailLamiaSubPanel:OnHeroActDailyReset()
  self:FreshEnterBattle()
end

function LevelDetailLamiaSubPanel:OnDestroy()
  LevelDetailLamiaSubPanel.super.OnDestroy(self)
  if self.m_detailOutTimer ~= nil then
    TimeService:KillTimer(self.m_detailOutTimer)
    self.m_detailOutTimer = nil
  end
end

function LevelDetailLamiaSubPanel:MonsterIsInList(monsterIDList, checkMonsterID)
  if not monsterIDList then
    return
  end
  if not checkMonsterID then
    return
  end
  for _, monsterID in ipairs(monsterIDList) do
    if monsterID == checkMonsterID then
      return true
    end
  end
  return false
end

function LevelDetailLamiaSubPanel:CombineBaseAndFirstRewards(baseRewardArray, firstRewardArray, isHavePass)
  local showItemList = {}
  if not baseRewardArray then
    return
  end
  if not isHavePass then
    local firstLen = firstRewardArray.Length
    for i = 1, firstLen do
      local tempBaseReward = firstRewardArray[i - 1]
      local tempItem = {
        itemID = tonumber(tempBaseReward[0]),
        itemNum = tonumber(tempBaseReward[1]),
        isFirst = true
      }
      showItemList[#showItemList + 1] = tempItem
    end
  end
  local baseLen = baseRewardArray.Length
  for i = 1, baseLen do
    local tempBaseReward = baseRewardArray[i - 1]
    local tempItem = {
      itemID = tonumber(tempBaseReward[0]),
      itemNum = tonumber(tempBaseReward[1]),
      isFirst = false
    }
    showItemList[#showItemList + 1] = tempItem
  end
  return showItemList
end

function LevelDetailLamiaSubPanel:GetCostItemNum()
  local isChallenge = self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if isChallenge then
    return
  end
  local mainActInfoCfg = self.m_mainInfoCfg
  local costItemID = mainActInfoCfg.m_PassItem
  local costItemNum = ItemManager:GetItemNum(costItemID)
  local freeItemId = mainActInfoCfg.m_FreePassItem
  local freeitemNum = ItemManager:GetItemNum(freeItemId) or 0
  return costItemNum + freeitemNum
end

function LevelDetailLamiaSubPanel:IsHaveEnoughTimes()
  local leftTimes = self.m_levelHelper:GetLeftFreeTimes(self.m_activityID, self.m_subActivityID) or 0
  local itemNum = self:GetCostItemNum() or 0
  return 0 < leftTimes + itemNum, leftTimes + itemNum
end

function LevelDetailLamiaSubPanel:IsRepeat()
  if not self.m_levelCfg then
    return
  end
  return self.m_levelCfg.m_Repeat == 1
end

function LevelDetailLamiaSubPanel:GetCostItemNameStr()
  local isChallenge = self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if not isChallenge then
    local mainActInfoCfg = self.m_mainInfoCfg
    local costItemID = mainActInfoCfg.m_PassItem
    return ItemManager:GetItemName(costItemID)
  end
end

function LevelDetailLamiaSubPanel:FreshLevelInfo()
  local levelCfg = self.m_levelCfg
  self.m_curBattleWorldCfg = nil
  local levelRefStr = levelCfg.m_LevelRef or ""
  local mapID = levelCfg.m_MapID
  self.m_curBattleWorldCfg = ConfigManager:GetBattleWorldCfgById(mapID)
  self.m_levelRefStr = levelRefStr
  if not utils.isNull(self.m_txt_level_name_Text) then
    self.m_txt_level_name_Text.text = levelRefStr
  end
  self.m_txt_dialogue_desc_Text.text = self.m_levelCfg.m_mLevelName or ""
  self.m_txt_round_Text.text = ConfigManager:BattleWorldMaxRound(self.m_curBattleWorldCfg) or 0
  local isHavePass = self.m_levelHelper:IsLevelHavePass(self.m_curLevelID)
  local rewardItemList = self:CombineBaseAndFirstRewards(self.m_levelCfg.m_Rewards, self.m_levelCfg.m_FirstBonus, isHavePass)
  self:FreshRewardList(rewardItemList)
  self:FreshExtraRewardItems(self.m_levelCfg.m_Bonus)
  self:FreshEnemyList()
  self:FreshDailyTimes()
  self:FreshLevelTypeTag()
end

function LevelDetailLamiaSubPanel:FreshDailyTimes()
end

function LevelDetailLamiaSubPanel:FreshLevelTypeTag()
  if not self.m_curBattleWorldCfg then
    return
  end
  local resultConditionType = ConfigManager:BattleConditionStart(self.m_curBattleWorldCfg)
  local resultConditionCfg = ResultConditionTypeIns:GetValue_ByConditionTypeID(resultConditionType)
  if resultConditionCfg:GetError() then
    return
  end
  local resultTypePath = resultConditionCfg.m_ConditionTypeMark
  local resultNote = resultConditionCfg.m_mNote
  UILuaHelper.SetAtlasSprite(self.m_img_type_Image, resultTypePath)
  self.m_txt_type_Text.text = resultNote
end

function LevelDetailLamiaSubPanel:FreshEnemyList()
  if not self.m_curBattleWorldCfg then
    return
  end
  local monsterGroupArray = ConfigManager:BattleWorldMonsterGroupList(self.m_curBattleWorldCfg)
  if not monsterGroupArray or monsterGroupArray.Length == 0 then
    return
  end
  local monsterDic = {}
  local isHaveHide = false
  local arrayLen = monsterGroupArray.Length
  for i = 0, arrayLen - 1 do
    local monsterGroupID = monsterGroupArray[i]
    local monsterGroupCfg = MonsterGroupIns:GetValue_ByID(monsterGroupID)
    if not monsterGroupCfg:GetError() then
      local monsterList = monsterGroupCfg.m_MonsterList
      if monsterList and monsterList.Length > 0 then
        local monsterLen = monsterList.Length
        local hideMonsterIDList = utils.changeCSArrayToLuaTable(monsterGroupCfg.m_Hide) or {}
        local notShowMonsterIDList = utils.changeCSArrayToLuaTable(monsterGroupCfg.m_MosterHideView) or {}
        for monsterIndex = 0, monsterLen - 1 do
          local monsterTemp = monsterList[monsterIndex]
          if monsterTemp and monsterTemp[1] then
            local monsterID = monsterTemp[1]
            if self:MonsterIsInList(notShowMonsterIDList, monsterID) ~= true and monsterDic[monsterID] == nil then
              local monsterCfg = MonsterIns:GetValue_ByMonsterID(monsterID)
              if monsterCfg and not monsterCfg:GetError() then
                local isHide = self:MonsterIsInList(hideMonsterIDList, monsterID)
                local battleCamp = monsterCfg.m_BattleCamp
                local isNeedCreat = true
                if isHide and isHaveHide == true then
                  isNeedCreat = false
                end
                if battleCamp == 0 or battleCamp == 1 then
                  isNeedCreat = false
                end
                if isNeedCreat then
                  local tempEnemyTab = {monsterCfg = monsterCfg, isHide = isHide}
                  monsterDic[monsterID] = tempEnemyTab
                  if isHide then
                    isHaveHide = true
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  local tempEnemyList = {}
  for _, monsterData in pairs(monsterDic) do
    tempEnemyList[#tempEnemyList + 1] = monsterData
  end
  self.m_enemyList = HeroManager:GetHeroSort():GetMonsterListSort(tempEnemyList)
  self.m_enemy_listInfinityGrid:ShowItemList(self.m_enemyList)
end

function LevelDetailLamiaSubPanel:CreateItemNode(itemObj)
  if not itemObj then
    return
  end
  local widget = self:createCommonItem(itemObj)
  widget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  local firstTag = itemObj.transform:Find("m_img_first_tag")
  return {widget = widget, firstTag = firstTag}
end

function LevelDetailLamiaSubPanel:FreshItemNodeShow(itemNode, itemData)
  local itemWidget = itemNode.widget
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = itemData.itemID,
    iNum = itemData.itemNum
  })
  itemWidget:SetItemInfo(processItemData)
  UILuaHelper.SetActive(itemNode.firstTag, itemData.isFirst == true)
end

function LevelDetailLamiaSubPanel:FreshRewardList(rewardArray)
  if not rewardArray or #rewardArray <= 0 then
    UILuaHelper.SetActive(self.m_list_reward_mask, false)
    return
  end
  UILuaHelper.SetActive(self.m_list_reward_mask, true)
  local itemNodes = self.m_ItemNodeList
  local dataLen = #rewardArray
  local parentTrans = self.m_reward_root
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      local itemData = rewardArray[i]
      self:FreshItemNodeShow(itemNode, itemData)
      itemNode.widget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_reward_item, parentTrans.transform).gameObject
      itemObj.name = self.m_itemNameStr .. i
      local itemNode = self:CreateItemNode(itemObj)
      itemNodes[#itemNodes + 1] = itemNode
      local itemData = rewardArray[i]
      self:FreshItemNodeShow(itemNode, itemData)
      itemNode.widget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemNodes[i].widget:SetActive(false)
    end
  end
  UILuaHelper.SetLocalPosition(parentTrans, 0, 0, 0)
end

function LevelDetailLamiaSubPanel:FreshExtraRewardItems(rewardArray)
  if not rewardArray or rewardArray.Length <= 0 then
    UILuaHelper.SetActive(self.m_list_reward_extra_mask, false)
    return
  end
  UILuaHelper.SetActive(self.m_list_reward_extra_mask, true)
  local itemWidgets = self.m_ItemExtraWidgetList
  local dataLen = rewardArray.Length
  local parentTrans = self.m_extra_reward_root
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local itemArray = rewardArray[i - 1]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemArray[0]),
        iNum = tonumber(itemArray[1])
      })
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_reward_item_extra, parentTrans.transform).gameObject
      itemObj.name = self.m_itemExtraNameStr .. i
      local itemWidget = self:createCommonItem(itemObj)
      local itemArray = rewardArray[i - 1]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemArray[0]),
        iNum = tonumber(itemArray[1])
      })
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidgets[#itemWidgets + 1] = itemWidget
      itemWidget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemWidgets[i]:SetActive(false)
    end
  end
end

function LevelDetailLamiaSubPanel:FreshCostItemShow()
  local isChallenge = self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  UILuaHelper.SetActive(self.m_txt_consume_num, not isChallenge)
  if not isChallenge then
    local mainActInfoCfg = self.m_mainInfoCfg
    local costItemID = mainActInfoCfg.m_PassItem
    local iconPath = ItemManager:GetItemIconPathByID(costItemID)
    if iconPath then
      UILuaHelper.SetAtlasSprite(self.m_icon_cost_Image, iconPath)
    end
  end
end

function LevelDetailLamiaSubPanel:FreshForceLevel()
  if not self.m_levelCfg then
    return
  end
  local heroModify = self.m_levelCfg.m_HeroModify
  UILuaHelper.SetActive(self.m_pnl_levellock, heroModify ~= 0)
  UILuaHelper.SetActive(self.m_enemy1, heroModify == 0)
  UILuaHelper.SetActive(self.m_ourside, heroModify == 0)
  if heroModify ~= 0 then
    local heroModifyCfg = HeroModifyIns:GetValue_ByID(heroModify)
    if heroModifyCfg:GetError() ~= true then
      self.m_txt_levellock_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(20204), heroModifyCfg.m_ForceLevel)
    end
  else
    self.m_txt_enemy1_Text.text = self.m_levelCfg.m_RecoEfficencyType
    local power = HeroManager:GetTopFiveHeroPower()
    self.m_txt_ourside_Text.text = power
    if power >= self.m_levelCfg.m_RecoEfficencyType then
      self.m_bg_blue:SetActive(true)
      self.m_bg_red:SetActive(false)
      self.m_img_battle_ourside_Image.color = ColorEnum.gray
      self.m_txt_ourside_Text.color = ColorEnum.gray
      self.m_txt_ourside_Text.color = ColorEnum.gray
    else
      self.m_bg_blue:SetActive(false)
      self.m_bg_red:SetActive(true)
      self.m_img_battle_ourside_Image.color = ColorEnum.red
      self.m_txt_ourside_Text.color = ColorEnum.red
      self.m_txt_ourside_Text.color = ColorEnum.red
    end
  end
end

function LevelDetailLamiaSubPanel:FreshBuffHeroEnterButtons()
  if not self.m_actSubType then
    return
  end
  local isChallenge = self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if not utils.isNull(self.m_btn_buff_hero) then
    UILuaHelper.SetActive(self.m_btn_buff_hero, not isChallenge)
  end
  if not utils.isNull(self.m_btn_challenge_buff_hero) then
    UILuaHelper.SetActive(self.m_btn_challenge_buff_hero, isChallenge)
  end
end

function LevelDetailLamiaSubPanel:FreshEnterBattle()
  if not self.m_curLevelID then
    return
  end
  local tempHelper = self.m_levelHelper
  local isUnlock = tempHelper:IsLevelUnLock(self.m_curLevelID)
  local isHavePass = self.m_levelHelper:IsLevelHavePass(self.m_curLevelID)
  local isHaveEnough = self:IsHaveEnoughTimes()
  local isRepeat = self:IsRepeat()
  local isChallenge = self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  UILuaHelper.SetActive(self.m_btn_battle_gray, isUnlock and not isHaveEnough and (isRepeat or not isHavePass))
  UILuaHelper.SetActive(self.m_btn_quick_gray, isUnlock and (not isHaveEnough or not isHavePass) and isRepeat)
  UILuaHelper.SetActive(self.m_btn_battle, isUnlock and isHaveEnough and (isRepeat or not isHavePass))
  UILuaHelper.SetActive(self.m_btn_quick, isUnlock and isHaveEnough and isRepeat and isHavePass)
  local leftTimes = self.m_levelHelper:GetLeftFreeTimes(self.m_activityID, self.m_subActivityID) or 0
  local isHaveFree = 1 <= leftTimes
  local isShowConsume = not isChallenge and isUnlock and (isRepeat and not isHaveFree or not isRepeat and not isHaveFree and not isHavePass)
  local isShowFree = not isChallenge and isUnlock and (isRepeat and isHaveFree or not isRepeat and isHaveFree and not isHavePass)
  UILuaHelper.SetActive(self.m_pnl_consume, isShowConsume)
  if isShowConsume then
    local colorTab = isHaveEnough and GlobalConfig.COMMON_COLOR.Normal2 or GlobalConfig.COMMON_COLOR.Red
    UILuaHelper.SetColor(self.m_txt_consume_num, table.unpack(colorTab))
  end
  UILuaHelper.SetActive(self.m_pnl_free, isShowFree)
  UILuaHelper.SetActive(self.m_node_lock, not isUnlock)
  UILuaHelper.SetActive(self.m_node_pass, not isRepeat and isHavePass)
  if not utils.isNull(self.m_icon_free_Image) then
    local itemPath = ItemManager:GetItemIconPathByID(self.m_mainInfoCfg.m_PassItem)
    if itemPath then
      UILuaHelper.SetAtlasSprite(self.m_icon_free_Image, itemPath)
    end
  end
end

function LevelDetailLamiaSubPanel:CheckShowAnimIn()
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, EnterAnimStr)
end

function LevelDetailLamiaSubPanel:CheckShowAnimOut(endFun)
  if self.m_detailOutTimer ~= nil then
    return
  end
  local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_level_panel_detail, EnterAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, OutAnimStr)
  if endFun then
    endFun()
  end
  self.m_detailOutTimer = TimeService:SetTimer(detailAnimLen, 1, function()
    self.m_detailOutTimer = nil
  end)
end

function LevelDetailLamiaSubPanel:ConfirmJumpShop()
  if self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel then
    return
  end
  local costItemNameStr = self:GetCostItemNameStr()
  utils.CheckAndPushCommonTips({
    tipsID = 3001,
    bLockBack = true,
    fContentCB = function(sContent)
      return string.CS_Format(sContent, costItemNameStr)
    end,
    func1 = function()
      local jumpIns = ConfigManager:GetConfigInsByName("Jump")
      local jump_item = jumpIns:GetValue_ByJumpID(self.m_mainInfoCfg.m_ShopJumpID)
      local windowId = jump_item.m_Param.Length > 0 and tonumber(jump_item.m_Param[0]) or 0
      local shop_list = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Activity)
      local shop_id
      for i, v in ipairs(shop_list) do
        if v.m_WindowID == windowId then
          shop_id = v.m_ShopID
        end
      end
      local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shop, {
        id = self.m_activityID,
        shop_id = shop_id
      })
      if is_corved and not TimeUtil:IsInTime(t1, t2) then
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
        return
      end
      self.m_parentLua.bIsWaitingShopData = true
      ShopManager:ReqGetShopData(shop_id)
    end
  })
end

function LevelDetailLamiaSubPanel:OnBtndetailbgClicked()
  self:CheckShowAnimOut(function()
    if self.m_bgClkBack then
      self.m_bgClkBack()
    end
  end)
end

function LevelDetailLamiaSubPanel:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function LevelDetailLamiaSubPanel:OnEnemyIconClk(monsterID)
  if not monsterID then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_LEVELMONSTERPREVIEW, {
    battleWorldID = self.m_curBattleWorldCfg.m_MapID,
    stageStr = self.m_levelRefStr
  })
end

function LevelDetailLamiaSubPanel:OnBtnbattleClicked()
  if not self.m_curLevelID or not self.m_activityID then
    return
  end
  if not self.m_levelCfg then
    return
  end
  local heroModify = self.m_levelCfg.m_HeroModify
  if heroModify == 0 then
    local power = HeroManager:GetTopFiveHeroPower()
    if power < self.m_levelCfg.m_RecoEfficencyType then
      utils.CheckAndPushCommonTips({
        tipsID = 1226,
        func1 = function()
          BattleFlowManager:StartEnterBattle(self.m_levelType, self.m_activityID, self.m_curLevelID)
        end
      })
      return
    end
  end
  BattleFlowManager:StartEnterBattle(self.m_levelType, self.m_activityID, self.m_curLevelID)
end

function LevelDetailLamiaSubPanel:OnBtnbattlegrayClicked()
  if not self.m_curLevelID then
    return
  end
  if self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40040)
  else
    self:ConfirmJumpShop()
  end
end

function LevelDetailLamiaSubPanel:OnBtnquickClicked()
  if not self.m_curLevelID or not self.m_activityID then
    return
  end
  local isHaveEnough, totalTimes = self:IsHaveEnoughTimes()
  if isHaveEnough ~= true then
    return
  end
  local isChallenge = self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if totalTimes <= 1 or isChallenge then
    LevelHeroLamiaActivityManager:ReqLamiaStageSweep(self.m_activityID, self.m_curLevelID, 1)
  else
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_DIALOGUEFASTPASS, {
      activityID = self.m_activityID,
      subActivityID = self.m_subActivityID,
      levelID = self.m_curLevelID
    })
  end
end

function LevelDetailLamiaSubPanel:OnBtnquickgrayClicked()
  if not self.m_curLevelID then
    return
  end
  local isHavePass = self.m_levelHelper:IsLevelHavePass(self.m_curLevelID)
  if isHavePass ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40037)
    return
  end
  local isHaveEnough = self:IsHaveEnoughTimes()
  if not isHaveEnough then
    self:ConfirmJumpShop()
  end
end

function LevelDetailLamiaSubPanel:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function LevelDetailLamiaSubPanel:OnBtnchallengebuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_CHALLENGEHERO, {
    activityID = self.m_activityID
  })
end

return LevelDetailLamiaSubPanel
