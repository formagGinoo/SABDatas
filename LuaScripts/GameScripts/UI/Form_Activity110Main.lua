local Form_Activity110Main = class("Form_Activity110Main", require("UI/UIFrames/Form_Activity110MainUI"))

function Form_Activity110Main:SetInitParam(param)
end

function Form_Activity110Main:AfterInit()
  self.super.AfterInit(self)
  self.sChangeGachaAniName1 = "Activity110Main_GachaBtn_switch1"
  self.sChangeGachaAniName2 = "Activity110Main_GachaBtn_switch2"
end

function Form_Activity110Main:OnActive()
  self.super.OnActive(self)
  HeroActivityManager:CheckShowEnterAnim(self.m_csui.m_uiGameObject, "Form_Activity110Main_ShowAni", "Activity110Main_in_DailyFirstOpen", "Activity110Main_in", 417)
  self:RegisterOrUpdateRedDotItem(self.m_minigame_redpoint, RedDotDefine.ModuleType.MiniGame110Entry, self.act_id)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(415)
end

function Form_Activity110Main:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity110Main:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity110Main:OnBtnconvertClicked()
  self:ChangeGachaUI()
end

function Form_Activity110Main:OnBtnheroClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.act_id
  })
end

function Form_Activity110Main:OnBtnminigameClicked()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame)
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity110Main", Form_Activity110Main)
return Form_Activity110Main
