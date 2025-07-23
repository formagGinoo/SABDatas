local Form_HeroBreakThrough = class("Form_HeroBreakThrough", require("UI/UIFrames/Form_HeroBreakThroughUI"))
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
local RBreakNum = HeroManager.RBreakNum
local SRBreakNum = HeroManager.SRBreakNum
local SSRBreakNum = HeroManager.SSRBreakNum
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local string_format = string.format
local ipairs = _ENV.ipairs

function Form_HeroBreakThrough:SetInitParam(param)
end

function Form_HeroBreakThrough:AfterInit()
  self.super.AfterInit(self)
  self.m_curShowHeroData = nil
  self.m_beforeBreakNum = nil
  self.m_afterBreakNum = nil
  self.m_maxBreakNum = nil
  self.m_maxBackFun = nil
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_HeroFashion = HeroManager:GetHeroFashion()
end

function Form_HeroBreakThrough:OnActive()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(33)
  self.super.OnActive(self)
  self:FreshUI()
end

function Form_HeroBreakThrough:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
  self:ClearData()
end

function Form_HeroBreakThrough:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
  self:ClearData()
end

function Form_HeroBreakThrough:FreshData()
  if not self.m_curShowHeroData then
    return
  end
  self.m_curHeroLv = self.m_curShowHeroData.serverData.iLevel
  self.m_heroBreakCfgList = {}
  self.m_maxBreakNum = 0
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

function Form_HeroBreakThrough:ClearData()
  self.m_heroBreakCfgList = nil
  self.m_curHeroLv = nil
end

function Form_HeroBreakThrough:IsBreakMax()
  local breakNum = self.m_curShowHeroData.serverData.iBreak or 0
  if breakNum >= self.m_maxBreakNum then
    return true
  end
  return false
end

function Form_HeroBreakThrough:IsHeroOverQualityBreak()
  if not self.m_curShowHeroData then
    return
  end
  local breakNum = self.m_curShowHeroData.serverData.iBreak or 0
  local heroCfg = self.m_curShowHeroData.characterCfg
  local quality = heroCfg.m_Quality
  local qualityLimitBreakNum = RBreakNum
  if quality == HeroManager.QualityType.R then
    qualityLimitBreakNum = RBreakNum
  elseif quality == HeroManager.QualityType.SR then
    qualityLimitBreakNum = SRBreakNum
  else
    qualityLimitBreakNum = SSRBreakNum
  end
  return breakNum > qualityLimitBreakNum
end

function Form_HeroBreakThrough:FreshUI()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curShowHeroData = tParam.heroData
  self.m_beforeBreakNum = tParam.beforeBreakNum
  self.m_afterBreakNum = tParam.afterBreakNum
  self:FreshData()
  self:FreshBreakStatus()
  self:FreshShowBeforeUp()
  self:FreshShowAfterUp()
  self:FreshShowSpine()
end

function Form_HeroBreakThrough:FreshBreakStatus()
  local breakNum = self.m_curShowHeroData.serverData.iBreak or 0
  local heroCfg = self.m_curShowHeroData.characterCfg
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
      local overBreakNum = self.m_maxBreakNum - SSRBreakNum
      for i = 1, overBreakNum do
        if not utils.isNull(self["m_pnl_break_light" .. i]) then
          UILuaHelper.SetActive(self["m_pnl_break_light" .. i], i <= breakNum - SSRBreakNum)
        end
      end
    else
      UILuaHelper.SetActive(self.m_img_break_SSR4, false)
    end
  end
  local heroID = self.m_curShowHeroData.serverData.iHeroId
  local fashionID = self.m_curShowHeroData.serverData.iFashion
  local voice = HeroManager:GetHeroVoice():GetHeroBreakVoice(heroID, fashionID)
  if voice and voice ~= "" then
    CS.UI.UILuaHelper.StartPlaySFX(voice)
  end
end

function Form_HeroBreakThrough:FreshShowBeforeUp()
  local breakNum = self.m_beforeBreakNum
  local curBreakCfg = self.m_heroBreakCfgList[breakNum]
  if not curBreakCfg then
    return
  end
  local curBreakMaxLv = curBreakCfg.m_MaxLevel
  self.m_txt_break_before_num_Text.text = curBreakMaxLv
  local heroID = self.m_curShowHeroData.characterCfg.m_HeroID
  local heroServerData = self.m_curShowHeroData.serverData
  local heroAttrTab = self.m_heroAttr:GetHeroAttrByParam(heroID, {
    iBreak = breakNum,
    iLevel = self.m_curHeroLv
  }, heroServerData)
  for i, _ in ipairs(AttrBaseShowCfg) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
    UILuaHelper.SetAtlasSprite(self[string_format("m_before_attr_icon%d_Image", i)], propertyIndexCfg.m_PropertyIcon .. "_02")
    self[string_format("m_before_attr_name%d_Text", i)].text = propertyIndexCfg.m_mCNName
    self[string_format("m_before_attr_num%d_Text", i)].text = BigNumFormat(heroAttrTab[propertyIndexCfg.m_ENName] or 0)
  end
  local isOverQualityBreak = self:IsHeroOverQualityBreak()
  UILuaHelper.SetActive(self.m_pnl_breakthrough_lv_upgrade, not isOverQualityBreak)
  UILuaHelper.SetActive(self.m_pnl_breakthrough_lv_top, isOverQualityBreak)
  if isOverQualityBreak then
    self.m_txt_break_num_top_Text.text = curBreakMaxLv
  end
end

function Form_HeroBreakThrough:FreshShowAfterUp()
  local afterBreakNum = self.m_afterBreakNum
  local afterBreakCfg = self.m_heroBreakCfgList[afterBreakNum]
  if not afterBreakCfg then
    return
  end
  local afterBreakMaxLvNum = afterBreakCfg.m_MaxLevel
  self.m_txt_break_after_num_Text.text = afterBreakMaxLvNum
  local heroID = self.m_curShowHeroData.characterCfg.m_HeroID
  local heroServerData = self.m_curShowHeroData.serverData
  local heroAttrTab = self.m_heroAttr:GetHeroAttrByParam(heroID, {
    iBreak = afterBreakNum,
    iLevel = self.m_curHeroLv
  }, heroServerData)
  for i, _ in ipairs(AttrBaseShowCfg) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
    local afterAttrStr = BigNumFormat(heroAttrTab[propertyIndexCfg.m_ENName] or 0) or MaxStr
    self[string_format("m_after_attr_num%d_Text", i)].text = afterAttrStr
  end
end

function Form_HeroBreakThrough:FreshShowSpine()
  if not self.m_curShowHeroData then
    return
  end
  local fashionID = self.m_curShowHeroData.serverData.iFashion
  local heroID = self.m_curShowHeroData.serverData.iHeroId
  local heroFashionSpine = self.m_HeroFashion:GetHeroSpineByHeroFashionID(heroID, fashionID)
  if not heroFashionSpine then
    return
  end
  self:LoadHeroSpine(heroFashionSpine, SpinePlaceCfg.HeroBreak, self.m_hero_root)
end

function Form_HeroBreakThrough:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HeroBreakThrough:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
  if not heroSpineAssetName then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end)
  end
end

function Form_HeroBreakThrough:OnBtnBgCloseClicked()
  self:CloseForm()
end

function Form_HeroBreakThrough:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroID = tParam.heroData.characterCfg.m_HeroID
  vPackage[#vPackage + 1] = {
    sName = tostring(heroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

function Form_HeroBreakThrough:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroBreakThrough", Form_HeroBreakThrough)
return Form_HeroBreakThrough
