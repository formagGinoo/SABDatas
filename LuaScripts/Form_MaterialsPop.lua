local Form_MaterialsPop = class("Form_MaterialsPop", require("UI/UIFrames/Form_MaterialsPopUI"))
local GoblinLevelIns = ConfigManager:GetConfigInsByName("GoblinLevel")
local ResultConditionTypeIns = ConfigManager:GetConfigInsByName("ResultConditionType")

function Form_MaterialsPop:SetInitParam(param)
end

function Form_MaterialsPop:AfterInit()
  self.super.AfterInit(self)
  self.m_curBattleWorldCfg = nil
  self.m_curLevelID = nil
  self.m_levelCfg = nil
  self.m_levelType = nil
  self.m_curSubLevelType = nil
  self.m_monsterLv = nil
  self.m_levelGoblinHelper = LevelManager:GetLevelGoblinHelper()
end

function Form_MaterialsPop:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_MaterialsPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_MaterialsPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MaterialsPop:AddEventListeners()
  self:addEventListener("eGameEvent_Level_MopUp", handler(self, self.OnLevelMopUp))
  self:addEventListener("eGameEvent_Level_StageDetailFresh", handler(self, self.OnEventDetailFresh))
end

function Form_MaterialsPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_MaterialsPop:OnLevelMopUp(param)
  if not param then
    return
  end
  local levelType = param.levelType
  if levelType == LevelManager.LevelType.Goblin then
    local rewardData = param.rewards
    if rewardData and next(rewardData) then
      utils.popUpRewardUI(rewardData)
    end
  end
end

function Form_MaterialsPop:OnEventDetailFresh()
  self:FreshEnterBattle()
end

function Form_MaterialsPop:ClearData()
end

function Form_MaterialsPop:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curLevelID = tParam.levelID
  local levelCfg = GoblinLevelIns:GetValue_ByLevelID(self.m_curLevelID)
  self.m_levelCfg = levelCfg
  self.m_levelType = self.m_levelCfg.m_LevelType
  self.m_curSubLevelType = self.m_levelCfg.m_LevelSubType
end

function Form_MaterialsPop:FreshUI()
  if not self.m_levelCfg then
    return
  end
  self:FreshLevelInfo()
  self:FreshEnterBattle()
end

function Form_MaterialsPop:FreshLevelInfo()
  local levelCfg = self.m_levelCfg
  local mapID = levelCfg.m_MapID
  self.m_curBattleWorldCfg = ConfigManager:GetBattleWorldCfgById(mapID)
  self.m_monsterLv = levelCfg.m_Difficulty or 0
  local levelNameStr = levelCfg.m_mName or ""
  self.m_txt_title_Text.text = levelNameStr or ""
  self.m_txt_rounddesc_Text.text = levelNameStr or ""
  self.m_txt_round_Text.text = ConfigManager:BattleWorldMaxRound(self.m_curBattleWorldCfg) or 0
  local levelDesc = levelCfg.m_mDesc or ""
  self.m_txt_levelDesc_Text.text = levelDesc
  self:FreshLevelTypeTag()
end

function Form_MaterialsPop:FreshLevelTypeTag()
  if not self.m_curBattleWorldCfg then
    return
  end
  local resultConditionType = ConfigManager:BattleWorldResultConditionType(self.m_curBattleWorldCfg)
  local resultConditionCfg = ResultConditionTypeIns:GetValue_ByConditionTypeID(resultConditionType)
  if resultConditionCfg:GetError() then
    return
  end
  local resultTypePath = resultConditionCfg.m_ConditionTypeMark
  local resultNote = resultConditionCfg.m_mNote
  UILuaHelper.SetAtlasSprite(self.m_img_type_Image, resultTypePath)
  self.m_txt_type_Text.text = resultNote
end

function Form_MaterialsPop:FreshEnterBattle()
  if not self.m_curLevelID then
    return
  end
  local isHavePassOne = self.m_levelGoblinHelper:IsLevelDailyHavePassOne(self.m_curLevelID)
  local isHaveTimes, curTimes, maxTimes = self.m_levelGoblinHelper:IsSubLevelHaveTimes(LevelManager.GoblinSubType.Skill)
  local leftTimes = maxTimes - (curTimes or 0)
  self.m_txt_enterBattle_num_normal_Text.text = leftTimes .. "/" .. maxTimes
  self.m_txt_enterBattle_num_grey_Text.text = leftTimes .. "/" .. maxTimes
  local isNormalEnterBattle = isHaveTimes
  local isQuickEnterBattle = isHaveTimes and isHavePassOne
  UILuaHelper.SetActive(self.m_btn_EnterBattle, isNormalEnterBattle)
  UILuaHelper.SetActive(self.m_btn_EnterBattleGrey, not isNormalEnterBattle)
  UILuaHelper.SetActive(self.m_btn_FastBattle, isQuickEnterBattle)
  UILuaHelper.SetActive(self.m_btn_FastBattleGrey, not isQuickEnterBattle)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_enterBattleLeftTimeNode)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_enterBattleLeftTimeNodeGrey)
end

function Form_MaterialsPop:OnBtnIconReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_MaterialsPop:OnBtnEnemyClicked()
  StackPopup:Push(UIDefines.ID_FORM_LEVELMONSTERPREVIEW, {
    battleWorldID = self.m_curBattleWorldCfg.m_MapID,
    monsterLv = self.m_monsterLv
  })
end

function Form_MaterialsPop:OnBtnFastBattleClicked()
  if not self.m_levelType then
    return
  end
  LevelManager:ReqStageMopUp(self.m_levelType, self.m_curLevelID, 1)
end

function Form_MaterialsPop:OnBtnFastBattleGreyClicked()
  local isHaveTimes = self.m_levelGoblinHelper:IsSubLevelHaveTimes(LevelManager.GoblinSubType.Skill)
  if not isHaveTimes then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40010)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40011)
  end
end

function Form_MaterialsPop:OnBtnEnterBattleClicked()
  if not self.m_curLevelID then
    return
  end
  BattleFlowManager:StartEnterBattle(self.m_levelType, self.m_curLevelID)
end

function Form_MaterialsPop:OnBtnEnterBattleGreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40010)
end

function Form_MaterialsPop:OnBtnRewardClicked()
  if not self.m_levelCfg then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_MATERIALSREWARDPOP, {
    rewardGroupID = self.m_levelCfg.m_RewardGroupID
  })
end

function Form_MaterialsPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_MaterialsPop", Form_MaterialsPop)
return Form_MaterialsPop
