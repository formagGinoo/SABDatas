local UISubPanelBase = require("UI/Common/UISubPanelBase")
local MallGoodsChapterNewSubPanel = class("MallGoodsChapterSubPanel", UISubPanelBase)
local maxNoScorll = 4

function MallGoodsChapterNewSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollview_InfinityGrid, "PayStore/GoodsChapterLevelItemNew")
  self.m_lastBuyState = false
  self.m_curBuyState = false
  self.m_showEnterAnim = true
end

function MallGoodsChapterNewSubPanel:OnFreshData(params)
  self.m_vx_unlock:SetActive(false)
  if params and params.isBuy then
    self.m_vx_unlock:SetActive(true)
  end
  if self.m_showEnterAnim then
    UILuaHelper.PlayAnimationByName(self.m_rootObj, "goodschapternew_in")
    self.m_showEnterAnim = false
  end
  local store_config = self.m_panelData
  self.iStoreId = store_config.storeData.iStoreId
  local pre_iGoodsId = self.iGoodsId
  self.goodsChapterCfg, self.server_data = MallGoodsChapterManager:GetCurStoreBaseGoodsChapterCfg()
  if not self.goodsChapterCfg then
    log.error("MallGoodsChapterSubPanel:OnFreshData Error! Wrong ServerData!")
    return
  end
  self.iGoodsId = self.goodsChapterCfg.m_GoodsID
  if pre_iGoodsId and pre_iGoodsId ~= self.iGoodsId then
    StackTop:Push(UIDefines.ID_FORM_MALLGOODSCHAPTERUPGRADE, {
      call_back = function()
        self.need_active_init = true
        self:ReFreshUI()
        TimeService:SetTimer(0.1, 1, function()
          local content = self.m_scrollview.transform:Find("Viewport/Content")
          if content then
            content:GetComponent("RectTransform").anchoredPosition = Vector3(0, 0, 0)
          end
        end)
        self.m_lastBuyState = false
        self.m_curBuyState = false
      end
    })
  else
    self:ReFreshUI()
  end
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
  self.have_RewardCanGet = MallGoodsChapterManager:HaveAnyRewardsAvailable()
  self.m_curBuyState = self.is_Purchased
  self.m_lastBuyState = self.is_Purchased
  self.m_bg_getall_normal:SetActive(self.have_RewardCanGet)
  self.m_bg_getall_grey:SetActive(not self.have_RewardCanGet)
end

function MallGoodsChapterNewSubPanel:RefreshTitle()
  self.m_txt_title_Text.text = self.goodsChapterCfg.m_mItemName
  self.m_txt_des_Text.text = self.goodsChapterCfg.m_mItemHint
  local discount = self.goodsChapterCfg.m_DiscountNum or 0
  self.m_txt_point_Text.text = discount .. "%"
  self.m_txt_tag_Text.text = discount .. "%"
end

function MallGoodsChapterNewSubPanel:RefreshRewardItemList()
  local finData = {}
  local dataList = MallGoodsChapterManager:GetSmallLevelData(self.iGoodsId)
  for _, v in ipairs(dataList) do
    table.insert(finData, {
      freeDataCfg = v.freeData,
      payDataCfg = v.payData,
      server_data = self.server_data,
      iStoreId = self.iStoreId
    })
  end
  if #finData <= maxNoScorll then
    UILuaHelper.SetScrollViewEnable(self.m_scrollview, false)
  else
    UILuaHelper.SetScrollViewEnable(self.m_scrollview, true)
  end
  self.m_ListInfinityGrid:ShowItemList(finData)
end

function MallGoodsChapterNewSubPanel:OnActivePanel()
  self:AddEventListeners()
end

function MallGoodsChapterNewSubPanel:OnInactivePanel()
  self.m_lastBuyState = false
  self.m_curBuyState = false
  self.m_showEnterAnim = true
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
  self:addEventListener("eGameEvent_RefreshBaseStoreChapter", handler(self, self.OnFreshData))
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

function MallGoodsChapterNewSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  MallGoodsChapterNewSubPanel.super.OnDestroy(self)
end

return MallGoodsChapterNewSubPanel
