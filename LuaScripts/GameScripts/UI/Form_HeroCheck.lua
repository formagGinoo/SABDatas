local Form_HeroCheck = class("Form_HeroCheck", require("UI/UIFrames/Form_HeroCheckUI"))
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
local CharacterTagIns = ConfigManager:GetConfigInsByName("CharacterTag")
local CharacterDamageTypeIns = ConfigManager:GetConfigInsByName("CharacterDamageType")
local SkillNum = 4
local String_format = string.format
local StarMaxNum = 3
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local StarInAnimStr = "star_in"
local StarOutAnimStr = "star_out"
local SRBreakNum = 2
local SSRBreakNum = 3
local CharacterTagNum = 4

function Form_HeroCheck:SetInitParam(param)
end

function Form_HeroCheck:AfterInit()
  self.super.AfterInit(self)
  self:AddEventListeners()
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("panel_detail_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1101)
  self.m_curHeroID = nil
  self.m_heroCfg = nil
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_skillCfgList = nil
  self.m_skillGroupId = nil
  self.m_attr_base_root_trans = self.m_attr_base_root.transform
  self.m_showAttrBaseItems = {}
  self.m_skillCfgList = nil
  self.m_skillGroupId = nil
  self.m_isShowSkillPanel = true
  self.m_showAttrBaseCfgList = {}
  self.m_showHeroMaxLv = true
  self:InitShowAttr()
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_HeroCheck:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  self:PlayHeroDisPlayVoice(self.m_heroCfg)
end

function Form_HeroCheck:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_FashionJump", handler(self, self.OnHeroFashionJump))
end

function Form_HeroCheck:OnHeroFashionJump()
  self:CloseForm()
end

function Form_HeroCheck:PlayHeroDisPlayVoice(heroCfg)
  local m_PerformanceID = heroCfg.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_GainVoice then
    return
  end
  if self.m_playingDisplayId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId)
    self.m_playingDisplayId = nil
  end
  if self.m_playingDisplayId2 then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId2)
    self.m_playingDisplayId2 = nil
  end
  CS.UI.UILuaHelper.StartPlaySFX(presentationData.m_CharDisplayVoice, nil, function(playingDisplayId)
    self.m_playingDisplayId = playingDisplayId
  end, function()
    self.m_playingDisplayId = nil
  end)
  CS.UI.UILuaHelper.StartPlaySFX(presentationData.m_GainVoiceEvent, nil, function(playingDisplayId)
    self.m_playingDisplayId2 = playingDisplayId
  end, function()
    self.m_playingDisplayId2 = nil
  end)
end

function Form_HeroCheck:FreshDamageType(heroAttribute)
  if not heroAttribute then
    return
  end
  local damageCfg = CharacterDamageTypeIns:GetValue_ByDamageType(heroAttribute)
  if damageCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_damagetype_Image, damageCfg.m_DamageTypeIcon)
end

function Form_HeroCheck:OnInactive()
  if self.m_playingDisplayId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId)
    self.m_playingDisplayId = nil
  end
  if self.m_playingDisplayId2 then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId2)
    self.m_playingDisplayId2 = nil
  end
  self:CheckRecycleSpine(true)
  self.super.OnInactive(self)
end

function Form_HeroCheck:ChangeHeroDummyData()
  self.m_heroBreak = self.m_showHeroMaxLv and self:GetHeroCheckBreakNum() or 0
  self.m_heroMaxLevelNum = self.m_showHeroMaxLv and self:GetHeroLevelMax() or 1
  self.m_heroAttrList = self.m_heroAttr:GetLvBreakAllAttr(self.m_curHeroID, self.m_heroMaxLevelNum, self.m_heroBreak or 0)
  self.m_heroSkillList = self:GetLocalHeroSKills(self.m_heroCfg.m_SkillGroupID[0])
  self:FreshUI(true)
end

function Form_HeroCheck:OnBtnswitchClicked()
  self.m_showHeroMaxLv = not self.m_showHeroMaxLv
  self:ChangeHeroDummyData()
end

function Form_HeroCheck:OnDestroy()
  self:CheckRecycleSpine(true)
  self.super.OnDestroy(self)
  if self.m_startInAnimTimer then
    TimeService:KillTimer(self.m_startInAnimTimer)
    self.m_startInAnimTimer = nil
  end
end

function Form_HeroCheck:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  local heroID = tParam.heroID
  if not heroID then
    return
  end
  self.m_closeCallBackFun = tParam.callBackFun
  self.m_csui.m_param = nil
  self.m_curHeroID = heroID
  self.m_heroServerData = tParam.heroServerData
  self.m_heroCfg = CharacterInfoIns:GetValue_ByHeroID(self.m_curHeroID)
  if self.m_heroCfg:GetError() then
    return
  end
  self.m_showHeroMaxLv = true
  self.m_serverPower = nil
  if self.m_heroServerData then
    self.m_heroMaxLevelNum = self.m_heroServerData.iLevel or 1
    self.m_heroBreak = self.m_heroServerData.iBreak or 0
    self.m_heroAttrList = self.m_heroServerData.mHeroAttr[0] or {}
    self.m_heroSkillList = self.m_heroServerData.mSkill or {}
    self.m_serverPower = self.m_heroServerData.iPower or 0
  else
    self.m_heroBreak = self:GetHeroCheckBreakNum()
    self.m_heroMaxLevelNum = self:GetHeroLevelMax()
    self.m_heroAttrList = self.m_heroAttr:GetLvBreakAllAttr(self.m_curHeroID, self.m_heroMaxLevelNum, self.m_heroBreak or 0)
    self.m_heroSkillList = self:GetLocalHeroSKills(self.m_heroCfg.m_SkillGroupID[0])
  end
end

function Form_HeroCheck:FreshUI(isNoFreshSpine)
  self.m_skillCfgList = nil
  self.m_skillGroupId = nil
  self.m_btn_switch:SetActive(self.m_heroServerData == nil)
  self.m_z_txt_max:SetActive(self.m_showHeroMaxLv)
  self.m_z_txt_min:SetActive(not self.m_showHeroMaxLv)
  self:ShowHeroTag()
  if not isNoFreshSpine then
    self:FreshShowHeroInfo()
  end
  self.m_isShowSkillPanel = true
  self:FreshShowHeroBaseInfo()
  self:FreshBreakStatus()
  self:FreshSkinBtnStatus()
  ResourceUtil:CreateEquipTypeImg(self.m_icon_equip_Image, self.m_heroCfg.m_Equiptype)
end

function Form_HeroCheck:ShowHeroTag()
  local tagList = utils.changeCSArrayToLuaTable(self.m_heroCfg.m_CharacterTag)
  if tagList and 0 < #tagList then
    self.m_hero_showtag:SetActive(true)
    for i = 1, CharacterTagNum do
      if self["m_line" .. i] then
        self["m_line" .. i]:SetActive(false)
      end
      if tagList[i] then
        local cfg = CharacterTagIns:GetValue_ByTagID(tagList[i])
        if not cfg:GetError() then
          self["m_txt_tag" .. i .. "_Text"].text = cfg.m_mTagName
        end
        self["m_txt_tag" .. i]:SetActive(true)
        if self["m_line" .. i - 1] then
          self["m_line" .. i - 1]:SetActive(true)
        end
      else
        self["m_txt_tag" .. i]:SetActive(false)
      end
    end
  else
    self.m_hero_showtag:SetActive(false)
  end
end

function Form_HeroCheck:FreshBreakStatus()
  local breakNum = self.m_heroBreak
  local heroCfg = self.m_heroCfg
  local quality = heroCfg.m_Quality
  if quality == HeroManager.QualityType.R then
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, false)
    UILuaHelper.SetActive(self.m_img_break_SSR4, false)
  elseif quality == HeroManager.QualityType.SR then
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, true)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, false)
    UILuaHelper.SetActive(self.m_img_break_SSR4, false)
    for i = 1, SRBreakNum do
      UILuaHelper.SetActive(self["m_img_break_SR" .. i], i <= breakNum)
    end
  else
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, breakNum <= SSRBreakNum)
    UILuaHelper.SetActive(self.m_img_break_SSR4, breakNum > SSRBreakNum)
    if breakNum <= SSRBreakNum then
      for i = 1, SSRBreakNum do
        UILuaHelper.SetActive(self["m_img_break_SSR" .. i], i <= breakNum)
      end
    end
    if breakNum > SSRBreakNum then
      local maxNum = self.m_heroBreak - SSRBreakNum
      for i = 1, maxNum do
        if not utils.isNull(self["m_pnl_break_light" .. i]) then
          UILuaHelper.SetActive(self["m_pnl_break_light" .. i], i <= breakNum - SSRBreakNum)
        end
      end
    else
      UILuaHelper.SetActive(self.m_img_break_SSR4, false)
    end
  end
end

function Form_HeroCheck:FreshSkinBtnStatus()
  local isFashionBtnShow = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HeroFashion)
  UILuaHelper.SetActive(self.m_btn_skin, isFashionBtnShow == true)
end

function Form_HeroCheck:FreshShowHeroInfo()
  if not self.m_heroCfg then
    return
  end
  local heroCfg = self.m_heroCfg
  local heroName = heroCfg.m_mName
  self.m_txt_hero_name_Text.text = heroName
  self.m_txt_hero_nike_name_Text.text = heroCfg.m_mTitle
  local quality = heroCfg.m_Quality
  UILuaHelper.SetAtlasSprite(self.m_img_hero_ssr_Image, QualityPathCfg[quality].ssrImgPath)
  UILuaHelper.SetActive(self.m_ssr_lz, quality == HeroManager.QualityType.SSR)
  UILuaHelper.SetActive(self.m_sr_lz, quality == HeroManager.QualityType.SR)
  UILuaHelper.SetActive(self.m_r_lz, quality == HeroManager.QualityType.R)
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
  if not careerCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_career_Image, careerCfg.m_CareerIcon)
  end
  self:ShowHeroSpine(heroCfg.m_Spine)
end

function Form_HeroCheck:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HeroCheck:ShowHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.HeroDetail
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack()
  end)
end

function Form_HeroCheck:OnLoadSpineBack()
  if not self.m_curHeroSpineObj then
    return
  end
  local spineObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spineObj, true)
  self:CheckShowSpineEnterAnim()
end

function Form_HeroCheck:CheckShowSpineEnterAnim()
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpine = self.m_curHeroSpineObj.spineObj
  if not heroSpine then
    return
  end
  UILuaHelper.SpineResetInit(heroSpine)
  if heroSpine:GetComponent("SpineSkeletonPosControl") then
    heroSpine:GetComponent("SpineSkeletonPosControl"):OnResetInit()
  end
  UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, "chuchang2", false, false, function()
    if not UILuaHelper.IsNull(heroSpine) then
      UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, "idle", true, false)
    end
  end)
end

function Form_HeroCheck:InitShowAttr()
  local propertyAllCfg = PropertyIndexIns:GetAll()
  for _, tempCfg in pairs(propertyAllCfg) do
    if AttrBaseShowCfg[tempCfg.m_PropertyID] == true then
      self.m_showAttrBaseCfgList[tempCfg.m_PropertyID] = tempCfg
    end
  end
  for _, v in ipairs(self.m_showAttrBaseCfgList) do
    local attrItemRoot = GameObject.Instantiate(self.m_attributes_item_base, self.m_attr_base_root_trans).transform
    UILuaHelper.SetActive(attrItemRoot, true)
    local attrNumText = attrItemRoot:Find("c_txt_num"):GetComponent(T_TextMeshProUGUI)
    local attrIconImg = attrItemRoot:Find("c_icon"):GetComponent(T_Image)
    local attrNameText = attrItemRoot:Find("c_txt_sx_name"):GetComponent(T_TextMeshProUGUI)
    local attrItem = {
      itemRoot = attrItemRoot,
      attrNumText = attrNumText,
      attrIconImg = attrIconImg,
      attrNameText = attrNameText,
      propertyCfg = v
    }
    attrNameText.text = v.m_mCNName
    UILuaHelper.SetAtlasSprite(attrIconImg, v.m_PropertyIcon .. "_02")
    self.m_showAttrBaseItems[#self.m_showAttrBaseItems + 1] = attrItem
  end
end

function Form_HeroCheck:GetHeroLevelMax()
  if not self.m_heroCfg then
    return
  end
  local heroCheckBreakNum = self.m_heroBreak
  local breakQuality = self.m_heroCfg.m_Quality
  local limitBreakCfg = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplateAndLimitBreakLevel(breakQuality, heroCheckBreakNum)
  if limitBreakCfg:GetError() then
    return
  end
  return limitBreakCfg.m_MaxLevel
end

function Form_HeroCheck:GetHeroCheckBreakNum()
  if not self.m_heroCfg then
    return
  end
  local heroBreak = 0
  local limitBreakQuality = self.m_heroCfg.m_Quality
  if limitBreakQuality == nil or limitBreakQuality == 0 then
    return heroBreak
  end
  local breakLevelList = {}
  local allCharacterLimitBreaks = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplate(limitBreakQuality)
  for _, breakCfg in pairs(allCharacterLimitBreaks) do
    breakLevelList[#breakLevelList + 1] = {
      breakCfg.m_LimitBreakLevel,
      breakCfg.m_MaxLevel
    }
  end
  
  local function sortFun(a1, a2)
    return a1[1] > a2[1]
  end
  
  table.sort(breakLevelList, sortFun)
  if self.m_heroCfg.m_Quality == HeroManager.QualityType.SSR then
    local level = breakLevelList[1][2]
    local curBreak = 0
    for i, v in ipairs(breakLevelList) do
      if v[2] == level and curBreak < v[1] then
        curBreak = v[1]
      end
    end
    heroBreak = curBreak
  elseif self.m_heroCfg.m_Quality == HeroManager.QualityType.SR then
    heroBreak = breakLevelList[1][1]
  else
    heroBreak = breakLevelList[1][1]
  end
  return heroBreak
end

function Form_HeroCheck:FreshShowHeroBaseInfo()
  local heroLvMax = self:GetHeroLevelMax()
  self:FreshLvNum(self.m_heroMaxLevelNum, heroLvMax)
  self:FreshHeroStar(StarMaxNum)
  local heroSkillGroupID = self.m_heroCfg.m_SkillGroupID[0]
  self:FreshShowSkillInfo(heroSkillGroupID)
  self:FreshStarInfo()
  self:FreshShowHeroPower()
  self:FreshCamp(self.m_heroCfg.m_Camp)
  self:FreshShowHeroBaseAttr()
  self:FreshChangeSkillStarPanel(self.m_isShowSkillPanel)
  self:FreshMoonType()
  self:FreshDamageType(self.m_heroCfg.m_MainAttribute)
end

function Form_HeroCheck:FreshMoonType()
  UILuaHelper.SetActive(self.m_btn_moon, true)
  UILuaHelper.SetActive(self.m_icon_moon1, self.m_heroCfg.m_MoonType == 1)
  UILuaHelper.SetActive(self.m_icon_moon2, self.m_heroCfg.m_MoonType == 2)
  UILuaHelper.SetActive(self.m_icon_moon3, self.m_heroCfg.m_MoonType == 3)
end

function Form_HeroCheck:FreshLvNum(lvNum, maxLv)
  if not lvNum then
    return
  end
  self.m_txt_lv_num_Text.text = lvNum
  self.m_txt_lv_max_Text.text = "/" .. maxLv or 0
end

function Form_HeroCheck:FreshHeroStar(starNum)
  if not starNum then
    return
  end
  UILuaHelper.SetActiveChildren(self.m_stargroup, true)
  for i = 1, StarMaxNum do
    local starNode = self["m_img_star0" .. i]
  end
end

function Form_HeroCheck:FreshShowHeroBaseAttr()
  if not self.m_showAttrBaseItems then
    return
  end
  local heroAttrTab = self.m_heroAttrList
  for _, attrItem in ipairs(self.m_showAttrBaseItems) do
    local attr = heroAttrTab[attrItem.propertyCfg.m_ENName] or 0
    if not heroAttrTab[attrItem.propertyCfg.m_ENName] then
      attr = heroAttrTab["i" .. attrItem.propertyCfg.m_ENName] or 0
    end
    local afterAttrStr = BigNumFormat(attr)
    attrItem.attrNumText.text = afterAttrStr
  end
end

function Form_HeroCheck:FreshCamp(heroCamp)
  if not heroCamp then
    return
  end
  local campCfg = CampCfgIns:GetValue_ByCampID(heroCamp)
  if campCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_camp_Image, campCfg.m_CampIcon)
end

function Form_HeroCheck:FreshShowSkillInfo(skillGroupID)
  if not skillGroupID then
    return
  end
  local skillGroupCfgList = HeroManager:GetSkillGroupCfgList(skillGroupID)
  local OverMaxSkillTag = #HeroManager.HeroSkillTagSort + 1
  table.sort(skillGroupCfgList, function(a, b)
    local skillTagA = a.m_SkillShowType
    local skillTagB = b.m_SkillShowType
    local skillSortA = HeroManager.HeroSkillTagSort[skillTagA] or OverMaxSkillTag
    local skillSortB = HeroManager.HeroSkillTagSort[skillTagB] or OverMaxSkillTag
    return skillSortA < skillSortB
  end)
  local skillCfgList = {}
  for _, skillGroupCfg in ipairs(skillGroupCfgList) do
    local skillID = skillGroupCfg.m_SkillID
    if skillID then
      local tempSkillCfg = HeroManager:GetSkillConfigById(skillID)
      skillCfgList[#skillCfgList + 1] = tempSkillCfg
    end
  end
  self.m_skillCfgList = skillCfgList
  self.m_skillGroupId = skillGroupID
  for i = 1, SkillNum do
    local skillCfg = skillCfgList[i]
    if skillCfg then
      self["m_btn_skill0" .. i]:SetActive(true)
      UILuaHelper.SetAtlasSprite(self[String_format("m_icon_kill0%d_Image", i)], skillCfg.m_Skillicon)
      local skillLv = self:GetHeroSKillLv(skillCfg.m_SkillID)
      self["m_txt_skill_lv_num0" .. i .. "_Text"].text = skillLv
    else
      self["m_btn_skill0" .. i]:SetActive(false)
    end
  end
end

function Form_HeroCheck:GetHeroSKillLv(skillID)
  local skillLv = 1
  if self.m_heroServerData then
    for id, lv in pairs(self.m_heroServerData.mSkill) do
      if id == skillID then
        skillLv = lv
      end
    end
  else
    skillLv = self.m_showHeroMaxLv and HeroManager:GetHeroSkillMaxLvById(self.m_heroCfg.m_HeroID, skillID) or 1
  end
  return skillLv
end

function Form_HeroCheck:GetLocalHeroSKills(skillGroupID)
  local skillTab = {}
  local skillGroupCfgList = HeroManager:GetSkillGroupCfgList(skillGroupID)
  if skillGroupCfgList then
    for _, skillGroupCfg in ipairs(skillGroupCfgList) do
      local skillID = skillGroupCfg.m_SkillID
      if skillID then
        local skillLv = self:GetHeroSKillLv(skillID)
        skillTab[skillID] = skillLv
      end
    end
  end
  return skillTab
end

function Form_HeroCheck:FreshStarInfo()
  local heroCfg = self.m_heroCfg
  for i = 2, StarMaxNum do
    UILuaHelper.SetActive(self["m_skill_star" .. i], true)
    local paramStr = String_format("m_mLv%dDescription", i)
    self[String_format("m_txt_star_content%d_Text", i)].text = heroCfg[paramStr]
  end
end

function Form_HeroCheck:FreshShowHeroPower()
  if not self.m_heroCfg then
    return
  end
  local breakNum = self.m_heroBreak or 0
  local power = self.m_serverPower
  power = power or BigNumFormat(self.m_heroAttr:GetHeroPower(self.m_curHeroID, self.m_heroMaxLevelNum, breakNum, self.m_heroSkillList))
  self.m_txt_power_value_Text.text = power
end

function Form_HeroCheck:FreshChangeSkillStarPanel(isShowSkillPanel)
  self.m_isShowSkillPanel = isShowSkillPanel
  UILuaHelper.SetActive(self.m_pnl_skill, self.m_isShowSkillPanel)
  UILuaHelper.SetActive(self.m_attr_base_root, self.m_isShowSkillPanel)
  UILuaHelper.SetActive(self.m_pnl_star, not self.m_isShowSkillPanel)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_star)
end

function Form_HeroCheck:ShowSkillStarChangePanelAnim(isShowSkillPanel, backFun)
  UILuaHelper.SetActive(self.m_pnl_skill, true)
  UILuaHelper.SetActive(self.m_attr_base_root, true)
  UILuaHelper.SetActive(self.m_pnl_star, true)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_star)
  local animStr = isShowSkillPanel and StarOutAnimStr or StarInAnimStr
  if self.m_startInAnimTimer then
    TimeService:KillTimer(self.m_startInAnimTimer)
    self.m_startInAnimTimer = nil
  end
  UILuaHelper.PlayAnimationByName(self.m_hero_panel_base_info, animStr)
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_hero_panel_base_info, animStr)
  self.m_startInAnimTimer = TimeService:SetTimer(animLen, 1, function()
    if backFun then
      backFun()
    end
  end)
end

function Form_HeroCheck:OnBackClk()
  self:CheckRecycleSpine(true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
  if self.m_closeCallBackFun then
    self.m_closeCallBackFun()
  end
end

function Form_HeroCheck:OnBackHome()
  self:CheckRecycleSpine(true)
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackPopup:PopAll()
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_HeroCheck:OnBtnCareerClicked()
  if not self.m_heroCfg then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HEROCAREERDETAIL, {
    heroCfg = self.m_heroCfg
  })
end

function Form_HeroCheck:OnBtncampClicked()
  if not self.m_heroCfg then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HEROCAMPDETAIL, {
    heroCfg = self.m_heroCfg
  })
end

function Form_HeroCheck:OnBtnequipClicked()
  if not self.m_heroCfg then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL, {
    heroCfg = self.m_heroCfg
  })
end

function Form_HeroCheck:OnBtnskill01Clicked()
  self:ClickOneSkillItem(1)
end

function Form_HeroCheck:OnBtnskill02Clicked()
  self:ClickOneSkillItem(2)
end

function Form_HeroCheck:OnBtnskill03Clicked()
  self:ClickOneSkillItem(3)
end

function Form_HeroCheck:OnBtnskill04Clicked()
  self:ClickOneSkillItem(4)
end

function Form_HeroCheck:ClickOneSkillItem(index)
  if self.m_skillCfgList and self["m_btn_skill0" .. index] and self.m_skillGroupId then
    local cfg = self.m_skillCfgList[index]
    local skillId = cfg.m_SkillID
    local skillLv = self:GetHeroSKillLv(skillId)
    utils.openSkillTips(skillId, self.m_skillGroupId, self.m_curHeroID, self["m_btn_skill0" .. index].transform, {x = 0.5, y = 1}, nil, skillLv)
  end
end

function Form_HeroCheck:OnBtnstarClicked()
  self:ShowSkillStarChangePanelAnim(false, function()
    self:FreshChangeSkillStarPanel(false)
  end)
end

function Form_HeroCheck:OnBtnSkillClicked()
  self:ShowSkillStarChangePanelAnim(true, function()
    self:FreshChangeSkillStarPanel(true)
  end)
end

function Form_HeroCheck:OnBtnmoreClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROABILITYDETAIL, {
    heroAttrList = self.m_heroAttrList
  })
end

function Form_HeroCheck:OnBtnSkillFilterClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROSKILLPREVIEW, {
    hero_cfg_id = self.m_curHeroID,
    skill_list = self.m_heroSkillList
  })
end

function Form_HeroCheck:OnBtnHeroPreviewClicked()
  if not self.m_heroCfg then
    return
  end
  local fashion = HeroManager:GetHeroFashion()
  if fashion then
    local cfg = fashion:GetFashionInfoByHeroIDAndFashionID(self.m_heroCfg.m_HeroID, 0)
    StackFlow:Push(UIDefines.ID_FORM_HEROPREVIEW, {
      fashionId = cfg.m_FashionID,
      backFun = function()
        self:OnHeroPreviewBack()
      end
    })
  end
end

function Form_HeroCheck:OnHeroPreviewBack()
  self:FreshShowHeroInfo()
end

function Form_HeroCheck:OnBtnmoonClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL, {
    heroCfg = self.m_heroCfg,
    isMoonType = true
  })
end

function Form_HeroCheck:OnBtnCareerDetailClicked()
  if not self.m_heroCfg then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HEROCAREERDETAIL, {
    heroCfg = self.m_heroCfg
  })
end

function Form_HeroCheck:OnBtndamagetypeClicked()
  if not self.m_heroCfg then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HERODAMAGETYPEDETAIL, {
    heroCfg = self.m_heroCfg
  })
end

function Form_HeroCheck:OnBtnskinClicked()
  if not self.m_heroCfg then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_FASHION, {
    heroID = self.m_heroCfg.m_HeroID
  })
end

function Form_HeroCheck:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroID = tParam.heroID
  vPackage[#vPackage + 1] = {
    sName = tostring(heroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_HeroCheck", Form_HeroCheck)
return Form_HeroCheck
