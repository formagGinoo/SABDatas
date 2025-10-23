local Form_LoungeGuide_Typhoeus = class("Form_LoungeGuide_Typhoeus", require("UI/UIFrames/Form_LoungeGuide_TyphoeusUI"))

function Form_LoungeGuide_Typhoeus:AfterInit()
  self.super.AfterInit(self)
  self._guild_points = {
    head = self.m_head,
    body = self.m_body,
    breast_l = self.m_breast_l,
    breast_r = self.m_breast_r,
    leg_l = self.m_leg_l,
    leg_r = self.m_leg_r,
    box = self.m_box,
    gold = self.m_gold,
    perfume_up = self.m_perfume_up,
    perfume_down = self.m_perfume_down
  }
end

function Form_LoungeGuide_Typhoeus:OnActive()
  self.super.OnActive(self)
  local params = self.m_csui.m_param
  if not params then
    return
  end
  self:hideAllGuildPoints()
  for i, v in ipairs(params) do
    local guildPoint = self._guild_points[v]
    if guildPoint then
      UILuaHelper.SetActive(guildPoint, true)
    end
  end
  self.closeTimer = 0
end

function Form_LoungeGuide_Typhoeus:OnInactive()
  self.super.OnInactive(self)
end

function Form_LoungeGuide_Typhoeus:OnUpdate(dt)
  self.closeTimer = self.closeTimer + dt
  if self.closeTimer >= 2 then
    self:OnBtnCloseClicked()
  end
end

function Form_LoungeGuide_Typhoeus:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_LoungeGuide_Typhoeus:hideAllGuildPoints()
  for k, v in pairs(self._guild_points) do
    UILuaHelper.SetActive(v, false)
  end
end

local fullscreen = true
ActiveLuaUI("Form_LoungeGuide_Typhoeus", Form_LoungeGuide_Typhoeus)
return Form_LoungeGuide_Typhoeus
