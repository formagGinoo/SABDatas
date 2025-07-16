local UISubPanelBase = require("UI/Common/UISubPanelBase")
local StepGiftSubPanel = class("StepGiftSubPanel", UISubPanelBase)

function StepGiftSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_gift_list_InfinityGrid, "PayStore/StepPaidGiftPackItem")
  self.lastItemData = nil
end

function StepGiftSubPanel:OnFreshData()
  self.m_storeData = self.m_panelData.storeData
  self:RefreshData()
  self:RefreshList()
  self.m_curBuyIndex = 0
end

function StepGiftSubPanel:OnUpdate(dt)
  if self.tempData then
    for _, v in ipairs(self.tempData) do
      if v.delalyActiveTime and v.delalyActiveTime >= 0 then
        v.delalyActiveTime = v.delalyActiveTime - dt
      end
    end
  end
  self.m_ListInfinityGrid:OnUpdate(dt)
end

function StepGiftSubPanel:RefreshData()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  local goodsData = self.m_storeData.stGoodsConfig.mGoods
  table.sort(goodsData, function(a, b)
    return a.iGoodsId < b.iGoodsId
  end)
  if self.tempData then
    for _, v in ipairs(self.tempData) do
      v.delalyActiveTime = nil
    end
  end
  self.tempData = {}
  for i = 1, #goodsData do
    local config = goodsData[i]
    if not config.iStoreId then
      config.iStoreId = self.m_storeData.iStoreId
    end
    local buyTimes = tonumber(payStoreActivity:GetBuyCount(config.iStoreId, config.iGoodsId))
    local sellOut = buyTimes >= config.iLimitNum and config.iLimitNum > 0
    config.m_Sellout = sellOut
    local isBlockBuy = false
    local lastbuyTimes = payStoreActivity:GetBuyCount(config.iStoreId, config.iPreGoodsId)
    if 1 <= lastbuyTimes then
      isBlockBuy = false
    elseif config.iPreGoodsId == 0 then
      isBlockBuy = false
    else
      isBlockBuy = true
    end
    config.isBlockBuy = isBlockBuy
    if not isBlockBuy and not sellOut then
      self.m_curBuyIndex = i - 1
    end
    table.insert(self.tempData, config)
  end
  for i, v in ipairs(self.tempData) do
    v.delalyActiveTime = (i - 1) * 0.04
  end
  self.m_ListInfinityGrid:LocateTo(self.m_curBuyIndex)
end

function StepGiftSubPanel:OnActivePanel()
end

function StepGiftSubPanel:OnInactivePanel()
end

function StepGiftSubPanel:RefreshList()
  self.m_ListInfinityGrid:ShowItemList(self.tempData)
end

function StepGiftSubPanel:OnBtntipsClicked()
  utils.popUpDirectionsUI({tipsID = 1195})
end

return StepGiftSubPanel
