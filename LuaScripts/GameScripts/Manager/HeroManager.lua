local BaseManager = require("Manager/Base/BaseManager")
local HeroManager = class("HeroManager", BaseManager)
local pairs = _ENV.pairs
local ipairs = _ENV.ipairs
local string_split = string.split
local string_format = string.format
HeroManager.QualityType = {
  N = 1,
  R = 2,
  SR = 3,
  SSR = 4
}
HeroManager.TeamTypeBase = {Default = 0, SoloRaid = 1}
QualityPathCfg = {
  [1] = {},
  [2] = {
    heroCheckBreak = 0,
    bgBigPath = "Atlas_CharacterQuality/hero_card_bg_r",
    borderBigImgPath = "Atlas_CharacterQuality/hero_card_light_r",
    bgPath = "Atlas_CharacterQuality/common_card_m",
    borderImgPath = "Atlas_CharacterQuality/common_card_purple",
    borderImgTeamPath = "Atlas_CharacterQuality/common_card_purple_big",
    teamImgMask = "Atlas_CharacterQuality/team_img_purple",
    ssrImgPath = "Atlas_CharacterQuality/common_img_r",
    campColor = {
      65,
      199,
      255,
      0.4
    }
  },
  [3] = {
    heroCheckBreak = 2,
    bgBigPath = "Atlas_CharacterQuality/hero_card_bg_r",
    borderBigImgPath = "Atlas_CharacterQuality/hero_card_light_sr",
    bgPath = "Atlas_CharacterQuality/common_card_m",
    borderImgPath = "Atlas_CharacterQuality/common_card_goldm",
    borderImgTeamPath = "Atlas_CharacterQuality/common_card_goldom_big",
    teamImgMask = "Atlas_CharacterQuality/team_img_goldom",
    ssrImgPath = "Atlas_CharacterQuality/common_img_sr",
    campColor = {
      255,
      65,
      236,
      0.4
    }
  },
  [4] = {
    heroCheckBreak = 3,
    bgBigPath = "Atlas_CharacterQuality/hero_card_bg_ssr",
    borderBigImgPath = "Atlas_CharacterQuality/hero_card_light_ssr",
    bgPath = "Atlas_CharacterQuality/common_card_redm2",
    borderImgPath = "Atlas_CharacterQuality/common_card_redm1",
    borderImgTeamPath = "Atlas_CharacterQuality/common_card_red_big",
    teamImgMask = "Atlas_CharacterQuality/team_img_red",
    ssrImgPath = "Atlas_CharacterQuality/common_img_ssr",
    campColor = {
      255,
      157,
      39,
      0.4
    }
  }
}
SpinePlaceCfg = {
  HeroDetail = "herodetail",
  HeroBreak = "herobreak",
  HeroEquip = "heroequip",
  HeroEquipMain = "heroequipmain",
  HeroShow = "heroshow",
  HeroPreview = "heropreview",
  MainShow = "mainshow",
  MainShowSmall = "mainshowsmall",
  ActivityGacha = "activity_gacha",
  HuntingRaid = "huntingraid",
  HeroFashionItem = "herofashionitem",
  HeroBpMain = "herobpmain",
  HeroBpBenefits = "herobpbenefits",
  HeroFashionStore = "fashionstore",
  HeroNewSkin = "getskin",
  SignIn10DayFace = "signin10dayface",
  SignIn10DaySystem = "signin10daysystem"
}
AttrShowType = {
  Camp = 1,
  Attribute = 2,
  Career = 3,
  Race = 4
}
HeroManager.AttrType = {Fixed = 1, TenThousandPercent = 2}
HeroManager.TotalServerAttrIndex = 0
HeroManager.MonsterType = {
  Normal = 0,
  NPC = 1,
  Boss = 2,
  DestroyObj = 3,
  Elite = 4,
  Pitfall = 5,
  RogueNormalMonster = 6,
  RogueBossMonster = 7
}
HeroManager.MonsterTypeSort = {
  [HeroManager.MonsterType.Normal] = 3,
  [HeroManager.MonsterType.NPC] = 0,
  [HeroManager.MonsterType.Boss] = 1,
  [HeroManager.MonsterType.DestroyObj] = 999,
  [HeroManager.MonsterType.Elite] = 2,
  [HeroManager.MonsterType.Pitfall] = 5,
  [HeroManager.MonsterType.DestroyObj] = 5,
  [HeroManager.MonsterType.RogueNormalMonster] = 5
}
HeroManager.BondStageBgPath = {
  Normal = {
    bgPath = "Atlas_Bond/bond_bg_normal"
  },
  [0] = {
    bgPath = "Atlas_Bond/bond_bg_grey"
  },
  [1] = {
    bgPath = "Atlas_Bond/bond_bg_copper"
  },
  [2] = {
    bgPath = "Atlas_Bond/bond_bg_silver"
  },
  [3] = {
    bgPath = "Atlas_Bond/bond_bg_gold"
  }
}
HeroManager.HeroBaseTab = {BaseInfo = 1}
HeroManager.CirculationType = {
  Root = 1,
  Equip = 2,
  Camp = 3
}
HeroManager.CirculationRootID = 1
HeroManager.RBreakNum = 0
HeroManager.SRBreakNum = 2
HeroManager.SSRBreakNum = 3
HeroManager.FormPlotMaxNum = 5
HeroManager.BreakNeedNum = 1
HeroManager.BreakShowMaxNum = 4
HeroManager.MaxBreakNewType = 7
HeroManager.MaxBreakNew = 10
HeroManager.BreakThroughVideoPreStr = "break_through"
HeroManager.BreakTypeEnum = {Normal = 1, OverLimit = 2}

function HeroManager:OnCreate()
  self.m_HeroList = nil
  self.m_PresetDic = nil
  self.m_cacheFormReqDataList = {}
  self.m_cacheFormDic = {}
  HeroManager.FilterType = {
    Camp = 1,
    Career = 2,
    EquipType = 3,
    MoonType = 4
  }
  self.m_HeroSort = require("Manager/ManagerPlus/HeroSort").new()
  HeroManager.HeroFilterFunctionCfg = {
    [HeroManager.FilterType.Camp] = self.m_HeroSort.HeroCampFilter,
    [HeroManager.FilterType.Career] = self.m_HeroSort.HeroCareerFilter,
    [HeroManager.FilterType.EquipType] = self.m_HeroSort.HeroEquipTypeFilter,
    [HeroManager.FilterType.MoonType] = self.m_HeroSort.HeroMoonTypeFilter
  }
  self.m_circulationDic = nil
  self.m_cacheCharacterCfgDic = {}
  self.m_monsterLevelTemplateCache = {}
  self.m_cacheCharacterViewModeCfgDic = {}
  self:AddEventListener()
end

function HeroManager:AddEventListener()
  self:addEventListener("eGameEvent_Item_Init", handler(self, self.OnItemInit))
  self:addEventListener("eGameEvent_PopupUnlockSystem", handler(self, self.OnUnlockSystem))
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.OnItemChange))
  self:addEventListener("eGameEvent_OtherSystem_UpdateHeroData", handler(self, self.OnHeroEquipDataChange))
  self:addEventListener("eGameEvent_Inherit_Change", handler(self, self.OnInheritChange))
  self:addEventListener("eGameEvent_Inherit_Init", handler(self, self.OnInheritInit))
  self:addEventListener("eGameEvent_Hero_AttractRedCheck", handler(self, self.OnItemInit))
end

function HeroManager:OnItemInit()
  self:CheckUpdateHeroEntryRedDotCount()
  self:FreshUpdateCirculationEntryRedDot()
end

function HeroManager:OnUnlockSystem(param)
  if not param then
    return
  end
  if param.systemID == GlobalConfig.SYSTEM_ID.Character then
    self:CheckUpdateHeroEntryRedDotCount()
  else
    self:FreshUpdateCirculationEntryRedDot()
  end
end

function HeroManager:OnItemChange(vItemChange)
  for _, stItemChange in pairs(vItemChange) do
    if stItemChange.iID == self.LvMoneyItemID or stItemChange.iID == self.LvExpItemID or stItemChange.iID == self.LvBreakthroughItemID then
      self:CheckUpdateHeroEntryRedDotCount()
    end
  end
  self:FreshUpdateCirculationEntryRedDot()
end

function HeroManager:OnInitNetwork()
  self:__CreateSkillTypeSort()
  RPCS():Listen_Push_SetHeroData(handler(self, self.OnPushSetHeroData), "HeroManager")
  RPCS():Listen_Push_HeroList(handler(self, self.OnPushSetHeroListData), "HeroManager")
  RPCS():Listen_Push_FormPower(handler(self, self.OnPushFormPower), "HeroManager")
  RPCS():Listen_Push_Hero_AddFashion(handler(self, self.OnPushHeroAddFashion), "HeroManager")
  self:ReqGetCirculation()
  self:ReqGetRecommendData()
end

function HeroManager:OnAfterInitConfig()
  local characterViewIns = ConfigManager:GetConfigInsByName("CharacterViewMode")
  local characterViewAll = characterViewIns:GetAll()
  if characterViewAll then
    for i, v in pairs(characterViewAll) do
      self.m_cacheCharacterViewModeCfgDic[v.m_FashionId] = v
    end
  end
end

function HeroManager:ReqGetRecommendData()
  local msg = MTTDProto.Cmd_Recommend_GetInit_CS()
  RPCS():Recommend_GetInit(msg, handler(self, self.OnGetRecommendData))
end

function HeroManager:OnGetRecommendData(stdata)
  self.m_recommendDataList = stdata
end

function HeroManager:GetRecommendData()
  return self.m_recommendDataList or 0
end

function HeroManager:SetRecommendData(recommendDataList)
  self.m_recommendDataList = recommendDataList
end

function HeroManager:GetRecommendNextRefreshTime()
  if self.m_recommendDataList then
    return self.m_recommendDataList.iNextRefreshTime or 0
  end
  return 0
end

function HeroManager:OnAfterFreshData()
  self.m_SkillResetItemId = tonumber(ConfigManager:GetGlobalSettingsByKey("SkillResetItem"))
  self.m_SkillResetItemNum = tonumber(ConfigManager:GetGlobalSettingsByKey("SkillResetItemNum"))
end

function HeroManager:OnUpdate(dt)
end

function HeroManager:OnHeroGetListSC(stHeroListData, msg)
  self.m_CharacterInfoCfg = ConfigManager:GetConfigInsByName("CharacterInfo")
  self.m_HeroAttr = require("Manager/ManagerPlus/HeroAttr").new()
  self.m_HeroGuideHelper = require("Manager/ManagerPlus/HeroGuideHelper").new()
  self.m_HeroFashion = require("Manager/ManagerPlus/HeroFashion").new()
  self.m_HeroVoice = require("Manager/ManagerPlus/HeroVoice").new()
  self.CharacterLevelIns = ConfigManager:GetConfigInsByName("CharacterLevel")
  self.GlobalSettingsIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  self.CharacterLevelLockIns = ConfigManager:GetConfigInsByName("CharacterLevelLock")
  self.LvExpItemID = tonumber(self.GlobalSettingsIns:GetValue_ByName("CharacterlvEXPitem").m_Value)
  self.LvMoneyItemID = tonumber(self.GlobalSettingsIns:GetValue_ByName("CharacterlvCurrencyitem").m_Value)
  self.LvBreakthroughItemID = tonumber(self.GlobalSettingsIns:GetValue_ByName("CharacterlvBreakthroughitem").m_Value)
  log.info("HeroManager OnHeroGetListSC stHeroListData: ", tostring(stHeroListData))
  self.m_HeroList = {}
  if not stHeroListData then
    return
  end
  local heroDataList = stHeroListData.vHeroList
  for _, v in pairs(heroDataList) do
    if v then
      local characterCfg = self:GetHeroConfigByID(v.iHeroId)
      if characterCfg then
        local heroItem = {serverData = v, characterCfg = characterCfg}
        self.m_HeroList[#self.m_HeroList + 1] = heroItem
      end
    end
  end
  self.m_HeroGuideHelper:InitAllHeroGuideList()
  self.m_HeroFashion:InitFashionStatus(stHeroListData.mHasFashion)
  self:CheckUpdateHeroEntryRedDotCount()
end

function HeroManager:OnHeroGetPresetSC(stHeroPresetData, msg)
  if not stHeroPresetData then
    return
  end
  local allPreset = stHeroPresetData.mPreset
  self.m_PresetDic = allPreset or {}
end

function HeroManager:OnPushSetHeroData(stHeroData, msg)
  local heroData = stHeroData.stCmdHeroData
  local isHave, iHeroID = self:__FreshHeroData(heroData)
  self:broadcastEvent("eGameEvent_Hero_SetHeroData", {heroServerData = heroData})
  self:FreshUpdateCirculationEntryRedDot()
  if isHave == false then
    self:broadcastEvent("eGameEvent_Hero_NewHero", {iHeroID = iHeroID})
  end
  self:CheckUpdateHeroEntryRedDotCount()
end

function HeroManager:OnHeroEquipDataChange(heroData)
  self:OnPushSetHeroData({stCmdHeroData = heroData})
end

function HeroManager:OnInheritChange()
  self:FreshUpdateCirculationEntryRedDot()
end

function HeroManager:OnInheritInit()
  self:FreshUpdateCirculationEntryRedDot()
end

function HeroManager:OnPushSetHeroListData(stHeroListData, msg)
  if not stHeroListData then
    return
  end
  local heroDataList = stHeroListData.vHeroData
  for i, heroData in ipairs(heroDataList) do
    self:__FreshHeroData(heroData)
  end
  if heroDataList and 0 < #heroDataList then
    self:broadcastEvent("eGameEvent_Hero_SetHeroDataList", heroDataList)
  end
end

function HeroManager:OnPushFormPower(stFormPowerData, msg)
  local mPresetPower = stFormPowerData.mPresetPower
  if mPresetPower then
    for formType, formPower in pairs(mPresetPower) do
      self:__FreshFormPresetPower(formType, formPower)
    end
  end
  local mFormPower = stFormPowerData.mFormPower
  if mFormPower then
    for levelType, subTypeTab in pairs(mFormPower) do
      if subTypeTab then
        for levelSubType, power in pairs(subTypeTab) do
          self:__FreshFormPower(levelType, levelSubType, power)
        end
      end
    end
  end
end

function HeroManager:OnPushHeroAddFashion(stHeroAddFashionData, msg)
  if not stHeroAddFashionData then
    return
  end
  if not self.m_HeroFashion then
    return
  end
  local fashionID = stHeroAddFashionData.iFashionId
  local isRepeat = stHeroAddFashionData.bSame
  if isRepeat ~= true then
    self.m_HeroFashion:AddNewFashion(fashionID)
    self:broadcastEvent("eGameEvent_Hero_GetNewFashion", {fashionID = fashionID})
  end
end

function HeroManager:ReqHeroLevelUp(heroID, lv)
  if not heroID or not heroID then
    return
  end
  local msg = MTTDProto.Cmd_Hero_LevelUp_CS()
  msg.iHeroId = heroID
  msg.iNum = lv
  RPCS():Hero_LevelUp(msg, handler(self, self.OnHeroLevelUpSC))
end

function HeroManager:GetHeroCanLevelUpMaxLv(heroId)
  local unLockLevel = 1
  if not self.UnlockCharacterLevelCount then
    local GlobalSettingsIns = ConfigManager:GetConfigInsByName("GlobalSettings")
    self.UnlockCharacterLevelCount = tonumber(GlobalSettingsIns:GetValue_ByName("UnlockCharacterLevelCount").m_Value)
  end
  local fourthHero = self.UnlockCharacterLevelCount or 4
  local canUpLevel = 1
  local characterLevelLockIns = self.CharacterLevelLockIns
  characterLevelLockIns = characterLevelLockIns or ConfigManager:GetConfigInsByName("CharacterLevelLock")
  local vCharacterLevelLockCfg = characterLevelLockIns:GetAll()
  local otherFourHero = self:GetOtherFourHeroBesidesUpgrade(heroId)
  local maxLv, tips = self:GetNewHeroCanLevelUpMaxLevel()
  if fourthHero > #otherFourHero then
    return maxLv, tips
  end
  unLockLevel = otherFourHero[fourthHero].serverData.iLevel
  local id = 1
  local step = vCharacterLevelLockCfg.Count
  for i = 1, vCharacterLevelLockCfg.Count do
    local data = vCharacterLevelLockCfg[i]
    if unLockLevel >= data.m_UnlockLevel then
      id = math.min(i + 1, step)
    end
  end
  tips = "???"
  local cfg = characterLevelLockIns:GetValue_ByID(id)
  if not cfg:GetError() then
    canUpLevel = cfg.m_LockMaxLevel
    tips = cfg.m_TipsID
  end
  return canUpLevel, tips
end

function HeroManager:GetOtherFourHeroBesidesUpgrade(heroId)
  local heroList = {}
  local otherFourHero = {}
  heroList = InheritManager:GetTopFiveHero()
  if heroList and 0 < #heroList then
    for i, v in ipairs(heroList) do
      if v.serverData.iHeroId ~= heroId then
        otherFourHero[#otherFourHero + 1] = v
      end
    end
  else
    local function sortFun(data1, data2)
      if data1.serverData.iLevel == data2.serverData.iLevel then
        return data1.serverData.iHeroId < data2.serverData.iHeroId
      else
        return data1.serverData.iLevel > data2.serverData.iLevel
      end
    end
    
    table.sort(self.m_HeroList, sortFun)
    for i, v in ipairs(self.m_HeroList) do
      if v.serverData.iHeroId ~= heroId then
        otherFourHero[#otherFourHero + 1] = v
      end
    end
  end
  return otherFourHero
end

function HeroManager:GetNewHeroCanLevelUpMaxLevel()
  local characterLevelLockIns = self.CharacterLevelLockIns
  characterLevelLockIns = characterLevelLockIns or ConfigManager:GetConfigInsByName("CharacterLevelLock")
  local vCharacterLevelLockCfg = characterLevelLockIns:GetAll()
  local maxLv = 999999
  local tips = "???"
  for i, v in pairs(vCharacterLevelLockCfg) do
    if maxLv > v.m_LockMaxLevel then
      maxLv = v.m_LockMaxLevel
      tips = v.m_TipsID
    end
  end
  return maxLv, tips
end

function HeroManager:OnHeroLevelUpSC(stHeroData, msg)
  if not stHeroData then
    return
  end
  self:broadcastEvent("eGameEvent_Hero_LevelUp")
end

function HeroManager:ReqHeroResetLevel(heroID)
  if not heroID then
    return
  end
  local msg = MTTDProto.Cmd_Hero_ResetLevel_CS()
  msg.iHeroId = heroID
  RPCS():Hero_ResetLevel(msg, handler(self, self.OnHeroResetLevelSC))
end

function HeroManager:OnHeroResetLevelSC(stData, msg)
  if not stData then
    return
  end
  if stData.vItem and next(stData.vItem) then
    utils.popUpRewardUI(stData.vItem)
  end
  self:broadcastEvent("eGameEvent_Hero_ResetLevel")
end

function HeroManager:ReqSetPreset(presetID, heroIDList)
  if not presetID or not heroIDList then
    return
  end
  local msg = MTTDProto.Cmd_Form_SetPreset_CS()
  msg.iPresetId = presetID
  msg.vHeroId = heroIDList
  RPCS():Form_SetPreset(msg, handler(self, self.OnSetFormPresetSC))
end

function HeroManager:OnSetFormPresetSC(stFormPresetData, msg)
  if not stFormPresetData then
    return
  end
  local presetID = stFormPresetData.iPresetId
  local presetData = stFormPresetData.stPreset
  self:__SetFormPreset(presetID, presetData)
  self:broadcastEvent("eGameEvent_Hero_SetForm", {formType = presetID, formData = presetData})
end

function HeroManager:ReqHeroSkillLevelUp(heroId, skillId)
  if not heroId or not skillId then
    return
  end
  local msg = MTTDProto.Cmd_Hero_SkillLevelUp_CS()
  msg.iHeroId = heroId
  msg.iSkillId = skillId
  RPCS():Hero_SkillLevelUp(msg, handler(self, self.OnHeroSkillLevelUpSC))
end

function HeroManager:OnHeroSkillLevelUpSC(stHeroSkillData, msg)
  if not stHeroSkillData then
    return
  end
  self:broadcastEvent("eGameEvent_Hero_SkillLevelUp", {
    iHeroId = stHeroSkillData.iHeroId,
    iSkillId = stHeroSkillData.iSkillId,
    iLevel = stHeroSkillData.iLevel
  })
end

function HeroManager:ReqHeroBreak(heroID)
  if not heroID then
    return
  end
  local msg = MTTDProto.Cmd_Hero_Break_CS()
  msg.iHeroId = heroID
  RPCS():Hero_Break(msg, handler(self, self.OnHeroBreakSC))
end

function HeroManager:OnHeroBreakSC(stBreakData, msg)
  if not stBreakData then
    return
  end
  local heroID = stBreakData.iHeroId
  local heroBreak = stBreakData.iBreak
  self:broadcastEvent("eGameEvent_Hero_Break", {heroID = heroID, heroBreak = heroBreak})
end

function HeroManager:ReqGetForm(levelType, subType)
  if not levelType then
    return
  end
  if not subType then
    return
  end
  local msg = MTTDProto.Cmd_Form_GetForm_CS()
  msg.iFightType = levelType
  msg.iFightSubType = subType
  local tempCacheData = {formLevelType = levelType, formLevelSubType = subType}
  self.m_cacheFormReqDataList[#self.m_cacheFormReqDataList + 1] = tempCacheData
  RPCS():Form_GetForm(msg, handler(self, self.OnGetFormSC))
end

function HeroManager:OnGetFormSC(stGetForm, msg)
  if not stGetForm then
    return
  end
  local stForm = stGetForm.stForm
  if next(self.m_cacheFormReqDataList) then
    local tempFormReqData = table.remove(self.m_cacheFormReqDataList, 1)
    self:SetFormData(tempFormReqData.formLevelType, tempFormReqData.formLevelSubType, stForm)
    self:broadcastEvent("eGameEvent_Hero_GetForm", {
      stForm = stForm,
      levelType = tempFormReqData.formLevelType,
      levelSubType = tempFormReqData.formLevelSubType
    })
  end
end

function HeroManager:ReqGetCirculation()
  local msg = MTTDProto.Cmd_Role_GetCirculation_CS()
  RPCS():Role_GetCirculation(msg, handler(self, self.OnGetCirculation))
end

function HeroManager:OnGetCirculation(stGetCirculation, msg)
  if not stGetCirculation then
    return
  end
  self.m_circulationDic = stGetCirculation.mCirculationItem or {}
  self:FreshUpdateCirculationEntryRedDot()
end

function HeroManager:ReqUpgradeCirculation(typeID, itemNum)
  if not type then
    return
  end
  if not itemNum then
    return
  end
  local msg = MTTDProto.Cmd_Role_UpgradeCirculation_CS()
  msg.iTypeID = typeID
  msg.iItemNum = itemNum
  RPCS():Role_UpgradeCirculation(msg, handler(self, self.OnUpgradeCirculation))
end

function HeroManager:OnUpgradeCirculation(stUpgradeCirculation, msg)
  if not stUpgradeCirculation then
    return
  end
  local circulationItem = stUpgradeCirculation.stCirculationItem
  if not circulationItem then
    return
  end
  local type = circulationItem.iTypeID
  self.m_circulationDic[type] = circulationItem
  self:broadcastEvent("eGameEvent_Hero_CirculationUpgrade", circulationItem)
  self:FreshUpdateCirculationEntryRedDot()
end

function HeroManager:ReqHeroSkillResetCS(iHeroId)
  local msg = MTTDProto.Cmd_Hero_SkillReset_CS()
  msg.iHeroId = iHeroId
  RPCS():Hero_SkillReset(msg, handler(self, self.OnHeroSkillResetSC))
end

function HeroManager:OnHeroSkillResetSC(stData, msg)
  if not stData then
    return
  end
  if stData.vItem and next(stData.vItem) then
    utils.popUpRewardUI(stData.vItem)
  end
  self:broadcastEvent("eGameEvent_Hero_ResetSkillLevel")
end

function HeroManager:ReqHeroSetFashion(heroID, fashionID)
  if not heroID then
    return
  end
  if not fashionID then
    return
  end
  local msg = MTTDProto.Cmd_Hero_SetFashion_CS()
  msg.iHeroId = heroID
  msg.iFashionId = fashionID
  RPCS():Hero_SetFashion(msg, handler(self, self.OnHeroSetFashionSC))
end

function HeroManager:OnHeroSetFashionSC(stData, msg)
  if not stData then
    return
  end
  local heroID = stData.iHeroId
  local fashionID = stData.iFashionId
  self:__FreshHeroDataFashion(heroID, fashionID)
  self:broadcastEvent("eGameEvent_Hero_SetFashion", {heroID = heroID, fashionID = fashionID})
end

function HeroManager:__CreateSkillTypeSort()
  local globalConfig = ConfigManager:GetConfigInsByName("GlobalSettings")
  local skillTypeSortStr = globalConfig:GetValue_ByName("SkillTypeSorting").m_Value
  local skillTypeSortList = string_split(skillTypeSortStr, ",")
  self.HeroSkillTagSort = skillTypeSortList
  for i, strSortNum in ipairs(self.HeroSkillTagSort) do
    self.HeroSkillTagSort[i] = tonumber(strSortNum)
  end
end

function HeroManager:__SetFormPreset(presetID, presetData)
  if not presetID then
    return
  end
  if not presetData then
    return
  end
  self.m_PresetDic[presetID] = presetData
end

function HeroManager:__FreshFormPresetPower(formType, formPower)
  if not formType then
    return
  end
  if not formPower then
    return
  end
  local formData = self.m_PresetDic[formType]
  if not formData then
    return
  end
  formData.iPower = formPower
end

function HeroManager:__FreshFormPower(levelType, levelSubType, formPower)
  if not levelType then
    return
  end
  if not levelSubType then
    return
  end
  local levelTypeTab = self.m_cacheFormDic[levelType]
  if not levelTypeTab then
    return
  end
  local subTypeFormData = levelTypeTab[levelSubType]
  if not subTypeFormData then
    return
  end
  subTypeFormData.iPower = formPower
end

function HeroManager:__FreshHeroData(heroData)
  if not heroData then
    return
  end
  local heroID = heroData.iHeroId
  local isHave = false
  for _, v in ipairs(self.m_HeroList) do
    if v.serverData.iHeroId == heroID then
      v.serverData = heroData
      isHave = true
      break
    end
  end
  if isHave == false then
    local characterCfg = self:GetHeroConfigByID(heroID)
    if characterCfg then
      local heroItem = {serverData = heroData, characterCfg = characterCfg}
      self.m_HeroList[#self.m_HeroList + 1] = heroItem
      if self.m_HeroGuideHelper then
        self.m_HeroGuideHelper:FreshHeroGuideIsHave(heroItem)
      end
    end
  end
  return isHave, heroID
end

function HeroManager:__FreshHeroDataFashion(heroID, fashionID)
  if not heroID then
    return
  end
  if not fashionID then
    return
  end
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return
  end
  heroData.serverData.iFashion = fashionID
end

function HeroManager:__IsHeroLvUpHaveEnoughItem(heroData)
  if not heroData then
    return
  end
  local curLevel = heroData.serverData.iLevel
  local levelTemplate = heroData.characterCfg.m_LevelTemplateID
  local levelTemplateGroupList = self.m_HeroAttr:GetLevelTemplateGroup(levelTemplate)
  local curHeroMaxLevelNum = #levelTemplateGroupList
  if curLevel >= curHeroMaxLevelNum then
    return false
  end
  local characterNextLevelCfg = self.CharacterLevelIns:GetValue_ByCharacterLv(curLevel)
  if characterNextLevelCfg:GetError() then
    return
  end
  local needExp = characterNextLevelCfg.m_LvExp
  local haveExp = ItemManager:GetItemNum(self.LvExpItemID)
  if needExp > haveExp then
    return false
  end
  local needMoney = characterNextLevelCfg.m_LvMoney
  local haveMoney = ItemManager:GetItemNum(self.LvMoneyItemID, true)
  if needMoney > haveMoney then
    return false
  end
  local needBreakThrough = characterNextLevelCfg.m_LvBreakthrough
  local haveBreakThrough = ItemManager:GetItemNum(self.LvBreakthroughItemID)
  if needBreakThrough > haveBreakThrough then
    return false
  end
  return true
end

function HeroManager:__GetHeroCamUpMaxLvNum(heroData)
  if not heroData then
    return
  end
  local unLockMaxLv, _ = self:GetHeroCanLevelUpMaxLv(heroData.serverData.iHeroId)
  local curBreakNum = heroData.serverData.iBreak or 0
  local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
  if not CharacterLimitBreakIns then
    return
  end
  local curBreakCfg = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplateAndLimitBreakLevel(heroData.characterCfg.m_Quality, curBreakNum)
  if curBreakCfg:GetError() then
    return
  end
  local breakMaxLv = curBreakCfg.m_MaxLevel
  return math.min(breakMaxLv, unLockMaxLv)
end

function HeroManager:__IsHeroLvCanUpByHeroData(heroData)
  if not heroData then
    return
  end
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.CharacterLevel)
  if isOpen ~= true then
    return false
  end
  local curLevel = heroData.serverData.iLevel
  local curCanUpMaxLv = self:__GetHeroCamUpMaxLvNum(heroData)
  if curLevel >= curCanUpMaxLv then
    return false
  end
  local isItemCanUp = self:__IsHeroLvUpHaveEnoughItem(heroData)
  if isItemCanUp ~= true then
    return false
  end
  return true
end

function HeroManager:GetHeroList()
  local tempHeroList = {}
  if self.m_HeroList and next(self.m_HeroList) then
    for _, v in ipairs(self.m_HeroList) do
      if v then
        tempHeroList[#tempHeroList + 1] = v
      end
    end
  end
  return tempHeroList
end

function HeroManager:GetHeroServerList()
  local tempHeroList = {}
  if self.m_HeroList and next(self.m_HeroList) then
    for _, v in ipairs(self.m_HeroList) do
      if v then
        tempHeroList[#tempHeroList + 1] = v.serverData
      end
    end
  end
  return tempHeroList
end

function HeroManager:GetHeroDataByID(heroID)
  if not heroID then
    return
  end
  if not self.m_HeroList then
    return
  end
  for _, v in ipairs(self.m_HeroList) do
    if v.serverData.iHeroId == heroID then
      return v
    end
  end
  return nil
end

function HeroManager:GetHeroiPower(heroID)
  if not heroID then
    return
  end
  if not self.m_HeroList then
    return
  end
  for _, v in ipairs(self.m_HeroList) do
    if v.serverData.iHeroId == heroID then
      return v.serverData.iPower or 0
    end
  end
  return nil
end

function HeroManager:GetHeroDataByConfigID(heroConfigID)
  if not heroConfigID then
    return
  end
  if not self.m_HeroList then
    return
  end
  for _, v in ipairs(self.m_HeroList) do
    if v.characterCfg.m_HeroID == heroConfigID then
      return v
    end
  end
  return nil
end

function HeroManager:GetHeroConfigByID(heroID)
  if not heroID then
    return
  end
  if not self.m_CharacterInfoCfg then
    self.m_CharacterInfoCfg = ConfigManager:GetConfigInsByName("CharacterInfo")
  end
  local characterCfg = self.m_cacheCharacterCfgDic[heroID]
  if characterCfg == nil then
    characterCfg = self.m_CharacterInfoCfg:GetValue_ByHeroID(heroID)
    if characterCfg:GetError() == true then
      characterCfg = nil
    end
    self.m_cacheCharacterCfgDic[heroID] = characterCfg
  end
  return characterCfg
end

function HeroManager:IsHeroHide(heroCfg)
  if not heroCfg then
    return
  end
  local onScaleValue = self:GetHeroOnSaleValue(heroCfg.m_HeroID, heroCfg.m_OnSale) or 0
  if onScaleValue == 1 then
    return true
  end
  if ActivityManager:IsInCensorOpen() == true and heroCfg.m_CensorOnSale == 1 then
    return true
  end
  return false
end

function HeroManager:GetHeroOnSaleValue(heroID, configSaleValue)
  if not heroID then
    return configSaleValue
  end
  local activityCom = ActivityManager:GetActivityByType(MTTD.ActivityType_UpTimeManager)
  if not activityCom then
    return configSaleValue
  end
  local isMatch, serverValue = activityCom:GetHeroHideStatusByID(heroID)
  if isMatch == true then
    configSaleValue = serverValue
  end
  return configSaleValue
end

function HeroManager:CheckHadLevelHero(checkLevel)
  if not self.m_HeroList then
    return false
  end
  for _, v in ipairs(self.m_HeroList) do
    if checkLevel <= v.serverData.iLevel then
      return true
    end
  end
  return false
end

function HeroManager:CheckHeroInPreset(heroID)
  if self.m_PresetDic then
    for k, v in pairs(self.m_PresetDic) do
      local serverPresetData = v
      local heroIDList = serverPresetData.vHeroId
      for _, _heroID in ipairs(heroIDList) do
        if _heroID == heroID then
          return true
        end
      end
    end
  end
  return false
end

function HeroManager:GetPresetDic()
  return self.m_PresetDic
end

function HeroManager:GetPresetDataByType(presetType)
  if not presetType then
    return
  end
  if not self.m_PresetDic then
    return
  end
  return self.m_PresetDic[presetType]
end

function HeroManager:GetHeroSort()
  return self.m_HeroSort
end

function HeroManager:GetHeroAttr()
  return self.m_HeroAttr
end

function HeroManager:GetHeroGuideHelper()
  return self.m_HeroGuideHelper
end

function HeroManager:GetHeroFashion()
  return self.m_HeroFashion
end

function HeroManager:GetHeroVoice()
  return self.m_HeroVoice
end

function HeroManager:GetHeroEquippedDataByID(heroID)
  if not heroID then
    return
  end
  if not self.m_HeroList then
    return
  end
  for _, v in ipairs(self.m_HeroList) do
    if v.serverData.iHeroId == heroID then
      return v.serverData.mEquip
    end
  end
  return nil
end

function HeroManager:IsHeroAttractRedDot(heroID)
  return AttractManager:CheckHeroRedDotOut(heroID)
end

function HeroManager:IsHeroCanUpGrade(heroID)
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return 0
  end
  return self:__IsHeroLvCanUpByHeroData(heroData) and 1 or 0
end

function HeroManager:IsHeroBaseInfoTabRedDot(heroID)
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return 0
  end
  local redPoint = 0
  local isCanBreakNum = self:IsHeroCanBreakUp(heroID)
  redPoint = redPoint + isCanBreakNum
  if 0 < redPoint then
    return redPoint
  end
  local isFashionNum = self:IsHeroFashionHaveRedDot(heroID)
  redPoint = redPoint + isFashionNum
  return redPoint
end

function HeroManager:IsHeroCanBreakUp(heroID)
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return 0
  end
  local qualityID = heroData.characterCfg.m_Quality
  if qualityID == nil or qualityID == 0 then
    return 0
  end
  local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
  if not CharacterLimitBreakIns then
    return 0
  end
  local maxBreakNum = 0
  local allCharacterLimitBreaks = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplate(qualityID)
  for _, breakCfg in pairs(allCharacterLimitBreaks) do
    if maxBreakNum < breakCfg.m_LimitBreakLevel then
      maxBreakNum = breakCfg.m_LimitBreakLevel
    end
  end
  local isBelowBreakNum = false
  if maxBreakNum > heroData.serverData.iBreak then
    isBelowBreakNum = true
  end
  local haveEnough = false
  local costItemID = heroData.characterCfg.m_LimitBreakItem
  if costItemID then
    local curHaveNum = ItemManager:GetItemNum(costItemID, true)
    if curHaveNum >= HeroManager.BreakNeedNum then
      haveEnough = true
    end
  end
  if isBelowBreakNum and haveEnough then
    return 1
  end
  return 0
end

function HeroManager:GetHeroMaxBreakNum(heroID)
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return 0
  end
  local qualityID = heroData.characterCfg.m_Quality
  if qualityID == nil or qualityID == 0 then
    return 0
  end
  local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
  if not CharacterLimitBreakIns then
    return 0
  end
  local maxBreakNum = 0
  local allCharacterLimitBreaks = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplate(qualityID)
  for _, breakCfg in pairs(allCharacterLimitBreaks) do
    if maxBreakNum < breakCfg.m_LimitBreakLevel then
      maxBreakNum = breakCfg.m_LimitBreakLevel
    end
  end
  return maxBreakNum
end

function HeroManager:IsHeroListItemHaveRedDot(heroID)
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return 0
  end
  local redPoint = 0
  local isCanBreakNum = self:IsHeroCanBreakUp(heroID)
  redPoint = redPoint + isCanBreakNum
  if 0 < redPoint then
    return redPoint
  end
  local isAttractNum = self:IsHeroAttractRedDot(heroID)
  redPoint = redPoint + isAttractNum
  if 0 < redPoint then
    return redPoint
  end
  local isFashionNum = self:IsHeroFashionHaveRedDot(heroID)
  redPoint = redPoint + isFashionNum
  if 0 < redPoint then
    return redPoint
  end
  redPoint = EquipManager:IsHeroCanEquipped(heroID)
  return redPoint
end

function HeroManager:IsHeroEntryHaveRedDot(heroID)
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return 0
  end
  local redPoint = 0
  local itemBreakNum = self:IsHeroCanBreakUp(heroID) or 0
  redPoint = redPoint + itemBreakNum
  if 0 < redPoint then
    return redPoint
  end
  local isAttractNum = self:IsHeroAttractRedDot(heroID)
  redPoint = redPoint + isAttractNum
  return redPoint
end

function HeroManager:IsHeroFashionHaveRedDot(heroID)
  if not heroID then
    return 0
  end
  if not self.m_HeroFashion then
    return 0
  end
  local isFashionBtnShow = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HeroFashion)
  if isFashionBtnShow ~= true then
    return 0
  end
  return self.m_HeroFashion:IsHeroFashionHaveRedDot(heroID)
end

function HeroManager:GetHeroEntryRedDotCount()
  if not self.m_HeroList then
    return 0
  end
  local heroRedDotCount = 0
  for _, heroData in ipairs(self.m_HeroList) do
    if heroData and self:IsHeroEntryHaveRedDot(heroData.serverData.iHeroId) == 1 then
      heroRedDotCount = heroRedDotCount + 1
    end
  end
  return heroRedDotCount
end

function HeroManager:CheckUpdateHeroEntryRedDotCount()
  if not self.m_HeroList then
    return
  end
  local redDotCount = 0
  local isCharacterOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Character)
  if isCharacterOpen then
    redDotCount = self:GetHeroEntryRedDotCount() or 0
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.HeroEntry,
    count = redDotCount
  })
end

function HeroManager:GetFormDataByLevelTypeAndSubType(levelType, levelSubType)
  local subTypeData = self.m_cacheFormDic[levelType]
  if not subTypeData then
    return
  end
  return self.m_cacheFormDic[levelType][levelSubType]
end

function HeroManager:SetCSFormData(levelType, levelSubType, formDataCS)
  local formatLuaData = {
    vHero = {},
    iPower = formDataCS.iPower,
    vStarUp = {}
  }
  local tempStarUpArray = formDataCS.vStarUp
  if tempStarUpArray then
    local tempLen = tempStarUpArray.Count
    if 0 < tempLen then
      for i = 1, tempLen do
        formatLuaData.vStarUp[#formatLuaData.vStarUp + 1] = tempStarUpArray[i - 1]
      end
    end
  end
  local tempHeroArray = formDataCS.vHero
  if tempHeroArray then
    local tempHeroLen = formDataCS.vHero.Count
    if 0 < tempHeroLen then
      for i = 1, tempHeroLen do
        local tempCSTab = tempHeroArray[i - 1]
        local tempTab = {
          iHeroId = tempCSTab.iHeroId,
          iPos = tempCSTab.iPos
        }
        formatLuaData.vHero[#formatLuaData.vHero + 1] = tempTab
      end
    end
  end
  self:SetFormData(levelType, levelSubType, formatLuaData)
end

function HeroManager:SetFormData(levelType, levelSubType, formatData)
  if not self.m_cacheFormDic[levelType] then
    self.m_cacheFormDic[levelType] = {}
  end
  self.m_cacheFormDic[levelType][levelSubType] = formatData
end

function HeroManager:GetCirculationLvByID(circulationID)
  if not circulationID then
    return
  end
  local circulationItem = self.m_circulationDic[circulationID] or {}
  return circulationItem.iLevel or 0
end

function HeroManager:GetCirculationExpByID(circulationID)
  if not circulationID then
    return
  end
  local circulationItem = self.m_circulationDic[circulationID] or {}
  return circulationItem.iExp or 0
end

function HeroManager:GetCirculationIDByType(circulationType, paramNum)
  if not circulationType then
    return
  end
  if circulationType == HeroManager.CirculationType.Root then
    return HeroManager.CirculationRootID
  end
  local circulationTypeIns = ConfigManager:GetConfigInsByName("CirculationType")
  local allCfgDic = circulationTypeIns:GetAll()
  if circulationType == HeroManager.CirculationType.Equip then
    for _, tempCfg in pairs(allCfgDic) do
      if tempCfg.m_CirculationType == circulationType and tempCfg.m_EquipTypeID == paramNum then
        return tempCfg.m_CirculationTypeID
      end
    end
  elseif circulationType == HeroManager.CirculationType.Camp then
    for _, tempCfg in pairs(allCfgDic) do
      if tempCfg.m_CirculationType == circulationType and tempCfg.m_CharacterCampID == paramNum then
        return tempCfg.m_CirculationTypeID
      end
    end
  end
end

function HeroManager:GetCirculationListByHeroID(heroID)
  local heroCfg = self:GetHeroConfigByID(heroID)
  if not heroCfg then
    return
  end
  local circulationTab = {}
  local rootID = HeroManager.CirculationRootID
  local rootLv = self:GetCirculationLvByID(rootID)
  local rootTab = {ID = rootID, lv = rootLv}
  circulationTab[#circulationTab + 1] = rootTab
  local camp = heroCfg.m_Camp
  local campCirculationID = self:GetCirculationIDByType(HeroManager.CirculationType.Camp, camp)
  local campCirculationLv = self:GetCirculationLvByID(campCirculationID)
  local campTab = {ID = campCirculationID, lv = campCirculationLv}
  circulationTab[#circulationTab + 1] = campTab
  local equipType = heroCfg.m_Equiptype
  local equipCirculationID = self:GetCirculationIDByType(HeroManager.CirculationType.Equip, equipType)
  local equipCirculationLv = self:GetCirculationLvByID(equipCirculationID)
  local equipTab = {ID = equipCirculationID, lv = equipCirculationLv}
  circulationTab[#circulationTab + 1] = equipTab
  return circulationTab
end

function HeroManager:FreshUpdateCirculationEntryRedDot()
  if not self.m_circulationDic then
    return
  end
  local redDotNum = self:IsCirculationEntryHaveRedDot()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.HeroCirculationEntry,
    count = redDotNum
  })
end

function HeroManager:IsCirculationEntryHaveRedDot()
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Circulation)
  if isOpen ~= true then
    return 0
  end
  local CirculationTypeIns = ConfigManager:GetConfigInsByName("CirculationType")
  local allCfg = CirculationTypeIns:GetAll()
  local redDotNum = 0
  for circulationID, v in pairs(allCfg) do
    if 0 < self:IsCirculationIDHaveRedDot(circulationID) then
      redDotNum = 1
      return redDotNum
    end
  end
  return redDotNum
end

function HeroManager:IsCirculationIDHaveRedDot(circulationID)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Circulation)
  if isOpen ~= true then
    return 0
  end
  if not circulationID then
    return 0
  end
  local CirculationLevelIns = ConfigManager:GetConfigInsByName("CirculationLevel")
  local circulationLv = self:GetCirculationLvByID(circulationID) or 0
  if circulationLv < 0 then
    return 0
  end
  local circulationCfg = CirculationLevelIns:GetValue_ByCirculationTypeAndLevel(circulationID, circulationLv)
  if circulationCfg:GetError() == true then
    return 0
  end
  local upAllExp = circulationCfg.m_Exp
  if upAllExp <= 0 then
    return 0
  end
  local curExp = self:GetCirculationExpByID(circulationID) or 0
  local upNeedExp = upAllExp - curExp
  local haveItemNum = ItemManager:GetItemNum(circulationCfg.m_ItemID)
  if upNeedExp <= haveItemNum then
    if circulationCfg.m_SynchronizeLevel ~= 0 then
      local conditionNum
      if circulationID == HeroManager.CirculationRootID then
        conditionNum = InheritManager:GetInheritLevel()
      else
        conditionNum = self:GetCirculationLvByID(HeroManager.CirculationRootID)
      end
      if conditionNum < circulationCfg.m_SynchronizeLevel then
        return 0
      else
        return 1
      end
    else
      return 1
    end
  end
  return 0
end

function HeroManager:IsHeroLegacyHaveRedDot(heroID)
  if not heroID then
    return 0
  end
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Legacy)
  if not openFlag then
    return 0
  end
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return 0
  end
  local stLegacyCmd = heroData.serverData.stLegacy or {}
  local legacyID = stLegacyCmd.iLegacyId
  if legacyID == nil or legacyID == 0 then
    return LegacyManager:IsLegacyWareRedDot()
  else
    return LegacyManager:IsLegacyCanUpgrade(legacyID)
  end
end

function HeroManager:GetSkillGroupCfgList(skillGroupID)
  if not skillGroupID then
    return
  end
  local skillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
  local skillGroupCfgDic = skillGroupInstance:GetValue_BySkillGroupID(skillGroupID)
  local skillGroupCfgList = {}
  for _, v in pairs(skillGroupCfgDic) do
    if v.m_SkillShowType > 0 then
      skillGroupCfgList[#skillGroupCfgList + 1] = v
    end
  end
  return skillGroupCfgList
end

function HeroManager:GetHeroSkillMaxLvById(heroId, skillId)
  local heroCfg = self:GetHeroConfigByID(heroId)
  local skillGroupID = heroCfg.m_SkillGroupID[0]
  return self:GetSkillMaxLevelById(skillGroupID, skillId)
end

function HeroManager:GetHeroSkillLvById(heroId, skillId)
  local heroData = self:GetHeroDataByID(heroId)
  if not heroData then
    local heroCfg = self:GetHeroConfigByID(heroId)
    local skillGroupID = heroCfg.m_SkillGroupID[0]
    return self:GetSkillMaxLevelById(skillGroupID, skillId)
  end
  local serverData = heroData.serverData
  local mSkill = serverData.mSkill or {}
  for id, lv in pairs(mSkill) do
    if id == skillId then
      return lv
    end
  end
  return 1
end

function HeroManager:GetHeroSkillDataByHeroCfgId(heroCfgId, skill_list)
  local heroCfg = self:GetHeroConfigByID(heroCfgId)
  local skillGroupID = heroCfg.m_SkillGroupID[0]
  local skillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
  local skillGroupCfgDic = skillGroupInstance:GetValue_BySkillGroupID(skillGroupID)
  local skillDesList = {}
  for _, skillGroupCfg in pairs(skillGroupCfgDic) do
    local skillId = skillGroupCfg.m_SkillID
    local curLevel = self:GetHeroSkillLvById(heroCfgId, skillId)
    local level = curLevel
    if skill_list and skill_list[skillId] then
      level = skill_list[skillId]
    end
    skillDesList[skillId] = self:GetSkillDescriptionBySkillIdAndLv(skillId, level)
  end
  return skillDesList
end

function HeroManager:GetSkillValueByIdAndLevel(skillValueId, skillLv)
  skillLv = skillLv or 1
  local skillValueInstance = ConfigManager:GetConfigInsByName("SkillValue")
  local cfg = skillValueInstance:GetValue_BySkillValueID(skillValueId)
  if cfg:GetError() then
    return
  end
  local paramList = utils.changeCSArrayToLuaTable(cfg.m_Num)
  return paramList[skillLv], cfg.m_ValueType
end

function HeroManager:GetSkillBuffCfg(buffID)
  local SkillBuffIns = ConfigManager:GetConfigInsByName("SkillBuff")
  local buffCfg = SkillBuffIns:GetValue_ByBuffID(buffID)
  if buffCfg:GetError() then
    log.error("can not find SkillBuffCfg by id == " .. tostring(buffID))
    return
  end
  return buffCfg
end

function HeroManager:GetBuffDescribeByCfg(buffCfg)
  local buffParamList = {}
  local buffParamArray = buffCfg.m_BuffParam
  local showParamStr = buffCfg.m_mDescribe
  local paramFStr = "%.f"
  local paramFStr1 = "%.1f"
  if buffParamArray then
    local arrayLen = buffParamArray.Length
    for i = 1, arrayLen do
      local skillValueId = buffParamArray[i - 1]
      local value, valueType = self:GetSkillValueByIdAndLevel(skillValueId, 1)
      if GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[valueType] then
        local paramF = GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.Fixed == valueType and paramFStr or paramFStr1
        value = string.format(paramF, value / GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[valueType])
      end
      if GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent == valueType then
        value = string.format(ConfigManager:GetCommonTextById(100009), tostring(value))
      else
      end
      buffParamList[#buffParamList + 1] = value
    end
    if 0 < arrayLen then
      showParamStr = string.CS_Format(showParamStr, buffParamList)
    end
  end
  return showParamStr, buffParamList
end

function HeroManager:GetSkillDescribeByParam(des, param)
  local paramList = {}
  local paramArray = param
  local showParamStr = des
  local paramFStr = "%.f"
  local paramFStr1 = "%.1f"
  if paramArray then
    local arrayLen = paramArray.Length
    for i = 1, arrayLen do
      local skillValueId = paramArray[i - 1]
      local value, valueType = self:GetSkillValueByIdAndLevel(skillValueId, 1)
      if GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[valueType] then
        local paramF = GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.Fixed == valueType and paramFStr or paramFStr1
        value = string.format(paramF, value / GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[valueType])
      end
      if GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent == valueType then
        value = string.format(ConfigManager:GetCommonTextById(100009), tostring(value))
      else
      end
      paramList[#paramList + 1] = value
    end
    if 0 < arrayLen then
      showParamStr = string.CS_Format(showParamStr, paramList)
    end
  end
  return showParamStr, paramList
end

function HeroManager:GetSkillDescriptionBySkillIdAndLv(skillId, skillLv, showNext)
  local skillCfg = self:GetSkillConfigById(skillId)
  local des = skillCfg.m_mSkillDescription
  local nextUpgradeParam = {}
  if showNext then
    nextUpgradeParam = utils.changeCSArrayToLuaTable(skillCfg.m_SkillValue)
  end
  local paramList = utils.changeCSArrayToLuaTable(skillCfg.m_SkillValue)
  local skillParams = {}
  for i, v in ipairs(paramList) do
    local value = 0
    local nextValue = 0
    local paramValue, paramType = self:GetSkillValueByIdAndLevel(v, skillLv)
    local paramFStr = "%.f"
    local paramFStr1 = "%.1f"
    if GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[paramType] then
      local paramF = GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.Fixed == paramType and paramFStr or paramFStr1
      value = string.format(paramF, paramValue / GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[paramType])
    else
      log.error("GetSkillDescriptionBySkillIdAndLv Undefined skill parameter type " .. tostring(paramType))
    end
    if showNext then
      local paramValueNext, paramTypeNext = self:GetSkillValueByIdAndLevel(v, skillLv + 1)
      if paramValueNext and paramValue < paramValueNext then
        local paramF = GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.Fixed == paramType and paramFStr or paramFStr1
        nextValue = string.format(paramF, paramValueNext / GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[paramTypeNext])
      end
      if 0 < tonumber(nextValue) then
        local textId = paramType == GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent and 2022 or 2021
        value = string.format(ConfigManager:GetCommonTextById(textId), tostring(value), tostring(nextValue))
      elseif GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.Fixed == paramType or GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent2 == paramType then
        value = tostring(value)
      else
        value = string.format(ConfigManager:GetCommonTextById(100009), tostring(value))
      end
    elseif GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent == paramType then
      value = string.format(ConfigManager:GetCommonTextById(100009), tostring(value))
    elseif GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent2 == paramType then
    end
    skillParams[#skillParams + 1] = value
  end
  return string.gsubnumberreplace(des, table.unpack(skillParams))
end

function HeroManager:GetSkillMaxLevelById(skillGroupId, skillId)
  local skillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
  local skillGroupCfgDic = skillGroupInstance:GetValue_BySkillGroupIDAndSkillID(skillGroupId, skillId)
  if skillGroupCfgDic:GetError() then
    log.error("GetSkillTemplateCfgById is error skillGroupId and skillId == " .. tostring(skillGroupId) .. tostring(skillId))
    return
  end
  local SkillTemplateID = skillGroupCfgDic.m_SkillTemplateID
  local SkillTemplateInstance = ConfigManager:GetConfigInsByName("SkillTemplate")
  local SkillTemplateArr = SkillTemplateInstance:GetValue_BySkillTemplateID(SkillTemplateID)
  return math.max(SkillTemplateArr.Count, 1)
end

function HeroManager:GetSkillCost(skillId, skillLevel)
  local skillCfg = self:GetSkillConfigById(skillId)
  if skillCfg.m_SkillType == 2 and skillCfg.m_NewEnergy then
    local prevSecondValue = -math.huge
    local newEnergy = utils.changeCSArrayToLuaTable(skillCfg.m_NewEnergy) or {}
    for _, row in ipairs(newEnergy) do
      local firstValue = row[1]
      local secondValue = row[2]
      if skillLevel <= secondValue and skillLevel > prevSecondValue then
        return math.floor(firstValue / 10000)
      end
    end
  end
  return -1
end

function HeroManager:GetSkillTemplateByIDAndSkillLevel(skillGroupId, skillId, skillLv)
  local skillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
  local skillGroupCfgDic = skillGroupInstance:GetValue_BySkillGroupIDAndSkillID(skillGroupId, skillId)
  if skillGroupCfgDic:GetError() then
    log.error("GetSkillTemplateCfgById is error skillGroupId and skillId == " .. tostring(skillGroupId) .. tostring(skillId))
    return
  end
  local SkillTemplateID = skillGroupCfgDic.m_SkillTemplateID
  local SkillTemplateInstance = ConfigManager:GetConfigInsByName("SkillTemplate")
  local SkillTemplate = SkillTemplateInstance:GetValue_BySkillTemplateIDAndSkillLevel(SkillTemplateID, skillLv)
  if SkillTemplate:GetError() then
    log.error("GetSkillTemplateCfgById is error SkillTemplateID == " .. tostring(SkillTemplateID))
    return
  end
  return SkillTemplate
end

function HeroManager:GetSkillConfigById(skillId)
  local SkillInstance = ConfigManager:GetConfigInsByName("Skill")
  local tempSkillCfg = SkillInstance:GetValue_BySkillID(skillId)
  if tempSkillCfg:GetError() then
    return
  end
  return tempSkillCfg
end

function HeroManager:IsHeroSkillCanUpGrade(heroID)
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return 0
  end
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.SkillLevelUp)
  if isOpen ~= true then
    return 0
  end
  local heroCfg = heroData.characterCfg
  local skillGroupID = heroCfg.m_SkillGroupID[0]
  local skillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
  local skillGroupCfgDic = skillGroupInstance:GetValue_BySkillGroupID(skillGroupID)
  for _, skillGroupCfg in pairs(skillGroupCfgDic) do
    local skillID = skillGroupCfg.m_SkillID
    local canLvUp = self:CheckHeroSkillCanLevelUp(heroID, skillID)
    if canLvUp then
      return 1
    end
  end
  return 0
end

function HeroManager:CheckHeroSkillCanLevelUp(heroId, skillId)
  local heroData = self:GetHeroDataByID(heroId)
  local heroCfg = heroData.characterCfg
  local skillGroupID = heroCfg.m_SkillGroupID[0]
  local curLevel = self:GetHeroSkillLvById(heroId, skillId)
  local maxLv = self:GetSkillMaxLevelById(skillGroupID, skillId)
  if curLevel < maxLv then
    local skillTemplate = self:GetSkillTemplateByIDAndSkillLevel(skillGroupID, skillId, curLevel)
    local skillLevelUpCostList = utils.changeCSArrayToLuaTable(skillTemplate.m_SkillLevelUpCost) or {}
    local canLvUp = true
    for i = 1, #skillLevelUpCostList do
      local userItemNum = ItemManager:GetItemNum(skillLevelUpCostList[i][1])
      if userItemNum < skillLevelUpCostList[i][2] then
        canLvUp = false
      end
    end
    return canLvUp
  end
  return false
end

function HeroManager:GetCharacterBattleStarCfg(heroCfgId, starLv)
  local CharacterBattleStarIns = ConfigManager:GetConfigInsByName("CharacterBattleStar")
  local characterBattleStarCfg = CharacterBattleStarIns:GetValue_ByHeroIDAndStarLevel(heroCfgId, starLv)
  if characterBattleStarCfg:GetError() then
    log.warn("GetCharacterBattleStarCfg is error heroId == " .. tostring(heroCfgId) .. " starLv == " .. tostring(starLv))
    return
  end
  return characterBattleStarCfg
end

function HeroManager:GetHeroUpStarSkillDes(heroCfgId)
  local upStarDesTab = {}
  for starLv = 2, GlobalConfig.HERO_BATTLE_STAR do
    local cfg = self:GetCharacterBattleStarCfg(heroCfgId, starLv)
    upStarDesTab[starLv] = cfg
  end
  return upStarDesTab
end

function HeroManager:GetHeroSkillShowTypeDes(heroId, skillId)
  local skillTypeName = "???"
  local skillShowType = 1
  local heroCfg = self:GetHeroConfigByID(heroId)
  local skillGroupID = heroCfg.m_SkillGroupID[0]
  local SkillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
  local tempSkillGroupCfg = SkillGroupInstance:GetValue_BySkillGroupIDAndSkillID(skillGroupID, skillId)
  if not tempSkillGroupCfg:GetError() then
    skillShowType = tempSkillGroupCfg.m_SkillShowType
    local txtId = GlobalConfig.SKILL_SHOW_TYPE_COMMON_TXT_ID_LIST[skillShowType]
    if txtId then
      skillTypeName = ConfigManager:GetCommonTextById(txtId)
    end
  end
  return skillTypeName, skillShowType
end

function HeroManager:GetHeroCfgListByCamp(camp)
  local characterIns = ConfigManager:GetConfigInsByName("CharacterInfo")
  local characterAll = characterIns:GetAll()
  local cfgList = {}
  for i, v in pairs(characterAll) do
    if v.m_OnSale == 0 and v.m_Camp == camp then
      cfgList[#cfgList + 1] = v
    end
  end
  return cfgList
end

function HeroManager:GetHeroServerDataListByCamp(camp)
  local dataList = {}
  for i, v in ipairs(self.m_HeroList) do
    if v.characterCfg and v.characterCfg.m_Camp == camp then
      dataList[#dataList + 1] = v
    end
  end
  return dataList
end

function HeroManager:GetTopFiveHeroByCombat()
  local topFive = {}
  local totalCombat = 0
  
  local function sortFun(data1, data2)
    if data1.serverData.iPower == data2.serverData.iPower then
      if data1.serverData.iLevel == data2.serverData.iLevel then
        return data1.serverData.iHeroId < data2.serverData.iHeroId
      else
        return data1.serverData.iLevel > data2.serverData.iLevel
      end
    else
      return data1.serverData.iPower > data2.serverData.iPower
    end
  end
  
  table.sort(self.m_HeroList, sortFun)
  for i = 1, 5 do
    if self.m_HeroList[i] then
      topFive[#topFive + 1] = self.m_HeroList[i]
      totalCombat = totalCombat + self.m_HeroList[i].serverData.iPower
    end
  end
  return topFive, totalCombat
end

function HeroManager:GetTopFiveHeroPower()
  local topFive = self:GetTopFiveHeroByCombat()
  local power = 0
  for i, v in ipairs(topFive) do
    if v.serverData and v.serverData.iPower then
      power = power + v.serverData.iPower
    end
  end
  return power
end

function HeroManager:ReqHeroSetLove(heroID, bLove)
  if not heroID or not heroID then
    return
  end
  local msg = MTTDProto.Cmd_Hero_SetHeroLove_CS()
  msg.iHeroId = heroID
  msg.bLove = bLove
  RPCS():Hero_SetHeroLove(msg, handler(self, self.OnHeroSetLoveSC))
end

function HeroManager:OnHeroSetLoveSC(sc, msg)
  local heroID = sc.iHeroId
  local bLove = sc.bLove
  for _, v in ipairs(self.m_HeroList) do
    if v.serverData.iHeroId == heroID then
      v.serverData.bLove = bLove
      break
    end
  end
  self:broadcastEvent("eGameEvent_Hero_SetLove", bLove)
end

function HeroManager:GetCharacterCampCfgByCamp(camp)
  local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
  local stItemData = CampCfgIns:GetValue_ByCampID(camp)
  if stItemData:GetError() then
    log.error("GetCharacterCampCfgByCamp error camp = " .. tostring(camp))
    return
  end
  return stItemData
end

function HeroManager:GetCharacterCareerCfgByCareer(career)
  local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
  local stItemData = CareerCfgIns:GetValue_ByCareerID(career)
  if stItemData:GetError() then
    log.error("GetCharacterCareerCfgByCareer error  career = " .. tostring(career))
    return
  end
  return stItemData
end

function HeroManager:GetHeroQualityById(heroId)
  local cfg = self:GetHeroConfigByID(heroId)
  if cfg:GetError() then
    log.error("can not find hero id in CharacterInfo config  id==" .. tostring(heroId))
    return
  end
  return cfg.m_Quality
end

function HeroManager:GetMonsterGroupCfgById(monsterGroupId)
  local MonsterGroupIns = ConfigManager:GetConfigInsByName("MonsterGroup")
  local cfg = MonsterGroupIns:GetValue_ByID(monsterGroupId)
  if cfg:GetError() then
    log.error("GetMonsterGroupCfgById error  monsterGroupId = " .. tostring(monsterGroupId))
    return
  end
  return cfg
end

function HeroManager:GetMonsterLevelCfgByLv(levelTemplate, level)
  local MonsterLevelIns = ConfigManager:GetConfigInsByName("MonsterLevel")
  local monsterLevelCfg = MonsterLevelIns:GetValue_ByLevelTemplateAndLevel(levelTemplate, level)
  if monsterLevelCfg:GetError() then
    log.error("GetMonsterLevelCfgByLv error  levelTemplate level = " .. tostring(levelTemplate) .. tostring(level))
    return
  end
  return monsterLevelCfg
end

function HeroManager:GetMonstersAttrsByBattleWorldId(battleWorldId)
  local battleWorldCfg = ConfigManager:GetBattleWorldCfgById(battleWorldId)
  local monsterGroupList = utils.changeCSArrayToLuaTable(ConfigManager:BattleWorldMonsterGroupList(battleWorldCfg))
  local monstersAttrMap = {}
  for i, v in ipairs(monsterGroupList) do
    monstersAttrMap[v] = self:GetMonstersAttrsByBattleWorldIdAndMonsterGroup(battleWorldId, v)
  end
  return monstersAttrMap
end

function HeroManager:GetMonstersAttrsByBattleWorldIdAndMonsterGroupList(battleWorldId, monsterGroupList)
  local monstersAttrMap = {}
  for i, v in ipairs(monsterGroupList) do
    for m, monsterGroupId in pairs(v) do
      monstersAttrMap[monsterGroupId] = self:GetMonstersAttrsByBattleWorldIdAndMonsterGroup(battleWorldId, monsterGroupId)
    end
  end
  return monstersAttrMap
end

function HeroManager:GetMonstersAttrsByBattleWorldIdAndMonsterGroup(battleWorldId, monsterGroupId)
  local monstersAttrList = {}
  local monsterLevel = 0
  local battleWorldCfg = ConfigManager:GetBattleWorldCfgById(battleWorldId)
  local monsterGroupCfg = self:GetMonsterGroupCfgById(monsterGroupId)
  if battleWorldCfg and monsterGroupCfg then
    monsterLevel = battleWorldCfg.m_MonsterLevel
    if monsterLevel == -1 then
      monsterLevel = monsterGroupCfg.m_MonsterAttrLevel
    end
    local monsterList = utils.changeCSArrayToLuaTable(monsterGroupCfg.m_MonsterList)
    local waveCoefficient = utils.changeCSArrayToLuaTable(monsterGroupCfg.m_WaveCoefficient)
    local difficultyNum = utils.changeCSArrayToLuaTable(battleWorldCfg.m_difficultyNum)
    for i, v in ipairs(monsterList) do
      monstersAttrList[#monstersAttrList + 1] = {
        attr = self:GetMonsterAttrsByMonsterID(v[2], monsterLevel, waveCoefficient, difficultyNum),
        id = v[2]
      }
    end
  end
  return monstersAttrList
end

function HeroManager:GetMonsterAttrsByMonsterID(monsterId, level, waveCoefficient, difficultyNum)
  local monsterAttr = {}
  local MonsterIns = ConfigManager:GetConfigInsByName("Monster")
  local cfg = MonsterIns:GetValue_ByMonsterID(monsterId)
  if cfg:GetError() then
    log.error("GetMonsterAttrsByMonsterID error monsterId =" .. tostring(monsterId))
    return
  end
  local levelTemplate = cfg.m_LevelTemplateID
  local levelTemplateGroupCfg = self:GetMonsterLevelTemplateGroup(levelTemplate)
  if levelTemplateGroupCfg then
    local tempLevelCfg = levelTemplateGroupCfg[level]
    monsterAttr = self:GetMonsterBaseAttrByPropertyID(cfg.m_MonsterAttrID, tempLevelCfg, waveCoefficient, difficultyNum)
  end
  return monsterAttr
end

function HeroManager:GetMonsterBaseAttrByPropertyID(propertyID, tempLevelCfg, waveCoefficient, difficultyNum)
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  local PropertyIns = ConfigManager:GetConfigInsByName("Property")
  local basePropertyCfg = PropertyIns:GetValue_ByPropertyID(propertyID)
  local allPropertyIndexCfg = PropertyIndexIns:GetAll()
  local retParamTab = {}
  local levelTemplateCfg = tempLevelCfg.levelTemplateCfg
  local otherPropertyCfg = tempLevelCfg.otherPropertyCfg
  for _, propertyIndexCfg in pairs(allPropertyIndexCfg) do
    if propertyIndexCfg.m_Compute == 1 then
      local paramStr = propertyIndexCfg.m_ENName
      local levelTemplateParam = levelTemplateCfg[string_format("m_%sParam", paramStr)]
      local basePropertyNum = basePropertyCfg["m_" .. paramStr]
      local otherPropertyNum = 0
      if otherPropertyCfg then
        otherPropertyNum = otherPropertyCfg["m_" .. paramStr]
      end
      local paramNum = 0
      if AttrBaseShowCfg[propertyIndexCfg.m_PropertyID] then
        local coefficient = 1
        local difficulty = 1
        if waveCoefficient then
          for i, v in ipairs(waveCoefficient) do
            if v[1] == propertyIndexCfg.m_PropertyID then
              coefficient = v[2] / 10000
            end
          end
        end
        if difficultyNum then
          for i, v in ipairs(difficultyNum) do
            if v[1] == propertyIndexCfg.m_PropertyID then
              difficulty = v[2] / 10000
            end
          end
        end
        local basePropertyRate = basePropertyCfg[string_format("m_Lv_%s_Rate", paramStr)]
        local otherPropertyRate = 0
        if otherPropertyCfg then
          otherPropertyRate = otherPropertyCfg[string_format("m_Lv_%s_Rate", paramStr)]
        end
        paramNum = basePropertyNum + otherPropertyNum + (basePropertyRate + otherPropertyRate) / 10000 * levelTemplateParam
        retParamTab[paramStr] = math.floor(paramNum * coefficient * difficulty)
      end
    end
  end
  return retParamTab
end

function HeroManager:GetMonsterLevelTemplateGroup(levelTemplate)
  if not levelTemplate then
    return
  end
  if self.m_monsterLevelTemplateCache[levelTemplate] then
    return self.m_monsterLevelTemplateCache[levelTemplate]
  end
  local MonsterLevelIns = ConfigManager:GetConfigInsByName("MonsterLevel")
  local PropertyIns = ConfigManager:GetConfigInsByName("Property")
  local characterLevelTemplateCfgDic = {}
  local levelTemplateGroupCfg = MonsterLevelIns:GetValue_ByLevelTemplate(levelTemplate)
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
  self.m_monsterLevelTemplateCache[levelTemplate] = characterLevelTemplateCfgDic
  return self.m_monsterLevelTemplateCache[levelTemplate]
end

function HeroManager:GetTeamTypeByTeamIdxAndTypeBase(teamTypeBase, teamIdx)
  if not teamTypeBase or not teamIdx then
    return
  end
  return teamTypeBase * 10 + teamIdx
end

function HeroManager:GetTeamIdxByTypeBaseAndTeamType(teamTypeBase, teamType)
  if not teamTypeBase or not teamType then
    return
  end
  if teamTypeBase == 0 then
    return teamType
  end
  return teamType % (teamTypeBase * 10)
end

function HeroManager:OpenFilterPanel(filterInfo, click_transform, chooseBackFun, isHideShowMoonType, isCs)
  local filterData = utils.changeCSArrayToLuaTable(filterInfo)
  utils.openForm_filter(filterData, click_transform, {x = 0, y = 0}, {x = -35, y = 40}, chooseBackFun, isHideShowMoonType, isCs)
end

function HeroManager:GenerateCommonHeroIconData(serverData)
  local commonHeroData = {}
  commonHeroData.iHeroId = serverData.iHeroId
  commonHeroData.iLevel = serverData.iLevel
  commonHeroData.iBreak = serverData.iBreak or 0
  commonHeroData.iBaseId = serverData.iBaseId
  commonHeroData.iOriLevel = serverData.iOriLevel or 0
  commonHeroData.iPower = serverData.iPower or 0
  commonHeroData.iFashion = serverData.iFashion
  return commonHeroData
end

function HeroManager:CheckHeroSkillResetActivityIsOpen()
  local cutDownTime = 0
  local isOpen = false
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_HeroSkillReset)
  if activity and activity.GetActivityEndTime then
    local actEndTime = activity:GetActivityEndTime()
    local serverTime = TimeUtil:GetServerTimeS()
    cutDownTime = actEndTime - serverTime
    isOpen = activity:IsInActivityTime()
  end
  return isOpen, cutDownTime
end

function HeroManager:GetSkillResetItem()
  return self.m_SkillResetItemId, self.m_SkillResetItemNum
end

function HeroManager:CheckSkillResetIsEnough()
  local itemNum = ItemManager:GetItemNum(tonumber(self.m_SkillResetItemId))
  local needNum = tonumber(self.m_SkillResetItemNum)
  return itemNum >= needNum
end

function HeroManager:GetHeroIntrinsicSkills(heroId)
  local skillIds = {}
  local heroData = self:GetHeroDataByID(heroId)
  if heroData then
    local heroCfg = heroData.characterCfg
    local skillGroupID = heroCfg.m_SkillGroupID[0]
    if skillGroupID then
      local skillGroupCfgList = self:GetSkillGroupCfgList(skillGroupID)
      if skillGroupCfgList then
        for _, skillGroupCfg in ipairs(skillGroupCfgList) do
          skillIds[#skillIds + 1] = skillGroupCfg.m_SkillID
        end
      end
    end
  end
  return skillIds
end

function HeroManager:GetHeroSkillCosts(heroId)
  local heroData = self:GetHeroDataByID(heroId)
  local heroCfg = heroData.characterCfg
  local skillGroupID = heroCfg.m_SkillGroupID[0]
  local serverData = heroData.serverData
  local mSkill = serverData.mSkill or {}
  local skillIdList = self:GetHeroIntrinsicSkills(heroId)
  local skillCostList = {}
  local skillCostMap = {}
  if 0 < table.getn(mSkill) and 0 < table.getn(skillIdList) then
    for _, skillId in pairs(skillIdList) do
      local lv = self:GetHeroSkillLvById(heroId, skillId)
      if 1 < lv then
        for i = 1, lv - 1 do
          local skillTemplate = self:GetSkillTemplateByIDAndSkillLevel(skillGroupID, skillId, i)
          if skillTemplate then
            local skillLevelUpCost = skillTemplate.m_SkillLevelUpCost
            for m = 0, skillLevelUpCost.Length - 1 do
              local item = skillLevelUpCost[m]
              if not skillCostMap[item[0]] then
                skillCostMap[item[0]] = item[1]
              else
                skillCostMap[item[0]] = skillCostMap[item[0]] + item[1]
              end
            end
          end
        end
      end
    end
  end
  for i, v in pairs(skillCostMap) do
    skillCostList[#skillCostList + 1] = {i, v}
  end
  return skillCostList, skillCostMap
end

function HeroManager:CheckHeroSkillLvUp(heroId)
  local heroData = self:GetHeroDataByID(heroId)
  if not heroData then
    return false
  end
  local serverData = heroData.serverData
  local mSkill = serverData.mSkill or {}
  local skillIdList = self:GetHeroIntrinsicSkills(heroId)
  if table.getn(mSkill) > 0 and table.getn(skillIdList) > 0 then
    for _, skillId in pairs(skillIdList) do
      local lv = self:GetHeroSkillLvById(heroId, skillId)
      if 1 < lv then
        return true
      end
    end
  end
  return false
end

local ATTR_COEFFICIENT = 10000.0

function HeroManager:GetAttrInfoList(attrList)
  local attrInfoList = {}
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  for i, attr in pairs(attrList) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(attr[1])
    local paramNum = math.floor(attr[2]) or 0
    if propertyIndexCfg.m_Type == 2 then
      paramNum = paramNum / ATTR_COEFFICIENT
    end
    attrInfoList[#attrInfoList + 1] = {
      name = propertyIndexCfg.m_mCNName,
      num = paramNum,
      id = attr[1]
    }
  end
  return attrInfoList
end

function HeroManager:GetCharacterTrialCfgById(heroId)
  local characterTrialIns = ConfigManager:GetConfigInsByName("CharacterTrial")
  local cfg = characterTrialIns:GetValue_ByID(heroId)
  if cfg:GetError() then
    log.error("GetCharacterTrialCfgById error heroId =" .. tostring(heroId))
    return
  end
  return cfg
end

function HeroManager:GetCurUseFashionID(heroID)
  if not heroID then
    return 0
  end
  local heroData = self:GetHeroDataByID(heroID)
  if not heroData then
    return 0
  end
  return heroData.serverData.iFashion
end

function HeroManager:GetCharacterViewModeCfgById(fashionId)
  return self.m_cacheCharacterViewModeCfgDic[fashionId]
end

return HeroManager
