local Form_PopupUnlock = class("Form_PopupUnlock", require("UI/UIFrames/Form_PopupUnlockUI"))
local SystemUnlockConfigInstance = ConfigManager:GetConfigInsByName("SystemUnlock")

function Form_PopupUnlock:SetInitParam(param)
end

function Form_PopupUnlock:AfterInit()
  self.super.AfterInit(self)
end

function Form_PopupUnlock:OnActive()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  local config = SystemUnlockConfigInstance:GetValue_BySystemID(tParam)
  if config then
    self.m_txt_title_Text.text = tostring(config.m_mName)
    ResourceUtil:CreateIconByPath(self.m_icon_system_open_Image, config.m_UnlockIcon)
  else
    log.error("can not GetValue_BySystemID " .. tostring(tParam))
  end
  UnlockManager:ReqSetClientData(self.m_csui.m_param)
  GlobalManagerIns:TriggerWwiseBGMState(26)
end

function Form_PopupUnlock:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_POPUPUNLOCK)
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_PopupUnlock:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_PopupUnlock", Form_PopupUnlock)
return Form_PopupUnlock
