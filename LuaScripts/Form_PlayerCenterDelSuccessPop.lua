local Form_PlayerCenterDelSuccessPop = class("Form_PlayerCenterDelSuccessPop", require("UI/UIFrames/Form_PlayerCenterDelSuccessPopUI"))

function Form_PlayerCenterDelSuccessPop:SetInitParam(param)
end

function Form_PlayerCenterDelSuccessPop:AfterInit()
  self.super.AfterInit(self)
  self.calmDownTime = 0
  self.initTimer = nil
  self.endTime = 0
end

function Form_PlayerCenterDelSuccessPop:OnActive()
  self:RefreshUI()
end

function Form_PlayerCenterDelSuccessPop:OnInactive()
  if self.initTimer then
    TimeService:KillTimer(self.initTimer)
    self.initTimer = nil
  end
  self.calmDownTime = 0
  self.endTime = 0
end

function Form_PlayerCenterDelSuccessPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PlayerCenterDelSuccessPop:RefreshUI()
  CS.AccountManager.Instance:RequestCDStatus(function(msdkAccountCDResult)
    if not msdkAccountCDResult then
      return
    end
    if msdkAccountCDResult.resultCode == 0 then
      if msdkAccountCDResult.resultAction == 0 then
        self.calmDownTime = msdkAccountCDResult.msdkAccountCDStatus.period_left
        self.endTime = self.calmDownTime + TimeUtil:GetServerTimeS()
      end
    elseif msdkAccountCDResult.resultAction == 0 then
      log.error("查询冷静期失败")
    end
  end)
  if self.initTimer then
    TimeService:KillTimer(self.initTimer)
    self.initTimer = nil
  end
  if self.calmDownTime >= 0 then
    local cfgText = UILuaHelper.GetCommonText(100101)
    self.m_txt_infor_Text.text = string.gsubNumberReplace(cfgText, TimeUtil:TimeTableToFormatCNStrMax(self.calmDownTime))
    self.initTimer = TimeService:SetTimer(1, -1, function()
      local time = self.endTime - TimeUtil:GetServerTimeS()
      if time <= 0 then
        if self.initTimer then
          local content = string.gsubNumberReplace(cfgText, TimeUtil:TimeTableToFormatCNStrMax(0))
          self.m_txt_infor_Text.text = content
          TimeService:KillTimer(self.initTimer)
          self.initTimer = nil
        end
        return
      end
      local content = string.gsubNumberReplace(cfgText, TimeUtil:TimeTableToFormatCNStrMax(time))
      self.m_txt_infor_Text.text = content
    end)
  end
end

function Form_PlayerCenterDelSuccessPop:OnBtnCloseClicked()
end

function Form_PlayerCenterDelSuccessPop:OnBtnReturnClicked()
  ApplicationManager:RestartGame()
end

function Form_PlayerCenterDelSuccessPop:OnBtncancelClicked()
  CS.AccountManager.Instance:CancelCD(function(msdkCDResult)
    if not msdkCDResult then
      return
    end
    if msdkCDResult.resultCode == 0 then
      if msdkCDResult.resultAction == 2 then
        self:CloseForm()
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(12007))
      end
    elseif msdkCDResult.resultAction == 2 then
    end
  end)
end

function Form_PlayerCenterDelSuccessPop:OnBtnsureClicked()
  if self.m_csui.m_param.isClamDown then
    ApplicationManager:RestartGame()
    return
  end
  utils.popUpDirectionsUI({
    tipsID = 1028,
    func1 = function()
      CS.ApplicationManager.Instance:RestartGame()
    end
  })
end

local fullscreen = true
ActiveLuaUI("Form_PlayerCenterDelSuccessPop", Form_PlayerCenterDelSuccessPop)
return Form_PlayerCenterDelSuccessPop
