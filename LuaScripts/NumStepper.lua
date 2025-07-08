local NumStepper = class("NumStepper")
local NumChangeStatus = {
  None = 0,
  Reduce = 1,
  Increase = 2
}
local LongPressBeginTime = 0.8
local LongPressBeginTimeMax = 999
local NumChangeInterval = 0.1

function NumStepper:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_eNumChangeStatus = NumChangeStatus.None
  self.m_fNumChangeTime = 0
  self.m_longPressBeginChangeTime = 0
  self.m_bNumChanged = false
  self.m_bShowMax = false
  self.m_iNumCur = 1
  self.m_iNumMin = 1
  self.m_iNumMax = 1
  self.m_sTag = nil
  self.m_fNumChangeCB = nil
  self.m_btnReduce = self.m_goRoot.transform:Find("btn_reduce").gameObject
  CS.CommonExtensions.AddEventTriggerListener(self.m_btnReduce, CS.UnityEngine.EventSystems.EventTriggerType.PointerDown, handler(self, self.OnBtnReducePointerDown))
  CS.CommonExtensions.AddEventTriggerListener(self.m_btnReduce, CS.UnityEngine.EventSystems.EventTriggerType.PointerUp, handler(self, self.OnBtnReducePointerUp))
  self.m_btnIncrease = self.m_goRoot.transform:Find("btn_increase").gameObject
  CS.CommonExtensions.AddEventTriggerListener(self.m_btnIncrease, CS.UnityEngine.EventSystems.EventTriggerType.PointerDown, handler(self, self.OnBtnIncreasePointerDown))
  CS.CommonExtensions.AddEventTriggerListener(self.m_btnIncrease, CS.UnityEngine.EventSystems.EventTriggerType.PointerUp, handler(self, self.OnBtnIncreasePointerUp))
  self.m_btnMax = self.m_goRoot.transform:Find("btn_max"):GetComponent("Button")
  UILuaHelper.BindButtonClickManual(self, self.m_btnMax, handler(self, self.OnBtnMaxClicked))
  self.m_btnMin = self.m_goRoot.transform:Find("btn_min"):GetComponent("Button")
  UILuaHelper.BindButtonClickManual(self, self.m_btnMin, handler(self, self.OnBtnMinClicked))
  self.m_textNum = self.m_goRoot.transform:Find("img_grade_bg/c_txt_num"):GetComponent(T_TextMeshProUGUI)
  self.m_btnMaxC = self.m_goRoot.transform:Find("btn_max_c").gameObject
  self.m_btnReduceC = self.m_goRoot.transform:Find("btn_reduce_c").gameObject
  self.m_btnIncreaseC = self.m_goRoot.transform:Find("btn_increase_c").gameObject
  self.m_btnMinC = self.m_goRoot.transform:Find("btn_min_c").gameObject
end

function NumStepper:OnUpdate(dt)
  if self.m_eNumChangeStatus ~= NumChangeStatus.None then
    self.m_longPressBeginChangeTime = self.m_longPressBeginChangeTime + dt
    if self.m_longPressBeginChangeTime >= LongPressBeginTime then
      if self.m_longPressBeginChangeTime >= LongPressBeginTimeMax then
        self.m_longPressBeginChangeTime = LongPressBeginTime
      end
      if self.m_eNumChangeStatus == NumChangeStatus.Reduce then
        self.m_fNumChangeTime = self.m_fNumChangeTime + dt
        if self.m_fNumChangeTime >= NumChangeInterval then
          self.m_fNumChangeTime = self.m_fNumChangeTime - NumChangeInterval
          self:UpdateNum(-1)
          self.m_bNumChanged = true
        end
      elseif self.m_eNumChangeStatus == NumChangeStatus.Increase then
        self.m_fNumChangeTime = self.m_fNumChangeTime + dt
        if self.m_fNumChangeTime >= NumChangeInterval then
          self.m_fNumChangeTime = self.m_fNumChangeTime - NumChangeInterval
          self:UpdateNum(1)
          self.m_bNumChanged = true
        end
      end
    end
  end
end

function NumStepper:UpdateNumStr()
  if self.m_bShowMax then
    self.m_textNum.text = self.m_iNumCur .. "/" .. self.m_iNumMax
    if self.m_iNumCur == self.m_iNumMax and self.m_iNumCur == 0 then
      UILuaHelper.SetColor(self.m_textNum, table.unpack(GlobalConfig.COMMON_COLOR.Red))
    else
      UILuaHelper.SetColor(self.m_textNum, table.unpack(GlobalConfig.COMMON_COLOR.Normal))
    end
  else
    self.m_textNum.text = self.m_iNumCur
    UILuaHelper.SetColor(self.m_textNum, table.unpack(GlobalConfig.COMMON_COLOR.Normal))
  end
  self:UpdateBtnState(self.m_iNumCur == self.m_iNumMax, self.m_iNumCur == self.m_iNumMin)
end

function NumStepper:UpdateNum(iNumChange)
  self.m_iNumCur = self.m_iNumCur + iNumChange
  if self.m_iNumCur < self.m_iNumMin then
    self.m_iNumCur = self.m_iNumMin
  elseif self.m_iNumCur > self.m_iNumMax then
    self.m_iNumCur = self.m_iNumMax
  end
  self:UpdateNumStr()
  if self.m_fNumChangeCB then
    self.m_fNumChangeCB(self.m_iNumCur, iNumChange, self.m_sTag)
  end
end

function NumStepper:UpdateBtnState(isMax, isMin)
  local showMax = isMax ~= isMin and isMax or isMax == true and isMin == true
  local showMin = isMax ~= isMin and isMin or isMax == true and isMin == true
  UILuaHelper.SetActive(self.m_btnMaxC, showMax)
  UILuaHelper.SetActive(self.m_btnIncreaseC, showMax)
  UILuaHelper.SetActive(self.m_btnReduceC, showMin)
  UILuaHelper.SetActive(self.m_btnMinC, showMin)
end

function NumStepper:OnBtnReducePointerDown(eventData)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_eNumChangeStatus = NumChangeStatus.Reduce
  self.m_fNumChangeTime = 0
  self.m_longPressBeginChangeTime = 0
  self.m_bNumChanged = false
end

function NumStepper:OnBtnReducePointerUp(eventData)
  if self.m_eNumChangeStatus ~= NumChangeStatus.Reduce then
    return
  end
  self.m_eNumChangeStatus = NumChangeStatus.None
  self.m_fNumChangeTime = 0
  self.m_longPressBeginChangeTime = 0
  if not self.m_bNumChanged then
    if self.m_iNumCur == self.m_iNumMin then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20014)
    end
    self:UpdateNum(-1)
    self.m_bNumChanged = true
  end
end

function NumStepper:OnBtnIncreasePointerDown(eventData)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_eNumChangeStatus = NumChangeStatus.Increase
  self.m_fNumChangeTime = 0
  self.m_longPressBeginChangeTime = 0
  self.m_bNumChanged = false
end

function NumStepper:OnBtnIncreasePointerUp(eventData)
  if self.m_eNumChangeStatus ~= NumChangeStatus.Increase then
    return
  end
  self.m_eNumChangeStatus = NumChangeStatus.None
  self.m_fNumChangeTime = 0
  self.m_longPressBeginChangeTime = 0
  if not self.m_bNumChanged then
    if self.m_iNumCur == self.m_iNumMax then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20013)
    end
    self:UpdateNum(1)
    self.m_bNumChanged = true
  end
end

function NumStepper:OnBtnMaxClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_eNumChangeStatus = NumChangeStatus.None
  if self.m_iNumCur == self.m_iNumMax then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20013)
  end
  local curNum = self.m_iNumCur
  self:SetNumCur(self.m_iNumMax)
  if self.m_fNumChangeCB then
    self.m_fNumChangeCB(self.m_iNumCur, self.m_iNumMax - curNum, self.m_sTag)
  end
end

function NumStepper:OnBtnMinClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_eNumChangeStatus = NumChangeStatus.None
  if self.m_iNumCur == self.m_iNumMin then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20014)
  end
  local curNum = self.m_iNumCur
  self:SetNumCur(self.m_iNumMin)
  if self.m_fNumChangeCB then
    self.m_fNumChangeCB(self.m_iNumCur, self.m_iNumMin - curNum, self.m_sTag)
  end
end

function NumStepper:SetNumCur(iNumCur)
  self.m_iNumCur = iNumCur
  self:UpdateNumStr()
end

function NumStepper:GetCurNum()
  return self.m_iNumCur
end

function NumStepper:SetNumShowMax(bShowMax)
  self.m_bShowMax = bShowMax
end

function NumStepper:SetNumMin(iNumMin)
  self.m_iNumMin = iNumMin
end

function NumStepper:SetNumMax(iNumMax)
  self.m_iNumMax = iNumMax
end

function NumStepper:SetNumChangeCB(fNumChangeCB, sTag)
  self.m_fNumChangeCB = fNumChangeCB
  self.m_sTag = sTag
end

function NumStepper:GetNumCur()
  return self.m_iNumCur
end

function NumStepper:OnDestroy()
end

return NumStepper
