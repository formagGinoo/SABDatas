local Form_BattleSystemPop1 = class("Form_BattleSystemPop1", require("UI/UIFrames/Form_BattleSystemPop1UI"))

function Form_BattleSystemPop1:SetInitParam(param)
end

function Form_BattleSystemPop1:AfterInit()
  self.super.AfterInit(self)
  self.m_settingLanguageIns = ConfigManager:GetConfigInsByName("SettingLanguage")
end

function Form_BattleSystemPop1:OnActive()
  self.super.OnActive(self)
  self:RefreshView()
end

function Form_BattleSystemPop1:OnInactive()
  self.super.OnInactive(self)
  if self.m_infinityGrid then
    self.m_infinityGrid:dispose()
    self.m_infinityGrid = nil
  end
end

function Form_BattleSystemPop1:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattleSystemPop1:RefreshView()
  local multiLangCfgAll = CData_MultiLanguage:GetAll()
  local vVoiceList = {}
  for i, v in pairs(multiLangCfgAll) do
    if v.m_IsEnableVoice == 1 then
      local stLanguageElment = CData_MultiLanguage:GetValue_ByID(v.m_ID)
      local sLabelName = "multilanvo_" .. stLanguageElment.m_SoundType
      local downloadedSize = DownloadManager:GetDownloadedBytesByLabel(sLabelName)
      if 0 < downloadedSize or CS.MultiLanguageManager.g_iLanguageVoiceID == v.m_ID then
        vVoiceList[#vVoiceList + 1] = {
          voiceCfg = v,
          callFunc = handler(self, self.OnSelectVoice),
          downloadedSize = downloadedSize
        }
      end
    end
  end
  table.sort(vVoiceList, function(a, b)
    return a.voiceCfg.m_ID < b.voiceCfg.m_ID
  end)
  self.m_vVoiceList = vVoiceList
  self.m_infinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "Setting/UISettingVoiceItem")
  self.m_infinityGrid:ShowItemList(vVoiceList)
end

function Form_BattleSystemPop1:OnSelectVoice(iItemIndex, itemData)
  if self.m_lastIndex ~= nil then
    local lastItem = self.m_infinityGrid:GetShowItemByIndex(self.m_lastIndex)
    if lastItem then
      lastItem.m_img_select1:SetActive(false)
    end
  end
  local curItem = self.m_infinityGrid:GetShowItemByIndex(iItemIndex)
  if curItem then
    curItem.m_img_select1:SetActive(true)
  end
  self.m_lastIndex = iItemIndex
end

function Form_BattleSystemPop1:OnBtnRClicked()
  if self.m_lastIndex == nil then
    return
  end
  local voiceCfg = self.m_vVoiceList[self.m_lastIndex].voiceCfg
  local selectVoiceID = voiceCfg.m_ID
  local settingLanguageCfg = self.m_settingLanguageIns:GetValue_ByLanID(voiceCfg.m_LanID)
  if selectVoiceID == CS.MultiLanguageManager.g_iLanguageVoiceID then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40021)
  else
    DownloadManager:DeleteMultiLanguageVoice(selectVoiceID)
    utils.CheckAndPushCommonTips({
      tipsID = 1604,
      fContentCB = function(content)
        return string.format(content, settingLanguageCfg.m_mVoiceName)
      end,
      func1 = function()
        self:RefreshView()
      end
    })
  end
end

function Form_BattleSystemPop1:OnBtnLClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_BattleSystemPop1", Form_BattleSystemPop1)
return Form_BattleSystemPop1
