local UIItemBase = require("UI/Common/UIItemBase")
local UIRoleBgItem = class("UIRoleBgItem", UIItemBase)
local ChooseFrameAnimStr = "PersonalChange_herochoose"

function UIRoleBgItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_btnBgEx = self.m_btn_bg_Item:GetComponent("ButtonExtensions")
  if self.m_btnBgEx then
    self.m_btnBgEx.Clicked = handler(self, self.OnBtnBgItemClk)
  end
  self.m_isShowNewFlag = nil
end

function UIRoleBgItem:OnFreshData()
  self.m_playerBgCfg = self.m_itemData
  self:FreshItemUI()
end

function UIRoleBgItem:FreshItemUI()
  if not self.m_playerBgCfg then
    return
  end
  self:FreshChooseStatues(self.m_playerBgCfg.isSelect)
  self:FreshItemShow()
end

function UIRoleBgItem:FreshChooseStatues(isSelect)
  UILuaHelper.SetActive(self.m_img_bg_select, isSelect)
end

function UIRoleBgItem:FreshItemShow()
  local isUnlock = self.m_playerBgCfg.isHave
  UILuaHelper.SetActive(self.m_pnl_bg_maskchangelock, not isUnlock)
  UILuaHelper.SetAtlasSprite(self.m_img_bg_icon_Image, self.m_playerBgCfg.cfg.m_SmallPic)
  UILuaHelper.SetAtlasSprite(self.m_img_bg_icon_lock_Image, self.m_playerBgCfg.cfg.m_SmallPic)
  self:FreshNewFlagStatus()
end

function UIRoleBgItem:FreshNewFlagStatus()
  local isUnlock = self.m_playerBgCfg.isHave
  local bgID = self.m_playerBgCfg.cfg.m_CardBGID
  self.m_isShowNewFlag = RoleManager:GetRoleHeadBackgroundNewFlag(bgID)
  UILuaHelper.SetActive(self.m_img_bg_new, self.m_isShowNewFlag)
  UILuaHelper.SetActive(self.m_img_hourglass_bg, self.m_playerBgCfg.cfg.m_EffectTime > 0 and isUnlock and not self.m_isShowNewFlag)
end

function UIRoleBgItem:ChangeItemChooseStatus(isSelect)
  self.m_itemData.isSelect = isSelect
  self:FreshChooseStatues(isSelect)
end

function UIRoleBgItem:ShowChooseStatusAnim()
  if not self.m_itemData.isSelect then
    return
  end
end

function UIRoleBgItem:OnBtnBgItemClk()
  if self.m_playerBgCfg and self.m_isShowNewFlag then
    RoleManager:SetRoleHeadBackgroundNewFlag(self.m_playerBgCfg.cfg.m_CardBGID, -1)
    self:FreshNewFlagStatus()
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIRoleBgItem
