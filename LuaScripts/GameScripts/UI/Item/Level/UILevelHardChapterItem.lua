local UIItemBase = require("UI/Common/UIItemBase")
local UILevelHardChapterItem = class("UILevelHardChapterItem", UIItemBase)
local animStr = "chapter_hard"

function UILevelHardChapterItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_levelMainHelper = LevelManager:GetLevelMainHelper()
  self.isUnLock = nil
end

function UILevelHardChapterItem:OnFreshData()
  UILuaHelper.ResetAnimationByName(self.m_itemRootObj, animStr, -1)
  self:FreshChapterUI()
  self:RegisterOrUpdateRedDotItem(self.m_icon_redpoint_hard, RedDotDefine.ModuleType.TaskChapterProgress, self.m_itemData.chapterData.chapterCfg.m_ChapterID)
  self:FreshChooseStatus(self.m_itemData.isChoose)
end

function UILevelHardChapterItem:FreshChapterUI()
  local chapterData = self.m_itemData.chapterData
  if not chapterData then
    return
  end
  local chapterCfg = chapterData.chapterCfg
  if not chapterCfg then
    return
  end
  local chapterID = chapterCfg.m_ChapterID
  local isCurProgressChapter = self.m_itemData.isProgressChapter
  local isUnLock = self.m_levelMainHelper:IsChapterUnlock(chapterID)
  self.isUnLock = isUnLock
  local haveProcessNum, levelTotalNum, exhaveProcessNum, exlevelTotalNum = self.m_levelMainHelper:GetChapterProgress(chapterData)
  local progressStr = string.format("%d/%d", haveProcessNum, levelTotalNum)
  UILuaHelper.SetActive(self.m_img_hard_unlock, isUnLock)
  UILuaHelper.SetActive(self.m_img_hard_lock, not isUnLock)
  if isUnLock then
    self.m_txt_hard_num_unlock_Text.text = chapterCfg.m_ChapterTitle
    self.m_txt_hard_chapter_name_unlock_Text.text = chapterCfg.m_mChapterName
    UILuaHelper.SetActive(self.m_tips_cur_hard_unlock, isCurProgressChapter)
    UILuaHelper.SetActive(self.m_icon_hard_ex_unlock, self.m_levelMainHelper:GetChapterFirstExLevel(chapterID) ~= nil)
    self.m_txt_hard_chapter_progress_unlock_Text.text = progressStr
    self.m_txt_hard_num_select_Text.text = chapterCfg.m_ChapterTitle
    self.m_txt_hard_chapter_name_select_Text.text = chapterCfg.m_mChapterName
    UILuaHelper.SetActive(self.m_tips_cur_hard_select, isCurProgressChapter)
    UILuaHelper.SetActive(self.m_icon_hard_ex_select, self.m_levelMainHelper:GetChapterFirstExLevel(chapterID) ~= nil)
    self.m_txt_hard_chapter_progress_select_Text.text = progressStr
  else
    self.m_txt_hard_num_lock_Text.text = chapterCfg.m_ChapterTitle
    self.m_txt_hard_chapter_name_lock_Text.text = chapterCfg.m_mChapterName
  end
end

function UILevelHardChapterItem:FreshChooseStatus(isChoose)
  UILuaHelper.SetActive(self.m_img_hard_select, isChoose)
  UILuaHelper.SetActive(self.m_node_hard_unselect, not isChoose)
end

function UILevelHardChapterItem:ChangeItemChoose(isChoose)
  self.m_itemData.isChoose = isChoose
  self:FreshChooseStatus(isChoose)
end

function UILevelHardChapterItem:OnBtnchapterharditemClicked()
  if self.isUnLock == false then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 30006)
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UILevelHardChapterItem
