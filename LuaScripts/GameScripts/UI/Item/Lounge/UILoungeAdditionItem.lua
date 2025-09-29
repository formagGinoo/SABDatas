local UIItemBase = require("UI/Common/UIItemBase")
local UILoungeAdditionItem = class("UILoungeAdditionItem", UIItemBase)

function UILoungeAdditionItem:OnInit()
end

function UILoungeAdditionItem:OnFreshData()
  local attrInfo = self.m_itemData
  ResourceUtil:CreatePropertyImg(self.m_img_buff_icon_Image, attrInfo.id)
  self.m_txt_buff_desc_Text.text = tostring(attrInfo.cfg.m_mCNName)
  self.m_txt_buff_desc2_Text.text = tostring(attrInfo.num)
end

function UILoungeAdditionItem:dispose()
  UILoungeAdditionItem.super.dispose(self)
end

return UILoungeAdditionItem
