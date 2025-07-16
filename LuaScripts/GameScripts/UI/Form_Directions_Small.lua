local Form_Directions_Small = class("Form_Directions_Small", require("UI/UIFrames/Form_Directions_SmallUI"))
local ConfirmCommonTipsIns = ConfigManager:GetConfigInsByName("ConfirmCommonTips")

function Form_Directions_Small:SetInitParam(param)
end

function Form_Directions_Small:AfterInit()
  self.super.AfterInit(self)
end

function Form_Directions_Small:OnActive()
  self.super.OnActive(self)
  self.m_param = self.m_csui.m_param
  if not self.m_param then
    return
  end
  self:RefreshUI()
end

function Form_Directions_Small:RefreshUI()
  local tipsID = self.m_param.tipsID
  if tipsID and type(tipsID) == "number" then
    local commonTextCfg = ConfirmCommonTipsIns:GetValue_ByID(tipsID)
    if not commonTextCfg:GetError() then
      self.m_txt_content_Text.text = commonTextCfg.m_mcontent or ""
      self.m_txt_title_Text.text = commonTextCfg.m_mtitle or ""
      UIUtil.setContentSizeFitterLayoutVertical(self.m_txt_content)
    end
  end
end

function Form_Directions_Small:OnBtniconreturnClicked()
  StackTop:RemoveUIFromStack(UIDefines.ID_FORM_DIRECTIONS_SMALL)
end

function Form_Directions_Small:IsOpenGuassianBlur()
  return true
end

function Form_Directions_Small:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Directions_Small", Form_Directions_Small)
return Form_Directions_Small
