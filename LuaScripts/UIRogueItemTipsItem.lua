local UIItemBase = require("UI/Common/UIItemBase")
local UIRogueItemTipsItem = class("UIRogueItemTipsItem", UIItemBase)
local __MAX_NUM = 5

function UIRogueItemTipsItem:OnInit()
  self.m_rogue_Item_list = {}
  self.m_rogue_Item_list[1] = {}
  self.m_rogue_Item_list[1].rogueItem = self:createRogueItemIcon(self.m_rogue_itemformula1)
  self.m_rogue_Item_list[1].formula = self.m_rogue_itemformula1.transform:Find("m_pnl_formula1").gameObject
  self.m_rogue_Item_list[1].obj = self.m_rogue_itemformula1
  self.m_rogue_Item_list[1].pnl_add = self.m_pnl_add1
  self.m_rogue_Item_list[1].pnl_equal = self.m_pnl_equal1
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
end

function UIRogueItemTipsItem:createItem(index)
  local tempItem = self.m_item_list.transform:Find("m_rogue_itemformula" .. index)
  if utils.isNull(tempItem) then
    tempItem = GameObject.Instantiate(self.m_rogue_itemformula1, self.m_item_list.transform)
    tempItem.gameObject.name = "m_rogue_itemformula" .. index
  end
  local rogueItem = self:createRogueItemIcon(tempItem.gameObject)
  local formula = tempItem.transform:Find("m_pnl_formula1").gameObject
  local m_pnl_add1 = tempItem.transform:Find("m_pnl_formula1/m_pnl_add1").gameObject
  local m_pnl_equal1 = tempItem.transform:Find("m_pnl_formula1/m_pnl_equal1").gameObject
  self.m_rogue_Item_list[index] = {}
  self.m_rogue_Item_list[index].rogueItem = rogueItem
  self.m_rogue_Item_list[index].formula = formula
  self.m_rogue_Item_list[index].pnl_add = m_pnl_add1
  self.m_rogue_Item_list[index].pnl_equal = m_pnl_equal1
  self.m_rogue_Item_list[index].obj = tempItem.gameObject
end

function UIRogueItemTipsItem:OnFreshData()
  local data = self.m_itemData
  if not data then
    return
  end
  self.m_haveItemList = table.deepcopy(self.m_itemData.haveItemList)
  for i = 1, __MAX_NUM do
    if not self.m_rogue_Item_list[i] then
      self:createItem(i)
    end
    local id = data["materialId" .. i - 1]
    if id and id ~= 0 then
      UILuaHelper.SetActive(self.m_rogue_Item_list[i].obj, true)
      UILuaHelper.SetActive(self.m_rogue_Item_list[i].formula, true)
      local cfg = self.m_levelRogueStageHelper:GetRogueItemCfgByID(id)
      local isHave = self:IsHaveItem(id)
      self.m_rogue_Item_list[i].rogueItem:SetItemInfo({
        itemId = id,
        hideType = true,
        showAnim = cfg.m_ItemType == RogueStageManager.RogueStageItemType.Product,
        sort = data.sort,
        isHave = isHave,
        checkIsHave = data.checkIsHave,
        synthesisFlag = self.m_itemData.synthesisFlag
      })
      if i == __MAX_NUM and self.m_rogue_Item_list[i] and self.m_rogue_Item_list[i].formula then
        UILuaHelper.SetActive(self.m_rogue_Item_list[i].formula, false)
      end
    else
      UILuaHelper.SetActive(self.m_rogue_Item_list[i].obj, false)
      if self.m_rogue_Item_list[i - 1] and self.m_rogue_Item_list[i - 1].formula then
        UILuaHelper.SetActive(self.m_rogue_Item_list[i - 1].formula, false)
      end
    end
    UILuaHelper.SetActive(self.m_rogue_Item_list[i].pnl_add, i ~= 1)
    UILuaHelper.SetActive(self.m_rogue_Item_list[i].pnl_equal, i == 1)
  end
  self.m_img_title:SetActive(data.showTitle)
end

function UIRogueItemTipsItem:IsHaveItem(itemId)
  if table.getn(self.m_haveItemList) > 0 then
    local index = table.indexof(self.m_haveItemList, itemId)
    if index then
      table.remove(self.m_haveItemList, index)
      return true
    else
      return false
    end
  else
    return false
  end
end

function UIRogueItemTipsItem:OnDestroy()
  UIRogueItemTipsItem.super.OnDestroy(self)
end

return UIRogueItemTipsItem
