local Form_RogueAchievement = class("Form_RogueAchievement", require("UI/UIFrames/Form_RogueAchievementUI"))

function Form_RogueAchievement:SetInitParam(param)
end

function Form_RogueAchievement:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1203)
  local initQuestGridData = {
    itemClkBackFun = handler(self, self.OnQuestItemClk)
  }
  self.m_questInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_task_list_InfinityGrid, "RogueChoose/RogueQuestItem", initQuestGridData)
end

function Form_RogueAchievement:OnActive()
  self.super.OnActive(self)
  self.m_bg_tips:SetActive(false)
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_AchieveRewardCfgs = TaskManager:GetAchieveRewardCfgs()
  self:addEventListener("eGameEvent_RogueAchievement_TaskUpdate", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_RogueStage_TakeAchieveReward", handler(self, self.FreshLeft))
  self.m_vx_glow_slider:SetActive(false)
  self:RefreshUI()
end

function Form_RogueAchievement:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_RogueAchievement:OnDestroy()
  self.super.OnDestroy(self)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_RogueAchievement:RefreshUI()
  self.mQuests = TaskManager:GetRogueSortedQuests()
  self.m_questInfinityGrid:ShowItemList(self.mQuests)
  self.m_questInfinityGrid:LocateTo(0)
  local t = TaskManager:GetRogueQuestCanReceiveRewardIDList()
  local temp = TaskManager:GetRogueAchievementScore() or {}
  local lastTakeAwardId = temp[#temp] or 0
  local curRewardCfg = self.m_AchieveRewardCfgs[lastTakeAwardId + 1]
  local bCanTakeReward = false
  if curRewardCfg then
    local _, t2 = TaskManager:GetAchievementScore()
    local cur_Point = t2
    local max_Point = tonumber(curRewardCfg.m_RequiredCount)
    bCanTakeReward = cur_Point >= max_Point
  end
  self.m_btn_yes:SetActive(t and 0 < #t or bCanTakeReward)
  self.m_txt_got:SetActive(bCanTakeReward)
  self.m_txt_got_Text.text = ConfigManager:GetCommonTextById(100714)
  self.m_btn_grey:SetActive((not t or not (0 < #t)) and not bCanTakeReward)
  self:FreshLeft()
end

function Form_RogueAchievement:FreshLeft()
  local temp = TaskManager:GetRogueAchievementScore() or {}
  local lastTakeAwardId = temp[#temp] or 0
  local curRewardCfg = self.m_AchieveRewardCfgs[lastTakeAwardId + 1]
  if curRewardCfg then
    local rewards = utils.changeCSArrayToLuaTable(curRewardCfg.m_Reward)
    for i = 1, 2 do
      local item = self:createCommonItem(self["m_item" .. i])
      local reward = rewards[i]
      local processData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(reward[1]),
        iNum = tonumber(reward[2])
      })
      item:SetItemInfo(processData)
      item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardCommonItemClk(itemID, itemNum, itemCom)
      end)
    end
    local _, t2 = TaskManager:GetAchievementScore()
    local cur_Point = t2
    local max_Point = tonumber(curRewardCfg.m_RequiredCount)
    self.m_txt_slidernum_Text.text = cur_Point
    self.m_txt_slidernum1_Text.text = "/" .. curRewardCfg.m_RequiredCount
    if cur_Point / max_Point > self.m_img_fg_slider_Image.fillAmount then
      self.m_vx_glow_slider:SetActive(true)
      DOTweenModuleUI.DOFillAmount(self.m_img_fg_slider_Image, cur_Point / max_Point, 0.5)
      DOTweenModuleUI.DOFillAmount(self.m_vx_glow_slider_Image, cur_Point / max_Point, 0.5)
      if self.timer then
        TimeService:KillTimer(self.timer)
        self.timer = nil
      end
      self.timer = TimeService:SetTimer(0.5, -1, function()
        self.m_vx_glow_slider:SetActive(false)
      end)
    else
      self.m_img_fg_slider_Image.fillAmount = cur_Point / max_Point
    end
    self.m_pnl_effect_cup:SetActive(cur_Point >= max_Point)
    self.m_vx_glow:SetActive(cur_Point >= max_Point)
    self.m_pnl_tips:SetActive(true)
  else
    self.m_txt_got:SetActive(true)
    self.m_txt_got_Text.text = ConfigManager:GetCommonTextById(100715)
    self.m_pnl_effect_cup:SetActive(false)
    self.m_vx_glow:SetActive(false)
    self.m_pnl_tips:SetActive(false)
    curRewardCfg = self.m_AchieveRewardCfgs[lastTakeAwardId]
    if curRewardCfg then
      self.m_txt_slidernum1_Text.text = "/" .. curRewardCfg.m_RequiredCount
    end
    local _, t2 = TaskManager:GetAchievementScore()
    local cur_Point = t2
    self.m_txt_slidernum_Text.text = cur_Point
    self.m_img_fg_slider_Image.fillAmount = 1
  end
end

function Form_RogueAchievement:OnQuestItemClk(m_Quest, index, item)
  self:RequestTakeReward({
    m_Quest.iId
  }, function(sc)
    self:RefreshUI()
  end)
end

function Form_RogueAchievement:OnRewardCommonItemClk(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_RogueAchievement:OnBtnyesClicked()
  local t = TaskManager:GetRogueQuestCanReceiveRewardIDList()
  if t and 0 < #t then
    self:RequestTakeReward(t, function(sc)
      self:RefreshUI()
    end)
  else
    self:OnBtncupClicked()
  end
end

function Form_RogueAchievement:OnBtngreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20041)
end

function Form_RogueAchievement:RequestTakeReward(vQuestId, callback)
  local reqMsg = MTTDProto.Cmd_Quest_TakeReward_CS()
  reqMsg.iQuestType = MTTDProto.QuestType_RogueAchieve
  reqMsg.vQuestId = vQuestId
  RPCS():Quest_TakeReward(reqMsg, function(sc, msg)
    local reward = sc.vReward
    if reward and next(reward) then
      utils.popUpRewardUI(reward, callback)
    elseif callback then
      callback(sc)
    end
    TaskManager:CheckRogueAchievementReddot()
  end)
end

function Form_RogueAchievement:OnBtncupClicked()
  local bCanTakeReward = false
  local temp = TaskManager:GetRogueAchievementScore() or {}
  local lastTakeAwardId = temp[#temp] or 0
  local curRewardCfg = self.m_AchieveRewardCfgs[lastTakeAwardId + 1]
  if curRewardCfg then
    local _, t2 = TaskManager:GetAchievementScore()
    local cur_Point = t2
    local max_Point = tonumber(curRewardCfg.m_RequiredCount)
    bCanTakeReward = cur_Point >= max_Point
  end
  if bCanTakeReward then
    TaskManager:ReqTakeAchieveRewardReward(lastTakeAwardId + 1, nil, MTTDProto.QuestType_RogueAchieve)
  else
    self.m_bg_tips:SetActive(true)
  end
end

function Form_RogueAchievement:OnBtnCloseTipsClicked()
  self.m_bg_tips:SetActive(false)
end

function Form_RogueAchievement:OnBackClk()
  self:CloseForm()
end

function Form_RogueAchievement:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RogueAchievement", Form_RogueAchievement)
return Form_RogueAchievement
