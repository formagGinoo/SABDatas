local Form_Activity112_Sign = class("Form_Activity112_Sign", require("UI/UIFrames/Form_Activity112_SignUI"))

function Form_Activity112_Sign:SetInitParam(param)
end

function Form_Activity112_Sign:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnSignItemClick)
  }
  self.m_luaSignItemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "HeroActivity/UIAct103SignItem", initGridData)
end

function Form_Activity112_Sign:OnActive()
  self.super.OnActive(self)
end

function Form_Activity112_Sign:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity112_Sign:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity112_Sign:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity112_Sign", Form_Activity112_Sign)
return Form_Activity112_Sign
