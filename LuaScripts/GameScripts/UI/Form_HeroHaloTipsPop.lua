local Form_HeroHaloTipsPop = class("Form_HeroHaloTipsPop", require("UI/UIFrames/Form_HeroHaloTipsPopUI"))

function Form_HeroHaloTipsPop:SetInitParam(param)
end

function Form_HeroHaloTipsPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_HeroHaloTipsPop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.haloCamp = tParam.haloCamp
  self.m_formationIds = tParam.formationIds
  self.activeLevel = tParam.activeLevel
  if self.haloCamp.Length == 0 then
    return
  end
  self:InitView()
end

function Form_HeroHaloTipsPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_HeroHaloTipsPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroHaloTipsPop:InitView()
  local linkCharacterData = CS.CData_LinkCharacterInfo.GetInstance():GetValue_ByLinkID(self.haloCamp[0])
  local ownerHeroId = linkCharacterData.m_HeroID
  self:initHeroView(self.m_link_owner, ownerHeroId, true)
  if self.linkHeroGos == nil then
    self.linkHeroGos = {}
    table.insert(self.linkHeroGos, self.m_link_hero)
  end
  local linkHeroIds = linkCharacterData.m_LinkHeroID
  local heroGoCount = #self.linkHeroGos
  for i = heroGoCount, linkHeroIds.Length - 1 do
    local heroObj = GameObject.Instantiate(self.linkHeroGos[1], self.linkHeroGos[1].transform.parent).gameObject
    table.insert(self.linkHeroGos, heroObj)
  end
  for i = 1, #self.linkHeroGos do
    self.linkHeroGos[i]:SetActive(false)
  end
  for i = 0, linkHeroIds.Length - 1 do
    local linkId = linkHeroIds[i]
    self:initHeroView(self.linkHeroGos[i + 1], linkId, false)
  end
  local activeClolorOne = 0
  local activeClolorTwo = 0
  if self.activeLevel == -1 then
    activeClolorOne = 1
    activeClolorTwo = 1
  elseif self.activeLevel == 0 then
    activeClolorOne = 0
    activeClolorTwo = 0
  elseif self.activeLevel == 1 then
    activeClolorOne = 1
    activeClolorTwo = 0
  elseif self.activeLevel == 2 then
    activeClolorOne = 0
    activeClolorTwo = 1
  end
  self.m_csui.m_uiGameObject.transform:Find("m_pnl_halo/Viewport/content/pnl_item/c_pnl_title/c_img_bg_tips1"):GetComponent("MultiColorChange"):SetColorByIndex(activeClolorOne)
  self.m_csui.m_uiGameObject.transform:Find("m_pnl_halo/Viewport/content/pnl_item/c_pnl_title/c_img_bg_tips1/c_img_bg_tips2"):GetComponent("MultiColorChange"):SetColorByIndex(activeClolorOne)
  self.m_csui.m_uiGameObject.transform:Find("m_pnl_halo/Viewport/content/pnl_item/c_pnl_title/c_img_bg_tips1/c_img_bg_tips2/c_txt_tips1"):GetComponent("MultiColorChange"):SetColorByIndex(activeClolorOne)
  self.m_txt_link2Des_Text.transform:GetComponent("MultiColorChange"):SetColorByIndex(activeClolorOne)
  self.m_txt_link2Des_Text.text = self:GetLinkDes(linkCharacterData.m_mLink2Des, linkCharacterData.m_BuffParam)
  self.m_csui.m_uiGameObject.transform:Find("m_pnl_halo/Viewport/content/pnl_item/c_pnl_title/c_img_bg_tips1/c_img_bg_tips2/c_txt_tips1"):GetComponent("TextMeshProUGUI").text = string.CS_Format(ConfigManager:GetClientMessageTextById(58010), linkCharacterData.m_mLink2Limit)
  self.m_csui.m_uiGameObject.transform:Find("m_pnl_halo/Viewport/content/pnl_item/c_pnl_title/c_img_bg_tips2"):GetComponent("MultiColorChange"):SetColorByIndex(activeClolorTwo)
  self.m_csui.m_uiGameObject.transform:Find("m_pnl_halo/Viewport/content/pnl_item/c_pnl_title/c_img_bg_tips2/c_img_bg_tips3"):GetComponent("MultiColorChange"):SetColorByIndex(activeClolorTwo)
  self.m_csui.m_uiGameObject.transform:Find("m_pnl_halo/Viewport/content/pnl_item/c_pnl_title/c_img_bg_tips2/c_img_bg_tips3/c_txt_tips3"):GetComponent("MultiColorChange"):SetColorByIndex(activeClolorTwo)
  self.m_txt_link3Des_Text.transform:GetComponent("MultiColorChange"):SetColorByIndex(activeClolorTwo)
  self.m_txt_link3Des_Text.text = self:GetLinkDes(linkCharacterData.m_mLink3Des, linkCharacterData.m_BuffParam)
  self.m_csui.m_uiGameObject.transform:Find("m_pnl_halo/Viewport/content/pnl_item/c_pnl_title/c_img_bg_tips2/c_img_bg_tips3/c_txt_tips3"):GetComponent("TextMeshProUGUI").text = string.CS_Format(ConfigManager:GetClientMessageTextById(58010), linkCharacterData.m_mLink3Limit)
  self.m_csui.m_uiGameObject.transform:Find("ui_common_frame_middle/img_txt_bg/txt_frame_middle_title"):GetComponent("TextMeshProUGUI").text = linkCharacterData.m_mName
end

function Form_HeroHaloTipsPop:initHeroView(heroObj, heroID, isOwner)
  if heroObj == nil then
    return
  end
  heroObj.transform:Find("c_bg_prohibit").gameObject:SetActive(false)
  heroObj:SetActive(true)
  local heroData = HeroManager:GetHeroDataByID(heroID)
  local iBreak = 0
  local fashionInfo
  local hasHero = false
  if heroData then
    iBreak = heroData.serverData.iBreak
    fashionInfo = HeroManager:GetHeroFashion():GetFashionInfoByHeroIDAndFashionID(heroData.serverData.iHeroId, heroData.serverData.iFashion)
    hasHero = true
  end
  heroObj.transform:Find("c_no_obtain").gameObject:SetActive(false)
  heroObj.transform:Find("c_battle_card/c_txt_lv_num").gameObject:SetActive(false)
  local characterInfoCfg = ConfigManager:GetConfigInsByName("CharacterInfo")
  local characterCfg = characterInfoCfg:GetValue_ByHeroID(heroID)
  if not characterCfg:GetError() then
    local performanceID
    if fashionInfo then
      performanceID = fashionInfo.m_PerformanceID[0]
    else
      performanceID = characterCfg.m_PerformanceID[0]
    end
    local presentationData = CS.CData_Presentation.GetInstance():GetValue_ByPerformanceID(performanceID)
    local m_imgHead = heroObj.transform:Find("c_battle_card/pnl_head_mask/c_img_head"):GetComponent(T_Image)
    local szIcon = presentationData.m_UIkeyword .. "001"
    UILuaHelper.SetAtlasSprite(m_imgHead, szIcon)
    self.m_moonParent = heroObj.transform:Find("pnl_icon/c_bg_moon")
    if utils.isNull(self.m_moonParent) then
      self.m_moonParent = heroObj.transform:Find("c_bg_moon")
    end
    if not utils.isNull(self.m_moonParent) then
      self.m_moonParent.gameObject:SetActive(true)
      self.m_moonParent:Find("c_icon_moon1").gameObject:SetActive(characterCfg.m_MoonType == 1)
      self.m_moonParent:Find("c_icon_moon2").gameObject:SetActive(characterCfg.m_MoonType == 2)
      self.m_moonParent:Find("c_icon_moon3").gameObject:SetActive(characterCfg.m_MoonType == 3)
    end
    UILuaHelper.InitBreakView(heroObj.transform:Find("c_battle_card/c_list_star").gameObject, iBreak, characterCfg.m_Quality)
    UILuaHelper.InitCarrerViewTeam(heroObj.transform:Find("c_pnl_left_top/c_img_career").gameObject, characterCfg.m_Career)
    local borderObj, border2Obj, imgBgObj
    if characterCfg.m_Quality then
      local pathData = QualityPathCfg[characterCfg.m_Quality]
      borderObj = heroObj.transform:Find("c_battle_card/c_img_border"):GetComponent(T_Image)
      border2Obj = heroObj.transform:Find("c_battle_card/c_img_border/c_img_border2"):GetComponent(T_Image)
      imgBgObj = heroObj.transform:Find("c_battle_card/c_img_bg"):GetComponent(T_Image)
      if imgBgObj then
        UILuaHelper.SetAtlasSprite(imgBgObj, pathData.bgPath)
      end
      if borderObj then
        UILuaHelper.SetAtlasSprite(borderObj, pathData.borderImgPath)
      end
      if border2Obj then
        UILuaHelper.SetAtlasSprite(border2Obj, pathData.borderImgPath)
      end
    end
    if hasHero then
      self:SetHeroGrey(m_imgHead, borderObj, border2Obj, imgBgObj, nil)
    else
      self:SetHeroGrey(m_imgHead, borderObj, border2Obj, imgBgObj, self.m_img_grey_cache_Image.material)
    end
  else
    log.error("CharacterInfo not find heroID=" .. heroID)
  end
  local name_Text = heroObj.transform:Find("c_txt_name"):GetComponent("TextMeshProUGUI")
  name_Text.text = characterCfg.m_mName
  if hasHero then
    name_Text:GetComponent("MultiColorChange"):SetColorByIndex(0)
  else
    name_Text:GetComponent("MultiColorChange"):SetColorByIndex(1)
  end
  local c_Img_entered = heroObj.transform:Find("c_battle_card/c_Img_entered").gameObject
  c_Img_entered:SetActive(false)
  if self.m_formationIds then
    for i = 0, self.m_formationIds.Count - 1 do
      if self.m_formationIds[i] == heroID then
        c_Img_entered:SetActive(true)
        break
      end
    end
  end
end

function Form_HeroHaloTipsPop:SetHeroGrey(m_imgHead, borderObj, border2Obj, imgBgObj, greyMat)
  if m_imgHead then
    m_imgHead.material = greyMat
  end
  if borderObj then
    borderObj.material = greyMat
  end
  if border2Obj then
    border2Obj.material = greyMat
  end
  if imgBgObj then
    imgBgObj.material = greyMat
  end
end

function Form_HeroHaloTipsPop:GetLinkDes(des, params)
  local paramList = utils.changeCSArrayToLuaTable(params)
  local desParams = {}
  for i, v in ipairs(paramList) do
    local value = 0
    local paramValue, paramType = HeroManager:GetSkillValueByIdAndLevel(v)
    local paramFStr = "%.f"
    local paramFStr1 = "%.1f"
    if GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[paramType] then
      local paramF = GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.Fixed == paramType and paramFStr or paramFStr1
      paramValue = string.format(paramF, paramValue / GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[paramType])
    end
    if GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent == paramType then
      paramValue = string.format(ConfigManager:GetCommonTextById(100009), tostring(paramValue))
    end
    desParams[#desParams + 1] = paramValue
  end
  return string.gsubnumberreplace(des, table.unpack(desParams))
end

function Form_HeroHaloTipsPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroHaloTipsPop", Form_HeroHaloTipsPop)
return Form_HeroHaloTipsPop
