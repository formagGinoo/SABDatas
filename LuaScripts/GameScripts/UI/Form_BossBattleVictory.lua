local Form_BossBattleVictory = class("Form_BossBattleVictory", require("UI/UIFrames/Form_BossBattleVictoryUI"))

function Form_BossBattleVictory:SetInitParam(param)
end

function Form_BossBattleVictory:AfterInit()
  self.super.AfterInit(self)
  self.m_itemDataList = nil
  self.m_itemDataListEx = nil
  self.m_rewardItemBase = self.m_reward_root.transform:Find("c_common_item")
  self.m_rewardItemBaseEx = self.m_reward_rootex.transform:Find("c_common_item")
  self.m_ItemNodeList = {}
  self.m_ItemNodeListEx = {}
  local itemNode = self:CreateItemNode(self.m_rewardItemBase)
  local itemNodeEx = self:CreateItemNode(self.m_rewardItemBaseEx)
  self.m_itemNameStr = self.m_rewardItemBase.name
  self.m_itemNameStrEx = self.m_rewardItemBaseEx.name
  self.m_ItemNodeList[#self.m_ItemNodeList + 1] = itemNode
  self.m_ItemNodeListEx[#self.m_ItemNodeListEx + 1] = itemNodeEx
  UILuaHelper.SetActive(self.m_rewardItemBase, false)
  UILuaHelper.SetActive(self.m_rewardItemBaseEx, false)
  self.m_levelType = nil
  self.m_curLevelID = nil
  self.m_csRewardList = nil
  self.m_csExRewardList = nil
  self.m_finishErrorCode = nil
  self.m_isSweep = nil
  self.m_isSim = nil
  self.m_showHeroID = nil
  self.m_levelEquipmentHelper = LevelManager:GetLevelHelperByType(LevelManager.LevelType.Dungeon)
  self.m_curDungeonLevelPhaseCfgList = nil
  self.m_curDamageNum = nil
  self.m_curStageIndex = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_HeroFashion = HeroManager:GetHeroFashion()
  self.m_HeroVoice = HeroManager:GetHeroVoice()
end

function Form_BossBattleVictory:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_BossBattleVictory:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
  if self.m_sequence then
    self.m_sequence:Kill()
    self.m_sequence = nil
  end
end

function Form_BossBattleVictory:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_BossBattleVictory:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_levelType = tParam.levelType
    self.m_curLevelID = tParam.levelID
    self.m_csRewardList = tParam.rewardData
    self.m_csExRewardList = tParam.extraReward
    self.m_finishErrorCode = tParam.finishErrorCode
    self.m_showHeroID = tParam.showHeroID
    self.m_isSweep = tParam.isSweep
    self.m_isSim = tParam.isSim
    self:FreshRewardListData()
    self.m_curDungeonLevelPhaseCfgList = self.m_levelEquipmentHelper:GetDungeonLevelPhaseCfgListByID(self.m_curLevelID)
    self.m_curDamageNum = tParam.damageNum
    self.m_curStageIndex = self.m_levelEquipmentHelper:GetLevelStageByDamage(self.m_curLevelID, self.m_curDamageNum)
    self.m_csui.m_param = nil
  end
end

function Form_BossBattleVictory:FreshRewardListData()
  if not self.m_csRewardList then
    return
  end
  self.m_itemDataList = {}
  self.m_itemDataListEx = {}
  if self.m_csExRewardList then
    for _, rewardCsData in pairs(self.m_csExRewardList) do
      if rewardCsData then
        local tempReward = {
          iID = rewardCsData.iID,
          iNum = rewardCsData.iNum,
          is_extra = true
        }
        self.m_itemDataListEx[#self.m_itemDataListEx + 1] = tempReward
      end
    end
  end
  for _, rewardCsData in pairs(self.m_csRewardList) do
    if rewardCsData then
      local tempReward = {
        iID = rewardCsData.iID,
        iNum = rewardCsData.iNum
      }
      self.m_itemDataList[#self.m_itemDataList + 1] = tempReward
    end
  end
end

function Form_BossBattleVictory:ClearCacheData()
  self.m_curLevelID = nil
  self.m_levelType = nil
  self.m_csRewardList = nil
  self.m_csExRewardList = nil
  self.m_finishErrorCode = nil
  self.m_isSweep = nil
  self.m_isSim = nil
  self.m_curDungeonLevelPhaseCfgList = nil
  self.m_curDamageNum = nil
  self.m_curStageIndex = nil
end

function Form_BossBattleVictory:GetRandom(beginIndex, endIndex)
  if not beginIndex then
    return
  end
  if not endIndex then
    return
  end
  math.newrandomseed()
  return math.random(beginIndex, endIndex)
end

function Form_BossBattleVictory:GetSpineFashionInfo()
  local heroData
  if self.m_showHeroID ~= nil then
    local heroID = self.m_showHeroID
    heroData = HeroManager:GetHeroDataByID(heroID)
  else
    local showHeroDataList = HeroManager:GetTopFiveHeroByCombat()
    local randomIndex = self:GetRandom(1, #showHeroDataList)
    heroData = showHeroDataList[randomIndex]
  end
  if not heroData then
    return
  end
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroData.serverData.iHeroId, heroData.serverData.iFashion)
  return fashionInfo
end

function Form_BossBattleVictory:GetShowSpineAndVoice()
  if not self.m_curLevelID then
    return
  end
  local levelCfg = self.m_levelEquipmentHelper:GetDunLevelCfgById(self.m_curLevelID)
  if not levelCfg then
    return
  end
  local fashionID = levelCfg.m_Settlement
  local fashionInfo
  if fashionID == nil or fashionID == 0 then
    fashionInfo = self:GetSpineFashionInfo()
  else
    fashionInfo = self.m_HeroFashion:GetFashionInfoByID(fashionID)
  end
  if not fashionInfo then
    return
  end
  local voice = self.m_HeroVoice:GetHeroBattleVictoryVoice(fashionInfo)
  local spineStr = fashionInfo.m_Spine
  if not spineStr then
    return
  end
  return spineStr, voice
end

function Form_BossBattleVictory:AddEventListeners()
end

function Form_BossBattleVictory:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BossBattleVictory:FreshUI()
  self:FreshBossStageInfo()
  self:FreshRewardItems()
  self:FreshShowSpine()
  self:FreshIsSweep()
end

function Form_BossBattleVictory:FreshBossStageInfo()
  if not self.m_curLevelID then
    return
  end
  local levelCfg = self.m_levelEquipmentHelper:GetDunLevelCfgById(self.m_curLevelID)
  if not levelCfg then
    return
  end
  local levelSubType = levelCfg.m_LevelSubType
  local dungeonChapterCfg = self.m_levelEquipmentHelper:GetDunChapterById(levelSubType)
  if not dungeonChapterCfg then
    return
  end
  self.m_boss_name_Text.text = dungeonChapterCfg.m_mName
  local damageScoreNum = self.m_curDamageNum
  self.m_txt_damage_Text.text = damageScoreNum
  self.m_txt_stage_num_Text.text = self.m_curStageIndex
  UILuaHelper.PlayAnimationByName(self.m_txt_stage_num, "m_pnl_stage_num_upgrade")
  for i = 1, self.m_uiVariables.MaxStageNum do
    local tempPhaseCfg = self.m_curDungeonLevelPhaseCfgList[i]
    UILuaHelper.SetActive(self["m_pnl_point" .. i], tempPhaseCfg ~= nil)
    if tempPhaseCfg then
      UILuaHelper.SetActive(self["m_point_finish" .. i], i < self.m_curStageIndex)
      UILuaHelper.SetActive(self["m_point_now" .. i], self.m_curStageIndex == i)
      if self.m_curStageIndex == i then
        local index = self.m_curStageIndex
        self.m_sequence = Tweening.DOTween.Sequence()
        self.m_sequence:AppendInterval(1.2)
        self.m_sequence:OnComplete(function()
          if not utils.isNull(self["m_point_now" .. index]) then
            UILuaHelper.PlayAnimationByName(self["m_point_now" .. index], "battle_stage_point_in")
          end
          self.m_sequence = nil
        end)
        self.m_sequence:SetAutoKill(true)
      end
      if i < self.m_uiVariables.MaxStageNum then
        self["m_point_slider" .. i .. "_Image"].fillAmount = i < self.m_curStageIndex and 1 or 0
      end
    end
  end
end

function Form_BossBattleVictory:FreshIsSweep()
  UILuaHelper.SetActive(self.m_btn_Data, self.m_isSweep ~= true)
end

function Form_BossBattleVictory:CreateItemNode(itemObj)
  if not itemObj then
    return
  end
  local widget = self:createCommonItem(itemObj)
  widget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  return widget
end

function Form_BossBattleVictory:FreshItemNodeShow(itemNode, itemData)
  local itemWidget = itemNode
  local processItemData = ResourceUtil:GetProcessRewardData(itemData, {
    is_extra = itemData.is_extra
  })
  itemWidget:SetItemInfo(processItemData)
end

function Form_BossBattleVictory:FreshRewardItems()
  UILuaHelper.SetActive(self.m_pnl_reward, not self.m_isSim)
  UILuaHelper.SetActive(self.m_reward_empty, self.m_isSim)
  if self.m_isSim then
    return
  end
  self:UpdateRewardItems(self.m_itemDataList, self.m_ItemNodeList, self.m_reward_root, self.m_rewardItemBase, self.m_itemNameStr)
  local hasExtraRewards = not self.m_isSim and self.m_itemDataListEx and #self.m_itemDataListEx > 0
  UILuaHelper.SetActive(self.m_pnl_rewardex, hasExtraRewards)
  UILuaHelper.SetActive(self.m_img_line2, not hasExtraRewards)
  UILuaHelper.SetActive(self.m_img_line3, hasExtraRewards)
  if hasExtraRewards then
    self:UpdateRewardItems(self.m_itemDataListEx, self.m_ItemNodeListEx, self.m_reward_rootex, self.m_rewardItemBaseEx, self.m_itemNameStrEx)
  end
end

function Form_BossBattleVictory:UpdateRewardItems(itemDataList, itemNodes, rewardRoot, rewardItemBase, itemNameStr)
  if not itemDataList then
    return
  end
  local dataLen = #itemDataList
  local childCount = #itemNodes
  local totalFreshNum = math.max(childCount, dataLen)
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      self:FreshItemNodeShow(itemNode, itemDataList[i])
      itemNode:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(rewardItemBase, rewardRoot.transform).gameObject
      itemObj.name = itemNameStr .. i
      local itemNode = self:CreateItemNode(itemObj)
      table.insert(itemNodes, itemNode)
      self:FreshItemNodeShow(itemNode, itemDataList[i])
      itemNode:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemNodes[i]:SetActive(false)
    end
  end
end

function Form_BossBattleVictory:FreshShowSpine()
  local spineStr, voice = self:GetShowSpineAndVoice()
  if not spineStr then
    return
  end
  if voice and voice ~= "" then
    UILuaHelper.StartPlaySFX(voice)
  end
  self:LoadHeroSpine(spineStr, "battlewin", self.m_hero_root)
end

function Form_BossBattleVictory:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
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

function Form_BossBattleVictory:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_BossBattleVictory:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_BossBattleVictory:OnBtnBgCloseClicked()
  self:CloseForm()
  if self.m_isSweep ~= true then
    BattleFlowManager:ExitBattle()
  end
end

function Form_BossBattleVictory:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

function Form_BossBattleVictory:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroID = tParam.showHeroID
  if not heroID then
    local showHeroDataList = HeroManager:GetTopFiveHeroByCombat()
    local randomIndex = self:GetRandom(1, #showHeroDataList)
    heroID = showHeroDataList[randomIndex].characterCfg.m_HeroID
    tParam.showHeroID = heroID
  end
  vPackage[#vPackage + 1] = {
    sName = tostring(heroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

function Form_BossBattleVictory:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BossBattleVictory", Form_BossBattleVictory)
return Form_BossBattleVictory
