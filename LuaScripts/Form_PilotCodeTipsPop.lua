local Form_PilotCodeTipsPop = class("Form_PilotCodeTipsPop", require("UI/UIFrames/Form_PilotCodeTipsPopUI"))

function Form_PilotCodeTipsPop:SetInitParam(param)
end

function Form_PilotCodeTipsPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_PilotCodeTipsPop:OnActive()
  self.super.OnActive(self)
end

function Form_PilotCodeTipsPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_PilotCodeTipsPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PilotCodeTipsPop:OnBtnapplyClicked()
  if SDKUtil.HasBindingWithThirdParty() then
    utils.CheckAndPushCommonTips()
    StackPopup:RemoveUIFromStack(self:GetID())
    return
  end
  StackPopup:RemoveUIFromStack(self:GetID())
  SDKUtil.GetTransferCode(function(codeResult)
    if codeResult.resultCode == 0 and codeResult.msdkAccountTransferCode and codeResult.msdkAccountTransferCode.transferCodeStatus == 4 then
      local apply = {
        type = "apply",
        transferCode = codeResult.msdkAccountTransferCode.transferCode
      }
      StackPopup:Push(UIDefines.ID_FORM_PILOTCODEPOP, apply)
    else
      SDKUtil.CreateTransferCode(function(isSuccess, result)
        local apply = {
          type = "apply",
          transferCode = result.msdkAccountTransferCode.transferCode
        }
        if isSuccess then
          StackPopup:Push(UIDefines.ID_FORM_PILOTCODEPOP, apply)
        end
      end)
    end
  end)
end

function Form_PilotCodeTipsPop:OnBtnReturnClicked()
  StackPopup:RemoveUIFromStack(self:GetID())
end

local fullscreen = true
ActiveLuaUI("Form_PilotCodeTipsPop", Form_PilotCodeTipsPop)
return Form_PilotCodeTipsPop
