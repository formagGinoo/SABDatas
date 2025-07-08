local Form_Activity102Dalcaro_BuffHeroList = class("Form_Activity102Dalcaro_BuffHeroList", require("UI/UIFrames/Form_Activity102Dalcaro_BuffHeroListUI"))

function Form_Activity102Dalcaro_BuffHeroList:SetInitParam(param)
end

function Form_Activity102Dalcaro_BuffHeroList:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity102Dalcaro_BuffHeroList:OnActive()
  self.super.OnActive(self)
end

function Form_Activity102Dalcaro_BuffHeroList:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity102Dalcaro_BuffHeroList:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity102Dalcaro_BuffHeroList", Form_Activity102Dalcaro_BuffHeroList)
return Form_Activity102Dalcaro_BuffHeroList
