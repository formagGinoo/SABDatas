local UIItemBase = require("UI/Common/UIItemBase")
local ActChargeRebateRewardItem = class("ActChargeRebateRewardItem", UIItemBase)

function ActChargeRebateRewardItem:OnInit()
  local itemUnlockFx1 = self.m_itemTemplateCache:GameObject("c_free_light1")
  local itemUnlockFx2 = self.m_itemTemplateCache:GameObject("c_free_light2")
  local itemUnlockFx3 = self.m_itemTemplateCache:GameObject("c_free_light3")
  self.m_btnReward = self.m_itemTemplateCache:GameObject("c_btn_Reward")
  self.m_highLight = self.m_itemTemplateCache:GameObject("c_icon_lightdot")
  self.m_rewardFx = {
    [1] = {itemUnlock = itemUnlockFx1},
    [2] = {itemUnlock = itemUnlockFx2},
    [3] = {itemUnlock = itemUnlockFx3}
  }
end

function ActChargeRebateRewardItem:OnFreshData()
  self.m_reward = self.m_itemData.vReward
  self.m_bBigReward = self.m_itemData.bFinal ~= 0
  self.m_iNeedPoint = self.m_itemData.iNeedPoint
  self.m_activity = self.m_itemData.stActivity
  self.m_lastPoint = self.m_itemData.lastPoint
  self:RefreshUI()
end

function ActChargeRebateRewardItem:RefreshUI()
  self:FreshRewardList()
  self:FreshBg()
  self:FreshSlider()
  local btnEx = self.m_btnReward:GetComponent("ButtonExtensions")
  if btnEx then
    function btnEx.Clicked()
      if self.m_activity then
        self.m_activity:RequestRewardCS(function()
        end)
      end
    end
  end
end

function ActChargeRebateRewardItem:UpdateChildCount(transform, count)
  local childCount = transform.childCount
  if count > childCount then
    local itemInstance = transform:GetChild(0)
    for i = 1, count - childCount do
      GameObject.Instantiate(itemInstance, transform)
    end
    childCount = count
  end
  for i = 1, childCount do
    local child = transform:GetChild(i - 1)
    child.gameObject:SetActive(count >= i)
  end
end

function ActChargeRebateRewardItem:FreshRewardList()
  local isCanReward = false
  local isGet = false
  local getList = self.m_activity:GetTakenRewardList()
  for k, v in ipairs(getList) do
    if v == self.m_iNeedPoint then
      isGet = true
    end
  end
  local itemRoot = self.m_list_itemreward.transform
  local count = #self.m_reward
  self:UpdateChildCount(itemRoot, count)
  for i, v in ipairs(self.m_rewardFx) do
    self.m_rewardFx[i].itemUnlock:SetActive(false)
  end
  for i, v in ipairs(self.m_reward) do
    local itemObj = itemRoot:GetChild(i - 1).gameObject
    local common_item = self:createCommonItem(itemObj)
    common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = v.iID,
      iNum = v.iNum
    })
    common_item:SetItemInfo(processItemData)
    if self.m_activity:GetCurPoint() >= self.m_iNeedPoint and not isGet then
      self.m_rewardFx[i].itemUnlock:SetActive(true)
      isCanReward = true
    else
      self.m_rewardFx[i].itemUnlock:SetActive(false)
    end
    common_item:SetItemHaveGetActive(isGet)
  end
  self.m_bg_get:SetActive(isCanReward)
  self.m_btnReward:SetActive(isCanReward)
  self.m_fx_glow_get:SetActive(isCanReward)
end

function ActChargeRebateRewardItem:FreshBg()
  self.m_item_bgred:SetActive(self.m_bBigReward)
end

function ActChargeRebateRewardItem:FreshSlider()
  local isFirst = self.m_itemIndex == 1
  self.m_img_bg_slider_short:SetActive(isFirst)
  self.m_img_slider_short:SetActive(isFirst)
  self.m_img_bg_slider_long:SetActive(not isFirst)
  self.m_img_slider_long:SetActive(not isFirst)
  local totalPoint = self.m_iNeedPoint
  local curPoint = self.m_activity:GetCurPoint()
  local tempPoint = curPoint - self.m_lastPoint > 0 and curPoint - self.m_lastPoint or 0
  local fillAmount = 0
  if totalPoint - self.m_lastPoint == 0 then
    fillAmount = 1
  else
    fillAmount = tempPoint / (totalPoint - self.m_lastPoint)
  end
  if 1 <= fillAmount then
    fillAmount = 1
  end
  if fillAmount < 0 then
    fillAmount = 0
  end
  self.m_highLight:SetActive(0 <= fillAmount)
  if isFirst then
    self.m_img_slider_short_Image.fillAmount = fillAmount
    self.m_img_slider_short2_Image.fillAmount = fillAmount
  else
    self.m_img_slider_long_Image.fillAmount = fillAmount
    self.m_img_slider_long2_Image.fillAmount = fillAmount
  end
  self.m_txt_slidernum_Text.text = tostring(self.m_iNeedPoint)
end

function ActChargeRebateRewardItem:ShowItemTips(iID, iNum)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

return ActChargeRebateRewardItem
