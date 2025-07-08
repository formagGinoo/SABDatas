local Form_ShopConfirmPop = class("Form_ShopConfirmPop", require("UI/UIFrames/Form_ShopConfirmPopUI"))

function Form_ShopConfirmPop:SetInitParam(param)
end

function Form_ShopConfirmPop:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetNumStepper = self:createNumStepper(self.m_pnl_right.transform:Find("ui_common_stepper"))
  self.top_Bar = self:createResourceBar(self.m_top_resource)
end

function Form_ShopConfirmPop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_shopId = tParam.shopId
  self.m_goodsInfo = tParam.goodsInfo
  self.bSkipVoice = tParam.bSkipVoice
  self.m_stockBoughtMaxNum = 0
  self.m_curGoodsCfg = {}
  self.m_buyCount = 1
  self:RefreshUI()
  self:RefreshResourceBar()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_ShopConfirmPop:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_ShopConfirmPop:RefreshResourceBar()
  local shopCfg = ShopManager:GetShopConfig(self.m_shopId)
  if not shopCfg:GetError() then
    local mainCurrency = utils.changeCSArrayToLuaTable(shopCfg.m_MainCurrency)
    self.top_Bar:FreshChangeItems(mainCurrency)
  end
end

function Form_ShopConfirmPop:RefreshUI()
  local goodCfg = ShopManager:GetShopGoodsConfig(self.m_goodsInfo.iGroupId, self.m_goodsInfo.iGoodsId)
  if goodCfg and not goodCfg:GetError() then
    local boughtNum = ShopManager:GetShopGoodsStockBought(self.m_shopId, self.m_goodsInfo.iGroupId, self.m_goodsInfo.iGoodsId)
    self.m_stockBoughtMaxNum = goodCfg.m_ItemQuantity - boughtNum
    self.m_widgetNumStepper:SetNumShowMax(false)
    self.m_widgetNumStepper:SetNumMax(self.m_stockBoughtMaxNum)
    self.m_widgetNumStepper:SetNumCur(1)
    self.m_widgetNumStepper:SetNumChangeCB(handler(self, self.OnNumStepperChange))
    if self.m_itemIcon == nil then
      self.m_itemIcon = self:createCommonItem(self.m_common_item)
    end
    local goodItem = utils.changeCSArrayToLuaTable(goodCfg.m_ItemID) or {}
    local itemData = ResourceUtil:GetProcessRewardData({
      iID = goodItem[1],
      iNum = goodItem[2]
    })
    self.m_itemIcon:SetItemInfo(itemData)
    self.m_txt_name_Text.text = itemData.name
    if itemData.data_type == ResourceUtil.RESOURCE_TYPE.HEROES then
      self.m_txt_num_Text.text = ""
    else
      self.m_txt_num_Text.text = string.format(ConfigManager:GetCommonTextById(20043), itemData.user_num)
    end
    self.m_txt_shopitemdes_long_Text.text = itemData.description
    local currency = utils.changeCSArrayToLuaTable(goodCfg.m_Currency) or {}
    local originalPrice = currency[2]
    local finalPrice = currency[3]
    ResourceUtil:CreatIconById(self.m_consume_icon_Image, currency[1])
    local price = math.floor((originalPrice - finalPrice) / originalPrice * 100)
    if price == 0 then
      self.m_shopitem_salenum:SetActive(false)
    else
      self.m_shopitem_salenum:SetActive(true)
      self.m_txt_shopitem_salenum_Text.text = string.format(ConfigManager:GetCommonTextById(20040), price)
    end
    ResourceUtil:CreatIconById(self.m_consume_icon2_Image, currency[1])
    self.m_curGoodsCfg = goodCfg
    self.m_txt_resource_num_Text.text = ItemManager:GetItemNum(currency[1], true)
    self:ChangeConsumeTextState(1)
    local myMoney = ItemManager:GetItemNum(currency[1], true)
    local nums = math.max(1, math.floor(myMoney / finalPrice))
    local maxNum = math.min(self.m_stockBoughtMaxNum, nums)
    self.m_widgetNumStepper:SetNumMax(maxNum)
  end
end

function Form_ShopConfirmPop:ChangeConsumeTextState(buyNum)
  if self.m_curGoodsCfg then
    local currency = utils.changeCSArrayToLuaTable(self.m_curGoodsCfg.m_Currency) or {}
    local finalPrice = currency[3] * buyNum
    self.m_consume_num_Text.text = BigNumFormat(finalPrice)
    local num = ItemManager:GetItemNum(currency[1], true)
    if finalPrice > num then
      UILuaHelper.SetColor(self.m_consume_num_Text, 255, 0, 0, 1)
    else
      UILuaHelper.SetColor(self.m_consume_num_Text, 84, 78, 71, 1)
    end
    self.m_buyCount = buyNum
  end
end

function Form_ShopConfirmPop:OnNumStepperChange(iNumCur, iNumChange, sTag)
  self:ChangeConsumeTextState(iNumCur)
end

function Form_ShopConfirmPop:OnBtnconsumeClicked()
  if self.m_curGoodsCfg then
    local currency = utils.changeCSArrayToLuaTable(self.m_curGoodsCfg.m_Currency) or {}
    local finalPrice = currency[3] * self.m_buyCount
    local num = ItemManager:GetItemNum(currency[1], true)
    if finalPrice > num then
      if currency[1] == MTTDProto.SpecialItem_Diamond or currency[1] == MTTDProto.SpecialItem_FreeDiamond then
        utils.CheckAndPushCommonTips({
          tipsID = 1222,
          func1 = function()
            QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
            StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_SHOPCONFIRMPOP)
          end
        })
      else
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10103)
      end
      return
    end
  end
  ShopManager:BuyGoods(self.m_shopId, self.m_goodsInfo.iGroupId, self.m_goodsInfo.iGoodsId, self.m_buyCount, self.bSkipVoice)
  self:OnBtnCloseClicked()
end

function Form_ShopConfirmPop:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_SHOPCONFIRMPOP)
end

function Form_ShopConfirmPop:IsOpenGuassianBlur()
  return true
end

function Form_ShopConfirmPop:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_ShopConfirmPop:OnDestroy()
  self.super.OnDestroy(self)
end

ActiveLuaUI("Form_ShopConfirmPop", Form_ShopConfirmPop)
return Form_ShopConfirmPop
