local BaseManager = require("Manager/Base/BaseManager")
local ActivityManager = class("ActivityManager", BaseManager)
local ActivityTmpPath = CS.UnityEngine.Application.persistentDataPath .. "/Activity.tmp"
ActivityManager.SignTaken = 0
ActivityManager.SignCanTaken = 1
ActivityManager.SignCannotTaken = 2
ActivityManager.PayStoreSubPanelEnum = {
  "MallMonthlyCardMainSubPanel",
  "MallNewbieGiftSubPanel",
  "MallGoodsChapterSubPanel",
  "PushGiftSubPanel",
  "RechargeSubPanel",
  "MallDailyPackSubPanel",
  "PickupGiftSubPanel",
  "StepGiftSubPanel",
  "GameOpenGiftSubPanel",
  "LimitUpPackSubPanel",
  "ChainGiftPackSubPanel",
  "SignGiftFiveSunPanel",
  "FashionStoreSubPanel"
}
ActivityManager.ActivitySubPanelName = {
  ActivitySPName_Sign7 = "ActivitySevenDaysSubPanel_ByMain",
  ActivitySPName_Sign10 = "ActivitySignTenDaySubPanel",
  ActivitySPName_Sign14 = "ActivityFourteenSignSubPanel",
  ActivitySPName_CommunityEntrance = "ActivityCommunityEntranceSubPanel",
  ActivitySPName_RechargeBack = "ActivityRebateSubPanel",
  ActivitySPName_OnePicActivity = "OnePicActivitySubPanel",
  ActivitySPName_LoginSendItem = "ActivityLoginSendItemSubPanel",
  ActivitySPName_LevelAwardActivity = "LevelAwardActivitySubPanel",
  ActivitySPName_LevelAwardActivity2 = "LevelAwardActivitySubPanel2",
  ActivitySPName_EmpousaActivity = "EmpousaActivitySubPanel",
  ActivitySPName_CliveActivity = "CliveActivitySubPanel",
  ActivitySPName_EmbraceBonusActivity = "EmbraceBonusSubPanel",
  ActivitySPName_FirstRechargeActivity = "FirstRechargeActivitySubPanel"
}
ActivityManager.ActStateEnum = {
  Normal = 0,
  Finished = 1,
  Locked = 2,
  NotOpen = 3
}
ActivityManager.JumpType = {
  Activity = 0,
  Url = 1,
  System = 2,
  Elva = 3,
  Naver = 4,
  NoJump = 5,
  WebTokenUrl = 6
}
ActivityManager.ActPushFaceStatue = {
  NoReserve = 1,
  Reserve = 2,
  Jump = 3
}
ActivityManager.BattlePassBuyStatus = {
  Free = 0,
  Paid = 1,
  Advanced = 2
}
ActivityManager.BattlePassType = {
  StartBp = 1,
  MonthBp = 2,
  ActivityUpBp = 3
}
ActivityManager.BattlePassUIType = {
  [ActivityManager.BattlePassType.StartBp] = {
    BattlePassMain = "Form_BattlePass",
    BattlePassBenefits = "Form_BattlePassBenefits",
    BattlePassLevelUp = "Form_BattlePassLevelUp10",
    UnlockAnimation = "BattlePass_advanced_lock"
  },
  [ActivityManager.BattlePassType.MonthBp] = {
    BattlePassMain = "Form_BattlePass_Monthly",
    BattlePassBenefits = "Form_BattlePassBenefits_Monthly",
    BattlePassLevelUp = "Form_BattlePassLevelUp10_Monthly",
    UnlockAnimation = "BattlePass_Monthly_lock"
  },
  [ActivityManager.BattlePassType.ActivityUpBp] = {
    BattlePassMain = "Form_BattlePass_Up",
    BattlePassBenefits = "Form_BattlePassBenefits_Up",
    BattlePassLevelUp = "Form_BattlePassLevelUp10_Up",
    UnlockAnimation = "BattlePass_Up_lock"
  }
}

function ActivityManager:OnCreate()
  self.m_vActivityData = nil
  self.m_mActivityClass = {}
  self.reportPercentList = nil
end

function ActivityManager:LoadAllActivity()
  self:LoadActivity("Module/Activity/ModuleControl/ModuleControlActivity")
  self:LoadActivity("Module/Activity/Sign/SignActivity")
  self:LoadActivity("Module/Activity/CommonQuest/CommonQuestActivity")
  self:LoadActivity("Module/Activity/SurveyReward/SurveyRewardActivity")
  self:LoadActivity("Module/Activity/LoginSelect/LoginSelectActivity")
  self:LoadActivity("Module/Activity/LevelAward/LevelAwardActivity")
  self:LoadActivity("Module/Activity/PushGift/PushGiftActivity")
  self:LoadActivity("Module/Activity/HeroAct/HeroActTimeActivity")
  self:LoadActivity("Module/Activity/Mall/PickUpGiftActivity")
  self:LoadActivity("Module/Activity/Mall/PayStoreActivity")
  self:LoadActivity("Module/Activity/GameNotice/GameNoticeActivity")
  self:LoadActivity("Module/Activity/RechargeBack/RechargeBackActivity")
  self:LoadActivity("Module/Activity/CommunityEntrance/CommunityEntranceActivity")
  self:LoadActivity("Module/Activity/BattlePass/BattlePassActivity")
  self:LoadActivity("Module/Activity/SystemUnlock/SystemUnlockActivity")
  self:LoadActivity("Module/Activity/PersonalRaid/PersonalRaidActivity")
  self:LoadActivity("Module/Activity/JumpFace/JumpFaceActivity")
  self:LoadActivity("Module/Activity/GuildBoss/GuildBossActivity")
  self:LoadActivity("Module/Activity/OnePicAct/OnePicActivity")
  self:LoadActivity("Module/Activity/LoginSendItem/LoginSendItemActivity")
  self:LoadActivity("Module/Activity/UpTimeManager/UpTimeManagerActivity")
  self:LoadActivity("Module/Activity/BattleDebug/BattleDebugActivity")
  self:LoadActivity("Module/Activity/WelfareShow/WelfareShowActivity")
  self:LoadActivity("Module/Activity/CensorCtrl/CensorCtrlActivity")
  self:LoadActivity("Module/Activity/FullBurstDay/FullBurstDayActivity")
  self:LoadActivity("Module/Activity/HeroSkillReset/HeroSkillResetActivity")
  self:LoadActivity("Module/Activity/EmergencyGift/EmergencyGiftActivity")
  self:LoadActivity("Module/Activity/HuntingRaid/HuntingRaidActivity")
  self:LoadActivity("Module/Activity/VoucherControl/VoucherControlActivity")
  self:LoadActivity("Module/Activity/SignGift/SignGiftActivity")
  self:LoadActivity("Module/Activity/Gacha/Gacha10FreeActivity")
end

function ActivityManager:LoadActivity(sActivityPath)
  local activityClass = require(sActivityPath)
  self.m_mActivityClass[activityClass:getActivityType()] = activityClass
end

function ActivityManager:CanShowRedCurrentLogin(iActivityID)
  if iActivityID == nil then
    return true
  end
  local stActivityData = self:GetActivityDataByID(iActivityID)
  if not stActivityData then
    return false
  end
  if stActivityData.iShowReddotNew and stActivityData.iShowReddotNew == 1 then
    if TimeUtil:GetServerTimeS() < LocalDataManager:GetIntSimple("Red_Point" .. iActivityID, 0) then
      return false
    end
  elseif stActivityData.iShowReddotNew and stActivityData.iShowReddotNew == 2 then
    if LocalDataManager:GetIntSimple("Red_Point" .. iActivityID, 0) ~= 0 then
      return false
    end
  else
    return false
  end
  return true
end

function ActivityManager:CanShowRedCurrentLoginByType(iActivityID, iShowReddotNew)
  if iActivityID == nil then
    return true
  end
  local stActivityData = self:GetActivityDataByID(iActivityID)
  if not stActivityData then
    return false
  end
  if iShowReddotNew == nil then
    iShowReddotNew = stActivityData.iShowReddotNew
  end
  if iShowReddotNew and iShowReddotNew == 1 then
    if TimeUtil:GetServerTimeS() < LocalDataManager:GetIntSimple("Red_Point" .. iActivityID, 0) then
      return false
    end
  elseif iShowReddotNew and iShowReddotNew == 2 then
    if LocalDataManager:GetIntSimple("Red_Point" .. iActivityID, 0) ~= 0 then
      return false
    end
  else
    return false
  end
  return true
end

function ActivityManager:SetShowRedCurrentLogin(iActivityID, iShowReddotNew)
  if iActivityID == nil then
    return
  end
  local stActivityData = self:GetActivityDataByID(iActivityID)
  if not stActivityData then
    return false
  end
  if iShowReddotNew == nil then
    iShowReddotNew = stActivityData.iShowReddotNew
  end
  if iShowReddotNew and iShowReddotNew == 1 then
    if LocalDataManager:GetIntSimple("Red_Point" .. iActivityID, 0) == 0 then
      LocalDataManager:SetIntSimple("Red_Point" .. iActivityID, TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
    end
    if TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()) - 1000 > LocalDataManager:GetIntSimple("Red_Point" .. iActivityID, 0) then
      LocalDataManager:SetIntSimple("Red_Point" .. iActivityID, TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
    end
  elseif iShowReddotNew and iShowReddotNew == 2 then
    if LocalDataManager:GetIntSimple("Red_Point" .. iActivityID, 0) == 0 then
      LocalDataManager:SetIntSimple("Red_Point" .. iActivityID, 1)
    end
    if TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()) - 1000 > LocalDataManager:GetIntSimple("Red_Point" .. iActivityID, 0) then
      LocalDataManager:SetIntSimple("Red_Point" .. iActivityID, 1)
    end
  end
end

function ActivityManager:CanShowRedWeekLogin(iActivityID)
  if iActivityID == nil then
    return true
  end
  if TimeUtil:GetServerTimeS() < LocalDataManager:GetIntSimple("Red_Point_Week" .. iActivityID, 0) then
    return false
  end
  return true
end

function ActivityManager:SetShowRedWeekLogin(iActivityID, iWeekDay)
  if iActivityID == nil then
    return
  end
  local swday = TimeUtil:GetServerTimeWeekDay() - 1
  if swday == 0 then
    swday = 7
  end
  local twday = iWeekDay
  local iCurZeroTime = TimeUtil:GetZeroClockTimeS()
  local iRefreshZeroTime = iCurZeroTime + (twday - swday) * 3600 * 24
  local iCurTime = TimeUtil:GetServerTimeS()
  if iRefreshZeroTime < iCurTime then
    iRefreshZeroTime = iRefreshZeroTime + 604800
  end
  if iRefreshZeroTime ~= LocalDataManager:GetIntSimple("Red_Point_Week" .. iActivityID, 0) then
    LocalDataManager:SetIntSimple("Red_Point_Week" .. iActivityID, iRefreshZeroTime)
  end
end

function ActivityManager:OnInitNetwork()
  self:LoadAllActivity()
  RPCS():Listen_Push_Activity_Status(handler(self, self.OnPushActivityStatus), "ActivityManager")
  RPCS():Listen_Push_Activity_Remove(handler(self, self.OnPushActivityRemove), "ActivityManager")
  RPCS():Listen_Push_Activity_RemoveBatch(handler(self, self.OnPushActivityRemoveBatch), "ActivityManager")
  RPCS():Listen_Push_Activity_Change(handler(self, self.OnPushActivityChange), "ActivityManager")
  RPCS():Listen_Push_Activity_ChangeBatch(handler(self, self.OnPushActivityChangeBatch), "ActivityManager")
  RPCS():Listen_Push_Activity_Reload(handler(self, self.OnPushActivityReload), "ActivityManager")
  RPCS():Listen_Push_SurveyStatus(handler(self, self.OnPushSurveyStatus), "ActivityManager")
  RPCS():Listen_Push_NewGift(handler(self, self.OnPushNewGift), "ActivityManager")
  RPCS():Listen_Push_NewActivityPickupGift(handler(self, self.OnPushNewActivityPickupGift), "ActivityManager")
  RPCS():Listen_Push_UploadFlog(handler(self, self.OnPushFlogReport), "ActivityManager")
end

function ActivityManager:OnInitMustRequestInFetchMore()
  self:GetActivityList(false, false)
end

function ActivityManager:OnDailyReset()
  self:GetActivityList(true)
end

function ActivityManager:GetAllActivityList()
  return self.m_vActivity or {}
end

function ActivityManager:SetActivityDataList(msg)
  local mOldMapActivity = self.m_mapActivity
  self.m_vActivity = nil
  self.m_mapActivity = nil
  self.m_vActivityData = nil
  local vState = msg.vStatusData
  local bOnlyStatusData = msg.bOnlyStatusData
  if bOnlyStatusData then
    local savedAct = utils.readfile(ActivityTmpPath)
    if savedAct then
      self.m_vActivityData = table.unserialize(savedAct)
    end
  else
    self.m_vActivityData = msg.vActivity
    local strAct = table.serialize(self.m_vActivityData)
    local sMD5 = CS.Util.md5fileByMemory(strAct)
    LocalDataManager:SetStringSimple("ACTIVITY_LOCAL_SUM", sMD5)
    utils.writefile(ActivityTmpPath, strAct)
    LocalDataManager:SetStringSimple("ACTIVITY_SUM", msg.sNewChecksum)
  end
  self.m_iPushVersion = msg.iPushVersion
  if self.m_vActivityData == nil then
    return
  end
  
  local function replcaeState(stActivityData, stateList)
    for k, v in ipairs(stateList) do
      if stActivityData.iActivityId == v.iActivityId then
        stActivityData.sStatusDataSdp = v.sStatusDataSdp
        break
      end
    end
  end
  
  local ActivitySort = {
    [MTTD.ActivityType_SignGift] = 100,
    [MTTD.ActivityType_PayStore] = 200
  }
  table.sort(self.m_vActivityData, function(a, b)
    local aSort = ActivitySort[a.iActivityType] or 0
    local bSort = ActivitySort[b.iActivityType] or 0
    if aSort == bSort then
      return a.iActivityId < b.iActivityId
    end
    return aSort < bSort
  end)
  self.m_pushList = {}
  self.m_vActivity = {}
  if #self.m_vActivityData > 0 then
    for k, v in ipairs(self.m_vActivityData) do
      if bOnlyStatusData then
        replcaeState(v, vState)
      end
      self:CreateActivityByData(v, mOldMapActivity)
    end
  end
  self:UpdateMainActivityList()
  self:FreshMainBannerActivityList()
  local isOpenFlog = 0
  local activityModule = self:GetActivityByType(MTTD.ActivityType_ModuleControl)
  if activityModule then
    isOpenFlog = activityModule:GetFlogControlData().iOpenReport or 0
  end
  CS.UnityEngine.PlayerPrefs.SetInt("logs_switch", isOpenFlog)
end

function ActivityManager:UpdateMainActivityList()
  self.m_vMainPanelActivityList = {}
  if self.m_mapActivity then
    for k, v in pairs(self.m_mapActivity) do
      local data = v:getData()
      if v.getSubPanelName and v:getSubPanelName() then
        local subPanel = v:getSubPanelName()
        if subPanel and data.iEntry > 0 then
          local item = {
            Id = k,
            SubPanelName = subPanel,
            Type = v:getType(),
            Activity = v,
            Priority = data.iActivityPriority,
            ActivityPic = data.sActivityPic
          }
          table.insert(self.m_vMainPanelActivityList, item)
        end
      end
    end
    table.sort(self.m_vMainPanelActivityList, function(a, b)
      return a.Priority > b.Priority
    end)
  end
end

function ActivityManager:GetMainActivityList()
  if self.m_vMainPanelActivityList == nil then
    self.m_vMainPanelActivityList = {}
  end
  return self.m_vMainPanelActivityList
end

function ActivityManager:FreshMainBannerActivityList()
  self.m_vMainBannerActivityList = {}
  if self.m_mapActivity then
    for k, v in pairs(self.m_mapActivity) do
      local data = v:getData()
      if data and data.iEntry > 0 and data.sActivityPic and data.sActivityPic ~= "" then
        local item = {
          Id = k,
          Type = v:getType(),
          Activity = v,
          Priority = data.iActivityPriority,
          ActivityPic = data.sActivityPic
        }
        self.m_vMainBannerActivityList[#self.m_vMainBannerActivityList + 1] = item
      end
    end
    table.sort(self.m_vMainBannerActivityList, function(a, b)
      return a.Priority > b.Priority
    end)
  end
end

function ActivityManager:GetMainBannerActivityList()
  if self.m_vMainBannerActivityList == nil then
    self.m_vMainBannerActivityList = {}
  end
  return self.m_vMainBannerActivityList
end

function ActivityManager:GetBannerPic(iActivityID)
  local data = self:GetActivityDataByID(iActivityID)
  if data then
    return data.sActivityPic
  end
  return ""
end

function ActivityManager:GetActivityList(bReload, isShowWaitView)
  isShowWaitView = isShowWaitView == nil and true or isShowWaitView
  if bReload then
    if self.m_vActivityData == nil then
      return
    end
    if self.m_vActivity == nil then
      return
    end
  end
  local reqMsg = MTTDProto.Cmd_Act_GetList_CS()
  
  local function checkLocalSum()
    local savedAct = utils.readfile(ActivityTmpPath)
    if savedAct == nil then
      return false
    end
    local sMD5 = CS.Util.md5fileByMemory(savedAct)
    local readMD5 = LocalDataManager:GetStringSimple("ACTIVITY_LOCAL_SUM", "")
    if sMD5 == readMD5 then
      return true
    else
      return false
    end
  end
  
  if checkLocalSum() then
    reqMsg.sChecksum = LocalDataManager:GetStringSimple("ACTIVITY_SUM", "")
  end
  RPCS():Act_GetList(reqMsg, function(sc, msg)
    if self.m_vActivity ~= nil then
      for k, v in ipairs(self.m_vActivity) do
        v:dispose()
      end
    end
    self:SetActivityDataList(sc)
    if bReload then
      self:broadcastEvent("eGameEvent_Activity_Reload")
      self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
    end
    if not self:IsOpenBackgroundDownloadAllResource() then
      DownloadManager:PauseDownloadAddResAll()
      CS.MUF.Download.DownloadResource.Instance:SetOpenDownloadEnsurance(false)
    end
    self:broadcastEvent("eGameEvent_Activity_AnywayReload")
    self:CheckShowUidAndMaking()
  end, self.OnReqGetListFailed)
end

function ActivityManager:OnReqGetListFailed(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  local iErrorCode = msg.rspcode
  log.error("Message Error Code: ", iErrorCode)
  if iErrorCode == 1008 then
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonPrompt"),
      content = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsContent1198"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      bLockTop = true,
      func1 = function()
        self:GetActivityList(true)
      end,
      func2 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  else
    NetworkManager:OnRpcCallbackFail(msg)
  end
  local params = {
    Server_message = "Act_GetList",
    Server_code = tostring(iErrorCode)
  }
  ReportManager:ReportMessage(CS.ReportDataDefines.Client_report_server_error_code, params)
end

function ActivityManager:GetActivityDataByID(iActivityID)
  if self.m_vActivityData == nil then
    return nil
  end
  for k, v in ipairs(self.m_vActivityData) do
    if v.iActivityId == iActivityID then
      return v
    end
  end
  return nil
end

function ActivityManager:RemoveActivityDataByID(iActivityID)
  if self.m_vActivityData == nil then
    return nil
  end
  for k, v in ipairs(self.m_vActivityData) do
    if v.iActivityId == iActivityID then
      table.remove(self.m_vActivityData, k)
      return
    end
  end
end

function ActivityManager:CreateActivityByData(stActivityData, mOldMapActivity, mParamEx)
  local activity
  if stActivityData then
    local activityClass = self.m_mActivityClass[stActivityData.iActivityType]
    if activityClass == nil then
      return
    end
    local isOldAct = false
    if mOldMapActivity and mOldMapActivity[stActivityData.iActivityId] then
      activity = mOldMapActivity[stActivityData.iActivityId]
      isOldAct = true
    else
      activity = activityClass.new(stActivityData)
    end
    local bInsert = true
    if mParamEx and mParamEx.bInsert ~= nil then
      bInsert = mParamEx.bInsert
    end
    if bInsert then
      if self.m_vActivity == nil then
        self.m_vActivity = {}
      end
      if self.m_mapActivity == nil then
        self.m_mapActivity = {}
      end
      if activity then
        table.insert(self.m_vActivity, activity)
        self.m_mapActivity[activity:getID()] = activity
      end
    end
    if isOldAct then
      activity:setData(stActivityData)
    end
  end
  return activity
end

function ActivityManager:RemoveActivityByID(iActivityID)
  if self.m_vActivity then
    for index, activity in ipairs(self.m_vActivity) do
      if activity:getID() == iActivityID then
        activity:dispose()
        table.remove(self.m_vActivity, index)
        self.m_mapActivity[iActivityID] = nil
        break
      end
    end
    if self.m_vMainPanelActivityList then
      for i, v in ipairs(self.m_vMainPanelActivityList) do
        if v.Id == iActivityID then
          table.remove(self.m_vMainPanelActivityList, i)
          break
        end
      end
    end
    if self.m_vMainBannerActivityList then
      for i, v in ipairs(self.m_vMainBannerActivityList) do
        if v.Id == iActivityID then
          table.remove(self.m_vMainBannerActivityList, i)
          break
        end
      end
    end
  end
end

function ActivityManager:GetActivityByID(iActivityID)
  if iActivityID == nil or iActivityID == 0 then
    return nil
  end
  if self.m_vActivity then
    for _, activity in ipairs(self.m_vActivity) do
      if activity:getID() == iActivityID then
        return activity
      end
    end
  end
end

function ActivityManager:GetMapActivityByID(iActivityID)
  if self.m_mapActivity == nil or iActivityID == nil or iActivityID == 0 then
    return nil
  end
  return self.m_mapActivity[iActivityID]
end

function ActivityManager:GetActivityListByType(iActivityType)
  local activityList = {}
  if self.m_vActivity then
    for _, activity in ipairs(self.m_vActivity) do
      if activity:getType() == iActivityType then
        table.insert(activityList, activity)
      end
    end
  end
  return activityList
end

function ActivityManager:GetActivityByType(iActivityType)
  if self.m_vActivity then
    for _, activity in ipairs(self.m_vActivity) do
      if activity:getType() == iActivityType then
        return activity
      end
    end
  end
end

function ActivityManager:GetActivityInShowTimeByType(iActivityType)
  if self.m_vActivity then
    for _, activity in ipairs(self.m_vActivity) do
      if activity:getType() == iActivityType and activity:checkCondition() and activity:isInActivityShowTime() then
        return activity
      end
    end
  end
end

function ActivityManager:GetActivityInShowTimeById(activityId)
  if self.m_vActivity then
    for _, activity in ipairs(self.m_vActivity) do
      if activity:getID() == activityId and activity:checkCondition() and activity:isInActivityShowTime() then
        return activity
      end
    end
  end
end

function ActivityManager:CanShowSurveyReward(activeIndex, iIndex)
  local showFlag = false
  local state = MTTDProto.SurveyRewardStatus_None
  if self.m_vActivity then
    local activityList = self:GetActivityListByType(MTTD.ActivityType_SurveyReward)
    if activityList and activityList[activeIndex] then
      local activity = activityList[activeIndex]
      if activity:CheckActivityIsOpen() then
        state = activity:GetSurveyRewardStatus()[iIndex] or MTTDProto.SurveyRewardStatus_None
        showFlag = state == MTTDProto.SurveyRewardStatus_None
        return showFlag, state, activity:getID()
      end
    end
  end
  return showFlag, state, 0
end

function ActivityManager:RequestSurveyReward(iActivityId, iIndexId)
  local activity = self:GetActivityByID(iActivityId)
  if activity then
    activity:RequestGetSurveyReward(iIndexId)
  end
end

function ActivityManager:OnPushSurveyStatus(sc, msg)
  local iActivityId = sc.iActivityId
  local iIndexId = sc.iIndexId
  local iStatus = sc.iStatus
  local activity = self:GetActivityByID(iActivityId)
  if activity then
    activity:RequestGetSurveyReward(iIndexId)
    activity:SetSurveyRewardStatus(iIndexId, iStatus)
  end
end

function ActivityManager:OnPushNewGift(sc, msg)
  self:broadcastEvent("eGameEvent_Push_Gift", sc)
  self:RefreshPushGiftRedPoint()
end

function ActivityManager:OnPushNewActivityPickupGift(sc, msg)
  self:broadcastEvent("eGameEvent_Push_ActivityPickupGift", sc)
end

function ActivityManager:OnPushFlogReport(sc, msg)
  ReportManager:ReportFlog(sc.iLogLevel)
end

function ActivityManager:RefreshPushGiftRedPoint()
  local activity = self:GetActivityByType(MTTD.ActivityType_PushGift)
  if not activity then
    return
  end
  local redPoint = activity:GetPushGiftRedPoint()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.MallPushGiftTab,
    count = redPoint
  })
end

function ActivityManager:OnPushActivityStatus(sc, msg)
  self.m_iPushVersion = sc.iPushVersion
  self:OnActivityStatus(sc.iActivityId, sc.sStatusDataSdp, true)
end

function ActivityManager:OnActivityStatus(iActivityID, sStatusDataSdp, bUpdateView)
  local activity = self:GetActivityByID(iActivityID)
  if activity then
    activity:onActivityStatus(sStatusDataSdp, bUpdateView)
  end
end

function ActivityManager:OnPushActivityRemove(sc, msg)
  self.m_iPushVersion = sc.iPushVersion
  self:OnActivityRemove(sc.iActivityId)
end

function ActivityManager:OnPushActivityRemoveBatch(sc, msg)
  self.m_iPushVersion = sc.iPushVersion
  for _, iActivityID in ipairs(sc.vActivityId) do
    self:OnActivityRemove(iActivityID)
  end
end

function ActivityManager:OnActivityRemove(iActivityID)
  if self.m_vActivity == nil then
    return
  end
  local activity
  for k, v in ipairs(self.m_vActivity) do
    if v:getID() == iActivityID then
      activity = v
      break
    end
  end
  if activity ~= nil then
    local iActivityType = activity:getType()
    self:RemoveActivityByID(iActivityID)
    self:RemoveActivityDataByID(iActivityID)
    self:broadcastEvent("eGameEvent_Activity_Remove", {iActivityID = iActivityID, iActivityType = iActivityType})
    self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
  end
end

function ActivityManager:OnPushActivityChange(sc, msg)
  self.m_iPushVersion = sc.iPushVersion
  self:OnActivityChange(sc.iActivityId, sc.stActivityData)
end

function ActivityManager:OnPushActivityChangeBatch(sc, msg)
  self.m_iPushVersion = sc.iPushVersion
  for iActivityID, stActivityData in pairs(sc.mActivityData) do
    self:OnActivityChange(iActivityID, stActivityData)
  end
end

function ActivityManager:OnActivityChange(iActivityID, stActivityDataNew)
  local activityData = self:GetActivityDataByID(iActivityID)
  if activityData ~= nil then
    activityData.iActivityType = stActivityDataNew.iActivityType
    activityData.sTitle = stActivityDataNew.sTitle
    activityData.sPageTitle = stActivityDataNew.sPageTitle
    activityData.sBriefDesc = stActivityDataNew.sBriefDesc
    activityData.sBriefDescImg = stActivityDataNew.sBriefDescImg
    activityData.sDetailDesc = stActivityDataNew.sDetailDesc
    activityData.sIcon = stActivityDataNew.sIcon
    activityData.sJumpURL = stActivityDataNew.sJumpURL
    activityData.sJumpUI = stActivityDataNew.sJumpUI
    activityData.bIsTop = stActivityDataNew.bIsTop
    activityData.bIsMajor = stActivityDataNew.bIsMajor
    activityData.iBeginTime = stActivityDataNew.iBeginTime
    activityData.iEndTime = stActivityDataNew.iEndTime
    activityData.iShowTimeBegin = stActivityDataNew.iShowTimeBegin
    activityData.iShowTimeEnd = stActivityDataNew.iShowTimeEnd
    activityData.iMinLevel = stActivityDataNew.iMinLevel
    activityData.iMaxLevel = stActivityDataNew.iMaxLevel
    activityData.bShowInList = stActivityDataNew.bShowInList
    activityData.stMainCityIcon = stActivityDataNew.stMainCityIcon
    activityData.iMainClassId = stActivityDataNew.iMainClassId
    activityData.sSdpConfig = stActivityDataNew.sSdpConfig
    activityData.sStatusDataSdp = stActivityDataNew.sStatusDataSdp
    if stActivityDataNew.mDownloadPicture ~= nil then
      activityData.mDownloadPicture = activityData.mDownloadPicture or {}
      for k, v in pairs(stActivityDataNew.mDownloadPicture) do
        activityData.mDownloadPicture[k] = v
      end
    end
    if stActivityDataNew.mMultiLanguage ~= nil then
      activityData.mMultiLanguage = activityData.mMultiLanguage or {}
      for k, v in pairs(stActivityDataNew.mMultiLanguage) do
        activityData.mMultiLanguage[k] = v
      end
    end
    local activity = self:GetActivityByID(iActivityID)
    if activity then
      activity:onActivityChange()
    end
  else
    if self.m_vActivityData == nil then
      self.m_vActivityData = {}
    end
    table.insert(self.m_vActivityData, stActivityDataNew)
    local activity = self:CreateActivityByData(stActivityDataNew)
    if activity ~= nil then
      self:broadcastEvent("eGameEvent_Activity_CreateHalfway", {
        iActivityID = iActivityID,
        iActivityType = activity:getType()
      })
    end
    self:UpdateMainActivityList()
    self:FreshMainBannerActivityList()
  end
  self:CheckShowUidAndMaking()
  self:broadcastEvent("eGameEvent_Activity_HallActivityChange")
end

function ActivityManager:OnPushActivityReload(sc, msg)
  self:GetActivityList(true)
end

function ActivityManager:IsNotShowInList(activity)
  local bContinue = false
  if activity == nil then
    return true
  end
  if false == activity:isInActivityLevel() then
    bContinue = true
  end
  return bContinue
end

function ActivityManager:SaveActivity(iActivityID)
  LocalDataManager:SetIntSimple("Activity_ID_" .. iActivityID, iActivityID)
end

function ActivityManager:CollectValidProductIds()
  if self.m_validProductIds == nil and self.m_vActivity ~= nil then
    self.m_validProductIds = {}
    for k, activity in ipairs(self.m_vActivity) do
      if nil ~= activity.getValidProductIds then
        local pids = activity:getValidProductIds()
        for k1, v1 in ipairs(pids) do
          self.m_validProductIds[v1] = 1
        end
      end
    end
  end
end

function ActivityManager:GetValidProductIds()
  self:CollectValidProductIds()
  return self.m_validProductIds or {}
end

function ActivityManager:IsProductIDValidate(productID)
  local validProductIds = self:GetValidProductIds()
  if validProductIds[productID] == 1 then
    return true
  end
  return false
end

function ActivityManager:SetActivityImage(stActivityData, image, sFileName, fCB)
  local sFileNameReal
  if string.find(sFileName, "_all.") or string.find(sFileName, "_all_9Patch_") or string.find(sFileName, "_all_size_") then
    sFileNameReal = sFileName
  else
    sFileNameReal = sFileName
    if stActivityData then
      local mDownloadPictureCDN = stActivityData.mDownloadPictureCDN
      if mDownloadPictureCDN and mDownloadPictureCDN[sFileName] then
        local vLanIDAll = string.split(mDownloadPictureCDN[sFileName], ";")
        local stLanguageElment = CData_MultiLanguage:GetValue_ByID(CS.MultiLanguageManager.g_iLanguageID)
        local iLanID = stLanguageElment.m_LanID
        for _, sLanIDTmp in ipairs(vLanIDAll) do
          if tonumber(sLanIDTmp) == iLanID then
            if string.endsWith(sFileName, ".png") then
              sFileNameReal = string.replace(sFileName, ".png", "_" .. sLanIDTmp .. ".png")
              break
            end
            if string.endsWith(sFileName, ".jpg") then
              sFileNameReal = string.replace(sFileName, ".jpg", "_" .. sLanIDTmp .. ".jpg")
            end
            break
          end
        end
      end
    end
  end
  if sFileNameReal == nil then
    log.error("SetActivityImage Failed: " .. sFileName)
    return
  end
  UILuaHelper.SetCDNAtlasSprite(image, sFileNameReal, fCB)
end

function ActivityManager:GetItemReportStr(...)
  local vItemList = self:GetItemInfoListByProductID(...)
  local vContent = {}
  if vItemList then
    for i = 1, #vItemList do
      table.insert(vContent, vItemList[i].iID .. "," .. vItemList[i].iNum)
    end
  end
  return table.concat(vContent, ";")
end

function ActivityManager:GetItemInfoListByProductID(activity, strProductId, strProductSubId, iGiftId)
  return {}
end

function ActivityManager:IsHallActivityEntryHaveRedDot(param)
  local openFlagActivity = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Activity)
  if openFlagActivity ~= true then
    return 0
  end
  local redPoint = 0
  local paramType = type(param)
  if paramType == "table" then
    for i, v in pairs(param) do
      if v == RogueStageManager.BattleType then
        redPoint = redPoint + (self:CheckHallActivityHaveRedPointBySystemID(GlobalConfig.SYSTEM_ID.RogueStage) or 0)
      else
        redPoint = redPoint + (BattleFlowManager:IsLevelEntryHaveRedDot(v) or 0)
      end
    end
  elseif paramType == "number" then
    if param == RogueStageManager.BattleType then
      redPoint = redPoint + (self:CheckHallActivityHaveRedPointBySystemID(GlobalConfig.SYSTEM_ID.RogueStage) or 0)
    else
      redPoint = redPoint + (BattleFlowManager:IsLevelEntryHaveRedDot(param) or 0)
    end
  end
  redPoint = redPoint + (GlobalRankManager:IsGlobalRankEntryHaveRedDot() or 0)
  return redPoint
end

function ActivityManager:CheckHallActivityHaveRedPointBySystemID(systemId)
  local redPoint = 0
  if systemId == GlobalConfig.SYSTEM_ID.Dungeon then
    redPoint = LevelManager:IsLevelEntryHaveRedDot(LevelManager.LevelType.Dungeon)
  elseif systemId == GlobalConfig.SYSTEM_ID.Tower then
    redPoint = LevelManager:IsLevelEntryHaveRedDot(LevelManager.LevelType.Tower)
  elseif systemId == GlobalConfig.SYSTEM_ID.Goblin then
    redPoint = LevelManager:IsLevelEntryHaveRedDot(LevelManager.LevelType.Goblin)
  elseif systemId == GlobalConfig.SYSTEM_ID.LegacyLevel then
    redPoint = LegacyLevelManager:IsLevelEntryHaveRedDot(LegacyLevelManager.LevelType.LegacyLevel)
  elseif systemId == GlobalConfig.SYSTEM_ID.RogueStage then
    redPoint = RogueStageManager:CheckRogueEntryHaveRedPoint()
  end
  return redPoint
end

function ActivityManager:CheckHallActivityHaveRedPoint()
  local HallEventIns = ConfigManager:GetConfigInsByName("HallEvent")
  local activityInfoAll = HallEventIns:GetAll()
  local redPoint = 0
  for i, v in pairs(activityInfoAll) do
    redPoint = self:CheckHallActivityHaveRedPointBySystemID(v.m_SystemID)
    if redPoint and 0 < redPoint then
      return redPoint
    end
  end
  return redPoint
end

function ActivityManager:GetHallEventCfgBySystemId(systemId)
  local HallEventIns = ConfigManager:GetConfigInsByName("HallEvent")
  local activityInfoAll = HallEventIns:GetAll()
  for i, v in pairs(activityInfoAll) do
    if v.m_SystemID == systemId then
      return v
    end
  end
  return nil
end

function ActivityManager:IsOpenBackgroundDownloadAllResource()
  local activityList = self:GetActivityListByType(MTTD.ActivityType_ModuleControl)
  if activityList == nil then
    return true
  end
  local bOpen = true
  for _, activity in pairs(activityList) do
    local sOpenTmp = activity:GetCommonParamByKey("close_backstage_download_all")
    if sOpenTmp and sOpenTmp == "1" then
      bOpen = false
      break
    end
  end
  return bOpen
end

function ActivityManager:CheckShowUidAndMaking()
  local dataUid = self:IsOpenWaterMark(1)
  if dataUid then
    local roleId = RoleManager:GetUID()
    local showText = "UID:" .. tostring(roleId) .. ""
    local margin = dataUid.iOffset
    local fontSize = dataUid.iSize
    local pos = dataUid.iPos
    UILuaHelper.ShowGuiLabelText(showText, fontSize, margin, pos, "ShowUid")
  else
  end
  local dataMaking, act = self:IsOpenWaterMark(2)
  if dataMaking then
    local showText = act:getLangText(dataMaking.sContent)
    local margin = dataMaking.iOffset
    local fontSize = dataMaking.iSize
    local pos = dataMaking.iPos
    UILuaHelper.ShowGuiLabelText(showText, fontSize, margin, pos, "EndShow")
  else
  end
end

function ActivityManager:IsOpenWaterMark(index)
  local activityList = self:GetActivityListByType(MTTD.ActivityType_ModuleControl)
  if not activityList then
    return false
  end
  for _, activity in pairs(activityList) do
    local data = activity:CheckShowWaterMark(index)
    if data then
      return data, activity
    end
  end
  return false
end

function ActivityManager:IsUseClientFightResult()
  local activityList = self:GetActivityListByType(MTTD.ActivityType_ModuleControl)
  if activityList == nil then
    return false
  end
  for _, activity in pairs(activityList) do
    local sClientResult = activity:GetCommonParamByKey("use_client_result")
    if sClientResult and sClientResult == "1" then
      return true
    end
  end
  return false
end

function ActivityManager:IsCloseFightCheatType(cheatype)
  local activityList = self:GetActivityListByType(MTTD.ActivityType_ModuleControl)
  if activityList == nil then
    return false
  end
  for _, activity in pairs(activityList) do
    if activity.m_stSdpConfig and activity.m_stSdpConfig.stClientCfg and activity.m_stSdpConfig.stClientCfg.vCloseFightCheatType then
      for _, v in pairs(activity.m_stSdpConfig.stClientCfg.vCloseFightCheatType) do
        if cheatype == v then
          return true
        end
      end
    end
  end
  return false
end

function ActivityManager:CloseRogueJumpImprove()
  local activityList = self:GetActivityListByType(MTTD.ActivityType_ModuleControl)
  if activityList == nil then
    return false
  end
  for _, activity in pairs(activityList) do
    if activity.m_stSdpConfig and activity.m_stSdpConfig.stClientCfg and activity.m_stSdpConfig.stClientCfg.bCloseRogueJumpImprove then
      return true
    end
  end
  return false
end

function ActivityManager:ColseFormWebViewFullScreen()
  self:broadcastEvent("eGameEvent_Colse_UniWebView")
end

function ActivityManager:SignPushFacePanelDownLoadInHall()
  local activitySignList = ActivityManager:GetActivityListByType(MTTD.ActivityType_Sign)
  local prefabs = {}
  for _, act in pairs(activitySignList) do
    if act:checkShowRed() and act:isInActivityShowTime() then
      prefabs[#prefabs + 1] = act:GetSignPushFacePrefabName()
    end
  end
  return prefabs
end

function ActivityManager:GachaPushFacePanelDownLoadInHall()
  local allGachaPushFaceData = self:GetActivityListByType(MTTD.ActivityType_GachaJump)
  local gachaFacePanelList = {}
  local vSubResourcesExtra = {}
  for _, act in pairs(allGachaPushFaceData) do
    if act:checkShowRed() then
      gachaFacePanelList[#gachaFacePanelList + 1] = act:GetJumpPushFacePanelName()
      local vPackageSub, vResourcesExtra = SubPanelManager:GetSubPanelDownloadResourceExtra(act:GetJumpPushFaceSubPanelName())
      for _, data in pairs(vResourcesExtra) do
        vSubResourcesExtra[#vSubResourcesExtra + 1] = data
      end
      for _, data in pairs(vPackageSub) do
        gachaFacePanelList[#gachaFacePanelList + 1] = data
      end
    end
  end
  return gachaFacePanelList, vSubResourcesExtra
end

function ActivityManager:ReportEventLimit(eventName)
  if not MTTD or not MTTD.ActivityType_ModuleControl then
    return true
  end
  local activityModule = self:GetActivityByType(MTTD.ActivityType_ModuleControl)
  if not activityModule then
    return true
  end
  if not self.reportPercentList then
    self.reportPercentList = activityModule:GetReportpercentListData()
  end
  if self.reportPercentList then
    local uid = RoleManager:GetUID()
    if uid then
      local lastUid = math.floor(uid // 10 % 10)
      for _, value in ipairs(self.reportPercentList) do
        if value.sLogName == eventName then
          local paramArray = string.split(value.sExcludeUid, ";")
          for _, valueUid in ipairs(paramArray) do
            if valueUid == uid then
              return true
            end
          end
          if value.iLogPercent == 10 then
            return true
          end
          if value.iLogPercent == 0 then
            return false
          end
          if value.iLogOffset and value.iLogOffset ~= 0 then
            return (lastUid + value.iLogOffset) % 10 < value.iLogPercent
          end
          return lastUid < value.iLogPercent
        end
      end
    end
  end
  return true
end

function ActivityManager:ProcessParamListToTable(jumpParamList)
  if not jumpParamList then
    return
  end
  if #jumpParamList <= 1 then
    return
  end
  local jumpParamTab = {}
  for i = 2, #jumpParamList do
    local index = i - 1
    local num = index % 2
    if num == 0 then
      local paramKey = jumpParamList[i - 1]
      local paramValue = jumpParamList[i]
      jumpParamTab[paramKey] = paramValue
    end
  end
  return jumpParamTab
end

function ActivityManager:DealJump(jumpType, jumpParam)
  if not jumpType or not jumpParam then
    log.error("Activity Jump Defeat: jumpType or jumpParam is nil")
  end
  
  local function func()
  end
  
  if jumpType == ActivityManager.JumpType.Activity then
    function func()
      QuickOpenFuncUtil:OpenFunc(30001, {
        activityId = tonumber(jumpParam)
      })
    end
  elseif jumpType == ActivityManager.JumpType.URL then
    function func()
      CS.DeviceUtil.OpenURLNew(jumpParam)
    end
  elseif jumpType == ActivityManager.JumpType.System then
    function func()
      local strList = string.split(jumpParam, ";")
      
      local paramTab = self:ProcessParamListToTable(strList)
      QuickOpenFuncUtil:OpenFunc(tonumber(strList[1]), paramTab)
    end
  elseif jumpType == ActivityManager.JumpType.Elva then
    function func()
      SettingManager:PullAiHelpMessage()
    end
  elseif jumpType == ActivityManager.JumpType.Naver then
    function func()
    end
  else
    if jumpType == ActivityManager.JumpType.WebTokenUrl then
      function func()
        RoleManager:ReqGetUserToken(jumpParam)
      end
    else
    end
  end
  func()
end

function ActivityManager:IsInCensorOpen()
  local activityCom = self:GetActivityByType(MTTD.ActivityType_Censor)
  if not activityCom then
    return false
  end
  return activityCom:IsInCensor()
end

function ActivityManager:IsFullBurstDayOpen()
  local act = self:GetActivityByType(MTTD.ActivityType_FullBurstDay)
  if not act then
    return false
  end
  return act:IsFullBurstDay()
end

function ActivityManager:CheckEmergencyGift()
  local act = self:GetActivityByType(MTTD.ActivityType_EmergencyGift)
  if act then
    act:CheckCanShowGift()
  end
end

function ActivityManager:OnCheckVoucherControlAndUrl()
  local act = self:GetActivityByType(MTTD.ActivityType_VoucherControl)
  if act then
    return act:GetIsControl(), act:GetJumpUrl()
  end
  return false
end

function ActivityManager:OnCheckBattlePassRedInHall(actId)
  if actId then
    local stActivity = self:GetActivityByID(actId)
    if stActivity and stActivity:checkCondition() and stActivity:CheckRed() > 0 then
      return 1
    end
  end
  return 0
end

function ActivityManager:OnInitFetchMoreDataMustFail(messageId, msg)
end

return ActivityManager
