local Form_Activity106_Sign = class("Form_Activity106_Sign", require("UI/UIFrames/Form_Activity106_SignUI"))

function Form_Activity106_Sign:SetInitParam(param)
end

function Form_Activity106_Sign:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnSignItemClick)
  }
  self.m_luaSignItemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "HeroActivity/UIAct103SignItem", initGridData)
  self.m_reward_list:SetActive(false)
end

function Form_Activity106_Sign:OnActive()
  self.m_reward_list:SetActive(false)
  Form_Activity106_Sign.super.OnActive(self)
  self.fDelayShowItemListAnim = 0.08
  self.fDelayShowItem = 0.05
end

function Form_Activity106_Sign:OnActiveTransitionDone()
  self:CheckShowEnterAnim()
end

function Form_Activity106_Sign:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity106_Sign:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity106_Sign", Form_Activity106_Sign)
return Form_Activity106_Sign
