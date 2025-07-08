local M = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local __funcList = {}
__funcList[2001] = function(extData)
  local function openForm()
    if extData.ex_param[1] then
      local cfgIns = ConfigManager:GetConfigInsByName("MainLevel")
      
      local cfg = cfgIns:GetValue_ByLevelID(extData.ex_param[2])
      if cfg:GetError() then
        log.error("Jump Cfg error, wrong LevelID : " .. extData.ex_param[2])
        return
      end
      extData.levelSubType = cfg.m_LevelSubType
      if LevelManager:GetLevelMainHelper():IsLevelUnLock(cfg.m_LevelID) then
        extData.chapterIndex = tonumber(cfg.m_ChapterIndex) + 1
        extData.levelID = cfg.m_LevelID
      end
    end
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_LEVELMAIN, extData)
  end
  
  local curscene = GameSceneManager:GetCurScene()
  if curscene and curscene == GameSceneManager:GetGameScene(GameSceneManager.SceneID.LevelMap) then
    openForm()
  else
    LevelManager:LoadLevelMapScene(function()
      log.info("Form_Hall OnBtnfightClicked LevelMap LoadBack")
      openForm()
    end)
  end
end
__funcList[3001] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_TEAM, extData)
end
__funcList[4001] = function(extData)
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local time = tonumber(GlobalManagerIns:GetValue_ByName("AFKRequestInterval").m_Value) or 5
  if time < TimeUtil:GetServerTimeS() - tonumber(HangUpManager.m_iSeeRewardTime) then
    HangUpManager:ReqGetHangUpData()
  else
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HANGUPBATTLE)
    StackFlow:Push(UIDefines.ID_FORM_HANGUP, extData)
  end
end
__funcList[5001] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_TOWERCHOOSE, extData)
end
__funcList[6001] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_TASK, extData)
end
__funcList[6002] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_TASK, {
    chooseTab = TaskManager.TaskType.Daily
  })
end
__funcList[6003] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_TASK, {
    chooseTab = TaskManager.TaskType.Weekly
  })
end
__funcList[6004] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_TASK, {
    chooseTab = TaskManager.TaskType.MainTask
  })
end
__funcList[6005] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_TASK, {
    chooseTab = TaskManager.TaskType.Achievement
  })
end
__funcList[7001] = function(extData)
  if not FriendManager:GetFriendInfo() then
    utils.popUpDirectionsUI({
      tipsID = 1178,
      func1 = function()
      end
    })
    return
  end
  FriendManager:RqsFriendInfo(function()
    StackFlow:Push(UIDefines.ID_FORM_FRIENDMAIN)
  end)
end
__funcList[5002] = function(extData)
  if QuickOpenFuncUtil:CheckTowerLevelSubType(LevelManager.TowerLevelSubType.Tribe1) then
    StackFlow:Push(UIDefines.ID_FORM_TOWER, {
      subType = LevelManager.TowerLevelSubType.Tribe1
    })
  end
end
__funcList[5003] = function(extData)
  if QuickOpenFuncUtil:CheckTowerLevelSubType(LevelManager.TowerLevelSubType.Tribe2) then
    StackFlow:Push(UIDefines.ID_FORM_TOWER, {
      subType = LevelManager.TowerLevelSubType.Tribe2
    })
  end
end
__funcList[5004] = function(extData)
  if QuickOpenFuncUtil:CheckTowerLevelSubType(LevelManager.TowerLevelSubType.Tribe3) then
    StackFlow:Push(UIDefines.ID_FORM_TOWER, {
      subType = LevelManager.TowerLevelSubType.Tribe3
    })
  end
end
__funcList[5005] = function(extData)
  if QuickOpenFuncUtil:CheckTowerLevelSubType(LevelManager.TowerLevelSubType.Tribe4) then
    StackFlow:Push(UIDefines.ID_FORM_TOWER, {
      subType = LevelManager.TowerLevelSubType.Tribe4
    })
  end
end
__funcList[46001] = function(extData)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.ReplaceArena)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  local curServerTime = TimeUtil:GetServerTimeS()
  local curSeasonEndTime, nextSeasonStartTime = PvpReplaceManager:GetSeasonTimeByCfg()
  local m_isCurSeason = false
  if curServerTime < curSeasonEndTime then
    m_isCurSeason = true
  end
  if not m_isCurSeason then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40014)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_PVPREPLACEMAIN, extData)
end
__funcList[46002] = function(extData)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.LegacyLevel)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_LEGACYACTIVITYMAIN, extData)
end
__funcList[13000] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE, extData)
end
__funcList[13001] = function(extData)
  QuickOpenFuncUtil:GotoEquipmentChapter(extData)
end
__funcList[13002] = function(extData)
  QuickOpenFuncUtil:GotoEquipmentChapter(extData)
end
__funcList[13003] = function(extData)
  QuickOpenFuncUtil:GotoEquipmentChapter(extData)
end
__funcList[13004] = function(extData)
  QuickOpenFuncUtil:GotoEquipmentChapter(extData)
end
__funcList[13005] = function(extData)
  QuickOpenFuncUtil:GotoEquipmentChapter(extData)
end
__funcList[21001] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_STAGESELECT_NEW, extData)
end
__funcList[101001] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_HEROLIST, extData)
end
__funcList[24001] = function(extData)
  if InheritManager.m_inherit_level == 0 then
    InheritManager:ReqUnLockSystemInheritData()
  else
    StackFlow:Push(UIDefines.ID_FORM_INHERIT, extData)
  end
end
__funcList[24002] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_MATERIALSMAIN, extData)
end
__funcList[26001] = function(extData)
  local openFlag = ShopManager:CheckShopIsOpenByWinId(26001)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_SHOP, {sel_shop = 26001})
end
__funcList[26002] = function(extData)
  local openFlag = ShopManager:CheckShopIsOpenByWinId(26002)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_SHOP, {sel_shop = 26002})
end
__funcList[26003] = function(extData)
  local openFlag = ShopManager:CheckShopIsOpenByWinId(26003)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_SHOP, {sel_shop = 26003})
end
__funcList[26004] = function(extData)
  local openFlag = ShopManager:CheckShopIsOpenByWinId(26004)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_SHOP, {sel_shop = 26004})
end
__funcList[26005] = function(extData)
  local openFlag = ShopManager:CheckShopIsOpenByWinId(26005)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_SHOP, {sel_shop = 26005})
end
__funcList[26006] = function(extData)
  local openFlag = ShopManager:CheckShopIsOpenByWinId(26006)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHOP, {sel_shop = 26006})
end
__funcList[26007] = function(extData)
  local openFlag = ShopManager:CheckShopIsOpenByWinId(26007)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_SHOP, {sel_shop = 26007})
end
__funcList[27001] = function(extData)
  StackPopup:Push(UIDefines.ID_FORM_GUILDSIGN)
end
__funcList[27002] = function(extData)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Guild)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  local isBossOpen = GuildManager:CheckGuildBossIsOpen()
  local allianceId = RoleManager:GetRoleAllianceInfo()
  local hasAlliance = allianceId and tostring(allianceId) ~= "0"
  if not hasAlliance then
    GuildManager:ReqAllianceGetRecommendList()
    return
  end
  if isBossOpen and GuildManager:IsGuildBossTime() then
    StackFlow:Push(UIDefines.ID_FORM_GUILDRAIDMAIN, {requestFlag = true})
  else
    GuildManager:ReqGetOwnerAllianceDetail(allianceId)
  end
end
__funcList[27003] = function(extData)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Guild)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  local allianceId = RoleManager:GetRoleAllianceInfo()
  local hasAlliance = allianceId and tostring(allianceId) ~= "0"
  if not hasAlliance then
    GuildManager:ReqAllianceGetRecommendList()
    return
  end
end
__funcList[28001] = function(extData)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Arena)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  local curServerTime = TimeUtil:GetServerTimeS()
  local curSeasonEndTime, nextSeasonStartTime = ArenaManager:GetSeasonTimeByCfg() or 0
  local m_isCurSeason = false
  if curServerTime < curSeasonEndTime then
    m_isCurSeason = true
  end
  if not m_isCurSeason then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40014)
    return
  end
  ArenaManager:ReqOriginalArenaGetInit()
  StackFlow:Push(UIDefines.ID_FORM_PVPMAIN, extData)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
end
__funcList[190401] = function(extData)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Arena)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYPVP, extData)
end
__funcList[30001] = function(extData)
  local uiInfo = StackFlow:GetUIInstanceLua(UIDefines.ID_FORM_ACTIVITYMAIN)
  local act = ActivityManager:GetActivityByID(extData.activityId)
  if not act or not act:checkCondition(true) then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20068))
    return
  end
  if uiInfo and uiInfo.m_csui and uiInfo:IsActive() then
    uiInfo:ChooseActivityByID(tonumber(extData.activityId))
  else
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITYMAIN, tonumber(extData.activityId))
  end
end
__funcList[30002] = function(extData)
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_CommonQuest)
  local stActivity
  for key, act in pairs(act_list) do
    if act:GetUIType() == GlobalConfig.CommonQuestActType.DayTask_14 and tonumber(extData.activityId) == act:getID() then
      stActivity = act
      break
    end
  end
  if stActivity and stActivity:checkCondition() then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITYDAYTASK14)
  else
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20068))
  end
end
__funcList[40001] = function(extData)
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity then
    local list = payStoreActivity:GetNewStoreList()
    if list and 0 < #list then
      StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW)
    end
  end
end
__funcList[40002] = function(extData)
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity then
    local id = payStoreActivity:GetActivityGiftStoreID()
    if id ~= 0 then
      StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW, {iStoreId = id})
    end
  end
end
__funcList[40003] = function(extData)
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity then
    local id = payStoreActivity:GetFixedGiftStoreID()
    if id ~= 0 then
      StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW, {iStoreId = id})
    end
  end
end
__funcList[40007] = function(extData)
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity then
    local isCanJump, storeId1, subStoreId1 = payStoreActivity:GetChainPackState()
    if not isCanJump then
      if extData.defeatShow then
        extData.defeatShow()
      else
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13018)
      end
    end
    if isCanJump and storeId1 and subStoreId1 then
      StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW, {iStoreId = storeId1, subStoreId = subStoreId1})
    end
  end
end
__funcList[40004] = function(extData)
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity then
    local id = payStoreActivity:GetMonthlyCardStoreID()
    if id ~= 0 then
      StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW, {iStoreId = id})
    end
  end
end
__funcList[40006] = function(extData)
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity then
    local id = payStoreActivity:GetRechargeStoreID()
    if id ~= 0 then
      StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW, {iStoreId = id})
    end
  end
end
__funcList[53001] = function(extData)
  local placeID = tonumber(ConfigManager:GetGlobalSettingsByKey("CastleCouncilHallPlaceId"))
  local isUnlock, unlockTips = CastleManager:IsCastlePlaceUnlock(placeID)
  if isUnlock ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, unlockTips)
    return
  end
  CouncilHallManager:LoadCouncilHallScene()
end
__funcList[9000101] = function(extData)
  StackPopup:Push(UIDefines.ID_FORM_PERSONALRENAME)
end
__funcList[51001] = function(extData)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.CastleDispatch)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_CASTLEDISPATCHMAP)
end
__funcList[51002] = function(extData)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaShow)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_ACTIVITYFACEMAIN, extData)
end
__funcList[7002] = function(extData)
  local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.SoloRaid)
  if isOpen then
    PersonalRaidManager:ReqSoloRaidGetDataCS()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
end
__funcList[58001] = function(extData)
  StackFlow:Push(UIDefines.ID_FORM_ROGUESTAGEMAIN)
end
__funcList[60001] = function(extData)
  local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HuntingRaid)
  if isOpen then
    HuntingRaidManager:OpenHuntingRaidUI()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
end

function M:OpenFunc(jumpId, extData)
  if jumpId then
    local jumpIns = ConfigManager:GetConfigInsByName("Jump")
    local jump_item = jumpIns:GetValue_ByJumpID(jumpId)
    if jump_item then
      local open_condition_id = jump_item.m_SystemID or 0
      local open_flag, tips_id = UnlockSystemUtil:IsSystemOpen(open_condition_id)
      if 0 < open_condition_id and not open_flag then
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
        return
      end
      local func = __funcList[jump_item.m_WindowID]
      if func then
        local ex_param = utils.changeCSArrayToLuaTable(jump_item.m_Param)
        if extData and type(extData) == "table" then
          extData.jumpId = jumpId
          extData.ex_param = ex_param
        elseif extData == nil then
          extData = {jumpId = jumpId, ex_param = ex_param}
        end
        func(extData)
        if extData and extData.guideTaskId then
          EventCenter.Broadcast(EventDefine.eGameEvent_MainTask_Jump_Guide, {
            taskId = extData.guideTaskId
          })
        end
        return
      end
      self:GotoSystemSeriesWindow(jump_item.m_SystemID, jump_item.m_WindowID, extData)
    end
  else
    log.warn("go to func cfg not found : " .. tostring(jumpId))
  end
end

function M:GotoSystemSeriesWindow(systemID, windowID, extData)
  if systemID == GlobalConfig.SYSTEM_ID.Gacha then
    local itemCfg = GachaManager:GetGachaConfigByWindowId(windowID)
    if itemCfg then
      local flag = UnlockSystemUtil:CheckGachaIsOpenById(itemCfg.m_GachaID)
      if flag then
        GachaManager:GetGachaData(windowID)
      else
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40024)
      end
    else
      log.error("can not find gachaPool windowId == " .. tostring(windowID))
    end
  else
    log.warn("go to func id not found : " .. tostring(systemID))
  end
end

function M:GotoEquipmentChapter(extData)
  local chapterIndex = 1
  local equipHelper = LevelManager:GetLevelEquipmentHelper()
  if type(extData) == "table" and extData.chapterIndex then
    chapterIndex = extData.chapterIndex
  else
    local cfg = equipHelper:GetDunChapterByJumpId(extData.jumpId)
    chapterIndex = cfg.m_Order
  end
  local chapterInfo = equipHelper:GetDunChapterByOrderId(chapterIndex)
  local isUnlock, unlockType, unlockStr = equipHelper:IsChapterSubTypeUnlock(chapterInfo.m_LevelSubType)
  if not isUnlock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, unlockStr)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE, {chapterIndex = chapterIndex})
end

function M:CheckTowerLevelSubType(subTowerType)
  if not subTowerType then
    return
  end
  local m_levelTowerHelper = LevelManager:GetLevelHelperByType(LevelManager.LevelType.Tower)
  local TowerCfgIns = ConfigManager:GetConfigInsByName("Tower")
  local towerSubTypeCfg = TowerCfgIns:GetValue_ByLevelSubType(subTowerType)
  if towerSubTypeCfg:GetError() then
    return
  end
  local isSubTypeUnlock = m_levelTowerHelper:IsLevelSubTypeUnlock(subTowerType)
  if isSubTypeUnlock ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, towerSubTypeCfg.m_ClientMessage)
    return
  end
  local isSubTypeInOpen = m_levelTowerHelper:IsLevelSubTypeInOpen(subTowerType)
  if isSubTypeInOpen ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 21006)
    return
  end
  return true
end

return M
