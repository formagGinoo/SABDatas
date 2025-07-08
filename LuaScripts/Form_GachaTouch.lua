local Form_GachaTouch = class("Form_GachaTouch", require("UI/UIFrames/Form_GachaTouchUI"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local ItemIns = ConfigManager:GetConfigInsByName("Item")
local OutAnimStr = "GachaTouch_out"
local OutAnimStr2 = "GachaTouch_blood_out"
local OutAnimStr3 = "GachaTouch_blood_out2"
local OutLoopAnimStr = "GachaTouch_arrow_loop"

function Form_GachaTouch:SetInitParam(param)
end

function Form_GachaTouch:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self:addActionLongPress(self.m_btn_touch_Button, handler(self, self.LongPressClick), handler(self, self.LongPress))
  self:addTrigger(UIUtil.findLuaBehaviour(self.m_btn_touch.transform), "m_btn_touch", handler(self, self.PressEnter), handler(self, self.PressExit))
  self:addTriggerEnter(UIUtil.findLuaBehaviour(self.m_btn_touch.transform), "m_btn_touch", handler(self, self.PressTriggerEnter), handler(self, self.PressTriggerExit))
  self.m_LongPressCS = self.m_btn_touch.transform:GetComponent("LongPress")
  self.m_pressPing = 0.2
  self.m_touchAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_rootTrans, OutAnimStr)
end

function Form_GachaTouch:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_gachaIdList = tParam.vGachaItem
  self.m_heroDataList = GachaManager:GetHeroDataAndPreLoadVideo(self.m_gachaIdList)
  self:ResetAnimation()
  self.m_touchTime = 0
  self.m_isLongPressClicked = false
  self.m_isOrganStart = false
  self.m_isLongPressShake = false
  self.isJump = true
end

function Form_GachaTouch:OnInactive()
  self.super.OnInactive(self)
  self.m_heroDataList = {}
  self.m_gachaIdList = {}
  self:ResetAnimation()
  self.m_touchTime = 0
  self.m_isLongPressClicked = false
  self.m_isOrganStart = false
  self.m_isLongPressShake = false
  UIUtil.setButtonClickable(self.m_btn_touch_Button, true)
end

function Form_GachaTouch:ResetAnimation()
  self.m_bg_blood:SetActive(false)
  self.m_bg_blood_2:SetActive(false)
  if self.m_bloodAnimTimer then
    TimeService:KillTimer(self.m_bloodAnimTimer)
    self.m_bloodAnimTimer = nil
  end
  UIUtil.setButtonClickable(self.m_btn_touch_Button, true)
end

function Form_GachaTouch:ShowBloodAndJump()
  self.m_bg_blood:SetActive(true)
  self.m_bg_blood_2:SetActive(true)
  UILuaHelper.PlayAnimationByName(self.m_bg_blood, OutAnimStr2)
  UILuaHelper.PlayAnimationByName(self.m_bg_blood_2, OutAnimStr3)
  if self.m_bloodAnimTimer then
    TimeService:KillTimer(self.m_bloodAnimTimer)
    self.m_bloodAnimTimer = nil
  end
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_bg_blood, "GachaTouch_blood_out")
  self.m_bloodAnimTimer = TimeService:SetTimer(animLen, 1, function()
    self:OnBtnjumpClicked()
  end)
end

function Form_GachaTouch:PlayHeroSound()
  for i, v in ipairs(self.m_heroDataList) do
    if v.heroId then
      local cfg = HeroManager:GetHeroConfigByID(v.heroId)
      if cfg.m_Quality >= GlobalConfig.QUALITY_COMMON_ENUM.SSR then
        CS.GlobalManager.Instance:TriggerWwiseBGMState(54)
        self.isJump = false
        return
      end
    end
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(53)
  self.isJump = false
end

function Form_GachaTouch:LongPressClick()
end

function Form_GachaTouch:LongPress()
  self.m_touchTime = self.m_touchTime + self.m_pressPing
  if self.m_touchTime >= 1 and not self.m_isLongPressClicked then
    self.m_isLongPressClicked = true
    CS.GlobalManager.Instance:TriggerWwiseBGMState(48)
  elseif self.m_touchTime >= self.m_touchAnimLen and not self.m_isLongPressShake then
    self.m_isLongPressShake = true
    UILuaHelper.ResetAnimationByName(self.m_rootTrans, OutLoopAnimStr)
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, OutLoopAnimStr)
  end
end

function Form_GachaTouch:PressExit()
  self.m_pressExit = true
  if not self.m_pressTriggerExit then
    if self.m_touchTime <= 1 and self.m_isOrganStart then
      UILuaHelper.PlayAnimationRewindImmediately(self.m_rootTrans, OutAnimStr)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(51)
      self.m_isOrganStart = false
    elseif self.m_touchTime > 1 and self.m_isLongPressClicked then
      UILuaHelper.StopAnimation(self.m_rootTrans)
      UIUtil.setButtonClickable(self.m_btn_touch_Button, false)
      self:ShowBloodAndJump()
      self:PlayHeroSound()
    end
    self.m_touchTime = 0
  end
end

function Form_GachaTouch:PressEnter()
  self.m_touchTime = 0
  CS.GlobalManager.Instance:TriggerWwiseBGMState(46)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(47)
  if self.m_touchTime < 1 and not self.m_isOrganStart then
    self.m_isOrganStart = true
    UILuaHelper.ResetAnimationByName(self.m_rootTrans, OutAnimStr)
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, OutAnimStr)
  end
  self.m_pressTriggerExit = nil
  self.m_pressExit = nil
end

function Form_GachaTouch:PressTriggerEnter()
end

function Form_GachaTouch:PressTriggerExit()
  self.m_pressTriggerExit = true
  if not self.m_pressExit then
    if self.m_touchTime <= 1 and self.m_isOrganStart then
      UILuaHelper.PlayAnimationRewindImmediately(self.m_rootTrans, OutAnimStr)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(51)
      self.m_isOrganStart = false
    elseif self.m_touchTime > 1 and self.m_isLongPressClicked then
      UILuaHelper.StopAnimation(self.m_rootTrans)
      UIUtil.setButtonClickable(self.m_btn_touch_Button, false)
      self:ShowBloodAndJump()
      self:PlayHeroSound()
    end
    self.m_touchTime = 0
  end
end

function Form_GachaTouch:OnBtnjumpClicked()
  if self.m_heroDataList and #self.m_heroDataList > 0 then
    local param = {
      heroDataList = self.m_heroDataList,
      param = self.m_csui.m_param
    }
    StackFlow:Push(UIDefines.ID_FORM_GACHASHOW, param)
    if self.isJump then
      for i, v in ipairs(self.m_heroDataList) do
        if v.heroId then
          local cfg = HeroManager:GetHeroConfigByID(v.heroId)
          if cfg.m_Quality >= GlobalConfig.QUALITY_COMMON_ENUM.SSR then
            StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GACHATOUCH)
            CS.GlobalManager.Instance:TriggerWwiseBGMState(54)
            return
          end
        end
      end
      CS.GlobalManager.Instance:TriggerWwiseBGMState(53)
    end
  end
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GACHATOUCH)
end

function Form_GachaTouch:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_bloodAnimTimer then
    TimeService:KillTimer(self.m_bloodAnimTimer)
    self.m_bloodAnimTimer = nil
  end
  self.m_heroDataList = {}
  self.m_gachaIdList = {}
  self:ResetAnimation()
  self.m_touchTime = 0
  self.m_isLongPressClicked = false
  self.m_isOrganStart = false
  self.m_isLongPressShake = false
end

function Form_GachaTouch:IsFullScreen()
  return true
end

function Form_GachaTouch:GetDownloadResourceExtra(tParam)
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

function Form_GachaTouch:GetDownloadResourceNetworkStatus()
  return DownloadManager.NetworkStatus.Mobile
end

local fullscreen = true
ActiveLuaUI("Form_GachaTouch", Form_GachaTouch)
return Form_GachaTouch
