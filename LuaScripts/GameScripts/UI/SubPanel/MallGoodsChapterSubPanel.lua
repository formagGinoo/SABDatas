local UISubPanelBase = require("UI/Common/UISubPanelBase")
local MallGoodsChapterSubPanel = class("MallGoodsChapterSubPanel", UISubPanelBase)

function MallGoodsChapterSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_goods_list_InfinityGrid, "PayStore/GoodsChapterLevelItem")
  self.m_grayImgMaterial = self.m_img_gray_Image.material
  self.need_active_init = true
end

function MallGoodsChapterSubPanel:OnFreshData()
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
        UILuaHelper.PlayAnimationByName(self.m_rootObj, "Mall_Main_Chapter_in")
        self.m_goods_list:SetActive(false)
        self.m_goods_list:SetActive(true)
      end
    })
    UILuaHelper.PlayAnimationByName(self.m_pnl_purchase, "Mall_Main_Chapter_purchasein")
  else
    self:ReFreshUI()
  end
end

function MallGoodsChapterSubPanel:ReFreshUI()
  self.goodsChapterLevelList = MallGoodsChapterManager:GetStoreBaseGoodsChapterListByID(self.goodsChapterCfg.m_GoodsID)
  self.have_RewardCanGet = MallGoodsChapterManager:HaveAnyRewardsAvailable()
  if self.have_RewardCanGet then
    self.m_img_bg_red_Image.material = nil
  else
    self.m_img_bg_red_Image.material = self.m_grayImgMaterial
  end
  self.m_txt_title_Text.text = self.goodsChapterCfg.m_mItemName
  self.m_txt_purchase_tips_Text.text = self.goodsChapterCfg.m_mItemHint
  self:FreshGoodsInfo()
  self:FreshFreeItem()
  self:FreshPaidUnlockItem()
end

function MallGoodsChapterSubPanel:FreshGoodsInfo()
  local goods_reward = utils.changeCSArrayToLuaTable(self.goodsChapterCfg.m_ItemID)[1]
  UILuaHelper.SetAtlasSprite(self.m_icon_gift_purchase_Image, ItemManager:GetItemIconPathByID(goods_reward[1]))
  self.m_txt_num_purchase_Text.text = "X" .. goods_reward[2]
  self.goods_reward = goods_reward
  local productID = self.goodsChapterCfg.m_ProductID
  self.m_txt_price_Text.text = IAPManager:GetProductPrice(productID, true)
end

function MallGoodsChapterSubPanel:FreshFreeItem()
  local server_data = self.server_data
  local is_Purchased = server_data and server_data.iBuyTime > 0 and true or false
  if not self.purchasing then
    self.m_pnl_purchase:SetActive(not is_Purchased)
  end
  local free_config = MallGoodsChapterManager:HaveFreeLevelRewardCanGet(self.iGoodsId)
  local level_id = free_config.m_MainLevelID
  local is_free_unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, level_id)
  self.m_mask_lock_silver:SetActive(not is_free_unlock)
  local is_free_got = server_data and server_data.mLevelInfo[free_config.m_Level] and true or false
  self.m_icon_received_silver:SetActive(is_free_got)
  self.m_btn_collection_sliver:SetActive(not is_free_got and is_free_unlock)
  local free_reward_list = utils.changeCSArrayToLuaTable(free_config.m_FreeReward) or {}
  local free_reward = free_reward_list[1]
  UILuaHelper.SetAtlasSprite(self.m_icon_gift_sliver_Image, ItemManager:GetItemIconPathByID(free_reward[1]))
  self.m_txt_num_silver_Text.text = "X" .. free_reward[2]
  self.free_reward = free_reward
  self.free_Level = free_config.m_Level
  self.m_txt_chapter_sliver_Text.text = free_config.m_mLevelName
end

function MallGoodsChapterSubPanel:FreshPaidUnlockItem()
  local datas = {}
  for _, v in ipairs(self.goodsChapterLevelList) do
    if v.m_Type == MTTDProto.BaseStoreChapterRewardType_Pay then
      table.insert(datas, {
        config = v,
        server_data = self.server_data,
        iStoreId = self.iStoreId
      })
    end
  end
  self.m_ListInfinityGrid:ShowItemList(datas)
  local data = self.server_data
  local is_Purchased = data and data.iBuyTime > 0 and true or false
  if not is_Purchased then
    self.m_ListInfinityGrid:LocateTo(0)
  end
  if is_Purchased and self.need_active_init then
    for i, v in ipairs(datas) do
      local level_id = v.config.m_MainLevelID
      local is_unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, level_id)
      local is_got = data and data.mLevelInfo[v.config.m_Level] and true or false
      if not (not is_unlock or is_got) or not is_unlock then
        self.m_ListInfinityGrid:LocateTo(i - 1)
        break
      end
    end
    self.need_active_init = false
  end
end

function MallGoodsChapterSubPanel:PlayPurchaseAni()
  self.purchasing = false
  self.m_pnl_purchase:SetActive(true)
  UILuaHelper.PlayAnimationByName(self.m_pnl_purchase, "Mall_Main_Chapter_purchase")
  GlobalManagerIns:TriggerWwiseBGMState(72)
  self.timer = TimeService:SetTimer(1.6, 1, function()
    self.m_pnl_purchase:SetActive(false)
  end)
end

function MallGoodsChapterSubPanel:OnInactivePanel()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  self.is_playing = nil
  self:clearEventListener()
  self.purchasing = false
end

function MallGoodsChapterSubPanel:OnActivePanel()
  self.need_active_init = true
  self:AddEventListeners()
end

function MallGoodsChapterSubPanel:OnBtnpurchaseClicked()
  self.purchasing = true
  MallGoodsChapterManager:RqsBaseStoreBuyGoods(self.iStoreId, self.goodsChapterCfg.m_GoodsID, self.goodsChapterCfg.m_ProductID, self.goodsChapterCfg.m_ProductSubID, {
    productName = self.goodsChapterCfg.m_mItemName,
    productDesc = self.goodsChapterCfg.m_mItemHint
  })
end

function MallGoodsChapterSubPanel:OnIcongiftpurchaseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({
    iID = self.goods_reward[1],
    iNum = self.goods_reward[2]
  })
end

function MallGoodsChapterSubPanel:OnIcongiftsliverClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({
    iID = self.free_reward[1],
    iNum = self.free_reward[2]
  })
end

function MallGoodsChapterSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_RefreshBaseStoreChapter", handler(self, self.OnFreshData))
  self:addEventListener("eGameEvent_IAPDeliveryOnCloseRewardUI", handler(self, self.PlayPurchaseAni))
end

function MallGoodsChapterSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function MallGoodsChapterSubPanel:OnBtncollectionsliverClicked()
  MallGoodsChapterManager:RqsGetBaseStoreChapterReward(self.iStoreId, self.goodsChapterCfg.m_GoodsID, self.free_Level, false)
end

function MallGoodsChapterSubPanel:OnBtntakeallClicked()
  if self.have_RewardCanGet then
    MallGoodsChapterManager:RqsGetBaseStoreChapterReward(self.iStoreId, self.goodsChapterCfg.m_GoodsID, 0, true)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(40041))
  end
end

function MallGoodsChapterSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  MallGoodsChapterSubPanel.super.OnDestroy(self)
end

return MallGoodsChapterSubPanel
