local Form_HuntingNightVictory = class("Form_HuntingNightVictory", require("UI/UIFrames/Form_HuntingNightVictoryUI"))

function Form_HuntingNightVictory:SetInitParam(param)
end

function Form_HuntingNightVictory:AfterInit()
  self.super.AfterInit(self)
  self.m_showHeroID = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_HuntingNightVictory:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_levelType = tParam.levelType
    self.m_curLevelID = tParam.levelID
    self.m_showHeroID = tParam.showHeroID
    self.m_battleResult = tParam.battleResult
    self.m_csui.m_param = nil
  end
  self:RefreshUI()
end

function Form_HuntingNightVictory:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
end

function Form_HuntingNightVictory:RefreshUI()
  self:FreshShowSpine()
  local curDamage = HuntingRaidManager:GetBossRealDamageByIdAndServerDamage(self.m_battleResult.iBossId, self.m_battleResult.iCurDamage)
  self.m_txt_damage_Text.text = curDamage
  if not curDamage or curDamage == "0" or curDamage == 0 then
    self.m_pnl_damage:SetActive(false)
  else
    self.m_pnl_damage:SetActive(true)
  end
  local damage = HuntingRaidManager:GetBossRealDamageByIdAndServerDamage(self.m_battleResult.iBossId, self.m_battleResult.iDamage)
  if not damage or damage == "0" or damage == 0 then
    self.m_txt_damage_num_Text.text = ConfigManager:GetCommonTextById(20347)
  else
    self.m_txt_damage_num_Text.text = damage
  end
  local flag = HuntingRaidManager:CompareDamage(self.m_battleResult.iBossId, self.m_battleResult.iCurDamage, self.m_battleResult.iDamage)
  UILuaHelper.SetActive(self.m_icon_new, flag)
  local bossCfg = HuntingRaidManager:GetHuntingRaidBossCfgById(self.m_battleResult.iBossId)
  if bossCfg then
    self.m_txt_damage_desc_Text.text = tostring(bossCfg.m_mTitle1)
    self.m_txt_damage_title_Text.text = tostring(bossCfg.m_mTitle2)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_txt_damage_title)
end

function Form_HuntingNightVictory:GetSpineHeroID()
  if self.m_showHeroID ~= nil then
    return self.m_showHeroID
  end
  local showHeroDataList = HeroManager:GetTopFiveHeroByCombat()
  local randomIndex = self:GetRandom(1, #showHeroDataList)
  return showHeroDataList[randomIndex].characterCfg.m_HeroID
end

function Form_HuntingNightVictory:GetShowSpineAndVoice()
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

function Form_HuntingNightVictory:FreshShowSpine()
  local spineStr, voice = self:GetShowSpineAndVoice()
  if not spineStr then
    return
  end
  if voice and voice ~= "" then
    UILuaHelper.StartPlaySFX(voice)
  end
  self:LoadHeroSpine(spineStr, "battlewin", self.m_hero_root)
end

function Form_HuntingNightVictory:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
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

function Form_HuntingNightVictory:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HuntingNightVictory:GetRandom(beginIndex, endIndex)
  if not beginIndex then
    return
  end
  if not endIndex then
    return
  end
  math.newrandomseed()
  return math.random(beginIndex, endIndex)
end

function Form_HuntingNightVictory:OnBtnBgCloseClicked()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_HuntingNightVictory:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

function Form_HuntingNightVictory:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HuntingNightVictory:GetDownloadResourceExtra(tParam)
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

function Form_HuntingNightVictory:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HuntingNightVictory", Form_HuntingNightVictory)
return Form_HuntingNightVictory
