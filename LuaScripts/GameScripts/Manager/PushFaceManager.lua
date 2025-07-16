local BaseManager = require("Manager/Base/BaseManager")
local PushFaceManager = class("PushFaceManager", BaseManager)
local PopPanelCfg = {
  PopUpLevel = {
    FormID = UIDefines.ID_FORM_POPUPLEVEL,
    SortNum = 1,
    paramData = nil
  },
  PopSystemUnlock = {
    FormID = UIDefines.ID_FORM_POPUPUNLOCK,
    SortNum = 999,
    paramData = nil
  },
  PopSystemHangUpLevelUP = {
    FormID = UIDefines.ID_FORM_HANGUPLEVELUP,
    SortNum = 2,
    paramData = nil
  },
  HeroShow = {
    FormID = UIDefines.ID_FORM_HEROSHOW,
    SortNum = 1,
    paramData = nil
  },
  CommonRewardShow = {
    FormID = UIDefines.ID_FORM_POPUPRECEIVE,
    SortNum = 2,
    paramData = nil
  },
  ActivitySevenDay = {
    FormID = UIDefines.ID_FORM_ACTIVITYSEVENDAYSFACE,
    SortNum = 103,
    paramData = nil,
    onlyDisplayInLobby = true
  },
  ActivityFourteenDay = {
    FormID = UIDefines.ID_FORM_ACTIVITYFOURTEENDAYSFACE,
    SortNum = 104,
    paramData = nil,
    onlyDisplayInLobby = true
  },
  MonthlyCardDailyReward = {
    FormID = UIDefines.ID_FORM_MALLMONTHCARDTIPS,
    SortNum = 101,
    paramData = true
  },
  AnnouncementPanel = {
    FormID = UIDefines.ID_FORM_ACTIVITYANNOUNCELOTTERYPAGE,
    SortNum = 100,
    paramData = true,
    onlyDisplayInLobby = true
  },
  PushGift = {
    FormID = UIDefines.ID_FORM_PUSH_GIFT,
    SortNum = 107,
    paramData = nil,
    onlyDisplayInLobby = true,
    iActivityType = "ActivityType_PushGift"
  },
  JumpFace = {
    FormID = UIDefines.ID_FORM_ACTIVITYFACEMAIN,
    SortNum = 106,
    paramData = nil,
    onlyDisplayInLobby = true
  },
  HeroActSign = {
    FormID = nil,
    SortNum = 102,
    paramData = nil,
    onlyDisplayInLobby = true
  },
  EmergencyGift = {
    FormID = UIDefines.ID_FORM_PUSH_GIFT_RESERVE,
    SortNum = 107,
    paramData = nil
  }
}

function PushFaceManager:OnCreate()
  self:AddEventListeners()
  self.m_showPopPanelList = {}
  self.m_isInShowPanel = false
  self.m_rewardPopPanelList = {}
  self.m_isInShowRewardPanel = false
  self.m_curShowPanelId = -1
end

function PushFaceManager:OnUpdate(dt)
end

function PushFaceManager:AddShowPopPanelList(popPanelCfg)
  if not popPanelCfg then
    return
  end
  local popCfg = table.deepcopy(popPanelCfg)
  local isInsert = false
  for i, v in ipairs(self.m_showPopPanelList) do
    if popPanelCfg.SortNum < v.SortNum then
      table.insert(self.m_showPopPanelList, i, popCfg)
      isInsert = true
      break
    end
  end
  if isInsert ~= true then
    self.m_showPopPanelList[#self.m_showPopPanelList + 1] = popCfg
  end
end

function PushFaceManager:RemoveShowPopPanelList(popPanelId, param)
  if not (popPanelId and self.m_showPopPanelList) or type(self.m_showPopPanelList) ~= "table" then
    return
  end
  for i = #self.m_showPopPanelList, 1, -1 do
    local panel = self.m_showPopPanelList[i]
    if panel and panel.FormID == popPanelId and (param == nil or self:IsValueEqual(panel.paramData, param)) then
      table.remove(self.m_showPopPanelList, i)
    end
  end
end

function PushFaceManager:AddEventListeners()
  self:addEventListener("eGameEvent_Role_SetLevel", handler(self, self.OnRoleSetLevel))
  self:addEventListener("eGameEvent_PopupUnlockSystem", handler(self, self.OnUnlockSystem))
  self:addEventListener("eGameEvent_HallPopupUnlockSystem", handler(self, self.CheckNotPopAndNotCacheUI))
  self:addEventListener("eGameEvent_HangUp_LevelChanged", handler(self, self.OnHangUpLevelUpSystem))
  self:addEventListener("eGameEvent_ActivityDailyLogin", handler(self, self.OnActivityDailyLogin))
  self:addEventListener("eGameEvent_MonthlyCardDailyReward", handler(self, self.OnMonthlyCardDailyReward))
  self:addEventListener("eGameEvent_UnReadAccountment", handler(self, self.OnUnReadAccountment))
  self:addEventListener("eGameEvent_GetCommonReward", handler(self, self.OnGetCommonReward))
  self:addEventListener("eGameEvent_Push_Gift", handler(self, self.OnPushGift))
  self:addEventListener("eGameEvent_JumpFaceActivity", handler(self, self.OnPushJumpFace))
  self:addEventListener("eGameEvent_HeroActSign", handler(self, self.OnPushHeroActSign))
  self:addEventListener("eGameEvent_EmergencyGiftPushFace", handler(self, self.OnPushEmergencyGift))
end

function PushFaceManager:OnHangUpLevelUpSystem(param)
  if not param then
    return
  end
  if not UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AFK) then
    return
  end
  self:PushFacePanel("PopSystemHangUpLevelUP", param)
  self:CheckIsNotShowAndPopPanel()
end

function PushFaceManager:OnPushJumpFace(param)
  if not param then
    return
  end
  self:PushFacePanel("JumpFace", param)
  self:CheckIsNotShowAndPopPanel()
end

function PushFaceManager:OnPushEmergencyGift(param)
  if not param then
    return
  end
  self:PushFacePanel("EmergencyGift", param)
  self:CheckIsNotShowAndPopPanel()
end

function PushFaceManager:OnPushHeroActSign(param)
  if not param then
    return
  end
  self:PushFacePanel("HeroActSign", param)
  self:CheckIsNotShowAndPopPanel()
end

function PushFaceManager:OnRoleSetLevel(param)
  if not param then
    return
  end
  self:PushFacePanel("PopUpLevel", param)
  self:CheckIsNotShowAndPopPanel()
end

function PushFaceManager:CheckNotPopAndNotCacheUI(param)
  local unlockList = {}
  for i, systemId in ipairs(param) do
    local id = systemId
    for _, v in ipairs(self.m_showPopPanelList) do
      if v.paramData and type(v.paramData) == "number" and systemId == v.paramData then
        id = nil
      end
    end
    if id then
      unlockList[#unlockList + 1] = id
    end
  end
  self:OnUnlockSystem(unlockList)
end

function PushFaceManager:OnUnlockSystem(param)
  if not param then
    return
  end
  for i, v in pairs(param) do
    if v == GlobalConfig.SYSTEM_ID.Notice then
      self:PushFacePanel("AnnouncementPanel")
      UnlockManager:ReqSetClientData(v)
    else
      self:PushFacePanel("PopSystemUnlock", v)
    end
  end
  self:CheckIsNotShowAndPopPanel()
end

function PushFaceManager:OnUnReadAccountment()
  if self:CheckIsCanAdd("AnnouncementPanel") then
    self:PushFacePanel("AnnouncementPanel")
    self:CheckIsNotShowAndPopPanel()
  end
end

function PushFaceManager:OnActivityDailyLogin(param)
  if not param then
    return
  end
  if param == ActivityManager.ActivitySubPanelName.ActivitySPName_Sign7 then
    if self:CheckIsCanAdd("ActivitySevenDay") then
      self:PushFacePanel("ActivitySevenDay", param)
      self:CheckIsNotShowAndPopPanel()
    end
  elseif self:CheckIsCanAdd("ActivityFourteenDay") then
    self:PushFacePanel("ActivityFourteenDay", param)
    self:CheckIsNotShowAndPopPanel()
  end
end

function PushFaceManager:CheckIsCanAdd(CfgStr)
  if not PopPanelCfg[CfgStr] then
    return false
  end
  for _, v in ipairs(self.m_showPopPanelList) do
    if v.FormID == PopPanelCfg[CfgStr].FormID then
      return false
    end
  end
  if PopPanelCfg[CfgStr].FormID == self.m_curShowPanelId then
    return false
  end
  return true
end

function PushFaceManager:OnMonthlyCardDailyReward()
  self:PushFacePanel("MonthlyCardDailyReward")
  self:CheckIsNotShowAndPopPanel()
end

function PushFaceManager:OnPushGift(param)
  self:PushFacePanel("PushGift", param)
  self:CheckIsNotShowAndPopPanel()
end

function PushFaceManager:OnNewHero(param)
  if not param then
    return
  end
  local vPackage = {}
  local vHeroID = {}
  if param.vHeroID then
    vHeroID = param.vHeroID
  elseif param.iHeroID then
    vHeroID[#vHeroID + 1] = param.iHeroID
  end
  for i = 1, #vHeroID do
    local iHeroID = vHeroID[i]
    vPackage[#vPackage + 1] = {
      sName = tostring(iHeroID),
      eType = DownloadManager.ResourcePackageType.Character
    }
  end
  
  local function OnDownloadComplete(ret)
    log.info(string.format("Download NewHero %s Complete: %s", table.serialize(vHeroID), tostring(ret)))
    for i = 1, #vHeroID do
      local iHeroID = vHeroID[i]
      self:PushRewardFacePanel("HeroShow", {heroID = iHeroID})
    end
    self:CheckIsNotShowAndPopRewardPanel()
  end
  
  DownloadManager:DownloadResourceWithUI(vPackage, nil, "NewHero_" .. table.concat(vHeroID, "_"), nil, nil, OnDownloadComplete, nil, DownloadManager.NetworkStatus.Mobile)
end

function PushFaceManager:OnGetCommonReward(param)
  if not param then
    return
  end
  self:PushRewardFacePanel("CommonRewardShow", param)
  self:CheckIsNotShowAndPopRewardPanel()
end

function PushFaceManager:PushFacePanel(popParamStr, paramData)
  if not popParamStr then
    return
  end
  local tempPopPanelCfg = PopPanelCfg[popParamStr]
  if not tempPopPanelCfg then
    return
  end
  tempPopPanelCfg.paramData = paramData
  self:AddShowPopPanelList(tempPopPanelCfg)
end

function PushFaceManager:CheckClearPopPanelStatus()
  if not self.m_isInShowPanel then
    return
  end
  local uiInfo = StackFlow:GetTopUI()
  if utils.isNull(uiInfo) then
    return
  end
  local name = uiInfo:GetFramePrefabName()
  if name ~= "Form_Hall" then
    return
  end
  self.m_isInShowPanel = false
end

function PushFaceManager:CheckIsNotShowAndPopPanel()
  if self.m_isInShowPanel then
    return
  end
  local formHall = CS.UI.UILuaHelper.GetRootUI("Form_Hall")
  local formBattleWin = CS.UI.UILuaHelper.GetRootUI("Form_BattleVictory")
  if formHall ~= nil or formBattleWin ~= nil then
    self:CheckShowNextPopPanel()
  end
end

function PushFaceManager:CheckShowNextPopPanel()
  if #self.m_showPopPanelList == 0 then
    self.m_isInShowPanel = false
    self.m_curShowPanelId = -1
    return
  end
  local firstShowPopPanelCfg = self.m_showPopPanelList[1]
  if firstShowPopPanelCfg.onlyDisplayInLobby then
    local uiInfo = StackFlow:GetTopUI()
    if not utils.isNull(uiInfo) then
      local name = uiInfo:GetFramePrefabName()
      if name ~= "Form_Hall" then
        self.m_isInShowPanel = false
        return
      end
    end
  end
  if firstShowPopPanelCfg then
    local canShow = self:CheckActivityCanShowByType(firstShowPopPanelCfg)
    if canShow then
      if firstShowPopPanelCfg.FormID == UIDefines.ID_FORM_POPUPUNLOCK or firstShowPopPanelCfg.FormID == UIDefines.ID_FORM_ACTIVITYANNOUNCELOTTERYPAGE then
        StackFlow:Push(firstShowPopPanelCfg.FormID, firstShowPopPanelCfg.paramData)
        self.m_curShowPanelId = firstShowPopPanelCfg.FormID
      elseif firstShowPopPanelCfg.FormID then
        StackPopup:Push(firstShowPopPanelCfg.FormID, firstShowPopPanelCfg.paramData)
        self.m_curShowPanelId = firstShowPopPanelCfg.FormID
      else
        StackPopup:Push(firstShowPopPanelCfg.paramData.FormID, firstShowPopPanelCfg.paramData)
        self.m_curShowPanelId = firstShowPopPanelCfg.paramData.FormID
      end
    end
    table.remove(self.m_showPopPanelList, 1)
    self.m_isInShowPanel = true
  end
end

function PushFaceManager:PushRewardFacePanel(popParamStr, paramData)
  if not popParamStr then
    return
  end
  local tempPopPanelCfg = PopPanelCfg[popParamStr]
  if not tempPopPanelCfg then
    return
  end
  tempPopPanelCfg.paramData = paramData
  self:AddShowRewardPopPanelList(tempPopPanelCfg)
end

function PushFaceManager:AddShowRewardPopPanelList(popPanelCfg)
  if not popPanelCfg then
    return
  end
  local popCfg = table.deepcopy(popPanelCfg)
  local isInsert = false
  for i, v in ipairs(self.m_rewardPopPanelList) do
    if popPanelCfg.SortNum < v.SortNum then
      table.insert(self.m_rewardPopPanelList, i, popCfg)
      isInsert = true
      break
    end
  end
  if isInsert ~= true then
    self.m_rewardPopPanelList[#self.m_rewardPopPanelList + 1] = popCfg
  end
end

function PushFaceManager:CheckIsNotShowAndPopRewardPanel()
  if self.m_isInShowRewardPanel then
    return
  end
  self:CheckShowNextPopRewardPanel()
end

function PushFaceManager:CheckShowNextPopRewardPanel()
  if #self.m_rewardPopPanelList == 0 then
    self.m_isInShowRewardPanel = false
    return
  end
  local firstShowPopPanelCfg = self.m_rewardPopPanelList[1]
  if firstShowPopPanelCfg then
    StackPopup:Push(firstShowPopPanelCfg.FormID, firstShowPopPanelCfg.paramData)
    table.remove(self.m_rewardPopPanelList, 1)
    self.m_isInShowRewardPanel = true
  end
end

function PushFaceManager:CheckActivityCanShowByType(popPanelCfg)
  local canShow = true
  if popPanelCfg and popPanelCfg.iActivityType and MTTD then
    local activity = ActivityManager:GetActivityByType(MTTD[popPanelCfg.iActivityType])
    if activity == nil or activity.isInActivityShowTime and not activity:isInActivityShowTime() then
      canShow = false
    end
  end
  if popPanelCfg and not popPanelCfg.FormID and popPanelCfg.paramData.main_id then
    local subID = HeroActivityManager:GetSubFuncID(popPanelCfg.paramData.main_id, HeroActivityManager.SubActTypeEnum.Sign)
    local unlock_flag = HeroActivityManager:IsSubActIsOpenByID(popPanelCfg.paramData.main_id, subID)
    if not unlock_flag then
      canShow = false
    end
  end
  return canShow
end

function PushFaceManager:CheckClearRewardPopList(isNeedPopReward)
  if isNeedPopReward then
    self:CheckShowNextPopRewardPanel()
  else
    self.m_rewardPopPanelList = {}
    self.m_isInShowRewardPanel = false
  end
end

function PushFaceManager:IsValueEqual(value1, value2, visited)
  visited = visited or {}
  if type(value1) ~= type(value2) then
    return false
  end
  if type(value1) == "table" then
    if visited[value1] and visited[value1] == value2 then
      return true
    end
    visited[value1] = value2
    for k, v in pairs(value1) do
      if not self:IsValueEqual(v, value2[k], visited) then
        return false
      end
    end
    for k, v in pairs(value2) do
      if value1[k] == nil then
        return false
      end
    end
    return true
  else
    return value1 == value2
  end
  return false
end

return PushFaceManager
