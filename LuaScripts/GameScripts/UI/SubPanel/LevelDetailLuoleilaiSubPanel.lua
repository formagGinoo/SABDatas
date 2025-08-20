local UISubPanelBase = require("UI/SubPanel/LevelDetailLamiaSubPanel")
local LevelDetailLuoleilaiSubPanel = class("LevelDetailLuoleilaiSubPanel", UISubPanelBase)
local EnterAnimStr = "Dalcaro_dialoguedetial_in"
local OutAnimStr = "Dalcaro_dialoguedetial_out"

function LevelDetailLuoleilaiSubPanel:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function LevelDetailLuoleilaiSubPanel:OnBtnchallengebuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_CHALLENGEHERO, {
    activityID = self.m_activityID
  })
end

function LevelDetailLuoleilaiSubPanel:OnBtnquickClicked()
  if not self.m_curLevelID or not self.m_activityID then
    return
  end
  local isHaveEnough, totalTimes = self:IsHaveEnoughTimes()
  if isHaveEnough ~= true then
    return
  end
  local isChallenge = self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if totalTimes <= 1 or isChallenge then
    LevelHeroLamiaActivityManager:ReqLamiaStageSweep(self.m_activityID, self.m_curLevelID, 1)
  else
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_DIALOGUEFASTPASS, {
      activityID = self.m_activityID,
      subActivityID = self.m_subActivityID,
      levelID = self.m_curLevelID
    })
  end
end

function LevelDetailLuoleilaiSubPanel:CheckShowAnimOut(endFun)
  if self.m_detailOutTimer ~= nil then
    return
  end
  local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_level_panel_detail, OutAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, OutAnimStr)
  if endFun then
    endFun()
  end
  self.m_detailOutTimer = TimeService:SetTimer(detailAnimLen, 1, function()
    self.m_detailOutTimer = nil
  end)
end

return LevelDetailLuoleilaiSubPanel
