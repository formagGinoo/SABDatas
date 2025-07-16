local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroFashionVoiceItem = class("UIHeroFashionVoiceItem", UIItemBase)

function UIHeroFashionVoiceItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
end

function UIHeroFashionVoiceItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_voiceItemData = self.m_itemData
  self:FreshDescText()
  self:FreshStatus()
end

function UIHeroFashionVoiceItem:FreshDescText()
  if not self.m_voiceItemData then
    return
  end
  local voiceInfoCfg = self.m_voiceItemData.voiceInfoCfg
  self.m_txt_play_Text.text = voiceInfoCfg.m_mTitle
  self.m_txt_voice_Text.text = voiceInfoCfg.m_mTitle
  self.m_txt_lock_Text.text = voiceInfoCfg.m_mUnlockDesc
end

function UIHeroFashionVoiceItem:FreshStatus()
  local voiceInfoCfg = self.m_voiceItemData.voiceInfoCfg
  local isUnlock = AttractManager:CheckVoiceUnlockCondition(self.m_voiceItemData.heroData, voiceInfoCfg.m_UnlockType, voiceInfoCfg.m_UnlockData)
  UILuaHelper.SetActive(self.m_img_lock, not isUnlock)
  local isPlaying = self.m_voiceItemData.isPlaying
  UILuaHelper.SetActive(self.m_img_play, isUnlock and not isPlaying)
  UILuaHelper.SetActive(self.m_img_voice, isUnlock and isPlaying)
end

function UIHeroFashionVoiceItem:PlayVoiceAnim()
  self.m_voiceItemData.isPlaying = true
  self:FreshStatus()
end

function UIHeroFashionVoiceItem:StopVoiceAnim()
  self.m_voiceItemData.isPlaying = false
  self:FreshStatus()
end

function UIHeroFashionVoiceItem:OnBtnVoiceClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIHeroFashionVoiceItem
