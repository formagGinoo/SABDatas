local BaseManager = require("Manager/Base/BaseManager")
local BaseLevelManager = class("BaseLevelManager", BaseManager)

function BaseLevelManager:OnCreate()
end

function BaseLevelManager:OnInitNetwork()
end

function BaseLevelManager:OnAfterFreshData()
end

function BaseLevelManager:OnUpdate(dt)
end

function BaseLevelManager:LoadLevelMapScene(backFun, isHideLoading)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.LevelMap, function(isSuc)
    if isSuc and backFun then
      backFun()
    end
  end, isHideLoading)
end

function BaseLevelManager:GetDownloadResourceExtra()
  return nil, nil
end

function BaseLevelManager:StartEnterBattle(...)
end

function BaseLevelManager:BeforeEnterBattle(...)
end

function BaseLevelManager:GetLevelMapID(...)
end

function BaseLevelManager:GetBattleLoadingUI(...)
  return "Form_BattleLoading"
end

function BaseLevelManager:EnterPVEBattle(mapID)
  BattleFlowManager:ChangeBattleStage(BattleFlowManager.BattleStage.InBattle)
  BattleGlobalManager:EnterPVEBattle(mapID, 0)
end

function BaseLevelManager:OnBattleEnd(isSuc, stageFinishChallengeSc, randomShowHeroID)
end

function BaseLevelManager:OnBackLobby(fCB)
end

function BaseLevelManager:IsInBattle()
  return CS.BattleGlobalManager.Instance.IsMainCity ~= true
end

function BaseLevelManager:ClearCurBattleInfo()
end

function BaseLevelManager:FromBattleToHall()
  self:ClearCurBattleInfo()
  CS.BattleGameManager.Instance:ExitBattle()
end

function BaseLevelManager:ExitBattle()
  CS.BattleGameManager.Instance:ExitBattle()
end

function BaseLevelManager:EnterNextBattle(levelType, levelID)
  CS.BattleGameManager.Instance:HandleExitBattle()
  self:StartEnterBattle(levelType, levelID)
end

function BaseLevelManager:ReStartBattle(isRestartArea)
  CS.BattleGameManager.Instance:ReStartBattle(isRestartArea)
end

return BaseLevelManager
