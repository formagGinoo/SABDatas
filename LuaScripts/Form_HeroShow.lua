local Form_HeroShow = class("Form_HeroShow", require("UI/UIFrames/Form_HeroShowUI"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local CharacterDamageTypeIns = ConfigManager:GetConfigInsByName("CharacterDamageType")
local QualitySpineColorCfg = {
  [HeroManager.QualityType.R] = {
    rectColor = {
      6,
      27,
      55,
      1
    },
    spineColor = {
      86,
      177,
      255,
      1
    },
    rectUpColor = {
      136,
      234,
      255,
      0.5
    },
    lightColor = {
      136,
      234,
      255,
      1
    }
  },
  [HeroManager.QualityType.SR] = {
    rectColor = {
      50,
      8,
      58,
      1
    },
    spineColor = {
      198,
      87,
      255,
      1
    },
    rectUpColor = {
      194,
      139,
      229,
      0.5
    },
    lightColor = {
      194,
      139,
      229,
      1
    }
  },
  [HeroManager.QualityType.SSR] = {
    rectColor = {
      78,
      28,
      21,
      1
    },
    spineColor = {
      255,
      158,
      86,
      1
    },
    rectUpColor = {
      229,
      95,
      30,
      0.5
    },
    lightColor = {
      229,
      95,
      30,
      1
    }
  }
}
local HeroShow_in = "HeroShow_in"

function Form_HeroShow:SetInitParam(param)
end

function Form_HeroShow:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_curShowHeroID = nil
  self.m_showHeroCfg = nil
  self.m_curQuality = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_HeroShow:OnActive()
  self.super.OnActive(self)
  self.m_playingVoiceStr = nil
  self.m_img_click:SetActive(false)
  self.m_btn_skip:SetActive(false)
  self.m_closeCallBack = self.m_csui.m_param.closeCallBack
  self.m_new_flag = self.m_csui.m_param.isNew
  self.m_wish_flag = self.m_csui.m_param.wishFlag
  self.m_bgmId = self.m_csui.m_param.bgmId or 45
  self:FreshData()
  self:FreshShowUI()
  UILuaHelper.ResetAnimationByName(self.m_rootTrans, HeroShow_in)
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, HeroShow_in)
  UILuaHelper.TryPlayUISFX(self.m_csui.m_uiGameObject, 1)
  GlobalManagerIns:TriggerWwiseBGMState(self.m_bgmId)
  if self.m_wish_flag then
    GlobalManagerIns:TriggerWwiseBGMState(239)
  end
end

function Form_HeroShow:OnInactive()
  self.super.OnInactive(self)
  if self.m_playingVoiceStr then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingVoiceStr)
  end
  self:CheckRecycleSpine(true)
  self.m_isGachaResult = nil
  if self.m_imgCloseTimer then
    TimeService:KillTimer(self.m_imgCloseTimer)
    self.m_imgCloseTimer = nil
  end
  if self.m_playingDisplayId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId)
    self.m_playingDisplayId = nil
  end
end

function Form_HeroShow:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_HeroShow:FreshData()
  self.m_curShowHeroID = nil
  self.m_showHeroCfg = nil
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curShowHeroID = tParam.heroID
    self.m_isGachaResult = tParam.isGacha
    local characterCfg = CharacterInfoIns:GetValue_ByHeroID(self.m_curShowHeroID)
    if not characterCfg:GetError() then
      self.m_showHeroCfg = characterCfg
    end
  end
end

function Form_HeroShow:FreshShowUI()
  if not self.m_showHeroCfg then
    return
  end
  UILuaHelper.SetCanvasGroupAlpha(self.m_hero_root, 0)
  local m_img_click = self.m_img_click
  if self.m_imgCloseTimer then
    TimeService:KillTimer(self.m_imgCloseTimer)
    self.m_imgCloseTimer = nil
  end
  self.m_imgCloseTimer = TimeService:SetTimer(3, 1, function()
    if not utils.isNull(m_img_click) then
      m_img_click:SetActive(true)
    end
  end)
  self:FreshShowHeroInfo()
end

function Form_HeroShow:FreshShowHeroInfo()
  if not self.m_showHeroCfg then
    return
  end
  local heroCfg = self.m_showHeroCfg
  if heroCfg.m_HeroID == 0 then
    return
  end
  local heroName = heroCfg.m_mName
  self.m_txt_hero_name_Text.text = heroName
  self.m_txt_hero_nikename_Text.text = tostring(heroCfg.m_mTitle)
  local quality = heroCfg.m_Quality
  self.m_curQuality = quality
  UILuaHelper.SetAtlasSprite(self.m_img_level_Image, QualityPathCfg[quality].ssrImgPath)
  local qualitySpineColorCfg = QualitySpineColorCfg[quality]
  if qualitySpineColorCfg then
    UILuaHelper.SetColor(self.m_img_light, table.unpack(qualitySpineColorCfg.lightColor))
  end
  local campCfg = CampCfgIns:GetValue_ByCampID(heroCfg.m_Camp)
  if not campCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_btn_camp_Image, campCfg.m_CampIcon .. "_big")
  end
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
  if not careerCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_career_Image, careerCfg.m_CareerIcon)
  end
  self:LoadHeroSpine(heroCfg.m_Spine, "heroshow", self.m_hero_root)
  self.m_pnl_bgr:SetActive(quality == GlobalConfig.QUALITY_COMMON_ENUM.R)
  self.m_pnl_bgsr:SetActive(quality == GlobalConfig.QUALITY_COMMON_ENUM.SR)
  self.m_pnl_bgssr:SetActive(quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
  self.m_mask_r:SetActive(quality == GlobalConfig.QUALITY_COMMON_ENUM.R)
  self.m_mask_sr:SetActive(quality == GlobalConfig.QUALITY_COMMON_ENUM.SR)
  self.m_mask_ssr:SetActive(quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
  self.m_Line_R_FX:SetActive(quality == GlobalConfig.QUALITY_COMMON_ENUM.R)
  self.m_Line_SRFX:SetActive(quality == GlobalConfig.QUALITY_COMMON_ENUM.SR)
  self.m_Line_SSRFX:SetActive(quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
  ResourceUtil:CreateEquipTypeImg(self.m_img_equipicon_Image, heroCfg.m_Equiptype)
  self.m_img_new:SetActive(self.m_new_flag)
  self.m_wish_node:SetActive(self.m_wish_flag)
  if self.m_playingDisplayId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId)
    self.m_playingDisplayId = nil
  end
  local voice = HeroManager:GetHeroGainVoice(heroCfg.m_HeroID)
  if voice and voice ~= "" then
    self.m_playingVoiceStr = voice
    CS.UI.UILuaHelper.StartPlaySFX(voice, nil, function(playingDisplayId)
      self.m_playingDisplayId = playingDisplayId
    end, function()
      self.m_playingDisplayId = nil
    end)
  end
  self:FreshMoonType()
  self:FreshDamageType(heroCfg.m_MainAttribute)
end

function Form_HeroShow:FreshMoonType()
  if not self.m_showHeroCfg then
    return
  end
  self.m_btn_moon:SetActive(self.m_isGachaResult)
  UILuaHelper.SetActive(self.m_icon_moon1, self.m_showHeroCfg.m_MoonType == 1)
  UILuaHelper.SetActive(self.m_icon_moon2, self.m_showHeroCfg.m_MoonType == 2)
  UILuaHelper.SetActive(self.m_icon_moon3, self.m_showHeroCfg.m_MoonType == 3)
end

function Form_HeroShow:FreshDamageType(heroAttribute)
  if not heroAttribute then
    return
  end
  local damageCfg = CharacterDamageTypeIns:GetValue_ByDamageType(heroAttribute)
  if damageCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_damagetype_Image, damageCfg.m_DamageTypeIcon)
end

function Form_HeroShow:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
  if not heroSpineAssetName then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      self:CheckShowSpineAnim()
    end)
  end
end

function Form_HeroShow:CheckShowSpineAnim()
  if utils.isNull(self.m_showHeroCfg) then
    return
  end
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpineObj = self.m_curHeroSpineObj.spineObj
  if utils.isNull(heroSpineObj) then
    log.error("Form_HeroShow CheckShowSpineAnim is error ")
    return
  end
  if UILuaHelper.CheckIsHaveSpineAnim(heroSpineObj, "idle2") then
    UILuaHelper.SpinePlayAnim(heroSpineObj, 0, "idle2", true)
  else
    UILuaHelper.SpinePlayAnim(heroSpineObj, 0, "idle", true)
  end
  UILuaHelper.SetCanvasGroupAlpha(self.m_hero_root, 1)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(1)
  sequence:OnComplete(function()
    if not utils.isNull(self.m_btn_skip) then
      self.m_btn_skip:SetActive(self.m_isGachaResult)
      self.m_img_click:SetActive(true)
    end
  end)
  sequence:SetAutoKill(true)
  local sequence2 = Tweening.DOTween.Sequence()
  sequence:AppendInterval(0.5)
  sequence2:OnComplete(function()
    if not utils.isNull(heroSpineObj) then
      UILuaHelper.SetSpineSkeletonGraphicDissolveEffect(heroSpineObj)
    end
  end)
  sequence:SetAutoKill(true)
  if not self.m_isGachaResult then
    self.m_img_click:SetActive(true)
  end
end

function Form_HeroShow:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HeroShow:OnImgclickClicked()
  self:CloseForm()
  if not self.m_isGachaResult then
    PushFaceManager:CheckShowNextPopRewardPanel()
  end
  if self.m_closeCallBack then
    self.m_closeCallBack()
    self.m_closeCallBack = nil
  end
end

function Form_HeroShow:OnBtnskipClicked()
  GachaManager:SetSkippedHeroShow(true)
  if self.m_isGachaResult then
    self:CloseForm()
    if self.m_closeCallBack then
      self.m_closeCallBack()
      self.m_closeCallBack = nil
    end
  end
end

function Form_HeroShow:GetDownloadResourceExtra(tParam)
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
ActiveLuaUI("Form_HeroShow", Form_HeroShow)
return Form_HeroShow
