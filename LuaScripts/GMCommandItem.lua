local UIItemBase = require("UI/Common/UIItemBase")
local GMCommandItem = class("GMCommandItem", UIItemBase)

function GMCommandItem:OnInit()
end

function GMCommandItem:OnFreshData()
  local config = self.m_itemData.Config
  local tmpPro = self.m_itemRootObj:GetComponent("TMPPro")
  tmpPro.text = config.m_Key .. " " .. config.m_ShowName .. " 参数：" .. config.m_Param
  local btn = self.m_itemRootObj:GetComponent(T_Button)
  btn.onClick:RemoveAllListeners()
  btn.onClick:AddListener(handler(self, self.OnCommanditemClicked))
end

function GMCommandItem:OnCommanditemClicked()
  self.m_itemData.OnSelected(self.m_itemData.Config)
end

return GMCommandItem
