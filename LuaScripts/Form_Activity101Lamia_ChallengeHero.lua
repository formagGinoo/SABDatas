local Form_Activity101Lamia_ChallengeHero = class("Form_Activity101Lamia_ChallengeHero", require("UI/UIFrames/Form_Activity101Lamia_ChallengeHeroUI"))
local ActLamiaPowerChaIns = ConfigManager:GetConfigInsByName("ActLamiaPowerCha")

function Form_Activity101Lamia_ChallengeHero:SetInitParam(param)
end

function Form_Activity101Lamia_ChallengeHero:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity101Lamia_ChallengeHero:OnActive()
  self.super.OnActive(self)
end

function Form_Activity101Lamia_ChallengeHero:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity101Lamia_ChallengeHero:OnDestroy()
  self.super.OnDestroy(self)
end

ActiveLuaUI("Form_Activity101Lamia_ChallengeHero", Form_Activity101Lamia_ChallengeHero)
return Form_Activity101Lamia_ChallengeHero
