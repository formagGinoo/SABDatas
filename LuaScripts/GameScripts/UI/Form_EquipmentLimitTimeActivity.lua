local Form_EquipmentLimitTimeActivity = class("Form_EquipmentLimitTimeActivity", require("UI/UIFrames/Form_EquipmentLimitTimeActivityUI"))
local ChallengeText = ConfigManager:GetCommonTextById(20397)
local TotalScoreText = ConfigManager:GetCommonTextById(20398)
local ContributionText = ConfigManager:GetCommonTextById(20399)

function Form_EquipmentLimitTimeActivity:AfterInit()
  self.super.AfterInit(self)
  local param = self.m_csui.m_param
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.CloseForm), nil, nil, 1278)
  local initGridData = {
    OnItemClk = function(score)
      self:OnItemClk(score)
    end
  }
  self.m_reward_list_Grid = self:CreateInfinityGrid(self.m_reward_list_InfinityGrid, "PartDungeonWelfare/UIPartDungeonWelfareRewardItem", initGridData)
  self.m_stActivity = param.activity
  self.m_iActivityId = self.m_stActivity:getID()
  self.totalScore = 0
  self.m_iTimeDurationOneSecond = 1
  self.EndTimeStr = ""
end

function Form_EquipmentLimitTimeActivity:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:ResetData()
end

function Form_EquipmentLimitTimeActivity:OnUpdate(dt)
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick - dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond - dt
  if self.m_iTimeDurationOneSecond <= 0 then
    self.m_iTimeDurationOneSecond = 1
    local lastTimeCur = TimeUtil:SecondsToFormatCNStr4(self.m_iTimeTick)
    self.m_txt_time_Text.text = string.gsubnumberreplace(self.EndTimeStr, lastTimeCur)
  end
  if self.m_iTimeTick <= 0 and self.m_stActivity then
    self:CloseForm()
  end
end

function Form_EquipmentLimitTimeActivity:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
  self.m_iTimeTick = nil
end

function Form_EquipmentLimitTimeActivity:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_EquipmentLimitTimeActivity:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_AnywayReload", handler(self, self.OnAnywayReload))
  self:addEventListener("eGameEvent_Activity_PartDungeonWelfare_GetReward", handler(self, self.OnGetReward))
  self:addEventListener("eGameEvent_Activity_PartDungeonWelfare_QuestStatuChange", handler(self, self.OnQuestStatuChange))
  self:addEventListener("eGameEvent_Activity_PartDungeonWelfare_TotalScoreChange", handler(self, self.OnTotalScoreChange))
end

function Form_EquipmentLimitTimeActivity:OnAnywayReload()
  if self.m_iActivityId then
    self.m_stActivity = ActivityManager:GetActivityByID(self.m_iActivityId)
    if not self.m_stActivity then
      self:CloseForm()
    else
      self:ResetData()
    end
  end
end

function Form_EquipmentLimitTimeActivity:OnGetReward(vReward)
  utils.popUpRewardUI(vReward)
  if self.m_reward_list_Grid then
    local data = self:GeneratedRewardData()
    self.m_reward_list_Grid:ShowItemList(data)
  end
end

function Form_EquipmentLimitTimeActivity:OnQuestStatuChange()
  if self.m_stActivity then
    UILuaHelper.SetActive(self.m_task_redpoint, self.m_stActivity:HaveTaskRedDot())
  end
end

function Form_EquipmentLimitTimeActivity:OnTotalScoreChange()
  local selfScore = self.m_stActivity:GetSelfScore()
  self.m_txt_cont_num_Text.text = string.gsubnumberreplace(ContributionText, selfScore)
  self.totalScore = self.m_stActivity:GetTotalScore()
  self.m_score_num_Text.text = BigNumFormat(self.totalScore)
  if self.m_reward_list_Grid then
    local data = self:GeneratedRewardData()
    self.m_reward_list_Grid:ShowItemList(data)
  end
end

function Form_EquipmentLimitTimeActivity:ResetData()
  if self.m_stActivity then
    self.totalScore = self.m_stActivity:GetTotalScore()
    self.m_score_num_Text.text = BigNumFormat(self.totalScore)
    self:ReFreshUI()
  end
end

function Form_EquipmentLimitTimeActivity:ReFreshUI()
  if self.m_stActivity then
    local selfScore = self.m_stActivity:GetSelfScore()
    self.m_txt_cont_num_Text.text = string.gsubnumberreplace(ContributionText, selfScore)
    self.m_txt_cur_challenge_Text.text = ChallengeText
    self.m_txt_score_Text.text = TotalScoreText
    self.m_z_activity_tip_Text.text = self.m_stActivity:GetDetailDesc()
    UILuaHelper.SetAtlasSprite(self.m_mid_Icon_Image, self.m_stActivity:GetActivityPic())
    local subTypeArr = self.m_stActivity:GetFightSubType()
    if subTypeArr[1] then
      local levelName = ""
      local chapterData = ConfigManager:GetConfigInsByName("PartDungeonChapter"):GetValue_ByLevelSubType(subTypeArr[1])
      levelName = chapterData.m_mName
      self.m_level_name_Text.text = levelName
      UILuaHelper.SetAtlasSprite(self.m_level_icon_Image, chapterData.m_Icon)
    end
    UILuaHelper.SetActive(self.m_task_redpoint, self.m_stActivity:HaveTaskRedDot())
    local endTime, endTimeStr = self.m_stActivity:GetEndTime()
    if 0 < endTime then
      UILuaHelper.SetActive(self.m_txt_time, true)
      self.m_iTimeTick = endTime - TimeUtil:GetServerTimeS()
      local lastTimeCur = TimeUtil:SecondsToFormatCNStr4(self.m_iTimeTick)
      self.m_txt_time_Text.text = string.gsubnumberreplace(endTimeStr, lastTimeCur)
      self.EndTimeStr = endTimeStr
    else
      self.m_iTimeTick = nil
      self:CloseForm()
    end
    if self.m_reward_list_Grid then
      local data = self:GeneratedRewardData()
      self.m_reward_list_Grid:ShowItemList(data)
    end
  end
end

function Form_EquipmentLimitTimeActivity:GeneratedRewardData()
  local data = {}
  local mRewardConfig = self.m_stActivity:GetWelfareCfg().mRewardConfig
  local drawScore = self.m_stActivity:GetDrawScore()
  for i, v in pairs(mRewardConfig) do
    local isHaveGet = i <= drawScore
    table.insert(data, {
      score = i,
      id = v[1].iID,
      num = v[1].iNum,
      isShowLight = false,
      isShowPoint = false,
      isLast = false,
      isHaveGet = isHaveGet,
      beClaimed = i <= self.totalScore and not isHaveGet
    })
  end
  table.sort(data, function(a, b)
    return a.score < b.score
  end)
  for i, v in pairs(data) do
    local key, next = next(data, i)
    if key and self.totalScore >= next.score then
      v.isShowLight = true
    end
    if self.totalScore >= v.score then
      v.isShowPoint = true
    end
    v.isLast = key ~= nil
  end
  return data
end

function Form_EquipmentLimitTimeActivity:OnItemClk(score)
  if self.m_stActivity then
    self.m_stActivity:DrawRewardCS(self.m_iActivityId, score)
  end
end

function Form_EquipmentLimitTimeActivity:OnBtntaskClicked()
  if self.m_stActivity then
    StackFlow:Push(UIDefines.ID_FORM_EUIPCROSSTASK, self.m_stActivity)
  end
end

function Form_EquipmentLimitTimeActivity:IsFullScreen()
  return true
end

ActiveLuaUI("Form_EquipmentLimitTimeActivity", Form_EquipmentLimitTimeActivity)
return Form_EquipmentLimitTimeActivity
