local Form_Push_StageGift = class("Form_Push_StageGift", require("UI/UIFrames/Form_Push_StageGiftUI"))

function Form_Push_StageGift:SetInitParam(param)
end

function Form_Push_StageGift:AfterInit()
  self.super.AfterInit(self)
  local itemData = {
    itemClkBackFun = handler(self, self.OnGiftItemClk)
  }
  self.m_giftListGrid = require("UI/Common/UIInfinityGrid").new(self.m_buy_list_InfinityGrid, "HallActivity/StageGiftItem", itemData)
  self.m_giftListGrid:RegisterButtonCallback("c_btn_buy", handler(self, self.OnEmptyItemClk))
  self.m_iTimeDurationOneSecond = 0
end

function Form_Push_StageGift:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_PushStageGift", handler(self, self.FreshUI))
  self:addEventListener("eGameEvent_IAPDeliveryOnCloseRewardUI", handler(self, self.OnCloseRewardUI))
end

function Form_Push_StageGift:OnCloseRewardUI()
  if self.m_giftListGrid == nil then
    return
  end
  if self.star_sequence then
    self.star_sequence:Kill()
    self.star_sequence = nil
  end
  local rewardItem = self.m_giftListGrid:GetShowItemByIndex(self.invalidIndex)
  local showItem = self.m_giftListGrid:GetShowItemByIndex(self.invalidIndex + 1)
  if showItem then
    showItem:ShowEffect()
  end
  if rewardItem and rewardItem.m_itemData and rewardItem.m_itemData.giftData and rewardItem.m_itemData.giftData.iScore > 0 then
    self.m_uifx_trail_star:SetActive(true)
    self.m_uifx_trail_star.transform.position = rewardItem.m_icon_giftnum.transform.position
    local startPos = rewardItem.m_icon_giftnum.transform.position
    local targetPos = self.m_txt_receivenum.transform.position + Vector3(-0.8, 0, 0)
    local midHeight = (startPos.y + targetPos.y) / 2 + (startPos.y - targetPos.y) * 0.2
    local pathPoints = {
      startPos,
      Vector3((startPos.x + targetPos.x) / 2, midHeight, (startPos.z + targetPos.z) / 2),
      targetPos
    }
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(self.m_uifx_trail_star.transform:DOPath(pathPoints, 1.1, Tweening.PathType.CatmullRom))
    sequence:OnComplete(function()
      self.m_uifx_trail_star:SetActive(false)
    end)
    sequence:SetAutoKill(true)
    self.star_sequence = sequence
  end
end

function Form_Push_StageGift:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Push_StageGift:OnEmptyItemClk(index, go)
  local itemIndex = index + 1
  local config = self.m_giftListData[itemIndex].giftData
  if self.m_giftListData[itemIndex].index - 1 > self.m_giftListData[itemIndex].goodStatus then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 52014)
    return
  end
  if self.m_giftListData[itemIndex].index - 1 < self.m_giftListData[itemIndex].goodStatus then
    return
  end
  if config.sProductId == "" then
    self:BuyFreeGiftPackage(config, self.act)
  else
    self:BuyGiftPackage(self.m_giftListData[itemIndex].giftData, self.act)
  end
end

function Form_Push_StageGift:OnGiftItemClk(index, isLock)
end

function Form_Push_StageGift:FreshUI()
  local act = ActivityManager:GetActivityByType(MTTD.ActivityType_LimitChainGift)
  if act == nil then
    self:CloseForm()
    return
  end
  self.act = act
  local priorgroup = self.act:GetOpenGroup()
  self.totalScore = 0
  self.hasRewarded = true
  if priorgroup then
    local dataList = priorgroup.mGiftGoodsCfg.mGoods
    local invalidIndex = #self.act.stGroupInfo.GoodsState
    local goods = self.act.stGroupInfo.GoodsState
    self.hasRewarded = self.act.stGroupInfo.bScoreRewarded
    local totalScore = priorgroup.iTotalScore
    local curScore = 0
    local sortList = {}
    for index = 1, #dataList do
      if goods[index] and goods[index] == 1 then
        curScore = curScore + (dataList[index] and dataList[index].iScore or 0)
      end
      sortList[index] = {
        index = index,
        giftData = dataList[index] or nil,
        goodStatus = invalidIndex
      }
    end
    self.m_txt_receivenum_Text.text = curScore .. "/" .. totalScore
    self.m_giftListData = sortList
    self.m_giftListGrid:ShowItemList(sortList)
    self.m_txt_title_num_shadow01_Text.text = priorgroup.sValueForMoney .. "%"
    self.m_img_bg_receive_light:SetActive(totalScore <= curScore and not self.hasRewarded)
    self.totalScore = totalScore
    self.curScore = curScore
    self.m_giftListGrid:LocateTo(invalidIndex - 1)
    self.invalidIndex = invalidIndex
    if priorgroup.vScoreReward and priorgroup.vScoreReward[1] then
      local award = priorgroup.vScoreReward[1]
      self.m_txt_iconnum_Text.text = "x" .. award.iNum
      ResourceUtil:CreatIconById(self.m_icon_receive_Image, award.iID)
    end
  end
  self.m_pnl_received:SetActive(self.hasRewarded)
  self.m_btn_receive:SetActive(self.totalScore > 0)
end

function Form_Push_StageGift:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshUI()
end

function Form_Push_StageGift:TakeGroupScoreReward(config, act)
  local msg = MTTDProto.Cmd_Act_LimitChainGift_TakeGroupScoreReward_CS()
  msg.iActivityID = self.act:getID()
  local priorgroup = self.act:GetOpenGroup()
  msg.iGiftGroupId = priorgroup.iGiftGroupId
  RPCS():Act_LimitChainGift_TakeGroupScoreReward(msg, function(sc, msg)
    self:ShowRewards(sc.vReward)
  end)
end

function Form_Push_StageGift:BuyFreeGiftPackage(config, act)
  local msg = MTTDProto.Cmd_Act_LimitChainGift_TakeFreeGoods_CS()
  msg.iActivityID = act:getID()
  local priorgroup = self.act:GetOpenGroup()
  msg.iGiftGroupId = priorgroup.iGiftGroupId
  msg.iGiftGoodsId = config.iGiftId
  RPCS():Act_LimitChainGift_TakeFreeGoods(msg, function(sc, msg)
    self:ShowRewards(sc.vReward)
    self:broadcastEvent("eGameEvent_Activity_ResetStatus")
  end)
end

function Form_Push_StageGift:ShowRewards(rewardList)
  if rewardList and next(rewardList) then
    utils.popUpRewardUI(rewardList, handler(self, self.OnCloseRewardUI))
  end
end

function Form_Push_StageGift:BuyGiftPackage(config, act)
  local ProductInfo = {
    productId = config.sProductId,
    productSubId = config.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActLimitChainGift,
    productName = ConfigManager:GetCommonTextById(220035),
    productDesc = ConfigManager:GetCommonTextById(220035)
  }
  local baseStoreBuyParam = MTTDProto.CmdActLimitChainGiftBuyParam()
  baseStoreBuyParam.iActivityId = act:getID()
  local priorgroup = self.act:GetOpenGroup()
  baseStoreBuyParam.iGiftGroupId = priorgroup.iGiftGroupId
  baseStoreBuyParam.iGiftGoodsId = config.iGiftId
  local storeParam = sdp.pack(baseStoreBuyParam)
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
      return
    end
    self:broadcastEvent("eGameEvent_Buy_Gift_Success")
  end)
end

function Form_Push_StageGift:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_Push_StageGift:OnUpdate(dt)
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + dt
  if self.m_iTimeDurationOneSecond >= 1 then
    self.m_iTimeDurationOneSecond = 0
    local disOutTime = self.act.m_stStatusData.stGiftGroupInfo.iOpenTime + self.act.m_stSdpConfig.stCommonCfg.iGiftGroupDuration - TimeUtil:GetServerTimeS()
    if 0 < disOutTime then
      local lastTime = TimeUtil:SecondsToFormatCNStr4(math.floor(disOutTime))
      self.m_txt_remainingtime01_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(220020), lastTime)
    else
      self:CloseForm()
    end
  end
end

function Form_Push_StageGift:OnDestroy()
  if self.m_giftListGrid then
    self.m_giftListGrid:dispose()
    self.m_giftListGrid = nil
  end
  if self.star_sequence then
    self.star_sequence:Kill()
    self.star_sequence = nil
  end
  self.super.OnDestroy(self)
end

function Form_Push_StageGift:OnBtncloseClicked()
  self:CloseForm()
end

function Form_Push_StageGift:OnBtnclose1Clicked()
  self:CloseForm()
end

function Form_Push_StageGift:OnBtnrefreshClicked()
  self:CloseForm()
end

function Form_Push_StageGift:IsFullScreen()
  return true
end

function Form_Push_StageGift:IsOpenGuassianBlur()
  return true
end

function Form_Push_StageGift:OnBtnreceiveClicked()
  if self.curScore < self.totalScore or self.hasRewarded then
    local priorgroup = self.act:GetOpenGroup()
    if priorgroup and priorgroup.vScoreReward and priorgroup.vScoreReward[1] then
      local award = priorgroup.vScoreReward[1]
      utils.openItemDetailPop({
        iID = award.iID,
        award = award.iNum
      })
    end
  else
    self:TakeGroupScoreReward()
  end
end

local fullscreen = true
ActiveLuaUI("Form_Push_StageGift", Form_Push_StageGift)
return Form_Push_StageGift
