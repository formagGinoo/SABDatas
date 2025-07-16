local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroFashionVoiceSubPanel = class("HeroFashionVoiceSubPanel", UISubPanelBase)
local FashionVoiceInfoIns = ConfigManager:GetConfigInsByName("FashionVoiceInfo")
local FashionVoiceTextIns = ConfigManager:GetConfigInsByName("FashionVoiceText")
local FashionVoiceCV = {
  [6] = "Chinese",
  [10] = "English",
  [22] = "Japanese"
}
local InAnimStr = "skinvoice_in"

function HeroFashionVoiceSubPanel:OnInit()
  self.m_HeroFashion = HeroManager:GetHeroFashion()
  self.m_heroData = nil
  self.m_heroFashionInfoList = nil
  self.m_curChooseIndex = nil
  self.m_curShowFashion = nil
  self.m_heroCfg = nil
  self.m_voiceTextListDic = nil
  self.m_showVoiceInfoList = nil
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnVoiceClick(itemIndex)
    end
  }
  self.m_luaVoiceInfinityGrid = self:CreateInfinityGrid(self.m_pnl_voiceitem_InfinityGrid, "HeroFashion/UIHeroFashionVoiceItem", initGridData)
  self:AddEventListeners()
end

function HeroFashionVoiceSubPanel:AddEventListeners()
end

function HeroFashionVoiceSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function HeroFashionVoiceSubPanel:OnFreshData()
  self.m_heroData = self.m_panelData.heroData
  self.m_heroCfg = self.m_panelData.heroCfg
  self.m_heroFashionInfoList = self.m_panelData.allFashionList
  local chooseIndex = self.m_panelData.chooseIndex
  self.m_curChooseIndex = chooseIndex
  self.m_curShowFashion = self.m_heroFashionInfoList[chooseIndex]
  self:FreshVoiceListData()
  self:FreshUI()
end

function HeroFashionVoiceSubPanel:ChangeChooseIndex(chooseIndex)
  if not self.m_heroFashionInfoList then
    return
  end
  self.m_curChooseIndex = chooseIndex
  self.m_curShowFashion = self.m_heroFashionInfoList[chooseIndex]
  self:FreshVoiceListData()
  self:FreshUI()
end

function HeroFashionVoiceSubPanel:FreshUI()
  self:FreshCVNameShow()
  self.m_luaVoiceInfinityGrid:ShowItemList(self.m_showVoiceInfoList, true)
end

function HeroFashionVoiceSubPanel:FreshCVNameShow()
  if not self.m_curShowFashion then
    return
  end
  local iLanguageVoiceID = CS.MultiLanguageManager.g_iLanguageVoiceID
  local voiceCVStr = FashionVoiceCV[iLanguageVoiceID]
  if voiceCVStr then
    self.m_txt_cvname_Text.text = self.m_curShowFashion["m_mCV" .. voiceCVStr]
  end
end

function HeroFashionVoiceSubPanel:OnActivePanel()
  UILuaHelper.PlayAnimationByName(self.m_rootObj, InAnimStr)
end

function HeroFashionVoiceSubPanel:OnHidePanel()
end

function HeroFashionVoiceSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  HeroFashionVoiceSubPanel.super.OnDestroy(self)
end

function HeroFashionVoiceSubPanel:FreshVoiceListData()
  if not self.m_curShowFashion then
    return
  end
  self.m_voiceTextListDic = {}
  self.m_showVoiceInfoList = {}
  local fashionVoiceInfoList = FashionVoiceInfoIns:GetValue_ByFashionID(self.m_curShowFashion.m_FashionID)
  for i, v in pairs(fashionVoiceInfoList) do
    local tempTab = {
      voiceInfoCfg = v,
      heroData = self.m_heroData
    }
    self.m_showVoiceInfoList[#self.m_showVoiceInfoList + 1] = tempTab
    local vVoiceTextList = FashionVoiceTextIns:GetValue_ByVoiceId(v.m_VoiceId)
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
    self.m_voiceTextListDic[v.m_VoiceId] = vTextList
  end
end

function HeroFashionVoiceSubPanel:StopCurPlayingVoice()
  self.m_playSubIndex = 1
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
  local voiceItem = self.m_luaVoiceInfinityGrid:GetShowItemByIndex(self.m_curIdx)
  if voiceItem then
    voiceItem:StopVoiceAnim()
  end
  self.m_txt_voicedesc_Text.text = ""
  UILuaHelper.SetActive(self.m_img_bg_voice02, false)
end

function HeroFashionVoiceSubPanel:PlayVoice(voice)
  CS.UI.UILuaHelper.StartPlaySFX(voice, nil, function(playingId)
    self.m_playingId = playingId
    UILuaHelper.SetActive(self.m_img_bg_voice02, true)
    self.m_txt_voicedesc_Text.text = self.m_voiceTextListDic[self.m_iVoiceId][self.m_playSubIndex].m_mText
    local voiceItem = self.m_luaVoiceInfinityGrid:GetShowItemByIndex(self.m_curIdx)
    if voiceItem then
      voiceItem:PlayVoiceAnim()
    end
  end, function()
    self.m_playSubIndex = self.m_playSubIndex + 1
    local nextVoice = self.m_voiceTextListDic[self.m_iVoiceId][self.m_playSubIndex]
    if nextVoice ~= nil then
      self:PlayVoice(nextVoice.m_voice)
    else
      self.m_playingId = nil
      self.m_txt_voicedesc_Text.text = ""
      UILuaHelper.SetActive(self.m_img_bg_voice02, false)
      local voiceItem = self.m_luaVoiceInfinityGrid:GetShowItemByIndex(self.m_curIdx)
      if voiceItem then
        voiceItem:StopVoiceAnim()
      end
    end
  end)
end

function HeroFashionVoiceSubPanel:OnVoiceClick(index)
  local voiceCfg = self.m_showVoiceInfoList[index].voiceInfoCfg
  if not AttractManager:CheckVoiceUnlockCondition(self.m_heroData, voiceCfg.m_UnlockType, voiceCfg.m_UnlockData) then
    return
  end
  self:StopCurPlayingVoice()
  self.m_curIdx = index
  self.m_iVoiceId = voiceCfg.m_VoiceId
  local eventName = self.m_voiceTextListDic[self.m_iVoiceId][self.m_playSubIndex].m_voice
  self:PlayVoice(eventName)
end

function HeroFashionVoiceSubPanel:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return HeroFashionVoiceSubPanel
