local UISubPanelBase = require("UI/Common/UISubPanelBase")
local LegacyLevelDetailSubPanel = class("LegacyLevelDetailSubPanel", UISubPanelBase)
local EnterAnimStr = "level_detail_in"
local OutAnimStr = "level_detail_out"

function LegacyLevelDetailSubPanel:OnInit()
  if self.m_initData then
    self.m_bgClkBack = self.m_initData.bgBackFun
  end
  UILuaHelper.SetActive(self.m_btn_detail_bg, self.m_bgClkBack ~= nil)
  self.m_chapterData = nil
  self.m_isExChapter = nil
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnLevelItemClk(itemIndex)
    end
  }
  self.m_luaLevelInfinityGrid = self:CreateInfinityGrid(self.m_stage_list_InfinityGrid, "LegacyActivity/UILegacyLevelItem", initGridData)
  self.m_isHaveTakeReward = nil
  self.m_showChapterCustomDataList = nil
  self:AddEventListeners()
end

function LegacyLevelDetailSubPanel:FreshRedDot()
  if not self.m_chapterData then
    return
  end
  self:RegisterOrUpdateRedDotItem(self.m_chapter_reward_red_dot, RedDotDefine.ModuleType.LegacyLevelChapterReward, self.m_chapterData.chapterCfg.m_ChapterID)
end

function LegacyLevelDetailSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_LegacyLevel_StageReset", handler(self, self.OnEventLegacyLevelStageReset))
  self:addEventListener("eGameEvent_LegacyLevel_GetChapterReward", handler(self, self.OnEventLegacyLevelGetChapterReward))
  self:addEventListener("eGameEvent_LegacyLevel_LegacyStagePush", handler(self, self.OnEventLegacyLevelPushStage))
end

function LegacyLevelDetailSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function LegacyLevelDetailSubPanel:OnEventLegacyLevelStageReset(param)
  if not self.m_chapterData then
    return
  end
  local levelID = param.levelID
  local levelList = self.m_chapterData.levelList
  if not levelList then
    return
  end
  for i, tempLevelStageInfoCfg in ipairs(levelList) do
    if levelID == tempLevelStageInfoCfg.m_LevelID then
      local showItem = self.m_luaLevelInfinityGrid:GetShowItemByIndex(i)
      if showItem then
        showItem:FreshItemUI()
      end
      return
    end
  end
end

function LegacyLevelDetailSubPanel:OnEventLegacyLevelGetChapterReward(param)
  if not self.m_chapterData then
    return
  end
  local chapterID = self.m_chapterData.chapterCfg.m_ChapterID
  if chapterID ~= param.chapterID then
    return
  end
  self:FreshRewardProgress()
end

function LegacyLevelDetailSubPanel:OnEventLegacyLevelPushStage()
  if not self.m_chapterData then
    return
  end
  self:FreshUI()
end

function LegacyLevelDetailSubPanel:OnFreshData()
  self.m_chapterData = self.m_panelData.chapterData
  self.m_isExChapter = self.m_panelData.isExChapter
  self:CheckSetLevelWatchStatus()
  self:FreshUI()
  self:CheckShowAnimIn()
  self:FreshRedDot()
end

function LegacyLevelDetailSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  if self.m_detailOutTimer ~= nil then
    TimeService:KillTimer(self.m_detailOutTimer)
    self.m_detailOutTimer = nil
  end
  LegacyLevelDetailSubPanel.super.OnDestroy(self)
end

function LegacyLevelDetailSubPanel:CheckSetLevelWatchStatus()
  if not self.m_chapterData then
    return
  end
  local chapterID = self.m_chapterData.chapterCfg.m_ChapterID
  if not chapterID then
    return
  end
  LegacyLevelManager:CheckSetChapterWatchStatus(chapterID)
end

function LegacyLevelDetailSubPanel:CreateCustomChooseDataList(vRewardList)
  if not vRewardList then
    return
  end
  local vRewardLua = utils.changeCSArrayToLuaTable(vRewardList)
  local customDataList = {}
  for i, v in ipairs(vRewardLua) do
    local tempCustomData = {
      is_have_get = self.m_isHaveTakeReward
    }
    customDataList[#customDataList + 1] = tempCustomData
  end
  return customDataList
end

function LegacyLevelDetailSubPanel:FreshUI()
  if not self.m_chapterData then
    return
  end
  self.m_txt_title_Text.text = self.m_chapterData.chapterCfg.m_mChapterName
  self:FreshRewardProgress()
  self:FreshLevelList(true)
end

function LegacyLevelDetailSubPanel:FreshRewardProgress()
  if not self.m_chapterData then
    return
  end
  local progressNum = LegacyLevelManager:GetChapterProgressNum(self.m_chapterData.chapterCfg.m_ChapterID) or 0
  local percentNumStr = math.floor(progressNum * 100) .. "%"
  self.m_txt_slidernum_Text.text = percentNumStr
  self.m_img_sliderreward_Image.fillAmount = progressNum
  self.m_isHaveTakeReward = LegacyLevelManager:IsChapterRewardHaveGet(self.m_chapterData.chapterCfg.m_ChapterID)
  UILuaHelper.SetActive(self.m_btn_reward, 1 <= progressNum and not self.m_isHaveTakeReward)
  self.m_showChapterCustomDataList = nil
end

function LegacyLevelDetailSubPanel:FreshLevelList(isReSetPos)
  if not self.m_chapterData then
    return
  end
  if not self.m_chapterData.levelList then
    return
  end
  self.m_luaLevelInfinityGrid:ShowItemList(self.m_chapterData.levelList)
  if isReSetPos then
    self.m_luaLevelInfinityGrid:LocateTo()
  end
end

function LegacyLevelDetailSubPanel:CheckShowAnimIn()
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, EnterAnimStr)
end

function LegacyLevelDetailSubPanel:CheckShowAnimOut(endFun)
  if self.m_detailOutTimer ~= nil then
    return
  end
  local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_level_panel_detail, EnterAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, OutAnimStr)
  self.m_detailOutTimer = TimeService:SetTimer(detailAnimLen, 1, function()
    if endFun then
      endFun()
    end
    self.m_detailOutTimer = nil
  end)
end

function LegacyLevelDetailSubPanel:OnBtndetailbgClicked()
  self:CheckShowAnimOut(function()
    if self.m_bgClkBack then
      self.m_bgClkBack()
    end
  end)
end

function LegacyLevelDetailSubPanel:OnBtnrewardClicked()
  if not self.m_chapterData then
    return
  end
  LegacyLevelManager:ReqLegacyStageTakeChapterReward(self.m_chapterData.chapterCfg.m_ChapterID)
end

function LegacyLevelDetailSubPanel:OnBtnRewardGreyClicked()
  if not self.m_chapterData then
    return
  end
  local vReward = self.m_chapterData.chapterCfg.m_ChapterReward
  if not self.m_showChapterCustomDataList then
    self.m_showChapterCustomDataList = self:CreateCustomChooseDataList(vReward)
  end
  StackFlow:Push(UIDefines.ID_FORM_COMMONTIPPREVIEW, {
    vReward = vReward,
    vCustomData = self.m_showChapterCustomDataList
  })
end

function LegacyLevelDetailSubPanel:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return LegacyLevelDetailSubPanel
