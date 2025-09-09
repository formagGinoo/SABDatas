local Form_Activity108_DialogueCollection = class("Form_Activity108_DialogueCollection", require("UI/UIFrames/Form_Activity108_DialogueCollectionUI"))

function Form_Activity108_DialogueCollection:SetInitParam(param)
end

function Form_Activity108_DialogueCollection:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity108_DialogueCollection:OnActive()
  self.super.OnActive(self)
end

function Form_Activity108_DialogueCollection:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity108_DialogueCollection:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity108_DialogueCollection:OnStoryItemClk(index)
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
    activityID,
    levelCfg.m_LevelID
  }, function(backFun)
    local subCfg = HeroActivityManager:GetSubInfoByID(activitySubID)
    local formStr = "Form_Hall"
    local formUIID = UIDefines.ID_FORM_HALL
    if subCfg == nil then
      formStr = "Form_Hall"
      formUIID = UIDefines.ID_FORM_HALL
    else
      formStr = "Form_Activity108_DialogueCollection"
      formUIID = UIDefines.ID_FORM_ACTIVITY108_DIALOGUECOLLECTION
    end
    self:OnBackLobby(backFun, formStr, formUIID)
  end)
end

local fullscreen = true
ActiveLuaUI("Form_Activity108_DialogueCollection", Form_Activity108_DialogueCollection)
return Form_Activity108_DialogueCollection
