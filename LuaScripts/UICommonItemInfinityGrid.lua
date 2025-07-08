local BaseNode = require("UI/Common/UIInfinityGrid")
local UICommonItemInfinityGrid = class("UICommonItemInfinityGrid", BaseNode)

function UICommonItemInfinityGrid:ctor(infinityGrid, itemLuaName, initItemData)
  UICommonItemInfinityGrid.super.ctor(self, infinityGrid, itemLuaName, initItemData)
  if not infinityGrid then
    return
  end
  self.m_selectIndex = nil
end

function UICommonItemInfinityGrid:OnChooseItem(itemIndex, showFlag)
  itemIndex = itemIndex or 1
  local item = self:GetShowItemByIndex(itemIndex)
  if item then
    item:OnChooseItem(showFlag)
  else
    local itemData = self.m_itemDataList[itemIndex]
    if itemData then
      itemData.is_selected = showFlag
    end
  end
end

function UICommonItemInfinityGrid:SetUpGradeNum(itemIndex, num)
  itemIndex = itemIndex or 1
  local item = self:GetShowItemByIndex(itemIndex)
  if item then
    item:SetUpGradeNum(num)
  else
    local itemData = self.m_itemDataList[itemIndex]
    if itemData and itemData.customData then
      itemData.customData.sel_upgrade_item_num = num
    elseif itemData then
      itemData.customData = {}
      itemData.customData.sel_upgrade_item_num = num
    end
  end
end

return UICommonItemInfinityGrid
