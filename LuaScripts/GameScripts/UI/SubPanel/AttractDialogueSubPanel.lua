local UISubPanelBase = require("UI/Common/UISubPanelBase")
local AttractDialogueSubPanel = class("AttractDialogueSubPanel", UISubPanelBase)
local AttractVoiceTextCfgIns = ConfigManager:GetConfigInsByName("AttractVoiceText")

function AttractDialogueSubPanel:OnInit()
  self.m_voiceInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollview_InfinityGrid, "Attract/UIAttractVoiceItem")
  self.m_voiceInfinityGrid:RegisterButtonCallback("c_btn_voice", handler(self, self.OnVoiceClick))
end

function AttractDialogueSubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.curShowHeroData
  self.m_stContentData = self.m_panelData.stContentData
  self.m_vVoiceInfo = self.m_stContentData.vVoiceInfo
  local performanceID = self.m_curShowHeroData.characterCfg.m_PerformanceID[0]
  local presentationData = CS.CData_Presentation.GetInstance():GetValue_ByPerformanceID(performanceID)
  local szIcon = presentationData.m_UIkeyword .. "001"
  UILuaHelper.SetAtlasSprite(self.m_img_head1_Image, szIcon)
  local iLanguageVoiceID = CS.MultiLanguageManager.g_iLanguageVoiceID
  if iLanguageVoiceID == 22 then
    self.m_txt_cv_Text.text = self.m_curShowHeroData.characterCfg.m_mCVJapanese
  elseif iLanguageVoiceID == 10 then
    self.m_txt_cv_Text.text = self.m_curShowHeroData.characterCfg.m_mCVEnglish
  elseif iLanguageVoiceID == 6 then
    self.m_txt_cv_Text.text = self.m_curShowHeroData.characterCfg.m_mCVChinese
  end
  self.m_txt_dialogue_Text.text = ""
  local showData = {}
  self.m_vVoiceText = {}
  for k, v in ipairs(self.m_vVoiceInfo) do
    local vVoiceTextList = AttractVoiceTextCfgIns:GetValue_ByVoiceId(v.m_VoiceId)
    local vVoiceTextListLua = {}
    for k2, v2 in pairs(vVoiceTextList) do
      vVoiceTextListLua[k2] = v2
    end
    local vTextList = {}
    local firstId = 1
    local firstText = vVoiceTextListLua[firstId]
    while firstText do
      vTextList[#vTextList + 1] = firstText
      firstText = vVoiceTextListLua[firstText.m_NextId]
    end
    self.m_vVoiceText[v.m_VoiceId] = vTextList
    showData[#showData + 1] = {
      stVoice = v,
      stHero = self.m_curShowHeroData
    }
  end
  self.m_voiceInfinityGrid:ShowItemList(showData)
end

function AttractDialogueSubPanel:AddEventListeners()
end

function AttractDialogueSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function AttractDialogueSubPanel:OnVoiceClick(idx, gameObject)
  local voiceCfg = self.m_vVoiceInfo[idx + 1]
  if not AttractManager:CheckVoiceUnlockCondition(self.m_curShowHeroData, voiceCfg.m_UnlockType, voiceCfg.m_UnlockData) then
    return
  end
  self:StopCurPlayingVoice()
  self.m_curIdx = idx + 1
  self.m_iVoiceId = voiceCfg.m_VoiceId
  local eventName = self.m_vVoiceText[self.m_iVoiceId][self.m_playSubIndex].m_voice
  self:PlayVoice(eventName)
end

function AttractDialogueSubPanel:PlayVoice(voice)
  CS.UI.UILuaHelper.StartPlaySFX(voice, nil, function(playingId)
    self.m_playingId = playingId
    self.m_txt_dialogue_Text.fontSize = 36
    self.m_txt_dialogue_Text.text = self.m_vVoiceText[self.m_iVoiceId][self.m_playSubIndex].m_mText
    self:CheckOverFlow()
    local voiceItem = self.m_voiceInfinityGrid:GetShowItemByIndex(self.m_curIdx)
    if voiceItem then
      voiceItem:PlayVoiceAnim()
    end
  end, function()
    self.m_playSubIndex = self.m_playSubIndex + 1
    local nextVoice = self.m_vVoiceText[self.m_iVoiceId][self.m_playSubIndex]
    if nextVoice ~= nil then
      self:PlayVoice(nextVoice.m_voice)
    else
      self.m_playingId = nil
      self.m_txt_dialogue_Text.text = ""
      local voiceItem = self.m_voiceInfinityGrid:GetShowItemByIndex(self.m_curIdx)
      if voiceItem then
        voiceItem:StopVoiceAnim()
      end
    end
  end)
end

function AttractDialogueSubPanel:CheckOverFlow()
  local preferredHeight = self.m_txt_dialogue_Text.preferredHeight
  local containerHeight = self.m_txt_dialogue:GetComponent(T_RectTransform).rect.height
  if preferredHeight > containerHeight then
    self.m_txt_dialogue_Text.fontSize = 32
  end
end

function AttractDialogueSubPanel:StopCurPlayingVoice()
  self.m_playSubIndex = 1
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
  local voiceItem = self.m_voiceInfinityGrid:GetShowItemByIndex(self.m_curIdx)
  if voiceItem then
    voiceItem:StopVoiceAnim()
  end
end

function AttractDialogueSubPanel:OnInactivePanel()
  self:StopCurPlayingVoice()
end

function AttractDialogueSubPanel:OnActivePanel()
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "ui_attract_panel_prologue_in")
end

return AttractDialogueSubPanel
