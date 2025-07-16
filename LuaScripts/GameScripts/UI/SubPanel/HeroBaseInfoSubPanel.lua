local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroBaseInfoSubPanel = class("HeroBaseInfoSubPanel", UISubPanelBase)
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
local CharacterTagIns = ConfigManager:GetConfigInsByName("CharacterTag")
local CharacterDamageTypeIns = ConfigManager:GetConfigInsByName("CharacterDamageType")
local SkillNum = 4
local String_format = string.format
local CharacterTagNum = 4
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local EnterAnimStr = "herodetail_panel_base_in"
local OutAnimStr = "herodetail_panel_base_out"
local RBreakNum = HeroManager.RBreakNum
local SRBreakNum = HeroManager.SRBreakNum
local SSRBreakNum = HeroManager.SSRBreakNum

function HeroBaseInfoSubPanel:OnInit()
  self.m_curShowHeroData = nil
  self.m_allHeroList = nil
  self.m_curChooseHeroIndex = nil
  self.m_showAttrBaseCfgList = {}
  self.m_attr_base_root_trans = self.m_attr_base_root.transform
  self.m_showAttrBaseItems = {}
  if self.m_initData then
    self.m_baseChangeClkBack = self.m_initData.backFun
  end
  self.m_outAnimTimer = nil
  self:InitShowAttr()
  self:addEventListener("eGameEvent_Hero_SetLove", handler(self, self.FreshFavourite))
end

function HeroBaseInfoSubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.heroData
  self.m_allHeroList = self.m_panelData.allHeroList
  self.m_curChooseHeroIndex = self.m_panelData.chooseIndex
  local serverData = self.m_curShowHeroData.serverData
  local heroCfg = self.m_curShowHeroData.characterCfg
  self.m_skillCfgList = nil
  self.m_skillGroupId = nil
  self.m_heroBreakCfgList = nil
  self.m_maxBreakNum = nil
  self.m_curHeroBreakNum = nil
  self:FreshLevelUpData()
  self:FreshBreakStatus()
  local heroLvMax = self:GetHeroLvMax() or 0
  self:FreshLvNum(serverData.iLevel, heroLvMax)
  self:FreshHeroBreak(serverData.iBreak or 0, heroCfg.m_Quality)
  local heroSkillGroupID = heroCfg.m_SkillGroupID[0]
  self:FreshShowSkillInfo(heroSkillGroupID)
  self:FreshCamp(heroCfg.m_Camp)
  self:FreshFavourite(serverData.bLove, true)
  self:FreshAttrAndCareer()
  self:FreshShowHeroBaseAttr()
  self:FreshUpgradeBtnShow(serverData.iLevel, heroCfg.m_Quality)
  self:BindRedDot(heroCfg)
  self:RefreshInheritUI()
  self:FreshHeroQuality(heroCfg.m_Quality)
  self:FreshHeroName(heroCfg.m_mName, heroCfg.m_mTitle)
  self:ResetAnimIn()
  self:ShowHeroTag()
  self:FreshMoonType(heroCfg.m_MoonType)
  self:FreshDamageType(heroCfg.m_MainAttribute)
  ResourceUtil:CreateEquipTypeImg(self.m_icon_equip_Image, heroCfg.m_Equiptype)
end

function HeroBaseInfoSubPanel:OnDestroy()
  HeroBaseInfoSubPanel.super.OnDestroy(self)
  if self.m_outAnimTimer then
    TimeService:KillTimer(self.m_outAnimTimer)
    self.m_outAnimTimer = nil
  end
  if self.m_skillTimer then
    TimeService:KillTimer(self.m_skillTimer)
    self.m_skillTimer = nil
  end
  self:clearEventListener()
end

function HeroBaseInfoSubPanel:InitShowAttr()
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

function HeroBaseInfoSubPanel:RefreshInheritUI()
  local resetFlag = InheritManager:CheckCanResetLvById(self.m_curShowHeroData.serverData.iHeroId)
  self.m_bg_tongbu:SetActive(resetFlag)
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.LevelReset)
  if not openFlag then
    self.m_btn_reset:SetActive(false)
  else
    self.m_btn_reset:SetActive(not resetFlag)
  end
  if resetFlag then
    UILuaHelper.SetColor(self.m_txt_lv_num_Text, 217, 145, 0, 1)
  else
    UILuaHelper.SetColor(self.m_txt_lv_num_Text, 255, 255, 255, 1)
  end
end

function HeroBaseInfoSubPanel:IsCanBreak()
  local isBelowBreakNum = false
  local maxBreakNum = self.m_maxBreakNum
  if maxBreakNum > self.m_curHeroBreakNum then
    isBelowBreakNum = true
  end
  return isBelowBreakNum
end

function HeroBaseInfoSubPanel:FreshLevelUpData()
  if not self.m_curShowHeroData then
    return
  end
  self.m_heroBreakCfgList = {}
  self.m_maxBreakNum = 0
  self.m_curHeroBreakNum = self.m_curShowHeroData.serverData.iBreak or 0
  local limitBreakTemplateID = self.m_curShowHeroData.characterCfg.m_Quality
  if limitBreakTemplateID == nil or limitBreakTemplateID == 0 then
    return
  end
  local allCharacterLimitBreaks = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplate(limitBreakTemplateID)
  for _, breakCfg in pairs(allCharacterLimitBreaks) do
    self.m_heroBreakCfgList[breakCfg.m_LimitBreakLevel] = breakCfg
    if breakCfg.m_LimitBreakLevel > self.m_maxBreakNum then
      self.m_maxBreakNum = breakCfg.m_LimitBreakLevel
    end
  end
end

function HeroBaseInfoSubPanel:GetHeroLvMax()
  if not self.m_curShowHeroData then
    return
  end
  local breakNum = self.m_curHeroBreakNum
  local curBreakCfg = self.m_heroBreakCfgList[breakNum]
  if not curBreakCfg then
    return
  end
  return curBreakCfg.m_MaxLevel or 0
end

function HeroBaseInfoSubPanel:FreshBreakStatus()
  local isCanBreak = self:IsCanBreak()
  UILuaHelper.SetActive(self.m_bg_break_normal, isCanBreak)
  UILuaHelper.SetActive(self.m_bg_break_grey, not isCanBreak)
end

function HeroBaseInfoSubPanel:FreshLvNum(lvNum, maxLv)
  if not lvNum then
    return
  end
  self.m_txt_lv_num_Text.text = lvNum
  self.m_txt_lv_max_Text.text = "/" .. maxLv or 0
end

function HeroBaseInfoSubPanel:FreshHeroBreak(breakNum, quality)
  if not breakNum then
    return
  end
  if not quality then
    return
  end
  if quality == HeroManager.QualityType.R then
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, false)
    UILuaHelper.SetActive(self.m_img_break_SSR4, false)
  elseif quality == HeroManager.QualityType.SR then
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, true)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, false)
    UILuaHelper.SetActive(self.m_img_break_SSR4, false)
    for i = 1, HeroManager.SRBreakNum do
      UILuaHelper.SetActive(self["m_img_break_SR" .. i], i <= breakNum)
    end
  else
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, breakNum <= SSRBreakNum)
    UILuaHelper.SetActive(self.m_img_break_SSR4, breakNum > SSRBreakNum)
    if breakNum <= SSRBreakNum then
      for i = 1, HeroManager.SSRBreakNum do
        UILuaHelper.SetActive(self["m_img_break_SSR" .. i], i <= breakNum)
      end
    end
    if breakNum > SSRBreakNum then
      local maxNum = self.m_maxBreakNum - SSRBreakNum
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

function HeroBaseInfoSubPanel:FreshHeroQuality(quality)
  if not quality then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_hero_ssr_Image, QualityPathCfg[quality].ssrImgPath)
  UILuaHelper.SetActive(self.m_ssr_lz, quality == HeroManager.QualityType.SSR)
  UILuaHelper.SetActive(self.m_sr_lz, quality == HeroManager.QualityType.SR)
  UILuaHelper.SetActive(self.m_r_lz, quality == HeroManager.QualityType.R)
end

function HeroBaseInfoSubPanel:FreshHeroName(name, shortName)
  if name then
    self.m_txt_hero_name_Text.text = name
  end
  if shortName then
    self.m_txt_hero_nike_name_Text.text = shortName
  end
end

function HeroBaseInfoSubPanel:FreshShowHeroBaseAttr()
  if not self.m_showAttrBaseItems then
    return
  end
  local serverData = self.m_curShowHeroData.serverData
  local heroAttr = serverData.mHeroAttr[HeroManager.TotalServerAttrIndex] or {}
  for _, attrItem in ipairs(self.m_showAttrBaseItems) do
    local serverAttrValue = heroAttr["i" .. attrItem.propertyCfg.m_ENName] or 0
    attrItem.attrNumText.text = BigNumFormat(serverAttrValue)
  end
end

function HeroBaseInfoSubPanel:FreshCamp(heroCamp)
  if not heroCamp then
    return
  end
  local campCfg = CampCfgIns:GetValue_ByCampID(heroCamp)
  if campCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_camp_Image, campCfg.m_CampIcon)
end

function HeroBaseInfoSubPanel:FreshDamageType(heroAttribute)
  if not heroAttribute then
    return
  end
  local damageCfg = CharacterDamageTypeIns:GetValue_ByDamageType(heroAttribute)
  if damageCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_damagetype_Image, damageCfg.m_DamageTypeIcon)
end

function HeroBaseInfoSubPanel:FreshFavourite(bLove, bFirst)
  self.m_img_attract_active:SetActive(bLove)
  self.m_img_attract_unactive:SetActive(not bLove)
  self.m_UIFX_attract:SetActive(bLove)
  if bLove and not bFirst then
    self.m_UIFX_attract:GetComponent("ParticleSystem"):Play()
  end
end

function HeroBaseInfoSubPanel:FreshAttrAndCareer()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
  if not careerCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_career_Image, careerCfg.m_CareerIcon)
  end
end

function HeroBaseInfoSubPanel:FreshMoonType(moonType)
  UILuaHelper.SetActive(self.m_btn_moon, true)
  UILuaHelper.SetActive(self.m_icon_moon1, moonType == 1)
  UILuaHelper.SetActive(self.m_icon_moon2, moonType == 2)
  UILuaHelper.SetActive(self.m_icon_moon3, moonType == 3)
end

function HeroBaseInfoSubPanel:ShowHeroTag()
  local tagList = utils.changeCSArrayToLuaTable(self.m_curShowHeroData.characterCfg.m_CharacterTag)
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

function HeroBaseInfoSubPanel:FreshShowSkillInfo(skillGroupID)
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
      local skillLv = HeroManager:GetHeroSkillLvById(self.m_curShowHeroData.characterCfg.m_HeroID, skillCfg.m_SkillID)
      local maxSkillLv = HeroManager:GetSkillMaxLevelById(skillGroupID, skillCfg.m_SkillID)
      self["m_img_skill_rectangle0" .. i]:SetActive(maxSkillLv ~= 1)
      self["m_txt_skill_lv_num0" .. i .. "_Text"].text = tostring(skillLv)
    else
      self["m_btn_skill0" .. i]:SetActive(false)
    end
  end
  self:FreshSkillResetUI()
end

function HeroBaseInfoSubPanel:FreshUpgradeBtnShow(lv, heroQuality)
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.CharacterLevel)
  local isShow = true
  if not openFlag then
    isShow = false
  end
  local qualityMaxBreakNum = HeroManager.RBreakNum
  if heroQuality == HeroManager.QualityType.R then
    qualityMaxBreakNum = HeroManager.RBreakNum
  elseif heroQuality == HeroManager.QualityType.SR then
    qualityMaxBreakNum = HeroManager.SRBreakNum
  elseif heroQuality == HeroManager.QualityType.SSR then
    qualityMaxBreakNum = HeroManager.SSRBreakNum
  end
  if qualityMaxBreakNum <= self.m_curHeroBreakNum then
    local curBreakMaxNum = self:GetHeroLvMax()
    if lv and curBreakMaxNum and lv >= curBreakMaxNum then
      isShow = false
    end
  end
  local resetFlag = InheritManager:CheckCanResetLvById(self.m_curShowHeroData.serverData.iHeroId)
  if resetFlag then
    isShow = false
  end
  UILuaHelper.SetActive(self.m_btn_upgrade, isShow)
end

function HeroBaseInfoSubPanel:FreshSkillResetUI()
  local isOpen, cutDownTime = HeroManager:CheckHeroSkillResetActivityIsOpen()
  local isEnough = HeroManager:CheckSkillResetIsEnough()
  self.m_pnl_skillreset:SetActive(isOpen and isEnough)
  if isOpen and isEnough then
    local timeStr = TimeUtil:SecondToTimeText(cutDownTime)
    self.m_txt_time_Text.text = timeStr
    self.m_txt_time_grey_Text.text = timeStr
    local skillLvUp = HeroManager:CheckHeroSkillLvUp(self.m_curShowHeroData.characterCfg.m_HeroID)
    self.m_btn_skillreset:SetActive(skillLvUp)
    self.m_btn_skillreset_grey:SetActive(not skillLvUp)
  end
end

function HeroBaseInfoSubPanel:ShowEnterInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.SetCanvasGroupAlpha(self.m_rootObj, 0)
  TimeService:SetTimer(0.2, 1, function()
    UILuaHelper.SetCanvasGroupAlpha(self.m_rootObj, 1)
    UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterAnimStr)
  end)
end

function HeroBaseInfoSubPanel:ShowTabInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterAnimStr)
end

function HeroBaseInfoSubPanel:ShowOutAnim(backFun)
  if not self.m_rootObj then
    return
  end
  if self.m_outAnimTimer then
    return
  end
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_rootObj, OutAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_rootObj, OutAnimStr)
  if self.m_outAnimTimer then
    TimeService:KillTimer(self.m_outAnimTimer)
    self.m_outAnimTimer = nil
  end
  self.m_outAnimTimer = TimeService:SetTimer(animLen, 1, function()
    if backFun then
      backFun()
    end
    self.m_outAnimTimer = nil
  end)
end

function HeroBaseInfoSubPanel:ResetAnimIn()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.ResetAnimationByName(self.m_rootObj, EnterAnimStr, -1)
end

function HeroBaseInfoSubPanel:BindRedDot(heroCfg)
  if not heroCfg then
    return
  end
  local heroID = heroCfg.m_HeroID
  self:RegisterOrUpdateRedDotItem(self.m_img_redDot, RedDotDefine.ModuleType.HeroLevelUp, heroID)
  self:RegisterOrUpdateRedDotItem(self.m_hero_break_red_point, RedDotDefine.ModuleType.HeroBreak, heroID)
  local camp = heroCfg.m_Camp
  local campCirculationID = HeroManager:GetCirculationIDByType(HeroManager.CirculationType.Camp, camp)
  self:RegisterOrUpdateRedDotItem(self.m_hero_camp_red_point, RedDotDefine.ModuleType.HeroCirculationUp, campCirculationID)
  local equipType = heroCfg.m_Equiptype
  local equipCirculationID = HeroManager:GetCirculationIDByType(HeroManager.CirculationType.Equip, equipType)
  self:RegisterOrUpdateRedDotItem(self.m_hero_equip_red_point, RedDotDefine.ModuleType.HeroCirculationUp, equipCirculationID)
end

function HeroBaseInfoSubPanel:OnBtnattractClicked()
  local serverData = self.m_curShowHeroData.serverData
  if serverData.bLove == false then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40050)
  end
  HeroManager:ReqHeroSetLove(serverData.iHeroId, not serverData.bLove)
end

function HeroBaseInfoSubPanel:OnBtnupgradeClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.CharacterLevel)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  self:broadcastEvent("eGameEvent_Hero_EnterUpgrade", {
    heroDataList = self.m_allHeroList,
    chooseHeroIndex = self.m_curChooseHeroIndex
  })
end

function HeroBaseInfoSubPanel:OnBtnmoreClicked()
  local serverData = self.m_curShowHeroData.serverData
  local heroAttr = serverData.mHeroAttr[HeroManager.TotalServerAttrIndex] or {}
  StackFlow:Push(UIDefines.ID_FORM_HEROABILITYDETAIL, {heroAttrList = heroAttr})
end

function HeroBaseInfoSubPanel:OnBtnskill01Clicked()
  self:ClickOneSkillItem(1)
end

function HeroBaseInfoSubPanel:OnBtnskill02Clicked()
  self:ClickOneSkillItem(2)
end

function HeroBaseInfoSubPanel:OnBtnskill03Clicked()
  self:ClickOneSkillItem(3)
end

function HeroBaseInfoSubPanel:OnBtnskill04Clicked()
  self:ClickOneSkillItem(4)
end

function HeroBaseInfoSubPanel:ClickOneSkillItem(index)
  if self.m_skillTimer then
    TimeService:KillTimer(self.m_skillTimer)
    self.m_skillTimer = nil
  end
  self.m_skillTimer = TimeService:SetTimer(0.03, 1, function()
    self.m_skillTimer = nil
    if self.m_skillCfgList and self["m_btn_skill0" .. index] and self.m_skillGroupId then
      local cfg = self.m_skillCfgList[index]
      local skillId = cfg.m_SkillID
      utils.openSkillTips(skillId, self.m_skillGroupId, self.m_curShowHeroData.characterCfg.m_HeroID, self["m_btn_skill0" .. index].transform, {x = 0.5, y = 1})
    end
  end)
end

function HeroBaseInfoSubPanel:OnBtnresetClicked()
  if self.m_curShowHeroData.serverData.iLevel > 1 then
    local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.LevelReset)
    if not openFlag then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
      return
    end
    StackPopup:Push(UIDefines.ID_FORM_POPUPLEVELRESET, {
      heroData = self.m_curShowHeroData
    })
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20034)
  end
end

function HeroBaseInfoSubPanel:OnBtncampClicked()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Circulation)
  if isOpen ~= true then
    StackFlow:Push(UIDefines.ID_FORM_HEROCAMPDETAIL, {heroCfg = heroCfg})
  else
    local camp = heroCfg.m_Camp
    local campCirculationID = HeroManager:GetCirculationIDByType(HeroManager.CirculationType.Camp, camp)
    StackFlow:Push(UIDefines.ID_FORM_CIRCULATIONPOP, {circulationID = campCirculationID, isNeedBackCirculation = true})
  end
end

function HeroBaseInfoSubPanel:OnBtnequipClicked()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Circulation)
  if isOpen ~= true then
    StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL, {heroCfg = heroCfg})
  else
    local equipType = heroCfg.m_Equiptype
    local equipCirculationID = HeroManager:GetCirculationIDByType(HeroManager.CirculationType.Equip, equipType)
    StackFlow:Push(UIDefines.ID_FORM_CIRCULATIONPOP, {circulationID = equipCirculationID, isNeedBackCirculation = true})
  end
end

function HeroBaseInfoSubPanel:OnBtnCareerDetailClicked()
  if not self.m_curShowHeroData then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HEROCAREERDETAIL, {
    heroCfg = self.m_curShowHeroData.characterCfg
  })
end

function HeroBaseInfoSubPanel:OnBtnmoonClicked()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL, {heroCfg = heroCfg, isMoonType = true})
end

function HeroBaseInfoSubPanel:OnBtndamagetypeClicked()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  StackPopup:Push(UIDefines.ID_FORM_HERODAMAGETYPEDETAIL, {heroCfg = heroCfg})
end

function HeroBaseInfoSubPanel:OnBtnBreakClicked()
  local isCanBreak = self:IsCanBreak()
  if not isCanBreak then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13009)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HEROBREAKTHROUGHPOP, {
    heroDataList = self.m_allHeroList,
    chooseHeroIndex = self.m_curChooseHeroIndex
  })
end

function HeroBaseInfoSubPanel:OnBgtongbuClicked()
  utils.popUpDirectionsUI({
    tipsID = 1219,
    func1 = function()
      QuickOpenFuncUtil:OpenFunc(12)
    end
  })
end

function HeroBaseInfoSubPanel:OnBtnSkillFilterClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROSKILLPREVIEW, {
    hero_cfg_id = self.m_curShowHeroData.characterCfg.m_HeroID
  })
end

function HeroBaseInfoSubPanel:OnBtnPreviewClicked()
  if not self.m_curShowHeroData then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_HEROPREVIEW, {
    heroID = self.m_curShowHeroData.characterCfg.m_HeroID
  })
end

function HeroBaseInfoSubPanel:OnBtnskillresetgreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13019)
end

function HeroBaseInfoSubPanel:OnBtnskillresetClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROSKILLRESET, {
    heroId = self.m_curShowHeroData.characterCfg.m_HeroID
  })
end

return HeroBaseInfoSubPanel
