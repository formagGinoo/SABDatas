local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ActivitySevenDaysSubPanel_ByMain = class("ActivitySevenDaysSubPanel_ByMain", UISubPanelBase)
local SignMaxNum = 7
local Big_Reward = 2
local MaxRewardNumOneDay = 3
local spineStr = "saint_base"

function ActivitySevenDaysSubPanel_ByMain:OnInit()
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
  self.remainTimer = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
end

function ActivitySevenDaysSubPanel_ByMain:AddEventListeners()
  self.m_iHandlerIDUpdateSign = self:addEventListener("eGameEvent_Activity_Sign_UpdateSign", handler(self, self.OnEventUpdateSign))
  self.m_iHandlerIDReload = self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
end

function ActivitySevenDaysSubPanel_ByMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function ActivitySevenDaysSubPanel_ByMain:OnFreshData()
  self:RemoveAllEventListeners()
  self:AddEventListeners()
  self:RefreshUI()
  self:AutoRequestSign()
end

function ActivitySevenDaysSubPanel_ByMain:OnEventUpdateSign(stParam)
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  PushFaceManager:RemoveShowPopPanelList(UIDefines.ID_FORM_ACTIVITYSEVENDAYSFACE, self.m_stActivity:getSubPanelName())
  if self.m_rootObj.activeInHierarchy then
    utils.popUpRewardUI(stParam.vReward)
    self:RefreshReward()
    if self.m_parentLua then
      self.m_parentLua:RefreshTableButtonList()
    end
  end
end

function ActivitySevenDaysSubPanel_ByMain:OnEventActivityReload()
  if self.m_rootObj.activeInHierarchy then
    self:RefreshUI()
    self:AutoRequestSign()
  end
end

function ActivitySevenDaysSubPanel_ByMain:AutoRequestSign()
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

function ActivitySevenDaysSubPanel_ByMain:RefreshUI()
  local activityId = self.m_panelData.activity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  if not self.m_stActivity then
    return
  end
  self:RefreshReward()
  self:RefreshRemainTime()
  self:LoadHeroSpine()
end

function ActivitySevenDaysSubPanel_ByMain:LoadHeroSpine()
  if not spineStr then
    return
  end
  self:DestroySpine()
  self.m_HeroSpineDynamicLoader:GetObjectByName(spineStr, function(backStr, spineSomethingObj)
    self:DestroySpine()
    self.m_curHeroSpineObj = spineSomethingObj
    self.m_heroSpineStr = backStr
    UILuaHelper.SetParent(self.m_curHeroSpineObj, self.m_root_spine, true)
    UILuaHelper.SetActive(self.m_curHeroSpineObj, true)
    UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
  end)
end

function ActivitySevenDaysSubPanel_ByMain:DestroySpine()
  if self.m_curHeroSpineObj and self.m_heroSpineStr then
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(self.m_heroSpineStr, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
    self.m_heroSpineStr = nil
  end
end

function ActivitySevenDaysSubPanel_ByMain:RefreshReward()
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

function ActivitySevenDaysSubPanel_ByMain:RefreshRemainTime()
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
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
    end
  end)
end

function ActivitySevenDaysSubPanel_ByMain:killRemainTimer()
  if self.remainTimer then
    TimeService:KillTimer(self.remainTimer)
    self.remainTimer = nil
  end
end

function ActivitySevenDaysSubPanel_ByMain:OnInactive()
  self:RemoveAllEventListeners()
  self:killRemainTimer()
end

function ActivitySevenDaysSubPanel_ByMain:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function ActivitySevenDaysSubPanel_ByMain:GetDownloadResourceExtra()
  local spineStr = "saint_base"
  local vPackage = {}
  local vResourceExtra = {}
  if spineStr then
    vResourceExtra[#vResourceExtra + 1] = {
      sName = spineStr,
      eType = DownloadManager.ResourceType.UI
    }
  end
  return vPackage, vResourceExtra
end

return ActivitySevenDaysSubPanel_ByMain
