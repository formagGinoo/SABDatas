local Form_PersonalRaidNewDifficult = class("Form_PersonalRaidNewDifficult", require("UI/UIFrames/Form_PersonalRaidNewDifficultUI"))

function Form_PersonalRaidNewDifficult:SetInitParam(param)
end

function Form_PersonalRaidNewDifficult:AfterInit()
  self.super.AfterInit(self)
end

function Form_PersonalRaidNewDifficult:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  local curStageCfg = tParam
  if curStageCfg then
    if curStageCfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Normal then
      self.m_txt_num_Text.text = tostring(curStageCfg.m_mName)
    else
      self.m_txt_num_Text.text = ""
    end
    self.m_pnl_unlock:SetActive(curStageCfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Normal)
    self.m_pnl_unlockboss:SetActive(curStageCfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
    if curStageCfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Normal then
      UILuaHelper.PlayAnimationByName(self.m_pnl_unlock, "unlock_in")
    else
      UILuaHelper.PlayAnimationByName(self.m_pnl_unlockboss, "unlockboss_in")
    end
  else
    log.error("can not GetSoloRaidLevelCfgById " .. tostring(tParam))
  end
end

function Form_PersonalRaidNewDifficult:OnInactive()
  self.super.OnInactive(self)
end

function Form_PersonalRaidNewDifficult:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PersonalRaidNewDifficult:OnBtnCloseClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRaidNewDifficult", Form_PersonalRaidNewDifficult)
return Form_PersonalRaidNewDifficult
