local UISubPanelBase = require("UI/Common/UISubPanelBase")
local LimitUpPackSubPanel = class("LimitUpPackSubPanel", UISubPanelBase)

function LimitUpPackSubPanel:OnInit()
  self.m_ListInfinityGrid1 = require("UI/Common/UIInfinityGrid").new(self.m_item_list_Lamia_InfinityGrid, "PayStore/PaidGiftPackItem", nil, true)
  self.m_ListInfinityGrid2 = require("UI/Common/UIInfinityGrid").new(self.m_item_list_Darcaro_InfinityGrid, "PayStore/PaidGiftPackItem", nil, true)
end

function LimitUpPackSubPanel:OnFreshData()
  self.m_storeData = self.m_panelData.storeData
  self:RefreshData()
end

function LimitUpPackSubPanel:OnUpdate(dt)
  if not self.m_storeData then
    return
  end
  if self.m_storeData.iShowType == 3 then
    self.m_ListInfinityGrid1:OnUpdate(dt)
  elseif self.m_storeData.iShowType == 4 then
    self.m_ListInfinityGrid2:OnUpdate(dt)
  end
end

function LimitUpPackSubPanel:RefreshData()
  self.m_ListInfinityGrid = self.m_ListInfinityGrid1
  if self.m_storeData.iShowType == 3 then
    self.m_img_bg_Lamia:SetActive(true)
    self.m_img_bg_Darcaro:SetActive(false)
    self.m_ListInfinityGrid = self.m_ListInfinityGrid1
    self.m_pnl_list_Lamia:SetActive(true)
    self.m_pnl_list_Darcaro:SetActive(false)
  elseif self.m_storeData.iShowType == 4 then
    self.m_img_bg_Lamia:SetActive(false)
    self.m_img_bg_Darcaro:SetActive(true)
    self.m_ListInfinityGrid = self.m_ListInfinityGrid2
    self.m_pnl_list_Lamia:SetActive(false)
    self.m_pnl_list_Darcaro:SetActive(true)
  end
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  self.goodsList = {}
  for k, v in pairs(self.m_storeData.stGoodsConfig.mGoods) do
    v.iStoreId = self.m_storeData.iStoreId
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
  self.m_ListInfinityGrid:ShowItemList(self.goodsList)
  self.m_ListInfinityGrid:LocateTo(0)
end

function LimitUpPackSubPanel:OnActivePanel()
end

function LimitUpPackSubPanel:OnInactivePanel()
  self.m_ListInfinityGrid:ShowItemList({})
end

return LimitUpPackSubPanel
