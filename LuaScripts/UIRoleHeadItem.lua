local UIItemBase = require("UI/Common/UIItemBase")
local UIRoleHeadItem = class("UIRoleHeadItem", UIItemBase)
local ChooseFrameAnimStr = "PersonalChange_herochoose"

function UIRoleHeadItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_btnHeadEx = self.m_btn_Head_Item:GetComponent("ButtonExtensions")
  if self.m_btnHeadEx then
    self.m_btnHeadEx.Clicked = handler(self, self.OnBtnHeadItemClk)
  end
  self.m_isShowNewFlag = nil
end

function UIRoleHeadItem:OnFreshData()
  self.m_playerHeadCfg = self.m_itemData
  self:FreshItemUI()
end

function UIRoleHeadItem:FreshItemUI()
  if not self.m_playerHeadCfg then
    return
  end
  self:FreshChooseStatues(self.m_playerHeadCfg.isSelect)
  self:FreshItemShow()
end

function UIRoleHeadItem:FreshChooseStatues(isSelect)
  UILuaHelper.SetActive(self.m_img_selectherohead, isSelect)
end

function UIRoleHeadItem:FreshItemShow()
  local isUnlock = self.m_playerHeadCfg.isHave
  UILuaHelper.SetActive(self.m_pnl_head_maskchangenor, isUnlock)
  UILuaHelper.SetActive(self.m_pnl_head_maskchangelock, not isUnlock)
  UILuaHelper.SetAtlasSprite(self.m_img_changehead_Image, self.m_playerHeadCfg.cfg.m_ItemIcon)
  UILuaHelper.SetAtlasSprite(self.m_icon_changeheadlock_Image, self.m_playerHeadCfg.cfg.m_ItemIcon)
  self:FreshNewFlagStatus()
end

function UIRoleHeadItem:FreshNewFlagStatus()
  local headID = self.m_playerHeadCfg.cfg.m_HeadID
  self.m_isShowNewFlag = RoleManager:GetRoleHeadNewFlag(headID)
  UILuaHelper.SetActive(self.m_img_newherohead, self.m_isShowNewFlag)
end

function UIRoleHeadItem:ChangeItemChooseStatus(isSelect)
  self.m_itemData.isSelect = isSelect
  self:FreshChooseStatues(isSelect)
end

function UIRoleHeadItem:ShowChooseStatusAnim()
  if not self.m_itemData.isSelect then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_img_selectherohead, ChooseFrameAnimStr)
end

function UIRoleHeadItem:OnBtnHeadItemClk()
  if self.m_playerHeadCfg and self.m_isShowNewFlag then
    RoleManager:SetRoleHeadNewFlag(self.m_playerHeadCfg.cfg.m_HeadID, -1)
    self:FreshNewFlagStatus()
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIRoleHeadItem
