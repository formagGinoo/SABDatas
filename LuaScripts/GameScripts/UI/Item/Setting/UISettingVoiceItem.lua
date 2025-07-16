local UIItemBase = require("UI/Common/UIItemBase")
local UISettingVoiceItem = class("UISettingVoiceItem", UIItemBase)

function UISettingVoiceItem:OnInit()
  self.m_settingLanguageIns = ConfigManager:GetConfigInsByName("SettingLanguage")
end

function UISettingVoiceItem:OnFreshData()
  local itemData = self.m_itemData
  local voiceCfg = itemData.voiceCfg
  local rootBtn = self.m_itemRootObj:GetComponent(T_Button)
  rootBtn.onClick:RemoveAllListeners()
  rootBtn.onClick:AddListener(function()
    if itemData.callFunc then
      itemData.callFunc(self.m_itemIndex, voiceCfg)
    end
  end)
  if CS.MultiLanguageManager.g_iLanguageVoiceID == voiceCfg.m_ID then
    self.m_z_txt_use1:SetActive(true)
  else
    self.m_z_txt_use1:SetActive(false)
  end
  local settingLanguageCfg = self.m_settingLanguageIns:GetValue_ByLanID(voiceCfg.m_LanID)
  local str = ConfigManager:GetCommonTextById(100037)
  str = string.gsub(str, "{0}", settingLanguageCfg.m_mVoiceName)
  local downloadedSize = itemData.downloadedSize / 1024 / 1024
  if 1000 < downloadedSize then
    str = string.gsub(str, "{1}", string.format(" %.02f%s", downloadedSize / 1024, DownloadManager:GetGBStr()))
  else
    str = string.gsub(str, "{1}", string.format(" %.02f%s", downloadedSize, DownloadManager:GetMBStr()))
  end
  self.m_txt_downnum1_Text.text = str
  self.m_img_select1:SetActive(false)
end

function UISettingVoiceItem:dispose()
  UISettingVoiceItem.super.dispose(self)
end

return UISettingVoiceItem
