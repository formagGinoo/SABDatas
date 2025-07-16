local Form_Activity103Luoleilai_BuffHeroList = class("Form_Activity103Luoleilai_BuffHeroList", require("UI/UIFrames/Form_Activity103Luoleilai_BuffHeroListUI"))

function Form_Activity103Luoleilai_BuffHeroList:SetInitParam(param)
end

function Form_Activity103Luoleilai_BuffHeroList:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity103Luoleilai_BuffHeroList:OnActive()
  self.super.OnActive(self)
end

function Form_Activity103Luoleilai_BuffHeroList:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity103Luoleilai_BuffHeroList:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity103Luoleilai_BuffHeroList", Form_Activity103Luoleilai_BuffHeroList)
return Form_Activity103Luoleilai_BuffHeroList
