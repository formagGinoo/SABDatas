local Form_WhackMoleBattleResult = class("Form_WhackMoleBattleResult", require("UI/UIFrames/Form_WhackMoleBattleResultUI"))

function Form_WhackMoleBattleResult:SetInitParam(param)
end

function Form_WhackMoleBattleResult:AfterInit()
  self.super.AfterInit(self)
end

function Form_WhackMoleBattleResult:OnActive()
  self.super.OnActive(self)
  if self.m_csui.m_param then
    self.m_battleResult = self.m_csui.m_param
    self.m_csui.m_param = nil
  end
  self:RefreshUI()
end

function Form_WhackMoleBattleResult:OnInactive()
  self.super.OnInactive(self)
end

function Form_WhackMoleBattleResult:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_WhackMoleBattleResult:RefreshUI()
  if self.m_battleResult then
    local curLevelCfg = HeroActivityManager:GetActWhackMoleInfoCfgByIDAndLevelId(self.m_battleResult.curSubActId, self.m_battleResult.curLevelId)
    local isWin = self.m_battleResult.isWin or false
    if isWin then
      HeroActivityManager:ReqHeroActMiniGameFinishCS(self.m_battleResult.iActId, curLevelCfg.m_SubActID, curLevelCfg.m_LevelID)
    end
    UILuaHelper.SetActive(self.m_VictoryPanel, isWin)
    UILuaHelper.SetActive(self.m_DefeatPanel, not isWin)
    self.m_txt_victoryContent_Text.text = tostring(self.m_battleResult.curScore)
    if curLevelCfg.m_VictoryCondition and curLevelCfg.m_VictoryCondition ~= 0 then
      self.m_txt_defeatScore_Text.text = tostring(self.m_battleResult.curScore) .. "/" .. curLevelCfg.m_VictoryCondition
    end
    if curLevelCfg.m_Mode == HeroActivityManager.WhackMoleLevelType.NormalType and not isWin and curLevelCfg then
      self.m_txt_defeatScore_Text.text = tostring(self.m_battleResult.curScore) .. "/" .. tostring(curLevelCfg.m_VictoryCondition)
    end
    if curLevelCfg.m_Mode == HeroActivityManager.WhackMoleLevelType.BossType then
    end
    if curLevelCfg.m_Mode == HeroActivityManager.WhackMoleLevelType.InfinityType then
      self.m_txt_defeatScore_Text.text = tostring(self.m_battleResult.curScore)
    end
  end
end

local fullscreen = true
ActiveLuaUI("Form_WhackMoleBattleResult", Form_WhackMoleBattleResult)
return Form_WhackMoleBattleResult
