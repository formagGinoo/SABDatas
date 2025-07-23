local Form_Activity101Lamia_DialogueCollection = class("Form_Activity101Lamia_DialogueCollection", require("UI/UIFrames/Form_Activity101Lamia_DialogueCollectionUI"))

function Form_Activity101Lamia_DialogueCollection:SetInitParam(param)
end

function Form_Activity101Lamia_DialogueCollection:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity101Lamia_DialogueCollection:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(97)
end

function Form_Activity101Lamia_DialogueCollection:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity101Lamia_DialogueCollection:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity101Lamia_DialogueCollection:OnStoryItemClk(index)
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
          formStr = "Form_Activity101Lamia_DialogueCollection"
          formUIID = UIDefines.ID_FORM_ACTIVITY101LAMIA_DIALOGUECOLLECTION
        end
        StackFlow:Push(formUIID, {activityID = activityID, activitySubID = activitySubID})
        if backFun then
          backFun(formStr)
        end
      end
    end, true)
  end)
end

ActiveLuaUI("Form_Activity101Lamia_DialogueCollection", Form_Activity101Lamia_DialogueCollection)
return Form_Activity101Lamia_DialogueCollection
