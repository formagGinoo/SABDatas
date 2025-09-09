local Form_Push_Gift = class("Form_Push_Gift", require("UI/UIFrames/Form_Push_GiftUI"))
local LockDelay = 1

function Form_Push_Gift:SetInitParam(param)
end

function Form_Push_Gift:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.m_rootTrans = goRoot.transform
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_gift_list_InfinityGrid, "PayStore/PushGiftItem")
  self.mPrefabHelper = self.m_pnl_list_dot:GetComponent("PrefabHelper")
  self.m_gift_list_Btn = self.m_gift_list:GetComponent("ButtonExtensions")
  if self.m_gift_list_Btn then
    self.m_gift_list_Btn.BeginDrag = handler(self, self.OnGiftListBeginDrag)
    self.m_gift_list_Btn.Drag = handler(self, self.OnGiftListDrag)
    self.m_gift_list_Btn.EndDrag = handler(self, self.OnGiftListEndDrag)
  end
  self.m_img_bg_1:SetActive(false)
end

function Form_Push_Gift:OnActive()
  self.super.OnActive(self)
  self.m_cutDownTime = 0
  UILuaHelper.PlayAnimationByName(self.m_Content, "m_pnl_flashsale_list_in")
  self:InitData()
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_Push_Gift:OnInactive()
  self.super.OnInactive(self)
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self.m_cutDownTime = 0
  self:RemoveAllEventListeners()
  if self.m_UILockID then
    UILockIns:Unlock(self.m_UILockID)
    self.m_UILockID = nil
  end
  if self.fSwitchTimer then
    TimeService:KillTimer(self.fSwitchTimer)
    self.fSwitchTimer = nil
  end
end

function Form_Push_Gift:InitData()
  local data = self.m_csui.m_param
  if not (data and data.vPushGiftNew) or not next(data.vPushGiftNew) then
    self:CloseUI()
    return
  end
  local iActivityID = data.iActivityId
  self.m_stActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  self.m_stPushGiftActivity = ActivityManager:GetActivityByID(iActivityID)
  if not self.m_stActivity or not self.m_stPushGiftActivity then
    log.error("error m_stPushGiftActivity  or m_stActivity == nil")
    self:CloseUI()
    return
  end
  self.vPushGiftNew = data.vPushGiftNew
  self.iCurIdx = 1
  self.m_giftData = self.vPushGiftNew[self.iCurIdx]
  self.m_giftDataList = self:GeneratedData()
  self:InitPageDot()
end

function Form_Push_Gift:OnActivityResetData()
  self:InitData()
  self:RefreshUI()
end

function Form_Push_Gift:OnBuyGiftSuccess()
  if not self.vPushGiftNew or #self.vPushGiftNew == 1 then
    self:CloseUI()
    return
  end
  table.remove(self.vPushGiftNew, self.iCurIdx)
  self.iCurIdx = 1
  self.m_giftData = self.vPushGiftNew[self.iCurIdx]
  self.m_giftDataList = self:GeneratedData()
  self:InitPageDot()
  self:RefreshUI()
end

function Form_Push_Gift:AddEventListeners()
  self:addEventListener("eGameEvent_Buy_Gift_Success", handler(self, self.OnBuyGiftSuccess))
  self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnActivityResetData))
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
  if not self.m_stActivity or not self.m_stPushGiftActivity then
    log.error("error m_stPushGiftActivity  or m_stActivity == nil")
    self:CloseUI()
    return
  end
  self.m_ListInfinityGrid:ShowItemList(self.m_giftDataList)
  self.m_ListInfinityGrid:LocateTo(0)
  self.m_cutDownTime = self.m_giftData.iExpireTime - TimeUtil:GetServerTimeS()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self.m_downTimer = TimeService:SetTimer(1, self.m_cutDownTime, function()
    self.m_cutDownTime = self.m_cutDownTime - 1
    if self.m_cutDownTime < 0 then
      TimeService:KillTimer(self.m_downTimer)
      self:CloseUI()
      return
    end
  end)
  local bIsShowDot = #self.vPushGiftNew > 1
  self.m_pnl_list_dot:SetActive(bIsShowDot)
  self.m_btn_arrow_l:SetActive(bIsShowDot)
  self.m_btn_arrow_r:SetActive(bIsShowDot)
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
  self:CloseUI()
  self:broadcastEvent("eGameEvent_Push_Gift_Closed")
end

function Form_Push_Gift:OnBtnBackClicked()
  self:CloseUI()
  self:broadcastEvent("eGameEvent_Push_Gift_Closed")
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
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  if self.m_UILockID then
    UILockIns:Unlock(self.m_UILockID)
    self.m_UILockID = nil
  end
  if self.fSwitchTimer then
    TimeService:KillTimer(self.fSwitchTimer)
    self.fSwitchTimer = nil
  end
end

function Form_Push_Gift:OnGiftListBeginDrag(pointerEventData)
  self.m_draging = true
  if not pointerEventData then
    return
  end
  self.m_startDragPos = pointerEventData.position
end

function Form_Push_Gift:OnGiftListDrag(pointerEventData)
end

function Form_Push_Gift:OnGiftListEndDrag(pointerEventData)
  self.m_draging = false
  if not pointerEventData then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.x - self.m_startDragPos.x
  local absDeltaNum = math.abs(deltaNum)
  if absDeltaNum < 100 then
    return
  end
  if deltaNum < 0 then
    self:OnBtnarrowrClicked()
  else
    self:OnBtnarrowlClicked()
  end
end

function Form_Push_Gift:InitPageDot()
  utils.ShowPrefabHelper(self.mPrefabHelper, function(go, index, data)
    local transform = go.transform
    local node_light = transform:Find("m_img_star_light1").gameObject
    node_light:SetActive(index + 1 == self.iCurIdx)
  end, self.vPushGiftNew)
end

function Form_Push_Gift:OnBtnarrowlClicked()
  if #self.vPushGiftNew <= 1 then
    return
  end
  self.iCurIdx = self.iCurIdx - 1
  if 1 > self.iCurIdx then
    self.iCurIdx = #self.vPushGiftNew
  end
  self.m_giftData = self.vPushGiftNew[self.iCurIdx]
  self.m_giftDataList = self:GeneratedData()
  self:RefreshUI()
  self.mPrefabHelper:Refresh()
  self:PlaySwitchAnimation()
end

function Form_Push_Gift:OnBtnarrowrClicked()
  if #self.vPushGiftNew <= 1 then
    return
  end
  self.iCurIdx = self.iCurIdx + 1
  if self.iCurIdx > #self.vPushGiftNew then
    self.iCurIdx = 1
  end
  self.m_giftData = self.vPushGiftNew[self.iCurIdx]
  self.m_giftDataList = self:GeneratedData()
  self:RefreshUI()
  self.mPrefabHelper:Refresh()
  self:PlaySwitchAnimation()
end

function Form_Push_Gift:PlaySwitchAnimation()
  self.m_img_bg_1:SetActive(true)
  UILuaHelper.PlayAnimationByName(self.m_Content, "m_pnl_flashsale_list_switch")
  local fAniLength = UILuaHelper.GetAnimationLengthByName(self.m_Content, "m_pnl_flashsale_list_switch")
  self.m_UILockID = UILockIns:Lock(fAniLength + LockDelay)
  if self.fSwitchTimer then
    TimeService:KillTimer(self.fSwitchTimer)
    self.fSwitchTimer = nil
  end
  self.fSwitchTimer = TimeService:SetTimer(fAniLength, 1, function()
    if not utils.isNull(self.m_img_bg_1) then
      self.m_img_bg_1:SetActive(false)
    end
    if not utils.isNull(self.m_Content) then
      UILuaHelper.PlayAnimationByName(self.m_Content, "m_pnl_flashsale_list_in")
    end
  end)
end

local fullscreen = true
ActiveLuaUI("Form_Push_Gift", Form_Push_Gift)
return Form_Push_Gift
