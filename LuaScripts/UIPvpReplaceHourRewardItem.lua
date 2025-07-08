local UIItemBase = require("UI/Common/UIItemBase")
local UIPvpReplaceHourRewardItem = class("UIPvpReplaceHourRewardItem", UIItemBase)
local MaxRewardNum = 3

function UIPvpReplaceHourRewardItem:OnInit()
end

function UIPvpReplaceHourRewardItem:OnFreshData()
  self:FreshRankRewardUI()
  self:FreshBgShow()
end

function UIPvpReplaceHourRewardItem:FreshRankRewardUI()
  if not self.m_itemData then
    return
  end
  local rankCfg = self.m_itemData
  UILuaHelper.SetAtlasSprite(self.m_icon_silver_Image, rankCfg.m_RankIcon)
  self.m_txt_sliver_name_Text.text = rankCfg.m_mName
  local rewardItemArray = rankCfg.m_PVPAFKReward
  local rewardLen = rewardItemArray.Length
  for i = 1, MaxRewardNum do
    UILuaHelper.SetActive(self["m_item" .. i], i <= rewardLen)
    if i <= rewardLen then
      local rewardItemData = rewardItemArray[i - 1]
      local itemID = tonumber(rewardItemData[0])
      local perHourAddNum = math.floor(tonumber(rewardItemData[1]) * 3600 / 10000)
      ResourceUtil:CreatIconById(self["m_icon_reward" .. i .. "_Image"], itemID)
      self["m_txt_num" .. i .. "_Text"].text = perHourAddNum .. "/H"
    end
  end
end

function UIPvpReplaceHourRewardItem:FreshBgShow()
  if not self.m_itemIndex then
    return
  end
  local leftNumTow = self.m_itemIndex % 2
  UILuaHelper.SetActive(self.m_img_type1, leftNumTow == 1)
  UILuaHelper.SetActive(self.m_img_type2, leftNumTow == 0)
end

return UIPvpReplaceHourRewardItem
