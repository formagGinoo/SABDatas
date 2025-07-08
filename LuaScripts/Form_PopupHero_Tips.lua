local Form_PopupHero_Tips = class("Form_PopupHero_Tips", require("UI/UIFrames/Form_PopupHero_TipsUI"))
local InGamePresentationIns = ConfigManager:GetConfigInsByName("Presentation")
local SkillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
local InGameSkillInstance = ConfigManager:GetConfigInsByName("Skill")
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local BondIns = ConfigManager:GetConfigInsByName("Bond")
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local MaxHeroBond = 3
local SkillNum = 4
local MaxStarNum = 3
local String_format = string.format
local DefaultLvNum = 1
local DefaultBreakNum = 0

function Form_PopupHero_Tips:SetInitParam(param)
end

function Form_PopupHero_Tips:AfterInit()
  self.super.AfterInit(self)
  self.m_attr_base_root_trans = self.m_attr_base_root.transform
  self.m_showAttrBaseCfgList = {}
  self.m_showAttrBaseItems = {}
  self:InitShowAttr()
  self.m_skillCfgList = nil
  self.m_skillGroupId = nil
  self.m_isHeroInfoShowNormal = true
  self.m_heroAttr = HeroManager:GetHeroAttr()
end

function Form_PopupHero_Tips:OnActive()
  self.super.OnActive(self)
  self:FreshUI()
end

function Form_PopupHero_Tips:OnInactive()
  self.super.OnInactive(self)
end

function Form_PopupHero_Tips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PopupHero_Tips:FreshUI()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  local heroID = tParam.heroID
  if not heroID then
    return
  end
  self.m_curHeroID = heroID
  local heroData = HeroManager:GetHeroDataByID(heroID)
  if not heroData then
    self.m_isHave = false
    self.m_heroCfg = CharacterInfoIns:GetValue_ByHeroID(heroID)
  else
    self.m_isHave = true
    self.m_heroCfg = heroData.characterCfg
    self.m_heroData = heroData
  end
  local heroName = self.m_heroCfg.m_mName
  self.m_txt_hero_name_Text.text = heroName
  self:FreshShowHeroLv()
  self:FreshHeroPower()
  self:FreshShowHeroBaseAttr()
  self:FreshHeadIcon(self.m_heroCfg.m_PerformanceID[0])
  local heroSkillGroupID = self.m_heroCfg.m_SkillGroupID[0]
  self:FreshShowSkillInfo(heroSkillGroupID)
  self:FreshStarContent(self.m_heroCfg)
  self:FreshHeroLabel(self.m_heroCfg)
  local isHeroInfoShowNormal = true
  self:FreshNormalStarShow(isHeroInfoShowNormal)
  self:FreshHeroBondInfos(self.m_heroCfg)
end

function Form_PopupHero_Tips:FreshShowHeroLv()
  local lvNum = DefaultLvNum
  if self.m_isHave then
    lvNum = self.m_heroData.serverData.iLevel
  end
  self.m_txt_lv_num_Text.text = lvNum
end

function Form_PopupHero_Tips:FreshHeroPower()
  local powerNum
  if self.m_isHave then
    powerNum = BigNumFormat(self.m_heroData.serverData.iPower)
  else
    powerNum = BigNumFormat(self.m_heroAttr:GetHeroPower(self.m_curHeroID, DefaultLvNum, DefaultBreakNum))
  end
  self.m_txt_power_num_Text.text = powerNum
end

function Form_PopupHero_Tips:InitShowAttr()
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

function Form_PopupHero_Tips:FreshShowHeroBaseAttr()
  if not self.m_showAttrBaseItems then
    return
  end
  if self.m_isHave then
    local heroData = self.m_heroData
    local serverData = heroData.serverData
    local heroAttr = serverData.mHeroAttr[HeroManager.TotalServerAttrIndex] or {}
    for _, attrItem in ipairs(self.m_showAttrBaseItems) do
      local serverAttrValue = heroAttr["i" .. attrItem.propertyCfg.m_ENName] or 0
      attrItem.attrNumText.text = BigNumFormat(serverAttrValue)
    end
  else
    local heroID = self.m_heroCfg.m_HeroID
    local heroAttrTab = self.m_heroAttr:GetLvBreakBaseAttr(heroID, DefaultLvNum, DefaultBreakNum)
    for _, attrItem in ipairs(self.m_showAttrBaseItems) do
      local afterAttrStr = BigNumFormat(heroAttrTab[attrItem.propertyCfg.m_ENName] or 0)
      attrItem.attrNumText.text = afterAttrStr
    end
  end
end

function Form_PopupHero_Tips:FreshHeadIcon(performanceIDLv)
  if not performanceIDLv then
    return
  end
  local presentationData = InGamePresentationIns:GetValue_ByPerformanceID(performanceIDLv)
  if presentationData:GetError() then
    return
  end
  local szIcon = presentationData.m_UIkeyword .. "001"
  UILuaHelper.SetAtlasSprite(self.m_img_head_Image, szIcon)
end

function Form_PopupHero_Tips:FreshShowSkillInfo(skillGroupID)
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
      local skillLv = HeroManager:GetHeroSkillLvById(self.m_heroCfg.m_HeroID, skillID)
      local tempSkillCfg = HeroManager:GetSkillConfigById(skillID)
      skillCfgList[#skillCfgList + 1] = tempSkillCfg
      if self["m_skill_lv_num" .. #skillCfgList .. "_Text"] then
        self["m_skill_lv_num" .. #skillCfgList .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(20033), tostring(skillLv))
      end
    end
  end
  for i = 1, SkillNum do
    local skillCfg = skillCfgList[i]
    if skillCfg then
      self["m_btn_hero_skill" .. i]:SetActive(true)
      if skillCfg.m_Skillicon then
        UILuaHelper.SetAtlasSprite(self[String_format("m_img_hero_skill%d_Image", i)], skillCfg.m_Skillicon)
      end
    else
      self["m_btn_hero_skill" .. i]:SetActive(false)
    end
  end
  self.m_skillCfgList = skillCfgList
  self.m_skillGroupId = skillGroupID
end

function Form_PopupHero_Tips:FreshStarContent(heroCfg)
  for i = 2, MaxStarNum do
    local paramStr = String_format("m_mLv%dDescription", i)
    self[String_format("m_txt_star_content%d_Text", i)].text = heroCfg[paramStr]
  end
end

function Form_PopupHero_Tips:FreshHeroLabel(heroCfg)
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
  if not careerCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_icon_career_Image, careerCfg.m_CareerIcon)
  end
end

function Form_PopupHero_Tips:FreshNormalStarShow(isShowNormal)
  if isShowNormal then
    UILuaHelper.SetColor(self.m_z_txt_normal, 248, 219, 188)
    UILuaHelper.SetColor(self.m_z_txt_star, 81, 79, 78)
    UILuaHelper.SetActive(self.m_chose_normal_bg, true)
    UILuaHelper.SetActive(self.m_choose_star_bg, false)
  else
    UILuaHelper.SetColor(self.m_z_txt_normal, 81, 79, 78)
    UILuaHelper.SetColor(self.m_z_txt_star, 248, 219, 188)
    UILuaHelper.SetActive(self.m_chose_normal_bg, false)
    UILuaHelper.SetActive(self.m_choose_star_bg, true)
  end
  UILuaHelper.SetActive(self.m_hero_normal_panel, isShowNormal)
  UILuaHelper.SetActive(self.m_hero_star_panel, not isShowNormal)
  self.m_isHeroInfoShowNormal = isShowNormal
end

function Form_PopupHero_Tips:FreshHeroBondInfos(heroCfg)
  if not heroCfg then
    return
  end
  local bondCfgList = {}
  local bonds = heroCfg.m_Bond
  if bonds and bonds.Length > 0 then
    for i = 0, bonds.Length - 1 do
      local bondID = bonds[i]
      local bondCfg = BondIns:GetValue_ByID(bondID)
      if not bondCfg:GetError() then
        bondCfgList[#bondCfgList + 1] = bondCfg
      end
    end
  end
  for i = 1, MaxHeroBond do
    local heroBondCfg = bondCfgList[i]
    if heroBondCfg then
      UILuaHelper.SetActive(self["m_img_icon_bond" .. i], true)
      UILuaHelper.SetAtlasSprite(self[String_format("m_img_icon_bond%d_Image", i)], heroBondCfg.m_Icon .. "_1")
    else
      UILuaHelper.SetActive(self["m_img_icon_bond" .. i], false)
    end
  end
end

function Form_PopupHero_Tips:OnBtnheroskill1Clicked()
  self:OpenSkillTips(1)
end

function Form_PopupHero_Tips:OnBtnheroskill2Clicked()
  self:OpenSkillTips(2)
end

function Form_PopupHero_Tips:OnBtnheroskill3Clicked()
  self:OpenSkillTips(3)
end

function Form_PopupHero_Tips:OnBtnheroskill4Clicked()
  self:OpenSkillTips(4)
end

function Form_PopupHero_Tips:OpenSkillTips(index)
  if self.m_skillCfgList and self["m_btn_hero_skill" .. index] and self.m_skillGroupId then
    local cfg = self.m_skillCfgList[index]
    local skillId = cfg.m_SkillID
    utils.openSkillTips(skillId, self.m_skillGroupId, self.m_heroCfg.m_HeroID, self["m_btn_hero_skill" .. index].transform, {x = 0.5, y = 1})
  end
end

function Form_PopupHero_Tips:OnBtnNormalClicked()
  self:FreshNormalStarShow(true)
end

function Form_PopupHero_Tips:OnBtnStarClicked()
  self:FreshNormalStarShow(false)
end

function Form_PopupHero_Tips:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_PopupHero_Tips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PopupHero_Tips", Form_PopupHero_Tips)
return Form_PopupHero_Tips
