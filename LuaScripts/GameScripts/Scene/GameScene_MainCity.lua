local GameSceneBase = require("Scene/GameSceneBase")
local GameScene_MainCity = class("GameScene_MainCity", GameSceneBase)

function GameScene_MainCity:OnEnterScene(iSceneIDPrev)
  self.super.OnEnterScene(self, iSceneIDPrev)
  UILuaHelper.InsertCameraToUIRootStack(nil, 0)
end

function GameScene_MainCity:OnLeaveScene(iSceneIDNext)
  self.super.OnLeaveScene(self, iSceneIDNext)
  UILuaHelper.RemoveCameraFromUIRootStack(nil)
end

return GameScene_MainCity
