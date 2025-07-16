local UISubPanelBase = require("UI/Common/UISubPanelBase")
local CommonUpPackSubPanel = class("CommonUpPackSubPanel", UISubPanelBase)

function CommonUpPackSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_item_list_act_InfinityGrid, "PayStore/PaidGiftPackUpCommonItem", nil, true)
end

function CommonUpPackSubPanel:OnFreshData()
  self.m_storeData = self.m_panelData.storeData
  self.m_bg = nil
  self:RefreshData()
  self:RefreshUI()
end

function CommonUpPackSubPanel:RefreshUI(dt)
  self.m_ListInfinityGrid:ShowItemList(self.goodsList)
  self.m_ListInfinityGrid:LocateTo(0)
  self:RefreshBg()
end

function CommonUpPackSubPanel:RefreshBg()
  if self.m_bg and self.m_bg ~= "" then
    UILuaHelper.SetUITexture(self.m_img_bg_act_Image, self.m_bg)
  end
end

function CommonUpPackSubPanel:OnUpdate(dt)
  if not self.m_storeData then
    return
  end
  self.m_ListInfinityGrid:OnUpdate(dt)
end

function CommonUpPackSubPanel:RefreshData()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  self.goodsList = {}
  for k, v in pairs(self.m_storeData.stGoodsConfig.mGoods) do
    v.iStoreId = self.m_storeData.iStoreId
    local buyTimes = payStoreActivity:GetBuyCount(v.iStoreId, v.iGoodsId)
    v.SortOrder = v.iShowOrder
    if v.iLimitNum > 0 and buyTimes >= v.iLimitNum then
      v.SortOrder = v.SortOrder + 100000
    end
    v.configBg = self.m_storeData.stUpInterfaceResourceConfig
    table.insert(self.goodsList, v)
  end
  
  local function sortFunc(a, b)
    if a.SortOrder ~= b.SortOrder then
      return a.SortOrder < b.SortOrder
    end
    return a.iGoodsId < b.iGoodsId
  end
  
  self.m_bg = self.m_storeData.stUpInterfaceResourceConfig.sGiftBackground or ""
  table.sort(self.goodsList, sortFunc)
end

function CommonUpPackSubPanel:OnActivePanel()
end

function CommonUpPackSubPanel:OnInactivePanel()
  self.m_ListInfinityGrid:ShowItemList({})
end

return CommonUpPackSubPanel
