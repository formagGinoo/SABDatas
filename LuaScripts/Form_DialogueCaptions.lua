local Form_DialogueCaptions = class("Form_DialogueCaptions", require("UI/UIFrames/Form_DialogueCaptionsUI"))

function Form_DialogueCaptions:SetInitParam(param)
end

function Form_DialogueCaptions:GetRootTransformType()
  return UIRootTransformType.Story
end

function Form_DialogueCaptions:AfterInit()
  self.playingId = -1
  self.super.AfterInit(self)
end

function Form_DialogueCaptions:OnActive()
  self.super.OnActive(self)
  self.m_csui.m_uiGameObject:SetActive(false)
  GuideManager:AddFrame(1, handler(self, self.ActiveRootUI), nil, "Form_DialogueCaptions")
end

function Form_DialogueCaptions:ActiveRootUI()
  self.m_csui.m_uiGameObject:SetActive(true)
end

function Form_DialogueCaptions:OnInactive()
  self.super.OnInactive(self)
  GuideManager:RemoveFrameByKey("Form_DialogueCaptions")
end

function Form_DialogueCaptions:OnUpdate(dt)
end

function Form_DialogueCaptions:SetData(chapterTitle, chapterName, chapterContent, chapterNum, voice)
  if self.playingId > 0 then
    CS.UI.UILuaHelper.StopPlaySFX(self.playingId)
    self.playingId = -1
  end
  if not string.isnullorempty(chapterTitle) then
    self.m_pnl_chapter:SetActive(true)
    self.m_txt_chapter_title_Text.text = CS.MultiLanguageManager.Instance:GetPlotText(chapterTitle)
    self.m_txt_chapter_name_Text.text = CS.MultiLanguageManager.Instance:GetPlotText(chapterName)
    self.m_txt_chapter_num_Text.text = CS.MultiLanguageManager.Instance:GetPlotText(chapterNum)
  else
    self.m_pnl_chapter:SetActive(false)
  end
  if not string.isnullorempty(chapterContent) then
    self.m_txt_captions:SetActive(true)
    local chapterContent = CS.MultiLanguageManager.Instance:GetPlotText(chapterContent)
    self.m_textTypeWriter = self.m_txt_captions.transform:GetComponent("CommonStoryText")
    self.m_textTypeWriter:ShowText(chapterContent, -1)
  else
    self.m_txt_captions:SetActive(false)
  end
  if not string.IsNullOrEmpty(voice) then
    CS.UI.UILuaHelper.StartPlaySFX(voice, nil, handler(self, self.OnPlaySFXStart), handler(self, self.OnPlaySFXFinish))
  end
end

function Form_DialogueCaptions:OnPlaySFXStart(playingId)
  self.playingId = playingId
end

function Form_DialogueCaptions:OnPlaySFXFinish(playingId)
  self.playingId = -1
end

local fullscreen = true
ActiveLuaUI("Form_DialogueCaptions", Form_DialogueCaptions)
return Form_DialogueCaptions
