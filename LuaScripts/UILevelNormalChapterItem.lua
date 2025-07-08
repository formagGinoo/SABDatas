local UIItemBase = require("UI/Common/UIItemBase")
local UILevelNormalChapterItem = class("UILevelNormalChapterItem", UIItemBase)
local animStr = "chapter_normal"

function UILevelNormalChapterItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_levelMainHelper = LevelManager:GetLevelMainHelper()
  self.isUnLock = nil
end

function UILevelNormalChapterItem:OnFreshData()
  UILuaHelper.ResetAnimationByName(self.m_itemRootObj, animStr, -1)
  self:FreshChapterUI()
  self:RegisterOrUpdateRedDotItem(self.m_icon_redpoint_normal, RedDotDefine.ModuleType.TaskChapterProgress, self.m_itemData.chapterData.chapterCfg.m_ChapterID)
  self:FreshChooseStatus(self.m_itemData.isChoose)
end

function UILevelNormalChapterItem:FreshChapterUI()
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
  local exprogressStr = string.format("%d/%d", exhaveProcessNum, exlevelTotalNum)
  UILuaHelper.SetActive(self.m_img_normal_unlock, isUnLock)
  UILuaHelper.SetActive(self.m_img_normal_lock, not isUnLock)
  if isUnLock then
    self.m_txt_normal_num_unlock_Text.text = chapterCfg.m_ChapterTitle
    self.m_txt_normal_chapter_name_unlock_Text.text = chapterCfg.m_mChapterName
    UILuaHelper.SetActive(self.m_tips_cur_normal_unlock, isCurProgressChapter)
    UILuaHelper.SetActive(self.m_icon_normal_ex_unlock, #chapterData.exLevelList > 0)
    self.m_txt_normal_chapter_progress_unlock_Text.text = progressStr
    self.m_txt_normal_num_select_Text.text = chapterCfg.m_ChapterTitle
    self.m_txt_normal_chapter_name_select_Text.text = chapterCfg.m_mChapterName
    UILuaHelper.SetActive(self.m_tips_cur_normal_select, isCurProgressChapter)
    UILuaHelper.SetActive(self.m_icon_normal_ex_select, #chapterData.exLevelList > 0)
    self.m_txt_normal_chapter_progress_select_Text.text = progressStr
    self.m_txt_normal_chapter_progress_unlockex_Text.text = exprogressStr
    self.m_txt_normal_chapter_progress_selectex_Text.text = exprogressStr
  else
    self.m_txt_normal_num_lock_Text.text = chapterCfg.m_ChapterTitle
    self.m_txt_normal_chapter_name_lock_Text.text = chapterCfg.m_mChapterName
  end
end

function UILevelNormalChapterItem:FreshChooseStatus(isChoose)
  UILuaHelper.SetActive(self.m_img_normal_select, isChoose)
  UILuaHelper.SetActive(self.m_node_normal_unselect, not isChoose)
end

function UILevelNormalChapterItem:ChangeItemChoose(isChoose)
  self.m_itemData.isChoose = isChoose
  self:FreshChooseStatus(isChoose)
end

function UILevelNormalChapterItem:OnBtnchapternormalitemClicked()
  if self.isUnLock == false then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 30006)
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UILevelNormalChapterItem
