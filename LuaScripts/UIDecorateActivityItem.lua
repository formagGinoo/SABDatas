local UIItemBase = require("UI/Common/UIItemBase")
local UIDecorateActivityItem = class("UIDecorateActivityItem", UIItemBase)

function UIDecorateActivityItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_btnBgEx = self.m_btn_Bg_Item:GetComponent("ButtonExtensions")
  if self.m_btnBgEx then
    self.m_btnBgEx.Clicked = handler(self, self.OnBtnBgItemClk)
  end
  self.m_isShowNewFlag = nil
end

function UIDecorateActivityItem:OnFreshData()
  self.m_mainBackGroundData = self.m_itemData
  self:FreshItemUI()
end

function UIDecorateActivityItem:FreshItemUI()
  if not self.m_mainBackGroundData then
    return
  end
  self:FreshChooseStatues(self.m_mainBackGroundData.isSelect)
  self:FreshItemShow()
end

function UIDecorateActivityItem:FreshChooseStatues(isSelect)
  UILuaHelper.SetActive(self.m_img_bg_sel, isSelect)
end

function UIDecorateActivityItem:FreshItemShow()
  UILuaHelper.SetAtlasSprite(self.m_banner_cdn_Image, self.m_mainBackGroundData.mainBackgroundCfg.m_BannerPic)
  UILuaHelper.SetActive(self.m_pnl_lock, not self.m_mainBackGroundData.isHave)
  self.m_txt_getrule_Text.text = self.m_mainBackGroundData.mainBackgroundCfg.m_mGetwayDes
  self:FreshNewFlagStatus()
end

function UIDecorateActivityItem:FreshNewFlagStatus()
  self.m_isShowNewFlag = RoleManager:GetRoleMainBackgroundNewFlag(self.m_mainBackGroundData.bgID)
  UILuaHelper.SetActive(self.m_img_new, self.m_isShowNewFlag)
end

function UIDecorateActivityItem:ChangeItemChooseStatus(isSelect)
  self.m_itemData.isSelect = isSelect
  self:FreshChooseStatues(isSelect)
end

function UIDecorateActivityItem:OnBtnBgItemClk()
  if not self.m_mainBackGroundData then
    return
  end
  if not self.m_mainBackGroundData.isHave then
    StackPopup:Push(UIDefines.ID_FORM_HALLBGPOPUP, {
      bgId = self.m_mainBackGroundData.bgID
    })
    return
  end
  if self.m_mainBackGroundData and self.m_isShowNewFlag then
    RoleManager:SetRoleMainBackgroundNewFlag(self.m_mainBackGroundData.bgID, -1)
    self:FreshNewFlagStatus()
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIDecorateActivityItem
