local UISubPanelBase = require("UI/Common/UISubPanelBase")
local RechargeSubPanel = class("RechargeSubPanel", UISubPanelBase)

function RechargeSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_buy_list_InfinityGrid, "PayStore/RechargeItem")
end

function RechargeSubPanel:OnInactivePanel()
end

function RechargeSubPanel:OnActivePanel()
  if table.getn(self.goodsList) == 0 then
    return
  end
  self.m_ListInfinityGrid:ShowItemList(self.goodsList, true)
  self.m_ListInfinityGrid:LocateTo(0)
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "panel_recharge_in")
end

function RechargeSubPanel:OnFreshData()
  local store = self.m_panelData.storeData
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
