local Form_TeamHeroList = class("Form_TeamHeroList", require("UI/UIFrames/Form_TeamHeroListUI"))
local HeroManager = _ENV.HeroManager
local DefaultChooseType = 1
local DefaultTeamPlot = 1
local FormTypeMaxNum = 6
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local HeroSortCfg = _ENV.HeroSortCfg
local DefaultChooseFilterIndex = 1
local String_format = string.format
local Table_insert = table.insert
local ipairs = _ENV.ipairs
local Table_remove = table.remove
local table_sort = table.sort
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local CharacterDamageTypeIns = ConfigManager:GetConfigInsByName("CharacterDamageType")
local SkillNum = 4

function Form_TeamHeroList:SetInitParam(param)
end

function Form_TeamHeroList:AfterInit()
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1154)
  self.m_cacheHeroIconWidget = {}
  local initGridData = {
    itemClkBackFun = handler(self, self.OnHeroItemClick)
  }
  self.m_luaHeroListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_hero_list_InfinityGrid, "Team/UITeamHeroListItem", initGridData)
  local goFilterBtnRoot = self.m_rootTrans:Find("content_node/pnl_right/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  self.m_heroSort = HeroManager:GetHeroSort()
  self.m_curChooseFormType = DefaultChooseType
  self.m_allFormTeams = nil
  self.m_curChooseHeroID = nil
  self.m_curSeverFormTeamData = nil
  self.m_allHeroList = nil
  self.m_curFilterIndex = nil
  self.m_bFilterDown = nil
  self.m_showHeroList = nil
  self.m_showAttrBaseItems = {}
  self.m_curChooseHeroDataList = nil
  self.m_heroTeamIconList = {}
  self.m_showAttrBaseCfgList = {}
  self.m_attr_prefab_helper = self.m_attr_base_root:GetComponent("PrefabHelper")
  self.m_attr_prefab_helper:RegisterCallback(handler(self, self.OnInitAttrItem))
  self:InitShowAttr()
  self.m_img_bk2:SetActive(false)
end

function Form_TeamHeroList:OnActive()
  self.m_filterData = {}
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_TeamHeroList:OnInactive()
  self:ClearData()
  self:RemoveAllEventListeners()
end

function Form_TeamHeroList:Init(gameObject, csui)
  self:InitClicks()
  self.super.Init(self, gameObject, csui)
end

function Form_TeamHeroList:InitClicks()
  for i = 1, FormTypeMaxNum do
    local clickFunName = String_format("OnBtnteam0%dClicked", i)
    self[clickFunName] = function()
      self:OnTeamClk(i)
    end
  end
end

function Form_TeamHeroList:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_SetForm", handler(self, self.OnEventSetForm))
end

function Form_TeamHeroList:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_TeamHeroList:OnEventSetForm(param)
  if not param then
    return
  end
  if self.m_isClearTeam == true then
    self.m_isClearTeam = false
    self:FreshOneFromTeamData(param.formType, param.formData)
    self:FreshServerTeamData()
    return
  end
  local formType = param.formType
  if formType == self.m_curChooseFormType then
    self:CloseForm()
  end
end

function Form_TeamHeroList:ClearData()
  if self.m_cacheHeroIconWidget then
    self.m_cacheHeroIconWidget = {}
  end
end

function Form_TeamHeroList:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  local formType = tParam.formType
  local teamPlot = tParam.teamPlot
  if not formType then
    return
  end
  if not teamPlot or teamPlot > FormPlotMaxNum then
    return
  end
  self:FreshAllFormTeamData()
  self.m_paramFormType = formType
  self.m_paramTeamPlot = teamPlot
  self.m_allHeroList = HeroManager:GetHeroList() or {}
end

function Form_TeamHeroList:FreshAllFormTeamData()
  local allFormDic = HeroManager:GetPresetDic() or {}
  local allFormTeams = {}
  for k, v in pairs(allFormDic) do
    local serverFormData = v
    local heroIDList = serverFormData.vHeroId
    local heroDataList = {}
    for _, heroID in ipairs(heroIDList) do
      if v then
        heroDataList[#heroDataList + 1] = HeroManager:GetHeroDataByID(heroID)
      end
    end
    local formData = {serverFormData = v, heroDataList = heroDataList}
    allFormTeams[k] = formData
  end
  self.m_allFormTeams = allFormTeams
end

function Form_TeamHeroList:FreshServerTeamData()
  if not self.m_curChooseFormType then
    return
  end
  local formTeamData = self.m_allFormTeams[self.m_curChooseFormType] or {}
  local curFormTeamData = formTeamData.serverFormData or {}
  self.m_curSeverFormTeamData = curFormTeamData
end

function Form_TeamHeroList:FreshOneFromTeamData(formType, formData)
  if not formType then
    return
  end
  if not formData then
    return
  end
  if not self.m_allFormTeams then
    return
  end
  local heroIDList = formData.vHeroId
  local heroDataList = {}
  for _, heroID in ipairs(heroIDList) do
    heroDataList[#heroDataList + 1] = HeroManager:GetHeroDataByID(heroID)
  end
  local tempFormData = {serverFormData = formData, heroDataList = heroDataList}
  self.m_allFormTeams[formType] = tempFormData
end

function Form_TeamHeroList:GetChooseHeroIndex(heroID)
  if not heroID then
    return
  end
  for i, v in ipairs(self.m_curChooseHeroDataList) do
    if v.characterCfg.m_HeroID == heroID then
      return i
    end
  end
end

function Form_TeamHeroList:GetAllShowHeroIndex(heroID)
  if not heroID then
    return
  end
  for i, v in ipairs(self.m_allShowHeroList) do
    if v.serverData.iHeroId == heroID then
      return i
    end
  end
end

function Form_TeamHeroList:FreshSortHero()
  local heroSort = HeroManager:GetHeroSort()
  heroSort:SortHeroList(self.m_allShowHeroList, self.m_curFilterIndex, self.m_bFilterDown)
  for index = #self.m_curChooseHeroDataList, 1, -1 do
    local heroData = self.m_curChooseHeroDataList[index]
    for i, v in ipairs(self.m_allShowHeroList) do
      if v.serverData.iHeroId == heroData.serverData.iHeroId then
        local tempHeroData = self.m_allShowHeroList[i]
        Table_remove(self.m_allShowHeroList, i)
        Table_insert(self.m_allShowHeroList, 1, tempHeroData)
      end
    end
  end
end

function Form_TeamHeroList:IsChooseHeroSameServer()
  local tempSeverFormData = self.m_curSeverFormTeamData or {}
  local heroIDList = tempSeverFormData.vHeroId or {}
  local curChooseLen = #self.m_curChooseHeroDataList
  local serverHeroLen = #heroIDList
  if curChooseLen ~= serverHeroLen then
    return false
  end
  for _, chooseHeroData in ipairs(self.m_curChooseHeroDataList) do
    local isHaveSame = false
    for _, serverHeroID in ipairs(heroIDList) do
      if chooseHeroData.serverData.iHeroId == serverHeroID then
        isHaveSame = true
        break
      end
    end
    if not isHaveSame then
      return false
    end
  end
  return true
end

function Form_TeamHeroList:IsSameHeroWithServerHero(heroList)
  local tempSeverFormData = self.m_curSeverFormTeamData or {}
  local heroIDList = tempSeverFormData.vHeroId or {}
  local tempHeroLen = #heroList
  local serverHeroLen = #heroIDList
  if tempHeroLen ~= serverHeroLen then
    return false
  end
  for _, tempHeroData in ipairs(heroList) do
    local isHaveSame = false
    for _, serverHeroID in ipairs(heroIDList) do
      if tempHeroData.serverData.iHeroId == serverHeroID then
        isHaveSame = true
        break
      end
    end
    if not isHaveSame then
      return false
    end
  end
  return true
end

function Form_TeamHeroList:GetBattleTopHeroList()
  local heroList = self.m_allShowHeroList
  if heroList and next(heroList) then
    table_sort(heroList, function(a, b)
      return a.serverData.iPower > b.serverData.iPower
    end)
  end
  local heroIDList = {}
  for i, v in ipairs(heroList) do
    if i <= FormPlotMaxNum then
      heroIDList[#heroIDList + 1] = v
    end
  end
  return heroIDList
end

function Form_TeamHeroList:IsSameHeroTeamWithChooseHero(heroList)
  if not heroList then
    return
  end
  if not next(self.m_curChooseHeroDataList) then
    return false
  end
  local curHeroDataList = self.m_curChooseHeroDataList
  local curChooseLen = #curHeroDataList
  local heroLen = #heroList
  if curChooseLen ~= heroLen then
    return false
  end
  for heroIndex, chooseHeroID in ipairs(heroList) do
    local tempHeroData = curHeroDataList[heroIndex]
    if tempHeroData == nil or tempHeroData.serverData == nil or tempHeroData.serverData.iHeroId ~= chooseHeroID then
      return false
    end
  end
  return true
end

function Form_TeamHeroList:GetChooseHeroIDList()
  if not self.m_curChooseHeroDataList then
    return {}
  end
  local heroIDList = {}
  for i, heroData in ipairs(self.m_curChooseHeroDataList) do
    if heroData then
      heroIDList[#heroIDList + 1] = heroData.serverData.iHeroId
    end
  end
  return heroIDList
end

function Form_TeamHeroList:InitShowAttr()
  local propertyAllCfg = PropertyIndexIns:GetAll()
  for _, tempCfg in pairs(propertyAllCfg) do
    if AttrBaseShowCfg[tempCfg.m_PropertyID] == true then
      self.m_showAttrBaseCfgList[tempCfg.m_PropertyID] = tempCfg
    end
  end
  self.m_attr_prefab_helper:CheckAndCreateObjs(#self.m_showAttrBaseCfgList)
end

function Form_TeamHeroList:FreshUI()
  if not self.m_curFilterIndex then
    self.m_curFilterIndex = DefaultChooseFilterIndex
  end
  self.m_widgetBtnFilter:RefreshTabConfig(HeroSortCfg, self.m_curFilterIndex, self.m_bFilterDown, handler(self, self.OnHeroSortChanged))
  local chooseType = self.m_paramFormType
  chooseType = chooseType or DefaultChooseType
  self:FreshTeamChangeUI(chooseType)
  UILuaHelper.SetActive(self.m_filter_select, false)
end

function Form_TeamHeroList:FreshLeftUI()
  if not self.curSelectHero or not self.curSelectHero.is_cur_hero then
    self.m_ui_hero_panel_base_info:SetActive(false)
    self.m_ui_common_empty:SetActive(true)
    return
  end
  self.m_img_bk2:SetActive(false)
  self.m_img_bk2:SetActive(true)
  self.m_heroAttrList = self.curSelectHero.serverData.mHeroAttr[0] or {}
  self.m_ui_hero_panel_base_info:SetActive(true)
  self.m_ui_common_empty:SetActive(false)
  local heroCfg = self.curSelectHero.characterCfg
  self.m_txt_hero_nike_name_Text.text = heroCfg.m_mTitle
  self.m_txt_hero_name_Text.text = heroCfg.m_mName
  self:FreshCamp(heroCfg.m_Camp)
  self:FreshMoonType(heroCfg.m_MoonType)
  self:FreshDamageType(heroCfg.m_MainAttribute)
  ResourceUtil:CreateEquipTypeImg(self.m_icon_equip_Image, heroCfg.m_Equiptype)
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
  if not careerCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_career_Image, careerCfg.m_CareerIcon)
  end
  self.m_txt_powernum02_Text.text = self.curSelectHero.serverData.iPower
  self:FreshShowHeroBaseAttr()
  local heroSkillGroupID = heroCfg.m_SkillGroupID[0]
  self:FreshShowSkillInfo(heroSkillGroupID)
end

function Form_TeamHeroList:FreshHeroPower()
  local power = 0
  for i, v in ipairs(self.m_curChooseHeroDataList) do
    power = power + v.serverData.iPower
  end
  self.m_txt_powernum_Text.text = power
end

function Form_TeamHeroList:FreshShowSkillInfo(skillGroupID)
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

function Form_TeamHeroList:ClickOneSkillItem(index)
  if self.m_skillCfgList and self["m_btn_skill0" .. index] and self.m_skillGroupId then
    local cfg = self.m_skillCfgList[index]
    local skillId = cfg.m_SkillID
    local skillLv = self:GetHeroSKillLv(skillId)
    utils.openSkillTips(skillId, self.m_skillGroupId, self.curSelectHero.characterCfg.m_HeroID, self["m_btn_skill0" .. index].transform, {x = 0.5, y = 1}, nil, skillLv)
  end
end

function Form_TeamHeroList:GetHeroSKillLv(skillID)
  local skillLv = 1
  if self.curSelectHero.serverData then
    for id, lv in pairs(self.curSelectHero.serverData.mSkill) do
      if id == skillID then
        skillLv = lv
      end
    end
  else
    skillLv = HeroManager:GetHeroSkillMaxLvById(self.curSelectHero.characterCfg.m_HeroID, skillID) or 1
  end
  return skillLv
end

function Form_TeamHeroList:OnInitAttrItem(go, index)
  local cfg = self.m_showAttrBaseCfgList[index + 1]
  local attrItemRoot = go.transform
  local attrNumText = attrItemRoot:Find("c_txt_num"):GetComponent(T_TextMeshProUGUI)
  local attrIconImg = attrItemRoot:Find("c_icon"):GetComponent(T_Image)
  local attrNameText = attrItemRoot:Find("c_txt_sx_name"):GetComponent(T_TextMeshProUGUI)
  local attrItem = {
    itemRoot = attrItemRoot,
    attrNumText = attrNumText,
    attrIconImg = attrIconImg,
    attrNameText = attrNameText,
    propertyCfg = cfg
  }
  attrNameText.text = cfg.m_mCNName
  UILuaHelper.SetAtlasSprite(attrIconImg, cfg.m_PropertyIcon .. "_02")
  self.m_showAttrBaseItems[#self.m_showAttrBaseItems + 1] = attrItem
end

function Form_TeamHeroList:FreshShowHeroBaseAttr()
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

function Form_TeamHeroList:FreshCamp(heroCamp)
  if not heroCamp then
    return
  end
  local campCfg = CampCfgIns:GetValue_ByCampID(heroCamp)
  if campCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_camp_Image, campCfg.m_CampIcon)
end

function Form_TeamHeroList:FreshMoonType(heroMoonType)
  if not heroMoonType then
    return
  end
  UILuaHelper.SetActive(self.m_icon_moon1, heroMoonType == 1)
  UILuaHelper.SetActive(self.m_icon_moon2, heroMoonType == 2)
  UILuaHelper.SetActive(self.m_icon_moon3, heroMoonType == 3)
end

function Form_TeamHeroList:FreshDamageType(heroAttribute)
  if not heroAttribute then
    return
  end
  local damageCfg = CharacterDamageTypeIns:GetValue_ByDamageType(heroAttribute)
  if damageCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_damagetype_Image, damageCfg.m_DamageTypeIcon)
end

function Form_TeamHeroList:OnBtndamagetypeClicked()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.curSelectHero.characterCfg
  StackPopup:Push(UIDefines.ID_FORM_HERODAMAGETYPEDETAIL, {heroCfg = heroCfg})
end

function Form_TeamHeroList:FreshFormTeamUI()
  if not self.m_curChooseFormType then
    return
  end
  local curFormTeamData = self.m_allFormTeams[self.m_curChooseFormType] or {}
  self.m_curSeverFormTeamData = curFormTeamData.serverFormData or {}
  self.m_curChooseHeroDataList = curFormTeamData.heroDataList or {}
  self:FreshServerTeamData()
  self:FreshHeroIconMask(false)
  local teamPlot = self.m_paramTeamPlot or DefaultTeamPlot
  self.m_paramTeamPlot = nil
  local chooseHeroData = self.m_curChooseHeroDataList[teamPlot]
  local heroID
  if chooseHeroData then
    local tempServerData = chooseHeroData.serverData or {}
    heroID = tempServerData.iHeroId
  end
  self.m_curChooseHeroID = heroID
  if self.m_curFilterIndex == nil then
    self.m_bFilterDown = false
    self.m_curFilterIndex = self.m_curFilterIndex or DefaultChooseFilterIndex
  end
  self:OnFilterChanged()
end

function Form_TeamHeroList:FreshHeroIconMask(isActive)
  if not self.m_heroTeamIconList then
    return
  end
  for _, heroTeamIcon in ipairs(self.m_heroTeamIconList) do
    heroTeamIcon:SetHeroSelectMaskActive(isActive)
  end
end

function Form_TeamHeroList:FreshHeroList()
  self.m_luaHeroListInfinityGrid:ShowItemList(self.m_allShowHeroList)
end

function Form_TeamHeroList:OnHeroItemClick(index, go)
  local itemIndex = index + 1
  local chooseHeroData = self.m_allShowHeroList[itemIndex]
  if not chooseHeroData then
    return
  end
  local tempChooseHeroID = chooseHeroData.serverData.iHeroId
  local tempChooseIndex = self:GetChooseHeroIndex(tempChooseHeroID)
  local trueIdentity = chooseHeroData.characterCfg.m_TrueIdentity
  local is_have = false
  for _, v in ipairs(self.m_curChooseHeroDataList) do
    local cfg = v.characterCfg
    if trueIdentity and trueIdentity ~= 0 and trueIdentity == cfg.m_TrueIdentity then
      is_have = cfg
      break
    end
  end
  if is_have and not tempChooseIndex then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(21008))
    return
  end
  if self.curSelectHero then
    self.curSelectHero.is_cur_hero = false
  end
  chooseHeroData.is_cur_hero = true
  self.curSelectHero = chooseHeroData
  if tempChooseIndex == nil then
    self.m_curChooseHeroID = tempChooseHeroID
    local isFull = #self.m_curChooseHeroDataList >= FormPlotMaxNum
    if isFull then
    else
      Table_insert(self.m_curChooseHeroDataList, chooseHeroData)
      chooseHeroData.is_TeamSelected = true
    end
  else
    Table_remove(self.m_curChooseHeroDataList, tempChooseIndex)
    chooseHeroData.is_TeamSelected = false
    if tempChooseHeroID == self.m_curChooseHeroID then
      self.m_curChooseHeroID = nil
      chooseHeroData.is_cur_hero = not chooseHeroData.is_cur_hero
    end
  end
  self.m_luaHeroListInfinityGrid:ReBindAll()
  self:FreshLeftUI()
  self:FreshHeroPower()
end

function Form_TeamHeroList:OnTeamClk(formType)
  if formType == self.m_curChooseFormType then
    return
  end
  if self:IsChooseHeroSameServer() == true then
    self:FreshTeamChangeUI(formType)
  else
    utils.CheckAndPushCommonTips({
      tipsID = 1001,
      func1 = function()
        self:FreshTeamChangeUI(formType)
      end
    })
  end
end

function Form_TeamHeroList:FreshTeamChangeUI(formType)
  local lastFormType = self.m_curChooseFormType
  if lastFormType then
    local lastChooseNode = self["m_team_choose" .. lastFormType]
    if lastChooseNode then
      UILuaHelper.SetActive(lastChooseNode, false)
      UILuaHelper.SetColor(self["m_z_txt_team_name0" .. lastFormType], 121, 121, 121, 1)
    end
  end
  self.m_curChooseFormType = formType
  local curChooseNode = self["m_team_choose" .. formType]
  if curChooseNode then
    UILuaHelper.SetActive(curChooseNode, true)
    UILuaHelper.SetColor(self["m_z_txt_team_name0" .. formType], 255, 255, 255, 1)
  end
  self:FreshFormTeamUI()
end

function Form_TeamHeroList:OnBackClk()
  if self:IsChooseHeroSameServer() == true then
    self:CloseForm()
  else
    utils.CheckAndPushCommonTips({
      tipsID = 1001,
      func1 = function()
        CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
        self:CloseForm()
      end
    })
  end
end

function Form_TeamHeroList:OnHeroSortChanged(iIndex, bDown)
  self.m_curFilterIndex = iIndex
  self.m_bFilterDown = bDown
  self:FreshSortHero()
  self:FreshHeroList()
end

function Form_TeamHeroList:OnFilterChanged()
  self.m_allShowHeroList = self.m_heroSort:FilterHeroList(self.m_allHeroList, self.m_filterData)
  local temp = {}
  for index, value in ipairs(self.m_curChooseHeroDataList) do
    local is_have = false
    for _, v in ipairs(self.m_allShowHeroList) do
      if value.serverData.iHeroId == v.serverData.iHeroId then
        is_have = true
        break
      end
    end
    if not is_have then
      table.insert(temp, value)
    end
  end
  for index, value in ipairs(temp) do
    table.insert(self.m_allShowHeroList, 1, value)
  end
  for i, v in ipairs(self.m_allShowHeroList) do
    v.is_cur_hero = self.m_curChooseHeroID == v.serverData.iHeroId
    if v.is_cur_hero then
      self.curSelectHero = v
    end
    v.is_TeamSelected = false
    for index = #self.m_curChooseHeroDataList, 1, -1 do
      local heroData = self.m_curChooseHeroDataList[index]
      if v.serverData.iHeroId == heroData.serverData.iHeroId then
        v.is_TeamSelected = v.serverData.iHeroId == heroData.serverData.iHeroId
        break
      end
    end
  end
  self:OnHeroSortChanged(self.m_curFilterIndex, self.m_bFilterDown)
  self:FreshLeftUI()
  self:FreshHeroPower()
end

function Form_TeamHeroList:OnBtnbianduiClicked()
  local isSameServer = self:IsChooseHeroSameServer()
  if isSameServer then
    self:CloseForm()
    return
  end
  local chooseHeroIDList = {}
  for _, heroData in ipairs(self.m_curChooseHeroDataList) do
    chooseHeroIDList[#chooseHeroIDList + 1] = heroData.serverData.iHeroId
  end
  HeroManager:ReqSetPreset(self.m_curChooseFormType, chooseHeroIDList)
end

function Form_TeamHeroList:OnBtnemptyClicked()
  local curChooseHeroLen = #self.m_curChooseHeroDataList
  if curChooseHeroLen == 0 then
    return
  end
  self.m_curChooseHeroDataList = {}
  self.m_curChooseHeroID = nil
  self:FreshHeroList()
end

function Form_TeamHeroList:OnBtnFilterClicked()
  local function chooseBackFun(filterData)
    if self.curSelectHero then
      self.curSelectHero.is_cur_hero = false
      
      self.curSelectHero = nil
    end
    self.m_curChooseHeroID = nil
    self.m_filterData = filterData
    self:OnFilterChanged()
    UILuaHelper.SetActive(self.m_filter_select, false)
    if self.m_filterData then
      for _, value in pairs(self.m_filterData) do
        if value ~= 0 then
          UILuaHelper.SetActive(self.m_filter_select, true)
          break
        end
      end
    end
  end
  
  utils.openForm_filter(self.m_filterData, self.m_btn_Filter.transform, {x = 1, y = 1}, {x = 35, y = -40}, chooseBackFun, false)
end

function Form_TeamHeroList:OnBtncampClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROCAMPDETAIL, {
    heroCfg = self.curSelectHero.characterCfg
  })
end

function Form_TeamHeroList:OnBtnequipClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL, {
    heroCfg = self.curSelectHero.characterCfg
  })
end

function Form_TeamHeroList:OnBtnCareerDetailClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROCAREERDETAIL, {
    heroCfg = self.curSelectHero.characterCfg
  })
end

function Form_TeamHeroList:OnBtnmoonClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL, {
    heroCfg = self.curSelectHero.characterCfg,
    isMoonType = true
  })
end

function Form_TeamHeroList:OnBtndamagetypeClicked()
  if not self.curSelectHero.characterCfg then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HERODAMAGETYPEDETAIL, {
    heroCfg = self.curSelectHero.characterCfg
  })
end

function Form_TeamHeroList:GetBattleTopHeroIDList()
  local heroList = table.clone(self.m_allShowHeroList)
  if heroList and next(heroList) then
    table_sort(heroList, function(a, b)
      return a.serverData.iPower > b.serverData.iPower
    end)
  end
  local heroIDList = {}
  for i, v in ipairs(heroList) do
    if i <= FormPlotMaxNum then
      heroIDList[#heroIDList + 1] = v.serverData.iHeroId
    end
  end
  return heroIDList
end

function Form_TeamHeroList:OnBtnskill01Clicked()
  self:ClickOneSkillItem(1)
end

function Form_TeamHeroList:OnBtnskill02Clicked()
  self:ClickOneSkillItem(2)
end

function Form_TeamHeroList:OnBtnskill03Clicked()
  self:ClickOneSkillItem(3)
end

function Form_TeamHeroList:OnBtnskill04Clicked()
  self:ClickOneSkillItem(4)
end

function Form_TeamHeroList:OnBtnmoreClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROABILITYDETAIL, {
    heroAttrList = self.m_heroAttrList
  })
end

function Form_TeamHeroList:OnBtnSkillFilterClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROSKILLPREVIEW, {
    hero_cfg_id = self.curSelectHero.characterCfg.m_HeroID
  })
end

function Form_TeamHeroList:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_TeamHeroList", Form_TeamHeroList)
return Form_TeamHeroList
