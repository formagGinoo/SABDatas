local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
local HeroGuideHelper = class("HeroGuideHelper")

function HeroGuideHelper:ctor()
  self.m_heroGuideList = {}
end

function HeroGuideHelper:InitAllHeroGuideList()
  local characterAll = CharacterInfoIns:GetAll()
  local heroGuideDataList = {}
  for _, tempCfg in pairs(characterAll) do
    local heroData = HeroManager:GetHeroDataByID(tempCfg.m_HeroID)
    local timeNum = heroData ~= nil and heroData.serverData.iTime or 0
    local heroSkillList = self:GetLocalHeroSKills(tempCfg.m_HeroID, tempCfg.m_SkillGroupID[0])
    local guideBreakNum = self:GetGuideBreakNumByHeroCfg(tempCfg)
    local maxLevelNum = self:GetHeroMaxLvByHeroCfgAndBreak(tempCfg, guideBreakNum)
    local powerNum = HeroManager:GetHeroAttr():GetHeroPower(tempCfg.m_HeroID, maxLevelNum, guideBreakNum, heroSkillList)
    local tempData = {
      serverData = {
        iHeroId = tempCfg.m_HeroID,
        iBreak = guideBreakNum,
        iLevel = maxLevelNum,
        iTime = timeNum,
        iPower = powerNum
      },
      characterCfg = tempCfg,
      isHave = HeroManager:GetHeroDataByID(tempCfg.m_HeroID) ~= nil
    }
    heroGuideDataList[#heroGuideDataList + 1] = tempData
  end
  self.m_heroGuideList = heroGuideDataList
end

function HeroGuideHelper:FreshHeroGuideIsHave(heroData)
  if not heroData then
    return
  end
  if not self.m_heroGuideList then
    return
  end
  for i, v in ipairs(self.m_heroGuideList) do
    if v.serverData.iHeroId == heroData.serverData.iHeroId then
      v.isHave = true
    end
  end
end

function HeroGuideHelper:GetHeroGuideList()
  if not self.m_heroGuideList then
    return {}
  end
  local tempGuidList = {}
  for i, v in ipairs(self.m_heroGuideList) do
    local tempCfg = v.characterCfg
    local isHide = HeroManager:IsHeroHide(tempCfg)
    if isHide ~= true then
      tempGuidList[#tempGuidList + 1] = v
    end
  end
  return tempGuidList
end

function HeroGuideHelper:GetLocalHeroSKills(heroID, skillGroupID)
  local skillTab = {}
  local skillGroupCfgList = HeroManager:GetSkillGroupCfgList(skillGroupID)
  if skillGroupCfgList then
    for _, skillGroupCfg in ipairs(skillGroupCfgList) do
      local skillID = skillGroupCfg.m_SkillID
      if skillID then
        local skillLv = HeroManager:GetHeroSkillMaxLvById(heroID, skillID) or 1
        skillTab[skillID] = skillLv
      end
    end
  end
  return skillTab
end

function HeroGuideHelper:GetHeroMaxLvByHeroCfgAndBreak(heroCfg, breakNum)
  local heroCheckBreakNum = breakNum
  local breakQuality = heroCfg.m_Quality
  local limitBreakCfg = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplateAndLimitBreakLevel(breakQuality, heroCheckBreakNum)
  if limitBreakCfg:GetError() then
    return
  end
  return limitBreakCfg.m_MaxLevel
end

function HeroGuideHelper:GetGuideBreakNumByHeroCfg(heroCfg)
  if not heroCfg then
    return
  end
  local qualityNum = heroCfg.m_Quality
  local breakNum = 0
  if qualityNum == HeroManager.QualityType.SR then
    breakNum = HeroManager.SRBreakNum
  elseif qualityNum == HeroManager.QualityType.SSR then
    breakNum = HeroManager.MaxBreakNew
  end
  return breakNum
end

return HeroGuideHelper
