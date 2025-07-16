local Form_SkillSpeDescTips = class("Form_SkillSpeDescTips", require("UI/UIFrames/Form_SkillSpeDescTipsUI"))
local tipCfgIns = ConfigManager:GetConfigInsByName("SkillTip")

function Form_SkillSpeDescTips:SetInitParam(param)
end

function Form_SkillSpeDescTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_SkillSpeDescTips:OnActive()
  self.super.OnActive(self)
  local param = self.m_csui.m_param
  if type(param) == "number" or type(param) == "string" then
    local config = tipCfgIns:GetValue_ByID(tonumber(param))
    self.m_txt_title_Text.text = config.m_mName
    self.m_txt_des_Text.text = config.m_mDesc
  elseif type(param) == "table" then
    self.m_txt_title_Text.text = param.title
    self.m_txt_des_Text.text = param.desc
    self.callback = param.callback
  end
end

function Form_SkillSpeDescTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_SkillSpeDescTips:OnBtnmaskClicked()
  self:CloseForm()
  if self.callback then
    self.callback()
    self.callback = nil
  end
end

function Form_SkillSpeDescTips:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_SkillSpeDescTips", Form_SkillSpeDescTips)
return Form_SkillSpeDescTips
