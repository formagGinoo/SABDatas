local UISubPanelBase = require("UI/Common/UISubPanelBase")
local FashionStoreSubPanel = class("FashionStoreSubPanel", UISubPanelBase)

function FashionStoreSubPanel:OnInit()
  self.m_HeroFashion = HeroManager:GetHeroFashion()
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_SpineStrCfg = nil
  self.m_selTabIndex = nil
  self.m_cutDownTimeTab = {}
  self.m_cutDownToBeReleasedTimeTab = {}
end

function FashionStoreSubPanel:OnInactivePanel()
  self:CheckRecycleSpine()
  self:RemoveAllEventListeners()
  self:ResetTimer()
  self:ResetToBeReleasedTimer()
end

function FashionStoreSubPanel:OnActivePanel()
  self:RemoveAllEventListeners()
  self:AddEventListeners()
end

function FashionStoreSubPanel:ResetTimer()
  if table.getn(self.m_cutDownTimeTab) > 0 then
    for i, v in pairs(self.m_cutDownTimeTab) do
      TimeService:KillTimer(self.m_cutDownTimeTab[i])
      self.m_cutDownTimeTab[i] = nil
    end
    self.m_cutDownTimeTab = {}
  end
end

function FashionStoreSubPanel:ResetToBeReleasedTimer()
  if table.getn(self.m_cutDownToBeReleasedTimeTab) > 0 then
    for i, v in pairs(self.m_cutDownToBeReleasedTimeTab) do
      TimeService:KillTimer(self.m_cutDownToBeReleasedTimeTab[i])
      self.m_cutDownToBeReleasedTimeTab[i] = nil
    end
  end
  self.m_cutDownToBeReleasedTimeTab = {}
end

function FashionStoreSubPanel:OnClosePanel()
  self.m_selTabIndex = nil
  self:ResetTimer()
  self:ResetToBeReleasedTimer()
end

function FashionStoreSubPanel:OnFreshData()
  self.m_stActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not self.m_stActivity then
    return
  end
  self.m_storeData = self.m_panelData.storeData
  if not self.m_storeData then
    return
  end
  self.m_selTabIndex = self.m_selTabIndex or 1
  self.m_shopData = self:GenerateShopData()
  self:refreshLoopScroll()
  self:ChooseGoods()
  if self.m_loop_scroll_view and table.getn(self.m_shopData) > 0 then
    self.m_loop_scroll_view:moveToCellIndex(1)
  end
  self:SetToBeReleasedCommodityRefresh()
end

function FashionStoreSubPanel:ChooseGoods()
  self:RefreshShopItem()
  self:RefreshSpine()
  self:OnRefreshGiftPoint()
end

function FashionStoreSubPanel:RefreshShopItem()
  if table.getn(self.m_shopData) > 0 and self.m_shopData[self.m_selTabIndex] and self.m_HeroFashion then
    local data = self.m_shopData[self.m_selTabIndex]
    local goodsCfg = data.goodsCfg
    local skinCfg = data.skinCfg
    self.m_SpineStrCfg = skinCfg.m_Spine
    local isHaveFashion = self.m_HeroFashion:IsFashionHave(skinCfg.m_FashionID)
    UILuaHelper.SetActive(self.m_btn_had, isHaveFashion)
    UILuaHelper.SetActive(self.m_btn_price, not isHaveFashion)
    self.m_skin_name_Text.text = skinCfg.m_mFashionName
    local heroCfg = HeroManager:GetHeroConfigByID(skinCfg.m_CharacterId)
    if heroCfg then
      self.m_txt_name_Text.text = heroCfg.m_mShortname
    end
    local szIcon = ResourceUtil:GetHeroSkinIconPath(skinCfg.m_FashionID, skinCfg)
    if szIcon and self.m_img_head then
      local img_head = self.m_img_head:GetComponent("CircleImage")
      UILuaHelper.SetBaseImageAtlasSprite(img_head, szIcon)
    end
    self.m_txt_yes_Text.text = IAPManager:GetProductPrice(goodsCfg.sProductId, true)
    UILuaHelper.SetActive(self.m_mark_limit_time, goodsCfg.iRemovalTime and 0 < goodsCfg.iRemovalTime)
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_mark_limit_time)
  end
end

function FashionStoreSubPanel:GenerateShopData()
  local list = {}
  local goodsTable = self.m_stActivity:GetFashionStoreCommodity()
  for i, v in pairs(goodsTable) do
    local skinId
    for m = 1, table.getn(v.vReward) do
      local good = v.vReward[m]
      if good then
        skinId = good.iID
        break
      end
    end
    if skinId and self.m_HeroFashion then
      local isHaveFashion = self.m_HeroFashion:IsFashionHave(skinId)
      local skinCfg = self:GetSkinCfg(skinId)
      list[#list + 1] = {
        goodsCfg = v,
        isHaveFashion = isHaveFashion,
        skinCfg = skinCfg,
        index = tonumber(v.goods_index)
      }
    else
      log.error("FashionStore Data is Error !!!")
    end
  end
  if table.getn(list) > 0 then
    local function sortFun(data1, data2)
      local goodsCfg1 = data1.goodsCfg or {}
      
      local goodsCfg2 = data2.goodsCfg or {}
      local isHaveFashion1 = data1.isHaveFashion and 1 or 0
      local isHaveFashion2 = data2.isHaveFashion and 1 or 0
      local iRemovalTime1 = 0 < (goodsCfg1.iRemovalTime or 0) and 1 or 0
      local iRemovalTime2 = 0 < (goodsCfg2.iRemovalTime or 0) and 1 or 0
      local index1 = data1.index
      local index2 = data2.index
      if isHaveFashion1 == isHaveFashion2 then
        if iRemovalTime1 == iRemovalTime2 then
          return index1 > index2
        else
          return iRemovalTime1 > iRemovalTime2
        end
      else
        return isHaveFashion1 < isHaveFashion2
      end
    end
    
    table.sort(list, sortFun)
  end
  if table.getn(list) < 4 then
    for i = table.getn(list) + 1, 4 do
      list[i] = {}
    end
  end
  return list
end

function FashionStoreSubPanel:GetSkinCfg(skinId)
  if not self.m_FashionInfo then
    self.m_FashionInfo = ConfigManager:GetConfigInsByName("FashionInfo")
  end
  if skinId and self.m_FashionInfo then
    local skinCfg = self.m_FashionInfo:GetValue_ByFashionID(skinId)
    if skinCfg:GetError() then
      log.error("BattlePass skinCfgID Cannot Find Check Config: " .. skinId)
      return
    end
    return skinCfg
  end
end

function FashionStoreSubPanel:AddEventListeners()
end

function FashionStoreSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function FashionStoreSubPanel:refreshLoopScroll()
  local all_cell_size = {}
  for i, v in ipairs(self.m_shopData or {}) do
    if self.m_selTabIndex == i then
      all_cell_size[i] = Vector2.New(501, 258)
    else
      all_cell_size[i] = Vector2.New(501, 180)
    end
  end
  self:ResetTimer()
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_skin_list
    local params = {
      show_data = self.m_shopData,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      all_cell_size = all_cell_size,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "cell_" .. index and cell_data and cell_data.skinCfg then
          CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
          local refreshRedDot = false
          if LocalDataManager:GetIntSimple("Red_Point_FashionStore_" .. tostring(cell_data.skinCfg.m_FashionID) .. tostring(cell_data.index), 0) == 0 then
            LocalDataManager:SetIntSimple("Red_Point_FashionStore_" .. tostring(cell_data.skinCfg.m_FashionID) .. tostring(cell_data.index), 1)
            self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
              redDotKey = RedDotDefine.ModuleType.MallFashionTab,
              count = self.m_stActivity:CheckFashionStoreRedPoint() and 1 or 0
            })
            refreshRedDot = true
          end
          if self.m_selTabIndex == index and not refreshRedDot then
            return
          end
          self.m_selTabIndex = index
          self:refreshLoopScroll()
          self:ChooseGoods()
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(self.m_shopData, true, all_cell_size)
  end
end

function FashionStoreSubPanel:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  if cell_data.goodsCfg and cell_data.skinCfg then
    local goodsCfg = cell_data.goodsCfg or {}
    local skinCfg = cell_data.skinCfg or {}
    local iRemovalTime = goodsCfg.iRemovalTime or 0
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_choose_item", index == self.m_selTabIndex)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_choose_select", index == self.m_selTabIndex)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_item", index ~= self.m_selTabIndex)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_choose_name", skinCfg.m_mFashionName)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_normal_name", skinCfg.m_mFashionName)
    LuaBehaviourUtil.setImg(luaBehaviour, "m_choose_Icon", goodsCfg.sGoodsPic)
    LuaBehaviourUtil.setImg(luaBehaviour, "m_normal_Icon", goodsCfg.sGoodsPic)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_Icon", true)
    local redPoint = LocalDataManager:GetIntSimple("Red_Point_FashionStore_" .. tostring(skinCfg.m_FashionID) .. tostring(cell_data.index), 0)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_choose_new", redPoint == 0 and not cell_data.isHaveFashion)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_new", redPoint == 0 and not cell_data.isHaveFashion)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_choose_purchased", cell_data.isHaveFashion)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_purchased", cell_data.isHaveFashion)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_Choose_lock", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_lock", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_choose_limit_time", index == self.m_selTabIndex and 0 < iRemovalTime)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_limit_time", index ~= self.m_selTabIndex and 0 < iRemovalTime)
    if self.m_cutDownTimeTab[cell_data.index] then
      TimeService:KillTimer(self.m_cutDownTimeTab[cell_data.index])
      self.m_cutDownTimeTab[cell_data.index] = nil
    end
    if 0 < iRemovalTime then
      local curTime = TimeUtil:GetServerTimeS()
      local left_time = iRemovalTime - curTime
      local strTime = TimeUtil:SecondsToFormatCNStr3(left_time, true)
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_choose_time", strTime)
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_normal_time", strTime)
      self.m_cutDownTimeTab[cell_data.index] = TimeService:SetTimer(1, -1, function()
        left_time = left_time - 1
        if left_time < 0 and self.m_cutDownTimeTab and self.m_cutDownTimeTab[cell_data.index] then
          TimeService:KillTimer(self.m_cutDownTimeTab[cell_data.index])
          self.m_cutDownTimeTab[cell_data.index] = nil
          self:OnFreshData()
        else
          local time = TimeUtil:SecondsToFormatCNStr3(left_time, true)
          LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_choose_time", time)
          LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_normal_time", time)
        end
      end)
    end
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_lock", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_choose_item", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_item", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_Icon", false)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_normal_name", "")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_purchased", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_new", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_normal_limit_time", false)
  end
end

function FashionStoreSubPanel:RefreshSpine()
  self:LoadHeroSpine(self.m_SpineStrCfg)
end

function FashionStoreSubPanel:CheckRecycleSpine()
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
    self.m_SpineStrCfg = nil
  end
end

function FashionStoreSubPanel:LoadHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, SpinePlaceCfg.HeroFashionStore, self.m_player_root, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SetActive(self.m_curHeroSpineObj.spinePlaceObj, true)
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
      UILuaHelper.PlayAnimationByName(self.m_player_root, "activity_panel_skinshop_swich")
    end)
  end
end

function FashionStoreSubPanel:OnBtnpriceClicked()
  if self.m_storeData and table.getn(self.m_shopData) > 0 and self.m_shopData[self.m_selTabIndex] then
    local goodsCfg = self.m_shopData[self.m_selTabIndex].goodsCfg
    local skinCfg = self.m_shopData[self.m_selTabIndex].skinCfg
    local ProductInfo = {
      StoreID = self.m_storeData.iStoreId,
      GoodsID = goodsCfg.iGoodsId,
      productId = goodsCfg.sProductId,
      productSubId = goodsCfg.iProductSubId,
      iStoreType = MTTDProto.IAPStoreType_ActPayStore,
      productName = skinCfg.m_mFashionName,
      productDesc = self.m_stActivity:getLangText(goodsCfg.sGoodsDesc),
      iActivityId = self.m_stActivity:getID()
    }
    IAPManager:BuyProductByStoreType(ProductInfo, nil, function(isSuccess, param1, param2)
      if not isSuccess then
        IAPManager:OnCallbackFail(param1, param2)
      end
    end)
  end
end

function FashionStoreSubPanel:OnBtnhadClicked()
end

function FashionStoreSubPanel:OnBtnturnClicked()
  if self.m_shopData and self.m_shopData[self.m_selTabIndex] then
    local data = self.m_shopData[self.m_selTabIndex]
    local skinCfg = data.skinCfg
    if skinCfg then
      StackFlow:Push(UIDefines.ID_FORM_FASHION, {
        heroID = skinCfg.m_CharacterId,
        fashionID = skinCfg.m_FashionID
      })
    end
  end
end

function FashionStoreSubPanel:OnBtnsearchClicked()
  if self.m_shopData and self.m_shopData[self.m_selTabIndex] then
    local data = self.m_shopData[self.m_selTabIndex]
    local skinCfg = data.skinCfg
    StackFlow:Push(UIDefines.ID_FORM_HEROPREVIEW, {
      fashionId = skinCfg.m_FashionID
    })
  end
end

function FashionStoreSubPanel:SetToBeReleasedCommodityRefresh()
  self:ResetToBeReleasedTimer()
  local goodsTable = self.m_stActivity:GetFashionStoreToBeReleasedCommodity()
  for i, goods in ipairs(goodsTable) do
    if goods.iLaunchTime and goods.iLaunchTime > 0 then
      local curTime = TimeUtil:GetServerTimeS()
      local left_time = goods.iLaunchTime - curTime
      if 0 < left_time then
        self.m_cutDownToBeReleasedTimeTab[goods.iGoodsId] = TimeService:SetTimer(1, -1, function()
          left_time = left_time - 1
          if left_time < 0 and self.m_cutDownToBeReleasedTimeTab and self.m_cutDownToBeReleasedTimeTab[goods.iGoodsId] then
            TimeService:KillTimer(self.m_cutDownToBeReleasedTimeTab[goods.iGoodsId])
            self.m_cutDownToBeReleasedTimeTab[goods.iGoodsId] = nil
            self.m_selTabIndex = 1
            self:OnFreshData()
            self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
              redDotKey = RedDotDefine.ModuleType.MallFashionTab,
              count = self.m_stActivity:CheckFashionStoreRedPoint() and 1 or 0
            })
          end
        end)
      end
    end
  end
end

function FashionStoreSubPanel:OnRefreshGiftPoint()
  if utils.isNull(self.m_packgift_point) then
    return
  end
  local data = self.m_shopData[self.m_selTabIndex]
  if not (data and data.goodsCfg) or not data.goodsCfg.sProductId then
    self.m_packgift_point:SetActive(false)
    return
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(data.goodsCfg.sProductId)
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

function FashionStoreSubPanel:GetDownloadResourceExtra(subPanelCfg)
  local vPackage = {}
  local vResourceExtra = {}
  local stActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if stActivity and stActivity.GetFashionStoreCommoditySpine then
    local skinIdList = stActivity:GetFashionStoreCommoditySpine()
    if table.getn(skinIdList) > 0 then
      for i, skinId in pairs(skinIdList) do
        local skinCfg = self:GetSkinCfg(skinId)
        if skinCfg then
          vResourceExtra[#vResourceExtra + 1] = {
            sName = skinCfg.m_Spine,
            eType = DownloadManager.ResourceType.UI
          }
        end
      end
    end
  end
  return vPackage, vResourceExtra
end

return FashionStoreSubPanel
