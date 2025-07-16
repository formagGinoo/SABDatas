local Form_GachaTouchNew = class("Form_GachaTouchNew", require("UI/UIFrames/Form_GachaTouchNewUI"))
local GachaTouchNew_in = "GachaTouchNew_in"
local GachaTouchNew_R_in = "GachaTouchNew_R_in"
local GachaTouchNew_SR_in = "GachaTouchNew_SR_in"
local GachaTouchNew_SSR_in = "GachaTouchNew_SSR_in"
local SpineAnimQ1 = "q1"
local SpineAnimQ2 = "q2"
local SpineAnimQ3 = "q3"

function Form_GachaTouchNew:SetInitParam(param)
end

function Form_GachaTouchNew:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
end

function Form_GachaTouchNew:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_gachaIdList = tParam.vGachaItem
  self.m_heroDataList = GachaManager:GetHeroDataAndPreLoadVideo(self.m_gachaIdList)
  self.m_highQuality = self:GetGachaHeroMaxQuality()
  self.m_gachaSequnceList = {}
  local str = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Gacha) or ""
  if str == GachaManager.FirstGachaStr then
    self:ShowAnim()
  end
  self:AddEventListeners()
end

function Form_GachaTouchNew:OnInactive()
  self.super.OnInactive(self)
  self.m_heroDataList = {}
  self.m_gachaIdList = {}
  self:RemoveAllEventListeners()
  for i = #self.m_gachaSequnceList, 1, -1 do
    if not utils.isNull(self.m_gachaSequnceList[i]) then
      self.m_gachaSequnceList[i]:Kill()
      self.m_gachaSequnceList[i] = nil
    end
  end
end

function Form_GachaTouchNew:AddEventListeners()
  self:addEventListener("eGameEvent_VideoFinish", handler(self, self.OnVideoFinish))
end

function Form_GachaTouchNew:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GachaTouchNew:OnVideoFinish(videoName)
  if videoName == "Gacha_Video_01" then
    self:ShowAnim()
  end
end

function Form_GachaTouchNew:ShowAnim()
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, GachaTouchNew_in)
  self.m_aniRLen = UILuaHelper.GetAnimationLengthByName(self.m_img_new_bg3, GachaTouchNew_R_in)
  self.m_aniSRLen = UILuaHelper.GetAnimationLengthByName(self.m_img_new_bg3, GachaTouchNew_SR_in)
  self.m_aniSSRLen = UILuaHelper.GetAnimationLengthByName(self.m_img_new_bg3, GachaTouchNew_SSR_in)
  if self.m_highQuality == GlobalConfig.QUALITY_COMMON_ENUM.SR then
    self:PlayAnimSR()
    CS.GlobalManager.Instance:TriggerWwiseBGMState(53)
  elseif self.m_highQuality == GlobalConfig.QUALITY_COMMON_ENUM.SSR then
    self:PlayAnimSSR()
    CS.GlobalManager.Instance:TriggerWwiseBGMState(54)
  else
    self:PlayAnimR()
    CS.GlobalManager.Instance:TriggerWwiseBGMState(53)
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(152)
end

function Form_GachaTouchNew:PlayAnimR()
  UILuaHelper.PlayAnimationByName(self.m_img_new_bg3, GachaTouchNew_R_in)
  UILuaHelper.SpinePlayAnim(self.m_spine_act, 0, SpineAnimQ1)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(46)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(self.m_aniRLen)
  sequence:OnComplete(function()
    if not GachaManager:IsSkippedHeroShow() then
      self:GotoNextFlow()
    end
  end)
  sequence:SetAutoKill(true)
  self.m_gachaSequnceList[#self.m_gachaSequnceList + 1] = sequence
end

function Form_GachaTouchNew:PlayAnimSR()
  UILuaHelper.PlayAnimationByName(self.m_img_new_bg3, GachaTouchNew_R_in)
  UILuaHelper.SpinePlayAnim(self.m_spine_act, 0, SpineAnimQ1)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(46)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(self.m_aniRLen)
  sequence:OnComplete(function()
    if not GachaManager:IsSkippedHeroShow() then
      UILuaHelper.PlayAnimationByName(self.m_img_new_bg3, GachaTouchNew_SR_in)
      UILuaHelper.SpinePlayAnim(self.m_spine_act, 0, SpineAnimQ2)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(47)
    end
  end)
  sequence:SetAutoKill(true)
  self.m_gachaSequnceList[#self.m_gachaSequnceList + 1] = sequence
  local sequenceJump = Tweening.DOTween.Sequence()
  sequenceJump:AppendInterval(self.m_aniRLen + self.m_aniSRLen)
  sequenceJump:OnComplete(function()
    if not GachaManager:IsSkippedHeroShow() then
      self:GotoNextFlow()
    end
  end)
  sequenceJump:SetAutoKill(true)
  self.m_gachaSequnceList[#self.m_gachaSequnceList + 1] = sequenceJump
end

function Form_GachaTouchNew:PlayAnimSSR()
  UILuaHelper.PlayAnimationByName(self.m_img_new_bg3, GachaTouchNew_R_in)
  UILuaHelper.SpinePlayAnim(self.m_spine_act, 0, SpineAnimQ1)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(46)
  local sequenceSR = Tweening.DOTween.Sequence()
  sequenceSR:AppendInterval(self.m_aniRLen)
  sequenceSR:OnComplete(function()
    if not GachaManager:IsSkippedHeroShow() then
      UILuaHelper.PlayAnimationByName(self.m_img_new_bg3, GachaTouchNew_SR_in)
      UILuaHelper.SpinePlayAnim(self.m_spine_act, 0, SpineAnimQ2)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(47)
    end
  end)
  sequenceSR:SetAutoKill(true)
  self.m_gachaSequnceList[#self.m_gachaSequnceList + 1] = sequenceSR
  local sequenceSSR = Tweening.DOTween.Sequence()
  sequenceSSR:AppendInterval(self.m_aniRLen + self.m_aniSRLen)
  sequenceSSR:OnComplete(function()
    if not GachaManager:IsSkippedHeroShow() then
      UILuaHelper.PlayAnimationByName(self.m_img_new_bg3, GachaTouchNew_SSR_in)
      UILuaHelper.SpinePlayAnim(self.m_spine_act, 0, SpineAnimQ3)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(48)
    end
  end)
  sequenceSSR:SetAutoKill(true)
  self.m_gachaSequnceList[#self.m_gachaSequnceList + 1] = sequenceSSR
  local sequenceJump = Tweening.DOTween.Sequence()
  sequenceJump:AppendInterval(self.m_aniRLen + self.m_aniSRLen + self.m_aniSSRLen)
  sequenceJump:OnComplete(function()
    if not GachaManager:IsSkippedHeroShow() then
      self:GotoNextFlow()
    end
  end)
  sequenceJump:SetAutoKill(true)
  self.m_gachaSequnceList[#self.m_gachaSequnceList + 1] = sequenceJump
end

function Form_GachaTouchNew:GetGachaHeroMaxQuality()
  local quality = GlobalConfig.QUALITY_COMMON_ENUM.R
  for i, v in ipairs(self.m_heroDataList) do
    if v.heroId then
      local cfg = HeroManager:GetHeroConfigByID(v.heroId)
      if quality < cfg.m_Quality then
        quality = cfg.m_Quality
      end
    end
  end
  return quality
end

function Form_GachaTouchNew:GotoNextFlow()
  if self.m_heroDataList and #self.m_heroDataList > 0 then
    local param = {
      heroDataList = self.m_heroDataList,
      param = self.m_csui.m_param
    }
    StackFlow:Push(UIDefines.ID_FORM_GACHASHOW, param)
  end
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GACHATOUCHNEW)
  self:StopSound()
end

function Form_GachaTouchNew:StopSound()
  CS.GlobalManager.Instance:StopWwiseVoice(46)
  CS.GlobalManager.Instance:StopWwiseVoice(47)
  CS.GlobalManager.Instance:StopWwiseVoice(48)
  CS.GlobalManager.Instance:StopWwiseVoice(53)
  CS.GlobalManager.Instance:StopWwiseVoice(54)
  CS.GlobalManager.Instance:StopWwiseVoice(152)
end

function Form_GachaTouchNew:OnBtnskipClicked()
  GachaManager:SetSkippedHeroShow(true)
  self:GotoNextFlow()
end

function Form_GachaTouchNew:IsFullScreen()
  return true
end

function Form_GachaTouchNew:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local vGachaIdList = tParam.vGachaItem
  for i, v in ipairs(vGachaIdList) do
    vPackage[#vPackage + 1] = {
      sName = tostring(v.iID),
      eType = DownloadManager.ResourcePackageType.Character
    }
  end
  return vPackage, vResourceExtra
end

function Form_GachaTouchNew:GetDownloadResourceNetworkStatus()
  return DownloadManager.NetworkStatus.Mobile
end

function Form_GachaTouchNew:OnDestroy()
  self.super.OnDestroy(self)
  self.m_heroDataList = {}
  self.m_gachaIdList = {}
end

local fullscreen = true
ActiveLuaUI("Form_GachaTouchNew", Form_GachaTouchNew)
return Form_GachaTouchNew
