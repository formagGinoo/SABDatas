local UIItemBase = require("UI/Common/UIItemBase")
local UIAttractTabItem = class("UIAttractTabItem", UIItemBase)

function UIAttractTabItem:OnInit()
end

function UIAttractTabItem:OnFreshData()
  local itemData = self.m_itemData
  local stVoice = itemData.stVoice
  self.m_txt_des_Colorchange = self.m_txt_des:GetComponent("MultiColorChange")
  self.m_stHero = itemData.stHero
  UILuaHelper.ResetAnimationByName(self.m_img_lock, "dialogue_m_img_lock_out")
  if AttractManager:CheckVoiceUnlockCondition(self.m_stHero, stVoice.m_UnlockType, stVoice.m_UnlockData) then
    self.m_img_lock:SetActive(false)
    self.m_img_bk_lock:SetActive(false)
    self.m_img_play:SetActive(true)
    self.m_img_bk_normal:SetActive(true)
    self.m_img_voice:SetActive(false)
    self.m_txt_des_Text.text = stVoice.m_mTitle
    self.m_txt_des_Colorchange:SetColorByIndex(0)
  else
    self.m_txt_des_Text.text = stVoice.m_mUnlockDesc
    self.m_img_lock:SetActive(true)
    self.m_img_bk_lock:SetActive(true)
    self.m_img_play:SetActive(false)
    self.m_img_bk_normal:SetActive(false)
    self.m_img_voice:SetActive(false)
    self.m_txt_des_Colorchange:SetColorByIndex(2)
  end
end

function UIAttractTabItem:PlayVoiceAnim()
  self.m_img_play:SetActive(false)
  self.m_img_voice:SetActive(true)
  self.m_txt_des_Colorchange:SetColorByIndex(1)
end

function UIAttractTabItem:StopVoiceAnim()
  self.m_img_play:SetActive(true)
  self.m_img_voice:SetActive(false)
  self.m_txt_des_Colorchange:SetColorByIndex(0)
end

function UIAttractTabItem:dispose()
  UIAttractTabItem.super.dispose(self)
end

return UIAttractTabItem
