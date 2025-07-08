local Form_BattleBossTips = class("Form_BattleBossTips", require("UI/UIFrames/Form_BattleBossTipsUI"))

function Form_BattleBossTips:SetInitParam(param)
end

function Form_BattleBossTips:AfterInit()
  self.super.AfterInit(self)
  self.m_normal_tips:SetActive(false)
  self.m_warning_tips:SetActive(false)
end

function Form_BattleBossTips:OnActive()
  self.super.OnActive(self)
  local tipsText
  local textId = self.m_csui.m_param[3]
  if 0 < textId then
    tipsText = ConfigManager:GetCommonTextById(textId)
  else
    local SkillIns = ConfigManager:GetConfigInsByName("Skill")
    local skillCfg = SkillIns:GetValue_BySkillID(self.m_csui.m_param[1])
    tipsText = skillCfg.m_mName
  end
  self:InitView(self.m_csui.m_param[0], tipsText)
end

function Form_BattleBossTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_BattleBossTips:OnDestroy()
  GuideManager:RemoveFrameByKey("CloseBattleBossTips")
  self.super.OnDestroy(self)
end

function Form_BattleBossTips:InitView(tipsType, tipsText)
  if tipsType == 1 then
    self.m_txt_warning_Text.text = tipsText
    self.m_normal_tips:SetActive(false)
    self.m_warning_tips:SetActive(true)
    self.closeTime = 4.5
  else
    self.m_txt_normal_Text.text = tipsText
    self.m_normal_tips:SetActive(true)
    self.m_warning_tips:SetActive(false)
    self.closeTime = 3.0
  end
  GuideManager:RemoveFrameByKey("CloseBattleBossTips")
  GuideManager:AddTimer(self.closeTime, handler(self, self.CloseForm), nil, "CloseBattleBossTips")
end

local fullscreen = true
ActiveLuaUI("Form_BattleBossTips", Form_BattleBossTips)
return Form_BattleBossTips
