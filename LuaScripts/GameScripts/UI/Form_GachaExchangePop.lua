local Form_GachaExchangePop = class("Form_GachaExchangePop", require("UI/UIFrames/Form_GachaExchangePopUI"))
local titleTxt = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(20388).m_mMessage
local desTxt = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(20389).m_mMessage
local curNumTxt = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(20390).m_mMessage
local exchangeTxt = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(20391).m_mMessage
local toggleTips = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(20392).m_mMessage

function Form_GachaExchangePop:SetInitParam(param)
end

function Form_GachaExchangePop:AfterInit()
  self.super.AfterInit(self)
  self.m_itemWidget = self:createCommonItem(self.m_common_item)
  self.m_itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
end

function Form_GachaExchangePop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.shopGoodsCfg = nil
  if tParam then
    self.gachaCfg = tParam.gachaCfg
  end
  self.m_specialGoodGroup = utils.changeCSArrayToLuaTable(self.gachaCfg.m_SpecialGoodsGroupID)
  self.shopGoodsCfg = ShopManager:GetShopGoodsConfig(self.m_specialGoodGroup[2], self.m_specialGoodGroup[3])
  self:AddEventListeners()
  self:FreshUI()
end

function Form_GachaExchangePop:FreshUI()
  self.m_txt_frame_middle_title_Text.text = titleTxt
  self.m_txt_desc_Text.text = desTxt
  self.m_txt_tip_Text.text = toggleTips
  local goodsCfg = utils.changeCSArrayToLuaTable(self.shopGoodsCfg.m_Currency)
  local num = ItemManager:GetItemNum(goodsCfg[1])
  local needNum = goodsCfg[2]
  self.m_isCanBuy = false
  self.m_cur_point_Text.text = string.CS_Format(curNumTxt, num)
  self.m_need_point_Text.text = string.CS_Format(exchangeTxt, needNum)
  self.m_isEnough = num >= needNum
  local reward = utils.changeCSArrayToLuaTable(self.shopGoodsCfg.m_ItemID)
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = reward[1],
    iNum = reward[2]
  })
  self.m_itemWidget:SetItemInfo(processItemData)
  local limit = not ShopManager:CheckHaveAnyStock(self.m_specialGoodGroup[1], self.m_specialGoodGroup[2], self.m_specialGoodGroup[3])
  UILuaHelper.SetActive(self.m_btn_confirmgray, limit or not self.m_isEnough)
  UILuaHelper.SetActive(self.m_btn_confirm, not limit and self.m_isEnough)
  local isOn = LocalDataManager:GetIntSimple("UpActivityReward" .. self.gachaCfg.m_GachaID, 0) == 1
  self.m_tip_toggle_Toggle.isOn = isOn
end

function Form_GachaExchangePop:OnBuyResult()
  self:CloseForm()
end

function Form_GachaExchangePop:AddEventListeners()
  self:addEventListener("eGameEvent_ShopSoldOut", handler(self, self.OnBuyResult))
  self:addEventListener("eGameEvent_ShopBuy", handler(self, self.OnBuyResult))
end

function Form_GachaExchangePop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GachaExchangePop:OnInactive()
  self.super.OnInactive(self)
  local tempNum = self.m_tip_toggle_Toggle.isOn == true and 1 or 0
  LocalDataManager:SetIntSimple("UpActivityReward" .. self.gachaCfg.m_GachaID, tempNum)
  self:broadcastEvent("eGameEvent_Gacha_FreshGachaTab", {
    iGahcaId = self.gachaCfg.m_GachaID
  })
  self:RemoveAllEventListeners()
end

function Form_GachaExchangePop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GachaExchangePop:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_GachaExchangePop:OnBtncancelClicked()
  self:CloseForm()
end

function Form_GachaExchangePop:OnBtnconfirmClicked()
  if not self.m_isEnough then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40057)
  end
  ShopManager:BuyGoods(self.m_specialGoodGroup[1], self.m_specialGoodGroup[2], self.m_specialGoodGroup[3])
end

function Form_GachaExchangePop:OnBtnconfirmgrayClicked()
  if not self.m_isEnough then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40057)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40058)
  end
end

local fullscreen = true
ActiveLuaUI("Form_GachaExchangePop", Form_GachaExchangePop)
return Form_GachaExchangePop
