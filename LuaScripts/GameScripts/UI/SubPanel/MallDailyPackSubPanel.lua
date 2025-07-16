local UISubPanelBase = require("UI/Common/UISubPanelBase")
local MallDailyPackSubPanel = class("MallDailyPackSubPanel", UISubPanelBase)

function MallDailyPackSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_daily_list_InfinityGrid, "PayStore/PaidGiftPackItem", nil, true)
end

local ITEM_WIDTH = 435

function MallDailyPackSubPanel:OnUpdate(dt)
  if self.goodsList then
    for _, v in ipairs(self.goodsList) do
      if v.delalyActiveTime and v.delalyActiveTime >= 0 then
        v.delalyActiveTime = v.delalyActiveTime - dt
      end
    end
  end
  self.m_ListInfinityGrid:OnUpdate(dt)
end

function MallDailyPackSubPanel:OnActivePanel()
  self:SetCellPerLine()
  self:FreshUI()
end

function MallDailyPackSubPanel:OnFreshData()
  self:SendReportData()
  self.openTime = TimeUtil:GetServerTimeS()
end

function MallDailyPackSubPanel:SetCellPerLine()
  local count = math.floor(self.m_daily_list.transform.rect.width / ITEM_WIDTH)
  count = 5 < count and 5 or count
  count = count < 4 and 4 or count
  self.m_ListInfinityGrid:SetCellPerLine(count)
end

function MallDailyPackSubPanel:FreshUI()
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
    v.iStoreType = store.iStoreType
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
    v.delalyActiveTime = math.floor((i - 1) / self.m_daily_list_InfinityGrid.CellPerLine) * 0.1 + 0.1
  end
  self.m_ListInfinityGrid:ShowItemList(self.goodsList)
  self.m_ListInfinityGrid:LocateTo(0)
end

function MallDailyPackSubPanel:OnInactivePanel()
  self:SendReportData()
  self.openTime = nil
  self.m_ListInfinityGrid:ShowItemList({})
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function MallDailyPackSubPanel:SendReportData()
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

return MallDailyPackSubPanel
