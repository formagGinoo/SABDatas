local Form_Activity105_DialogueCollection = class("Form_Activity105_DialogueCollection", require("UI/UIFrames/Form_Activity105_DialogueCollectionUI"))

function Form_Activity105_DialogueCollection:SetInitParam(param)
end

function Form_Activity105_DialogueCollection:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity105_DialogueCollection:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(124)
end

function Form_Activity105_DialogueCollection:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity105_DialogueCollection:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity105_DialogueCollection:OnStoryItemClk(index)
  if not index then
    return
  end
  local levelCfg = self.m_storyLevelCfgList[index]
  if not levelCfg then
    return
  end
  local mapID = levelCfg.m_MapID
  local activityID = self.m_activityID
  local activitySubID = self.m_activitySubID
  local levelType = HeroActivityManager:GetLevelTypeByActivityID(activityID)
  BattleFlowManager:EnterShowPlot(levelCfg.m_LevelID, mapID, levelType, {
    self.m_activityID,
    levelCfg.m_LevelID
  }, function(backFun)
    GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
      if isSuc then
        local subCfg = HeroActivityManager:GetSubInfoByID(activitySubID)
        local formStr = "Form_Hall"
        local formUIID = UIDefines.ID_FORM_HALL
        if subCfg == nil then
          formStr = "Form_Hall"
          formUIID = UIDefines.ID_FORM_HALL
        else
          formStr = "Form_Activity105_DialogueCollection"
          formUIID = UIDefines.ID_FORM_ACTIVITY105_DIALOGUECOLLECTION
        end
        StackFlow:Push(formUIID, {activityID = activityID, activitySubID = activitySubID})
        if backFun then
          backFun(formStr)
        end
      end
    end, true)
  end)
end

local fullscreen = true
ActiveLuaUI("Form_Activity105_DialogueCollection", Form_Activity105_DialogueCollection)
return Form_Activity105_DialogueCollection
