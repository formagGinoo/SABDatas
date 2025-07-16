local Form_EquipmentCopyMain = class("Form_EquipmentCopyMain", require("UI/UIFrames/Form_EquipmentCopyMainUI"))
local MonsterTypeIns = ConfigManager:GetConfigInsByName("MonsterType")
local HeroModifyIns = ConfigManager:GetConfigInsByName("HeroModify")
local FixAddWaitTime = 5
local AnimVideoStr = "equipment_enter"

function Form_EquipmentCopyMain:Init(gameObject, csui)
  self:CheckCreateVariable(csui)
  self:CheckCreateFunctions()
  Form_EquipmentCopyMain.super.Init(self, gameObject, csui)
end

function Form_EquipmentCopyMain:SetInitParam(param)
end

function Form_EquipmentCopyMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1102)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnDungeonRewardItemClick)
  }
  self.m_stageRewardInfinityGrid = self:CreateInfinityGrid(self.m_pnl_stage_reward_InfinityGrid, "UICommonItem", initGridData)
  self.m_stageRewardInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnDungeonRewardItemClick))
  self.m_dungeonStageRewardList = {}
  self.m_equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  self.m_curDungeonChapterCfg = nil
  self.m_curLevelSubType = nil
  self.m_selBossChapterIndex = nil
  self.m_curLevelID = nil
  self.m_curLevelCfg = nil
  self.m_curDungeonLevelPhaseCfgList = nil
  self.m_monsterTypeCfgList = nil
  self.m_failLoadNum = 0
  self.m_UILockID = nil
end

function Form_EquipmentCopyMain:OnActive()
  self:AddEventListeners()
  self:FreshData()
  self.m_failLoadNum = 0
  self:StartShowAnimLock()
  self:CheckShowVideoAndBoss()
  self:FreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(154)
  self:OnFullBurstDayUpdate()
end

function Form_EquipmentCopyMain:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  if self.m_initEnterGuideTimer then
    TimeService:KillTimer(self.m_initEnterGuideTimer)
    self.m_initEnterGuideTimer = nil
  end
  if self.m_waitShowBossTimer then
    TimeService:KillTimer(self.m_waitShowBossTimer)
    self.m_waitShowBossTimer = nil
  end
  self:CheckAnimUnLock()
  self.m_ownerModule:HideAllBossPosAndResetMainCamera(self.m_curLevelSubType)
end

function Form_EquipmentCopyMain:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  if self.m_waitShowBossTimer then
    TimeService:KillTimer(self.m_waitShowBossTimer)
    self.m_waitShowBossTimer = nil
  end
  if self.m_waitShowBossTimer then
    TimeService:KillTimer(self.m_waitShowBossTimer)
    self.m_waitShowBossTimer = nil
  end
  self:CheckAnimUnLock()
end

function Form_EquipmentCopyMain:AddEventListeners()
  self:addEventListener("eGameEvent_Level_MopUp", handler(self, self.OnEventLevelSweep))
  self:addEventListener("eGameEvent_Activity_FullBurstDayUpdate", handler(self, self.OnFullBurstDayUpdate))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
  self:addEventListener("eGameEvent_Level_DailyReset", handler(self, self.OnBossDailyResetRefresh))
end

function Form_EquipmentCopyMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipmentCopyMain:OnBossDailyResetRefresh()
  utils.popUpDirectionsUI({
    tipsID = 1128,
    func1 = function()
      self:OnBackClk()
    end
  })
  self:CheckAnimUnLock()
end

function Form_EquipmentCopyMain:OnFullBurstDayUpdate()
  self.m_doublereward:SetActive(ActivityManager:IsFullBurstDayOpen())
end

function Form_EquipmentCopyMain:OnEventLevelSweep(param)
  if not param then
    return
  end
  local levelType = param.levelType
  local rewardList = param.rewards
  local extraReward = param.extraReward
  if levelType == LevelManager.LevelType.Dungeon then
    local damageNum = self.m_equipmentHelper:GetLevelTopDamageByLevelID(self.m_curLevelCfg.m_LevelID)
    StackFlow:Push(UIDefines.ID_FORM_BOSSBATTLEVICTORY, {
      levelType = levelType,
      levelID = self.m_curLevelID,
      rewardData = rewardList,
      extraReward = extraReward,
      isSweep = true,
      isSim = false,
      showHeroID = nil,
      damageNum = damageNum
    })
    self:FreshStageInfoShow()
    self:FreshButtonsShow()
  end
end

function Form_EquipmentCopyMain:FreshData()
  local tParam = self.m_csui.m_param or {}
  self.m_selBossChapterIndex = tParam.chapterIndex or 1
  local chapterInfo = self.m_equipmentHelper:GetDunChapterByOrderId(self.m_selBossChapterIndex)
  if not chapterInfo then
    return
  end
  self.m_curDungeonChapterCfg = chapterInfo
  self.m_curLevelSubType = chapterInfo.m_LevelSubType
  local levelCfgList = self.m_equipmentHelper:GetDunLevelCfgListByLevelSubType(self.m_curLevelSubType)
  if not levelCfgList or not next(levelCfgList) then
    return
  end
  self.m_curLevelCfg = levelCfgList[1]
  self.m_curLevelID = self.m_curLevelCfg.m_LevelID
  self.m_curDungeonLevelPhaseCfgList = self.m_equipmentHelper:GetDungeonLevelPhaseCfgListByID(self.m_curLevelID)
  self.m_curDamageNum = self.m_equipmentHelper:GetLevelTopDamageByLevelID(self.m_curLevelID)
  self.m_curStageIndex = self.m_equipmentHelper:GetLevelStageByDamage(self.m_curLevelID, self.m_curDamageNum)
end

function Form_EquipmentCopyMain:FreshUI()
  if not self.m_curLevelCfg then
    return
  end
  self:FreshBossInfoShow()
  self:FreshStageInfoShow()
  self:FreshRewardList()
  self:FreshButtonsShow()
end

function Form_EquipmentCopyMain:FreshBossInfoShow()
  if not self.m_curDungeonChapterCfg then
    return
  end
  self.m_txt_boss_name_Text.text = self.m_curDungeonChapterCfg.m_mName
  self.m_txt_boss_information_Text.text = self.m_curDungeonChapterCfg.m_mDesc
  self.m_monsterTypeCfgList = {}
  local monsterTypeIDArray = self.m_curDungeonChapterCfg.m_MonsterTypeID
  local lenNum = monsterTypeIDArray.Length
  for i = 0, lenNum - 1 do
    local tempCfg = MonsterTypeIns:GetValue_ByID(monsterTypeIDArray[i])
    if tempCfg:GetError() ~= true then
      self.m_monsterTypeCfgList[#self.m_monsterTypeCfgList + 1] = tempCfg
    end
  end
  for i = 1, self.m_uiVariables.MaxBossType do
    local monsterTypeCfg = self.m_monsterTypeCfgList[i]
    UILuaHelper.SetActive(self["m_btn_BossType" .. i], monsterTypeCfg ~= nil)
    if monsterTypeCfg then
      UILuaHelper.SetAtlasSprite(self["m_icon_leveltype" .. i .. "_Image"], monsterTypeCfg.m_Icon)
    end
  end
end

function Form_EquipmentCopyMain:FreshStageInfoShow()
  if not self.m_curDungeonLevelPhaseCfgList then
    return
  end
  UILuaHelper.SetActive(self.m_pnl_stagegrey, self.m_curStageIndex <= 0)
  UILuaHelper.SetActive(self.m_pnl_stage, self.m_curStageIndex > 0)
  if self.m_curStageIndex > 0 then
    local tempPhaseCfg = self.m_curDungeonLevelPhaseCfgList[self.m_curStageIndex]
    if tempPhaseCfg then
      self.m_txt_content_Text.text = UIUtil:ArabToRomaNum(tempPhaseCfg.m_Phase)
    end
  end
  for i = 1, self.m_uiVariables.MaxStageNum do
    local tempPhaseCfg = self.m_curDungeonLevelPhaseCfgList[i]
    UILuaHelper.SetActive(self["m_pnl_point" .. i], tempPhaseCfg ~= nil)
    if tempPhaseCfg then
      UILuaHelper.SetActive(self["m_point_finish" .. i], i < self.m_curStageIndex)
      UILuaHelper.SetActive(self["m_point_now" .. i], self.m_curStageIndex == i)
      if i < self.m_uiVariables.MaxStageNum then
        self["m_point_slider" .. i .. "_Image"].fillAmount = i < self.m_curStageIndex and 1 or 0
      end
    end
  end
end

function Form_EquipmentCopyMain:FreshRewardList()
  if not self.m_curDungeonLevelPhaseCfgList then
    return
  end
  local maxPhaseCfg = self.m_curDungeonLevelPhaseCfgList[#self.m_curDungeonLevelPhaseCfgList]
  if not maxPhaseCfg then
    return
  end
  local rewardList = utils.changeCSArrayToLuaTable(maxPhaseCfg.m_ClientMustDrop)
  local proRewardList = utils.changeCSArrayToLuaTable(maxPhaseCfg.m_ClientProDrop)
  local rewardTab = {}
  local customDataTab = {}
  for i, v in ipairs(proRewardList) do
    rewardTab[#rewardTab + 1] = {
      v[1],
      1
    }
    customDataTab[#customDataTab + 1] = {
      percentage = v[2]
    }
  end
  for i, v in ipairs(rewardList) do
    customDataTab[#customDataTab + 1] = {percentage = 100}
  end
  table.insertto(rewardTab, rewardList)
  self.m_dungeonStageRewardList = rewardTab
  local dataList = {}
  for i, v in ipairs(rewardTab) do
    local processData = ResourceUtil:GetProcessRewardData({
      iID = v[1],
      iNum = v[2]
    }, customDataTab[i])
    dataList[#dataList + 1] = processData
  end
  self.m_stageRewardInfinityGrid:ShowItemList(dataList)
end

function Form_EquipmentCopyMain:FreshButtonsShow()
  local maxUseTimes = self.m_equipmentHelper:GetChallengeDailyNum()
  local curUseTimes = self.m_equipmentHelper:GetLevelDailyData()
  local leftTimes = maxUseTimes - curUseTimes
  self.m_txt_Left_Time_Text.text = leftTimes .. "/" .. maxUseTimes
  self.m_txt_Left_Time_Grey_Text.text = leftTimes .. "/" .. maxUseTimes
  UILuaHelper.SetActive(self.m_btn_StartGrey, leftTimes <= 0)
  UILuaHelper.SetActive(self.m_btn_Start, 0 < leftTimes)
  local heroModify = self.m_curLevelCfg.m_HeroModify or 0
  UILuaHelper.SetActive(self.m_pnl_levellock, heroModify ~= 0)
  if heroModify ~= 0 then
    local heroModifyCfg = HeroModifyIns:GetValue_ByID(heroModify)
    if heroModifyCfg:GetError() ~= true then
      self.m_txt_levellock_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(20204), heroModifyCfg.m_ForceLevel)
    end
  end
  UILuaHelper.SetActive(self.m_btn_Quick, 0 < curUseTimes and 0 < leftTimes)
  local finishNum = self.m_equipmentHelper:GetLevelFinishNumByLevelID(self.m_curLevelID)
  UILuaHelper.SetActive(self.m_btn_Quick_Grey, finishNum <= 0 or leftTimes <= 0)
end

function Form_EquipmentCopyMain:CheckAnimUnLock()
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
  self.m_UILockID = nil
end

function Form_EquipmentCopyMain:StartShowAnimLock()
  self:CheckAnimUnLock()
  self.m_UILockID = UILockIns:Lock(self.m_uiVariables.WaitShowBossBackTime + FixAddWaitTime)
end

function Form_EquipmentCopyMain:CheckShowVideoAndBoss()
  if TimeUtil:GetServerTimeS() > LocalDataManager:GetIntSimple("EquipmentBossDailyEnter_" .. self.m_selBossChapterIndex, 0) then
    UILuaHelper.PlayFromAddRes(AnimVideoStr, "", false, function()
      self:ShowBoss()
    end, CS.UnityEngine.ScaleMode.ScaleToFit, false, false, false, true, "DungeonOpen")
  else
    self:ShowBoss()
  end
end

function Form_EquipmentCopyMain:ShowBoss()
  if self.m_failLoadNum >= self.m_uiVariables.MaxTryLoadBossTimes then
    self:CheckAnimUnLock()
    return
  end
  local isSuc = self.m_ownerModule:ChangeBossMainCameraByName(self.m_selBossChapterIndex)
  if isSuc ~= true then
    self:FailWaitReloadBoss()
  else
    local boseObj = self.m_ownerModule:GetBossObjBySortID(self.m_selBossChapterIndex)
    if not boseObj then
      self:FailWaitReloadBoss()
      return
    end
    if TimeUtil:GetServerTimeS() > LocalDataManager:GetIntSimple("EquipmentBossDailyEnter_" .. self.m_selBossChapterIndex, 0) then
      LocalDataManager:SetIntSimple("EquipmentBossDailyEnter_" .. self.m_selBossChapterIndex, TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
      local maxLen = self.m_ownerModule:PlayAnimatorBySortIDAndType(self.m_selBossChapterIndex, self.m_ownerModule.BossAnimType.Show)
      self:OpenBossShowPanelAndWaitBack(maxLen)
    else
      self.m_ownerModule:PlayAnimatorBySortIDAndType(self.m_selBossChapterIndex, self.m_ownerModule.BossAnimType.Idle)
      self:CheckAnimUnLock()
      if self.m_initEnterGuideTimer then
        TimeService:KillTimer(self.m_initEnterGuideTimer)
        self.m_initEnterGuideTimer = nil
      end
      self.m_initEnterGuideTimer = TimeService:SetTimer(0.1, 1, function()
        self.m_initEnterGuideTimer = nil
        self:broadcastEvent("eGameEvent_GuideEvent")
      end)
    end
  end
end

function Form_EquipmentCopyMain:FailWaitReloadBoss()
  self.m_failLoadNum = self.m_failLoadNum + 1
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  self.m_timer = TimeService:SetTimer(self.m_uiVariables.ShowBoseDelayTime, 1, function()
    self.m_timer = nil
    self:ShowBoss()
  end)
end

function Form_EquipmentCopyMain:OpenBossShowPanelAndWaitBack(maxAnimLen)
  UILuaHelper.SetCanvasGroupAlpha(self.m_rootTrans, 0)
  if not self.m_curDungeonChapterCfg then
    return
  end
  GlobalManagerIns:TriggerWwiseBGMState(161)
  GlobalManagerIns:TriggerWwiseBGMState(self.m_curDungeonChapterCfg.m_SoundID)
  if self.m_waitShowBossTimer then
    TimeService:KillTimer(self.m_waitShowBossTimer)
    self.m_waitShowBossTimer = nil
  end
  self.m_waitShowBossTimer = TimeService:SetTimer(maxAnimLen, 1, function()
    self.m_waitShowBossTimer = nil
    self.m_ownerModule:PlayAnimatorBySortIDAndType(self.m_selBossChapterIndex, self.m_ownerModule.BossAnimType.Idle)
  end)
  StackFlow:Push(UIDefines.ID_FORM_BOSSSHOW, {
    dungeonChapterCfg = self.m_curDungeonChapterCfg,
    backFun = function()
      self:CheckAnimUnLock()
      UILuaHelper.SetCanvasGroupAlpha(self.m_rootTrans, 1)
      self:broadcastEvent("eGameEvent_GuideEvent")
    end
  })
end

function Form_EquipmentCopyMain:CheckCreateFunctions()
  local maxBossType = self.m_uiVariables.MaxBossType
  for i = 1, maxBossType do
    self["OnBtnBossType" .. i .. "Clicked"] = function()
      self:OnBossTypeClk(i)
    end
  end
end

function Form_EquipmentCopyMain:OnBossTypeClk(index)
  if not index then
    return
  end
  local monsterTypeCfg = self.m_monsterTypeCfgList[index]
  if not monsterTypeCfg then
    return
  end
  utils.CheckAndPushCommonTips({
    tipsID = monsterTypeCfg.m_TipID
  })
end

function Form_EquipmentCopyMain:OnBtnreviewClicked()
  if not self.m_curLevelCfg then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_LEVELMONSTERPREVIEW, {
    battleWorldID = self.m_curLevelCfg.m_MapID,
    stageStr = self.m_curLevelCfg.m_mName
  })
end

function Form_EquipmentCopyMain:OnBtnRewardDetailClicked()
  if not self.m_dungeonStageRewardList then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_BOSSREWARD, {
    levelID = self.m_curLevelCfg.m_LevelID
  })
end

function Form_EquipmentCopyMain:OnBtnStartClicked()
  if not self.m_curLevelCfg then
    return
  end
  if not self.m_selBossChapterIndex or not self.m_curLevelSubType then
    return
  end
  local flag = self.m_equipmentHelper:CheckTodayBossIsTrue(self.m_curLevelSubType)
  if not flag then
    utils.popUpDirectionsUI({
      tipsID = 1128,
      func1 = function()
        self:OnBackClk()
      end
    })
    return
  end
  BattleFlowManager:StartEnterBattle(LevelManager.LevelType.Dungeon, self.m_curLevelCfg.m_LevelID)
end

function Form_EquipmentCopyMain:OnBtnStartGreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20017))
end

function Form_EquipmentCopyMain:OnBtnSimClicked()
  if not self.m_curLevelCfg then
    return
  end
  if not self.m_selBossChapterIndex or not self.m_curLevelSubType then
    return
  end
  local flag = self.m_equipmentHelper:CheckTodayBossIsTrue(self.m_curLevelSubType)
  if not flag then
    utils.popUpDirectionsUI({
      tipsID = 1128,
      func1 = function()
        self:OnBackClk()
      end
    })
    return
  end
  BattleFlowManager:StartEnterBattle(LevelManager.LevelType.Dungeon, self.m_curLevelCfg.m_LevelID, true)
end

function Form_EquipmentCopyMain:OnBtnQuickClicked()
  if not self.m_curLevelCfg then
    return
  end
  local flag = self.m_equipmentHelper:CheckTodayBossIsTrue(self.m_curLevelSubType)
  if not flag then
    utils.popUpDirectionsUI({
      tipsID = 1128,
      func1 = function()
        self:OnBackClk()
      end
    })
    return
  end
  LevelManager:ReqStageMopUp(LevelManager.LevelType.Dungeon, self.m_curLevelCfg.m_LevelID, 1)
end

function Form_EquipmentCopyMain:OnBtnQuickGreyClicked()
  local maxUseTimes = self.m_equipmentHelper:GetChallengeDailyNum()
  local curUseTimes = self.m_equipmentHelper:GetLevelDailyData()
  local leftTimes = maxUseTimes - curUseTimes
  if leftTimes <= 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20017))
    return
  end
  local finishNum = self.m_equipmentHelper:GetLevelFinishNumByLevelID(self.m_curLevelID)
  if finishNum <= 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13011)
    return
  end
end

function Form_EquipmentCopyMain:OnDungeonRewardItemClick(index, itemObj)
  local reward = self.m_dungeonStageRewardList[index + 1]
  if reward then
    utils.openItemDetailPop({
      iID = reward[1],
      iNum = ItemManager:GetItemNum(reward[1])
    })
  end
end

function Form_EquipmentCopyMain:OnBtnCloseClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_EQUIPMENTCOPYMAIN)
end

function Form_EquipmentCopyMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:Push(UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_EQUIPMENTCOPYMAIN)
end

function Form_EquipmentCopyMain:OnBackHome()
  StackPopup:PopAll()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  self.m_ownerModule:ClearAllBossRes()
  GameSceneManager:CheckChangeSceneToMainCity(nil, true)
end

function Form_EquipmentCopyMain:IsFullScreen()
  return true
end

function Form_EquipmentCopyMain:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  vResourceExtra[#vResourceExtra + 1] = {
    sName = AnimVideoStr .. ".mp4",
    eType = DownloadManager.ResourceType.Video
  }
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_EquipmentCopyMain", Form_EquipmentCopyMain)
return Form_EquipmentCopyMain
