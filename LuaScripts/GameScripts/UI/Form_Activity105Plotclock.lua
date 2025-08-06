local Form_Activity105Plotclock = class("Form_Activity105Plotclock", require("UI/UIFrames/Form_Activity105PlotclockUI"))
local Mathf = CS.UnityEngine.Mathf

function Form_Activity105Plotclock:SetInitParam(param)
end

function Form_Activity105Plotclock:AfterInit()
  self.super.AfterInit(self)
  self.m_root_trans = self.m_csui.m_uiGameObject.transform
  local btnExtern = self.m_btn_touch:GetComponent("ButtonExtensions")
  if btnExtern then
    btnExtern.BeginDrag = handler(self, self.OnBeginDrag)
    btnExtern.Drag = handler(self, self.OnDrag)
  end
  self.m_width = self.m_btn_touch:GetComponent("RectTransform").rect.width / 2
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
end

function Form_Activity105Plotclock:OnBeginDrag(pointerEventData)
  self.bIsDragging = true
  self.m_beginDragPos = pointerEventData.position
  local mousePos = CS.UnityEngine.Input.mousePosition
  mousePos = self.m_groupCam:ScreenToWorldPoint(mousePos)
  self.angleOffset = self:GetAngle(mousePos) - self.m_img_clockneedle.transform.eulerAngles.z
  self.m_lastAngel = 360
end

function Form_Activity105Plotclock:OnActive()
  self.super.OnActive(self)
  if self.m_csui.m_param then
    self.onCloseCallBack = self.m_csui.m_param.finishFc
  end
  self.m_isFinish = false
  self.m_pnl_tips:SetActive(false)
  self.m_img_clockneedle:SetActive(true)
  self.m_tipsTimer = TimeService:SetTimer(5, 1, function()
    if not utils.isNull(self.m_pnl_tips) then
      self.m_pnl_tips:SetActive(true)
    end
  end)
end

function Form_Activity105Plotclock:OnDrag(pointerEventData)
  if self.bIsDragging and not self.m_isFinish then
    local mousePos = CS.UnityEngine.Input.mousePosition
    mousePos = self.m_groupCam:ScreenToWorldPoint(mousePos)
    local targetAngle = self:GetAngle(mousePos) - self.angleOffset
    if 45 < targetAngle and targetAngle < 90 then
      self.m_img_clockneedle.transform.rotation = CS.UnityEngine.Quaternion.Euler(0, 0, targetAngle)
    elseif 90 <= targetAngle and targetAngle < 180 and targetAngle > self.m_lastAngel then
      self.m_isFinish = true
      if not utils.isNull(self.m_pnl_tips) then
        self.m_pnl_tips:SetActive(false)
      end
      self.m_img_clockneedle:SetActive(false)
      UILuaHelper.PlayAnimationByName(self.m_root_trans, "clockneedle_out")
      TimeService:SetTimer(2, 1, function()
        self:CloseForm()
      end)
    end
    self.m_lastAngel = targetAngle
  end
end

function Form_Activity105Plotclock:GetAngle(mousePos)
  local direction = mousePos - self.m_clockneedle_glow.transform.position
  direction:Normalize()
  local angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg
  return (angle + 360) % 360
end

function Form_Activity105Plotclock:OnInactive()
  self.super.OnInactive(self)
  if self.m_tipsTimer then
    TimeService:KillTimer(self.m_tipsTimer)
    self.m_tipsTimer = nil
  end
  if self.onCloseCallBack then
    self.onCloseCallBack()
  end
end

function Form_Activity105Plotclock:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity105Plotclock", Form_Activity105Plotclock)
return Form_Activity105Plotclock
