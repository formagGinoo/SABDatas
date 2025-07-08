local Form_PlayerCenterDelInforPop = class("Form_PlayerCenterDelInforPop", require("UI/UIFrames/Form_PlayerCenterDelInforPopUI"))

function Form_PlayerCenterDelInforPop:SetInitParam(param)
end

function Form_PlayerCenterDelInforPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_PlayerCenterDelInforPop:OnActive()
  self:RefreshUI()
end

function Form_PlayerCenterDelInforPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_PlayerCenterDelInforPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PlayerCenterDelInforPop:RefreshUI()
  self.m_txt_id_num_Text.text = tostring(UserDataManager:GetAccountID())
  self.m_txt_hero_id_Text.text = tostring(RoleManager:GetName())
  self.m_txt_zone_id_Text.text = tostring(UserDataManager:GetZoneID())
  self.m_txt_level_Text.text = tostring(RoleManager:GetLevel())
end

function Form_PlayerCenterDelInforPop:OnBtnsureClicked()
  local accountId = CS.AccountManager.Instance:GetAccountID()
  CS.AccountManager.Instance:RequestCD(function(msdkCDResult)
    if not msdkCDResult then
      return
    end
    if msdkCDResult.resultCode == 0 then
      if msdkCDResult.resultAction == 1 then
        self:CloseForm()
        StackPopup:Push(UIDefines.ID_FORM_PLAYERCENTERDELSUCCESSPOP, {isClamDown = false})
      end
    elseif msdkCDResult.resultAction == 1 then
      self:CloseForm()
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(12006))
    end
  end)
end

function Form_PlayerCenterDelInforPop:OnBtncancelClicked()
  self:CloseForm()
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCENTERPOP)
end

function Form_PlayerCenterDelInforPop:OnBtnReturnClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_PlayerCenterDelInforPop", Form_PlayerCenterDelInforPop)
return Form_PlayerCenterDelInforPop
