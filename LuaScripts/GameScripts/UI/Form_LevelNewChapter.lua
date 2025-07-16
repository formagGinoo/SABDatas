local Form_LevelNewChapter = class("Form_LevelNewChapter", require("UI/UIFrames/Form_LevelNewChapterUI"))

function Form_LevelNewChapter:SetInitParam(param)
end

function Form_LevelNewChapter:AfterInit()
  self.super.AfterInit(self)
  self.m_newChapterID = nil
  self.m_lastChapterID = nil
  self.m_isNewChapterBackLobby = nil
  self.m_closeBackFun = nil
  self.m_levelMainHelper = LevelManager:GetLevelMainHelper()
end

function Form_LevelNewChapter:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_LevelNewChapter:OnInactive()
  self.super.OnInactive(self)
end

function Form_LevelNewChapter:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LevelNewChapter:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_lastChapterID = tParam.lastChapterID
    self.m_newChapterID = tParam.newChapterID
    self.m_closeBackFun = tParam.closeBackFun
    self.m_csui.m_param = nil
  end
end

function Form_LevelNewChapter:FreshUI()
  if not self.m_newChapterID then
    return
  end
  local newChapterData = self.m_levelMainHelper:GetChapterDataByID(self.m_newChapterID)
  if not newChapterData then
    return
  end
  self.m_isNewChapterBackLobby = false
  if self.m_lastChapterID then
    local lastChapterData = self.m_levelMainHelper:GetChapterDataByID(self.m_lastChapterID)
    if lastChapterData then
      self.m_isNewChapterBackLobby = lastChapterData.chapterCfg.m_ReturnType == 1
    end
  end
  local chapterType = newChapterData.chapterCfg.m_ChapterType
  local isHard = chapterType == LevelManager.ChapterType.Hard
  UILuaHelper.SetActive(self.m_img_hard_blood, isHard)
  UILuaHelper.SetActive(self.m_img_hard, isHard)
  UILuaHelper.SetActive(self.m_img_hard_blood2, isHard)
  self.m_txt_chapter_num_Text.text = newChapterData.chapterCfg.m_ChapterTitle
  self.m_txt_chapter_name_Text.text = newChapterData.chapterCfg.m_mChapterName
end

function Form_LevelNewChapter:OnBtnNewChapterCloseClicked()
  if self.m_isNewChapterBackLobby then
    self:CloseForm()
    LevelManager:BackMainCityScene(function()
      StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    end, false)
  else
    self:CloseForm()
    if self.m_closeBackFun then
      self.m_closeBackFun()
    end
  end
end

local fullscreen = true
ActiveLuaUI("Form_LevelNewChapter", Form_LevelNewChapter)
return Form_LevelNewChapter
