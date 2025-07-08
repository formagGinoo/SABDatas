local Form_LegacyLockTips = class("Form_LegacyLockTips", require("UI/UIFrames/Form_LegacyLockTipsUI"))
local MaxUnlockNum = 2

function Form_LegacyLockTips:SetInitParam(param)
end

function Form_LegacyLockTips:AfterInit()
  self.super.AfterInit(self)
  self.m_curLegacyChapterID = nil
end

function Form_LegacyLockTips:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_LegacyLockTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_LegacyLockTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LegacyLockTips:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    local paramChapterID = tParam.chapterID
    self.m_curLegacyChapterID = paramChapterID
    local legacyStageChapterInfo = LegacyLevelManager:GetChapterConfigByID(self.m_curLegacyChapterID)
    self.m_unlockDataList = self:GetChapterUnlockDataList(legacyStageChapterInfo)
    self.m_csui.m_param = nil
  end
end

function Form_LegacyLockTips:GetChapterUnlockDataList(chapterInfoCfg)
  if not chapterInfoCfg then
    return
  end
  local unlockDataList = {}
  local unlockMainLevelID = chapterInfoCfg.m_UnlockMainLevel
  local mainLevelCfg = LevelManager:GetMainLevelCfgById(unlockMainLevelID)
  if mainLevelCfg then
    local mainLevelUnlockStr = string.CS_Format(ConfigManager:GetCommonTextById(100501), mainLevelCfg.m_LevelName)
    local tempUnlockTab = {
      unlockStr = mainLevelUnlockStr,
      isMatch = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, unlockMainLevelID)
    }
    unlockDataList[#unlockDataList + 1] = tempUnlockTab
  end
  local preChapterID = chapterInfoCfg.m_PreChapterID
  if preChapterID and 0 < preChapterID then
    local preChapterCfg = LegacyLevelManager:GetChapterConfigByID(preChapterID)
    local chapterUnlockStr = string.CS_Format(ConfigManager:GetCommonTextById(100502), preChapterCfg.m_mChapterName)
    local tempUnlockTab = {
      unlockStr = chapterUnlockStr,
      isMatch = LegacyLevelManager:IsChapterLevelAllHavePass(preChapterID)
    }
    unlockDataList[#unlockDataList + 1] = tempUnlockTab
  end
  return unlockDataList
end

function Form_LegacyLockTips:FreshChapterLockStatus()
  if not self.m_unlockDataList then
    return
  end
  for i = 1, MaxUnlockNum do
    local unlockData = self.m_unlockDataList[i]
    if unlockData then
      UILuaHelper.SetActive(self["m_pnl_condition" .. i], true)
      UILuaHelper.SetActive(self["m_icon_fork" .. i], not unlockData.isMatch)
      UILuaHelper.SetActive(self["m_icon_complete" .. i], unlockData.isMatch)
      self[string.format("m_txt_conditon%d_Text", i)].text = unlockData.unlockStr
      UILuaHelper.SetColorByMultiIndex(self["m_txt_conditon" .. i], unlockData.isMatch and 1 or 0)
    else
      UILuaHelper.SetActive(self["m_pnl_condition" .. i], false)
    end
  end
end

function Form_LegacyLockTips:FreshUI()
  self:FreshChapterLockStatus()
end

local fullscreen = true
ActiveLuaUI("Form_LegacyLockTips", Form_LegacyLockTips)
return Form_LegacyLockTips
