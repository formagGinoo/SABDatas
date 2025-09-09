local Form_103Achievement = class("Form_103Achievement", require("UI/UIFrames/Form_103AchievementUI"))

function Form_103Achievement:SetInitParam(param)
end

function Form_103Achievement:AfterInit()
  Form_103Achievement.super.AfterInit(self)
end

function Form_103Achievement:OnActive()
  Form_103Achievement.super.OnActive(self)
end

function Form_103Achievement:OnInactive()
  Form_103Achievement.super.OnInactive(self)
end

function Form_103Achievement:OnDestroy()
  Form_103Achievement.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_103Achievement", Form_103Achievement)
return Form_103Achievement
