local UIItemBase = require("UI/Common/UIItemBase")
local UIPvpReplaceSeasonRewardItem = class("UIPvpReplaceSeasonRewardItem", UIItemBase)
local MaxRewardNum = 2

function UIPvpReplaceSeasonRewardItem:OnInit()
end

function UIPvpReplaceSeasonRewardItem:OnFreshData()
  self:FreshRankRewardUI()
  self:FreshBgShow()
end

function UIPvpReplaceSeasonRewardItem:FreshRankRewardUI()
  if not self.m_itemData then
    return
  end
  local rankCfg = self.m_itemData
  local minRankNum = rankCfg.m_RankMin
  local maxRankNum = rankCfg.m_RankMax
  local showRankStageStr = ""
  if maxRankNum == 0 then
    showRankStageStr = string.format(ConfigManager:GetCommonTextById(100017), tostring(minRankNum))
  else
    showRankStageStr = string.format(ConfigManager:GetCommonTextById(100016), tostring(minRankNum), tostring(maxRankNum))
  end
  self.m_txt_rank_season_Text.text = showRankStageStr
  local rewardItemArray = rankCfg.m_SeasonReward
  local rewardLen = rewardItemArray.Length
  for i = 1, MaxRewardNum do
    UILuaHelper.SetActive(self["m_item_season" .. i], i <= rewardLen)
    if i <= rewardLen then
      local rewardItemData = rewardItemArray[i - 1]
      local itemID = tonumber(rewardItemData[0])
      local itemNum = tonumber(rewardItemData[1])
      ResourceUtil:CreatIconById(self["m_icon_season_reward" .. i .. "_Image"], itemID)
      self["m_txt_season_num" .. i .. "_Text"].text = itemNum
    end
  end
end

function UIPvpReplaceSeasonRewardItem:FreshBgShow()
  if not self.m_itemIndex then
    return
  end
  local leftNumTow = self.m_itemIndex % 2
  UILuaHelper.SetActive(self.m_img_type3, leftNumTow == 1)
  UILuaHelper.SetActive(self.m_img_type4, leftNumTow == 0)
end

return UIPvpReplaceSeasonRewardItem
