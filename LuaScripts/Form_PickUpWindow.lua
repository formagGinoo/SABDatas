local Form_PickUpWindow = class("Form_PickUpWindow", require("UI/UIFrames/Form_PickUpWindowUI"))

function Form_PickUpWindow:SetInitParam(param)
end

function Form_PickUpWindow:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnCommonItemClk)
  }
  self.m_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_choosereward_InfinityGrid, "PickUp/PickUpChooseItem", initGridData)
  self.prefabHelper = self.m_pnl_rewardchoosen:GetComponent("PrefabHelper")
  self.mEmptyChoosenItem = {}
end

function Form_PickUpWindow:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:FreshUI()
  self:ChooseGiftListByIdx(-1)
end

function Form_PickUpWindow:OnInactive()
  self.super.OnInactive(self)
end

function Form_PickUpWindow:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PickUpWindow:InitData()
  self.giftCfg = self.m_csui.m_param.giftCfg
  self.giftInfo = self.m_csui.m_param.giftInfo
  self.activity = self.m_csui.m_param.activity
end

function Form_PickUpWindow:FreshUI()
  local giftCfg = self.giftCfg
  local giftInfo = self.giftInfo
  UILuaHelper.SetAtlasSprite(self.m_icon_box_Image, giftCfg.sIcon, function()
    self.m_icon_box_Image:SetNativeSize()
  end)
  local price = IAPManager:GetProductPrice(giftCfg.sProductId, true)
  self.m_txt_buygrey_Text.text = price
  self.m_txt_buysel_Text.text = price
  utils.ShowPrefabHelper(self.prefabHelper, function(go, index, cfg)
    local transform = go.transform
    transform.localScale = Vector3.one
    self.mEmptyChoosenItem[index] = transform:Find("c_item_select").gameObject
    local c_pickup_itemnormal = transform:Find("c_pickup_itemchoosen").gameObject
    local btn_empty = transform:Find("img_emptychoosen"):GetComponent("Button")
    btn_empty.onClick:RemoveAllListeners()
    btn_empty.onClick:AddListener(function()
      self:ChooseGiftListByIdx(index, true)
    end)
    local giftIdx = giftInfo and giftInfo.mGridRewardIndex[index + 1] or nil
    if not giftIdx then
      c_pickup_itemnormal:SetActive(false)
      return
    end
    local pickUpReward = cfg[giftIdx + 1]
    pickUpReward = pickUpReward or cfg[1]
    c_pickup_itemnormal:SetActive(true)
    local item = self:createCommonItem(c_pickup_itemnormal)
    local processData = ResourceUtil:GetProcessRewardData(pickUpReward)
    item:SetItemInfo(processData)
    item:SetItemIconClickCB(function(itemID, itemNum)
      self:ChooseGiftListByIdx(index, true)
    end)
  end, giftCfg.stGrids.mGridCfg)
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
  self.m_txt_lineupcommend_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(220007), count, max_count)
end

function Form_PickUpWindow:ChooseGiftListByIdx(index, bIsSetPos)
  if bIsSetPos then
    self.m_InfinityGrid:LocateTo(index)
  end
  for i, v in pairs(self.mEmptyChoosenItem) do
    v:SetActive(i == index)
  end
  local giftIdx = self.giftInfo and self.giftInfo.mGridRewardIndex[index + 1] or nil
  local curChooseIdx
  if not giftIdx then
    curChooseIdx = nil
  else
    curChooseIdx = index + 1
  end
  local itemlist = self.m_InfinityGrid:GetAllShownItemList()
  for i, item in pairs(itemlist) do
    item:SetSelected(index, curChooseIdx == item.m_itemIndex)
  end
end

function Form_PickUpWindow:OnCommonItemClk(index, chooseIdx)
  local giftInfo = self.giftInfo or {}
  local mGridRewardIndex = giftInfo.mGridRewardIndex or {}
  mGridRewardIndex[index] = chooseIdx - 1
  giftInfo.mGridRewardIndex = mGridRewardIndex
  self.giftInfo = giftInfo
  self:FreshUI()
  self:ChooseGiftListByIdx(index - 1)
end

function Form_PickUpWindow:OnBtnCloseClicked()
  self:CloseForm()
  self:OnBtnsaveClicked(true)
end

function Form_PickUpWindow:OnBtnReturnClicked()
  self:CloseForm()
  self:OnBtnsaveClicked(true)
end

function Form_PickUpWindow:OnBtnsaveClicked(dontShowTips)
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
    end
  end
end

function Form_PickUpWindow:OnBtnbuygreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(52004))
end

function Form_PickUpWindow:OnBtnbuyselClicked()
  local baseStoreBuyParam = MTTDProto.CmdActPickupGiftBuyParam()
  baseStoreBuyParam.iActivityId = self.activity:getID()
  baseStoreBuyParam.mGridRewardIndex = self.giftInfo.mGridRewardIndex
  local storeParam = sdp.pack(baseStoreBuyParam)
  self:OnBtnsaveClicked(true)
  local ProductInfo = {
    productId = self.giftCfg.sProductId,
    productSubId = self.giftCfg.iGiftId,
    iStoreType = MTTDProto.IAPStoreType_ActPickupGift,
    productName = self.activity:getLangText(self.giftCfg.sGiftName) or "",
    productDesc = self.activity:getLangText(self.giftCfg.sGiftDesc) or ""
  }
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    end
    self:CloseForm()
  end)
end

local fullscreen = true
ActiveLuaUI("Form_PickUpWindow", Form_PickUpWindow)
return Form_PickUpWindow
