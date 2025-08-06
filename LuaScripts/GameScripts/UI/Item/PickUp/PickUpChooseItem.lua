local UIItemBase = require("UI/Common/UIItemBase")
local PickUpChooseItem = class("PickUpChooseItem", UIItemBase)

function PickUpChooseItem:OnInit()
end

function PickUpChooseItem:OnFreshData()
  local cfg = self.m_itemData.cfg
  local chooseIdx = self.m_itemData.chooseIdx
  for index, v in ipairs(cfg) do
    v.chooseIdx = chooseIdx
  end
  local prefabHelper = self.m_pnl_reward_box:GetComponent("PrefabHelper")
  utils.ShowPrefabHelper(prefabHelper, function(go, index, data)
    local transform = go.transform
    transform.localScale = Vector3.one * 0.75
    local item = self:createCommonItem(go)
    local processData = ResourceUtil:GetProcessRewardData(data)
    item:SetItemInfo(processData)
    local isChoose = false
    if data.chooseIdx then
      isChoose = data.chooseIdx == index
    end
    item:SetItemHaveGetActive(isChoose)
    item:SetItemIconClickCB(function()
      self:OnCommonItemClk(index + 1)
    end)
    item:SetItemIconLongPress(handler(self, self.OnItemLongClk))
  end, cfg)
  local bIsChoose = chooseIdx and true or false
  self.m_common_item_selected:SetActive(bIsChoose)
  if bIsChoose then
    local pickUpReward = cfg[chooseIdx + 1]
    pickUpReward = pickUpReward or cfg[1]
    local item = self:createCommonItem(self.m_common_item_selected)
    local processData = ResourceUtil:GetProcessRewardData(pickUpReward)
    item:SetItemInfo(processData)
    item:SetItemIconClickCB(function(itemID, itemNum)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
  end
end

function PickUpChooseItem:OnCommonItemClk(index)
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex, index)
  end
end

function PickUpChooseItem:OnItemLongClk(itemID, itemNum)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return PickUpChooseItem
