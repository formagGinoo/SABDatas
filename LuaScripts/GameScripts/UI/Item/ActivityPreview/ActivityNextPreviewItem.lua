local UIItemBase = require("UI/Common/UIItemBase")
local ActivityNextPreviewItem = class("ActivityNextPreviewItem", UIItemBase)

function ActivityNextPreviewItem:OnInit()
  self.mPrefabHelper = self.m_reward:GetComponent("PrefabHelper")
end

function ActivityNextPreviewItem:OnFreshData()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Calendar)
  if not activity then
    return
  end
  local itemData = self.m_itemData
  if not itemData then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_icon_Image, itemData.sIcon)
  self.m_txt_tips_Text.text = activity:getLangText(itemData.sName)
  utils.ShowPrefabHelper(self.mPrefabHelper, function(go, index, data)
    UILuaHelper.SetLocalScale(go.transform, 0.8, 0.8, 0.8)
    local rewardData = ResourceUtil:GetProcessRewardData({iID = data})
    local commonItem = self:createCommonItem(go)
    commonItem:SetItemInfo(rewardData)
    commonItem:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnRewardItemClick(itemID, itemNum, itemCom)
    end)
  end, itemData.vReward)
end

function ActivityNextPreviewItem:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return ActivityNextPreviewItem
