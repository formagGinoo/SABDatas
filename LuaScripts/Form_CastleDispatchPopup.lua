local Form_CastleDispatchPopup = class("Form_CastleDispatchPopup", require("UI/UIFrames/Form_CastleDispatchPopupUI"))

function Form_CastleDispatchPopup:SetInitParam(param)
end

function Form_CastleDispatchPopup:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_heroListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_hero_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_heroListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnItemClk))
end

function Form_CastleDispatchPopup:OnActive()
  self.super.OnActive(self)
  local data = self.m_csui.m_param
  self.m_dispatchEvent = data.event
  self.m_dispatchLocation = data.id
  if not self.m_dispatchEvent then
    log.error("Form_CastleDispatchPopup is error serverData is nil")
    return
  end
  self.m_rewardData = nil
  self.m_heroList = {}
  self:RefreshUI()
  self:AddEventListeners()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(199)
end

function Form_CastleDispatchPopup:OnInactive()
  self.super.OnInactive(self)
  self.m_heroList = {}
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self:RemoveAllEventListeners()
  self.m_rewardData = nil
end

function Form_CastleDispatchPopup:AddEventListeners()
  self:addEventListener("eGameEvent_CancelDispatch", handler(self, self.OnCancelBack))
end

function Form_CastleDispatchPopup:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CastleDispatchPopup:RefreshTime()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self.m_cutDownTime = CastleDispatchManager:GetDispatchDurationTimeByData(self.m_dispatchEvent)
  self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_cutDownTime)
  if self.m_cutDownTime > 0 then
    self.m_downTimer = TimeService:SetTimer(1, -1, function()
      self.m_cutDownTime = self.m_cutDownTime - 1
      if self.m_cutDownTime <= 0 then
        self.m_txt_time_Text.text = ""
        self:OnBtnCloseClicked()
        return
      end
      self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_cutDownTime)
    end)
  end
end

function Form_CastleDispatchPopup:RefreshUI()
  local eventCfg = CastleDispatchManager:GetCastleDispatchEventCfg(self.m_dispatchEvent.iGroupId, self.m_dispatchEvent.iEventId)
  if eventCfg then
    local rewardData = utils.changeCSArrayToLuaTable(eventCfg.m_Reward)[1]
    local processData = ResourceUtil:GetProcessRewardData({
      iID = rewardData[1],
      iNum = rewardData[2]
    })
    self.m_rewardData = rewardData
    UILuaHelper.SetAtlasSprite(self.m_icon_item_Image, processData.icon_name, nil, nil, true)
    self.m_txt_time_Text.text = ""
    self.m_txt_star_num_Text.text = eventCfg.m_Grade
    self.m_txt_item_num_Text.text = rewardData[2]
  end
  local locationCfg = CastleDispatchManager:GetCastleDispatchLocationCfg(self.m_dispatchLocation)
  if locationCfg then
    self.m_txt_explore_name_Text.text = locationCfg.m_mDispatchLocation
  end
  self.m_heroList = {}
  for i, v in ipairs(self.m_dispatchEvent.vHero) do
    local data = HeroManager:GetHeroDataByID(v)
    self.m_heroList[#self.m_heroList + 1] = ResourceUtil:GetProcessRewardData({
      iID = data.serverData.iHeroId
    }, data.serverData)
  end
  self.m_heroListInfinityGrid:ShowItemList(self.m_heroList)
  if table.getn(self.m_heroList) > 0 then
    self.m_heroListInfinityGrid:LocateTo(0)
  end
  self:RefreshTime()
end

function Form_CastleDispatchPopup:OnItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_heroList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.heroData.iHeroId,
      heroServerData = chooseFJItemData.heroData
    })
  end
end

function Form_CastleDispatchPopup:OnBtncancelClicked()
  utils.CheckAndPushCommonTips({
    tipsID = 1176,
    func1 = function()
      if self.m_cutDownTime <= 0 then
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45010)
        self:OnBtnCloseClicked()
        self:broadcastEvent("eGameEvent_CancelDispatch")
        return
      end
      CastleDispatchManager:ReqCancelDispatch(self.m_dispatchLocation)
    end
  })
end

function Form_CastleDispatchPopup:OnIconitemClicked()
  if self.m_rewardData and self.m_rewardData[1] then
    utils.openItemDetailPop({
      iID = self.m_rewardData[1],
      iNum = self.m_rewardData[2]
    })
  end
end

function Form_CastleDispatchPopup:OnCancelBack()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45002)
  self:OnBtnCloseClicked()
end

function Form_CastleDispatchPopup:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_CastleDispatchPopup:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_CastleDispatchPopup:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleDispatchPopup:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleDispatchPopup", Form_CastleDispatchPopup)
return Form_CastleDispatchPopup
