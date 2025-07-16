local HeroAttr = class("HeroAttr")
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local CharacterLevelTemplateIns = ConfigManager:GetConfigInsByName("CharacterLevelTemplate")
local PropertyIns = ConfigManager:GetConfigInsByName("Property")
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
local CirculationTypeIns = ConfigManager:GetConfigInsByName("CirculationType")
local CirculationLevelIns = ConfigManager:GetConfigInsByName("CirculationLevel")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local AttractAddIns = ConfigManager:GetConfigInsByName("AttractAdd")
local string_format = string.format
AttrBaseShowCfg = {
  [1] = true,
  [2] = true,
  [3] = true,
  [4] = true
}

function HeroAttr:ctor()
  self.m_levelTemplateCache = {}
end

function HeroAttr:GetLevelTemplateGroup(levelTemplate)
  if not levelTemplate then
    return
  end
  if self.m_levelTemplateCache[levelTemplate] then
    return self.m_levelTemplateCache[levelTemplate]
  end
  local characterLevelTemplateCfgDic = {}
  local levelTemplateGroupCfg = CharacterLevelTemplateIns:GetValue_ByLevelTemplate(levelTemplate)
  if levelTemplateGroupCfg then
    for _, levelTemplateCfg in pairs(levelTemplateGroupCfg) do
      local otherPropertyCfg
      if levelTemplateCfg.m_PropertyID and levelTemplateCfg.m_PropertyID ~= 0 then
        otherPropertyCfg = PropertyIns:GetValue_ByPropertyID(levelTemplateCfg.m_PropertyID)
      end
      local tempCfg = {levelTemplateCfg = levelTemplateCfg, otherPropertyCfg = otherPropertyCfg}
      characterLevelTemplateCfgDic[levelTemplateCfg.m_Level] = tempCfg
    end
  end
  self.m_levelTemplateCache[levelTemplate] = characterLevelTemplateCfgDic
  return self.m_levelTemplateCache[levelTemplate]
end

function HeroAttr:GetHeroLevelMax(heroID)
  if not heroID then
    return
  end
  local characterInfoCfg = CharacterInfoIns:GetValue_ByHeroID(heroID)
  local levelTemplateID = characterInfoCfg.m_LevelTemplateID
  local levelTemplateGroupCfg = self:GetLevelTemplateGroup(levelTemplateID)
  if not levelTemplateGroupCfg then
    return
  end
  return #levelTemplateGroupCfg
end

function HeroAttr:GetLimitBreakPropertyCfg(limitBreakCfg, breakType)
  if not limitBreakCfg then
    return
  end
  local paramStr = breakType == HeroManager.BreakTypeEnum.Normal and "m_PropertyID" or "m_PropertyID2"
  local breakOtherPropertyCfg = PropertyIns:GetValue_ByPropertyID(limitBreakCfg[paramStr] or 0)
  if breakOtherPropertyCfg:GetError() then
    breakOtherPropertyCfg = {}
  end
  return breakOtherPropertyCfg
end

function HeroAttr:GetLimitBreakParam(limitBreakCfg, breakType, paramStr)
  if not limitBreakCfg then
    return
  end
  local breakParamStr = breakType == HeroManager.BreakTypeEnum.Normal and "m_%sParam" or "m_%sParam2"
  local limitBreakParam = 10000
  if limitBreakCfg[string_format(breakParamStr, paramStr)] then
    limitBreakParam = limitBreakCfg[string_format(breakParamStr, paramStr)]
  end
  limitBreakParam = limitBreakParam / 10000
  return limitBreakParam
end

function HeroAttr:GetLvBreakBaseAttr(heroID, level, breakNum, circulationParamTab, attractRank)
  if not heroID then
    return
  end
  if not level then
    return
  end
  breakNum = breakNum or 0
  local characterInfoCfg = CharacterInfoIns:GetValue_ByHeroID(heroID)
  local basePropertyID = characterInfoCfg.m_PropertyID
  local basePropertyCfg = PropertyIns:GetValue_ByPropertyID(basePropertyID)
  local levelTemplateID = characterInfoCfg.m_LevelTemplateID
  local levelTemplateGroupCfg = self:GetLevelTemplateGroup(levelTemplateID)
  local tempLevelCfg = levelTemplateGroupCfg[level]
  local breakTemplateID = characterInfoCfg.m_Quality
  local limitBreakCfg = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplateAndLimitBreakLevel(breakTemplateID, breakNum)
  if limitBreakCfg:GetError() then
    limitBreakCfg = {}
  end
  local breakType = limitBreakCfg.m_Type or HeroManager.BreakTypeEnum.Normal
  local limitBreakOtherPropertyCfg = self:GetLimitBreakPropertyCfg(limitBreakCfg, HeroManager.BreakTypeEnum.Normal)
  local overLimitBreakOtherPropertyCfg
  if breakType == HeroManager.BreakTypeEnum.OverLimit then
    overLimitBreakOtherPropertyCfg = self:GetLimitBreakPropertyCfg(limitBreakCfg, HeroManager.BreakTypeEnum.OverLimit)
  end
  local circulationAttrTab = self:GetCirculationAttrByParams(circulationParamTab) or {}
  local attractAttrTab = self:GetAttractAttr(characterInfoCfg.m_AttractAddTemplate, attractRank) or {}
  local retParamTab = {}
  if tempLevelCfg then
    local levelTemplateCfg = tempLevelCfg.levelTemplateCfg
    local otherPropertyCfg = tempLevelCfg.otherPropertyCfg
    for key, _ in pairs(AttrBaseShowCfg) do
      local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(key)
      local paramStr = propertyIndexCfg.m_ENName
      local basePropertyNum = basePropertyCfg["m_" .. paramStr]
      local basePropertyRate = basePropertyCfg[string_format("m_Lv_%s_Rate", paramStr)]
      local otherPropertyNum = 0
      local otherPropertyRate = 0
      if otherPropertyCfg then
        otherPropertyNum = otherPropertyCfg["m_" .. paramStr]
        otherPropertyRate = otherPropertyCfg[string_format("m_Lv_%s_Rate", paramStr)]
      end
      local limitBreakParam = self:GetLimitBreakParam(limitBreakCfg, HeroManager.BreakTypeEnum.Normal, paramStr)
      local breakOtherPropertyNum = 0
      if limitBreakOtherPropertyCfg then
        breakOtherPropertyNum = limitBreakOtherPropertyCfg["m_" .. paramStr]
      end
      local levelTemplateParam = levelTemplateCfg[string_format("m_%sParam", paramStr)]
      local paramNum = basePropertyNum + otherPropertyNum + (basePropertyRate + otherPropertyRate) / 10000 * levelTemplateParam
      paramNum = paramNum * limitBreakParam + breakOtherPropertyNum
      paramNum = paramNum + (circulationAttrTab[paramStr] or 0)
      paramNum = paramNum + (attractAttrTab[paramStr] or 0)
      if breakType == HeroManager.BreakTypeEnum.OverLimit then
        local overLimitBreakParam = self:GetLimitBreakParam(limitBreakCfg, HeroManager.BreakTypeEnum.OverLimit, paramStr)
        local overBreakOtherPropertyNum = 0
        if overLimitBreakOtherPropertyCfg then
          overBreakOtherPropertyNum = overLimitBreakOtherPropertyCfg["m_" .. paramStr]
        end
        paramNum = paramNum * overLimitBreakParam + overBreakOtherPropertyNum
      end
      retParamTab[paramStr] = paramNum
    end
  end
  return retParamTab
end

function HeroAttr:GetLvBreakAllAttr(heroID, level, breakNum, circulationParamTab, attractRank)
  if not heroID then
    return
  end
  if not level then
    return
  end
  breakNum = breakNum or 0
  local characterInfoCfg = CharacterInfoIns:GetValue_ByHeroID(heroID)
  local basePropertyID = characterInfoCfg.m_PropertyID
  local basePropertyCfg = PropertyIns:GetValue_ByPropertyID(basePropertyID)
  local levelTemplateID = characterInfoCfg.m_LevelTemplateID
  local levelTemplateGroupCfg = self:GetLevelTemplateGroup(levelTemplateID)
  local tempLevelCfg = levelTemplateGroupCfg[level]
  local breakTemplateID = characterInfoCfg.m_Quality
  local limitBreakCfg = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplateAndLimitBreakLevel(breakTemplateID, breakNum)
  if limitBreakCfg:GetError() then
    limitBreakCfg = {}
  end
  local breakType = limitBreakCfg.m_Type or HeroManager.BreakTypeEnum.Normal
  local limitBreakOtherPropertyCfg = self:GetLimitBreakPropertyCfg(limitBreakCfg, HeroManager.BreakTypeEnum.Normal)
  local overLimitBreakOtherPropertyCfg
  if breakType == HeroManager.BreakTypeEnum.OverLimit then
    overLimitBreakOtherPropertyCfg = self:GetLimitBreakPropertyCfg(limitBreakCfg, HeroManager.BreakTypeEnum.OverLimit)
  end
  local circulationAttrTab = self:GetCirculationAttrByParams(circulationParamTab) or {}
  local attractAttrTab = self:GetAttractAttr(characterInfoCfg.m_AttractAddTemplate, attractRank) or {}
  local retParamTab = {}
  if tempLevelCfg then
    local levelTemplateCfg = tempLevelCfg.levelTemplateCfg
    local otherPropertyCfg = tempLevelCfg.otherPropertyCfg
    local allPropertyIndexCfg = PropertyIndexIns:GetAll()
    for _, propertyIndexCfg in pairs(allPropertyIndexCfg) do
      if propertyIndexCfg and propertyIndexCfg.m_Compute == 1 then
        local paramStr = propertyIndexCfg.m_ENName
        local basePropertyNum = basePropertyCfg["m_" .. paramStr]
        local otherPropertyNum = 0
        if otherPropertyCfg then
          otherPropertyNum = otherPropertyCfg["m_" .. paramStr]
        end
        local circulationPropertyNum = circulationAttrTab[paramStr] or 0
        local attractPropertyNum = attractAttrTab[paramStr] or 0
        local levelTemplateParam = levelTemplateCfg[string_format("m_%sParam", paramStr)]
        local breakOtherPropertyNum = 0
        if limitBreakOtherPropertyCfg then
          breakOtherPropertyNum = limitBreakOtherPropertyCfg["m_" .. paramStr] or 0
        end
        local overBreakOtherPropertyNum = 0
        if breakType == HeroManager.BreakTypeEnum.OverLimit and overLimitBreakOtherPropertyCfg then
          overBreakOtherPropertyNum = overLimitBreakOtherPropertyCfg["m_" .. paramStr] or 0
        end
        local paramNum = 0
        if AttrBaseShowCfg[propertyIndexCfg.m_PropertyID] then
          local basePropertyRate = basePropertyCfg[string_format("m_Lv_%s_Rate", paramStr)]
          local otherPropertyRate = 0
          if otherPropertyCfg then
            otherPropertyRate = otherPropertyCfg[string_format("m_Lv_%s_Rate", paramStr)]
          end
          local limitBreakParam = self:GetLimitBreakParam(limitBreakCfg, HeroManager.BreakTypeEnum.Normal, paramStr)
          paramNum = basePropertyNum + otherPropertyNum + (basePropertyRate + otherPropertyRate) / 10000 * levelTemplateParam
          paramNum = paramNum * limitBreakParam + breakOtherPropertyNum
          paramNum = paramNum + circulationPropertyNum
          paramNum = paramNum + attractPropertyNum
          if breakType == HeroManager.BreakTypeEnum.OverLimit then
            local overLimitBreakParam = self:GetLimitBreakParam(limitBreakCfg, HeroManager.BreakTypeEnum.OverLimit, paramStr)
            paramNum = paramNum * overLimitBreakParam + overBreakOtherPropertyNum
          end
          retParamTab[paramStr] = paramNum
        else
          if basePropertyNum == nil then
            log.error("HeroAttr GetLvBreakAllAttr have nil Param ： ", paramStr)
          end
          paramNum = basePropertyNum + otherPropertyNum + circulationPropertyNum + breakOtherPropertyNum + overBreakOtherPropertyNum + attractPropertyNum
        end
        retParamTab[paramStr] = math.floor(paramNum)
      end
    end
  end
  return retParamTab
end

function HeroAttr:GetHeroPower(heroID, level, breakNum, skills, attractRank)
  if not heroID then
    return
  end
  if not level then
    return
  end
  breakNum = breakNum or 0
  local attrParamTab = self:GetLvBreakAllAttr(heroID, level, breakNum, nil, attractRank)
  local totalPower = CombatUtil:CalculateCombatsByAttrMap(attrParamTab)
  if skills then
    local skillPotency, skillPotencyParam = CombatUtil:CalculateSkillCombats(skills)
    totalPower = totalPower * (1 + skillPotencyParam) + skillPotency
  end
  return math.floor(totalPower)
end

function HeroAttr:GetCirculationBaseAttr(circulationID, lv)
  if not circulationID then
    return
  end
  if not lv then
    return
  end
  local circulationCfg = CirculationLevelIns:GetValue_ByCirculationTypeAndLevel(circulationID, lv)
  if circulationCfg:GetError() == true then
    return
  end
  local propertyID = circulationCfg.m_PropertyID
  local propertyCfg = PropertyIns:GetValue_ByPropertyID(propertyID)
  local retParamTab = {}
  if propertyCfg:GetError() == true then
    return retParamTab
  end
  local circulationTypeCfg = CirculationTypeIns:GetValue_ByCirculationTypeID(circulationID)
  if circulationTypeCfg:GetError() == true then
    return retParamTab
  end
  local lenNum = circulationTypeCfg.m_PropertyIndexID.Length
  for i = 0, lenNum - 1 do
    local tempID = circulationTypeCfg.m_PropertyIndexID[i]
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(tempID)
    local paramStr = propertyIndexCfg.m_ENName
    local propertyNum = propertyCfg["m_" .. paramStr]
    retParamTab[paramStr] = math.floor(propertyNum)
  end
  return retParamTab
end

function HeroAttr:GetCirculationAttr(circulationID, lv)
  if not circulationID then
    return
  end
  if not lv then
    return
  end
  local circulationCfg = CirculationLevelIns:GetValue_ByCirculationTypeAndLevel(circulationID, lv)
  if circulationCfg:GetError() == true then
    return
  end
  local propertyID = circulationCfg.m_PropertyID
  local propertyCfg = PropertyIns:GetValue_ByPropertyID(propertyID)
  local retParamTab = {}
  if propertyCfg:GetError() == true then
    return retParamTab
  end
  local allPropertyIndexCfg = PropertyIndexIns:GetAll()
  for _, propertyIndexCfg in pairs(allPropertyIndexCfg) do
    if propertyIndexCfg and propertyIndexCfg.m_Compute == 1 then
      local paramStr = propertyIndexCfg.m_ENName
      local propertyNum = propertyCfg["m_" .. paramStr]
      retParamTab[paramStr] = math.floor(propertyNum)
    end
  end
  return retParamTab
end

function HeroAttr:GetCirculationAttrByParams(paramTabs)
  if not paramTabs then
    return
  end
  local tempAttrTab
  for i, v in ipairs(paramTabs) do
    local oneAttrTab = self:GetCirculationAttr(v.ID, v.lv)
    if tempAttrTab == nil then
      tempAttrTab = oneAttrTab
    else
      for key, valueNum in pairs(oneAttrTab) do
        if tempAttrTab[key] then
          tempAttrTab[key] = tempAttrTab[key] + valueNum
        end
      end
    end
  end
  return tempAttrTab
end

function HeroAttr:GetLegacyAttr(legacyID, legacyLv)
  if not legacyID then
    return
  end
  legacyLv = legacyLv or 0
  local legacyLvCfg = LegacyLevelIns:GetValue_ByIDAndLevel(legacyID, legacyLv)
  if legacyLvCfg:GetError() == true then
    return
  end
  local propertyID = legacyLvCfg.m_PropertyID
  local propertyCfg = PropertyIns:GetValue_ByPropertyID(propertyID)
  local retParamTab = {}
  if propertyCfg:GetError() == true then
    return retParamTab
  end
  local allPropertyIndexCfg = PropertyIndexIns:GetAll()
  for _, propertyIndexCfg in pairs(allPropertyIndexCfg) do
    if propertyIndexCfg and propertyIndexCfg.m_Compute == 1 then
      local paramStr = propertyIndexCfg.m_ENName
      local propertyNum = propertyCfg["m_" .. paramStr]
      retParamTab[paramStr] = math.floor(propertyNum)
    end
  end
  return retParamTab
end

function HeroAttr:GetAttractAttr(iAttractAddTemplateID, iAttractRank)
  if not iAttractAddTemplateID then
    return
  end
  if not iAttractRank then
    return
  end
  local attractAddCfg = AttractAddIns:GetValue_ByAttractAddTemplateIDAndRankID(iAttractAddTemplateID, iAttractRank)
  if attractAddCfg:GetError() == true then
    return
  end
  local propertyID = attractAddCfg.m_PropertyID
  local propertyCfg = PropertyIns:GetValue_ByPropertyID(propertyID)
  local retParamTab = {}
  if propertyCfg:GetError() == true then
    return retParamTab
  end
  local allPropertyIndexCfg = PropertyIndexIns:GetAll()
  for _, propertyIndexCfg in pairs(allPropertyIndexCfg) do
    if propertyIndexCfg and propertyIndexCfg.m_Compute == 1 then
      local paramStr = propertyIndexCfg.m_ENName
      local propertyNum = propertyCfg["m_" .. paramStr]
      retParamTab[paramStr] = math.floor(propertyNum)
    end
  end
  return retParamTab
end

function HeroAttr:GetHeroAttrByParam(heroID, param, serverData)
  if not heroID then
    return
  end
  local heroCfg = HeroManager:GetHeroConfigByID(heroID)
  if not heroCfg then
    return
  end
  serverData = serverData or (HeroManager:GetHeroDataByID(heroID) or {}).serverData
  if not serverData then
    return
  end
  local breakNum = param.iBreak or serverData.iBreak
  if param.ignoreBreak then
    breakNum = 0
  end
  local heroLv = param.iLevel or serverData.iLevel
  local attractRank = param.iAttractRank or serverData.iAttractRank
  if param.ignoreAttractRank then
    attractRank = 0
  end
  local circulationTab = param.circulationParam or HeroManager:GetCirculationListByHeroID(heroID)
  if param.ignoreXunHuanShi then
    circulationTab = nil
  end
  local breakLvAttr = self:GetLvBreakAllAttr(heroID, heroLv, breakNum, circulationTab, attractRank)
  if not breakLvAttr then
    return
  end
  local equipTab = param.equipParam or EquipManager:GetHeroEquippedDataByHeroServerData(serverData)
  if param.ignoreEquip then
    equipTab = nil
  end
  if equipTab and next(equipTab) then
    for _, v in pairs(equipTab) do
      local equipBaseID = v.equipBaseId
      local level = v.level
      local iOverloadHero = v.iOverloadHero
      if iOverloadHero == 0 or iOverloadHero == nil then
        local equipAttrTab = EquipManager:GetEquipAttrByParam(heroID, equipBaseID, level)
        if equipAttrTab and next(equipAttrTab) then
          for paramStr, tempValue in pairs(equipAttrTab) do
            if breakLvAttr[paramStr] then
              breakLvAttr[paramStr] = breakLvAttr[paramStr] + tempValue
            end
          end
        end
      else
        local equipOverAttrTab = EquipManager:GetEquipOverLoadAttrByParam(heroID, equipBaseID, level)
        if equipOverAttrTab and next(equipOverAttrTab) then
          for paramStr, tempValue in pairs(equipOverAttrTab) do
            if breakLvAttr[paramStr] then
              breakLvAttr[paramStr] = breakLvAttr[paramStr] + tempValue
            end
          end
        end
      end
    end
  end
  local legacyParamTab = param.legacyParam or serverData.stLegacy
  if param.ignoreLegacy then
    legacyParamTab = nil
  end
  if legacyParamTab then
    local legacyAttr = self:GetLegacyAttr(legacyParamTab.iLegacyId, legacyParamTab.iLevel)
    if legacyAttr and next(legacyAttr) then
      for paramStr, tempValue in pairs(legacyAttr) do
        if breakLvAttr[paramStr] then
          breakLvAttr[paramStr] = breakLvAttr[paramStr] + tempValue
        end
      end
    end
  end
  return breakLvAttr
end

function HeroAttr:GetHeroPowerByParam(heroID, param, serverData)
  if not heroID then
    return
  end
  local heroCfg = HeroManager:GetHeroConfigByID(heroID)
  if not heroCfg then
    return
  end
  serverData = serverData or (HeroManager:GetHeroDataByID(heroID) or {}).serverData
  if not serverData then
    return
  end
  local attrParamTab = self:GetHeroAttrByParam(heroID, param, serverData)
  local totalPower = CombatUtil:CalculateCombatsByAttrMap(attrParamTab)
  local skills = param.mSkill or serverData.mSkill
  if skills then
    local skillPotency, skillPotencyParam = CombatUtil:CalculateSkillCombats(skills)
    totalPower = totalPower * (1 + skillPotencyParam) + skillPotency
  end
  return math.floor(totalPower)
end

return HeroAttr
