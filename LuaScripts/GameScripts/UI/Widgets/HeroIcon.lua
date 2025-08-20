local HeroIcon = class("HeroIcon")
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local BondIns = ConfigManager:GetConfigInsByName("Bond")
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")

function HeroIcon:ctor(goRoot)
  self.m_objRoot = goRoot
  self.m_goRootTrans = goRoot.transform
  self:InitComponents()
  self.m_enterBloodAnim = true
end

local string_format = string.format
local HP_CHANGE_ANIM_TIME = 0.02

function HeroIcon:InitComponents()
  if not self.m_goRootTrans then
    return
  end
  self.m_buttonEx = self.m_goRootTrans:Find("c_btnClick"):GetComponent("ButtonExtensions")
  self.m_heroIconLongPressCB = nil
  self.m_buttonEx = self.m_buttonEx:GetComponent("ButtonExtensions")
  if self.m_buttonEx then
    self.m_buttonEx.Clicked = handler(self, self.OnHeroIconClicked)
  end
  self.m_playUISfx = self.m_buttonEx:GetComponent("PlayUISfx")
  if self.m_playUISfx then
    self.m_sfxID = self.m_playUISfx.UISfxID
  end
  self.m_heroIconClickCB = nil
  local imgBgObj = self.m_goRootTrans:Find("c_battle_card/c_img_bg")
  if imgBgObj then
    self.m_img_bg = imgBgObj:GetComponent(T_Image)
  end
  local imgBgBigObj = self.m_goRootTrans:Find("c_battle_card/c_img_bg_big")
  if imgBgBigObj then
    self.m_img_bg_big = imgBgBigObj:GetComponent(T_Image)
  end
  local borderObjBig = self.m_goRootTrans:Find("c_battle_card/c_img_border_big")
  if borderObjBig then
    self.m_img_border_big = borderObjBig:GetComponent(T_Image)
    local border2Obj = self.m_goRootTrans:Find("c_battle_card/c_img_border_big/c_img_border_big2")
    if border2Obj then
      self.m_img_border_big2 = border2Obj:GetComponent(T_Image)
    end
  end
  local borderObj = self.m_goRootTrans:Find("c_battle_card/c_img_border")
  if borderObj then
    self.m_img_border = borderObj:GetComponent(T_Image)
    local border2Obj = self.m_goRootTrans:Find("c_battle_card/c_img_border/c_img_border2")
    if border2Obj then
      self.m_img_border2 = border2Obj:GetComponent(T_Image)
    end
  end
  local img_head_obj = self.m_goRootTrans:Find("c_battle_card/pnl_head_mask/c_img_head")
  if img_head_obj then
    self.m_imgHead = img_head_obj:GetComponent(T_Image)
  end
  local img_icon_obj = self.m_goRootTrans:Find("c_battle_card/pnl_head_mask/c_img_icon")
  if img_icon_obj then
    self.m_iconHead = img_icon_obj:GetComponent(T_Image)
  end
  self.m_pnl_left_top = self.m_goRootTrans:Find("c_pnl_left_top").gameObject
  self.m_img_career = self.m_goRootTrans:Find("c_pnl_left_top/c_img_career/c_icon_career"):GetComponent("Image")
  local equipTypeObj = self.m_goRootTrans:Find("c_pnl_left_top/c_img_equip/c_icon_equip")
  if equipTypeObj then
    self.m_icon_equip_type = equipTypeObj:GetComponent("Image")
  end
  self.m_liziRoot = self.m_goRootTrans:Find("c_battle_card/lizi_node_root")
  if self.m_liziRoot then
    self.m_lizir = self.m_goRootTrans:Find("c_battle_card/lizi_node_root/lizir")
    self.m_lizisr = self.m_goRootTrans:Find("c_battle_card/lizi_node_root/lizisr")
    self.m_lizissr = self.m_goRootTrans:Find("c_battle_card/lizi_node_root/lizissr")
  end
  local txtLvObj = self.m_goRootTrans:Find("c_battle_card/c_txt_lv_num")
  if txtLvObj then
    self.m_txt_Lv_num = txtLvObj:GetComponent(T_TextMeshProUGUI)
  end
  local txtLvObjBig = self.m_goRootTrans:Find("c_battle_card/txt_lv/c_txt_lv_num")
  if txtLvObjBig then
    self.m_txt_Lv_num_big = txtLvObjBig:GetComponent(T_TextMeshProUGUI)
  end
  local nameTextNode = self.m_goRootTrans:Find("bg_txt_name/c_txt_name")
  if nameTextNode then
    self.m_txt_name = nameTextNode:GetComponent(T_TextMeshProUGUI)
  end
  local btnHeroSearchObj = self.m_goRootTrans:Find("c_img_hero_search_bg/btn_hero_search")
  if btnHeroSearchObj then
    self.m_btnHeroSearch = btnHeroSearchObj:GetComponent(T_Button)
    UILuaHelper.BindButtonClickManual(self, self.m_btnHeroSearch, function()
      self:OnHeroSearchClk()
    end)
    self.m_heroSearchClickCB = nil
  end
  self.m_star_node = self.m_goRootTrans:Find("c_battle_card/c_list_star")
  if self.m_star_node then
    self.m_breakthrough_progress_SR = self.m_star_node:Find("c_breakthrough_progress_SR")
    self.m_breakthrough_progress_SSR = self.m_star_node:Find("c_breakthrough_progress_SSR")
    for i = 1, HeroManager.SSRBreakNum do
      self["m_img_break_SSR" .. i] = self.m_breakthrough_progress_SSR:Find(string_format("img_icon_stable%d/c_img_break_SSR%d", i, i))
    end
    self.m_img_break_SSR4 = self.m_star_node:Find("c_img_break_SSR4")
    for i = 1, HeroManager.MaxBreakNewType do
      self["m_pnl_break_light" .. i] = self.m_img_break_SSR4:Find(string_format("img_icon_stable%d", i))
    end
    self.m_txt_break_num_Text = self.m_img_break_SSR4:Find("c_txt_break_num"):GetComponent(T_TextMeshProUGUI)
    for i = 1, HeroManager.SRBreakNum do
      self["m_img_break_SR" .. i] = self.m_breakthrough_progress_SR:Find(string_format("img_icon_stable%d/c_img_break_SR%d", i, i))
    end
  end
  self.m_imageSelectedTran = self.m_goRootTrans:Find("c_img_selected")
  self.m_inheritTran = self.m_goRootTrans:Find("c_icon_tongbu")
  self.m_iconAttract = self.m_goRootTrans:Find("c_icon_attrackt")
  self.m_moonParent = self.m_goRootTrans:Find("c_bg_moon")
  if not utils.isNull(self.m_moonParent) then
    self.m_moonTypeOne = self.m_moonParent:Find("c_icon_moon1")
    self.m_moonTypeTwo = self.m_moonParent:Find("c_icon_moon2")
    self.m_moonTypeThree = self.m_moonParent:Find("c_icon_moon3")
  end
  self.m_slider_hp = self.m_goRootTrans:Find("c_slider_heart/c_img_fg_slider")
  if not utils.isNull(self.m_slider_hp) then
    self.m_slider_hp_img = self.m_slider_hp:GetComponent(T_Image)
  end
  self.m_death_obj = self.m_goRootTrans:Find("c_death_img")
  local txtChanceObj = self.m_goRootTrans:Find("c_txt_chance")
  if not utils.isNull(txtChanceObj) then
    self.m_txt_chance_num = txtChanceObj:GetComponent(T_TextMeshProUGUI)
  end
  local txtNameObj = self.m_goRootTrans:Find("c_txt_name")
  if not utils.isNull(txtNameObj) then
    self.m_txt_name = txtNameObj:GetComponent(T_TextMeshProUGUI)
  end
  self.m_img_notheld = self.m_goRootTrans:Find("c_img_notheld")
  self.m_txt_notheld = self.m_goRootTrans:Find("c_txt_notowned")
  local c_btn_selectframe = self.m_goRootTrans:Find("c_btn_selectframe")
  if c_btn_selectframe then
    c_btn_selectframe.gameObject:SetActive(false)
    self.c_btn_selectframe = c_btn_selectframe
  end
  local c_no_obtain = self.m_goRootTrans:Find("c_no_obtain")
  if c_no_obtain then
    c_no_obtain.gameObject:SetActive(false)
    self.c_no_obtain = c_no_obtain
  end
end

function HeroIcon:OnUpdate(dt)
end

function HeroIcon:SetHeroData(heroData, isSelected, isHideBreak, isShowMoon, isHideLv)
  if not heroData then
    return
  end
  self.m_heroData = heroData
  local heroCfgID = heroData.iHeroId
  self.m_heroID = heroCfgID
  local heroCfg = CharacterInfoIns:GetValue_ByHeroID(heroCfgID)
  if heroCfg:GetError() then
    log.error("HeroIcon heroCfgID Cannot Find Check Config: " .. tostring(heroCfgID))
    return
  end
  self.m_heroCfg = heroCfg
  self.m_isSelected = isSelected
  self.m_isHideBreak = isHideBreak
  self.m_isShowMoon = isShowMoon
  self.m_isHideLv = isHideLv
  self.m_maxBreakLevel = self:GetHeroMaxBreakLevel() or 0
  self:FreshHeroShow()
end

function HeroIcon:SetHeroDataHeroHot(heroCfg)
  if not heroCfg then
    return
  end
  self.m_heroCfg = heroCfg
  self:FreshHeadIcon(heroCfg.m_PerformanceID[0])
  self:FreshQuality(heroCfg.m_Quality)
  self.m_isShowMoon = true
  self:FreshMoonType(heroCfg.m_MoonType)
  self:FreshCareer(heroCfg.m_Career)
end

function HeroIcon:GetHeroMaxBreakLevel()
  if not self.m_heroCfg then
    return
  end
  local heroBreak = 0
  local limitBreakTemplateID = self.m_heroCfg.m_Quality
  if limitBreakTemplateID == nil or limitBreakTemplateID == 0 then
    return heroBreak
  end
  local allCharacterLimitBreaks = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplate(limitBreakTemplateID)
  for _, breakCfg in pairs(allCharacterLimitBreaks) do
    if heroBreak < breakCfg.m_LimitBreakLevel then
      heroBreak = breakCfg.m_LimitBreakLevel
    end
  end
  return heroBreak
end

function HeroIcon:GetPerformanceID()
  if not self.m_heroCfg then
    return
  end
  if not self.m_heroData then
    return
  end
  local heroFashion = HeroManager:GetHeroFashion()
  if not heroFashion then
    return
  end
  local fashionID = self.m_heroData.iFashion or 0
  local fashionInfo = heroFashion:GetFashionInfoByHeroIDAndFashionID(self.m_heroCfg.m_HeroID, fashionID)
  if not fashionInfo then
    return self.m_heroCfg.m_PerformanceID[0]
  end
  return fashionInfo.m_PerformanceID[0]
end

function HeroIcon:FreshHeroShow()
  if not self.m_heroCfg then
    return
  end
  if not self.m_heroData then
    return
  end
  local lvNum = self.m_heroData.iLevel or 0
  self:FreshHeroLv(lvNum)
  self:FreshBreak(self.m_heroData.iBreak or 0, self.m_heroCfg.m_Quality, self.m_isHideBreak)
  local performanceID = self:GetPerformanceID()
  self:FreshHeadIcon(performanceID)
  self:FreshQuality(self.m_heroCfg.m_Quality)
  self:FreshCareer(self.m_heroCfg.m_Career)
  self:FreshName(self.m_heroCfg.m_mShortname)
  self:SetSelected(self.m_isSelected)
  self:FreshInherit()
  self:FreshFavourite()
  self:FreshHeroHp()
  self:FreshHeroChance(self.m_heroData.chance)
  self:FreshMoonType(self.m_heroCfg.m_MoonType)
  self:FreshNotHave()
  ResourceUtil:CreateEquipTypeImg(self.m_icon_equip_type, self.m_heroCfg.m_Equiptype)
  self:SetHeroGrey(false)
  self:FreshGreyBg()
  self:FreshHideLv(self.m_isHideLv)
end

function HeroIcon:FreshGreyBg()
  if not utils.isNull(self.m_img_notheld) then
    local show = self.m_heroData.notHave or self.m_heroData.chance == 0
    self.m_img_notheld.gameObject:SetActive(show)
  end
end

function HeroIcon:FreshNotHave()
  if not utils.isNull(self.m_txt_notheld) then
    self.m_txt_notheld.gameObject:SetActive(self.m_heroData.notHave)
    local txt_notheld = self.m_txt_notheld:GetComponent(T_TextMeshProUGUI)
    txt_notheld.text = ConfigManager:GetCommonTextById(100093)
  end
end

function HeroIcon:FreshInherit()
  if not self.m_heroData.iOriLevel then
    if self.m_txt_Lv_num then
      UILuaHelper.SetColor(self.m_txt_Lv_num, 255, 255, 255, 1)
    end
    if self.m_txt_Lv_num_big then
      UILuaHelper.SetColor(self.m_txt_Lv_num_big, 255, 255, 255, 1)
    end
    if self.m_inheritTran then
      self.m_inheritTran.gameObject:SetActive(false)
    end
    return
  end
  local resetFlag, isHave = InheritManager:CheckCanResetLvById(self.m_heroData.iHeroId)
  if self.m_inheritTran then
    self.m_inheritTran.gameObject:SetActive(not resetFlag and isHave)
  end
  if self.m_txt_Lv_num then
    if not resetFlag and isHave then
      UILuaHelper.SetColor(self.m_txt_Lv_num, 178, 72, 91, 1)
    else
      UILuaHelper.SetColor(self.m_txt_Lv_num, 255, 255, 255, 1)
    end
  end
  if self.m_txt_Lv_num_big then
    if not resetFlag and isHave then
      UILuaHelper.SetColor(self.m_txt_Lv_num_big, 178, 72, 91, 1)
    else
      UILuaHelper.SetColor(self.m_txt_Lv_num_big, 255, 255, 255, 1)
    end
  end
end

function HeroIcon:FreshFavourite()
  if self.m_iconAttract then
    if self.m_heroData.bLove then
      UILuaHelper.SetActive(self.m_iconAttract, true)
    else
      UILuaHelper.SetActive(self.m_iconAttract, false)
    end
  end
end

function HeroIcon:FreshHeroHp()
  if not utils.isNull(self.m_slider_hp_img) and not utils.isNull(self.m_death_obj) then
    local curHpPercent = self.m_heroData.iHpPercent or 1
    local oldHpPercent = self.m_heroData.oldHpPercent or 1
    self.m_death_obj.gameObject:SetActive(curHpPercent == 0)
    if self.m_enterBloodAnim then
      self.m_slider_hp_img.fillAmount = oldHpPercent
      self.m_enterBloodAnim = false
      local sequence = Tweening.DOTween.Sequence()
      sequence:AppendInterval(1)
      sequence:OnComplete(function()
        if self and not utils.isNull(self.m_slider_hp_img) then
          DOTweenModuleUI.DOFillAmount(self.m_slider_hp_img, curHpPercent, 1)
        end
      end)
      sequence:SetAutoKill(true)
    else
      self.m_slider_hp_img.fillAmount = curHpPercent
    end
  end
end

function HeroIcon:SetInheritColor(r, g, b)
  if not utils.isNull(self.m_txt_Lv_num) then
    UILuaHelper.SetColor(self.m_txt_Lv_num, r, g, b, 1)
  end
  if not utils.isNull(self.m_txt_Lv_num_big) then
    UILuaHelper.SetColor(self.m_txt_Lv_num_big, r, g, b, 1)
  end
end

function HeroIcon:FreshHeroLv(LvNum)
  if not LvNum then
    return
  end
  if not utils.isNull(self.m_txt_Lv_num) then
    self.m_txt_Lv_num.text = string.format(ConfigManager:GetCommonTextById(20033), tostring(LvNum))
  end
  if not utils.isNull(self.m_txt_Lv_num_big) then
    self.m_txt_Lv_num_big.text = tostring(LvNum)
  end
end

function HeroIcon:FreshHideLv(hideLv)
  if hideLv then
    if not utils.isNull(self.m_txt_Lv_num) then
      self.m_txt_Lv_num.text = ""
    end
    if not utils.isNull(self.m_txt_Lv_num_big) then
      self.m_txt_Lv_num_big.text = ""
    end
  end
end

function HeroIcon:FreshHeroChance(LvNum)
  if not LvNum then
    return
  end
  if not utils.isNull(self.m_txt_chance_num) then
    self.m_txt_chance_num.text = string.format(ConfigManager:GetCommonTextById(100009), tostring(LvNum))
  end
end

function HeroIcon:FreshBreak(breakNum, quality, isHideBreak)
  if not breakNum then
    return
  end
  if isHideBreak then
    UILuaHelper.SetActive(self.m_star_node, false)
    return
  end
  if quality == HeroManager.QualityType.R then
    UILuaHelper.SetActive(self.m_star_node, false)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, false)
    UILuaHelper.SetActive(self.m_img_break_SSR4, false)
  elseif quality == HeroManager.QualityType.SR then
    UILuaHelper.SetActive(self.m_star_node, true)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, true)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, false)
    UILuaHelper.SetActive(self.m_img_break_SSR4, false)
    for i = 1, HeroManager.SRBreakNum do
      UILuaHelper.SetActive(self["m_img_break_SR" .. i], i <= breakNum)
    end
  elseif quality == HeroManager.QualityType.SSR then
    UILuaHelper.SetActive(self.m_star_node, true)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SR, false)
    UILuaHelper.SetActive(self.m_breakthrough_progress_SSR, breakNum <= HeroManager.SSRBreakNum)
    UILuaHelper.SetActive(self.m_img_break_SSR4, breakNum > HeroManager.SSRBreakNum and self.m_maxBreakLevel)
    if breakNum <= HeroManager.SSRBreakNum then
      for i = 1, HeroManager.SSRBreakNum do
        UILuaHelper.SetActive(self["m_img_break_SSR" .. i], i <= breakNum)
      end
    end
    if breakNum > HeroManager.SSRBreakNum and self.m_maxBreakLevel then
      local overBreakNum = breakNum - HeroManager.SSRBreakNum
      self.m_txt_break_num_Text.text = UIUtil:ArabToRomaNum(overBreakNum)
      local maxNum = self.m_maxBreakLevel - HeroManager.SSRBreakNum
      for i = 1, maxNum do
        if not utils.isNull(self["m_pnl_break_light" .. i]) then
          UILuaHelper.SetActive(self["m_pnl_break_light" .. i], i <= breakNum - HeroManager.SSRBreakNum)
        end
      end
    else
      UILuaHelper.SetActive(self.m_img_break_SSR4, false)
    end
  else
    UILuaHelper.SetActive(self.m_star_node, false)
  end
end

function HeroIcon:FreshCareer(heroCareer)
  if not heroCareer then
    return
  end
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCareer)
  if careerCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_career, careerCfg.m_CareerIcon)
end

function HeroIcon:FreshHeadIcon(performanceIDLv)
  if not performanceIDLv then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(performanceIDLv)
  if not presentationData.m_UIkeyword then
    return
  end
  if self.m_iconHead then
    local szIcon = presentationData.m_UIkeyword .. "003"
    UILuaHelper.SetAtlasSprite(self.m_iconHead, szIcon)
  end
  if self.m_imgHead then
    local szIcon = presentationData.m_UIkeyword .. "001"
    UILuaHelper.SetAtlasSprite(self.m_imgHead, szIcon)
  end
end

function HeroIcon:FreshQuality(qualityNum)
  if not qualityNum then
    return
  end
  local pathData = QualityPathCfg[qualityNum]
  if pathData then
    if self.m_img_bg then
      UILuaHelper.SetAtlasSprite(self.m_img_bg, pathData.bgPath)
    end
    if self.m_img_bg_big then
      UILuaHelper.SetAtlasSprite(self.m_img_bg_big, pathData.bgBigPath)
    end
    if self.m_img_border_big then
      UILuaHelper.SetAtlasSprite(self.m_img_border_big, pathData.borderBigImgPath)
    end
    if self.m_img_border_big2 then
      UILuaHelper.SetAtlasSprite(self.m_img_border_big2, pathData.borderBigImgPath)
    end
    if self.m_img_border then
      UILuaHelper.SetAtlasSprite(self.m_img_border, pathData.borderImgPath)
    end
    if self.m_img_border2 then
      UILuaHelper.SetAtlasSprite(self.m_img_border2, pathData.borderImgPath)
    end
    if self.m_lizir then
      UILuaHelper.SetActive(self.m_lizir, qualityNum == HeroManager.QualityType.R)
    end
    if self.m_lizisr then
      UILuaHelper.SetActive(self.m_lizisr, qualityNum == HeroManager.QualityType.SR)
    end
    if self.m_lizissr then
      UILuaHelper.SetActive(self.m_lizissr, qualityNum == HeroManager.QualityType.SSR)
    end
  end
end

function HeroIcon:SetHeroGrey(isGrey, greyMat)
  if isGrey then
    if greyMat then
      if self.m_iconHead then
        self.m_iconHead.material = greyMat
      end
      if self.m_imgHead then
        self.m_imgHead.material = greyMat
      end
      if self.m_img_border_big then
        self.m_img_border_big.material = greyMat
      end
      if self.m_img_border_big2 then
        self.m_img_border_big2.material = greyMat
      end
      if self.m_img_border then
        self.m_img_border.material = greyMat
      end
      if self.m_img_border2 then
        self.m_img_border2.material = greyMat
      end
      if self.m_liziRoot then
        UILuaHelper.SetActive(self.m_liziRoot, false)
      end
    end
  else
    if self.m_iconHead then
      self.m_iconHead.material = nil
    end
    if self.m_imgHead then
      self.m_imgHead.material = nil
    end
    if self.m_img_border_big then
      self.m_img_border_big.material = nil
    end
    if self.m_img_border_big2 then
      self.m_img_border_big2.material = nil
    end
    if self.m_img_border then
      self.m_img_border.material = nil
    end
    if self.m_img_border2 then
      self.m_img_border2.material = nil
    end
    if self.m_liziRoot then
      UILuaHelper.SetActive(self.m_liziRoot, true)
    end
  end
end

function HeroIcon:FreshName(nameStr)
  if not nameStr then
    return
  end
  if not self.m_txt_name then
    return
  end
  self.m_txt_name.text = nameStr
end

function HeroIcon:SetActive(isActive)
  if not self.m_objRoot then
    return
  end
  UILuaHelper.SetActive(self.m_objRoot, isActive)
end

function HeroIcon:SetSelected(bSelected)
  if self.m_imageSelectedTran then
    self.m_imageSelectedTran.gameObject:SetActive(bSelected)
  end
end

function HeroIcon:SetTeamCurSelected(bSelected)
  if self.c_btn_selectframe then
    self.c_btn_selectframe.gameObject:SetActive(bSelected)
  end
end

function HeroIcon:SetObtainActive(isActive)
  if self.c_no_obtain then
    self.c_no_obtain.gameObject:SetActive(isActive)
  end
  if self.m_star_node then
    self.m_star_node.gameObject:SetActive(not isActive)
  end
  if self.m_img_career then
    self.m_img_career.transform.parent.gameObject:SetActive(not isActive)
  end
end

function HeroIcon:SetSwallowTouch(bSwallowTouch)
  self.m_buttonEx:GetComponent("Empty4Raycast").SwallowTouch = bSwallowTouch
end

function HeroIcon:SetHeroIconClickCB(fClickCB)
  self.m_buttonEx:GetComponent("Empty4Raycast").raycastTarget = fClickCB ~= nil
  self.m_heroIconClickCB = fClickCB
end

function HeroIcon:OnHeroIconClicked()
  if self.m_heroIconClickCB then
    if self.m_sfxID then
      GlobalManagerIns:TriggerWwiseBGMState(self.m_sfxID)
    end
    self.m_heroIconClickCB(self.m_heroID, self)
  end
end

function HeroIcon:SetHeroIconLongPressCB(longPressCB)
  self.m_heroIconLongPressCB = longPressCB
  if self.m_buttonEx then
    self.m_buttonEx.LongPress = handler(self, self.OnHeroIconLongPress)
  end
end

function HeroIcon:FreshMoonType(moonType)
  if not moonType then
    return
  end
  if not self.m_isShowMoon and not utils.isNull(self.m_moonParent) then
    UILuaHelper.SetActive(self.m_moonParent, false)
    return
  end
  if not utils.isNull(self.m_moonParent) then
    UILuaHelper.SetActive(self.m_moonParent, true)
    UILuaHelper.SetActive(self.m_moonTypeOne, moonType == 1)
    UILuaHelper.SetActive(self.m_moonTypeTwo, moonType == 2)
    UILuaHelper.SetActive(self.m_moonTypeThree, moonType == 3)
  end
end

function HeroIcon:OnHeroIconLongPress()
  if self.m_heroIconLongPressCB then
    self.m_heroIconLongPressCB(self.m_heroID)
  end
end

function HeroIcon:OnHeroSearchClk()
  if self.m_heroSearchClickCB then
    self.m_heroSearchClickCB(self.m_heroID)
  end
end

function HeroIcon:SetHeroSearchClickCB(searchCB)
  self.m_heroSearchClickCB = searchCB
end

function HeroIcon:SetHeroStyleForStargazing()
  self.m_pnl_left_top:SetActive(false)
  self.m_star_node.gameObject:SetActive(false)
  self.m_moonParent.gameObject:SetActive(false)
  self.m_txt_Lv_num.text = self.m_heroCfg.m_mName
end

return HeroIcon
