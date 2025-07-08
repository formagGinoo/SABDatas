local UIItemBase = require("UI/Common/UIItemBase")
local UILegacyLevelItem = class("UILegacyLevelItem", UIItemBase)
local FullAlphaNum = 1
local HalfAlphaNum = 0.2

function UILegacyLevelItem:OnInit()
  self.m_isUnlock = nil
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
end

function UILegacyLevelItem:OnFreshData()
  self.m_stageLevelInfo = self.m_itemData
  self:FreshItemUI()
end

function UILegacyLevelItem:FreshItemUI()
  if not self.m_stageLevelInfo then
    return
  end
  self.m_isUnlock = LegacyLevelManager:IsLevelUnlock(self.m_stageLevelInfo.m_LevelID)
  self.m_txt_name_Text.text = self.m_stageLevelInfo.m_mLevelName
  UILuaHelper.SetAtlasSprite(self.m_icon_Image, self.m_stageLevelInfo.m_LevelRewardPic)
  UILuaHelper.SetActive(self.m_btn_Lock, not self.m_isUnlock)
  local isHavePass = LegacyLevelManager:IsLevelHavePass(self.m_stageLevelInfo.m_LevelID)
  UILuaHelper.SetActive(self.m_icon_completed, isHavePass == true)
  if not self.m_isUnlock then
    UILuaHelper.SetCanvasGroupAlpha(self.m_pnl_item, HalfAlphaNum)
  else
    UILuaHelper.SetCanvasGroupAlpha(self.m_pnl_item, FullAlphaNum)
  end
end

function UILegacyLevelItem:OnBtnRewardItemClicked()
  if not self.m_stageLevelInfo then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_LEGACYACTIVITYCUBEPOP, {
    levelCfg = self.m_stageLevelInfo
  })
end

function UILegacyLevelItem:OnBtnLockClicked()
  if not self.m_stageLevelInfo then
    return
  end
  local commonStr = ConfigManager:GetCommonTextById(100503)
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, commonStr)
end

function UILegacyLevelItem:OnBtnBattleClicked()
  if not self.m_stageLevelInfo then
    return
  end
  BattleFlowManager:StartEnterBattle(LegacyLevelManager.LevelType.LegacyLevel, self.m_stageLevelInfo.m_LevelID)
end

return UILegacyLevelItem
