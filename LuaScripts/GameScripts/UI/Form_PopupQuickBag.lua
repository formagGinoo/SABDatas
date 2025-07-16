local Form_PopupQuickBag = class("Form_PopupQuickBag", require("UI/UIFrames/Form_PopupQuickBagUI"))

function Form_PopupQuickBag:SetInitParam(param)
end

function Form_PopupQuickBag:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_listInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_list_item_InfinityGrid, "UICommonItem", initGridData)
  self.m_listInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnItemClk))
  self.m_costItemList = {}
end

function Form_PopupQuickBag:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_costItemList = {}
  self.m_QuickBagType = tParam.quickBagType
  self.m_costList = tParam.costList or {}
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_PopupQuickBag:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_costItemList = {}
end

function Form_PopupQuickBag:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Use", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_PopupQuickBag:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PopupQuickBag:GenerateData()
  local itemIdList = ItemManager:GetQuickBagItem()
  local itemList = {}
  for i, list in pairs(itemIdList) do
    if i == self.m_QuickBagType or i == ItemManager.ItemQuickUseType.LevelUp then
      for m, itemId in pairs(list) do
        local num = ItemManager:GetItemNum(itemId)
        if 0 < num then
          itemList[#itemList + 1] = ResourceUtil:GetProcessRewardData({itemId, num})
        end
      end
    end
  end
  
  local function sortFun(data1, data2)
    if data1.sub_type == data2.sub_type then
      if data1.quality == data2.quality then
        return data1.data_id < data2.data_id
      else
        return data1.quality > data2.quality
      end
    else
      return data1.sub_type > data2.sub_type
    end
  end
  
  table.sort(itemList, sortFun)
  return itemList
end

function Form_PopupQuickBag:RefreshUI()
  self.m_ItemList = self:GenerateData()
  self.m_list_item:SetActive(table.getn(self.m_ItemList) > 0)
  self.m_pnl_empty:SetActive(table.getn(self.m_ItemList) == 0)
  self.m_listInfinityGrid:ShowItemList(self.m_ItemList)
  local costList = {}
  for i, v in ipairs(self.m_costList) do
    costList[#costList + 1] = ResourceUtil:GetProcessRewardData({
      v[1],
      0
    })
  end
  for i = 1, 4 do
    self["m_cost_item" .. i]:SetActive(i <= #costList)
    if i <= #costList then
      if self.m_costItemList[i] == nil then
        self.m_costItemList[i] = self:createCommonItem(self["m_cost_item" .. i])
      end
      self.m_costItemList[i]:SetItemInfo(costList[i])
      self.m_costItemList[i]:SetItemIconClickCB(handler(self, self.OnNeedItemClk))
      local userItemNum = ItemManager:GetItemNum(costList[i].data_id)
      self.m_costItemList[i]:SetNeedNum(self.m_costList[i][2], userItemNum)
    end
  end
end

function Form_PopupQuickBag:OnItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_ItemList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    }, nil, true)
  end
end

function Form_PopupQuickBag:OnNeedItemClk(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function Form_PopupQuickBag:IsOpenGuassianBlur()
  return true
end

function Form_PopupQuickBag:IsFullScreen()
  return false
end

function Form_PopupQuickBag:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_PopupQuickBag", Form_PopupQuickBag)
return Form_PopupQuickBag
