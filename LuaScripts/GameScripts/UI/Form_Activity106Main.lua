local Form_Activity106Main = class("Form_Activity106Main", require("UI/UIFrames/Form_Activity106MainUI"))

function Form_Activity106Main:SetInitParam(param)
end

function Form_Activity106Main:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity106Main:OnActive()
  self.super.OnActive(self)
  HeroActivityManager:CheckShowEnterAnim(self.m_csui.m_uiGameObject, "Form_Activity106Main_ShowAni", "Activity106Main_in_DailyFirstOpen", "Activity106Main_in", 348)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(345)
end

function Form_Activity106Main:OnInactive()
  self.super.OnInactive(self)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_Activity106Main:OnDestroy()
  self.super.OnDestroy(self)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_Activity106Main:OnBtnheroClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.act_id
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity106Main", Form_Activity106Main)
return Form_Activity106Main
