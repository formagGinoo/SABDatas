local BaseManagerHelper = require("Manager/Base/BaseManagerHelper")
local HeroVoice = class("HeroVoice", BaseManagerHelper)
local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
local AttractVoiceTextCfgIns = ConfigManager:GetConfigInsByName("AttractVoiceText")

function HeroVoice:ctor()
  HeroVoice.super.ctor(self)
  self.m_HeroFashion = HeroManager:GetHeroFashion()
end

function HeroVoice:GetHeroGainVoice(heroId, fashionID)
  if not heroId then
    return
  end
  fashionID = fashionID or 0
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroId, fashionID)
  if not fashionInfo then
    return
  end
  if not fashionInfo.m_PerformanceID then
    return
  end
  local m_PerformanceID = fashionInfo.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_GainVoice then
    return
  end
  return presentationData.m_GainVoice
end

function HeroVoice:GetHeroLevelUpVoice(heroId, fashionID)
  if not heroId then
    return
  end
  fashionID = fashionID or 0
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroId, fashionID)
  if not fashionInfo then
    return
  end
  if not fashionInfo.m_PerformanceID then
    return
  end
  local m_PerformanceID = fashionInfo.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_LevelupVoice then
    return
  end
  local voiceList = string.split(presentationData.m_LevelupVoice, ";")
  if 0 < #voiceList then
    local random = math.random(1, #voiceList)
    return voiceList[random]
  end
end

function HeroVoice:GetHeroTransfusionVoice(heroId, fashionID)
  if not heroId then
    return
  end
  fashionID = fashionID or 0
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroId, fashionID)
  if not fashionInfo then
    return
  end
  if not fashionInfo.m_PerformanceID then
    return
  end
  local m_PerformanceID = fashionInfo.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_CharTransfusionVoice then
    return
  end
  return presentationData.m_CharTransfusionVoice
end

function HeroVoice:GetHeroDisPatchVoice(heroId, fashionID)
  if not heroId then
    return
  end
  fashionID = fashionID or 0
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroId, fashionID)
  if not fashionInfo then
    return
  end
  if not fashionInfo.m_PerformanceID then
    return
  end
  local m_PerformanceID = fashionInfo.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_CharDispatchVoice then
    return
  end
  return presentationData.m_CharDispatchVoice
end

function HeroVoice:GetHeroIdleVoice(heroId, fashionID)
  fashionID = fashionID or 0
  if not self.m_HeroFashion then
    return
  end
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroId, fashionID)
  if not fashionInfo then
    return
  end
  if not fashionInfo or not fashionInfo.m_PerformanceID then
    return
  end
  local m_PerformanceID = fashionInfo.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_CharIdleVoice then
    return
  end
  return presentationData.m_CharIdleVoice
end

function HeroVoice:GetHeroFavorLeveuUpVoice(heroId, fashionID)
  fashionID = fashionID or 0
  if not self.m_HeroFashion then
    return
  end
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroId, fashionID)
  if not fashionInfo then
    return
  end
  if not fashionInfo.m_PerformanceID then
    return
  end
  local m_PerformanceID = fashionInfo.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_CharAffinityUpVoice then
    return
  end
  local voiceTxtId = presentationData.m_CharAffinityUpVoiceID
  local vVoiceTextList = AttractVoiceTextCfgIns:GetValue_ByVoiceId(tonumber(voiceTxtId))
  local vVoiceTextListLua = {}
  for k2, v2 in pairs(vVoiceTextList) do
    vVoiceTextListLua[k2] = v2
  end
  local firstId = 1
  local firstText = vVoiceTextListLua[firstId]
  return presentationData.m_CharAffinityUpVoice, firstText.m_mText or ""
end

function HeroVoice:GetHeroFavorLeveuUpMaxVoice(heroId, fashionID)
  fashionID = fashionID or 0
  if not self.m_HeroFashion then
    return
  end
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroId, fashionID)
  if not fashionInfo then
    return
  end
  if not fashionInfo.m_PerformanceID then
    return
  end
  local m_PerformanceID = fashionInfo.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_CharAffinityMaxVoice then
    return
  end
  local voiceTxtId = presentationData.m_CharAffinityMaxVoiceID
  local vVoiceTextList = AttractVoiceTextCfgIns:GetValue_ByVoiceId(tonumber(voiceTxtId))
  local vVoiceTextListLua = {}
  for k2, v2 in pairs(vVoiceTextList) do
    vVoiceTextListLua[k2] = v2
  end
  local firstId = 1
  local firstText = vVoiceTextListLua[firstId]
  return presentationData.m_CharAffinityMaxVoice, firstText.m_mText or ""
end

function HeroVoice:GetHeroBreakVoice(heroId, fashionID)
  fashionID = fashionID or 0
  if not self.m_HeroFashion then
    return
  end
  local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroId, fashionID)
  if not fashionInfo then
    return
  end
  if not fashionInfo.m_PerformanceID then
    return
  end
  local m_PerformanceID = fashionInfo.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_BreakVoice then
    return
  end
  return presentationData.m_BreakVoice
end

function HeroVoice:GetHeroBattleVictoryVoice(fashionInfo)
  if not fashionInfo then
    return
  end
  if not fashionInfo.m_PerformanceID then
    return
  end
  local m_PerformanceID = fashionInfo.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_WinVoice then
    return
  end
  return presentationData.m_WinVoice
end

return HeroVoice
