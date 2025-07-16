local Form_Activity103Luoleilai_DialogueCollection = class("Form_Activity103Luoleilai_DialogueCollection", require("UI/UIFrames/Form_Activity103Luoleilai_DialogueCollectionUI"))

function Form_Activity103Luoleilai_DialogueCollection:SetInitParam(param)
end

function Form_Activity103Luoleilai_DialogueCollection:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity103Luoleilai_DialogueCollection:OnActive()
  self.super.OnActive(self)
  self.m_img_pictureframe01:SetActive(not self.m_bIsSecondHalf)
  self.m_img_pictureframe02:SetActive(self.m_bIsSecondHalf)
end

function Form_Activity103Luoleilai_DialogueCollection:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity103Luoleilai_DialogueCollection:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity103Luoleilai_DialogueCollection:OnStoryItemClk(index)
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
      formStr = "Form_Activity103Luoleilai_DialogueCollection"
      formUIID = UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_DIALOGUECOLLECTION
    end
    self:OnBackLobby(backFun, formStr, formUIID)
  end)
end

function Form_Activity103Luoleilai_DialogueCollection:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity103Luoleilai_DialogueCollection", Form_Activity103Luoleilai_DialogueCollection)
return Form_Activity103Luoleilai_DialogueCollection
