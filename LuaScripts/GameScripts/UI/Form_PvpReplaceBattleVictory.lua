local Form_PvpReplaceBattleVictory = class("Form_PvpReplaceBattleVictory", require("UI/UIFrames/Form_PvpReplaceBattleVictoryUI"))

function Form_PvpReplaceBattleVictory:SetInitParam(param)
end

function Form_PvpReplaceBattleVictory:AfterInit()
  self.super.AfterInit(self)
  self.m_itemDataList = nil
  self.m_ItemWidgetList = {}
  self.m_rewardItemBase = self.m_item_root.transform:Find("item_base")
  UILuaHelper.SetActive(self.m_rewardItemBase, false)
  self.m_playerHeadCom = self:createPlayerHead(self.m_mine_head)
  self.m_playerHeadCom:SetStopClkStatus(true)
  self.m_otherPlayerHeadCom = self:createPlayerHead(self.m_other_head)
  self.m_otherPlayerHeadCom:SetStopClkStatus(true)
  self.m_levelType = nil
  self.m_levelSubType = nil
  self.m_finishErrorCode = nil
  self.m_resultData = nil
  self.m_showHeroID = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_HeroFashion = HeroManager:GetHeroFashion()
end

function Form_PvpReplaceBattleVictory:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpReplaceBattleVictory:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
  self:RemoveAllEventListeners()
  self:ClearData()
end

function Form_PvpReplaceBattleVictory:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_PvpReplaceBattleVictory:AddEventListeners()
end

function Form_PvpReplaceBattleVictory:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpReplaceBattleVictory:ClearData()
end

function Form_PvpReplaceBattleVictory:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelType = tParam.levelType
  self.m_levelSubType = tParam.levelSubType
  self.m_finishErrorCode = tParam.finishErrorCode
  self.isOpenEnemyTips = tParam.isOpenEnemyTips
  self.m_showHeroID = tParam.showHeroID
  self.m_resultData = PvpReplaceManager:GetBattleResultData()
  self:CheckFreshRankOutputItemList()
  self.m_csui.m_param = nil
end

function Form_PvpReplaceBattleVictory:CheckFreshRankOutputItemList()
  self.m_itemDataList = {}
  local oldRank = self.m_resultData.iOldRank
  local newRank = self.m_resultData.iRank
  if oldRank == newRank then
    return
  end
  local oldRankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(oldRank)
  local newRankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(newRank)
  if oldRankCfg.m_ID == newRankCfg.m_ID then
    return
  end
  local pvpAFKReward = newRankCfg.m_PVPAFKReward
  local dataLength = pvpAFKReward.Length
  if dataLength == 0 then
    return
  end
  for i = 1, dataLength do
    local itemArray = pvpAFKReward[i - 1]
    local itemID = tonumber(itemArray[0])
    local itemNum = tonumber(itemArray[1])
    local tempReward = {iID = itemID, iNum = itemNum}
    self.m_itemDataList[#self.m_itemDataList + 1] = tempReward
  end
end

function Form_PvpReplaceBattleVictory:GetShowSpinePath()
  if not self.m_showHeroID then
    return
  end
  local heroData = HeroManager:GetHeroDataByID(self.m_showHeroID)
  if not heroData then
    return
  end
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroData.serverData.iHeroId, heroData.serverData.iFashion or 0)
  if not fashionInfo then
    return
  end
  local spineStr = fashionInfo.m_Spine
  if not spineStr then
    return
  end
  return spineStr
end

function Form_PvpReplaceBattleVictory:FreshUI()
  self:FreshRewardItems()
  self:FreshRoundInfo()
  self:FreshShowSpine()
end

function Form_PvpReplaceBattleVictory:FreshRewardItems()
  local finishErrorCode = self.m_finishErrorCode
  UILuaHelper.SetActive(self.m_pnl_enemy_tips, false)
  if self.isOpenEnemyTips then
    UILuaHelper.SetActive(self.m_rewards, false)
    UILuaHelper.SetActive(self.m_pnl_enemy_tips, true)
    return
  end
  if finishErrorCode == MTTD.Error_ReplaceArena_EnemyRankLow then
    UILuaHelper.SetActive(self.m_rewards, false)
    return
  end
  if not self.m_itemDataList then
    return
  end
  if #self.m_itemDataList == 0 then
    UILuaHelper.SetActive(self.m_rewards, false)
    return
  end
  UILuaHelper.SetActive(self.m_rewards, true)
  local itemWidgets = self.m_ItemWidgetList
  local dataLen = #self.m_itemDataList
  local parentTrans = self.m_item_root
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local itemData = self.m_itemDataList[i]
      self:FreshRewardItem(itemWidget, itemData)
      UILuaHelper.SetActive(itemWidget.rootNode, true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_rewardItemBase, parentTrans.transform).gameObject
      local itemNode = self:InitRewardItem(itemObj)
      itemWidgets[#itemWidgets + 1] = itemNode
      local itemData = self.m_itemDataList[i]
      self:FreshRewardItem(itemNode, itemData)
      UILuaHelper.SetActive(itemNode.rootNode, true)
    elseif i <= childCount and i > dataLen then
      local itemWidget = itemWidgets[i]
      UILuaHelper.SetActive(itemWidget.rootNode, false)
    end
  end
end

function Form_PvpReplaceBattleVictory:InitRewardItem(itemRootNode)
  if not itemRootNode then
    return
  end
  local rootNode = itemRootNode.transform
  local itemIcon = rootNode:Find("icon_item"):GetComponent(T_Image)
  local itemNumText = rootNode:Find("txt_item_num"):GetComponent(T_TextMeshProUGUI)
  return {
    rootNode = rootNode,
    itemIcon = itemIcon,
    itemNumText = itemNumText
  }
end

function Form_PvpReplaceBattleVictory:FreshRewardItem(itemNode, itemData)
  if not itemNode then
    return
  end
  if not itemData then
    return
  end
  local itemIconPath = ItemManager:GetItemIconPathByID(itemData.iID)
  UILuaHelper.SetAtlasSprite(itemNode.itemIcon, itemIconPath)
  local perHourNum = math.floor(itemData.iNum * 3600 / 10000)
  itemNode.itemNumText.text = BigNumFormat(perHourNum) .. "/H"
end

function Form_PvpReplaceBattleVictory:FreshRoundInfo()
  local rankNum = self.m_resultData.iRank
  local oldRankNum = self.m_resultData.iOldRank
  self.m_playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
  local rankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(rankNum)
  if rankCfg then
    UILuaHelper.SetAtlasSprite(self.m_icon_left_Image, rankCfg.m_RankIcon)
    self.m_txt_left_Text.text = rankNum
  end
  local enemyRankNum = self.m_resultData.iEnemyRank
  local enemyDetail = PvpReplaceManager:GetEnemyDetail()
  if enemyDetail then
    local roleSimpleInfo = enemyDetail.stRoleSimple
    self.m_otherPlayerHeadCom:SetPlayerHeadInfo(roleSimpleInfo)
  end
  local showRankNum = enemyRankNum
  local enemyRankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(showRankNum)
  if enemyRankCfg then
    UILuaHelper.SetAtlasSprite(self.m_icon_right_Image, enemyRankCfg.m_RankIcon)
    self.m_txt_right_Text.text = showRankNum
  end
  for i = 1, PvpReplaceManager.BattleTeamNum do
    local roundResult = self.m_resultData.vResult[i]
    UILuaHelper.SetActive(self["m_btn_round" .. i], roundResult ~= nil)
    if roundResult ~= nil then
      UILuaHelper.SetActive(self["m_img_victory" .. i], roundResult == 1)
      UILuaHelper.SetActive(self["m_img_defeat" .. i], roundResult ~= 1)
    end
  end
end

function Form_PvpReplaceBattleVictory:FreshShowSpine()
  local spineStr = self:GetShowSpinePath()
  if not spineStr then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(spineStr, "battlewin", self.m_hero_root, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end)
  end
end

function Form_PvpReplaceBattleVictory:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_PvpReplaceBattleVictory:OnBtnBgCloseClicked()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_PvpReplaceBattleVictory:OnBtnround1Clicked()
  self:OnRoundClk(1)
end

function Form_PvpReplaceBattleVictory:OnBtnround2Clicked()
  self:OnRoundClk(2)
end

function Form_PvpReplaceBattleVictory:OnBtnround3Clicked()
  self:OnRoundClk(3)
end

function Form_PvpReplaceBattleVictory:OnRoundClk(index)
  if not index then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA, index - 1)
end

function Form_PvpReplaceBattleVictory:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroID = tParam.showHeroID
  vPackage[#vPackage + 1] = {
    sName = tostring(heroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

function Form_PvpReplaceBattleVictory:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpReplaceBattleVictory", Form_PvpReplaceBattleVictory)
return Form_PvpReplaceBattleVictory
