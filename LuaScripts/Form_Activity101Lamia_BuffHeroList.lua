local Form_Activity101Lamia_BuffHeroList = class("Form_Activity101Lamia_BuffHeroList", require("UI/UIFrames/Form_Activity101Lamia_BuffHeroListUI"))

function Form_Activity101Lamia_BuffHeroList:SetInitParam(param)
end

function Form_Activity101Lamia_BuffHeroList:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity101Lamia_BuffHeroList:OnActive()
  self.super.OnActive(self)
end

function Form_Activity101Lamia_BuffHeroList:OnInactive()
  self.super.OnInactive(self)
end

ActiveLuaUI("Form_Activity101Lamia_BuffHeroList", Form_Activity101Lamia_BuffHeroList)
return Form_Activity101Lamia_BuffHeroList
