local Form_ActivityDailyLogin = class("Form_ActivityDailyLogin", require("UI/UIFrames/Form_ActivityDailyLoginUI"))
local SignMaxNum = 7
local Big_Reward = 2

function Form_ActivityDailyLogin:SetInitParam(param)
end

function Form_ActivityDailyLogin:AfterInit()
  self.m_vPanelItemConfig = {}
  for i = 1, SignMaxNum do
    self.m_vPanelItemConfig[i] = {}
    self.m_vPanelItemConfig[i].panel = self[string.format("m_item_%02d", i)]
    self.m_vPanelItemConfig[i].panelItemIcon = self.m_vPanelItemConfig[i].panel.transform:Find("c_common_item").gameObject
    self.m_vPanelItemConfig[i].textDay = self.m_vPanelItemConfig[i].panel.transform:Find("c_txt_day").gameObject
    self.m_vPanelItemConfig[i].imageMask = self.m_vPanelItemConfig[i].panel.transform:Find("c_img_mask").gameObject
    self.m_vPanelItemConfig[i].imageReceive = self.m_vPanelItemConfig[i].panel.transform:Find("c_item_receive").gameObject
    self.m_vPanelItemConfig[i].nextDay = self.m_vPanelItemConfig[i].panel.transform:Find("c_nextday").gameObject
  end
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBtnCloseClicked))
end

function Form_ActivityDailyLogin:OnActive()
  self.super.OnActive(self)
  self:RefreshUI()
  self:RemoveEventListeners()
  self.m_iHandlerIDUpdateSign = self:addEventListener("eGameEvent_Activity_Sign_UpdateSign", handler(self, self.OnEventUpdateSign))
  self.m_iHandlerIDReload = self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
  GlobalManagerIns:TriggerWwiseBGMState(33)
end

function Form_ActivityDailyLogin:AutoRequestSign()
  local iSignNum = self.m_stActivity:GetSignNum()
  local bSignToday = self.m_stActivity:IsSignToday()
  local vSignInfoList = self.m_stActivity:GetSignInfoList()
  if not bSignToday and iSignNum < #vSignInfoList then
    local stSignInfo = vSignInfoList[iSignNum + 1]
    self.m_stActivity:RequestSign(stSignInfo.iIndex)
  end
end

function Form_ActivityDailyLogin:OnActiveTransitionDone()
  self:AutoRequestSign()
end

function Form_ActivityDailyLogin:RefreshUI()
  self.m_stActivity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_Sign)
  if self.m_stActivity == nil then
    StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYDAILYLOGIN)
    return
  end
  self:RefreshReward()
  self:RefreshRemainTime()
end

function Form_ActivityDailyLogin:RemoveEventListeners()
  if self.m_iHandlerIDUpdateSign then
    self:removeEventListener("eGameEvent_Activity_Sign_UpdateSign", self.m_iHandlerIDUpdateSign)
    self.m_iHandlerIDUpdateSign = nil
  end
  if self.m_iHandlerIDReload then
    self:removeEventListener("eGameEvent_Activity_Reload", self.m_iHandlerIDReload)
    self.m_iHandlerIDReload = nil
  end
end

function Form_ActivityDailyLogin:OnInactive()
  self:RemoveEventListeners()
end

function Form_ActivityDailyLogin:OnUpdate(dt)
  self:RefreshRemainTime()
end

function Form_ActivityDailyLogin:RefreshReward()
  local iSignNum = self.m_stActivity:GetSignNum()
  local bSignToday = self.m_stActivity:IsSignToday()
  local vSignInfoList = self.m_stActivity:GetSignInfoList()
  local iRewardCount = math.min(#vSignInfoList, SignMaxNum)
  for i = 1, iRewardCount do
    local stSignInfo = vSignInfoList[i]
    local stPanelItemConfig = self.m_vPanelItemConfig[i]
    stPanelItemConfig.panel:SetActive(true)
    if stPanelItemConfig.widgetItemIcon == nil then
      stPanelItemConfig.widgetItemIcon = self:createCommonItem(stPanelItemConfig.panelItemIcon)
    end
    local iItemNum = stSignInfo.bShowCount and stSignInfo.stRewardInfo.iNum or nil
    local processData = ResourceUtil:GetProcessRewardData({
      iID = stSignInfo.stRewardInfo.iID,
      iNum = iItemNum
    })
    stPanelItemConfig.widgetItemIcon:SetItemInfo(processData)
    stPanelItemConfig.textDay:GetComponent(T_TextMeshProUGUI).text = string.format("%02d", i)
    if i <= iSignNum then
      stPanelItemConfig.imageMask:SetActive(true)
      stPanelItemConfig.imageReceive:SetActive(true)
      stPanelItemConfig.widgetItemIcon:SetItemIconClickCB(handler(self, self.ShowItemTips))
      stPanelItemConfig.nextDay:SetActive(false)
    elseif i == iSignNum + 1 and not bSignToday then
      stPanelItemConfig.imageMask:SetActive(false)
      stPanelItemConfig.imageReceive:SetActive(false)
      stPanelItemConfig.nextDay:SetActive(false)
    elseif i == iSignNum + 1 and bSignToday then
      stPanelItemConfig.nextDay:SetActive(true)
      stPanelItemConfig.imageMask:SetActive(false)
      stPanelItemConfig.imageReceive:SetActive(false)
      stPanelItemConfig.widgetItemIcon:SetItemIconClickCB(handler(self, self.ShowItemTips))
    else
      stPanelItemConfig.imageMask:SetActive(false)
      stPanelItemConfig.imageReceive:SetActive(false)
      stPanelItemConfig.nextDay:SetActive(false)
      stPanelItemConfig.widgetItemIcon:SetItemIconClickCB(handler(self, self.ShowItemTips))
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

function Form_ActivityDailyLogin:RefreshRemainTime()
  if not self.m_stActivity then
    return
  end
  self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_stActivity:getActivityRemainTime())
end

function Form_ActivityDailyLogin:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function Form_ActivityDailyLogin:OnBtnherocheckClicked()
  local vSignInfoList = self.m_stActivity:GetSignInfoList()
  if vSignInfoList and next(vSignInfoList) then
    local stSignInfo = vSignInfoList[Big_Reward]
    if stSignInfo and stSignInfo.stRewardInfo then
      utils.openItemDetailPop({
        iID = stSignInfo.stRewardInfo.iID,
        iNum = 0
      })
    end
  end
end

function Form_ActivityDailyLogin:OnEventUpdateSign(stParam)
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  if #stParam.vCharacter > 0 then
  else
    utils.popUpRewardUI(stParam.vReward)
  end
  self:RefreshReward()
end

function Form_ActivityDailyLogin:OnEventActivityReload()
  self:RefreshUI()
  self:AutoRequestSign()
end

function Form_ActivityDailyLogin:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYDAILYLOGIN)
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_ActivityDailyLogin:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ActivityDailyLogin", Form_ActivityDailyLogin)
return Form_ActivityDailyLogin
