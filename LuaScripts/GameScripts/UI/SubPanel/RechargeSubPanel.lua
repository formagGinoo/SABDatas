local UISubPanelBase = require("UI/Common/UISubPanelBase")
local RechargeSubPanel = class("RechargeSubPanel", UISubPanelBase)

function RechargeSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_buy_list_InfinityGrid, "PayStore/RechargeItem")
end

function RechargeSubPanel:OnInactivePanel()
  self.m_ListInfinityGrid:ShowItemList({})
end

function RechargeSubPanel:OnUpdate(dt)
  if table.getn(self.goodsList) > 0 then
    for _, v in ipairs(self.goodsList) do
      if v.delalyActiveTime and 0 <= v.delalyActiveTime then
        v.delalyActiveTime = v.delalyActiveTime - dt
      end
    end
  end
  self.m_ListInfinityGrid:OnUpdate(dt)
end

function RechargeSubPanel:OnActivePanel()
  if table.getn(self.goodsList) == 0 then
    return
  end
  for i, v in ipairs(self.goodsList) do
    v.delalyActiveTime = math.floor((i - 1) / self.m_buy_list_InfinityGrid.CellPerLine) * 0.1 + 0.1
  end
  self.m_ListInfinityGrid:ShowItemList(self.goodsList, true)
  self.m_ListInfinityGrid:LocateTo(0)
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "panel_recharge_in")
end

function RechargeSubPanel:OnFreshData()
  local store = self.m_panelData.storeData
  if table.getn(self.goodsList) > 0 then
    for _, v in ipairs(self.goodsList) do
      v.delalyActiveTime = nil
    end
  end
  self.goodsList = {}
  for _, v in pairs(store.stGoodsConfig.mGoods) do
    v.iStoreId = store.iStoreId
    table.insert(self.goodsList, v)
  end
  table.sort(self.goodsList, function(a, b)
    return a.iGoodsId < b.iGoodsId
  end)
end

function RechargeSubPanel:RefreshList()
  self.m_ListInfinityGrid:ReBindAll()
end

return RechargeSubPanel
