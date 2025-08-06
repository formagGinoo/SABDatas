local UISubPanelBase = require("UI/Common/UISubPanelBase")
local SignGiftFiveSunPanel = class("SignGiftFiveSunPanel", UISubPanelBase)
local SignMaxNum = 5
local MaxRewardNumOneDay = 2
local MaxBuyTimes = 1
local SpineStrCfg = "cain_base"

function SignGiftFiveSunPanel:OnInit()
  self.m_vPanelItemConfig = {}
  for i = 1, SignMaxNum do
    self.m_vPanelItemConfig[i] = {}
    self.m_vPanelItemConfig[i].childsItemIcon = {}
    self.m_vPanelItemConfig[i].panel = self[string.format("m_item_%02d", i)]
    self.m_vPanelItemConfig[i].buyBtn = self.m_vPanelItemConfig[i].panel.transform:GetComponent(T_Button)
    self.m_vPanelItemConfig[i].redBg = self.m_vPanelItemConfig[i].panel.transform:Find("img_item/c_bg_bug").gameObject
    self.m_vPanelItemConfig[i].redBuyFx = self.m_vPanelItemConfig[i].redBg.transform:Find("c_vx_bug").gameObject
    self.m_vPanelItemConfig[i].curDayRed = self.m_vPanelItemConfig[i].redBg.transform:Find("c_txt_num_buyday").gameObject
    self.m_vPanelItemConfig[i].blueBg = self.m_vPanelItemConfig[i].panel.transform:Find("img_item/c_bg_blue").gameObject
    self.m_vPanelItemConfig[i].blueBuyfx = self.m_vPanelItemConfig[i].blueBg.transform:Find("c_vx_blue").gameObject
    for j = 1, MaxRewardNumOneDay do
      self.m_vPanelItemConfig[i].childsItemIcon[j] = self.m_vPanelItemConfig[i].panel.transform:Find("img_item/pnl_itemlist" .. "/c_common_item" .. j).gameObject
    end
  end
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
end

function SignGiftFiveSunPanel:OnInactivePanel()
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine()
end

function SignGiftFiveSunPanel:OnActivePanel()
  self:RemoveAllEventListeners()
  self:AddEventListeners()
end

function SignGiftFiveSunPanel:OnFreshData()
  self.m_stActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_SignGift)
  if not self.m_stActivity then
    return
  end
  self:RefreshReward()
  self:RefreshSpine()
  self:RefreshBtn()
  self:OnRefreshGiftPoint()
end

function SignGiftFiveSunPanel:RefreshReward()
  if not self.m_stActivity then
    return
  end
  local iRewardDays = self.m_stActivity:GetMaxGetRewardDays()
  local vSignInfoList = self.m_stActivity:GetRewardList()
  local iLoginDays = self.m_stActivity:GetLoginDays()
  local iRewardCount = math.min(#vSignInfoList, SignMaxNum)
  for i = 1, iRewardCount do
    local stSignInfo = vSignInfoList[i]
    local stPanelItemConfig = self.m_vPanelItemConfig[i]
    if stPanelItemConfig then
      if stPanelItemConfig.panel then
        stPanelItemConfig.panel.gameObject:SetActive(true)
      end
      for j = 1, MaxRewardNumOneDay do
        if j <= #stSignInfo then
          local getVx = stPanelItemConfig.childsItemIcon[j].gameObject.transform:Find("c_vx_get").gameObject
          if getVx then
            if i <= iLoginDays and i > iRewardDays then
              getVx:SetActive(true)
            else
              getVx:SetActive(false)
            end
          end
          UILuaHelper.SetActive(stPanelItemConfig.childsItemIcon[j], true)
          local itemWidgetIcon = self:createCommonItem(stPanelItemConfig.childsItemIcon[j])
          local itemInfo = ResourceUtil:GetProcessRewardData({
            iID = stSignInfo[j].iID,
            iNum = stSignInfo[j].iNum
          })
          itemWidgetIcon:SetItemInfo(itemInfo)
          itemWidgetIcon:SetItemIconClickCB(handler(self, self.ShowItemTips))
          if i <= iRewardDays then
            itemWidgetIcon:SetItemHaveGetActive(true)
          else
            itemWidgetIcon:SetItemHaveGetActive(false)
          end
        else
          UILuaHelper.SetActive(stPanelItemConfig.childsItemIcon[j], false)
        end
      end
      stPanelItemConfig.redBg:SetActive(i == 1)
      stPanelItemConfig.blueBg:SetActive(i ~= 1)
      if i <= iLoginDays and i > iRewardDays then
        if i == 1 then
          stPanelItemConfig.redBuyFx:SetActive(true)
        else
          stPanelItemConfig.blueBuyfx:SetActive(true)
        end
        UILuaHelper.BindButtonClickManual(self, stPanelItemConfig.buyBtn, function()
          self.m_stActivity:ReqGetReward()
        end)
      else
        stPanelItemConfig.redBuyFx:SetActive(false)
        stPanelItemConfig.blueBuyfx:SetActive(false)
      end
    end
  end
end

function SignGiftFiveSunPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_SignGift_Reward", handler(self, self.OnEventGetReward))
  self:addEventListener("eGameEvent_Activity_SignGift_FirstReward", handler(self, self.OnEventFirsRewardGet))
end

function SignGiftFiveSunPanel:OnEventFirsRewardGet(stParam)
  self.m_stActivity = ActivityManager:GetActivityByID(stParam.iActivityID)
  if not self.m_stActivity then
    return
  end
  self:broadcastEvent("eGameEvent_Activity_RefreshPayStoreTimer")
  self:RefreshReward()
  self:RefreshBtn()
end

function SignGiftFiveSunPanel:OnEventGetReward(stParam)
  self.m_stActivity = ActivityManager:GetActivityByID(stParam.iActivityID)
  if not self.m_stActivity then
    return
  end
  utils.popUpRewardUI(stParam.vReward)
  self:RefreshReward()
  self:RefreshBtn()
end

function SignGiftFiveSunPanel:RefreshBtn()
  self.m_btn_tips:SetActive(false)
  local buyTimes = self.m_stActivity:GetBuyTimes()
  self.m_btn_soldout:SetActive(0 < buyTimes)
  self.m_btn_buy:SetActive(buyTimes <= 0)
  if buyTimes <= 0 then
    self.m_txt_price_Text.text = IAPManager:GetProductPrice(self.m_stActivity:GetCommonCfg().sProductId, true)
    self.m_txt_num_Text.text = tostring(self.m_stActivity:GetCommonCfg().iProductValue)
    self.m_txt_num_remaining_Text.text = string.format(ConfigManager:GetCommonTextById(20047), 1, 1)
  else
    self.m_txt_num_remaining_Text.text = string.format(ConfigManager:GetCommonTextById(20047), 0, 1)
  end
  if self.m_stActivity:GetClientData().sRule then
    self.m_btn_tips:SetActive(true)
  end
end

function SignGiftFiveSunPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function SignGiftFiveSunPanel:RefreshSpine()
  self:LoadHeroSpine(SpineStrCfg)
end

function SignGiftFiveSunPanel:CheckRecycleSpine()
  if self.m_curHeroSpineObj and SpineStrCfg then
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(SpineStrCfg, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function SignGiftFiveSunPanel:LoadHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:GetObjectByName(heroSpinePathStr, function(backStr, spineSomethingObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineSomethingObj
      UILuaHelper.SetParent(self.m_curHeroSpineObj, self.m_hero_spine, true)
      UILuaHelper.SetActive(self.m_curHeroSpineObj, true)
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    end)
  end
end

function SignGiftFiveSunPanel:OnBtntipsClicked()
  local id = tonumber(self.m_stActivity:GetClientData().sRule)
  utils.popUpDirectionsUI({tipsID = id})
end

function SignGiftFiveSunPanel:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function SignGiftFiveSunPanel:OnBtnbuyClicked()
  local config = self.m_stActivity:GetCommonCfg()
  local baseStoreBuyParam = MTTDProto.CmdActSignGiftBuyParam()
  baseStoreBuyParam.iActivityId = self.m_stActivity:getID()
  local storeParam = sdp.pack(baseStoreBuyParam)
  local ProductInfo = {
    productId = config.sProductId,
    productSubId = config.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActSignGift,
    productName = self.m_stActivity:getLangText(self.m_stActivity:GetClientData().sProductName)
  }
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    end
  end)
end

function SignGiftFiveSunPanel:OnBtnsoldoutClicked()
end

function SignGiftFiveSunPanel:OnRefreshGiftPoint()
  if utils.isNull(self.m_packgift_point) then
    return
  end
  local productId = self.m_stActivity:GetCommonCfg().sProductId
  if not productId then
    self.m_packgift_point:SetActive(false)
    return
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(productId)
  local pointParams = {pointReward = pointReward}
  if isShowPoint then
    self.m_packgift_point:SetActive(true)
    if self.m_paidGiftPoint then
      self.m_paidGiftPoint:SetFreshInfo(pointParams)
    else
      self.m_paidGiftPoint = self:createPackGiftPoint(self.m_packgift_point, pointParams)
    end
  else
    self.m_packgift_point:SetActive(false)
  end
end

function SignGiftFiveSunPanel:GetDownloadResourceExtra(subPanelCfg)
  local spineStr = SpineStrCfg
  local vPackage = {}
  local vResourceExtra = {}
  if spineStr then
    vResourceExtra[#vResourceExtra + 1] = {
      sName = spineStr,
      eType = DownloadManager.ResourceType.UI
    }
  end
  return vPackage, vResourceExtra
end

return SignGiftFiveSunPanel
