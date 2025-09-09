local UIItemBase = require("UI/Common/UIItemBase")
local UITipsBPItem = class("UITipsBPItem", UIItemBase)

function UITipsBPItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
    self.m_itemInfoClickFun = self.m_itemInitData.itemInfoClickFun
    self.m_parentLua = self.m_itemInitData.parentLua
  end
  local itemTrans = self.m_itemRootObj.transform
  self.m_pnl_unlock = itemTrans:Find("m_pnl_unlock").gameObject
  self.m_icon_bp_unlock_Image = itemTrans:Find("m_pnl_unlock/m_icon_bp_unlock"):GetComponent(T_Image)
  self.m_txt_bp_unlock_Text = itemTrans:Find("m_pnl_unlock/m_txt_bp_unlock"):GetComponent(T_TextMeshProUGUI)
  self.m_img_bg_select = itemTrans:Find("m_pnl_unlock/img_bg_select").gameObject
  local btn_select = itemTrans:Find("m_pnl_unlock/m_btn_select"):GetComponent(T_Button)
  if btn_select then
    UILuaHelper.BindButtonClickManual(btn_select, function()
      self:OnBPItemClick()
    end)
  end
  local btn_info = itemTrans:Find("m_pnl_unlock/m_btn_info"):GetComponent(T_Button)
  if btn_info then
    UILuaHelper.BindButtonClickManual(btn_info, function()
      self:OnBPItemInfoClick()
    end)
  end
  self.m_pnl_used = itemTrans:Find("m_pnl_used").gameObject
  self.m_icon_bp_used_Image = itemTrans:Find("m_pnl_used/m_icon_bp_used"):GetComponent(T_Image)
  self.m_icon_bp_useddark_Image = itemTrans:Find("m_pnl_used/m_icon_bp_used/m_icon_bp_useddark"):GetComponent(T_Image)
  self.m_txt_bp_used_Text = itemTrans:Find("m_pnl_used/m_txt_bp_used"):GetComponent(T_TextMeshProUGUI)
  local btn_select_advanced = itemTrans:Find("m_pnl_used/m_btn_select_used"):GetComponent(T_Button)
  if btn_select_advanced then
    UILuaHelper.BindButtonClickManual(btn_select_advanced, function()
      self:OnBPItemClick(true)
    end)
  end
  local btn_info_advanced = itemTrans:Find("m_pnl_used/m_btn_infoused"):GetComponent(T_Button)
  if btn_info_advanced then
    UILuaHelper.BindButtonClickManual(btn_info_advanced, function()
      self:OnBPItemInfoClick()
    end)
  end
end

function UITipsBPItem:OnFreshData()
  local act = self.m_itemData.act
  if not act then
    UILuaHelper.SetActive(self.m_itemRootObj, false)
    return
  end
  local isAdvanced = act:IsHaveBuy()
  if isAdvanced then
    self.m_pnl_used:SetActive(true)
    self.m_pnl_unlock:SetActive(false)
    self.m_txt_bp_used_Text.text = act:GetTitleAndEnterName()
    local sIconPath = act:GetBPIcon()
    UILuaHelper.SetAtlasSprite(self.m_icon_bp_used_Image, sIconPath)
    UILuaHelper.SetAtlasSprite(self.m_icon_bp_useddark_Image, sIconPath)
  else
    self.m_pnl_used:SetActive(false)
    self.m_pnl_unlock:SetActive(true)
    self.m_txt_bp_unlock_Text.text = act:GetTitleAndEnterName()
    UILuaHelper.SetAtlasSprite(self.m_icon_bp_unlock_Image, act:GetBPIcon())
  end
  self:SetChoose(self.m_itemData.bIsChoose)
end

function UITipsBPItem:SetChoose(bIsChoose)
  self.m_img_bg_select:SetActive(bIsChoose)
  self.m_itemData.bIsChoose = bIsChoose
end

function UITipsBPItem:OnBPItemClick(bIsAdvanced)
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex, bIsAdvanced)
  end
end

function UITipsBPItem:OnBPItemInfoClick()
  if self.m_itemInfoClickFun then
    self.m_itemInfoClickFun(self.m_itemData.act)
  end
end

return UITipsBPItem
