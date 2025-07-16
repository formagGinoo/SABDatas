local Form_PvpReplaceInforPop = class("Form_PvpReplaceInforPop", require("UI/UIFrames/Form_PvpReplaceInforPopUI"))
local UpdateRewardDeltaNum = 60
local MaxRewardItemIndex = 2

function Form_PvpReplaceInforPop:SetInitParam(param)
end

function Form_PvpReplaceInforPop:AfterInit()
  self.super.AfterInit(self)
  self.m_replaceArenaAfkInfo = nil
  self.m_isCanUpdateReward = false
  self.m_curDeltaRewardTime = 0
  self.m_afkStageInfoList = nil
  self.m_luaRecordGrid = self:CreateInfinityGrid(self.m_scrollView_InfinityGrid, "PvpReplace/UIPvpReplaceAfkRankItem", nil)
  self.m_backFun = nil
end

function Form_PvpReplaceInforPop:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpReplaceInforPop:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_PvpReplaceInforPop:OnUpdate(dt)
  self:CheckUpdateReward()
end

function Form_PvpReplaceInforPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpReplaceInforPop:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_backFun = tParam.backFun
    self.m_csui.m_param = nil
  end
  self:FreshRankStageData()
end

function Form_PvpReplaceInforPop:ClearCacheData()
end

function Form_PvpReplaceInforPop:FreshRankStageData()
  local afkData = PvpReplaceManager:GetReplaceArenaAfkInfo()
  if not afkData then
    return
  end
  local _, fullTime = self:IsAFKFull()
  local recordList = afkData.vRecord
  local tempShowRecordList = {}
  if recordList and next(recordList) then
    table.sort(recordList, function(a, b)
      return a.iStartTime > b.iStartTime
    end)
    for i, tempReplaceAfkRecord in ipairs(recordList) do
      if fullTime > tempReplaceAfkRecord.iStartTime then
        local replaceArenaRankCfg = PvpReplaceManager:GetReplaceRankCfgByGradeNum(tempReplaceAfkRecord.iGrade)
        if replaceArenaRankCfg then
          local tempShowRecordTab = {replaceArenaRankCfg = replaceArenaRankCfg, recordInfo = tempReplaceAfkRecord}
          tempShowRecordList[#tempShowRecordList + 1] = tempShowRecordTab
        end
      end
    end
  end
  self.m_afkStageInfoList = tempShowRecordList
end

function Form_PvpReplaceInforPop:IsAFKFull()
  local afkData = PvpReplaceManager:GetReplaceArenaAfkInfo()
  if not afkData then
    return
  end
  local lastTakeTime = afkData.iTakeRewardTime
  local limitTimeSecNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaAFKLimit"))
  local fullTime = lastTakeTime + limitTimeSecNum
  local curServerTime = TimeUtil:GetServerTimeS()
  local isFull = fullTime <= curServerTime
  return isFull, fullTime
end

function Form_PvpReplaceInforPop:AddEventListeners()
  self:addEventListener("eGameEvent_Level_ArenaReplaceAFKFresh", handler(self, self.OnAFKFresh))
  self:addEventListener("eGameEvent_ReplaceArena_SeasonInit", handler(self, self.OnArenaSeasonInit))
end

function Form_PvpReplaceInforPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpReplaceInforPop:OnAFKFresh()
  self:FreshRankStageData()
  self:FreshUI()
end

function Form_PvpReplaceInforPop:OnArenaSeasonInit()
  local curSeasonEndTime, nextSeasonStartTime = PvpReplaceManager:GetSeasonTimeByCfg()
  local curServerTime = TimeUtil:GetServerTimeS()
  if curSeasonEndTime <= curServerTime and nextSeasonStartTime > curServerTime then
    self:CloseForm()
  end
end

function Form_PvpReplaceInforPop:CheckUpdateReward()
  if not self.m_isCanUpdateReward then
    return
  end
  if self.m_curDeltaRewardTime <= UpdateRewardDeltaNum then
    self.m_curDeltaRewardTime = self.m_curDeltaRewardTime + 1
  else
    self.m_curDeltaRewardTime = 0
    self:FreshRewardStatus()
  end
end

function Form_PvpReplaceInforPop:FreshRewardStatus()
  local isFull = self:IsAFKFull()
  self.m_isCanUpdateReward = not isFull
  self:FreshMineInfo()
end

function Form_PvpReplaceInforPop:FreshUI()
  self:FreshAllGradeList()
  self:FreshRewardStatus()
end

function Form_PvpReplaceInforPop:FreshMineInfo()
  local afkData = PvpReplaceManager:GetReplaceArenaAfkInfo()
  if not afkData then
    return
  end
  local rankNum = afkData.iRank
  local rankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(rankNum)
  if rankCfg then
    UILuaHelper.SetAtlasSprite(self.m_rank_icon_Image, rankCfg.m_RankIcon)
    self.m_txt_rankname_Text.text = rankCfg.m_mName
    local rewardItemArray = rankCfg.m_PVPAFKReward
    local rewardLen = rewardItemArray.Length
    local curServerTime = TimeUtil:GetServerTimeS()
    local isFull, fullTime = self:IsAFKFull()
    local minAddTime = isFull and fullTime or curServerTime
    local lastFreshTime = afkData.iLastCalcTime
    local localDeltaTime = isFull and fullTime or lastFreshTime
    local deltaSecNum = minAddTime - localDeltaTime
    for i = 1, MaxRewardItemIndex do
      UILuaHelper.SetActive(self["m_pnl_reward" .. i], i <= rewardLen)
      if i <= rewardLen then
        local rewardItemData = rewardItemArray[i - 1]
        local itemID = tonumber(rewardItemData[0])
        local perSecAddNum = tonumber(rewardItemData[1]) / 10000
        local iconPath = ItemManager:GetItemIconPathByID(itemID)
        UILuaHelper.SetAtlasSprite(self["m_img_icon" .. i .. "_Image"], iconPath)
        local lastTimeRewardNum = math.floor((afkData.mReward[itemID] or 0) / 10000)
        local deltaAddRewardNum = math.floor(perSecAddNum * deltaSecNum)
        local curShowRewardNum = math.floor(deltaAddRewardNum + lastTimeRewardNum)
        if curShowRewardNum < 0 then
          curShowRewardNum = 0
        end
        self["m_txt_num" .. i .. "_Text"].text = BigNumFormat(curShowRewardNum)
      end
    end
    self:CheckFreshFirstGradeItem()
  end
end

function Form_PvpReplaceInforPop:FreshAllGradeList()
  if self.m_afkStageInfoList and next(self.m_afkStageInfoList) then
    UILuaHelper.SetActive(self.m_scrollView, true)
    UILuaHelper.SetActive(self.m_img_empty, false)
    self.m_luaRecordGrid:ShowItemList(self.m_afkStageInfoList)
    self.m_luaRecordGrid:LocateTo()
  else
    UILuaHelper.SetActive(self.m_scrollView, false)
    UILuaHelper.SetActive(self.m_img_empty, true)
  end
end

function Form_PvpReplaceInforPop:CheckFreshFirstGradeItem()
  if not self.m_afkStageInfoList or not next(self.m_afkStageInfoList) then
    return
  end
  local gradeItem = self.m_luaRecordGrid:GetShowItemByIndex(1)
  if gradeItem then
    gradeItem:OnFreshData()
  end
end

function Form_PvpReplaceInforPop:OnBtnCloseClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceInforPop:OnBtnReturnClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceInforPop:OnBtnconfirmClicked()
  if not PvpReplaceManager:IsAfkRankCanReward() then
    return
  end
  PvpReplaceManager:ReqReplaceArenaTakeAfk()
end

function Form_PvpReplaceInforPop:OnBtnnoClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceInforPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpReplaceInforPop", Form_PvpReplaceInforPop)
return Form_PvpReplaceInforPop
