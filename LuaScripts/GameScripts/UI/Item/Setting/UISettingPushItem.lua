local UIItemBase = require("UI/Common/UIItemBase")
local UISettingPushItem = class("UISettingPushItem", UIItemBase)

function UISettingPushItem:OnInit()
end

function UISettingPushItem:OnFreshData()
  local itemData = self.m_itemData
  local pushCfg = itemData.pushCfg
  self.m_pushCfg = pushCfg
  self.m_txt_title_tips1_Text.text = pushCfg.m_mSettingTitle
  self.m_txt_desc_tips1_Text.text = pushCfg.m_mSettingTip
  self.m_btn_yes_tips1_ActiveToggle.isOn = PushNotificationManager:IsPushOn(pushCfg.m_PushID, pushCfg)
  self.m_btn_yes_tips1_ActiveToggle.onValueChanged:RemoveAllListeners()
  self.m_btn_yes_tips1_ActiveToggle.onValueChanged:AddListener(function()
    self:OnToggleValueChanged()
  end)
  self:RefreshToggle()
end

function UISettingPushItem:OnToggleValueChanged()
  if self.m_itemData.callFunc then
    self.m_itemData.callFunc(self.m_pushCfg, self.m_btn_yes_tips1_ActiveToggle.isOn, self.m_btn_yes_tips1_ActiveToggle)
  end
end

function UISettingPushItem:RefreshToggle()
  if self.m_pushCfg.m_PushID == 1 then
    if not PushNotificationManager:CheckPermission() then
      self.m_btn_yes_tips1_ActiveToggle.isOn = false
    else
      self.m_btn_yes_tips1_ActiveToggle.isOn = true
    end
  end
end

function UISettingPushItem:dispose()
  UISettingPushItem.super.dispose(self)
end

return UISettingPushItem
