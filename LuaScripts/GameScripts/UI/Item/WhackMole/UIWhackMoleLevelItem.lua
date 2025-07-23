local UIItemBase = require("UI/Common/UIItemBase")
local UIWhackMoleLevelItem = class("UIWhackMoleLevelItem", UIItemBase)
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function UIWhackMoleLevelItem:OnInit()
  self.isSelect = false
end

function UIWhackMoleLevelItem:OnFreshData()
  self.isNullItem = false
  if self.m_itemData.levelCfg then
    local name = self.m_itemData.levelCfg.m_mName
    self.m_txt_level_Text.text = tostring(name)
    self.m_txt_level_pass_Text.text = tostring(name)
    self.m_txt_level_lock_Text.text = tostring(name)
    self.m_txt_levelsel_Text.text = tostring(name)
  else
    self.isNullItem = true
    UILuaHelper.SetActive(self.m_btn_levelSelect, false)
    UILuaHelper.SetActive(self.m_levelState_Pass, false)
    UILuaHelper.SetActive(self.m_levelState_Normal, false)
    UILuaHelper.SetActive(self.m_levelState_Lock, false)
    return
  end
  UILuaHelper.SetActive(self.m_btn_levelSelect, false)
  UILuaHelper.SetActive(self.m_levelState_Pass, self.m_itemData.levelState == 0)
  UILuaHelper.SetActive(self.m_levelState_Normal, self.m_itemData.levelState == 1)
  local isLock = self.m_itemData.levelState == 2
  UILuaHelper.SetActive(self.m_levelState_Lock, isLock)
  UILuaHelper.SetActive(self.m_icon_nml, not isLock)
  UILuaHelper.SetActive(self.m_icon_lock, isLock)
end

function UIWhackMoleLevelItem:ShowSelectStyle(isActive)
  if not self.isNullItem then
    if isActive then
      CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
    end
    UILuaHelper.SetActive(self.m_btn_levelSelect, isActive)
    self.isSelect = isActive
  end
end

function UIWhackMoleLevelItem:OnItemClicked()
  if self.isNullItem then
    return
  end
  if not self.isSelect then
    EventCenter.Broadcast(EventDefine.eGameEvent_WhackMole_Level_Select, self.m_itemIndex)
  end
end

function UIWhackMoleLevelItem:OnLevelStateNormalClicked()
  self:OnItemClicked()
end

function UIWhackMoleLevelItem:OnLevelStatePassClicked()
  self:OnItemClicked()
end

function UIWhackMoleLevelItem:OnLevelStateLockClicked()
  self:OnItemClicked()
end

return UIWhackMoleLevelItem
