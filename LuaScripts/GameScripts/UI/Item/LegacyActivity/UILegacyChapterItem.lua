local UIItemBase = require("UI/Common/UIItemBase")
local UILegacyChapterItem = class("UILegacyChapterItem", UIItemBase)
local MaxUnlockNum = 2
local AnimItemStr = "Activity_item_in"

function UILegacyChapterItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
    self.m_itemExClkBackFun = self.m_itemInitData.itemExClkBackFun
  end
end

function UILegacyChapterItem:OnFreshData()
  self.m_chapterItemData = self.m_itemData
  if not self.m_chapterItemData then
    return
  end
  self.m_chapterData = self.m_chapterItemData.chapterData
  self.m_chapterCfg = self.m_chapterData.chapterCfg
  self:FreshItemUI()
  self:FreshChooseStatus(self.m_chapterItemData.isChoose, self.m_chapterItemData.isChooseEx)
  self:CheckFreshRedDot()
  self:ResetLegacyItemToEnd()
end

function UILegacyChapterItem:FreshItemUI()
  if not self.m_chapterItemData then
    return
  end
  self:FreshNormalChapterNode()
  local exChapterData = self.m_chapterItemData.chapterData.exChapterData
  UILuaHelper.SetActive(self.m_pnl_item_ex, exChapterData ~= nil)
  if exChapterData then
    self:FreshExChapterNode()
  end
end

function UILegacyChapterItem:CheckFreshRedDot()
  if not self.m_chapterItemData then
    return
  end
  self:RegisterOrUpdateRedDotItem(self.m_chapter_red_dot, RedDotDefine.ModuleType.LegacyLevelChapterEntry, self.m_chapterItemData.chapterData.chapterCfg.m_ChapterID)
  if self.m_chapterItemData.chapterData.exChapterData then
    local exChapterID = self.m_chapterItemData.chapterData.exChapterData.chapterCfg.m_ChapterID
    self:RegisterOrUpdateRedDotItem(self.m_chapter_ex_red_dot, RedDotDefine.ModuleType.LegacyLevelChapterEntry, exChapterID)
  end
end

function UILegacyChapterItem:FreshChooseStatus(isChoose, isChooseEx)
  isChooseEx = isChooseEx or false
  UILuaHelper.SetActive(self.m_img_select, not isChooseEx and isChoose)
  UILuaHelper.SetActive(self.m_img_normal, not isChooseEx and not isChoose or isChooseEx)
  UILuaHelper.SetActive(self.m_img_ex_select, isChooseEx and isChoose)
end

function UILegacyChapterItem:FreshNormalChapterNode()
  local isUnlock = self.m_chapterItemData.isUnlock
  if isUnlock == nil then
    self.m_chapterItemData.isUnlock = LegacyLevelManager:IsChapterUnlock(self.m_chapterCfg.m_ChapterID)
  end
  UILuaHelper.SetActive(self.m_pnl_unlock, self.m_chapterItemData.isUnlock)
  UILuaHelper.SetActive(self.m_pnl_lock, not self.m_chapterItemData.isUnlock)
  if self.m_chapterItemData.isUnlock then
    self:FreshNormalChapterUnlockStatus()
  end
end

function UILegacyChapterItem:FreshNormalChapterUnlockStatus()
  if not self.m_chapterData then
    return
  end
  local chapterInfoCfg = self.m_chapterData.chapterCfg
  self.m_txt_subtitle_Text.text = chapterInfoCfg.m_mChapterDesc
  UILuaHelper.SetAtlasSprite(self.m_img_icon_normal_Image, chapterInfoCfg.m_RewardPicNoGet)
  UILuaHelper.SetAtlasSprite(self.m_img_icon_complete_Image, chapterInfoCfg.m_RewardPic)
  if self.m_chapterItemData.progressNum == nil then
    self.m_chapterItemData.progressNum = LegacyLevelManager:GetChapterProgressNum(chapterInfoCfg.m_ChapterID) or 0
  end
  local isComplete = self.m_chapterItemData.progressNum >= 1
  UILuaHelper.SetActive(self.m_img_icon_complete, isComplete)
  UILuaHelper.SetColorByMultiIndex(self.m_txt_subtitle, isComplete and 1 or 0)
  self.m_txt_level_name_Text.text = chapterInfoCfg.m_mChapterName
  self.m_img_bar_item1_Image.fillAmount = self.m_chapterItemData.progressNum
  local percentNumStr = math.floor(self.m_chapterItemData.progressNum * 100) .. "%"
  self.m_num_percentage_item1_Text.text = percentNumStr
end

function UILegacyChapterItem:FreshExChapterNode()
  local isExUnlock = self.m_chapterItemData.isExUnlock
  local exChapterData = self.m_chapterData.exChapterData
  if isExUnlock == nil then
    self.m_chapterItemData.isExUnlock = LegacyLevelManager:IsChapterUnlock(exChapterData.chapterCfg.m_ChapterID)
  end
  UILuaHelper.SetActive(self.m_pnl_ex_unlock, self.m_chapterItemData.isExUnlock)
  UILuaHelper.SetActive(self.m_pnl_ex_lock, not self.m_chapterItemData.isExUnlock)
  if self.m_chapterItemData.isExUnlock then
    self:FreshExChapterUnlockStatus()
  end
end

function UILegacyChapterItem:FreshExChapterUnlockStatus()
  if not self.m_chapterData then
    return
  end
  local exChapterData = self.m_chapterData.exChapterData
  if not exChapterData then
    return
  end
  local exChapterInfoCfg = exChapterData.chapterCfg
  self.m_txt_levelex_name_Text.text = exChapterInfoCfg.m_mChapterName
  if self.m_chapterItemData.exProgressNum == nil then
    self.m_chapterItemData.exProgressNum = LegacyLevelManager:GetChapterProgressNum(exChapterInfoCfg.m_ChapterID) or 0
  end
  self.m_img_bar_ex1_Image.fillAmount = self.m_chapterItemData.exProgressNum
  local percentNumStr = math.floor(self.m_chapterItemData.exProgressNum * 100) .. "%"
  self.m_num_percentage_ex1_Text.text = percentNumStr
end

function UILegacyChapterItem:ResetLegacyItemToEnd()
  if not self.m_itemRootObj then
    return
  end
  UILuaHelper.ResetAnimationByName(self.m_itemRootObj, AnimItemStr, -1)
end

function UILegacyChapterItem:ChangeChooseStatus(isChoose, isEx)
  self.m_chapterItemData.isChoose = isChoose
  self.m_chapterItemData.isChooseEx = isEx
  self:FreshChooseStatus(isChoose, isEx)
end

function UILegacyChapterItem:OnBtntouchitemClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

function UILegacyChapterItem:OnBtntouchlockClicked()
  if not self.m_chapterItemData then
    return
  end
  local chapterID = self.m_chapterItemData.chapterData.chapterCfg.m_ChapterID
  StackPopup:Push(UIDefines.ID_FORM_LEGACYLOCKTIPS, {chapterID = chapterID})
end

function UILegacyChapterItem:OnBtntouchexClicked()
  if self.m_itemExClkBackFun then
    self.m_itemExClkBackFun(self.m_itemIndex)
  end
end

function UILegacyChapterItem:OnBtntouchexlockClicked()
  if not self.m_chapterItemData then
    return
  end
  if not self.m_chapterItemData.chapterData.exChapterData then
    return
  end
  local chapterID = self.m_chapterItemData.chapterData.exChapterData.chapterCfg.m_ChapterID
  StackPopup:Push(UIDefines.ID_FORM_LEGACYLOCKTIPS, {chapterID = chapterID})
end

return UILegacyChapterItem
