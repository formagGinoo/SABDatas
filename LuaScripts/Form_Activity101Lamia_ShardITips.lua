local Form_Activity101Lamia_ShardITips = class("Form_Activity101Lamia_ShardITips", require("UI/UIFrames/Form_Activity101Lamia_ShardITipsUI"))

function Form_Activity101Lamia_ShardITips:SetInitParam(param)
end

function Form_Activity101Lamia_ShardITips:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity101Lamia_ShardITips:OnActive()
  self.super.OnActive(self)
  local params = self.m_csui.m_param
  CS.GlobalManager.Instance:TriggerWwiseBGMState(147)
  self.m_pnl_error:SetActive(params.is_error)
  self.m_pnl_right:SetActive(not params.is_error)
  self.call_back = params.call_back
  if params.is_error then
    self.m_txt_error_Text.text = params.tip_str
    if params.is_time then
      self.m_txt_error2_Text.text = ConfigManager:GetCommonTextById(100088)
    else
      self.m_txt_error2_Text.text = ConfigManager:GetCommonTextById(100090)
    end
  else
    self.m_txt_right_Text.text = params.tip_str
    if params.is_time then
      self.m_txt_right2_Text.text = ConfigManager:GetCommonTextById(100089)
    else
      self.m_txt_right2_Text.text = ConfigManager:GetCommonTextById(100091)
    end
  end
end

function Form_Activity101Lamia_ShardITips:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity101Lamia_ShardITips:OnBtnCloseClicked()
  if self.call_back then
    self.call_back()
    self.call_back = nil
  end
  self:CloseForm()
end

function Form_Activity101Lamia_ShardITips:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_ShardITips", Form_Activity101Lamia_ShardITips)
return Form_Activity101Lamia_ShardITips
