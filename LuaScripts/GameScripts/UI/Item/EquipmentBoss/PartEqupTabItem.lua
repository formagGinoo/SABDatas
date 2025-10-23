local UIItemBase = require("UI/Common/UIItemBase")
local PartEqupTabItem = class("PartEqupTabItem", UIItemBase)

function PartEqupTabItem:OnInit()
  self.m_txt_tab = self.m_itemRootObj.transform:Find("m_btn_tab/m_txt_tab"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_tab_sel = self.m_itemRootObj.transform:Find("m_btn_tab/m_img_tab_sel1/m_txt_tab_sel"):GetComponent(T_TextMeshProUGUI)
  self.m_img_tab_sel1 = self.m_itemRootObj.transform:Find("m_btn_tab/m_img_tab_sel1").gameObject
  self.m_txt_tab_obj = self.m_itemRootObj.transform:Find("m_btn_tab/m_txt_tab").gameObject
  if not self.btnObj then
    self.btnObj = self.m_itemRootObj.transform:Find("m_btn_tab"):GetComponent(T_Button)
    UILuaHelper.BindButtonClickManual(self, self.btnObj, function()
      if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
        self.m_itemInitData.itemClkBackFun(self.m_itemIndex, self.m_itemInitData.isLock)
      end
    end)
  end
end

function PartEqupTabItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function PartEqupTabItem:OnItemClick(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
end

function PartEqupTabItem:SetItemInfo(itemData)
  self.m_txt_tab.text = itemData and itemData.cfg.m_mName or ""
  self.m_txt_tab_sel.text = itemData and itemData.cfg.m_mName or ""
  self.m_img_tab_sel1:SetActive(itemData.selected)
  self.m_txt_tab_obj:SetActive(not itemData.selected)
end

return PartEqupTabItem
