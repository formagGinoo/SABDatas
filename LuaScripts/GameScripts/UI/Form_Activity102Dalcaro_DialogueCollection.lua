local Form_Activity102Dalcaro_DialogueCollection = class("Form_Activity102Dalcaro_DialogueCollection", require("UI/UIFrames/Form_Activity102Dalcaro_DialogueCollectionUI"))

function Form_Activity102Dalcaro_DialogueCollection:SetInitParam(param)
end

function Form_Activity102Dalcaro_DialogueCollection:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity102Dalcaro_DialogueCollection:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(124)
end

function Form_Activity102Dalcaro_DialogueCollection:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity102Dalcaro_DialogueCollection:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity102Dalcaro_DialogueCollection:OnStoryItemClk(index)
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
  BattleFlowManager:EnterShowPlot(levelCfg.m_LevelID, mapID, function(backFun)
    GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
      if isSuc then
        local subCfg = HeroActivityManager:GetSubInfoByID(activitySubID)
        local formStr = "Form_Hall"
        local formUIID = UIDefines.ID_FORM_HALL
        if subCfg == nil then
          formStr = "Form_Hall"
          formUIID = UIDefines.ID_FORM_HALL
        else
          formStr = "Form_Activity102Dalcaro_DialogueCollection"
          formUIID = UIDefines.ID_FORM_ACTIVITY102DALCARO_DIALOGUECOLLECTION
        end
        StackFlow:Push(formUIID, {activityID = activityID, activitySubID = activitySubID})
        if backFun then
          backFun(formStr)
        end
      end
    end, true)
  end)
end

function Form_Activity102Dalcaro_DialogueCollection:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_Activity102Dalcaro_DialogueCollection", Form_Activity102Dalcaro_DialogueCollection)
return Form_Activity102Dalcaro_DialogueCollection
