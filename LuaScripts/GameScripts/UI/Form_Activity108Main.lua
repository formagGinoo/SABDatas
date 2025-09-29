local Form_Activity108Main = class("Form_Activity108Main", require("UI/UIFrames/Form_Activity108MainUI"))

function Form_Activity108Main:SetInitParam(param)
end

function Form_Activity108Main:AfterInit()
  Form_Activity108Main.super.AfterInit(self)
  self.sChangeGachaAniName1 = "Activity108Main_GachaBtn_switch1"
  self.sChangeGachaAniName2 = "Activity108Main_GachaBtn_switch2"
end

function Form_Activity108Main:OnActive()
  Form_Activity108Main.super.OnActive(self)
  HeroActivityManager:CheckShowEnterAnim(self.m_csui.m_uiGameObject, "Form_Activity108Main_ShowAni", "Activity108_Main_in_DailyFirstOpen", "Activity108_Main_in", 368)
  self:RegisterOrUpdateRedDotItem(self.m_challenge_redpointhammersiren, RedDotDefine.ModuleType.MiniGame108, self.act_id)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(360)
end

function Form_Activity108Main:OnInactive()
  Form_Activity108Main.super.OnInactive(self)
  UILuaHelper.SetChildIndex(self.m_img_top_icon01, 2)
  UILuaHelper.SetChildIndex(self.m_img_bom_icon01, 0)
  UILuaHelper.ResetAnimationByName(self.m_DoubleGacha, "Activity108Main_GachaBtn_switch1")
end

function Form_Activity108Main:OnDestroy()
  Form_Activity108Main.super.OnDestroy(self)
end

function Form_Activity108Main:OnBtnconvertClicked()
  self:ChangeGachaUI()
end

function Form_Activity108Main:OnBtnhammersirenClicked()
  local sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame)
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame)
  })
end

function Form_Activity108Main:OnBtnheroClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.act_id
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity108Main", Form_Activity108Main)
return Form_Activity108Main
