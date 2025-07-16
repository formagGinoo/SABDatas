local Form_RogueBattleVictory = class("Form_RogueBattleVictory", require("UI/UIFrames/Form_RogueBattleVictoryUI"))
local __InAnimList = {
  "Roguebattle_point_in",
  "Roguebattle_point_in2",
  "Roguebattle_point_in3",
  "Roguebattle_point_in4",
  "Roguebattle_point_in5"
}
local __LoopAnimList = {
  "Roguebattle_point_loop",
  "Roguebattle_point_loop2",
  "Roguebattle_point_loop3",
  "Roguebattle_point_loop4",
  "Roguebattle_point_loop5"
}

function Form_RogueBattleVictory:SetInitParam(param)
end

function Form_RogueBattleVictory:AfterInit()
  self.super.AfterInit(self)
  self.m_showHeroID = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_rogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_text_color_list = {}
  for i = 1, 5 do
    self.m_text_color_list[#self.m_text_color_list + 1] = self["m_z_txt_num" .. i .. "_Text"]:GetComponent("MultiColorChange")
  end
end

function Form_RogueBattleVictory:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_levelType = tParam.levelType
    self.m_curLevelID = tParam.levelID
    self.m_showHeroID = tParam.showHeroID
    self.m_iScore = tParam.iScore
    self.m_csui.m_param = nil
  end
  self.m_my_gear = self.m_rogueStageHelper:GetRogueStageGearByIdAndKillCount(self.m_curLevelID, self.m_iScore) or 0
  self:RefreshUI()
  self:AddEventListeners()
  RogueStageManager:ResetRogueBagData()
  self:StopSequence()
  self:EnterAnim()
end

function Form_RogueBattleVictory:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine()
  self:RemoveAllEventListeners()
  self.m_curLevelID = nil
  self.m_levelType = nil
  self:StopSequence()
end

function Form_RogueBattleVictory:StopSequence()
  if self.m_sequence then
    self.m_sequence:Kill()
    self.m_sequence = nil
  end
  if self.m_sequence2 then
    self.m_sequence2:Kill()
    self.m_sequence2 = nil
  end
  if self.m_sequence3 then
    self.m_sequence3:Kill()
    self.m_sequence3 = nil
  end
end

function Form_RogueBattleVictory:AddEventListeners()
  self:addEventListener("eGameEvent_RogueStageFinishExitBattle", handler(self, self.OnBtnBgCloseClicked))
end

function Form_RogueBattleVictory:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_RogueBattleVictory:RefreshUI()
  self:FreshShowSpine()
  local maxGear = self.m_rogueStageHelper:GetStageRewardMaxGear(self.m_curLevelID)
  local myKeyLv = self.m_rogueStageHelper:GetDailyRewardLevel()
  local gearMin, gearMax = self.m_rogueStageHelper:GetRogueStageGearRangeById(self.m_curLevelID)
  for i = 1, 5 do
    self["m_pnl_point" .. i]:SetActive(i <= maxGear)
    local keyLv = gearMin + i - 1
    if not utils.isNull(self.m_text_color_list[i]) then
      local index = keyLv >= self.m_my_gear and 1 or 0
      self.m_text_color_list[i]:SetColorByIndex(index)
    end
    if gearMin then
      self["m_z_txt_num" .. i .. "_Text"].text = keyLv
    end
  end
  self.m_key_num_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100074), myKeyLv)
  local curRewardCfg = self.m_rogueStageHelper:GetRogueStageRewardGroupCfgListByLv(myKeyLv)
  if curRewardCfg then
    UILuaHelper.SetAtlasSprite(self.m_img_key_icon_Image, curRewardCfg.m_KeyPic, function()
      if self and not utils.isNull(self.m_img_key_icon_Image) then
        self.m_img_key_icon_Image:SetNativeSize()
      end
    end)
  end
end

function Form_RogueBattleVictory:EnterAnim()
  UILuaHelper.SetActive(self.m_UIFX_battle_key_Unlock, false)
  local gear = self.m_my_gear
  if gear and __InAnimList[gear] then
    self.m_sequence = Tweening.DOTween.Sequence()
    self.m_sequence:AppendInterval(0.3)
    self.m_sequence:OnComplete(function()
      if not utils.isNull(self.m_pnl_stage_point) and __InAnimList[gear] then
        UILuaHelper.PlayAnimationByName(self.m_pnl_stage_point, __InAnimList[gear])
        UILuaHelper.PlayAnimationByName(self.m_pnl_stage_point, __LoopAnimList[gear])
      end
    end)
    self.m_sequence:SetAutoKill(true)
    local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_stage_point, __InAnimList[gear])
    self.m_sequence2 = Tweening.DOTween.Sequence()
    self.m_sequence2:AppendInterval(detailAnimLen)
    self.m_sequence2:OnComplete(function()
      if not utils.isNull(self.m_pnl_stage_point) and __LoopAnimList[gear] then
        UILuaHelper.PlayAnimationByName(self.m_pnl_stage_point, __LoopAnimList[gear])
      end
    end)
    self.m_sequence2:SetAutoKill(true)
    self.m_sequence3 = Tweening.DOTween.Sequence()
    self.m_sequence3:AppendInterval(0.5)
    self.m_sequence3:OnComplete(function()
      if not utils.isNull(self.m_UIFX_battle_key_Unlock) then
        UILuaHelper.SetActive(self.m_UIFX_battle_key_Unlock, true)
      end
    end)
    self.m_sequence3:SetAutoKill(true)
  end
end

function Form_RogueBattleVictory:GetSpineHeroID()
  if self.m_showHeroID ~= nil then
    return self.m_showHeroID
  end
  local showHeroDataList = HeroManager:GetTopFiveHeroByCombat()
  local randomIndex = self:GetRandom(1, #showHeroDataList)
  return showHeroDataList[randomIndex].characterCfg.m_HeroID
end

function Form_RogueBattleVictory:GetShowSpineAndVoice()
  local heroID = self:GetSpineHeroID()
  local heroCfg
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

function Form_RogueBattleVictory:FreshShowSpine()
  local spineStr, voice = self:GetShowSpineAndVoice()
  if not spineStr then
    return
  end
  if voice and voice ~= "" then
    UILuaHelper.StartPlaySFX(voice)
  end
  self:LoadHeroSpine(spineStr, "battlewin", self.m_hero_root)
end

function Form_RogueBattleVictory:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
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

function Form_RogueBattleVictory:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_RogueBattleVictory:GetRandom(beginIndex, endIndex)
  if not beginIndex then
    return
  end
  if not endIndex then
    return
  end
  math.newrandomseed()
  return math.random(beginIndex, endIndex)
end

function Form_RogueBattleVictory:OnBtngetrewardClicked()
  BattleGlobalManager:RogueClaimRewardsSendMessage(true)
end

function Form_RogueBattleVictory:OnBtngiveupClicked()
  BattleGlobalManager:RogueClaimRewardsSendMessage(false)
end

function Form_RogueBattleVictory:OnBtnBgCloseClicked()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_RogueBattleVictory:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

function Form_RogueBattleVictory:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RogueBattleVictory:GetDownloadResourceExtra(tParam)
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

function Form_RogueBattleVictory:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RogueBattleVictory", Form_RogueBattleVictory)
return Form_RogueBattleVictory
