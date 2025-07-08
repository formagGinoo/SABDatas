local Form_MainCity = class("Form_MainCity", require("UI/UIFrames/Form_MainCityUI"))

function Form_MainCity:AfterInit()
end

function Form_MainCity:BeforeActive()
  log.info("before active")
end

function Form_MainCity:OnBtnEnterMineLandClicked()
  log.info("Hello , welcome to MUF by xlua")
  CS.SkyLandBattle.BattleLoadingManager.Instance:LoadingToMineLand()
end

function Form_MainCity:OnActive()
end

ActiveLuaUI("Form_MainCity", Form_MainCity)
return Form_MainCity
