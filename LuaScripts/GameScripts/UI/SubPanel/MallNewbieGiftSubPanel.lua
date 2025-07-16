local UISubPanelBase = require("UI/Common/UISubPanelBase")
local MallNewbieGiftSubPanel = class("MallNewbieGiftSubPanel", UISubPanelBase)

function MallNewbieGiftSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_daily_list_InfinityGrid, "PayStore/PaidGiftPackItem", nil, true)
end

function MallNewbieGiftSubPanel:OnUpdate(dt)
  if self.goodsList then
    for _, v in ipairs(self.goodsList) do
      if v.delalyActiveTime and v.delalyActiveTime >= 0 then
        v.delalyActiveTime = v.delalyActiveTime - dt
      end
    end
  end
  self.m_ListInfinityGrid:OnUpdate(dt)
end

function MallNewbieGiftSubPanel:OnFreshData()
  self:SendReportData()
  self.openTime = TimeUtil:GetServerTimeS()
  self:FreshUI()
end

function MallNewbieGiftSubPanel:FreshUI()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not payStoreActivity then
    return
  end
  local store = self.m_panelData.storeData
  if not store then
    return
  end
  if self.goodsList then
    for _, v in ipairs(self.goodsList) do
      v.delalyActiveTime = nil
    end
  end
  self.goodsList = {}
  for k, v in pairs(store.stGoodsConfig.mGoods) do
    v.iStoreId = store.iStoreId
    local buyTimes = payStoreActivity:GetBuyCount(v.iStoreId, v.iGoodsId)
    v.SortOrder = v.iShowOrder
    if v.iLimitNum > 0 and buyTimes >= v.iLimitNum then
      v.SortOrder = v.SortOrder + 100000
    end
    table.insert(self.goodsList, v)
  end
  
  local function sortFunc(a, b)
    if a.SortOrder ~= b.SortOrder then
      return a.SortOrder < b.SortOrder
    end
    return a.iGoodsId < b.iGoodsId
  end
  
  table.sort(self.goodsList, sortFunc)
  for i, v in ipairs(self.goodsList) do
    v.delalyActiveTime = 0
  end
  self.m_ListInfinityGrid:ShowItemList(self.goodsList)
  self.m_ListInfinityGrid:LocateTo(0)
end

function MallNewbieGiftSubPanel:OnInactivePanel()
  self:SendReportData()
  self.openTime = nil
  self.m_ListInfinityGrid:ShowItemList({})
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function MallNewbieGiftSubPanel:SendReportData()
  if self.openTime == nil then
    return
  end
  local second = TimeUtil:GetServerTimeS() - self.openTime
  if second < 2 then
    return
  end
  local store = self.m_panelData.storeData
  local reportData = {
    stayTime = second,
    windowId = store.iWindowID,
    storeName = store.sStoreName,
    storeDes = store.sStoreDesc,
    giftPackType = 1,
    storeId = store.iStoreId
  }
  ReportManager:ReportProductView(reportData)
  self.openTime = TimeUtil:GetServerTimeS()
end

return MallNewbieGiftSubPanel
