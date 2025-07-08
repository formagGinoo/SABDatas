local Form_Screen_Click = class("Form_Screen_Click", require("UI/UIFrames/Form_Screen_ClickUI"))

function Form_Screen_Click:SetInitParam(param)
end

function Form_Screen_Click:AfterInit()
  self.super.AfterInit(self)
end

function Form_Screen_Click:OnActive()
  self.super.OnActive(self)
  local sce = self.m_screen_click_effect_obj:GetComponent("ScreenClickEffect")
  if not sce then
    sce = self.m_screen_click_effect_obj:AddComponent(typeof(CS.UI.ScreenClickEffect))
    if sce then
      sce.screenEffect = self.m_common_touch_fx
      if CS.GMCommandPoster.Enable then
        sce.mouseButtonCallBack = handler(self, self.OnMouseEvent)
      end
    end
  end
end

function Form_Screen_Click:OnUpdate(dt)
  if self.popCountDown then
    if not CS.UnityEngine.Input.GetMouseButton(0) then
      self.popCountDown = nil
      return
    end
    local t = math.min(dt, 0.03)
    self.popCountDown = self.popCountDown - t
    if self.popCountDown <= 0 then
      local offset = CS.UnityEngine.Input.mousePosition - self.mousePos
      self.popCountDown = nil
      StackTop:Push(UIDefines.ID_FORM_GMTOOLS)
    end
  end
end

function Form_Screen_Click:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Screen_Click:OnMouseEvent(eventType)
  if eventType == 0 then
    if CS.BattleGlobalManager.Instance.IsMainCity then
      self.popCountDown = 3
    else
      self.popCountDown = nil
    end
    self.mousePos = CS.UnityEngine.Input.mousePosition
  elseif eventType == 1 then
    self.popCountDown = nil
  end
end

local fullscreen = true
ActiveLuaUI("Form_Screen_Click", Form_Screen_Click)
return Form_Screen_Click
