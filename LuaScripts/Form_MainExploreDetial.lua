local Form_MainExploreDetial = class("Form_MainExploreDetial", require("UI/UIFrames/Form_MainExploreDetialUI"))

function Form_MainExploreDetial:SetInitParam(param)
end

function Form_MainExploreDetial:AfterInit()
  self.super.AfterInit(self)
  self.m_scrollRect = self.m_scrollView:GetComponent("ScrollRect")
end

function Form_MainExploreDetial:OnActive()
  self.super.OnActive(self)
  local config = self.m_csui.m_param.config
  self.m_txt_title_Text.text = config.m_mSubsectionTitle
  self.m_txt_desc_Text.text = config.m_mText
  self.m_scrollRect.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(76)
end

function Form_MainExploreDetial:OnInactive()
  self.super.OnInactive(self)
end

function Form_MainExploreDetial:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MainExploreDetial:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_MainExploreDetial", Form_MainExploreDetial)
return Form_MainExploreDetial
