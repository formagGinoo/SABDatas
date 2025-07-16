local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
local UIItemBase = require("UI/Common/UIItemBase")
local UIDecorateFashionItem = class("UIDecorateFashionItem", UIItemBase)

function UIDecorateFashionItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_btnFashionEx = self.m_btn_fashion_Item:GetComponent("ButtonExtensions")
  if self.m_btnFashionEx then
    self.m_btnFashionEx.Clicked = handler(self, self.OnBtnFashionItemClk)
  end
end

function UIDecorateFashionItem:OnFreshData()
  self.m_fashionItemData = self.m_itemData
  self:FreshItemUI()
end

function UIDecorateFashionItem:FreshItemUI()
  if not self.m_fashionItemData then
    return
  end
  self:FreshChooseStatues(self.m_fashionItemData.isSelect)
  self:FreshItemShow()
end

function UIDecorateFashionItem:FreshChooseStatues(isSelect)
  UILuaHelper.SetActive(self.m_img_fashionsel, isSelect)
end

function UIDecorateFashionItem:FreshItemShow()
  if not self.m_fashionItemData then
    return
  end
  self:FreshHeadIcon(self.m_fashionItemData.fashionInfo.m_PerformanceID[0])
end

function UIDecorateFashionItem:FreshHeadIcon(performanceIDLv)
  if not performanceIDLv then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(performanceIDLv)
  if not presentationData.m_UIkeyword then
    return
  end
  local szIcon = presentationData.m_UIkeyword .. "001"
  UILuaHelper.SetAtlasSprite(self.m_icon_fashionhead_Image, szIcon)
end

function UIDecorateFashionItem:ChangeItemChooseStatus(isSelect)
  self.m_itemData.isSelect = isSelect
  self:FreshChooseStatues(isSelect)
end

function UIDecorateFashionItem:OnBtnFashionItemClk()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIDecorateFashionItem
