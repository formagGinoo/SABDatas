local UIItemBase = require("UI/Common/UIItemBase")
local UILoungeItem = class("UILoungeItem", UIItemBase)

function UILoungeItem:OnInit()
end

function UILoungeItem:OnFreshData()
  local attrInfo = self.m_itemData.newAttr
  local oldAttrInfo = self.m_itemData.oldAttr
  ResourceUtil:CreatePropertyImg(self.m_img_icon_Image, attrInfo.id)
  self.m_txt_ability_Text.text = tostring(attrInfo.cfg.m_mCNName)
  self.m_after_num_Text.text = tostring(attrInfo.num)
  if oldAttrInfo then
    self.m_before_num_Text.text = tostring(oldAttrInfo.num)
  else
    self.m_before_num_Text.text = 0
  end
end

function UILoungeItem:dispose()
  UILoungeItem.super.dispose(self)
end

return UILoungeItem
