local UIItemBase = require("UI/Common/UIItemBase")
local UIPvpReplaceRecordItem = class("UIPvpReplaceRecordItem", UIItemBase)

function UIPvpReplaceRecordItem:OnInit()
  self.m_playerHeadCom = self:createPlayerHead(self.m_circle_head)
  self.m_playerHeadCom:SetStopClkStatus(true)
end

function UIPvpReplaceRecordItem:OnFreshData()
  self:FreshPlayerInfo()
  self:FreshRankTime()
  self:FreshRankInfo()
end

function UIPvpReplaceRecordItem:FreshPlayerInfo()
  if not self.m_itemData then
    return
  end
  local recordInfo = self.m_itemData
  local enemySimpleInfo = recordInfo.stEnemySimple
  local enemyNameStr = enemySimpleInfo.sName
  self.m_txt_name_Text.text = enemyNameStr
  self.m_playerHeadCom:SetPlayerHeadInfo(enemySimpleInfo)
  self.m_txt_guild_name_Text.text = enemySimpleInfo.sAlliance ~= "" and enemySimpleInfo.sAlliance or ConfigManager:GetCommonTextById(20111) or ""
end

function UIPvpReplaceRecordItem:FreshRankInfo()
  if not self.m_itemData then
    return
  end
  local recordInfo = self.m_itemData
  UILuaHelper.SetActive(self.m_z_txt_win, recordInfo.bWin)
  UILuaHelper.SetActive(self.m_z_txt_lose, not recordInfo.bWin)
  UILuaHelper.SetActive(self.m_icon_offensive, recordInfo.bIsAttacker)
  UILuaHelper.SetActive(self.m_icon_defensive, not recordInfo.bIsAttacker)
  local newRankNum = recordInfo.iRank
  local oldRankNum = recordInfo.iOldRank
  local changeRankNum = newRankNum - oldRankNum
  self.m_txt_rank_num_Text.text = newRankNum
  if changeRankNum == 0 then
    UILuaHelper.SetActive(self.m_icon_arrow01, false)
    UILuaHelper.SetActive(self.m_icon_arrow02, false)
    UILuaHelper.SetActive(self.m_txt_rank_numup, false)
    UILuaHelper.SetActive(self.m_txt_rank_numdown, false)
  else
    UILuaHelper.SetActive(self.m_icon_arrow01, changeRankNum < 0)
    UILuaHelper.SetActive(self.m_icon_arrow02, 0 < changeRankNum)
    UILuaHelper.SetActive(self.m_txt_rank_numup, changeRankNum < 0)
    UILuaHelper.SetActive(self.m_txt_rank_numdown, 0 < changeRankNum)
    if changeRankNum < 0 then
      self.m_txt_rank_numup_Text.text = math.abs(changeRankNum)
    else
      self.m_txt_rank_numdown_Text.text = math.abs(changeRankNum)
    end
  end
end

function UIPvpReplaceRecordItem:FreshRankTime()
  if not self.m_itemData then
    return
  end
  local recordInfo = self.m_itemData
  local timeNum = recordInfo.iTime
  local curServerTime = TimeUtil:GetServerTimeS()
  local deltaTimeSec = curServerTime - timeNum
  local timeStr = TimeUtil:SecondsToFormatStrPvp(deltaTimeSec)
  self.m_txt_battle_time_Text.text = timeStr
end

return UIPvpReplaceRecordItem
