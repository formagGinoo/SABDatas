local BaseManager = require("Manager/Base/BaseManager")
local HeroActivityManager = class("HeroActivityManager", BaseManager)
HeroActivityManager.CorveTimeType = {
  main = 1,
  Level = 2,
  sub = 3,
  minigame = 4,
  gacha = 5,
  shop = 6,
  shopGoods = 7
}
HeroActivityManager.SubTypeIndex = {
  Default = 1,
  WhackMole = 2,
  Explore = 1001
}
HeroActivityManager.MiniGameType = {
  Memory = 1,
  WhackMole = 2,
  Explore = 1001
}
HeroActivityManager.SubActTypeEnum = {
  NormalLevel = 11,
  DiffLevel = 12,
  ChallengeLevel = 13,
  Sign = 14,
  Task = 15,
  MiniGame = 16,
  BattlePass = 17,
  DailyTask = 18,
  GameTask = 19
}
HeroActivityManager.ActMemoryTextType = {
  TimeSelect = 1,
  PlaceSelect = 2,
  Final = 3
}
HeroActivityManager.HeroActTaskType = {daily = 1, once = 2}
HeroActivityManager.SubActUnlockType = {ActLamiaLevel = 1}
HeroActivityManager.WhackMoleLevelType = {
  NormalType = 1,
  BossType = 2,
  InfinityType = 3
}
HeroActivityManager.ActivityType = {Normal = 1, Stages = 2}
local ActMemoryTextFormatByType = {}
local pairs = _ENV.pairs
local ipairs = _ENV.ipairs

function HeroActivityManager:OnCreate()
  self.m_actList = {}
  self.m_cacheReportData = {}
  self.isPush = false
  self.MainIDMapSubID = {}
  self:addEventListener("eGameEvent_Legacy_ActivityTreasureBox", handler(self, self.OpenTreasureBox))
end

function HeroActivityManager:OnInitNetwork()
  RPCS():Listen_Push_Lamia_Quest(handler(self, self.OnPushLamiaQuest), "HeroActivityManager")
  local report_time_interval = tonumber(ConfigManager:GetGlobalSettingsByKey("iReportInterval") or 60)
  TimeService:SetTimer(report_time_interval, -1, function()
    self:ReportActInfo()
  end)
end

function HeroActivityManager:OnDailyReset()
  self.isPush = false
  local lamia_getlist_msg = MTTDProto.Cmd_Lamia_GetList_CS()
  RPCS():Lamia_GetList(lamia_getlist_msg, handler(self, self.OnLamiaGetListSC))
end

function HeroActivityManager:OnDailyZeroReset()
  self.isPush = false
  local lamia_getlist_msg = MTTDProto.Cmd_Lamia_GetList_CS()
  RPCS():Lamia_GetList(lamia_getlist_msg, handler(self, self.OnLamiaGetListSC))
end

function HeroActivityManager:OnDestroy()
end

function HeroActivityManager:OnInitMustRequestInFetchMore()
  self:DealActivityData()
end

function HeroActivityManager:DealActivityData()
  local lamia_getlist_msg = MTTDProto.Cmd_Lamia_GetList_CS()
  RPCS():Lamia_GetList(lamia_getlist_msg, handler(self, self.OnLamiaGetListSC))
end

function HeroActivityManager:OnPushLamiaQuest(data)
  local iActId = data.iActId
  for i, v in pairs(data.vQuest) do
    self:UpdateLamiaQuestInfo(iActId, v)
  end
  self:broadcastEvent("eGameEvent_ActTask_GetReward")
end

function HeroActivityManager:OnLamiaGetListSC(act_list_data)
  local list = act_list_data.vList
  local m_actList = {}
  for k, data in pairs(list) do
    m_actList[data.iActId] = {
      config = self:GetMainInfoByActID(data.iActId),
      server_data = data
    }
  end
  self.m_actList = m_actList
  LevelHeroLamiaActivityManager:InitLevelData(act_list_data.vList)
  self:_MapMainIDAndSubId()
  self:broadcastEvent("eGameEvent_HeroAct_DailyReset")
end

function HeroActivityManager:RequestRecReward(act_id)
  local rqs_getAward = MTTDProto.Cmd_Lamia_SignIn_GetAward_CS()
  rqs_getAward.iActId = act_id
  RPCS():Lamia_SignIn_GetAward(rqs_getAward, handler(self, self.LamiaSignInGetAwardSC))
  self:SetPushFlag()
end

function HeroActivityManager:LamiaSignInGetAwardSC(data)
  local reward_list = data.vAward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  local act_data = self:GetHeroActData(data.iActId)
  if act_data then
    act_data.server_data.stSign.iAwardedMaxDays = data.iAwardedMaxDays
  end
  self:broadcastEvent("eGameEvent_ActSign_GetReward", data.iAwardedMaxDays)
end

function HeroActivityManager:ReqLamiaQuestGetAwardCS(iActId, iQuestId)
  local reqMsg = MTTDProto.Cmd_Lamia_Quest_GetAward_CS()
  reqMsg.iActId = iActId
  reqMsg.iQuestId = iQuestId
  RPCS():Lamia_Quest_GetAward(reqMsg, handler(self, self.OnReqLamiaQuestGetAwardSC))
end

function HeroActivityManager:OnReqLamiaQuestGetAwardSC(data)
  local reward_list = data.vAward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  self:UpdateLamiaQuestInfo(data.iActId, data.stQuest)
  self:broadcastEvent("eGameEvent_ActTask_GetReward")
end

function HeroActivityManager:ReqLamiaGameQuestGetAwardCS(iActId, iQuestId)
  local reqMsg = MTTDProto.Cmd_Lamia_GameQuest_GetAward_CS()
  reqMsg.iActId = iActId
  reqMsg.iQuestId = iQuestId
  RPCS():Lamia_GameQuest_GetAward(reqMsg, handler(self, self.OnReqLamiaGameQuestGetAwardSC))
end

function HeroActivityManager:OnReqLamiaGameQuestGetAwardSC(data)
  local reward_list = data.vAward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  self:UpdateLamiaQuestInfo(data.iActId, data.stQuest)
  self:broadcastEvent("eGameEvent_ActTask_GetReward")
end

function HeroActivityManager:ReqLamiaQuestGetAllAwardCS(iActId)
  local reqMsg = MTTDProto.Cmd_Lamia_Quest_GetAllAward_CS()
  reqMsg.iActId = iActId
  RPCS():Lamia_Quest_GetAllAward(reqMsg, handler(self, self.OnReqLamiaQuestGetAllAwardSC))
end

function HeroActivityManager:OnReqLamiaQuestGetAllAwardSC(data)
  local reward_list = data.vAward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  for i, v in pairs(data.vQuest) do
    self:UpdateLamiaQuestInfo(data.iActId, v)
  end
  self:broadcastEvent("eGameEvent_ActTask_GetAllReward")
end

function HeroActivityManager:ReqLamiaDailyQuestGetAwardCS(iActId, vQuestId)
  local reqMsg = MTTDProto.Cmd_Lamia_DailyQuest_GetAward_CS()
  reqMsg.iActId = iActId
  reqMsg.vQuestId = vQuestId
  RPCS():Lamia_DailyQuest_GetAward(reqMsg, handler(self, self.OnReqLamiaDailyQuestGetAwardSC))
end

function HeroActivityManager:OnReqLamiaDailyQuestGetAwardSC(scData)
  local reward_list = scData.vAward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  for i, v in pairs(scData.vQuest) do
    self:UpdateLamiaQuestInfo(scData.iActId, v)
  end
  local taskData = self:GetActTaskServerData(scData.iActId)
  if taskData then
    taskData.iDaiyQuestActive = scData.iDaiyQuestActive
  end
  self:broadcastEvent("eGameEvent_ActTask_GetReward")
end

function HeroActivityManager:UpdateLamiaQuestInfo(act_id, stQuest)
  local data = self:GetHeroActData(act_id)
  if not data or not stQuest then
    log.error("UpdateLamiaQuestInfo is error act_id = " .. tostring(act_id))
    return
  end
  local server_data = data.server_data
  if server_data then
    local quest = server_data.stQuest
    if quest and quest.vDailyQuest then
      for i, v in pairs(quest.vDailyQuest) do
        if v.iId == stQuest.iId then
          quest.vDailyQuest[i] = stQuest
          break
        end
      end
      if quest.vGameQuest then
        for i, v in pairs(quest.vGameQuest) do
          if v.iId == stQuest.iId then
            quest.vGameQuest[i] = stQuest
            break
          end
        end
      end
      local vQuest = quest.vQuest
      for i = table.getn(vQuest), 1, -1 do
        if vQuest[i].iId == stQuest.iId then
          vQuest[i] = stQuest
          return
        end
      end
    end
  end
end

function HeroActivityManager:ReqHeroActMiniGameFinishCS(iActId, iSubActId, iGameId, iScore)
  local rqs_finishMemory = MTTDProto.Cmd_Lamia_MiniGame_Finish_CS()
  rqs_finishMemory.iActId = iActId
  rqs_finishMemory.iSubActId = iSubActId
  rqs_finishMemory.iGameId = iGameId
  rqs_finishMemory.iScore = iScore
  RPCS():Lamia_MiniGame_Finish(rqs_finishMemory, handler(self, self.LamiaGameFinishSC))
end

function HeroActivityManager:LamiaGameFinishSC(data)
  local act_data = self:GetHeroActData(data.iActId)
  if act_data then
    act_data.server_data.stMiniGame.mGameStat[data.iGameId] = data.iGameStat
  end
  self:broadcastEvent("eGameEvent_ActMinigame_Finish", data.vAward)
end

function HeroActivityManager:ReqHeroActMiniGameFinishCS_UI(iActId, iSubActId, iGameId, iScore)
  local rqs_finishMemory = MTTDProto.Cmd_Lamia_MiniGame_Finish_CS()
  rqs_finishMemory.iActId = iActId
  rqs_finishMemory.iSubActId = iSubActId
  rqs_finishMemory.iGameId = iGameId
  rqs_finishMemory.iScore = iScore
  RPCS():Lamia_MiniGame_Finish(rqs_finishMemory, handler(self, self.LamiaGameFinishSC_UI))
end

function HeroActivityManager:LamiaGameFinishSC_UI(data)
  local act_data = self:GetHeroActData(data.iActId)
  if act_data then
    act_data.server_data.stMiniGame.mGameStat[data.iGameId] = data.iGameStat
  end
  utils.popUpRewardUI(data.vAward)
end

function HeroActivityManager:ReqLamiaGameGetAllAwardCS(iActId, iSubActId)
  local rqs_GetAllAward = MTTDProto.Cmd_Lamia_MiniGame_GetAllAward_CS()
  rqs_GetAllAward.iActId = iActId
  rqs_GetAllAward.iSubActId = iSubActId
  RPCS():Lamia_MiniGame_GetAllAward(rqs_GetAllAward, handler(self, self.LamiaGameGetAllAwardSC))
end

function HeroActivityManager:LamiaGameGetAllAwardSC(data)
  local reward_list = data.vAward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  local act_data = self:GetHeroActData(data.iActId)
  if act_data then
    act_data.server_data.stMiniGame.iMaxAwardedGame = data.iMaxAwardedGame
  end
  self:broadcastEvent("eGameEvent_ActMemory_GetAllReward")
end

function HeroActivityManager:ReqAct4ClueGetAwardCS(iActId, iClueId)
  local rqs_getAward = MTTDProto.Cmd_Lamia_GetClueAward_CS()
  rqs_getAward.iActId = iActId
  rqs_getAward.iClueID = iClueId
  RPCS():Lamia_GetClueAward(rqs_getAward, handler(self, self.LamiaClueGetAwardSC))
end

function HeroActivityManager:LamiaClueGetAwardSC(data)
  local reward_list = data.vReward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  local act_data = self:GetHeroActData(data.iActId)
  if act_data then
    act_data.server_data.vAwardedClue = data.vAwardedClue
  end
  self:broadcastEvent("eGameEvent_Act4ClueGetAward")
end

function HeroActivityManager:ReqLamiaGetSubActAwardCS(iActId, iSubActId, callback)
  local rqs_getAward = MTTDProto.Cmd_Lamia_GetSubActAward_CS()
  rqs_getAward.iActId = iActId
  rqs_getAward.iSubActId = iSubActId
  RPCS():Lamia_GetSubActAward(rqs_getAward, function(data)
    local reward_list = data.vRewards
    if reward_list and next(reward_list) then
      utils.popUpRewardUI(reward_list)
    end
    local act_data = self:GetHeroActData(iActId)
    if not act_data then
      log.error("GetActTaskServerData is error act_id = " .. tostring(iActId))
      return
    end
    local server_data = act_data.server_data
    if server_data then
      server_data.vAwardedSubAct = data.vAwardedSubAct
    end
    if callback then
      callback(data)
    end
    self:broadcastEvent("eGameEvent_ActMinigame_GetReward")
  end)
end

function HeroActivityManager:IsSubActAwarded(iActId, iSubActId)
  local act_data = self:GetHeroActData(iActId)
  if not act_data then
    return false
  end
  if not act_data.server_data or not act_data.server_data.vAwardedSubAct then
    return false
  end
  local bIsGot = false
  for i, v in ipairs(act_data.server_data.vAwardedSubAct) do
    if v == iSubActId then
      bIsGot = true
      break
    end
  end
  return bIsGot
end

function HeroActivityManager:_MapMainIDAndSubId()
  local list = self:GetOpenActList()
  self.MainIDMapSubID = {}
  for config_id, act_data in pairs(list) do
    self.MainIDMapSubID[config_id] = self.MainIDMapSubID[config_id] or {}
    local main_config = self:GetMainInfoByActID(config_id)
    if not main_config then
      log.error("HeroActivityManager:_MapMainIDAndSubId error! config_id = " .. tostring(config_id))
      return
    end
    local sub_function_ids = utils.changeCSArrayToLuaTable(main_config.m_SubFunctionID)
    for _, sub_config_id in pairs(sub_function_ids) do
      local sub_config = self:GetSubInfoByID(sub_config_id)
      local type = sub_config.m_ActivitySubType
      self.MainIDMapSubID[config_id][type] = self.MainIDMapSubID[config_id][type] or {}
      self.MainIDMapSubID[config_id][type][sub_config.m_SubTypeIndex] = sub_config_id
    end
  end
end

function HeroActivityManager:GetAllMainInfoConfig()
  return ConfigManager:GetConfigInsByName("ActivityMainInfo"):GetAll()
end

function HeroActivityManager:GetMainInfoByActID(config_id)
  if not config_id then
    log.error("获取角色活动配置失败，config_id不能为nil！")
    return
  end
  local config = ConfigManager:GetConfigInsByName("ActivityMainInfo"):GetValue_ByActivityID(config_id)
  if config:GetError() then
    log.error("获取角色活动配置失败，无效的config_id：" .. tostring(config_id))
    return
  end
  return config
end

function HeroActivityManager:GetSubInfoByID(config_id)
  if not config_id then
    log.error("获取角色活动配置失败，config_id不能为nil！")
    return
  end
  local config = ConfigManager:GetConfigInsByName("ActivitySubInfo"):GetValue_ByActivitySubID(config_id)
  if config:GetError() then
    log.error("获取角色活动配置失败，无效的config_id：" .. tostring(config_id))
    return
  end
  return config
end

function HeroActivityManager:GetActSignConfigByID(config_id)
  if not config_id then
    log.error("获取签到配置失败，config_id不能为nil！")
    return
  end
  local t = ConfigManager:GetConfigInsByName("ActSignin"):GetValue_ByActivitySubID(config_id)
  local config = {}
  for k, v in pairs(t) do
    if v.m_Day then
      config[v.m_Day] = v
    end
  end
  return config
end

function HeroActivityManager:GetActSignConfigByIDAndDay(config_id, day)
  day = day or 1
  if not config_id then
    log.error("获取签到配置失败，config_id不能为nil！")
    return
  end
  local config = ConfigManager:GetConfigInsByName("ActSignin"):GetValue_ByActivitySubIDAndDay(config_id, day)
  if config:GetError() then
    log.error("获取签到活动配置失败，参数无效！config_id：" .. tostring(config_id) .. "----day" .. day)
    return
  end
  return config
end

function HeroActivityManager:GetActMemoryInfoCfgByID(config_id)
  if not config_id then
    log.error("获取碎片叙事配置失败，config_id不能为nil！")
    return
  end
  local config = ConfigManager:GetConfigInsByName("ActMemoryInfo"):GetValue_ByFunID(config_id)
  return config
end

function HeroActivityManager:GetActWhackMoleInfoCfgByID(config_id)
  if not config_id then
    log.error("获取小游戏打地鼠配置失败，config_id不能为nil！")
    return
  end
  local allConfig = ConfigManager:GetConfigInsByName("MiniGameA3WhackaMoleLevel"):GetValue_BySubActID(config_id)
  return allConfig
end

function HeroActivityManager:GetActWhackMoleInfoCfgByIDAndLevelId(config_id, index)
  if not config_id or not index then
    log.error("获取打地鼠关卡配置失败，config_id or index不能为nil！", config_id, index)
    return
  end
  local levelCfg = ConfigManager:GetConfigInsByName("MiniGameA3WhackaMoleLevel"):GetValue_BySubActIDAndLevelID(config_id, index)
  if levelCfg:GetError() then
    log.error("获取打地鼠关卡配置失败，参数无效！", config_id, index)
    return
  end
  return levelCfg
end

function HeroActivityManager:GetActMemoryInfoCfgByIDAndIdx(config_id, index)
  if not config_id or not index then
    log.error("获取碎片叙事选项配置失败，config_id or index不能为nil！", config_id, index)
    return
  end
  local config = ConfigManager:GetConfigInsByName("ActMemoryInfo"):GetValue_ByFunIDAndMemoryID(config_id, index)
  if config:GetError() then
    log.error("获取碎片叙事配置失败，参数无效！", config_id, index)
    return
  end
  return config
end

function HeroActivityManager:GetCurMemorysPre(config_id, index)
  local cur_config = self:GetActMemoryInfoCfgByIDAndIdx(config_id, index)
  if not cur_config then
    return
  end
  if not cur_config.m_PreMemoryID or cur_config.m_PreMemoryID <= 0 then
    return
  end
  return self:GetActMemoryInfoCfgByIDAndIdx(config_id, cur_config.m_PreMemoryID)
end

function HeroActivityManager:GetFormatActMemoryTextCfgByID(config_id)
  if not config_id then
    log.error("获取碎片叙事文本配置失败，config_id不能为nil！")
    return
  end
  if ActMemoryTextFormatByType[config_id] then
    return ActMemoryTextFormatByType[config_id]
  end
  local t = {}
  local config = ConfigManager:GetConfigInsByName("ActMemoryText"):GetValue_ByMemoryID(config_id)
  for _, v in pairs(config) do
    t[v.m_Para] = t[v.m_Para] or {}
    t[v.m_Para][v.m_TextID] = v
  end
  ActMemoryTextFormatByType[config_id] = t
  return t
end

function HeroActivityManager:GetActMemoryChoiceByType(type)
  if not type then
    log.error("GetActMemoryChoiceByType : type不能为nil！", type)
    return
  end
  local t = ConfigManager:GetConfigInsByName("ActMemoryChoice"):GetValue_ByType(type)
  local config = {}
  for _, v in pairs(t) do
    if v.m_ChoiceID then
      config[v.m_ChoiceID] = v
    end
  end
  return config
end

function HeroActivityManager:GetActMemoryChoiceByTypeAndChoiceID(type, id)
  if not type or not id then
    log.error("获取碎片叙事选项配置失败，type or id不能为nil！", type, id)
    return
  end
  local config = ConfigManager:GetConfigInsByName("ActMemoryChoice"):GetValue_ByTypeAndChoiceID(type, id)
  if config:GetError() then
    log.error("获取碎片叙事文本配置失败，参数无效！config_id：", type, id)
    return
  end
  return config
end

function HeroActivityManager:GetActActLamiaBonusChaCfgsByGroup(act_id)
  local ActLamiaBonusChaCfg = ConfigManager:GetConfigInsByName("ActLamiaBonusCha")
  local all_config = ActLamiaBonusChaCfg:GetValue_ByActivityID(act_id)
  local configs = {}
  for k, v in pairs(all_config) do
    if v.m_UID and v.m_UID > 0 then
      configs[v.m_UID] = v
    end
  end
  table.sort(configs, function(a, b)
    return a.m_Sort < b.m_Sort
  end)
  return configs
end

function HeroActivityManager:GetWhackaMoleEnemyCfgByID(iID)
  local MiniGameA3WhackaMoleEnemyCfg = ConfigManager:GetConfigInsByName("MiniGameA3WhackaMoleEnemy")
  local cfg = MiniGameA3WhackaMoleEnemyCfg:GetValue_ByID(iID)
  if cfg:GetError() then
    log.error("HeroActivityManager:GetWhackaMoleEnemyCfgByID error！config_id：", iID)
    return
  end
  return cfg
end

function HeroActivityManager:GetAllActTimeByActID(act_id)
  local main_config = self:GetMainInfoByActID(act_id)
  if not main_config then
    log.error("HeroActivityManager:GetAllActTimeByActID error！act_id：", act_id)
    return 0, 0, 0, 0
  end
  local startTime = TimeUtil:TimeStringToTimeSec2(main_config.m_OpenTime) or 0
  local changeTime = TimeUtil:TimeStringToTimeSec2(main_config.m_ChangeTime) or 0
  local endTime = TimeUtil:TimeStringToTimeSec2(main_config.m_EndTime) or 0
  local closeTime = TimeUtil:TimeStringToTimeSec2(main_config.m_CloseTime) or 0
  return startTime, changeTime, endTime, closeTime
end

function HeroActivityManager:GetAct4ClueCfgByID(id)
  local act4ClueCfg = ConfigManager:GetConfigInsByName("Act4Clue"):GetValue_ByID(id)
  if act4ClueCfg:GetError() then
    log.warn("HeroActivityManager:GetAct4ClueCfgByID error！act_id：", id)
    return
  end
  return act4ClueCfg
end

function HeroActivityManager:GetOpenActList()
  return self.m_actList or {}
end

function HeroActivityManager:GetHeroActData(act_id)
  if not act_id then
    return
  end
  return self.m_actList[act_id]
end

function HeroActivityManager:GetPushFlag()
  return self.isPush
end

function HeroActivityManager:SetPushFlag()
  self.isPush = true
end

HeroActivityManager.ActOpenState = {
  Normal = 1,
  WaitingClose = 2,
  Closed = 3
}

function HeroActivityManager:GetActOpenState(config_id, bIsSecondHalf)
  local startTime, changeTime, endTime, closeTime = self:GetAllActTimeByActID(config_id)
  local is_corved, t1, t2, t3 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.main, config_id)
  if is_corved then
    startTime, endTime, changeTime = t1, t2, t3
  end
  if bIsSecondHalf then
    startTime = changeTime
  end
  if TimeUtil:IsInTime(startTime, endTime) then
    return HeroActivityManager.ActOpenState.Normal, endTime, startTime
  end
  if TimeUtil:IsInTime(startTime, closeTime) then
    return HeroActivityManager.ActOpenState.WaitingClose, closeTime
  end
  return HeroActivityManager.ActOpenState.Closed, startTime
end

function HeroActivityManager:CheckIsCorveTimeByType(type, param)
  if type == HeroActivityManager.CorveTimeType.main then
    return self:CheckMainIsCoverTime(param)
  end
  if type == HeroActivityManager.CorveTimeType.sub then
    return self:CheckSubIsCoverTime(param)
  end
  if type == HeroActivityManager.CorveTimeType.Level then
    return self:CheckLevelIsCoverTime(param)
  end
  if type == HeroActivityManager.CorveTimeType.minigame then
    return self:CheckMemoryIsCorveTime(param)
  end
  if type == HeroActivityManager.CorveTimeType.shop then
    return self:CheckShopIsCorveTime(param)
  end
  if type == HeroActivityManager.CorveTimeType.shopGoods then
    return self:CheckShopGoodsIsCorveTime(param)
  end
  if type == HeroActivityManager.CorveTimeType.gacha then
    return self:CheckGachaIsCorveTime(param)
  end
end

function HeroActivityManager:CheckGachaIsCorveTime(params)
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_LamiaTimeManager)
  for _, mHeroActTimeActivity in ipairs(act_list) do
    local cfg = mHeroActTimeActivity:GetHeroActTimeCfgByActID(params.id)
    if cfg then
      local corveCfg = cfg.mGachaCfg[params.gacha_id]
      if corveCfg then
        return true, corveCfg.iBeginTime or 0, corveCfg.iEndTime or 0
      end
    end
  end
end

function HeroActivityManager:CheckShopGoodsIsCorveTime(params)
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_LamiaTimeManager)
  for _, mHeroActTimeActivity in ipairs(act_list) do
    if params.id then
      local cfg = mHeroActTimeActivity:GetHeroActTimeCfgByActID(params.id)
      if cfg then
        local corveCfg = cfg.mShopGoodsCfg and cfg.mShopGoodsCfg[params.iGroupID]
        if corveCfg and corveCfg.iGoodsId == params.iGoodsId then
          return true, corveCfg
        end
      end
    else
      local cfgList = mHeroActTimeActivity:GetHeroActTimeCfgList()
      if cfgList then
        for _, cfg in pairs(cfgList) do
          local corveCfg = cfg.mShopGoodsCfg and cfg.mShopGoodsCfg[params.iGroupID]
          if corveCfg and corveCfg.iGoodsId == params.iGoodsId then
            return true, corveCfg
          end
        end
      end
    end
  end
end

function HeroActivityManager:CheckShopIsCorveTime(params)
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_LamiaTimeManager)
  for _, mHeroActTimeActivity in ipairs(act_list) do
    local cfg = mHeroActTimeActivity:GetHeroActTimeCfgByActID(params.id)
    if cfg then
      local corveCfg = cfg.mShopCfg[params.shop_id]
      if corveCfg then
        return true, corveCfg.iBeginTime or 0, corveCfg.iEndTime or 0
      end
    end
  end
end

function HeroActivityManager:CheckMemoryIsCorveTime(params)
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_LamiaTimeManager)
  for _, mHeroActTimeActivity in ipairs(act_list) do
    local cfg = mHeroActTimeActivity:GetHeroActTimeCfgByActID(params.id)
    if cfg then
      local corveCfg = cfg.mMiniGameCfg[params.m_MemoryID]
      if corveCfg then
        return true, corveCfg.iOpenTime or 0, 0
      end
    end
  end
end

function HeroActivityManager:CheckLevelIsCoverTime(levelCfg)
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_LamiaTimeManager)
  for _, mHeroActTimeActivity in ipairs(act_list) do
    local corveCfg = mHeroActTimeActivity:GetHeroActTimeCfgByActID(levelCfg.m_ActivityID)
    if corveCfg then
      local cfg = corveCfg.mActLamiaLevelCfg[levelCfg.m_LevelID]
      if cfg then
        return true, cfg.iOpenTime or 0, 0
      end
    end
  end
end

function HeroActivityManager:CheckSubIsCoverTime(sub_id)
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_LamiaTimeManager)
  for _, mHeroActTimeActivity in ipairs(act_list) do
    local startTime, closeTime
    local subCfg = self:GetSubInfoByID(sub_id)
    local cfg = mHeroActTimeActivity:GetHeroActTimeCfgByActID(subCfg.m_ActivityID)
    if cfg then
      local corveCfg = cfg.mActivitySubCfg[sub_id]
      if corveCfg then
        startTime = corveCfg.iBeginTime or 0
        closeTime = corveCfg.iEndTime or 0
        return true, startTime, closeTime
      end
    end
  end
end

function HeroActivityManager:CheckMainIsCoverTime(main_id)
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_LamiaTimeManager)
  for _, mHeroActTimeActivity in ipairs(act_list) do
    local startTime, closeTime, changeTime
    local cfg = mHeroActTimeActivity:GetHeroActTimeCfgByActID(main_id)
    if cfg then
      startTime = cfg.iOpenTime or 0
      closeTime = cfg.iCloseTime or 0
      changeTime = cfg.iChangeTime or 0
      return true, startTime, closeTime, changeTime
    end
  end
end

function HeroActivityManager:IsMainActIsOpenByID(config_id)
  local main_config = self:GetMainInfoByActID(config_id)
  if not main_config then
    log.error("HeroActivityManager:IsMainActIsOpenByID error! config_id = " .. tostring(config_id))
    return false
  end
  local startTime, changeTime, endTime, closeTime = self:GetAllActTimeByActID(config_id)
  local is_corved, t1, t2 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.main, config_id)
  if is_corved then
    startTime, closeTime = t1, t2
  end
  local temp_time = closeTime ~= 0 and closeTime or endTime
  local main_open_flag = TimeUtil:IsInTime(startTime, temp_time)
  if not main_open_flag then
    log.info(string.format("TODO: 返回一个提示时间不对的提示字符串%s---%s", startTime, temp_time))
    return false
  end
  local unlockTypeArray = main_config.m_UnlockConditionType
  local unlockConditionArray = main_config.m_UnlockConditionData
  local unlockTypeList = utils.changeCSArrayToLuaTable(unlockTypeArray)
  local unlockConditionDataList = utils.changeCSArrayToLuaTable(unlockConditionArray)
  local unlock_flag, unlock_type, lock_str = ConditionManager:IsMulConditionUnlockNew(unlockTypeList, unlockConditionDataList)
  if not unlock_flag then
    return false, unlock_type, lock_str
  end
  return true
end

function HeroActivityManager:IsSubActIsOpenByID(config_id, sub_config_id)
  local unlock_flag, unlock_type, lock_str = self:IsMainActIsOpenByID(config_id)
  if not unlock_flag then
    return unlock_flag, unlock_type, lock_str
  end
  local main_config = self:GetMainInfoByActID(config_id)
  if not main_config then
    log.error("HeroActivityManager:IsSubActIsOpenByID error! config_id = " .. tostring(config_id))
    return false
  end
  local sub_function_ids = utils.changeCSArrayToLuaTable(main_config.m_SubFunctionID)
  if not table.find(sub_function_ids, sub_config_id) then
    return false
  end
  local sub_config = self:GetSubInfoByID(sub_config_id)
  local startTime = TimeUtil:TimeStringToTimeSec2(sub_config.m_OpenTime) or 0
  local endTime = TimeUtil:TimeStringToTimeSec2(sub_config.m_EndTime) or 0
  local is_corved, t1, t2 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.sub, sub_config_id)
  if is_corved then
    startTime, endTime = t1, t2
  end
  local sub_open_flag = TimeUtil:IsInTime(startTime, endTime)
  local unlockTypeArray = sub_config.m_UnlockType
  local unlockConditionArray = sub_config.m_UnlockData
  local unlockTypeList = utils.changeCSArrayToLuaTable(unlockTypeArray)
  local unlockConditionDataList = utils.changeCSArrayToLuaTable(unlockConditionArray)
  unlock_flag, unlock_type, lock_str = self:IsSubActivityUnlock(unlockTypeList, unlockConditionDataList)
  return sub_open_flag and unlock_flag, unlock_type, lock_str
end

function HeroActivityManager:IsSubActInOpenTime(subActivityID)
  local subConfig = self:GetSubInfoByID(subActivityID)
  if not subConfig then
    return
  end
  local startTime = TimeUtil:TimeStringToTimeSec2(subConfig.m_OpenTime) or 0
  local endTime = TimeUtil:TimeStringToTimeSec2(subConfig.m_EndTime) or 0
  local is_corved, t1, t2 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.sub, subActivityID)
  if is_corved then
    startTime, endTime = t1, t2
  end
  local isInOpenTime = TimeUtil:IsInTime(startTime, endTime)
  return isInOpenTime
end

function HeroActivityManager:GetSubFuncID(main_id, sub_func_type, index)
  index = index or 1
  return self.MainIDMapSubID[main_id] and self.MainIDMapSubID[main_id][sub_func_type] and self.MainIDMapSubID[main_id][sub_func_type][index]
end

function HeroActivityManager:GetActJumpInfo(main_id, sub_id)
  local unlock_flag, unlock_type, lock_str = self:IsMainActIsOpenByID(main_id)
  if sub_id then
    unlock_flag, unlock_type, lock_str = self:IsSubActIsOpenByID(main_id, sub_id)
  end
  if not unlock_flag then
    log.info(string.format("###############------%s--%s", unlock_type, lock_str))
    return unlock_flag, lock_str
  end
  local config
  if sub_id then
    config = self:GetSubInfoByID(sub_id)
  else
    config = self:GetMainInfoByActID(main_id)
  end
  if not config then
    log.error("HeroActivityManager:GetActJumpInfo error! main_id = " .. tostring(main_id) .. "; sub_id = " .. tostring(sub_id))
    return false
  end
  local prefabStr = config.m_Prefab
  local ui_name = config.m_Prefab
  if not sub_id and config.m_ActivityType == HeroActivityManager.ActivityType.Stages then
    local bIsSecondHalf = self:IsSecondHalf(main_id)
    local strList = string.split(prefabStr, ";")
    if strList then
      ui_name = bIsSecondHalf and strList[2] or strList[1]
    end
  end
  local ui_id = UIDefines["ID_" .. string.upper(ui_name)]
  return unlock_flag, lock_str, ui_id
end

function HeroActivityManager:IsSecondHalf(main_id)
  local main_config = self:GetMainInfoByActID(main_id)
  if not main_config or main_config.m_ActivityType ~= HeroActivityManager.ActivityType.Stages then
    return false
  end
  local _, changeTime, endTime, closeTime = self:GetAllActTimeByActID(main_id)
  local is_corved, t1, t2, t3 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.main, main_id)
  if is_corved then
    _, closeTime, changeTime = t1, t2, t3
  end
  local temp_time = closeTime ~= 0 and closeTime or endTime
  local bIsSecondHalf = TimeUtil:IsInTime(changeTime, temp_time)
  return bIsSecondHalf
end

function HeroActivityManager:GotoHeroActivity(params)
  if not params then
    log.error("跳转参数不能为空!!!")
    return
  end
  local is_unlock, lock_str, ui_id = self:GetActJumpInfo(params.main_id, params.sub_id)
  if not is_unlock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, lock_str)
    return
  end
  local config = self:GetMainInfoByActID(params.main_id)
  if not config then
    log.error("HeroActivityManager:GotoHeroActivity error! main_id = " .. tostring(params.main_id) .. "; sub_id = " .. tostring(params.sub_id))
    return
  end
  if config.m_ActivityType == 2 and config.m_ExploreScene ~= "" then
    local vResource = {}
    table.insert(vResource, {
      sName = "ActExplore",
      eType = CS.MUF.Resource.ResourceType.Scene
    })
    table.insert(vResource, {
      sName = config.m_ExploreScene,
      eType = CS.MUF.Resource.ResourceType.Bytes
    })
    local allCfg = CS.CData_ActExploreInteractive.GetInstance():GetAll()
    for _, element in pairs(allCfg) do
      if element.m_Script ~= "" then
        table.insert(vResource, {
          sName = element.m_Script,
          eType = CS.MUF.Resource.ResourceType.StateScript
        })
      end
    end
    local key = params.main_id .. "PreInHeroAct"
    DownloadManager:DownloadResourceWithUI(nil, vResource, "GotoHeroActivity" .. key, nil, nil, function()
      self:DoGotoHeroActivity(params)
    end)
  else
    self:DoGotoHeroActivity(params)
  end
end

function HeroActivityManager:DoGotoHeroActivity(params)
  local is_unlock, lock_str, ui_id = self:GetActJumpInfo(params.main_id, params.sub_id)
  if not is_unlock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, lock_str)
    return
  end
  local key = params.main_id .. "FirstInHeroAct"
  local config = self:GetMainInfoByActID(params.main_id)
  if not config then
    log.error("HeroActivityManager:DoGotoHeroActivity error! main_id = " .. tostring(params.main_id) .. "; sub_id = " .. tostring(params.sub_id))
    return
  end
  local time_line = config.m_ActivityAnimation
  local vResource = {}
  local vPackage = {}
  if config.m_ActivityType == 2 and config.m_ExploreScene ~= "" then
    local preload = GameSceneManager:GetGameScene(GameSceneManager.SceneID.ActExplore):GetPreload(config.m_ExploreScene)
    local res = preload:GetDepenResources(true)
    for k, v in pairs(res) do
      table.insert(vResource, {sName = k, eType = v})
    end
  end
  local is_played = LocalDataManager:GetInt(key, 0, UserDataManager:GetAccountID(), UserDataManager:GetZoneID()) == 1
  if time_line == nil or time_line == "" then
    is_played = true
  end
  if config.m_ActivityAnimationReplay == 1 and params.isPlayTimeLine then
    is_played = false
  end
  if not is_played then
    table.insert(vResource, {
      sName = "Event_10001_01.bnk",
      eType = DownloadManager.ResourceType.Audio
    })
    table.insert(vResource, {
      sName = "746112276.wem",
      eType = DownloadManager.ResourceType.Audio
    })
    table.insert(vPackage, {
      sName = time_line,
      eType = DownloadManager.ResourcePackageType.Timeline
    })
  end
  DownloadManager:DownloadResourceWithUI(vPackage, vResource, "GotoHeroActivity" .. key, nil, nil, function()
    self:DoOpen(config, ui_id, params, {
      key = key,
      time_line = time_line,
      isPlay = not is_played
    })
  end)
end

function HeroActivityManager:DoOpen(config, ui_id, params, timeLineInfo)
  local function realOpen()
    if timeLineInfo.isPlay then
      CS.UI.UILuaHelper.PlayTimeline(timeLineInfo.time_line, false, "", function()
        StackFlow:Push(ui_id, params)
        
        self:broadcastEvent("eGameEvent_ActExploreUIReady")
        CS.UI.UILuaHelper.BlackTopOut(1, 0)
      end)
    else
      StackFlow:Push(ui_id, params)
      self:broadcastEvent("eGameEvent_ActExploreUIReady")
    end
    LocalDataManager:SetInt(timeLineInfo.key, 1, UserDataManager:GetAccountID(), UserDataManager:GetZoneID(), false)
  end
  
  if config.m_ActivityType == 2 and config.m_ExploreScene ~= "" then
    local currenentScene = GameSceneManager:GetCurScene()
    if currenentScene:GetSceneID() == GameSceneManager.SceneID.ActExplore then
      StackFlow:Push(ui_id, params)
      return
    end
    local scene = GameSceneManager:GetGameScene(GameSceneManager.SceneID.ActExplore)
    scene:OpenScene(config.m_ExploreScene, params.main_id, realOpen)
    return
  end
  realOpen()
end

function HeroActivityManager:IsSubActivityUnlock(unlockTypeList, unlockConditionDataList)
  if not unlockTypeList or not unlockConditionDataList then
    return true
  end
  if #unlockTypeList ~= #unlockConditionDataList then
    return false, nil, "error_params"
  end
  for index, conditionParamList2 in ipairs(unlockConditionDataList or {}) do
    for index2, v in ipairs(conditionParamList2) do
      local isUnlock, unlockStr = self:IsConditionUnlockNew(unlockTypeList[index], v)
      if not isUnlock then
        return isUnlock, unlockTypeList[index], unlockStr
      end
    end
  end
  return true
end

function HeroActivityManager:GetMinigameUnlockStr(levelCfg, iMiniGameId)
  if not levelCfg then
    return
  end
  local openTimeStr = ""
  local unlockLevelStr
  local subCfg = self:GetSubInfoByID(levelCfg.m_ActivitySubID)
  if subCfg then
    local subName = subCfg.m_mActivityTitle
    unlockLevelStr = subName .. " " .. levelCfg.m_LevelRef
  else
    unlockLevelStr = levelCfg.m_LevelRef or ""
  end
  local is_corved, t1 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
    id = levelCfg.m_ActivityID,
    m_MemoryID = iMiniGameId
  })
  if is_corved then
    openTimeStr = TimeUtil:TimerToString3(t1)
  end
  local formatUnlockStr
  if openTimeStr ~= "" then
    formatUnlockStr = ConfigManager:GetClientMessageTextById(40039)
    formatUnlockStr = string.CS_Format(formatUnlockStr, unlockLevelStr, openTimeStr)
  else
    formatUnlockStr = ConfigManager:GetClientMessageTextById(40036)
    formatUnlockStr = string.CS_Format(formatUnlockStr, unlockLevelStr)
  end
  return formatUnlockStr
end

function HeroActivityManager:GetLevelUnlockStr(levelCfg)
  if not levelCfg then
    return
  end
  local openTimeStr = levelCfg.m_OpenTime
  local unlockLevelStr
  local subCfg = self:GetSubInfoByID(levelCfg.m_ActivitySubID)
  if subCfg then
    local subName = subCfg.m_mActivityTitle
    unlockLevelStr = subName .. " " .. levelCfg.m_LevelRef
  else
    unlockLevelStr = levelCfg.m_LevelRef or ""
  end
  local is_corved, t1, t2 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.Level, levelCfg)
  if is_corved then
    openTimeStr = TimeUtil:TimerToString3(t1)
  end
  local formatUnlockStr
  if openTimeStr ~= "" then
    formatUnlockStr = ConfigManager:GetClientMessageTextById(40039)
    formatUnlockStr = string.CS_Format(formatUnlockStr, unlockLevelStr, openTimeStr)
  else
    formatUnlockStr = ConfigManager:GetClientMessageTextById(40036)
    formatUnlockStr = string.CS_Format(formatUnlockStr, unlockLevelStr)
  end
  return formatUnlockStr
end

local UnlockCMD = {}
UnlockCMD[HeroActivityManager.SubActUnlockType.ActLamiaLevel] = function(conditionParam, self)
  local bIsUnlock = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(conditionParam)
  local levelCfg = LevelHeroLamiaActivityManager:GetLevelHelper():GetLevelCfgByID(conditionParam)
  local unlockStr = self:GetLevelUnlockStr(levelCfg)
  return bIsUnlock, unlockStr
end

function HeroActivityManager:IsConditionUnlockNew(conditionType, conditionParam)
  if not conditionType or not conditionParam then
    return false
  end
  local f = UnlockCMD[tonumber(conditionType)]
  if f then
    return f(conditionParam, self)
  end
  return false
end

function HeroActivityManager:GetLevelTypeByActivityID(activityID)
  if not activityID then
    return
  end
  local mainActCfg = self:GetMainInfoByActID(activityID)
  if not mainActCfg then
    return
  end
  return mainActCfg.m_FightType
end

function HeroActivityManager:ReportActOpen(form_name, info)
  local openInfo = {}
  if not self.m_cacheReportData[form_name] then
    self.m_cacheReportData[form_name] = {}
  end
  local openTime = info.openTime
  openInfo.open_time = openTime
  self.m_cacheReportData[form_name][openTime] = openInfo
end

function HeroActivityManager:ReportActClose(form_name, info)
  local openTime = info.openTime
  if not self.m_cacheReportData[form_name] then
    self.m_cacheReportData[form_name] = {}
    self.m_cacheReportData[form_name][openTime] = {}
  elseif not self.m_cacheReportData[form_name][openTime] then
    self.m_cacheReportData[form_name][openTime] = {}
  end
  self.m_cacheReportData[form_name][openTime].close_time = TimeUtil:GetServerTimeS()
end

function HeroActivityManager:ReportActInfo()
  local systemsInfo = {}
  for system_name, v in pairs(self.m_cacheReportData) do
    local info = {}
    info.enter_num = 0
    info.online_time = 0
    info.log_details = {}
    info.module_name = system_name
    info.report_time = TimeUtil:GetServerTimeS()
    for time, n in pairs(v) do
      local open_time = n.open_time
      local close_time = n.close_time
      local add_open, add_close
      if open_time then
        info.enter_num = info.enter_num + 1
      else
        open_time = time
        add_open = true
      end
      if not close_time then
        close_time = open_time
        add_close = true
      end
      info.online_time = info.online_time + close_time - open_time
      info.log_details[tostring(table.getn(info.log_details) + 1)] = {
        open_time = open_time,
        close_time = close_time,
        add_open = add_open,
        add_close = add_close
      }
    end
    systemsInfo[tostring(system_name)] = info
  end
  if 0 < table.getn(systemsInfo) then
    for i, info in pairs(systemsInfo) do
      local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Module_log)
      stReportData.Enter_num = info.enter_num
      stReportData.Online_time = info.online_time
      stReportData.Report_time = info.report_time
      stReportData.Module_id = string.split(info.module_name, "/")[1] or "0"
      stReportData.Module_name = string.split(info.module_name, "/")[2] or "ActivityModule"
      local jsonData = info.log_details
      if type(jsonData) == "table" then
        jsonData = json.encode(jsonData)
      end
      stReportData.Log_details = jsonData
      CS.ReportService.Instance:Report(stReportData)
      CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
    end
  end
  self.m_cacheReportData = {}
end

function HeroActivityManager:FormatStrColor(str, color_str)
  local len = 0
  local start_index = 1
  local end_index = 1
  local char = string.byte(str, start_index)
  local charLength = string.getChrSize(char)
  end_index = start_index + charLength
  local start_str = string.sub(str, start_index, end_index - 1)
  local end_str = string.sub(str, end_index)
  local temp_str = "<color={0}>" .. start_str .. "</color>" .. end_str
  return string.gsubNumberReplace(temp_str, color_str)
end

function HeroActivityManager:GetSignPrefabList()
  local allConfig = self:GetAllMainInfoConfig()
  local prefabs = {}
  for i, config in pairs(allConfig) do
    if config.m_ActivityID and config.m_ActivityID > 0 then
      local sub_function_ids = utils.changeCSArrayToLuaTable(config.m_SubFunctionID)
      for _, sub_config_id in pairs(sub_function_ids) do
        local sub_config = self:GetSubInfoByID(sub_config_id)
        if sub_config then
          local type = sub_config.m_ActivitySubType
          if type == HeroActivityManager.SubActTypeEnum.Sign then
            prefabs[#prefabs + 1] = sub_config.m_Prefab
          end
        end
      end
    end
  end
  return prefabs
end

function HeroActivityManager:GetActTaskCfgByTaskId(taskUid)
  local actTaskIns = ConfigManager:GetConfigInsByName("ActTask")
  local cfg = actTaskIns:GetValue_ByUID(taskUid)
  if cfg:GetError() then
    log.error("GetActTaskCfgByTaskId is error taskUid = " .. tostring(taskUid))
    return
  end
  return cfg
end

function HeroActivityManager:GetActTaskCfgByActivitySubID(activitySubID)
  local actTaskIns = ConfigManager:GetConfigInsByName("ActTask")
  local cfgAll = actTaskIns:GetAll()
  local cfgList = {}
  local pinCfgList = {}
  for i, v in pairs(cfgAll) do
    if v.m_ActivitySubID == activitySubID then
      if v.m_Pin == 1 then
        pinCfgList[#pinCfgList + 1] = v
      else
        cfgList[#cfgList + 1] = v
      end
    end
  end
  return cfgList, pinCfgList
end

function HeroActivityManager:GetActTaskSubInfo(activeId)
  local taskCfgId = self:GetSubFuncID(activeId, HeroActivityManager.SubActTypeEnum.Task)
  local cfg = self:GetSubInfoByID(taskCfgId)
  return cfg
end

function HeroActivityManager:GetActTaskServerData(act_id)
  local data = self:GetHeroActData(act_id)
  if not data then
    log.error("GetActTaskServerData is error act_id = " .. tostring(act_id))
    return
  end
  local server_data = data.server_data
  if server_data then
    local stQuest = server_data.stQuest
    return stQuest
  end
end

function HeroActivityManager:GetActTaskServerDataById(act_id, taskId)
  if not taskId then
    log.error("GetActTaskServerDataById taskId = nil")
    return
  end
  local data = self:GetHeroActData(act_id)
  if not data then
    log.error("GetActTaskServerDataById is error act_id = " .. tostring(act_id))
    return
  end
  local server_data = data.server_data
  if server_data then
    local stQuest = server_data.stQuest
    if stQuest and stQuest.vQuest then
      for i, v in pairs(stQuest.vQuest) do
        if v.iId == taskId then
          return v
        end
      end
    end
    if stQuest and stQuest.vDailyQuest then
      for i, v in pairs(stQuest.vDailyQuest) do
        if v.iId == taskId then
          return v
        end
      end
    end
    if stQuest and stQuest.vGameQuest then
      for i, v in pairs(stQuest.vGameQuest) do
        if v.iId == taskId then
          return v
        end
      end
    end
  end
end

function HeroActivityManager:GetActTaskCfgByActiveId(activeId)
  local sub_config = self:GetActTaskSubInfo(activeId)
  if not sub_config then
    log.error("GetActTaskCfgByActiveId is error activeId = " .. tostring(activeId))
    return
  end
  local cfgList, pinCfgList = self:GetActTaskCfgByActivitySubID(sub_config.m_ActivitySubID)
  return cfgList, pinCfgList
end

function HeroActivityManager:GetActDailyTaskCfgByActiveId(activeId)
  if not activeId then
    return
  end
  local taskCfgId = self:GetSubFuncID(activeId, HeroActivityManager.SubActTypeEnum.DailyTask)
  if not taskCfgId then
    return
  end
  local sub_config = self:GetSubInfoByID(taskCfgId)
  if not sub_config then
    log.error("GetActTaskCfgByActiveId is error activeId = " .. tostring(activeId))
    return
  end
  local cfgList, pinCfgList = self:GetActTaskCfgByActivitySubID(sub_config.m_ActivitySubID)
  return cfgList, pinCfgList
end

function HeroActivityManager:GetActTaskDailyRewardCfgByID(iID)
  if iID <= 0 then
    return
  end
  local actTaskDailyRewardIns = ConfigManager:GetConfigInsByName("ActTaskDailyReward")
  local cfg = actTaskDailyRewardIns:GetValue_ByID(iID)
  if cfg:GetError() then
    log.error("GetActTaskDailyRewardCfgByID is error iID = " .. tostring(iID))
    return
  end
  return cfg
end

function HeroActivityManager:GetActTaskDailyRewardCfg()
  local actTaskDailyRewardIns = ConfigManager:GetConfigInsByName("ActTaskDailyReward")
  local cfg = actTaskDailyRewardIns:GetAll()
  local cfgList = {}
  for i, v in pairs(cfg) do
    if v.m_ID and v.m_ID > 0 then
      table.insert(cfgList, v)
    end
  end
  table.sort(cfgList, function(a, b)
    return a.m_ID < b.m_ID
  end)
  return cfgList
end

function HeroActivityManager:GetActTaskData(activeId, cfgList)
  local cfgDataList = {}
  if cfgList then
    for i, v in ipairs(cfgList) do
      local serverData = self:GetActTaskServerDataById(activeId, v.m_UID)
      if serverData then
        local preTaskState = self:CheckTaskStateByTaskId(activeId, v.m_PreTask)
        if preTaskState == TaskManager.TaskState.Completed and (serverData.iState ~= TaskManager.TaskState.Completed or serverData.iState == TaskManager.TaskState.Completed and v.m_Invisible ~= 1) then
          cfgDataList[#cfgDataList + 1] = {
            cfg = v,
            serverData = serverData,
            activeId = activeId
          }
        end
      else
        log.error("can not get task serverData id = " .. tostring(v.m_UID))
      end
    end
  end
  if 0 < #cfgDataList then
    local function sortFun(data1, data2)
      local server_data1 = data1.serverData
      
      local server_data2 = data2.serverData
      local iState1 = TaskManager:GetTaskStateSortNum(server_data1.iState)
      local iState2 = TaskManager:GetTaskStateSortNum(server_data2.iState)
      local cfg1 = data1.cfg
      local cfg2 = data2.cfg
      local sort1 = cfg1.m_Sort
      local sort2 = cfg2.m_Sort
      if iState1 == iState2 then
        if sort1 == sort2 then
          return cfg1.m_UID < cfg2.m_UID
        else
          return sort1 < sort2
        end
      else
        return iState1 < iState2
      end
    end
    
    table.sort(cfgDataList, sortFun)
  end
  return cfgDataList
end

function HeroActivityManager:CheckTaskIsCanJump(taskUid)
  local cfg = self:GetActTaskCfgByTaskId(taskUid)
  if cfg and cfg.m_Jump and cfg.m_Jump ~= 0 then
    return true
  end
  return false
end

function HeroActivityManager:CheckTaskStateByTaskId(activeId, taskUid)
  if taskUid == 0 then
    return TaskManager.TaskState.Completed
  end
  local serverData = self:GetActTaskServerDataById(activeId, taskUid)
  if serverData then
    return serverData.iState
  end
  return 1
end

function HeroActivityManager:CheckTaskCanReceive(activeId, isDailyTask, isAll)
  if isAll then
    return self:CheckTaskCanReceive(activeId) or self:CheckTaskCanReceive(activeId, true)
  end
  local data = self:GetActTaskServerData(activeId)
  local cfgs = self:GetActTaskDailyRewardCfg()
  local isAllCompleted = data and data.iDaiyQuestActive and data.iDaiyQuestActive >= cfgs[#cfgs].m_RequiredScore
  local flag = false
  local cfgList, pinCfgList = self:GetActTaskCfgByActiveId(activeId)
  if isDailyTask then
    cfgList, pinCfgList = self:GetActDailyTaskCfgByActiveId(activeId)
  else
    isAllCompleted = false
  end
  flag = self:CheckTaskCanReceiveByCfgList(activeId, cfgList)
  if flag then
    return flag and not isAllCompleted
  end
  flag = self:CheckTaskCanReceiveByCfgList(activeId, pinCfgList)
  return flag and not isAllCompleted
end

function HeroActivityManager:CheckTaskCanReceiveByCfgList(activeId, cfgList)
  if cfgList then
    for i, v in ipairs(cfgList) do
      local serverData = self:GetActTaskServerDataById(activeId, v.m_UID)
      if serverData then
        local preTaskState = self:CheckTaskStateByTaskId(activeId, v.m_PreTask)
        if preTaskState == TaskManager.TaskState.Completed and serverData.iState == TaskManager.TaskState.Finish then
          return true
        end
      end
    end
  end
  return false
end

function HeroActivityManager:GetDailyTaskCanReceiveList(activeId)
  local cfgList = self:GetActDailyTaskCfgByActiveId(activeId)
  if not cfgList then
    return {}
  end
  local vQuestId = {}
  for i, v in ipairs(cfgList) do
    local serverData = self:GetActTaskServerDataById(activeId, v.m_UID)
    if serverData then
      local preTaskState = self:CheckTaskStateByTaskId(activeId, v.m_PreTask)
      if preTaskState == TaskManager.TaskState.Completed and serverData.iState == TaskManager.TaskState.Finish then
        table.insert(vQuestId, v.m_UID)
      end
    end
  end
  return vQuestId
end

function HeroActivityManager:IsHeroActSignEntryHaveRedDot(act_id)
  local flag = self:GetHeroActSignHaveRedFlag(act_id)
  return flag and 1 or 0
end

function HeroActivityManager:IsHeroActActTaskEntryHaveRedDot(act_id)
  local flag = self:CheckTaskCanReceive(act_id, nil, true)
  return flag and 1 or 0
end

function HeroActivityManager:IsHeroActMemoryEntryHaveRedDot(act_id)
  local flag = self:GetMemoryEntryHaveRedFlag(act_id)
  return flag and 1 or 0
end

function HeroActivityManager:GetMemoryEntryHaveRedFlag(act_id)
  local sub_id = self:GetSubFuncID(act_id, HeroActivityManager.SubActTypeEnum.MiniGame)
  if not sub_id then
    return false
  end
  local configs = self:GetActMemoryInfoCfgByID(sub_id)
  local stMiniGame = self:GetHeroActData(act_id).server_data.stMiniGame
  if not stMiniGame then
    return false
  end
  local cur_readcard_num = 0
  for _, v in pairs(stMiniGame.mGameStat) do
    if v == 1 then
      cur_readcard_num = cur_readcard_num + 1
    end
  end
  local flag = false
  for _, config in pairs(configs) do
    local num = ItemManager:GetItemNum(config.m_Item)
    local is_got = num and 0 < num
    local open_time = TimeUtil:TimeStringToTimeSec2(config.m_OpenTime) or 0
    local cur_time = TimeUtil:GetServerTimeS()
    local is_corved, t1 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
      id = act_id,
      m_MemoryID = config.m_MemoryID
    })
    if is_corved then
      open_time = t1
    end
    local is_in_time = cur_time >= open_time
    local is_pre_done = false
    local pre_config = self:GetCurMemorysPre(config.m_FunID, config.m_MemoryID)
    if not pre_config then
      is_pre_done = true
    else
      is_pre_done = stMiniGame.mGameStat[pre_config.m_MemoryID] == 1
    end
    local is_done = stMiniGame.mGameStat[config.m_MemoryID] == 1
    if is_got and is_in_time and is_pre_done and not is_done then
      flag = true
      break
    end
    local rewards = utils.changeCSArrayToLuaTable(config.m_Rewards)
    if rewards and 0 < #rewards and cur_readcard_num >= config.m_MemoryID and stMiniGame.iMaxAwardedGame < config.m_MemoryID then
      flag = true
      break
    end
  end
  return flag
end

function HeroActivityManager:GetHeroActSignHaveRedFlag(act_id)
  local count = 0
  local sub_id = self:GetSubFuncID(act_id, HeroActivityManager.SubActTypeEnum.Sign)
  local sign_configs = self:GetActSignConfigByID(sub_id)
  for id, data in pairs(self.m_actList) do
    if id == act_id then
      local sign_data = data.server_data.stSign
      count = sign_data.iLoginDays > sign_data.iAwardedMaxDays and sign_data.iAwardedMaxDays < #sign_configs and 1 or 0
    end
  end
  return 0 < count and true or false
end

function HeroActivityManager:IsHeroActSignItemCanRec(params)
  return (params[1] > params[2] or params[3]) and 0 or 1
end

function HeroActivityManager:IsHeroActClueItemCanRec(params)
  local iClueId = params[1]
  local act_id = params[2]
  local clueCfg = self:GetAct4ClueCfgByID(iClueId)
  if clueCfg then
    local bIsGet = false
    local data = self:GetHeroActData(act_id)
    if data then
      local server_data = data.server_data
      if server_data then
        local vAwardedClue = server_data.vAwardedClue
        for _, v in ipairs(vAwardedClue) do
          if v == iClueId then
            bIsGet = true
            break
          end
        end
      end
    end
    local bIsUnlock = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(clueCfg.m_PreLevel)
    return not (not bIsUnlock or bIsGet) and 1 or 0
  else
    return 0
  end
end

function HeroActivityManager:IsHeroActMemoryCardCanRead(params)
  local config = params[1]
  local server_data = params[2]
  local act_id = params[3]
  local num = ItemManager:GetItemNum(config.m_Item)
  local is_got = num and 0 < num
  local open_time = TimeUtil:TimeStringToTimeSec2(config.m_OpenTime) or 0
  local cur_time = TimeUtil:GetServerTimeS()
  local is_corved, t1 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
    id = act_id,
    m_MemoryID = config.m_MemoryID
  })
  if is_corved then
    open_time = t1
  end
  local is_in_time = cur_time >= open_time
  local is_pre_done = false
  local pre_config = HeroActivityManager:GetCurMemorysPre(config.m_FunID, config.m_MemoryID)
  if not pre_config then
    is_pre_done = true
  else
    is_pre_done = server_data.mGameStat[pre_config.m_MemoryID] == 1
  end
  local is_done = server_data.mGameStat[config.m_MemoryID] == 1
  return not (not (is_got and is_in_time and is_pre_done) or is_done) and 1 or 0
end

function HeroActivityManager:HeroActHallEntryHaveRedDot(params)
  local config = params.config
  local act_id = config.m_ActivityID
  local nextDayResetTime = TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime())
  local bIsNewDay = nextDayResetTime - 1000 > LocalDataManager:GetIntSimple("HeroActHallEntry_Red_Point" .. act_id, 0)
  if bIsNewDay then
    return 1
  end
  if self:IsActShopEntryHaveRedDot(act_id) == 1 then
    return 1
  end
  local flag = self:CheckTaskCanReceive(act_id, nil, true)
  if flag then
    return 1
  end
  local miniGameTask = self:CheckHaveFinishWhackMoleTask({
    actId = act_id,
    whackMoleTaskId = self:GetSubFuncID(self.main_id, HeroActivityManager.SubActTypeEnum.GameTask)
  })
  if miniGameTask == 1 then
    return 1
  end
  flag = self:GetMemoryEntryHaveRedFlag(act_id)
  if flag then
    return 1
  end
  flag = self:GetHeroActSignHaveRedFlag(act_id)
  if flag then
    return 1
  end
  local challengeSubActID = self:GetSubFuncID(act_id, HeroActivityManager.SubActTypeEnum.ChallengeLevel)
  flag = 0 < LevelHeroLamiaActivityManager:IsSubActLeftTimesEntryHaveRedDot(challengeSubActID)
  if flag then
    return 1
  end
  local normalSubActID = self:GetSubFuncID(act_id, HeroActivityManager.SubActTypeEnum.NormalLevel)
  flag = 0 < LevelHeroLamiaActivityManager:IsSubActEnterHaveRedDot(normalSubActID)
  if flag then
    return 1
  end
  flag = self:IsHeroActMiniGamePuzzleEntryHaveRedDot({actId = act_id}) == 1
  if flag then
    return 1
  end
  return 0
end

function HeroActivityManager:GetWhackMoleLevelData()
  local MiniGame3WhackMoleLevelInfo = ConfigManager:GetConfigInsByName("MiniGameA3WhackaMoleLevel")
  local levelList = MiniGame3WhackMoleLevelInfo:GetAll()
  local levelDataList = {}
  for i, v in pairs(levelList) do
    local levelData = {}
    levelData.levelCfg = v
    levelData.state = 1
    levelDataList[#levelDataList + 1] = levelData
  end
  return levelDataList
end

function HeroActivityManager:GetWhackMoleTaskData(actId, whackMoleActivityId)
  self.m_cfgList, self.m_pinCfgList = self:GetActTaskCfgByActivitySubID(whackMoleActivityId)
  local taskDataList = self:GetActTaskData(actId, self.m_cfgList)
  return taskDataList
end

function HeroActivityManager:IsHeroActMiniGameEntryHaveRedDot(param)
  local miniGameIsOpen = self:IsSubActIsOpenByID(param.actId, self:GetSubFuncID(param.actId, HeroActivityManager.SubActTypeEnum.MiniGame))
  if not miniGameIsOpen then
    return 0
  end
  local flag = self:CheckHaveFinishWhackMoleTask({
    actId = param.actId,
    whackMoleTaskId = self:GetSubFuncID(param.actId, HeroActivityManager.SubActTypeEnum.GameTask)
  })
  if flag == 1 then
    return 1
  end
  local m_miniGameServerData = self:GetHeroActData(param.actId).server_data.stMiniGame
  local tempAllCfg = self:GetActWhackMoleInfoCfgByID(param.whackMoleActivityId)
  for _, v in pairs(tempAllCfg) do
    local open_time = TimeUtil:TimeStringToTimeSec2(v.m_OpenTime) or 0
    local is_corved, t1 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
      id = param.actId,
      m_MemoryID = v.m_LevelID
    })
    if is_corved then
      open_time = t1
    end
    local cur_time = TimeUtil:GetServerTimeS()
    local is_in_time = open_time <= cur_time
    if is_in_time then
      local is_done = m_miniGameServerData.mGameStat[v.m_LevelID] == 1
      if not is_done then
        local is_pre_done = false
        if not v.m_PreLevel or 0 >= v.m_PreLevel then
          is_pre_done = true
          return 1
        else
          local config = self:GetActWhackMoleInfoCfgByIDAndLevelId(param.whackMoleActivityId, v.m_PreLevel)
          is_pre_done = m_miniGameServerData.mGameStat[config.m_LevelID] == 1
          if is_pre_done then
            return 1
          end
        end
      end
    end
  end
  return 0
end

function HeroActivityManager:CheckHaveFinishWhackMoleTask(param)
  if param then
    local taskDataList = self:GetWhackMoleTaskData(param.actId, param.whackMoleTaskId)
    for _, v in pairs(taskDataList) do
      if v.serverData.iState == TaskManager.TaskState.Finish then
        return 1
      end
    end
  end
  return 0
end

function HeroActivityManager:IsActShopEntryHaveRedDot(iActID)
  local config = HeroActivityManager:GetMainInfoByActID(iActID)
  if not config then
    return 0
  end
  local jumpIns = ConfigManager:GetConfigInsByName("Jump")
  local jump_item = jumpIns:GetValue_ByJumpID(config.m_ShopJumpID)
  local windowId = 0 < jump_item.m_Param.Length and tonumber(jump_item.m_Param[0]) or 0
  local shop_list = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Activity)
  local shop_id
  for i, v in ipairs(shop_list) do
    if v.m_WindowID == windowId then
      shop_id = v.m_ShopID
    end
  end
  local goodsList = ShopManager:GetShopGoodsByShopId(shop_id) or {}
  local flag = false
  for _, v in ipairs(goodsList) do
    if self:IsShopGoodsHaveRedDot({
      iActID = iActID,
      iGroupID = v.iGroupId,
      iGoodsId = v.iGoodsId,
      iBought = v.iBought
    }) == 1 then
      flag = true
      break
    end
  end
  return flag and 1 or 0
end

function HeroActivityManager:IsShopGoodsHaveRedDot(params)
  local main_config = self:GetMainInfoByActID(params.iActID)
  if not main_config then
    log.error("HeroActivityManager:IsShopGoodsHaveRedDot error! iActID = " .. tostring(params.iActID))
    return 0
  end
  local startTime = TimeUtil:TimeStringToTimeSec2(main_config.m_OpenTime) or 0
  local is_act_corved, t1 = self:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.main, params.iActID)
  if is_act_corved then
    startTime = t1
  end
  local day = TimeUtil:GetPassedServerDay(startTime)
  if day <= 1 then
    return 0
  end
  local goodCfg = ShopManager:GetShopGoodsConfig(params.iGroupID, params.iGoodsId)
  local m_showTime = TimeUtil:TimeStringToTimeSec2(goodCfg.m_ShowTime) or 0
  local is_corved, corveCfg = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shopGoods, {
    id = params.iActID,
    iGroupID = params.iGroupID,
    iGoodsId = params.iGoodsId
  })
  if is_corved and corveCfg then
    m_showTime = corveCfg.iShowTime
  end
  local cur_time = TimeUtil:GetServerTimeS()
  local is_inTime = m_showTime <= cur_time
  if not is_inTime then
    return 0
  end
  local temp = m_showTime - startTime <= 86400
  if temp then
    return 0
  end
  if params.iBought >= goodCfg.m_ItemQuantity then
    return 0
  end
  local flag = LocalDataManager:GetIntSimple(params.iActID .. "_ActShopGoodsRedDot_" .. params.iGroupID .. "_" .. params.iGoodsId, 0) == 0
  return flag and 1 or 0
end

local RemoteSynchronizer = require("Module/ActExplore/ActExploreRemoteSynchronizer")

function HeroActivityManager:GetSynchronizer(iActId, callback)
  self.synchronizer = self.synchronizer or {}
  local data = self.synchronizer[iActId]
  if data == nil then
    data = {
      CallBack = callback,
      Synchronizer = RemoteSynchronizer.new(iActId)
    }
    self.synchronizer[iActId] = data
    self:RequestExploreData(iActId)
  elseif callback then
    callback(data.Synchronizer)
  end
end

function HeroActivityManager:RequestExploreData(iActId)
  local rqs_msg = MTTDProto.Cmd_Lamia_GetExploreData_CS()
  rqs_msg.iActId = iActId
  RPCS():Lamia_GetExploreData(rqs_msg, handler1(self, self.OnLamia_GetExploreData, iActId))
end

function HeroActivityManager:OnLamia_GetExploreData(iActId, msg)
  if msg.iActId ~= nil then
    iActId = msg.iActId
  end
  self.synchronizer = self.synchronizer or {}
  local data = self.synchronizer[iActId]
  if data == nil then
    data = {
      Synchronizer = RemoteSynchronizer.new(iActId)
    }
    self.synchronizer[iActId] = data
  end
  data.Synchronizer:SetServerData(msg.vExplore)
  if data.CallBack ~= nil then
    data.CallBack(data.Synchronizer)
    data.CallBack = nil
  end
end

function HeroActivityManager:SetExploreData(iActID, vExplore)
  local rqs_msg = MTTDProto:Cmd_Lamia_SetExploreData_CS()
  rqs_msg.iActId = iActID
  rqs_msg.vExplore = vExplore
  RPCS():Lamia_SetExploreData(rqs_msg, nil)
end

function HeroActivityManager:GetMinigameHelper()
  local minigameHelper = self.m_minigameHelper
  if minigameHelper == nil then
    minigameHelper = require("Manager/ManagerPlus/HeroActivityHelper/MinigameHelper").new()
    self.m_minigameHelper = minigameHelper
  end
  return minigameHelper
end

function HeroActivityManager:OpenTreasureBox(param)
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY105MINIGAME, {str = param})
end

function HeroActivityManager:IsHeroActMiniGamePuzzleEntryHaveRedDot(param)
  local subActId = self:GetSubFuncID(param.actId, HeroActivityManager.SubActTypeEnum.MiniGame)
  local miniGameIsOpen = self:IsSubActIsOpenByID(param.actId, subActId)
  if not miniGameIsOpen then
    return 0
  end
  local curLevelId = self:GetMinigameHelper():GetCurLevelCfg(param.actId, subActId)
  if not curLevelId or curLevelId == 0 then
    return 0
  end
  if self:GetMinigameHelper():IsMiniGamePuzzleRewardCanGet(param.actId, subActId) then
    return 1
  end
  local act_data = self:GetHeroActData(param.actId)
  if not act_data then
    return 0
  end
  local stMiniGame = act_data.server_data.stMiniGame
  if not stMiniGame then
    return 0
  end
  local bIsPass = stMiniGame.mGameStat[curLevelId] == 1
  if bIsPass then
    return 0
  end
  if not self:IsTodayEnterMinigamePuzzle(curLevelId) then
    return 0
  end
  return 1
end

function HeroActivityManager:IsTodayEnterMinigamePuzzle(curLevelId)
  local nextDayResetTime = TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime())
  return nextDayResetTime - 1000 > LocalDataManager:GetIntSimple("HeroActMiniGamePuzzle_Entry_Red_Point_" .. curLevelId, 0)
end

return HeroActivityManager
