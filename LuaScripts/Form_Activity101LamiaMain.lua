local Form_Activity101LamiaMain = class("Form_Activity101LamiaMain", require("UI/UIFrames/Form_Activity101LamiaMainUI"))
local BG_Prefab = "ui_panel_activity_bg101lamia"

function Form_Activity101LamiaMain:SetInitParam(param)
end

function Form_Activity101LamiaMain:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(58)
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, "Lamia_main_in")
  self.m_aniloopTimer = TimeService:SetTimer(aniLen, 1, function()
    if self.m_csui then
      UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Lamia_main_loop")
    end
  end)
  GlobalManagerIns:TriggerWwiseBGMState(93)
end

function Form_Activity101LamiaMain:OnInactive()
  self.super.OnInactive(self)
  if self.m_aniloopTimer then
    TimeService:KillTimer(self.m_aniloopTimer)
  end
end

function Form_Activity101LamiaMain:OnBtnheroClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_BUFFHEROLIST, {
    activityID = self.act_id
  })
end

ActiveLuaUI("Form_Activity101LamiaMain", Form_Activity101LamiaMain)
return Form_Activity101LamiaMain
