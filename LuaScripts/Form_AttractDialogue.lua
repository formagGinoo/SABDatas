local Form_AttractDialogue = class("Form_AttractDialogue", require("UI/UIFrames/Form_AttractDialogueUI"))

function Form_AttractDialogue:SetInitParam(param)
end

function Form_AttractDialogue:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1121)
  self.m_voiceInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollview_InfinityGrid, "Attract/UIAttractVoiceItem")
  self.m_voiceInfinityGrid:RegisterButtonCallback("c_btn_voice", handler(self, self.OnVoiceClick))
end

function Form_AttractDialogue:OnActive()
  self.super.OnActive(self)
  self.m_vioce_item:SetActive(false)
  self:InitData()
  self:FreshUI()
  AttractManager:SetRaycastOn(false)
  AttractManager:SetOtherModelActive(false)
end

function Form_AttractDialogue:OnInactive()
  self.super.OnInactive(self)
  self:StopCurPlayingVoice()
end

function Form_AttractDialogue:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_AttractDialogue:InitData()
  self.m_curShowHeroData = self.m_csui.m_param.curShowHeroData
  local iHeroId = self.m_curShowHeroData.characterCfg.m_HeroID
  local stAttractVoiceInfo = ConfigManager:GetConfigInsByName("AttractVoiceInfo")
  local vVoiceInfo = {}
  local stVoiceInfo = stAttractVoiceInfo:GetValue_ByHeroID(iHeroId)
  for k, v in pairs(stVoiceInfo) do
    vVoiceInfo[#vVoiceInfo + 1] = v
  end
  if 1 < #vVoiceInfo then
    table.sort(vVoiceInfo, function(a, b)
      if a.m_Sort == b.m_Sort then
        return a.m_VoiceId < b.m_VoiceId
      end
      return a.m_Sort < b.m_Sort
    end)
  end
  self.m_vVoiceInfo = vVoiceInfo
end

function Form_AttractDialogue:FreshUI()
  local iLanguageVoiceID = CS.MultiLanguageManager.g_iLanguageVoiceID
  if iLanguageVoiceID == 22 then
    self.m_txt_cv_Text.text = self.m_curShowHeroData.characterCfg.m_mCVJapanese
  elseif iLanguageVoiceID == 10 then
    self.m_txt_cv_Text.text = self.m_curShowHeroData.characterCfg.m_mCVEnglish
  elseif iLanguageVoiceID == 6 then
    self.m_txt_cv_Text.text = self.m_curShowHeroData.characterCfg.m_mCVChinese
  end
  local showData = {}
  local AttractVoiceTextCfgIns = ConfigManager:GetConfigInsByName("AttractVoiceText")
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

function Form_AttractDialogue:StopCurPlayingVoice()
  self.m_playSubIndex = 1
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
  local voiceItem = self.m_voiceInfinityGrid:GetShowItemByIndex(self.m_curIdx)
  if voiceItem then
    voiceItem:StopVoiceAnim()
  end
  self.m_txt_voice_desc_Text.text = ""
  self.m_vioce_item:SetActive(false)
end

function Form_AttractDialogue:PlayVoice(voice)
  CS.UI.UILuaHelper.StartPlaySFX(voice, nil, function(playingId)
    self.m_playingId = playingId
    self.m_vioce_item:SetActive(true)
    self.m_txt_voice_desc_Text.fontSize = 36
    self.m_txt_voice_desc_Text.text = self.m_vVoiceText[self.m_iVoiceId][self.m_playSubIndex].m_mText
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
      self.m_txt_voice_desc_Text.text = ""
      self.m_vioce_item:SetActive(false)
      local voiceItem = self.m_voiceInfinityGrid:GetShowItemByIndex(self.m_curIdx)
      if voiceItem then
        voiceItem:StopVoiceAnim()
      end
    end
  end)
end

function Form_AttractDialogue:CheckOverFlow()
  local preferredHeight = self.m_txt_voice_desc_Text.preferredHeight
  local containerHeight = self.m_txt_voice_desc:GetComponent(T_RectTransform).rect.height
  if preferredHeight > containerHeight then
    self.m_txt_voice_desc_Text.fontSize = 32
  end
end

function Form_AttractDialogue:OnVoiceClick(idx, gameObject)
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

function Form_AttractDialogue:OnBackClk()
  self:CloseForm()
end

function Form_AttractDialogue:OnBackHome()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_AttractDialogue:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_AttractDialogue", Form_AttractDialogue)
return Form_AttractDialogue
