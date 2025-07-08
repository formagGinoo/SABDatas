local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
local UIItemBase = require("UI/Common/UIItemBase")
local UIDecorateRoleItem = class("UIDecorateRoleItem", UIItemBase)

function UIDecorateRoleItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_btnRoleEx = self.m_btn_Role_Item:GetComponent("ButtonExtensions")
  if self.m_btnRoleEx then
    self.m_btnRoleEx.Clicked = handler(self, self.OnBtnRoleItemClk)
  end
end

function UIDecorateRoleItem:OnFreshData()
  self.m_roleItemData = self.m_itemData
  self:FreshItemUI()
end

function UIDecorateRoleItem:FreshItemUI()
  if not self.m_roleItemData then
    return
  end
  self:FreshChooseStatues(self.m_roleItemData.isSelect)
  self:FreshItemShow()
end

function UIDecorateRoleItem:FreshChooseStatues(isSelect)
  UILuaHelper.SetActive(self.m_img_rolesel, isSelect)
end

function UIDecorateRoleItem:FreshItemShow()
  if not self.m_roleItemData then
    return
  end
  self:FreshHeadIcon(self.m_roleItemData.characterCfg.m_PerformanceID[0])
end

function UIDecorateRoleItem:FreshHeadIcon(performanceIDLv)
  if not performanceIDLv then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(performanceIDLv)
  if not presentationData.m_UIkeyword then
    return
  end
  local szIcon = presentationData.m_UIkeyword .. "001"
  UILuaHelper.SetAtlasSprite(self.m_icon_rolehead_Image, szIcon)
end

function UIDecorateRoleItem:ChangeItemChooseStatus(isSelect)
  self.m_itemData.isSelect = isSelect
  self:FreshChooseStatues(isSelect)
end

function UIDecorateRoleItem:OnBtnRoleItemClk()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIDecorateRoleItem
