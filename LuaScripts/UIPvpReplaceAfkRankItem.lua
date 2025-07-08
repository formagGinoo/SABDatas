local UIItemBase = require("UI/Common/UIItemBase")
local UIPvpReplaceAfkRankItem = class("UIPvpReplaceAfkRankItem", UIItemBase)
local MaxRewardItemIndex = 2

function UIPvpReplaceAfkRankItem:OnInit()
end

function UIPvpReplaceAfkRankItem:IsAFKFull()
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

function UIPvpReplaceAfkRankItem:OnFreshData()
  self:FreshRankInfo()
  self:FreshRewardInfo()
  self:FreshRankTime()
end

function UIPvpReplaceAfkRankItem:FreshRankInfo()
  if not self.m_itemData then
    return
  end
  local rankCfg = self.m_itemData.replaceArenaRankCfg
  if not rankCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_rank_item_Image, rankCfg.m_RankIcon)
  self.m_txt_name_item_Text.text = rankCfg.m_mName
end

function UIPvpReplaceAfkRankItem:FreshRewardInfo()
  if not self.m_itemData then
    return
  end
  local recordInfo = self.m_itemData.recordInfo
  local rankCfg = self.m_itemData.replaceArenaRankCfg
  local startTime = recordInfo.iStartTime
  local userEndTime = recordInfo.iEndTime
  local isFull, fullTime = self:IsAFKFull()
  if recordInfo.iEndTime == 0 then
    userEndTime = isFull and fullTime or TimeUtil:GetServerTimeS()
  else
    userEndTime = recordInfo.iEndTime
    if fullTime < userEndTime then
      userEndTime = fullTime
    end
  end
  local rewardItemArray = rankCfg.m_PVPAFKReward
  local rewardLen = rewardItemArray.Length
  local deltaSecNum = userEndTime - startTime
  local limitTimeSecNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaAFKLimit"))
  if deltaSecNum >= limitTimeSecNum then
    deltaSecNum = limitTimeSecNum
  end
  for i = 1, MaxRewardItemIndex do
    UILuaHelper.SetActive(self["m_item_reward" .. i], rewardLen >= i)
    if rewardLen >= i then
      local rewardItemData = rewardItemArray[i - 1]
      local itemID = tonumber(rewardItemData[0])
      local perSecAddNum = tonumber(rewardItemData[1]) / 10000
      local iconPath = ItemManager:GetItemIconPathByID(itemID)
      UILuaHelper.SetAtlasSprite(self["m_img_item_icon" .. i .. "_Image"], iconPath)
      local curShowRewardNum = math.floor(perSecAddNum * deltaSecNum)
      if curShowRewardNum < 0 then
        curShowRewardNum = 0
      end
      self["m_txt_item_num" .. i .. "_Text"].text = BigNumFormat(curShowRewardNum)
    end
  end
end

function UIPvpReplaceAfkRankItem:FreshRankTime()
  if not self.m_itemData then
    return
  end
  local startTime = self.m_itemData.recordInfo.iStartTime
  local curServerTime = TimeUtil:GetServerTimeS()
  local deltaTimeSec = curServerTime - startTime
  local timeStr = TimeUtil:SecondsToFormatStrPvp(deltaTimeSec)
  self.m_txt_time_Text.text = timeStr
end

return UIPvpReplaceAfkRankItem
