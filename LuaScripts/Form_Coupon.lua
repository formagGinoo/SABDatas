local Form_Coupon = class("Form_Coupon", require("UI/UIFrames/Form_CouponUI"))
local showType = {WithItem = 1, NoItem = 2}

function Form_Coupon:SetInitParam(param)
end

function Form_Coupon:AfterInit()
  self.super.AfterInit(self)
  local root_trans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = root_trans.transform:Find("m_coupon_resource").gameObject
  local resourceBarList = {
    MTTDProto.SpecialItem_Welfare
  }
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_multiColor = self.m_txt_coupon:GetComponent("MultiColorChange")
  self.m_pnl_couponitem = require("UI/Common/UIInfinityGrid").new(self.m_pnl_couponitem_InfinityGrid, "UICommonItem", initGridData)
  self.m_pnl_couponitem:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
  self.m_widgetResourceBar = self:createResourceBar(goBackBtnRoot, resourceBarList)
  self.m_freeText = ConfigManager:GetCommonTextById(20041)
end

function Form_Coupon:OnActive()
  self.super.OnActive(self)
  self.m_curType = showType.NoItem
  local param = self.m_csui.m_param
  self.rewardList = {}
  self.productInfo = param.ProductInfo
  self.storeParam = param.storeParam
  self.m_normalBuy = param.normalBuy
  self.welfareBuy = param.welfareBuy
  self.desString = ConfigManager:GetCommonTextById(220016)
  if self.productInfo.rewardList and #self.productInfo.rewardList > 0 then
    self.m_curType = showType.WithItem
    self.rewardList = self.productInfo.rewardList
  end
  self:RefreshUI()
end

function Form_Coupon:RefreshUI()
  UILuaHelper.SetActive(self.m_txt_giftname01, self.m_curType == showType.NoItem)
  UILuaHelper.SetActive(self.m_pnl_giftconfirm, self.m_curType == showType.WithItem)
  local priceText = IAPManager:GetProductPrice(self.productInfo.productId, true)
  local welfareText = IAPManager:GetProductWelfarePrice(self.productInfo.productId)
  self.m_txt_upgrade_Text.text = priceText or self.m_freeText
  self.m_txt_coupon_Text.text = welfareText or self.m_freeText
  local m_curNum = ItemManager:GetItemNum(MTTDProto.SpecialItem_Welfare)
  self.m_enough = tonumber(welfareText) <= tonumber(m_curNum)
  self.m_multiColor:SetColorByIndex(self.m_enough and 0 or 1)
  if not self.productInfo.productName or self.productInfo.productName == "" or self.productInfo.productName == "???" then
    self.desString = ConfigManager:GetCommonTextById(220017)
  end
  if self.m_curType == showType.NoItem then
    self.m_txt_giftname01_Text.text = string.gsubnumberreplace(self.desString, self.productInfo.productName or "")
  else
    self.m_txt_giftname02_Text.text = string.gsubnumberreplace(self.desString, self.productInfo.productName or "")
    self:RefreshUIWithItem()
  end
end

function Form_Coupon:RefreshUIWithItem()
  local reward = {}
  for i, v in ipairs(self.productInfo.rewardList) do
    local processData = ResourceUtil:GetProcessRewardData(v)
    table.insert(reward, processData)
  end
  self.m_pnl_couponitem:ShowItemList(reward)
end

function Form_Coupon:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  if self.rewardList then
    local chooseFJItemData = self.rewardList[fjItemIndex]
    if chooseFJItemData then
      utils.openItemDetailPop({
        iID = chooseFJItemData.iID,
        iNum = chooseFJItemData.iNum
      })
    end
  end
end

function Form_Coupon:OnBtnupgradeClicked()
  if self.m_normalBuy then
    self.m_normalBuy()
    self:CloseForm()
  end
end

function Form_Coupon:OnBtncouponClicked()
  if self.m_enough then
    if self.welfareBuy then
      self.welfareBuy()
      self:CloseForm()
    end
  else
    utils.CheckAndPushCommonTips({
      tipsID = 1030,
      func1 = function()
        local iShow, url = ActivityManager:OnCheckVoucherControlAndUrl()
        if iShow and url then
          CS.DeviceUtil.OpenURLNew(url)
        end
      end
    })
  end
end

function Form_Coupon:OnBtnconsumegrayClicked()
end

function Form_Coupon:OnInactive()
  self.super.OnInactive(self)
end

function Form_Coupon:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Coupon:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Coupon", Form_Coupon)
return Form_Coupon
