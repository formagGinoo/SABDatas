local UIItemBase = require("UI/Common/UIItemBase")
local StageGiftItem = class("StageGiftItem", UIItemBase)

function StageGiftItem:OnInit()
  self.m_contianer_Obj = self.m_itemRootObj.transform:Find("pnl_item").gameObject
  self.m_arrow_right = self.m_contianer_Obj.transform:Find("m_arrow_right").gameObject
  self.c_gift_item = self.m_contianer_Obj.transform:Find("m_pnl_itemgift/c_gift_item1").gameObject
  self.rewardItem = self:createCommonItem(self.c_gift_item)
  self.m_btn_buy_obj = self.m_contianer_Obj.transform:Find("c_btn_buy").gameObject
  self.m_pnl_lock_free = self.m_contianer_Obj.transform:Find("c_btn_buy/m_pnl_lock_free").gameObject
  self.m_pnl_buy = self.m_contianer_Obj.transform:Find("c_btn_buy/m_pnl_buy").gameObject
  self.m_icon_lockfree = self.m_contianer_Obj.transform:Find("c_btn_buy/m_pnl_lock_free/pnl_free/m_icon_lockfree").gameObject
  self.m_icon_lockbuy = self.m_contianer_Obj.transform:Find("c_btn_buy/m_pnl_buy/pnl_buy/m_icon_lockbuy").gameObject
  self.m_txt_soldout_obj = self.m_contianer_Obj.transform:Find("m_mask_soldout").gameObject
  self.m_icon_lock_obj = self.m_contianer_Obj.transform:Find("c_btn_buy/m_pnl_buy/pnl_buy/m_icon_lockbuy").gameObject
  self.m_txt_giftnum = self.m_contianer_Obj.transform:Find("m_icon_giftnum/m_txt_giftnum"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_buynum = self.m_contianer_Obj.transform:Find("c_btn_buy/m_pnl_buy/pnl_buy/m_txt_buynum"):GetComponent(T_TextMeshProUGUI)
  self.m_rewardListObj = {}
  self.m_rewardList = {}
  self.m_rewardListObj[1] = self.m_contianer_Obj.transform:Find("m_pnl_itemgift/c_gift_item1").gameObject
  self.m_rewardListObj[2] = self.m_contianer_Obj.transform:Find("m_pnl_itemgift/c_gift_item2").gameObject
  self.m_rewardListObj[3] = self.m_contianer_Obj.transform:Find("m_pnl_itemgift/c_gift_item3").gameObject
  self.sAniIn = "m_stagegift_btn_unlock"
end

function StageGiftItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function StageGiftItem:OnItemClick(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function StageGiftItem:SetItemInfo(itemData)
  self.m_arrow_right:SetActive(itemData.index ~= 1)
  self.m_txt_soldout_obj:SetActive(itemData.index <= itemData.goodStatus)
  local giftData = itemData.giftData
  local awards = giftData.vReward
  if self.m_paidGiftPoint == nil then
    self.m_paidGiftPoint = self:createPackGiftPoint(self.m_packgift_point)
  end
  self.m_paidGiftPoint:SetFreshInfo({
    productId = giftData.sProductId
  })
  self.m_txt_buynum.text = IAPManager:GetProductPrice(giftData.sProductId, true)
  for i = 1, 3 do
    if self.m_rewardList[i] == nil then
      self.m_rewardList[i] = self:createCommonItem(self.m_rewardListObj[i])
    end
    self.m_rewardListObj[i]:SetActive(awards[i] ~= nil)
    if awards[i] then
      local processData = ResourceUtil:GetProcessRewardData(awards[i])
      self.m_rewardList[i]:SetItemInfo(processData)
      self.m_rewardList[i]:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnItemClick(itemID, itemNum, itemCom)
      end)
    end
  end
  self.m_txt_giftnum.text = giftData.iScore or 0
  self.m_pnl_lock_free:SetActive(giftData.sProductId == "")
  self.m_pnl_buy:SetActive(giftData.sProductId ~= "")
  self.m_icon_lockfree:SetActive(itemData.index > itemData.goodStatus + 1)
  self.m_icon_lockbuy:SetActive(itemData.index > itemData.goodStatus + 1)
  self.m_icon_giftnum:SetActive(giftData.iScore and giftData.iScore > 0)
end

function StageGiftItem:ShowEffect()
  local giftData = self.m_itemData.giftData
  if giftData.sProductId ~= "" then
    self.m_icon_lockbuy:SetActive(true)
    UILuaHelper.PlayAnimationByName(self.m_pnl_buy, self.sAniIn)
  else
    self.m_icon_lockfree:SetActive(true)
    UILuaHelper.PlayAnimationByName(self.m_pnl_lock_free, self.sAniIn)
  end
end

return StageGiftItem
