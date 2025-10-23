local UIItemBase = require("UI/Common/UIItemBase")
local PartEqupLevelItem = class("PartEqupLevelItem", UIItemBase)

function PartEqupLevelItem:OnInit()
  self.m_txt_leveldone = self.m_itemRootObj.transform:Find("m_pnl_leveldone/m_txt_leveldone"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_levelnow = self.m_itemRootObj.transform:Find("m_pnl_levelnow/m_txt_levelnow"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_levellock = self.m_itemRootObj.transform:Find("m_pnl_levellock/m_txt_levellock"):GetComponent(T_TextMeshProUGUI)
  self.m_pnl_leveldone = self.m_itemRootObj.transform:Find("m_pnl_leveldone").gameObject
  self.m_pnl_levelnow = self.m_itemRootObj.transform:Find("m_pnl_levelnow").gameObject
  self.m_pnl_levellock = self.m_itemRootObj.transform:Find("m_pnl_levellock").gameObject
  if not self.btnObj then
    self.btnObj = self.m_itemRootObj.transform:Find("m_btn_content"):GetComponent(T_Button)
    UILuaHelper.BindButtonClickManual(self, self.btnObj, function()
      if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
        self.m_itemInitData.itemClkBackFun(self.m_itemIndex, self.m_itemInitData.isLock)
      end
    end)
  end
end

function PartEqupLevelItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function PartEqupLevelItem:OnItemClick(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
end

function PartEqupLevelItem:SetItemInfo(itemData)
  self.m_txt_leveldone.text = itemData.cfg and itemData.cfg.m_mName or ""
  self.m_txt_levelnow.text = itemData.cfg and itemData.cfg.m_mName or ""
  self.m_txt_levellock.text = itemData.cfg and itemData.cfg.m_mName or ""
  self.m_pnl_levelnow:SetActive(not itemData.isLock and itemData.selected)
  self.m_pnl_leveldone:SetActive(not itemData.isLock and not itemData.selected)
  self.m_pnl_levellock:SetActive(itemData.isLock)
end

return PartEqupLevelItem
