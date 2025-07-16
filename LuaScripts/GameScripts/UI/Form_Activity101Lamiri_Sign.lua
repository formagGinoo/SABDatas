local Form_Activity101Lamiri_Sign = class("Form_Activity101Lamiri_Sign", require("UI/UIFrames/Form_Activity101Lamiri_SignUI"))

function Form_Activity101Lamiri_Sign:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(94)
  local sub_config = HeroActivityManager:GetSubInfoByID(self.sub_id)
  self.m_txt_actity_title_Text.text = sub_config.m_mActivityTitle
  self.m_txt_actity_desc1_Text.text = sub_config.m_mDes
end

function Form_Activity101Lamiri_Sign:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamiri_Sign", Form_Activity101Lamiri_Sign)
return Form_Activity101Lamiri_Sign
