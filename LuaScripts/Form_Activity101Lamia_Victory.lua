local Form_Activity101Lamia_Victory = class("Form_Activity101Lamia_Victory", require("UI/UIFrames/Form_Activity101Lamia_VictoryUI"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local ActLamiaBonusChaIns = ConfigManager:GetConfigInsByName("ActLamiaBonusCha")

function Form_Activity101Lamia_Victory:SetInitParam(param)
end

function Form_Activity101Lamia_Victory:AfterInit()
  self.super.AfterInit(self)
  self.m_itemDataList = nil
  self.m_rewardItemBase = self.m_reward_root.transform:Find("c_common_item")
  self.m_ItemNodeList = {}
  local itemNode = self:CreateItemNode(self.m_rewardItemBase)
  self.m_itemNameStr = self.m_rewardItemBase.name
  self.m_ItemNodeList[#self.m_ItemNodeList + 1] = itemNode
  UILuaHelper.SetActive(self.m_rewardItemBase, false)
  self.m_activityID = nil
  self.m_subActivityID = nil
  self.m_levelType = nil
  self.m_curLevelID = nil
  self.m_csRewardList = nil
  self.m_csFirstRewardList = nil
  self.m_csExRewardList = nil
  self.m_actSubType = nil
  self.m_heroAddExtraCfgDic = nil
  self.m_heroTopBonus = nil
  self.m_finishErrorCode = nil
  self.m_isSweep = nil
  self.m_showHeroID = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_Activity101Lamia_Victory:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_Activity101Lamia_Victory:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
end

function Form_Activity101Lamia_Victory:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_Activity101Lamia_Victory:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_levelType = tParam.levelType
    self.m_activityID = tParam.activityID
    self.m_curLevelID = tParam.levelID
    self.m_csFirstRewardList = tParam.firstReward
    self.m_csRewardList = tParam.rewardData
    self.m_csExRewardList = tParam.extraReward
    self.m_finishErrorCode = tParam.finishErrorCode
    self.m_showHeroID = tParam.showHeroID
    self.m_isSweep = tParam.isSweep
    self.m_actSubType = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(self.m_curLevelID)
    self:FreshRewardListData()
    self.m_csui.m_param = nil
  end
end

function Form_Activity101Lamia_Victory:FreshRewardListData()
  if not self.m_csRewardList then
    return
  end
  self.m_itemDataList = {}
  if self.m_csFirstRewardList then
    for _, rewardCsData in pairs(self.m_csFirstRewardList) do
      if rewardCsData then
        local tempReward = {
          iID = rewardCsData.iID,
          iNum = rewardCsData.iNum,
          isExtra = false,
          isFirst = true
        }
        self.m_itemDataList[#self.m_itemDataList + 1] = tempReward
      end
    end
  end
  if self.m_csExRewardList then
    for _, rewardCsData in pairs(self.m_csExRewardList) do
      if rewardCsData then
        local tempReward = {
          iID = rewardCsData.iID,
          iNum = rewardCsData.iNum,
          isExtra = true,
          isFirst = false
        }
        self.m_itemDataList[#self.m_itemDataList + 1] = tempReward
      end
    end
  end
  for _, rewardCsData in pairs(self.m_csRewardList) do
    if rewardCsData then
      local tempReward = {
        iID = rewardCsData.iID,
        iNum = rewardCsData.iNum,
        isExtra = false,
        isFirst = false
      }
      self.m_itemDataList[#self.m_itemDataList + 1] = tempReward
    end
  end
end

function Form_Activity101Lamia_Victory:ClearCacheData()
  self.m_activityID = nil
  self.m_subActivityID = nil
  self.m_curLevelID = nil
  self.m_levelType = nil
  self.m_actSubType = nil
  self.m_csRewardList = nil
  self.m_csFirstRewardList = nil
  self.m_csExRewardList = nil
  self.m_heroAddExtraCfgDic = nil
  self.m_heroTopBonus = nil
  self.m_finishErrorCode = nil
  self.m_isSweep = nil
end

function Form_Activity101Lamia_Victory:InsertTopFive(bonusData)
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

function Form_Activity101Lamia_Victory:FreshHeroBonusData()
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
      config = v,
      characterCfg = nil
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
      tempBonusData.characterCfg = heroData.characterCfg
      self:InsertTopFive(tempBonusData)
    end
  end
end

function Form_Activity101Lamia_Victory:GetRandom(beginIndex, endIndex)
  if not beginIndex then
    return
  end
  if not endIndex then
    return
  end
  math.newrandomseed()
  return math.random(beginIndex, endIndex)
end

function Form_Activity101Lamia_Victory:GetSpineHeroID()
  if self.m_showHeroID ~= nil then
    return self.m_showHeroID
  end
  local showHeroDataList
  if self.m_actSubType ~= HeroActivityManager.SubActTypeEnum.ChallengeLevel then
    showHeroDataList = HeroManager:GetHeroList()
  else
    self:FreshHeroBonusData()
    if #self.m_heroTopBonus <= 0 then
      showHeroDataList = HeroManager:GetHeroList()
    else
      showHeroDataList = self.m_heroTopBonus
    end
  end
  local randomIndex = self:GetRandom(1, #showHeroDataList)
  return showHeroDataList[randomIndex].characterCfg.m_HeroID
end

function Form_Activity101Lamia_Victory:GetShowSpineAndVoice()
  if not self.m_curLevelID then
    return
  end
  local levelCfg = LevelHeroLamiaActivityManager:GetLevelHelper():GetLevelCfgByID(self.m_curLevelID)
  if not levelCfg then
    return
  end
  local heroID = levelCfg.m_Settlement
  local heroCfg
  if heroID == nil or heroID == 0 then
    heroID = self:GetSpineHeroID()
  end
  if not heroID then
    return
  end
  heroCfg = HeroManager:GetHeroConfigByID(heroID)
  if not heroCfg then
    return
  end
  local voice = HeroManager:GetHeroBattleVictoryVoice(heroID)
  local spineStr = heroCfg.m_Spine
  if not spineStr then
    return
  end
  return spineStr, voice
end

function Form_Activity101Lamia_Victory:AddEventListeners()
end

function Form_Activity101Lamia_Victory:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Activity101Lamia_Victory:FreshUI()
  self:FreshRewardItems()
  self:FreshShowSpine()
  self:FreshIsSweep()
end

function Form_Activity101Lamia_Victory:FreshIsSweep()
  UILuaHelper.SetActive(self.m_btn_Data, self.m_isSweep ~= true)
end

function Form_Activity101Lamia_Victory:CreateItemNode(itemObj)
  if not itemObj then
    return
  end
  local widget = self:createCommonItem(itemObj)
  widget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  local firstTag = itemObj.transform:Find("m_img_first_tag")
  local extraTag = itemObj.transform:Find("m_img_bonus_tag")
  return {
    widget = widget,
    firstTag = firstTag,
    extraTag = extraTag
  }
end

function Form_Activity101Lamia_Victory:FreshItemNodeShow(itemNode, itemData)
  local itemWidget = itemNode.widget
  local processItemData = ResourceUtil:GetProcessRewardData(itemData)
  itemWidget:SetItemInfo(processItemData)
  UILuaHelper.SetActive(itemNode.firstTag, itemData.isFirst == true)
  UILuaHelper.SetActive(itemNode.extraTag, itemData.isExtra == true)
end

function Form_Activity101Lamia_Victory:FreshRewardItems()
  if not self.m_itemDataList then
    return
  end
  local itemNodes = self.m_ItemNodeList
  local dataLen = #self.m_itemDataList
  local parentTrans = self.m_reward_root
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      self:FreshItemNodeShow(itemNode, self.m_itemDataList[i])
      itemNode.widget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_rewardItemBase, parentTrans.transform).gameObject
      itemObj.name = self.m_itemNameStr .. i
      local itemNode = self:CreateItemNode(itemObj)
      itemNodes[#itemNodes + 1] = itemNode
      local itemData = self.m_itemDataList[i]
      self:FreshItemNodeShow(itemNode, itemData)
      itemNode.widget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemNodes[i].widget:SetActive(false)
    end
  end
end

function Form_Activity101Lamia_Victory:FreshShowSpine()
  local spineStr, voice = self:GetShowSpineAndVoice()
  if not spineStr then
    return
  end
  if voice and voice ~= "" then
    UILuaHelper.StartPlaySFX(voice)
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

function Form_Activity101Lamia_Victory:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_Activity101Lamia_Victory:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_Activity101Lamia_Victory:OnBtnBgCloseClicked()
  self:CloseForm()
  if self.m_isSweep ~= true then
    BattleFlowManager:ExitBattle()
  end
end

function Form_Activity101Lamia_Victory:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

function Form_Activity101Lamia_Victory:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroID = tParam.showHeroID
  vPackage[#vPackage + 1] = {
    sName = tostring(heroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

function Form_Activity101Lamia_Victory:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_Victory", Form_Activity101Lamia_Victory)
return Form_Activity101Lamia_Victory
