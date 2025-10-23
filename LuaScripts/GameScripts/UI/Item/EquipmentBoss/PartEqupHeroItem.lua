local UIItemBase = require("UI/Common/UIItemBase")
local PartEqupHeroItem = class("PartEqupHeroItem", UIItemBase)

function PartEqupHeroItem:OnInit()
  self.m_img_head = self.m_itemRootObj.transform:Find("m_item_headnormal/pnl_item_head/pnl_head_mask/m_img_head"):GetComponent("CircleImage")
  self.m_img_headgrey = self.m_itemRootObj.transform:Find("m_item_headgreay/pnl_headgrey/pnl_head_mask/m_img_headgrey"):GetComponent("CircleImage")
  self.m_item_headnormal = self.m_itemRootObj.transform:Find("m_item_headnormal").gameObject
  self.m_item_headgreay = self.m_itemRootObj.transform:Find("m_item_headgreay").gameObject
  if not self.btnObj then
    self.btnObj = self.m_itemRootObj.transform:GetComponent(T_Button)
    UILuaHelper.BindButtonClickManual(self, self.btnObj, function()
      if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
        self.m_itemInitData.itemClkBackFun(self.m_itemIndex, self.m_itemInitData.isLock)
      end
    end)
  end
end

function PartEqupHeroItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function PartEqupHeroItem:OnItemClick(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
end

function PartEqupHeroItem:SetItemInfo(itemData)
  UILuaHelper.SetBaseImageAtlasSprite(self.m_img_head, itemData.m_RoleHead)
  UILuaHelper.SetBaseImageAtlasSprite(self.m_img_headgrey, itemData.m_RoleHead)
  self.m_item_headnormal:SetActive(itemData.isValid)
  self.m_item_headgreay:SetActive(not itemData.isValid)
end

return PartEqupHeroItem
