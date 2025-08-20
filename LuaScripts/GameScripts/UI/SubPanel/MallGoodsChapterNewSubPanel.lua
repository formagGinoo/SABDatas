local UISubPanelBase = require("UI/Common/UISubPanelBase")
local MallGoodsChapterNewSubPanel = class("MallGoodsChapterSubPanel", UISubPanelBase)
local maxNoScorll = 4

function MallGoodsChapterNewSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollview_InfinityGrid, "PayStore/GoodsChapterLevelItemNew")
  self.iCurSelectSubTab = 1
  self.m_SubTabItemCache = {}
  self.m_SubTabHelper = self.m_subTab:GetComponent("PrefabHelper")
  self.m_SubTabHelper:RegisterCallback(handler(self, self.OnInitSubTabItem))
  self.m_moveToIndex = 0
  self.m_isFreshCfg = true
end

function MallGoodsChapterNewSubPanel:OnInitSubTabItem(go, idx)
  local transform = go.transform
  local index = idx + 1
  local item = self.m_SubTabItemCache[index]
  local goodsChapterCfg = self.m_mallGoodsChapterAllCfg[index]
  if not goodsChapterCfg then
    if go then
      go:SetActive(false)
    end
    return
  end
  if not item then
    item = {
      button = go:GetComponent("Button"),
      Selected = transform:Find("img_tab_sel").gameObject,
      RedObj = transform:Find("red").gameObject,
      LineObj = transform:Find("Img_cutline").gameObject,
      LineImage = transform:Find("Img_cutline"):GetComponent("Image"),
      TitleUnSelectText = transform:Find("txt_title"):GetComponent("TMPPro"),
      TitleSelectedText = transform:Find("img_tab_sel/txt_title"):GetComponent("TMPPro")
    }
    self.m_SubTabItemCache[index] = item
  end
  local count = #self.m_mallGoodsChapterAllCfg
  item.LineObj:SetActive(index < count)
  item.Selected:SetActive(index == self.iCurSelectSubTab)
  local titleName = goodsChapterCfg.m_mItemName
  item.TitleUnSelectText.text = titleName
  item.TitleSelectedText.text = titleName
  local isRed = MallGoodsChapterManager:HaveRewardAvailableWithGoodsIs(goodsChapterCfg.m_GoodsID)
  item.RedObj:SetActive(isRed)
  item.button.onClick:RemoveAllListeners()
  item.button.onClick:AddListener(function()
    if self.iCurSelectSubTab == index then
      return
    end
    self.iCurSelectSubTab = index
    self.goodsChapterCfg = self.m_mallGoodsChapterAllCfg[self.iCurSelectSubTab]
    self.iGoodsId = self.goodsChapterCfg.m_GoodsID
    self.m_goodCfg, self.server_data = MallGoodsChapterManager:__GetCurGiftInfo(self.goodsChapterCfg)
    GlobalManagerIns:TriggerWwiseBGMState(189)
    self.m_SubTabHelper:Refresh()
    self.m_ListInfinityGrid:LocateTo(0)
    self:ReFreshUI()
    UILuaHelper.PlayAnimationByName(self.m_rootObj, "goodschapternew_in")
  end)
end

function MallGoodsChapterNewSubPanel:OnFreshData(params)
  self.iCurSelectSubTab = 1
  if self.m_isFreshCfg then
    self.m_isShow, self.m_mallGoodsChapterAllCfg = MallGoodsChapterManager:IsShowGoodChapterGift()
    self.m_SubTabHelper:CheckAndCreateObjs(#self.m_mallGoodsChapterAllCfg)
    self.m_isFreshCfg = false
  end
  self.m_vx_unlock:SetActive(false)
  self.m_goodsChapterTab = {}
  local store_config = self.m_panelData
  self.iStoreId = store_config.storeData.iStoreId
  self.goodsChapterCfg = self.m_mallGoodsChapterAllCfg[self.iCurSelectSubTab]
  if not self.goodsChapterCfg then
    log.error("MallGoodsChapterSubPanel:OnFreshData Error! Wrong ServerData!")
    return
  end
  self.iGoodsId = self.goodsChapterCfg.m_GoodsID
  self.m_SubTabHelper:Refresh()
  self:ReFreshUI()
end

function MallGoodsChapterNewSubPanel:OnCloseParentPanel(params)
  self.m_isFreshCfg = true
end

function MallGoodsChapterNewSubPanel:OnEventGetRewardOrBuy(params)
  self.m_vx_unlock:SetActive(false)
  if params and params.isBuy then
    self.m_vx_unlock:SetActive(true)
  end
  self.m_ListInfinityGrid:LocateTo(0)
  self.m_goodsChapterTab = {}
  local store_config = self.m_panelData
  self.iStoreId = store_config.storeData.iStoreId
  self.goodsChapterCfg = self.m_mallGoodsChapterAllCfg[self.iCurSelectSubTab]
  if not self.goodsChapterCfg then
    log.error("MallGoodsChapterSubPanel:OnFreshData Error! Wrong ServerData!")
    return
  end
  self.iGoodsId = self.goodsChapterCfg.m_GoodsID
  self.m_SubTabHelper:Refresh()
  self:ReFreshUI()
end

function MallGoodsChapterNewSubPanel:ReFreshUI()
  self:RefreshTitle()
  self:RefreshRewardItemList()
  local server_data = self.server_data
  self.is_Purchased = server_data and server_data.iBuyTime > 0 and true or false
  self.m_icon_lock:SetActive(not self.is_Purchased)
  self.m_btn_sale:SetActive(not self.is_Purchased)
  local productID = self.goodsChapterCfg.m_ProductID
  self.m_txt_price_Text.text = IAPManager:GetProductPrice(productID, true)
  self.have_RewardCanGet = MallGoodsChapterManager:HaveRewardAvailableWithGoodsIs(self.iGoodsId)
  self.m_bg_getall_normal:SetActive(self.have_RewardCanGet)
  self.m_bg_getall_grey:SetActive(not self.have_RewardCanGet)
  self:OnRefreshGiftPoint()
end

function MallGoodsChapterNewSubPanel:RefreshTitle()
  self.m_txt_des_Text.text = self.goodsChapterCfg.m_mItemHint
  local discount = self.goodsChapterCfg.m_DiscountNum or 0
  self.m_txt_point_Text.text = discount .. "%"
  self.m_txt_tag_Text.text = discount .. "%"
end

function MallGoodsChapterNewSubPanel:RefreshRewardItemList()
  local finData = {}
  self.m_isGetRewardIndex = false
  self.m_goodCfg, self.server_data = MallGoodsChapterManager:__GetCurGiftInfo(self.goodsChapterCfg)
  local dataList = MallGoodsChapterManager:GetSmallLevelData(self.iGoodsId)
  self.m_moveToIndexLock = #dataList
  for k, v in ipairs(dataList) do
    table.insert(finData, {
      freeDataCfg = v.freeData,
      payDataCfg = v.payData,
      server_data = self.server_data,
      iStoreId = self.iStoreId
    })
    if not self.m_isGetRewardIndex and self.server_data then
      local function checkUnlockAndMoveToIndex(data, isPay)
        if data and not self.m_isGetRewardIndex then
          local isUnlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, data.m_MainLevelID)
          
          local isGot = data.m_Level and self.server_data.mLevelInfo[data.m_Level] and true or false
          if not isGot and isUnlock and (not isPay or self.server_data.iBuyTime > 0) then
            self.m_moveToIndex = k - 1
            self.m_isGetRewardIndex = true
          end
          if not isUnlock and self.m_moveToIndexLock > k - 1 then
            self.m_moveToIndexLock = k - 1
          end
        end
      end
      
      checkUnlockAndMoveToIndex(v.freeData and v.freeData[1], false)
      checkUnlockAndMoveToIndex(v.payData and v.payData[1], true)
    end
  end
  self.m_ListInfinityGrid:ShowItemList(finData)
  if #finData <= maxNoScorll then
    UILuaHelper.SetScrollViewEnable(self.m_scrollview, false)
  else
    UILuaHelper.SetScrollViewEnable(self.m_scrollview, true)
    if self.m_isGetRewardIndex then
      self.m_ListInfinityGrid:LocateTo(self.m_moveToIndex)
      self.m_moveToIndex = 0
    else
      self.m_ListInfinityGrid:LocateTo(self.m_moveToIndexLock)
    end
  end
end

function MallGoodsChapterNewSubPanel:OnActivePanel()
  self:AddEventListeners()
end

function MallGoodsChapterNewSubPanel:OnInactivePanel()
  self.m_vx_unlock:SetActive(false)
  self:RemoveAllEventListeners()
end

function MallGoodsChapterNewSubPanel:OnBtnsaleClicked()
  if not self.is_Purchased then
    MallGoodsChapterManager:RqsBaseStoreBuyGoods(self.iStoreId, self.goodsChapterCfg.m_GoodsID, self.goodsChapterCfg.m_ProductID, self.goodsChapterCfg.m_ProductSubID, {
      productName = self.goodsChapterCfg.m_mItemName,
      productDesc = self.goodsChapterCfg.m_mItemHint
    })
  end
end

function MallGoodsChapterNewSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_RefreshBaseStoreChapter", handler(self, self.OnEventGetRewardOrBuy))
end

function MallGoodsChapterNewSubPanel:OnBtngetailClicked()
  if self.have_RewardCanGet then
    MallGoodsChapterManager:RqsGetBaseStoreChapterReward(self.iStoreId, self.goodsChapterCfg.m_GoodsID, 0, true)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(40041))
  end
end

function MallGoodsChapterNewSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function MallGoodsChapterNewSubPanel:OnRefreshGiftPoint()
  if utils.isNull(self.m_packgift_point) then
    return
  end
  if not self.goodsChapterCfg or not self.goodsChapterCfg.m_ProductID then
    self.m_packgift_point:SetActive(false)
    return
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(self.goodsChapterCfg.m_ProductID)
  local pointParams = {pointReward = pointReward}
  if isShowPoint then
    if self.m_paidGiftPoint then
      self.m_paidGiftPoint:SetFreshInfo(pointParams)
    else
      self.m_paidGiftPoint = self:createPackGiftPoint(self.m_packgift_point, pointParams)
    end
  else
    self.m_packgift_point:SetActive(false)
  end
end

function MallGoodsChapterNewSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  MallGoodsChapterNewSubPanel.super.OnDestroy(self)
end

return MallGoodsChapterNewSubPanel
