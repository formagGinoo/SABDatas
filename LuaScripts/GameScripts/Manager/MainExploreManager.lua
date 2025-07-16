local BaseManager = require("Manager/Base/BaseManager")
local MainExploreManager = class("MainExploreManager", BaseManager)
MainExploreManager.RewardType = {reawrd = 1, story = 2}
MainExploreManager.ExploreTipsType = {Normal = 0, Sea = 1}

function MainExploreManager:OnCreate()
  self.MainExploreData = nil
  self.all_MainExplore_configs = nil
  self.all_MainExploreSort_config = nil
  self.all_MainLostStory_configs = nil
  self.all_MainLostStoryFormat_Configs = nil
end

function MainExploreManager:OnInitNetwork()
  local rqs_getExplore_msg = MTTDProto.Cmd_Castle_GetExplore_CS()
  self.MainExploreData = MTTDProto.Cmd_Castle_GetExplore_SC()
  RPCS():Castle_GetExplore(rqs_getExplore_msg, handler(self, self.OnCastleGetExploreSC))
end

function MainExploreManager:OnDestroy()
end

function MainExploreManager:OnCastleGetExploreSC(data)
  self.MainExploreData = data
  self:CheckUpdateMainExploreStoryEntryHaveRed()
end

function MainExploreManager:RqsGetStoryReawrd(iStoryId)
  local rqs_msg = MTTDProto.Cmd_Castle_TakeStoryReward_CS()
  rqs_msg.iStoryId = iStoryId
  RPCS():Castle_TakeStoryReward(rqs_msg, handler(self, self.OnCastleTakeStoryRewardSC))
end

function MainExploreManager:OnCastleTakeStoryRewardSC(data)
  local iStoryId = data.iStoryId
  self.MainExploreData.mStory[iStoryId].iRewardTime = TimeUtil:GetServerTimeS()
  local reward_list = data.vReward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  self:CheckUpdateMainExploreStoryEntryHaveRed()
  self:broadcastEvent("eGameEvent_LostStory_GetReward", data.iLevel)
end

function MainExploreManager:RqsTakeClueReward(iChapterId, iClueId)
  local rqs_msg = MTTDProto.Cmd_Castle_TakeClueReward_CS()
  rqs_msg.iChapterId = iChapterId
  rqs_msg.iClueId = iClueId
  RPCS():Castle_TakeClueReward(rqs_msg, handler(self, self.OnCastleTakeClueRewardSC))
end

function MainExploreManager:OnCastleTakeClueRewardSC(data)
  local mClue = self:GetServerClueData()
  mClue[data.iChapterId] = mClue[data.iChapterId] or {}
  table.insert(mClue[data.iChapterId], data.iClueId)
  local reward_list = data.vReward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  local config = self:GetMainConfigByChapterIDAndCludID(data.iChapterId, data.iClueId)
  local type = config.m_RewardType
  if type == self.RewardType.story then
    local story_arr = utils.changeCSArrayToLuaTable(config.m_SubsectionID)
    local story_config = self:GetMainLostStoryCfgByStoryIDAndSubID(story_arr[1], story_arr[2])
    StackPopup:Push(UIDefines.ID_FORM_MAINEXPLOREDETIAL, {config = story_config})
    local mStory = self:GetServerStoryData()
    mStory[story_arr[1]] = data.stRewardStory
  end
  self:CheckUpdateMainExploreStoryEntryHaveRed()
  self:broadcastEvent("eGameEvent_MainExplore_TakeClueReward", data.iChapterId)
end

function MainExploreManager:RqsCastleTakeChapterReward(iChapterId, callback)
  local rqs_msg = MTTDProto.Cmd_Castle_TakeChapterReward_CS()
  rqs_msg.iChapterId = iChapterId
  RPCS():Castle_TakeChapterReward(rqs_msg, function(sc)
    table.insert(self.MainExploreData.vChapterReward, sc.iChapterId)
    local reward_list = sc.vReward
    if reward_list and next(reward_list) then
      utils.popUpRewardUI(reward_list)
    end
    self:broadcastEvent("eGameEvent_MainExplore_TakeClueReward", iChapterId)
    if callback then
      callback()
    end
  end)
end

function MainExploreManager:GetMainExploreConfig()
  if self.all_MainExplore_configs then
    return self.all_MainExplore_configs, self.all_MainExploreSort_config
  end
  local MainExploreIns = ConfigManager:GetConfigInsByName("MainExplore")
  local all_config_dic = MainExploreIns:GetAll()
  local format_config = {}
  local sort_config = {}
  for k, list in pairs(all_config_dic) do
    for i, config in pairs(list) do
      if config.m_MainChapter then
        format_config[config.m_MainChapter] = format_config[config.m_MainChapter] or {}
        format_config[config.m_MainChapter][config.m_ClueID] = config
        table.insert(sort_config, config)
      end
    end
  end
  table.sort(sort_config, function(a, b)
    if a.m_MainChapter ~= b.m_MainChapter then
      return a.m_MainChapter < b.m_MainChapter
    else
      return a.m_ClueID < b.m_ClueID
    end
  end)
  self.all_MainExploreSort_config = sort_config
  self.all_MainExplore_configs = format_config
  return format_config, sort_config
end

function MainExploreManager:GetMainConfigByChapterIDAndCludID(iMainChapterID, iClueID)
  local configs = self:GetMainExploreConfig()
  return configs[iMainChapterID][iClueID]
end

function MainExploreManager:GetMainLostStoryConfig()
  if self.all_MainLostStory_configs then
    return self.all_MainLostStory_configs, self.all_MainLostStoryFormat_Configs
  end
  local MainLostStoryIns = ConfigManager:GetConfigInsByName("MainLostStory")
  local all_config_dic = MainLostStoryIns:GetAll()
  local configs = {}
  local format_configs = {}
  for k, list in pairs(all_config_dic) do
    for i, config in pairs(list) do
      if config.m_StoryID then
        table.insert(configs, config)
        format_configs[config.m_StoryID] = format_configs[config.m_StoryID] or {}
        table.insert(format_configs[config.m_StoryID], config)
      end
    end
  end
  table.sort(configs, function(a, b)
    if a.m_StoryID ~= b.m_StoryID then
      return a.m_StoryID < b.m_StoryID
    else
      return a.m_SubsectionID < b.m_SubsectionID
    end
  end)
  for i, v in ipairs(format_configs) do
    table.sort(v, function(a, b)
      return a.m_SubsectionID < b.m_SubsectionID
    end)
  end
  self.all_MainLostStory_configs = configs
  self.all_MainLostStoryFormat_Configs = format_configs
  return configs, format_configs
end

function MainExploreManager:GetMainLostStoryByStoryID(StoryID)
  local configs = self:GetMainLostStoryConfig()
  local list = {}
  for i, v in ipairs(configs) do
    if v.m_StoryID == StoryID then
      table.insert(list, v)
    end
  end
  return list
end

function MainExploreManager:GetMainLostStoryCfgByStoryIDAndSubID(StoryID, SubsectionID)
  if not StoryID or not SubsectionID then
    log.error("MainExploreManager:GetMainLostStoryCfgByStoryIDAndSubID Error: params is nil")
    return
  end
  local MainLostStoryIns = ConfigManager:GetConfigInsByName("MainLostStory")
  local config = MainLostStoryIns:GetValue_ByStoryIDAndSubsectionID(StoryID, SubsectionID)
  if config:GetError() then
    log.error("GetMainLostStoryCfgByStoryIDAndSubID is error")
    return
  end
  return config
end

function MainExploreManager:GetStoryToLevelList()
  local _, configs = self:GetMainExploreConfig()
  local story2level = {}
  for _, config in ipairs(configs) do
    if config.m_RewardType == MainExploreManager.RewardType.story then
      local storyarr = utils.changeCSArrayToLuaTable(config.m_SubsectionID)
      story2level[storyarr[1]] = story2level[storyarr[1]] or {}
      story2level[storyarr[1]][storyarr[2]] = config.m_UnlockLevel
    end
  end
  return story2level
end

function MainExploreManager:GetMainExploreRewardCfgByChapterID(iMainChapterID)
  local MainExploreRewardIns = ConfigManager:GetConfigInsByName("MainExploreReward")
  local config = MainExploreRewardIns:GetValue_ByMainChapter(iMainChapterID)
  if config:GetError() then
    log.error("MainExploreManager:GetMainExploreRewardCfgByChapterID is error, WRONG ID : " .. iMainChapterID)
    return
  end
  return config
end

function MainExploreManager:GetServerData()
  return self.MainExploreData
end

function MainExploreManager:GetServerClueData()
  return self.MainExploreData.mClue
end

function MainExploreManager:GetServerStoryData()
  return self.MainExploreData.mStory
end

function MainExploreManager:GetServerChapterRewardData()
  return self.MainExploreData.vChapterReward
end

function MainExploreManager:GetExploreInfoByChapterID(chapterID)
  local all_configs = self:GetMainExploreConfig()
  local chapter_configs = all_configs[chapterID]
  if not chapter_configs then
    return {}
  end
  local infos = {}
  for i, config in ipairs(chapter_configs) do
    local isShowClue = true
    local unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, tonumber(config.m_UnlockLevel))
    if not unlock then
      isShowClue = false
    else
      local data = self.MainExploreData
      local vClue = data.mClue[chapterID]
      if vClue then
        for _, v in ipairs(vClue) do
          if v == config.m_ClueID then
            isShowClue = false
          end
        end
      end
    end
    table.insert(infos, {
      isShowClue = isShowClue,
      clueID = config.m_ClueID
    })
  end
  return infos
end

function MainExploreManager:GetCurChapterExploreInfo(chapterID)
  local config = self:GetMainExploreConfig()
  if not config or not config[chapterID] then
    return
  end
  local data = self.MainExploreData
  local vClue = data.mClue[chapterID]
  local count = 0
  if vClue then
    for _, v in pairs(vClue) do
      count = count + 1
    end
  end
  return count, #config[chapterID]
end

function MainExploreManager:GetUnlockStorySubCount(m_StoryID)
  local server_data = self:GetServerStoryData()
  local data = server_data[m_StoryID]
  local unlock_count = 0
  if data then
    for i, v in pairs(data.vSectionId) do
      unlock_count = unlock_count + 1
    end
  end
  return unlock_count
end

function MainExploreManager:CheckPushNewClueTips()
  local clientData = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Explore)
  local pushed_idx, record
  local show_list = {}
  local _, all_config = self:GetMainExploreConfig()
  if clientData and clientData ~= "" then
    local dataStrList = clientData
    pushed_idx = tonumber(dataStrList)
  else
    local config = all_config[1]
    local unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, tonumber(config.m_UnlockLevel))
    if unlock then
      table.insert(show_list, all_config[1])
      record = 1
    end
  end
  local is_find = false
  for idx, config in ipairs(all_config) do
    if is_find then
      local unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, tonumber(config.m_UnlockLevel))
      if unlock then
        table.insert(show_list, config)
        record = idx
      end
    end
    if idx == pushed_idx or not pushed_idx then
      is_find = true
    end
  end
  if 0 < #show_list then
    ClientDataManager:SetClientValue(ClientDataManager.ClientKeyType.Explore, record)
    StackPopup:Push(UIDefines.ID_FORM_MAINEXPLORETIPS, {
      newUnlockCfg = show_list[#show_list]
    })
  end
end

function MainExploreManager:SetNewMark(ChapterID, ClueID)
  local key_str = ChapterID .. "-" .. ClueID .. "NewClue"
  LocalDataManager:SetInt(key_str, 1, UserDataManager:GetAccountID(), UserDataManager:GetZoneID())
end

function MainExploreManager:GetNewMark(ChapterID, ClueID)
  local key_str = ChapterID .. "-" .. ClueID .. "NewClue"
  return LocalDataManager:GetInt(key_str, 0, UserDataManager:GetAccountID(), UserDataManager:GetZoneID())
end

function MainExploreManager:IsHaveNewClueMark(chapterID)
  local configs = self:GetMainExploreConfig()
  if not configs or not configs[chapterID] then
    return
  end
  for i, config in ipairs(configs[chapterID]) do
    local unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, tonumber(config.m_UnlockLevel))
    if unlock then
      local mClue = self:GetServerClueData()
      local vClue = mClue[config.m_MainChapter]
      local is_explored = false
      if vClue then
        for _, v in ipairs(vClue) do
          if v == config.m_ClueID then
            is_explored = true
          end
        end
      end
      if not vClue or not is_explored then
        local saved = self:GetNewMark(config.m_MainChapter, config.m_ClueID) == 1
        if not saved then
          return true
        end
      end
    end
  end
  return false
end

function MainExploreManager:IsMainExploreStoryCanTakeReward(params)
  local m_StoryID = params.m_StoryID
  local unlock_count = self:GetUnlockStorySubCount(m_StoryID)
  local data = self:GetServerStoryData()
  local is_got = false
  if data and data[m_StoryID] then
    is_got = data[m_StoryID].iRewardTime > 0
  end
  return not is_got and unlock_count == params.max_count and 1 or 0
end

function MainExploreManager:CheckUpdateMainExploreStoryEntryHaveRed()
  local _, configs = self:GetMainLostStoryConfig()
  local flag = false
  for i, v in ipairs(configs) do
    local config = v[1]
    local unlock_count = self:GetUnlockStorySubCount(config.m_StoryID)
    local data = self:GetServerStoryData()
    local is_got = false
    if data and data[config.m_StoryID] then
      is_got = data[config.m_StoryID].iRewardTime > 0
    end
    flag = not is_got and unlock_count == #v
    if flag then
      break
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.MainExploreStoryEntry,
    count = flag and 1 or 0
  })
end

return MainExploreManager
