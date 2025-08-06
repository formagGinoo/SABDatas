local Form_GetSkin = class("Form_GetSkin", require("UI/UIFrames/Form_GetSkinUI"))

function Form_GetSkin:SetInitParam(param)
end

function Form_GetSkin:AfterInit()
  self.super.AfterInit(self)
  self.m_curFashionID = nil
  self.m_curFashionInfo = nil
  self.m_isNew = nil
  self.m_HeroFashion = HeroManager:GetHeroFashion()
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_HeroVoice = HeroManager:GetHeroVoice()
end

function Form_GetSkin:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_GetSkin:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_GetSkin:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
  if self.m_showClickTween and self.m_showClickTween:IsPlaying() then
    self.m_showClickTween:Kill()
  end
  self.m_showClickTween = nil
end

function Form_GetSkin:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curFashionID = tParam.fashionID
    self.m_isNew = tParam.isNew
    self.m_curFashionInfo = self.m_HeroFashion:GetFashionInfoByID(self.m_curFashionID)
    self.m_csui.m_param = nil
  end
end

function Form_GetSkin:ClearCacheData()
  if self.m_playingVoiceStr then
    UILuaHelper.StopPlaySFX(self.m_playingVoiceStr)
  end
  self:CheckRecycleSpine(true)
  if self.m_imgCloseTimer then
    TimeService:KillTimer(self.m_imgCloseTimer)
    self.m_imgCloseTimer = nil
  end
  if self.m_playingDisplayId then
    UILuaHelper.StopPlaySFX(self.m_playingDisplayId)
    self.m_playingDisplayId = nil
  end
end

function Form_GetSkin:AddEventListeners()
end

function Form_GetSkin:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GetSkin:FreshUI()
  if not self.m_curFashionInfo then
    return
  end
  self:FreshLeftFashionInfo()
  self:FreshSkinSpineShow()
end

function Form_GetSkin:FreshLeftFashionInfo()
  if not self.m_curFashionInfo then
    return
  end
  UILuaHelper.SetActive(self.m_img_new, self.m_isNew)
  self.m_txt_hero_nikename_Text.text = self.m_curFashionInfo.m_mFashionTag
  self.m_txt_hero_name_Text.text = self.m_curFashionInfo.m_mFashionName
  self.m_txt_maskinfor_Text.text = self.m_curFashionInfo.m_mFashionDes
end

function Form_GetSkin:FreshSkinSpineShow()
  if not self.m_curFashionInfo then
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
  if self.m_playingDisplayId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId)
    self.m_playingDisplayId = nil
  end
  local voice = self.m_HeroVoice:GetHeroGainVoice(self.m_curFashionInfo.m_CharacterId, self.m_curFashionInfo.m_FashionID)
  if voice and voice ~= "" then
    self.m_playingVoiceStr = voice
    CS.UI.UILuaHelper.StartPlaySFX(voice, nil, function(playingDisplayId)
      self.m_playingDisplayId = playingDisplayId
    end, function()
      self.m_playingDisplayId = nil
    end)
  end
  self:LoadHeroSpine(self.m_curFashionInfo.m_Spine, SpinePlaceCfg.HeroNewSkin, self.m_hero_root)
end

function Form_GetSkin:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
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

function Form_GetSkin:CheckShowSpineAnim()
  if utils.isNull(self.m_curFashionInfo) then
    return
  end
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpineObj = self.m_curHeroSpineObj.spineObj
  if utils.isNull(heroSpineObj) then
    log.error("Form_GetSkin CheckShowSpineAnim is error ")
    return
  end
  UILuaHelper.SpineResetMatParam(heroSpineObj)
  UILuaHelper.SetSpineTimeScale(heroSpineObj, 1)
  if UILuaHelper.CheckIsHaveSpineAnim(heroSpineObj, "idle2") then
    UILuaHelper.SpinePlayAnim(heroSpineObj, 0, "idle2", true)
  else
    UILuaHelper.SpinePlayAnim(heroSpineObj, 0, "idle", true)
  end
  UILuaHelper.SetCanvasGroupAlpha(self.m_hero_root, 1)
  if self.m_showClickTween and self.m_showClickTween:IsPlaying() then
    self.m_showClickTween:Kill()
  end
  self.m_showClickTween = nil
  self.m_showClickTween = Tweening.DOTween.Sequence()
  self.m_showClickTween:AppendInterval(1)
  self.m_showClickTween:OnComplete(function()
    if self.m_img_click and not utils.isNull(self.m_img_click) then
      self.m_img_click:SetActive(true)
    end
  end)
  self.m_showClickTween:SetAutoKill(true)
end

function Form_GetSkin:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_GetSkin:OnImgclickClicked()
  self:CloseForm()
  PushFaceManager:CheckShowNextPopRewardPanel()
  if self.m_closeCallBack then
    self.m_closeCallBack()
    self.m_closeCallBack = nil
  end
end

function Form_GetSkin:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroID = tParam.heroID
  vPackage[#vPackage + 1] = {
    sName = tostring(heroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

ActiveLuaUI("Form_GetSkin", Form_GetSkin)
return Form_GetSkin
