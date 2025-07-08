local Form_ActivityQuestion = class("Form_ActivityQuestion", require("UI/UIFrames/Form_ActivityQuestionUI"))

function Form_ActivityQuestion:SetInitParam(param)
end

function Form_ActivityQuestion:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
end

function Form_ActivityQuestion:OnActive()
  local tParam = self.m_csui.m_param
  self.m_rewardList = {}
  self.m_index = 1
  self.m_activeIndex = tParam.activeIndex or 1
  self.m_surveyId = ""
  local activeList = ActivityManager:GetActivityListByType(MTTD.ActivityType_SurveyReward)
  if not activeList or not activeList[self.m_activeIndex] then
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYQUESTION)
    return
  end
  self.m_active = activeList[self.m_activeIndex]
  self:RefreshUI()
  CS.UI.UILuaHelper.RegisterBrowserJSCallback(handler(self, self.OnRegisterBrowserJSCallback))
  CS.UI.UILuaHelper.RegisterBrowserClosedCallback(handler(self, self.OnRegisterBrowserClosedCallback))
  self:RemoveEventListeners()
  self.m_getSurveyReward = self:addEventListener("eGameEvent_Activity_SurveyReward", handler(self, self.OnRegisterBrowserClosedCallback))
  GlobalManagerIns:TriggerWwiseBGMState(41)
end

function Form_ActivityQuestion:OnInactive()
  CS.UI.UILuaHelper.RegisterBrowserJSCallback(nil)
  CS.UI.UILuaHelper.RegisterBrowserClosedCallback(nil)
  self:RemoveEventListeners()
end

function Form_ActivityQuestion:RemoveEventListeners()
  if self.m_getSurveyReward then
    self:removeEventListener("eGameEvent_Activity_SurveyReward", self.m_getSurveyReward)
    self.m_getSurveyReward = nil
  end
end

function Form_ActivityQuestion:RefreshUI()
  self.m_stActivity = ActivityManager:GetActivityInShowTimeById(self.m_active:getID())
  if self.m_stActivity == nil then
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYQUESTION)
    return
  end
  self:RefreshReward()
  self:RefreshRemainTime()
  if self.m_stActivity:GetSurveyRewardStatus() then
    local state = self.m_stActivity:GetSurveyRewardStatus()[self.m_index]
    self.m_btn_red:SetActive(state == MTTDProto.SurveyRewardStatus_None or state == nil)
    self.m_img_received:SetActive(state == MTTDProto.SurveyRewardStatus_Answer or state == MTTDProto.SurveyRewardStatus_Reward)
  end
end

function Form_ActivityQuestion:RefreshRemainTime()
  self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_stActivity:getActivityRemainTime())
end

function Form_ActivityQuestion:RefreshReward()
  self.m_rewardList = {}
  local vInfo = self.m_stActivity:GetInfoList()[self.m_index]
  if vInfo then
    self.m_txt_title_Text.text = self.m_stActivity:getLangText(vInfo.sMailTitle)
    self.m_txt_des_Text.text = self.m_stActivity:getLangText(vInfo.sMailContent)
    if vInfo.stRewardInfo then
      for i, v in ipairs(vInfo.stRewardInfo) do
        self.m_rewardList[#self.m_rewardList + 1] = ResourceUtil:GetProcessRewardData(v)
      end
    end
    self.m_surveyId = vInfo.sSurveyId
  end
  self.m_rewardListInfinityGrid:ShowItemList(self.m_rewardList)
end

function Form_ActivityQuestion:OnRegisterBrowserJSCallback()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYQUESTION)
end

function Form_ActivityQuestion:OnRegisterBrowserClosedCallback()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYQUESTION)
end

function Form_ActivityQuestion:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_rewardList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    })
  end
end

function Form_ActivityQuestion:OnBtnredClicked()
  self.m_stActivity:RequestGetSurveyLink(self.m_index)
end

function Form_ActivityQuestion:OnBtnCloseClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYQUESTION)
end

function Form_ActivityQuestion:IsOpenGuassianBlur()
  return true
end

local fullscreen = false
ActiveLuaUI("Form_ActivityQuestion", Form_ActivityQuestion)
return Form_ActivityQuestion
