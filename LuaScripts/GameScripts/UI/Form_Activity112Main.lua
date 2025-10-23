local Form_Activity112Main = class("Form_Activity112Main", require("UI/UIFrames/Form_Activity112MainUI"))

function Form_Activity112Main:SetInitParam(param)
end

function Form_Activity112Main:AfterInit()
  self.super.AfterInit(self)
  self.sChangeGachaAniName1 = "Activity112Main_GachaBtn_Switch1"
  self.sChangeGachaAniName2 = "Activity112Main_GachaBtn_Switch2"
  self.iBottomIconIndex = 1
  self.iTopIconIndex = 3
end

function Form_Activity112Main:OnActive()
  self.super.OnActive(self)
  HeroActivityManager:CheckShowEnterAnim(self.m_csui.m_uiGameObject, "Form_Activity112Main_ShowAni", "Activity112Main_in_DailyFirstOpen", "Activity112Main_in", 429)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(426)
end

function Form_Activity112Main:OnInactive()
  self.super.OnInactive(self)
  UILuaHelper.SetChildIndex(self.m_img_top_icon01, 3)
  UILuaHelper.SetChildIndex(self.m_img_bom_icon01, 1)
  UILuaHelper.ResetAnimationByName(self.m_DoubleGacha, "Activity112Main_GachaBtn_Switch1")
end

function Form_Activity112Main:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity112Main:OnBtnconvertClicked()
  self:ChangeGachaUI()
end

local fullscreen = true
ActiveLuaUI("Form_Activity112Main", Form_Activity112Main)
return Form_Activity112Main
