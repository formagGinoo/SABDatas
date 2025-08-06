local Form_Activity105Minigame_Main = class("Form_Activity105Minigame_Main", require("UI/UIFrames/Form_Activity105Minigame_MainUI"))
local iMaxLevelNum = 5

function Form_Activity105Minigame_Main:SetInitParam(param)
end

function Form_Activity105Minigame_Main:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil)
  self.m_minigameHelper = HeroActivityManager:GetMinigameHelper()
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.vLevelUnlockState = {}
  self.StateEnum = {
    Normal = 0,
    Lock = 1,
    Passed = 2
  }
end

function Form_Activity105Minigame_Main:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:RefreshUI()
end

function Form_Activity105Minigame_Main:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity105Minigame_Main:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity105Minigame_Main:InitData()
  local params = self.m_csui.m_param
  if params then
    self.iActId = params.main_id
    self.iSubActId = params.sub_id
    params = nil
  end
end

function Form_Activity105Minigame_Main:RefreshUI()
  local vAllLegacyStageCfg = self.m_minigameHelper:GetSubActMiniGameAllLegacyStageCfg(self.iSubActId)
  self.iCurLevelId = self.m_minigameHelper:GetCurLevelCfg(self.iActId, self.iSubActId)
  for i = 1, iMaxLevelNum do
    local cfg = vAllLegacyStageCfg[i]
    if cfg then
      self:RefreshLevelItem(i, cfg)
    end
  end
  if self.iCurLevelId and HeroActivityManager:IsTodayEnterMinigamePuzzle(self.iCurLevelId) then
    LocalDataManager:SetIntSimple("HeroActMiniGamePuzzle_Entry_Red_Point_" .. self.iCurLevelId, TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()), true)
  end
  local flag = self.m_minigameHelper:IsMiniGamePuzzleRewardCanGet(self.iActId, self.iSubActId)
  self.m_puzzle_redpoint:SetActive(flag)
end

function Form_Activity105Minigame_Main:RefreshLevelItem(iIndex, cfg)
  if not cfg then
    log.error("Form_Activity105Minigame_Main RefreshLevelItem error! iIndex:" .. tostring(iIndex))
    return
  end
  local act_data = HeroActivityManager:GetHeroActData(self.iActId)
  if not act_data then
    return
  end
  local stMiniGame = act_data.server_data.stMiniGame
  local bIsUnlock = true
  local iUnlockLevel = cfg.m_UnlockLevel
  local iPreLevel = cfg.m_OderLevel
  local bIsPass = stMiniGame.mGameStat[cfg.m_LevelID] == 1
  bIsPass = bIsPass and LegacyLevelManager:IsLevelHavePass(cfg.m_LevelID)
  if iUnlockLevel and 0 < iUnlockLevel then
    bIsUnlock = self.m_levelHelper:IsLevelHavePass(iUnlockLevel)
  end
  bIsUnlock = iPreLevel and 0 < iPreLevel and bIsUnlock and stMiniGame.mGameStat[iPreLevel] == 1 and LegacyLevelManager:IsLevelHavePass(iPreLevel)
  if cfg.m_OpenTime and cfg.m_OpenTime ~= "" then
    local open_time = TimeUtil:TimeStringToTimeSec2(cfg.m_OpenTime) or 0
    local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
      id = self.iActId,
      m_MemoryID = cfg.m_LevelID
    })
    if is_corved then
      open_time = t1
    end
    local cur_time = TimeUtil:GetServerTimeS()
    local is_in_time = open_time <= cur_time
    bIsUnlock = bIsUnlock and is_in_time
  end
  self.vLevelUnlockState[iIndex] = bIsUnlock
  local iState = self.StateEnum.Normal
  if not bIsUnlock then
    iState = self.StateEnum.Lock
  elseif bIsPass then
    iState = self.StateEnum.Passed
  end
  self["m_img_lock0" .. iIndex]:SetActive(iState == self.StateEnum.Lock)
  self["m_img_bg_clear0" .. iIndex]:SetActive(iState == self.StateEnum.Passed)
  self["m_img_bg_normal0" .. iIndex]:SetActive(iState == self.StateEnum.Normal)
  self["m_txt_levelnum0" .. iIndex .. "_Text"].text = cfg.m_mLevelNum
  self["m_txt_levelname0" .. iIndex .. "_Text"].text = cfg.m_mLevelName
  self["m_img_select_arror0" .. iIndex]:SetActive(self.iCurLevelId == cfg.m_LevelID)
  local mulColor = self["m_txt_levelnum0" .. iIndex]:GetComponent("MultiColorChange")
  mulColor:SetColorByIndex(iState)
end

function Form_Activity105Minigame_Main:OnBtnLevelClicked(iIndex)
  local vAllLegacyStageCfg = self.m_minigameHelper:GetSubActMiniGameAllLegacyStageCfg(self.iSubActId)
  local cfg = vAllLegacyStageCfg[iIndex]
  if not cfg then
    return
  end
  if self.vLevelUnlockState[iIndex] then
    BattleFlowManager:StartEnterBattle(LegacyLevelManager.LevelType.LegacyLevel, cfg.m_LevelID)
    self.m_minigameHelper:SetCurLevelInfo(self.iActId, self.iSubActId, cfg.m_LevelID)
  else
    local levelCfg = LevelHeroLamiaActivityManager:GetLevelHelper():GetLevelCfgByID(cfg.m_UnlockLevel)
    local unlockStr = HeroActivityManager:GetMinigameUnlockStr(levelCfg, cfg.m_LevelID)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, unlockStr)
  end
end

function Form_Activity105Minigame_Main:OnBtnenter01Clicked()
  self:OnBtnLevelClicked(1)
end

function Form_Activity105Minigame_Main:OnBtnenter02Clicked()
  self:OnBtnLevelClicked(2)
end

function Form_Activity105Minigame_Main:OnBtnenter03Clicked()
  self:OnBtnLevelClicked(3)
end

function Form_Activity105Minigame_Main:OnBtnenter04Clicked()
  self:OnBtnLevelClicked(4)
end

function Form_Activity105Minigame_Main:OnBtnenter05Clicked()
  self:OnBtnLevelClicked(5)
end

function Form_Activity105Minigame_Main:OnBtninfo01Clicked()
  self:OnClickInfoBtn(1)
end

function Form_Activity105Minigame_Main:OnBtninfo02Clicked()
  self:OnClickInfoBtn(2)
end

function Form_Activity105Minigame_Main:OnBtninfo03Clicked()
  self:OnClickInfoBtn(3)
end

function Form_Activity105Minigame_Main:OnBtninfo04Clicked()
  self:OnClickInfoBtn(4)
end

function Form_Activity105Minigame_Main:OnBtninfo05Clicked()
  self:OnClickInfoBtn(5)
end

function Form_Activity105Minigame_Main:OnClickInfoBtn(iIndex)
  local vAllLegacyStageCfg = self.m_minigameHelper:GetSubActMiniGameAllLegacyStageCfg(self.iSubActId)
  local cfg = vAllLegacyStageCfg[iIndex]
  if not cfg then
    return
  end
  local LegacyStageLevelInfoIns = ConfigManager:GetConfigInsByName("LegacyStageLevelInfo")
  local tempCfg = LegacyStageLevelInfoIns:GetValue_ByLevelID(cfg.m_LevelID)
  if not tempCfg:GetError() then
    StackFlow:Push(UIDefines.ID_FORM_LEGACYACTIVITYCUBEPOP, {levelCfg = tempCfg})
  end
end

function Form_Activity105Minigame_Main:OnBackClk()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.iActId
  })
  self:CloseForm()
end

function Form_Activity105Minigame_Main:OnBtnpuzzleClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY105MINIGAME_PUZZLE, {
    main_id = self.iActId,
    sub_id = self.iSubActId
  })
end

function Form_Activity105Minigame_Main:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity105Minigame_Main", Form_Activity105Minigame_Main)
return Form_Activity105Minigame_Main
