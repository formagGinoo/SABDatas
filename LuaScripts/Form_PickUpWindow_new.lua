local Form_PickUpWindow_new = class("Form_PickUpWindow_new", require("UI/UIFrames/Form_PickUpWindow_newUI"))

function Form_PickUpWindow_new:SetInitParam(param)
end

function Form_PickUpWindow_new:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnCommonItemClk)
  }
  self.m_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_choosereward_InfinityGrid, "PickUp/PickUpChooseItem", initGridData)
end

function Form_PickUpWindow_new:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:FreshUI()
end

function Form_PickUpWindow_new:OnInactive()
  self.super.OnInactive(self)
end

function Form_PickUpWindow_new:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PickUpWindow_new:InitData()
  self.giftCfg = self.m_csui.m_param.giftCfg
  self.giftInfo = self.m_csui.m_param.giftInfo
  self.activity = self.m_csui.m_param.activity
  self.mOriGridRewardIndex = self.giftInfo and table.copy(self.giftInfo.mGridRewardIndex) or {}
end

function Form_PickUpWindow_new:FreshUI()
  local giftCfg = self.giftCfg
  local giftInfo = self.giftInfo
  local price = IAPManager:GetProductPrice(giftCfg.sProductId, true)
  self.m_txt_buygrey_Text.text = price
  self.m_txt_buysel_Text.text = price
  local tempList = {}
  for i, v in ipairs(giftCfg.stGrids.mGridCfg) do
    table.insert(tempList, {
      cfg = v,
      chooseIdx = giftInfo and giftInfo.mGridRewardIndex[i] or nil
    })
  end
  self.m_InfinityGrid:ShowItemList(tempList)
  local count = 0
  local max_count = #giftCfg.stGrids.mGridCfg
  if giftInfo then
    for _, v in pairs(giftInfo.mGridRewardIndex) do
      count = count + 1
    end
  end
  self.m_btn_buysel:SetActive(count == max_count)
  self.m_btn_buygrey:SetActive(max_count > count)
end

function Form_PickUpWindow_new:OnCommonItemClk(index, chooseIdx)
  local giftInfo = self.giftInfo or {}
  local mGridRewardIndex = giftInfo.mGridRewardIndex or {}
  mGridRewardIndex[index] = chooseIdx - 1
  giftInfo.mGridRewardIndex = mGridRewardIndex
  self.giftInfo = giftInfo
  self:FreshUI()
end

function Form_PickUpWindow_new:OnBtnCloseClicked()
  self:CloseForm()
  self.giftInfo.mGridRewardIndex = self.mOriGridRewardIndex
end

function Form_PickUpWindow_new:OnBtnReturnClicked()
  self:CloseForm()
  self.giftInfo.mGridRewardIndex = self.mOriGridRewardIndex
end

function Form_PickUpWindow_new:OnBtnsaveClicked(dontShowTips)
  if self.giftInfo then
    local isSoldOut = self.giftInfo and self.giftInfo.iBoughtNum >= self.giftCfg.iBuyLimit
    if isSoldOut then
      return
    end
    local count = 0
    for _, v in pairs(self.giftInfo.mGridRewardIndex) do
      count = count + 1
    end
    if 0 < count then
      self.activity:RqsSetReward(self.giftCfg.iGiftId, self.giftInfo.mGridRewardIndex)
    end
    if not dontShowTips then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(52005))
      self:CloseForm()
    else
    end
  end
end

function Form_PickUpWindow_new:OnBtnbuygreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(52004))
end

function Form_PickUpWindow_new:OnBtnbuyselClicked()
  local baseStoreBuyParam = MTTDProto.CmdActPickupGiftBuyParam()
  baseStoreBuyParam.iActivityId = self.activity:getID()
  baseStoreBuyParam.mGridRewardIndex = self.giftInfo.mGridRewardIndex
  local storeParam = sdp.pack(baseStoreBuyParam)
  self:OnBtnsaveClicked(true)
  local reward = {}
  for index, v in ipairs(self.giftInfo.mGridRewardIndex) do
    if self.giftCfg.stGrids and self.giftCfg.stGrids.mGridCfg and self.giftCfg.stGrids.mGridCfg[index] and self.giftCfg.stGrids.mGridCfg[index][v + 1] then
      reward[#reward + 1] = self.giftCfg.stGrids.mGridCfg[index][v + 1]
    end
  end
  local ProductInfo = {
    productId = self.giftCfg.sProductId,
    productSubId = self.giftCfg.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActPickupGift,
    productName = self.activity:getLangText(self.giftCfg.sGiftName) or "",
    productDesc = self.activity:getLangText(self.giftCfg.sGiftDesc) or "",
    rewardList = reward
  }
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    end
    self:CloseForm()
  end)
end

function Form_PickUpWindow_new:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PickUpWindow_new", Form_PickUpWindow_new)
return Form_PickUpWindow_new
