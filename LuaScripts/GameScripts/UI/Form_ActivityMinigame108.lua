local Form_ActivityMinigame108 = class("Form_ActivityMinigame108", require("UI/UIFrames/Form_ActivityMinigame108UI"))

function Form_ActivityMinigame108:SetInitParam(param)
end

local CupType = {
  JIN = 1,
  YIN = 2,
  TONG = 3,
  NONE = 4
}

function Form_ActivityMinigame108:AfterInit()
  self.super.AfterInit(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.main_id = tParam.main_id
  self.sub_id = tParam.sub_id
  self.nowDifficulty = 1
  self.levelTb = ConfigManager:GetConfigInsByName("MiniGame108Level")
  self.levelConfigsAll = self.levelTb:GetValue_BySubActID(1086)
  self.difficulty1 = {}
  self.difficulty2 = {}
  self.difficulty3 = {}
  for k, v in pairs(self.levelConfigsAll) do
    if v.m_DifficultyID == 1 then
      table.insert(self.difficulty1, v)
    elseif v.m_DifficultyID == 2 then
      table.insert(self.difficulty2, v)
    elseif v.m_DifficultyID == 3 then
      table.insert(self.difficulty3, v)
    end
  end
  self.difficulty1UnlockTime = self.difficulty1[1]
  self.difficulty2UnlockTime = self.difficulty2[1]
  self.difficulty3UnlockTime = self.difficulty3[1]
  self.difficulty2Unlock = false
  self.difficulty3Unlock = false
  self.TabEnabled = true
  self.levelCfgs = {}
  self:UpdateLevelDatas()
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  if goBackBtnRoot then
    self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome))
  end
  self:addEventListener("eGameEvent_ActMinigame_Finish", function()
    self:FreshContent()
  end)
end

function Form_ActivityMinigame108:UpdateLevelDatas()
  for i = 1, 6 do
    local cfgele = self.levelTb:GetValue_BySubActIDAndLevelID(self.sub_id, i .. "00" .. self.nowDifficulty)
    self.levelCfgs[i] = cfgele
  end
end

function Form_ActivityMinigame108:IsUnlockDiffcult(cfg)
  local open_time = 0
  if cfg.m_OpenTime and cfg.m_OpenTime ~= "" then
    open_time = TimeUtil:TimeStringToTimeSec2(cfg.m_OpenTime) or 0
  end
  local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
    id = self.main_id,
    m_MemoryID = cfg.m_LevelID
  })
  if is_corved then
    open_time = t1
  end
  local cur_time = TimeUtil:GetServerTimeS()
  local unlock = open_time <= cur_time
  return unlock
end

function Form_ActivityMinigame108:FreshContent()
  for i = 1, 6 do
    local theone = self["m_minigame108_leve" .. i]
    local btn = theone.transform:Find("btn_leve").gameObject:GetComponent(T_Button)
    local btnTxt = theone.transform:Find("btn_leve/txt_leve_name"):GetComponent("TMPPro")
    local cups = {}
    for j = 1, 3 do
      local cup = theone.transform:Find("btn_leve/img_icon_cup" .. j)
      cups[j] = cup
      UILuaHelper.SetActive(cup, false)
    end
    local cup_type = self:GetCup(i, self.levelCfgs[i].m_LevelID)
    if cup_type ~= CupType.NONE then
      UILuaHelper.SetActive(cups[cup_type], true)
    end
    btnTxt.text = ConfigManager:GetCommonTextById("2037" .. i - 1)
    btn.onClick:RemoveAllListeners()
    UILuaHelper.BindButtonClickManual(self, btn, function()
      self:OpenPopInfo(i)
    end)
  end
end

function Form_ActivityMinigame108:GetCup(i, level_id)
  local score = self.server_gameScore[level_id]
  if not score then
    return CupType.NONE
  end
  local resultGroup = utils.changeCSArrayToLuaTable(self.levelCfgs[i].m_ResultGroup)
  if score <= resultGroup[1] then
    return CupType.JIN
  elseif score <= resultGroup[2] then
    return CupType.YIN
  elseif score <= resultGroup[3] then
    return CupType.TONG
  else
    return CupType.TONG
  end
end

function Form_ActivityMinigame108:OnActive()
  local id = self.sub_id
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(300)
  self.anim = self.m_rootTrans:GetComponent(T_Animation)
  local act_data = HeroActivityManager:GetHeroActData(self.main_id)
  if act_data then
    self.server_gameStat = act_data.server_data.stMiniGame.mGameStat
    self.server_gameScore = act_data.server_data.stMiniGame.mGameScore
  end
  local difficult_unlock = 1
  self.m_pnl_lock1:SetActive(false)
  if self:IsUnlockDiffcult(self.difficulty2UnlockTime) == true then
    self.m_pnl_lock2:SetActive(false)
    self.difficulty2Unlock = true
    difficult_unlock = 2
  end
  if self:IsUnlockDiffcult(self.difficulty3UnlockTime) == true then
    self.m_pnl_lock3:SetActive(false)
    self.difficulty3Unlock = true
    difficult_unlock = 3
  end
  self:RegisterOrUpdateRedDotItem(self.m_img_redpoint, RedDotDefine.ModuleType.HeroActMiniGameTask, {
    actId = self.main_id,
    whackMoleTaskId = HeroActivityManager:GetSubFuncID(self.main_id, HeroActivityManager.SubActTypeEnum.GameTask)
  })
  LocalDataManager:SetIntSimple("Activity_MiniGame_Red_Point" .. self.main_id .. "_" .. self.sub_id .. "_1", 1)
  self:RefreshRedPoint()
  self:broadcastEvent("eGameEvent_MiniGame_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.MiniGame108,
    count = 1
  })
  self:FreshContent()
end

function Form_ActivityMinigame108:RefreshRedPoint()
  self.m_level_redpoint1:SetActive(false)
  self.m_level_redpoint2:SetActive(self:IsUnlockDiffcult(self.difficulty2UnlockTime) and LocalDataManager:GetIntSimple("Activity_MiniGame_Red_Point" .. self.main_id .. "_" .. self.sub_id .. "_2", 0) == 0)
  self.m_level_redpoint3:SetActive(self:IsUnlockDiffcult(self.difficulty3UnlockTime) and LocalDataManager:GetIntSimple("Activity_MiniGame_Red_Point" .. self.main_id .. "_" .. self.sub_id .. "_3", 0) == 0)
end

function Form_ActivityMinigame108:OnBtnleve1Clicked()
  self.nowDifficulty = 1
  UILuaHelper.PlayAnimationByName(self.anim, "Minigame108Main_in_cut")
  self:UpdateLevelDatas()
  self:FreshContent()
  self.m_pnl_mask1:SetActive(false)
  self.m_pnl_mask2:SetActive(true)
  self.m_pnl_mask3:SetActive(true)
  GlobalManagerIns:TriggerWwiseBGMState(377)
end

function Form_ActivityMinigame108:OnBtnleve2Clicked()
  if self.difficulty2Unlock then
    self.nowDifficulty = 2
    UILuaHelper.PlayAnimationByName(self.anim, "Minigame108Main_in_cut")
    self:UpdateLevelDatas()
    self:FreshContent()
    self.m_pnl_mask1:SetActive(true)
    self.m_pnl_mask2:SetActive(false)
    self.m_pnl_mask3:SetActive(true)
    LocalDataManager:SetIntSimple("Activity_MiniGame_Red_Point" .. self.main_id .. "_" .. self.sub_id .. "_2", 1)
    self:RefreshRedPoint()
  else
    local open_time = self:GetLevelUnlockTime(self.difficulty2UnlockTime)
    local cur_time = TimeUtil:GetServerTimeS()
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, string.gsubNumberReplace(ConfigManager:GetCommonTextById(20368), TimeUtil:SecondsToFormatCNStr3(open_time - cur_time)))
  end
  GlobalManagerIns:TriggerWwiseBGMState(377)
end

function Form_ActivityMinigame108:OnBtnleve3Clicked()
  if self.difficulty3Unlock then
    self.nowDifficulty = 3
    UILuaHelper.PlayAnimationByName(self.anim, "Minigame108Main_in_cut")
    self:UpdateLevelDatas()
    self:FreshContent()
    self.m_pnl_mask1:SetActive(true)
    self.m_pnl_mask2:SetActive(true)
    self.m_pnl_mask3:SetActive(false)
    LocalDataManager:SetIntSimple("Activity_MiniGame_Red_Point" .. self.main_id .. "_" .. self.sub_id .. "_3", 1)
    self:RefreshRedPoint()
  else
    local open_time = self:GetLevelUnlockTime(self.difficulty3UnlockTime)
    local cur_time = TimeUtil:GetServerTimeS()
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, string.gsubNumberReplace(ConfigManager:GetCommonTextById(20368), TimeUtil:SecondsToFormatCNStr3(open_time - cur_time)))
  end
  GlobalManagerIns:TriggerWwiseBGMState(377)
end

function Form_ActivityMinigame108:CheckCanClick()
  self.TabEnabled = false
  if self.timer then
    TimeService:KillTimer(self.timer)
  end
  self.timer = TimeService:SetTimer(0.5, 1, function()
    self.TabEnabled = true
  end)
end

function Form_ActivityMinigame108:GetLevelUnlockTime(cfg)
  local open_time = 0
  if cfg.m_OpenTime and cfg.m_OpenTime ~= "" then
    open_time = TimeUtil:TimeStringToTimeSec2(cfg.m_OpenTime) or 0
  end
  local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
    id = self.main_id,
    m_MemoryID = cfg.m_LevelID
  })
  if is_corved then
    open_time = t1
  end
  return open_time
end

function Form_ActivityMinigame108:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActivityMinigame108:OpenPopInfo(index)
  local levelCfg = self.levelCfgs[index]
  if levelCfg then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITYMINIGAME108_POP, {
      id = index,
      main_id = self.main_id,
      sub_id = self.sub_id,
      data = levelCfg
    })
  end
end

function Form_ActivityMinigame108:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityMinigame108:OnBackClk()
  self:CloseForm()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(360)
end

function Form_ActivityMinigame108:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackPopup:PopAll()
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_ActivityMinigame108:OnBtnhelpClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITYMINIGAME108GUIDE)
end

function Form_ActivityMinigame108:OnBtnitemClicked()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.main_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.main_id, HeroActivityManager.SubActTypeEnum.GameTask)
  })
end

function Form_ActivityMinigame108:OnBtnstrengthClicked()
  utils.popUpDirectionsUI({
    tipsID = 1181,
    func1 = function()
    end
  })
end

function Form_ActivityMinigame108:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ActivityMinigame108", Form_ActivityMinigame108)
return Form_ActivityMinigame108
