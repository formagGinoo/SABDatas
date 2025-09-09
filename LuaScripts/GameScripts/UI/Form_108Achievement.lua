local Form_108Achievement = class("Form_108Achievement", require("UI/UIFrames/Form_108AchievementUI"))

function Form_108Achievement:SetInitParam(param)
end

function Form_108Achievement:AfterInit()
  Form_108Achievement.super.AfterInit(self)
end

function Form_108Achievement:OnActive()
  Form_108Achievement.super.OnActive(self)
end

function Form_108Achievement:OnInactive()
  Form_108Achievement.super.OnInactive(self)
end

function Form_108Achievement:OnDestroy()
  Form_108Achievement.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_108Achievement", Form_108Achievement)
return Form_108Achievement
