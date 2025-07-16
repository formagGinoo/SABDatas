local BaseManager = require("Manager/Base/BaseManager")
local StatueShowroomManager = class("StatueShowroomManager", BaseManager)

function StatueShowroomManager:OnCreate()
end

function StatueShowroomManager:OnInitNetwork()
  local rqs_getStatus_msg = MTTDProto.Cmd_Castle_GetStatue_CS()
  self.StatueData = MTTDProto.Cmd_Castle_GetStatue_SC()
  RPCS():Castle_GetStatue(rqs_getStatus_msg, handler(self, self.OnCastleGetStatueSC))
  RPCS():Listen_Push_Castle_StatueLevel(handler(self, self.OnPushCastleStatueLevel), "StatueShowroomManager")
  self:ParseCastleStatueCfg()
end

function StatueShowroomManager:OnDestroy()
end

function StatueShowroomManager:OnCastleGetStatueSC(data)
  self.StatueData = data
  self:CheckUpdateCastleStatueRewardHaveRed()
end

function StatueShowroomManager:OnPushCastleStatueLevel(data)
  self.StatueData.iLevel = data.iNewLevel
  self:CheckUpdateCastleStatueRewardHaveRed()
  self:broadcastEvent("eGameEvent_CastleDispatchStatueLevelUpRedPoint")
end

function StatueShowroomManager:ReqGetStatusLevelReward()
  local rqs_getAward = MTTDProto.Cmd_Castle_TakeStatueReward_CS()
  RPCS():Castle_TakeStatueReward(rqs_getAward, handler(self, self.CastleTakeStatueRewardSC))
end

function StatueShowroomManager:CastleTakeStatueRewardSC(data)
  self.StatueData.iRewardLevel = data.iLevel
  local reward_list = data.vReward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  self:broadcastEvent("eGameEvent_StatueShowroom_GetReward", data.iLevel)
  self:CheckUpdateCastleStatueRewardHaveRed()
end

function StatueShowroomManager:ParseCastleStatueCfg()
  self.m_effectCfg = {}
  local vCfg = self:GetAllCastleStatueCfg()
  for k, v in ipairs(vCfg) do
    local strType = v.m_Type
    if strType ~= "" then
      if self.m_effectCfg[strType] == nil then
        self.m_effectCfg[strType] = {}
      end
      table.insert(self.m_effectCfg[strType], {
        level = v.m_StatueLevel,
        value = v.m_Num
      })
    end
  end
end

function StatueShowroomManager:GetCastleStatueCfgByID(iStatueID)
  local castleStatueIns = ConfigManager:GetConfigInsByName("CastleStatue")
  local cfg = castleStatueIns:GetValue_ByStatueID(iStatueID)
  if cfg:GetError() then
    log.error("GetCastleStatueCfgByID is error iStatueID = " .. tostring(iStatueID))
    return
  end
  return cfg
end

function StatueShowroomManager:GetAllCastleStatueCfg()
  if self.all_statue_configs then
    return self.all_statue_configs
  end
  local castleStatueIns = ConfigManager:GetConfigInsByName("CastleStatue")
  local all_config_dic = castleStatueIns:GetAll()
  local configs = {}
  for k, v in pairs(all_config_dic) do
    if v.m_StatueID then
      table.insert(configs, v)
    end
  end
  table.sort(configs, function(a, b)
    return a.m_StatueID < b.m_StatueID
  end)
  self.all_statue_configs = configs
  return configs
end

function StatueShowroomManager:GetCastleStatueLevelCfgByLevel(iStatueLevel)
  local castleStatueLevelIns = ConfigManager:GetConfigInsByName("CastleStatueLevel")
  local cfg = castleStatueLevelIns:GetValue_ByStatueLevel(iStatueLevel)
  if cfg:GetError() then
    log.error("GetCastleStatueLevelCfgByLevel is error iStatueLevel = " .. tostring(iStatueLevel))
    return
  end
  return cfg
end

function StatueShowroomManager:GetAllCastleStatueLevelCfg()
  if self.all_level_configs then
    return self.all_level_configs
  end
  local castleStatueLevelIns = ConfigManager:GetConfigInsByName("CastleStatueLevel")
  local all_config_dic = castleStatueLevelIns:GetAll()
  local configs = {}
  for k, v in pairs(all_config_dic) do
    if v.m_StatueLevel then
      configs[v.m_StatueLevel] = v
    end
  end
  self.all_level_configs = configs
  return configs
end

function StatueShowroomManager:GetServerData()
  return self.StatueData
end

function StatueShowroomManager:GetStatueLevelInfo()
  local all_level_configs = self:GetAllCastleStatueLevelCfg()
  local iRewardLevel = self.StatueData.iRewardLevel
  local iLevel = self.StatueData.iLevel
  local exp_count = ItemManager:GetItemNum(MTTDProto.SpecialItem_StatueExp)
  local next_level_config = all_level_configs[iLevel + 1]
  local next_rewardLevel_cofnig = all_level_configs[iRewardLevel + 1]
  local info = {}
  if iLevel == iRewardLevel then
    info.show_level = iLevel
    if next_level_config then
      info.show_str = exp_count .. "/" .. next_level_config.m_StatueExp
      local vRewardLua = utils.changeCSArrayToLuaTable(next_level_config.m_Rewards)
      info.reward_info = vRewardLua[1]
      info.fillAmount = exp_count / next_level_config.m_StatueExp
    else
      info.show_str = "MAX"
      info.fillAmount = 1
    end
  end
  if iRewardLevel < iLevel then
    info.show_level = iRewardLevel + 1
    info.fillAmount = 1
    local vRewardLua = utils.changeCSArrayToLuaTable(next_rewardLevel_cofnig.m_Rewards)
    info.reward_info = vRewardLua[1]
    if next_level_config then
      info.show_str = exp_count .. "/" .. next_rewardLevel_cofnig.m_StatueExp
    else
      info.show_str = "MAX/" .. next_rewardLevel_cofnig.m_StatueExp
    end
  end
  return info
end

function StatueShowroomManager:GetLevelStatueList(level)
  local all_statue_configs = StatueShowroomManager:GetAllCastleStatueCfg()
  local list = {}
  for i, v in ipairs(all_statue_configs) do
    if v.m_StatueLevel == level then
      table.insert(list, v)
    end
  end
  return list
end

function StatueShowroomManager:CheckAndPushTip()
  local clientData = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Statue)
  local iLevel = self.StatueData.iLevel
  local pre_level = 0
  if clientData and clientData ~= "" then
    pre_level = tonumber(clientData)
  end
  if iLevel > pre_level then
    ClientDataManager:SetClientValue(ClientDataManager.ClientKeyType.Statue, tostring(self.StatueData.iLevel))
    StackPopup:Push(UIDefines.ID_FORM_CASTLESTATUELEVELUPTIPS, {pre_level = pre_level, cur_level = iLevel})
  end
end

function StatueShowroomManager:GetStatueEffectValue(strType, level)
  if level == nil then
    level = self.StatueData.iLevel
  end
  local vEffect = self.m_effectCfg[strType]
  if vEffect == nil then
    return 0
  end
  local effectValue = 0
  for k, v in ipairs(vEffect) do
    if level < v.level then
      break
    end
    if level >= v.level and "StatueEffect_TodayCouncilHallAttractNum" ~= strType then
      effectValue = effectValue + v.value[0]
    end
  end
  return effectValue
end

function StatueShowroomManager:CheckUpdateCastleStatueRewardHaveRed()
  local flag = self.StatueData.iLevel > self.StatueData.iRewardLevel
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.CastleStatueReward,
    count = flag and 1 or 0
  })
end

return StatueShowroomManager
