local Form_PvpBattleVictory = class("Form_PvpBattleVictory", require("UI/UIFrames/Form_PvpBattleVictoryUI"))

function Form_PvpBattleVictory:SetInitParam(param)
end

function Form_PvpBattleVictory:AfterInit()
  self.super.AfterInit(self)
  self.m_itemDataList = nil
  self.m_ItemWidgetList = {}
  self.m_rewardItemBase = self.m_reward_root.transform:Find("c_common_item")
  UILuaHelper.SetActive(self.m_rewardItemBase, false)
  self.m_playerHeadCom = self:createPlayerHead(self.m_mine_head)
  self.m_playerHeadCom:SetStopClkStatus(true)
  self.m_levelType = nil
  self.m_levelSubType = nil
  self.m_csRewardList = nil
  self.m_finishErrorCode = nil
  self.m_showHeroID = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_PvpBattleVictory:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpBattleVictory:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
  self:RemoveAllEventListeners()
  self:ClearData()
end

function Form_PvpBattleVictory:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_PvpBattleVictory:AddEventListeners()
end

function Form_PvpBattleVictory:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpBattleVictory:ClearData()
end

function Form_PvpBattleVictory:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelType = tParam.levelType
  self.m_levelSubType = tParam.levelSubType
  self.m_csRewardList = tParam.rewardData
  self.m_finishErrorCode = tParam.finishErrorCode
  self.m_showHeroID = tParam.showHeroID
  self:FreshRewardListData()
end

function Form_PvpBattleVictory:FreshRewardListData()
  if not self.m_csRewardList then
    return
  end
  self.m_itemDataList = {}
  for key, rewardCsData in pairs(self.m_csRewardList) do
    if rewardCsData then
      local tempReward = {
        iID = rewardCsData.iID,
        iNum = rewardCsData.iNum
      }
      self.m_itemDataList[#self.m_itemDataList + 1] = tempReward
    end
  end
end

function Form_PvpBattleVictory:GetShowSpinePath()
  if not self.m_showHeroID then
    return
  end
  local heroData = HeroManager:GetHeroDataByID(self.m_showHeroID)
  if not heroData then
    return
  end
  local heroCfg = heroData.characterCfg
  local spineStr = heroCfg.m_Spine
  if not spineStr then
    return
  end
  return spineStr
end

function Form_PvpBattleVictory:FreshUI()
  self:FreshRewardItems()
  self:FreshMineInfo()
  self:FreshShowSpine()
end

function Form_PvpBattleVictory:FreshRewardItems()
  if not self.m_itemDataList then
    return
  end
  local itemWidgets = self.m_ItemWidgetList
  local dataLen = #self.m_itemDataList
  local parentTrans = self.m_reward_root
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local processItemData = ResourceUtil:GetProcessRewardData(self.m_itemDataList[i])
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_rewardItemBase, parentTrans.transform).gameObject
      local itemWidget = self:createCommonItem(itemObj)
      local processItemData = ResourceUtil:GetProcessRewardData(self.m_itemDataList[i])
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

function Form_PvpBattleVictory:FreshMineInfo()
  local cacheRank, cacheScore
  local finishErrorCode = self.m_finishErrorCode
  if finishErrorCode ~= nil and finishErrorCode ~= 0 then
    UILuaHelper.SetActive(self.m_z_txt_endtips, true)
    cacheRank = ArenaManager:GetSeasonRank()
    cacheScore = ArenaManager:GetSeasonPoint()
  else
    UILuaHelper.SetActive(self.m_z_txt_endtips, false)
    cacheRank, cacheScore = ArenaManager:GetOldInfo()
  end
  cacheRank = cacheRank or 0
  cacheScore = cacheScore or 0
  local curRank = ArenaManager:GetSeasonRank()
  local curScore = ArenaManager:GetSeasonPoint()
  local changeRank = cacheRank - curRank
  local changeScore = curScore - cacheScore
  self.m_txt_ranknum_Text.text = curRank
  UILuaHelper.SetActive(self.m_txt_rankadd, 0 < changeRank)
  if 0 < changeRank then
    self.m_txt_rankadd_Text.text = changeRank
  end
  self.m_txt_rival_achievement_Text.text = curScore
  UILuaHelper.SetActive(self.m_txt_achievementadd, 0 < changeScore)
  if 0 < changeScore then
    self.m_txt_achievementadd_Text.text = changeScore
  end
  self.m_playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
end

function Form_PvpBattleVictory:FreshShowSpine()
  local spineStr = self:GetShowSpinePath()
  if not spineStr then
    return
  end
  self:LoadHeroSpine(spineStr, "battlewin", self.m_hero_root)
end

function Form_PvpBattleVictory:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_PvpBattleVictory:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
  if not heroSpineAssetName then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end)
  end
end

function Form_PvpBattleVictory:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_PvpBattleVictory:OnBtnBgCloseClicked()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_PvpBattleVictory:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroID = tParam.showHeroID
  vPackage[#vPackage + 1] = {
    sName = tostring(heroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

function Form_PvpBattleVictory:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpBattleVictory", Form_PvpBattleVictory)
return Form_PvpBattleVictory
