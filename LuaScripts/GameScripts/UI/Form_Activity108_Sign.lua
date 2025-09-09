local Form_Activity108_Sign = class("Form_Activity108_Sign", require("UI/UIFrames/Form_Activity108_SignUI"))

function Form_Activity108_Sign:SetInitParam(param)
end

function Form_Activity108_Sign:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnSignItemClick)
  }
  self.m_luaSignItemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "HeroActivity/UIAct103SignItem", initGridData)
end

function Form_Activity108_Sign:OnActive()
  self.super.OnActive(self)
end

function Form_Activity108_Sign:OnActiveTransitionDone()
end

function Form_Activity108_Sign:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity108_Sign:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity108_Sign:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity108_Sign", Form_Activity108_Sign)
return Form_Activity108_Sign
