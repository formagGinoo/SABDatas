local UIItemBase = require("UI/Common/UIItemBase")
local UIRoleHeadFrameItem = class("UIRoleHeadFrameItem", UIItemBase)
local ChooseFrameAnimStr = "PersonalChange_herochoose"

function UIRoleHeadFrameItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_btnHeadFrameEx = self.m_btn_HeadFrame_Item:GetComponent("ButtonExtensions")
  if self.m_btnHeadFrameEx then
    self.m_btnHeadFrameEx.Clicked = handler(self, self.OnBtnHeadFrameItemClk)
  end
  self.m_isShowNewFlag = nil
end

function UIRoleHeadFrameItem:OnFreshData()
  self.m_playerHeadFrameCfg = self.m_itemData
  self:FreshItemUI()
end

function UIRoleHeadFrameItem:FreshItemUI()
  if not self.m_playerHeadFrameCfg then
    return
  end
  self:FreshChooseStatues(self.m_playerHeadFrameCfg.isSelect)
  self:FreshItemShow()
end

function UIRoleHeadFrameItem:FreshChooseStatues(isSelect)
  UILuaHelper.SetActive(self.m_img_selectheadfarme, isSelect)
end

function UIRoleHeadFrameItem:FreshItemShow()
  local isUnlock = self.m_playerHeadFrameCfg.isHave
  UILuaHelper.SetActive(self.m_img_changeheadfarme, isUnlock)
  UILuaHelper.SetActive(self.m_pnl_headfarme_maskchangelock, not isUnlock)
  UILuaHelper.SetAtlasSprite(self.m_img_changeheadfarme_Image, self.m_playerHeadFrameCfg.cfg.m_ItemIcon)
  UILuaHelper.SetAtlasSprite(self.m_icon_changeheadlock_Image, self.m_playerHeadFrameCfg.cfg.m_ItemIcon)
  self:FreshNewFlagStatus()
end

function UIRoleHeadFrameItem:FreshNewFlagStatus()
  local isUnlock = self.m_playerHeadFrameCfg.isHave
  local headFrameID = self.m_playerHeadFrameCfg.cfg.m_HeadFrameID
  self.m_isShowNewFlag = RoleManager:GetRoleHeadFrameNewFlag(headFrameID)
  UILuaHelper.SetActive(self.m_img_newheadfarme, self.m_isShowNewFlag)
  UILuaHelper.SetActive(self.m_img_hourglassheadfarme, self.m_playerHeadFrameCfg.cfg.m_EffectTime > 0 and isUnlock and not self.m_isShowNewFlag)
end

function UIRoleHeadFrameItem:ChangeItemChooseStatus(isSelect)
  self.m_itemData.isSelect = isSelect
  self:FreshChooseStatues(isSelect)
end

function UIRoleHeadFrameItem:ShowChooseStatusAnim()
  if not self.m_itemData.isSelect then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_img_selectheadfarme, ChooseFrameAnimStr)
end

function UIRoleHeadFrameItem:OnBtnHeadFrameItemClk()
  if self.m_playerHeadFrameCfg and self.m_isShowNewFlag then
    RoleManager:SetRoleHeadFrameNewFlag(self.m_playerHeadFrameCfg.cfg.m_HeadFrameID, -1)
    self:FreshNewFlagStatus()
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIRoleHeadFrameItem
