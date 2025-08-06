local Form_Activity105_Sign = class("Form_Activity105_Sign", require("UI/UIFrames/Form_Activity105_SignUI"))

function Form_Activity105_Sign:SetInitParam(param)
end

function Form_Activity105_Sign:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnSignItemClick)
  }
  self.m_luaSignItemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "HeroActivity/UIAct103SignItem", initGridData)
end

function Form_Activity105_Sign:OnActive()
  self.super.OnActive(self)
end

function Form_Activity105_Sign:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity105_Sign:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity105_Sign:LoadShowSpine()
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  if not self.m_signinSpineName then
    return
  end
  self:CheckRecycleSpine()
  self.m_HeroSpineDynamicLoader:GetObjectByName(self.m_signinSpineName, function(nameStr, object)
    self:CheckRecycleSpine()
    UILuaHelper.SetParent(object, self.m_root_hero, true)
    UILuaHelper.SetActive(object, true)
    UILuaHelper.SpineResetMatParam(object)
    self.m_curHeroSpineObj = object
    UILuaHelper.SpinePlayAnim(self.m_curHeroSpineObj, 0, "idle2")
  end)
end

local fullscreen = true
ActiveLuaUI("Form_Activity105_Sign", Form_Activity105_Sign)
return Form_Activity105_Sign
