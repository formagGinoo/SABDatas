local Form_ActivitySevendaysFace = class("Form_ActivitySevendaysFace", require("UI/UIFrames/Form_ActivitySevendaysFaceUI"))
local SignMaxNum = 7
local Big_Reward = 2
local MaxRewardNumOneDay = 3

function Form_ActivitySevendaysFace:SetInitParam(param)
end

function Form_ActivitySevendaysFace:AfterInit()
  self.m_vPanelItemConfig = {}
  for i = 1, SignMaxNum do
    self.m_vPanelItemConfig[i] = {}
    self.m_vPanelItemConfig[i].childsItemIcon = {}
    self.m_vPanelItemConfig[i].panel = self[string.format("m_item_%02d", i)]
    self.m_vPanelItemConfig[i].imageMask = self.m_vPanelItemConfig[i].panel.transform:Find("c_img_mask").gameObject
    self.m_vPanelItemConfig[i].textDay = self.m_vPanelItemConfig[i].panel.transform:Find("c_txt_day").gameObject
    self.m_vPanelItemConfig[i].nextDay = self.m_vPanelItemConfig[i].panel.transform:Find("c_nextday").gameObject
    if i < SignMaxNum then
      self.m_vPanelItemConfig[i].already = self.m_vPanelItemConfig[i].panel.transform:Find("m_bg_already" .. i).gameObject
    end
    for j = 1, MaxRewardNumOneDay do
      self.m_vPanelItemConfig[i].childsItemIcon[j] = self.m_vPanelItemConfig[i].panel.transform:Find("m_list_itemreward" .. i .. "/c_common_item" .. j).gameObject
    end
  end
end

function Form_ActivitySevendaysFace:OnActive()
  self.super.OnActive(self)
  self.subPanelLuaName = self.m_csui.m_param
  local signActivityList = ActivityManager:GetActivityListByType(MTTD.ActivityType_Sign)
  for _, v in ipairs(signActivityList) do
    if v:getSubPanelName() == self.subPanelLuaName then
      self.m_stActivity = v
    end
  end
  self:RemoveEventListeners()
  self:AddEventListeners()
  self:RefreshUI()
  self:AutoRequestSign()
  GlobalManagerIns:TriggerWwiseBGMState(33)
end

function Form_ActivitySevendaysFace:AddEventListeners()
  self.m_iHandlerIDUpdateSign = self:addEventListener("eGameEvent_Activity_Sign_UpdateSign", handler(self, self.OnEventUpdateSign))
  self.m_iHandlerIDReload = self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
end

function Form_ActivitySevendaysFace:AutoRequestSign()
  if self.m_stActivity then
    local iSignNum = self.m_stActivity:GetSignNum()
    local bSignToday = self.m_stActivity:IsSignToday()
    local vSignInfoList = self.m_stActivity:GetSignInfoList()
    if not bSignToday and iSignNum < #vSignInfoList then
      local stSignInfo = vSignInfoList[iSignNum + 1]
      self.m_stActivity:RequestSign(stSignInfo.iIndex)
    end
  end
end

function Form_ActivitySevendaysFace:OnActiveTransitionDone()
end

function Form_ActivitySevendaysFace:RefreshUI()
  if self.m_stActivity == nil then
    StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYSEVENDAYSFACE)
    return
  end
  self:RefreshReward()
  self:RefreshRemainTime()
end

function Form_ActivitySevendaysFace:RemoveEventListeners()
  if self.m_iHandlerIDUpdateSign then
    self:removeEventListener("eGameEvent_Activity_Sign_UpdateSign", self.m_iHandlerIDUpdateSign)
    self.m_iHandlerIDUpdateSign = nil
  end
  if self.m_iHandlerIDReload then
    self:removeEventListener("eGameEvent_Activity_Reload", self.m_iHandlerIDReload)
    self.m_iHandlerIDReload = nil
  end
end

function Form_ActivitySevendaysFace:OnInactive()
  self:RemoveEventListeners()
  self:killRemainTimer()
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_ActivitySevendaysFace:OnUpdate(dt)
  self:RefreshRemainTime()
end

function Form_ActivitySevendaysFace:RefreshReward()
  if not self.m_stActivity then
    return
  end
  local iSignNum = self.m_stActivity:GetSignNum()
  local bSignToday = self.m_stActivity:IsSignToday()
  local vSignInfoList = self.m_stActivity:GetSignInfoList()
  local iRewardCount = math.min(#vSignInfoList, SignMaxNum)
  for i = 1, iRewardCount do
    local stSignInfo = vSignInfoList[i]
    local stPanelItemConfig = self.m_vPanelItemConfig[i]
    stPanelItemConfig.panel:SetActive(true)
    for j = 1, MaxRewardNumOneDay do
      if j <= #stSignInfo.stRewardInfo then
        UILuaHelper.SetActive(stPanelItemConfig.childsItemIcon[j], true)
        local itemWidgetIcon = self:createCommonItem(stPanelItemConfig.childsItemIcon[j])
        local itemInfo = ResourceUtil:GetProcessRewardData({
          iID = stSignInfo.stRewardInfo[j].iID,
          iNum = stSignInfo.stRewardInfo[j].iNum
        })
        itemWidgetIcon:SetItemInfo(itemInfo)
        itemWidgetIcon:SetItemIconClickCB(handler(self, self.ShowItemTips))
        if i <= iSignNum then
          itemWidgetIcon:SetItemHaveGetActive(true)
        else
          itemWidgetIcon:SetItemHaveGetActive(false)
        end
      else
        UILuaHelper.SetActive(stPanelItemConfig.childsItemIcon[j], false)
      end
    end
    stPanelItemConfig.textDay:GetComponent(T_TextMeshProUGUI).text = string.format("%02d", i)
    if i <= iSignNum then
      stPanelItemConfig.imageMask:SetActive(true)
      stPanelItemConfig.nextDay:SetActive(false)
      if i < SignMaxNum then
        stPanelItemConfig.already:SetActive(false)
      end
    elseif i == iSignNum + 1 and not bSignToday then
      stPanelItemConfig.imageMask:SetActive(false)
      stPanelItemConfig.nextDay:SetActive(false)
      if i < SignMaxNum then
        stPanelItemConfig.already:SetActive(false)
      end
    elseif i == iSignNum + 1 and bSignToday then
      stPanelItemConfig.nextDay:SetActive(false)
      stPanelItemConfig.imageMask:SetActive(false)
      if i < SignMaxNum then
        stPanelItemConfig.already:SetActive(false)
      end
    else
      stPanelItemConfig.imageMask:SetActive(false)
      stPanelItemConfig.nextDay:SetActive(false)
      if i < SignMaxNum then
        stPanelItemConfig.already:SetActive(false)
      end
    end
  end
  for i = iRewardCount + 1, SignMaxNum do
    self.m_vPanelItemConfig[i].panel:SetActive(false)
  end
  if vSignInfoList[iSignNum] then
    self.m_txt_descrption1_Text.text = self.m_stActivity:getLangText(tostring(vSignInfoList[iSignNum].sRewardDesc))
  else
    self.m_txt_descrption1_Text.text = ""
  end
end

function Form_ActivitySevendaysFace:RefreshRemainTime()
  if not self.m_stActivity then
    return
  end
  self:killRemainTimer()
  self.endTime = self.m_stActivity:getActivityEndTime()
  if self.endTime == 0 then
    self.m_PanelRemainTime:SetActive(false)
    return
  end
  self.m_PanelRemainTime:SetActive(true)
  local remainTime = 0 < self.endTime - TimeUtil:GetServerTimeS() and self.endTime - TimeUtil:GetServerTimeS() or 0
  if not remainTime or remainTime <= 0 then
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
    return
  end
  self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(remainTime)
  self.remainTimer = TimeService:SetTimer(1, -1, function()
    remainTime = self.endTime - TimeUtil:GetServerTimeS() > 0 and self.endTime - TimeUtil:GetServerTimeS() or 0
    self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(remainTime)
    if remainTime <= 0 then
      self:killRemainTimer()
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYSEVENDAYSFACE)
    end
  end)
end

function Form_ActivitySevendaysFace:killRemainTimer()
  if self.remainTimer then
    TimeService:KillTimer(self.remainTimer)
    self.remainTimer = nil
  end
end

function Form_ActivitySevendaysFace:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function Form_ActivitySevendaysFace:OnEventUpdateSign(stParam)
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  local activityId = self.m_stActivity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  utils.popUpRewardUI(stParam.vReward)
  self:RefreshReward()
end

function Form_ActivitySevendaysFace:OnEventActivityReload()
  self:RefreshUI()
  self:AutoRequestSign()
end

function Form_ActivitySevendaysFace:OnBtncloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYSEVENDAYSFACE)
end

function Form_ActivitySevendaysFace:IsOpenGuassianBlur()
  return true
end

function Form_ActivitySevendaysFace:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYSEVENDAYSFACE)
end

local fullscreen = true
ActiveLuaUI("Form_ActivitySevendaysFace", Form_ActivitySevendaysFace)
return Form_ActivitySevendaysFace
