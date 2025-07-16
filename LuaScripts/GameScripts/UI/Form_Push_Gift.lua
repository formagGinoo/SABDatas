local Form_Push_Gift = class("Form_Push_Gift", require("UI/UIFrames/Form_Push_GiftUI"))

function Form_Push_Gift:SetInitParam(param)
end

function Form_Push_Gift:AfterInit()
  self.super.AfterInit(self)
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_gift_list_InfinityGrid, "PayStore/PushGiftItem")
end

function Form_Push_Gift:OnActive()
  self.super.OnActive(self)
  self.m_cutDownTime = 0
  self.m_giftData = self.m_csui.m_param
  self.m_stActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  self.m_stPushGiftActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PushGift)
  if not self.m_stActivity or not self.m_stPushGiftActivity then
    log.error("error m_stPushGiftActivity  or m_stActivity == nil")
    self:CloseUI()
    return
  end
  self.m_giftDataList = self:GeneratedData()
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_Push_Gift:OnInactive()
  self.super.OnInactive(self)
  TimeService:KillTimer(self.m_downTimer)
  self.m_cutDownTime = 0
  self:RemoveAllEventListeners()
end

function Form_Push_Gift:AddEventListeners()
  self:addEventListener("eGameEvent_Buy_Gift_Success", handler(self, self.CloseUI))
end

function Form_Push_Gift:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Push_Gift:GeneratedData()
  local data = self.m_stPushGiftActivity:GetGiftGroupDataByGroupIndex(self.m_giftData.iGroupIndex)
  local store = self.m_stActivity:GetPushStoreConfigByType(MTTDProto.CmdActPayStoreType_PushGift)
  if not store then
    self:CloseUI()
    return
  end
  local mGoods = data.stPushGoodsConfig.mGoods
  local goodsTab = {}
  for _, index in ipairs(self.m_giftData.vGiftIndex) do
    goodsTab[#goodsTab + 1] = mGoods[index]
  end
  
  local function sortFunc(data1, data2)
    return data1.iGiftIndex < data2.iGiftIndex
  end
  
  table.sort(goodsTab, sortFunc)
  local iconTab = string.split(data.sIcon, ";")
  for p = 1, #goodsTab do
    goodsTab[p].sIcon = iconTab[p]
    goodsTab[p].iSubProductID = self.m_giftData.iSubProductID
    goodsTab[p].iStoreId = store.iStoreId
    goodsTab[p].iExpireTime = self.m_giftData.iExpireTime
    goodsTab[p].iTriggerParam = self.m_giftData.iTriggerParam
    goodsTab[p].iTotalRecharge = self.m_giftData.iTotalRecharge
    goodsTab[p].iTriggerIndex = self.m_giftData.iGroupIndex
    goodsTab[p].giftPushForm = "Form_Push_Gift"
    goodsTab[p].sortIndex = p
  end
  return goodsTab
end

function Form_Push_Gift:RefreshUI()
  self.m_ListInfinityGrid:ShowItemList(self.m_giftDataList)
  self.m_ListInfinityGrid:LocateTo(0)
  self.m_cutDownTime = self.m_giftData.iExpireTime - TimeUtil:GetServerTimeS()
  self.m_txt_frame_leftnum_Text.text = self:SecondToTimeText(self.m_cutDownTime)
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self.m_downTimer = TimeService:SetTimer(self.m_cutDownTime, -1, function()
    self.m_cutDownTime = self.m_cutDownTime - 1
    if self.m_cutDownTime < 0 then
      TimeService:KillTimer(self.m_downTimer)
      self:CloseUI()
      return
    end
    self.m_txt_frame_leftnum_Text.text = TimeUtil:SecondToTimeText(self.m_cutDownTime)
  end)
end

function Form_Push_Gift:SecondToTimeText(second)
  if second <= 0 then
    return ""
  end
  local timeTb = TimeUtil:SecondsToFourUnit(second)
  if 0 <= timeTb.day or 0 <= timeTb.hour or 0 < timeTb.min then
    local day_str = UnlockSystemUtil:GetLockClientMessage(10305)
    local min = timeTb.day * 24 + timeTb.hour * 60 + timeTb.min
    return string.gsubNumberReplace(day_str, min)
  elseif timeTb.day == 0 and timeTb.hour == 0 and timeTb.min == 0 then
    local day_str = UnlockSystemUtil:GetLockClientMessage(10216)
    return string.gsubNumberReplace(day_str, timeTb.sec)
  end
end

function Form_Push_Gift:OnBtnCloseClicked()
  utils.popUpDirectionsUI({
    tipsID = 1137,
    func1 = function()
      self:CloseUI()
    end
  })
end

function Form_Push_Gift:CloseUI()
  if self and self.m_csui then
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    self:CloseForm()
    PushFaceManager:CheckShowNextPopPanel()
  end
end

function Form_Push_Gift:IsOpenGuassianBlur()
  return true
end

function Form_Push_Gift:OnDestroy()
  self.super.OnDestroy(self)
  TimeService:KillTimer(self.m_downTimer)
end

local fullscreen = true
ActiveLuaUI("Form_Push_Gift", Form_Push_Gift)
return Form_Push_Gift
