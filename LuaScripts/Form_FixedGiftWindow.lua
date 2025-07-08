local Form_FixedGiftWindow = class("Form_FixedGiftWindow", require("UI/UIFrames/Form_FixedGiftWindowUI"))

function Form_FixedGiftWindow:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_stage_reward_InfinityGrid, "UICommonItem", initGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
end

function Form_FixedGiftWindow:OnActive()
  self.super.OnActive(self)
  local param = self.m_csui.m_param
  self.productInfo = param.ProductInfo
  self.m_txt_name_Text.text = param.Name
  self.m_txt_desc2_Text.text = param.Desc
  self.isBlockBuy = param.isBlockBuy or false
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnItemJumpClose))
  UILuaHelper.SetActive(self.m_btn_grey, self.isBlockBuy)
  UILuaHelper.SetActive(self.m_btn_upgrade, not self.isBlockBuy)
  if param.Icon and param.Icon ~= "" then
    UILuaHelper.SetAtlasSprite(self.m_icon_box_Image, param.Icon, function()
      self.m_icon_box_Image:SetNativeSize()
    end)
  end
  self.m_txt_upgrade_Text.text = param.PriceText
  self.m_txt_buy_grey_Text.text = param.PriceText
  self.rewardList = {}
  for i, v in ipairs(param.Reward) do
    local processData = ResourceUtil:GetProcessRewardData(v)
    table.insert(self.rewardList, processData)
  end
  self.m_rewardListInfinityGrid:ShowItemList(self.rewardList)
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity then
    local reportData = {
      activityId = payStoreActivity:getID(),
      storeId = self.productInfo.StoreID,
      goodsId = self.productInfo.GoodsID,
      giftPackType = self.productInfo.GiftPackType,
      groudId = self.productInfo.GroupId or 0,
      giftPushForm = self.productInfo.GiftPushForm,
      iTriggerParam = self.productInfo.iTriggerParam,
      iTotalRecharge = self.productInfo.iTotalRecharge,
      iTriggerIndex = self.productInfo.iTriggerIndex
    }
    ReportManager:ReportProductBuyView(reportData)
  end
end

function Form_FixedGiftWindow:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_FixedGiftWindow:OnUpdate(dt)
  if ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore) == nil then
    self:CloseForm()
    return
  end
end

function Form_FixedGiftWindow:OnBtnupgradeClicked()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity == nil then
    return
  end
  local reportData = {
    activityId = payStoreActivity:getID(),
    storeId = self.productInfo.StoreID,
    goodsId = self.productInfo.GoodsID,
    giftPackType = self.productInfo.GiftPackType,
    groudId = self.productInfo.GroupId or 0
  }
  ReportManager:ReportProductBuyBtn(reportData)
  if self.productInfo.productId == "" then
    local function onBuyFreeGoodsSuccess(msg)
      StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_FIXEDGIFTWINDOW)
      
      local reward_list = msg.vReward
      if reward_list and next(reward_list) then
        utils.popUpRewardUI(reward_list)
      end
    end
    
    local msg = MTTDProto.Cmd_Act_PayStore_FreeReward_CS()
    msg.iStoreId = self.productInfo.StoreID
    msg.iGoodsId = self.productInfo.GoodsID
    msg.iActivityId = payStoreActivity:getID()
    RPCS():Act_PayStore_FreeReward(msg, onBuyFreeGoodsSuccess)
    return
  end
  local baseStoreBuyParam = MTTDProto.CmdActPayStoreBuyParam()
  baseStoreBuyParam.iStoreId = self.productInfo.StoreID
  baseStoreBuyParam.iGoodsId = self.productInfo.GoodsID
  baseStoreBuyParam.iActivityId = payStoreActivity:getID()
  local storeParam = sdp.pack(baseStoreBuyParam)
  local examData = {}
  examData.productName = self.m_csui.m_param.Name or ""
  examData.productDesc = self.m_csui.m_param.Desc or ""
  if self.productInfo.GiftPushForm then
    examData.panelName = self.productInfo.GiftPushForm
  end
  local welfarePrice = IAPManager:GetProductWelfarePrice(self.productInfo.productId)
  local curWelfareNum = ItemManager:GetItemNum(MTTDProto.SpecialItem_Welfare)
  if self.productInfo.productId ~= "" and (tonumber(welfarePrice) <= tonumber(curWelfareNum) or ActivityManager:OnCheckVoucherControlAndUrl()) then
    local function OnNormalBuy(msg)
      IAPManager:BuyProduct(self.productInfo.productId, self.productInfo.productSubId, self.productInfo.iStoreType, storeParam, handler(self, self.OnBuyResult), examData)
    end
    
    local function OnWelfareBug(msg)
      IAPManager:BuyProduct(self.productInfo.productId, self.productInfo.productSubId, self.productInfo.iStoreType, storeParam, handler(self, self.OnBuyResult), examData, true)
    end
    
    StackPopup:Push(UIDefines.ID_FORM_COUPON, {
      ProductInfo = self.productInfo,
      storeParam = storeParam,
      normalBuy = OnNormalBuy,
      welfareBuy = OnWelfareBug
    })
  else
    IAPManager:BuyProduct(self.productInfo.productId, self.productInfo.productSubId, self.productInfo.iStoreType, storeParam, handler(self, self.OnBuyResult), examData)
  end
end

function Form_FixedGiftWindow:OnItemJumpClose()
  self:CloseForm()
end

function Form_FixedGiftWindow:OnBtnReturnClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_FIXEDGIFTWINDOW)
end

function Form_FixedGiftWindow:OnBtngreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 52003)
end

function Form_FixedGiftWindow:OnBtnCloseClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_FIXEDGIFTWINDOW)
end

function Form_FixedGiftWindow:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.rewardList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    })
  end
end

function Form_FixedGiftWindow:OnBuyResult(isSuccess, param1, param2)
  if not isSuccess then
    IAPManager:OnCallbackFail(param1, param2)
    return
  end
  self:broadcastEvent("eGameEvent_Buy_Gift_Success")
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_FIXEDGIFTWINDOW)
end

local fullscreen = true
ActiveLuaUI("Form_FixedGiftWindow", Form_FixedGiftWindow)
return Form_FixedGiftWindow
