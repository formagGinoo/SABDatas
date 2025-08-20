local BaseManager = require("Manager/Base/BaseManager")
local MallGoodsChapterManager = class("MallGoodsChapterManager", BaseManager)

function MallGoodsChapterManager:OnCreate()
  self.server_data = nil
  self.all_StoreBaseGoodsChapter_config = nil
  self.all_GoodsChapterList = nil
end

function MallGoodsChapterManager:OnUpdate(dt)
end

function MallGoodsChapterManager:OnDailyReset()
end

function MallGoodsChapterManager:OnInitNetwork()
  RPCS():Listen_Push_BaseStoreChapter(handler(self, self.OnPushBaseStoreChapter), "MallGoodsChapterManager")
end

function MallGoodsChapterManager:OnDestroy()
end

function MallGoodsChapterManager:OnPushBaseStoreChapter(data)
  self.server_data = data
  self:broadcastEvent("eGameEvent_RefreshBaseStoreChapter", {isBuy = true})
  self:CheckUpdateMallGoodsChapterHaveRed()
end

function MallGoodsChapterManager:RqsGetBaseStoreChapter(iStoreId)
  local rqs_msg = MTTDProto.Cmd_BaseStore_GetBaseStoreChapter_CS()
  rqs_msg.iStoreId = iStoreId
  RPCS():BaseStore_GetBaseStoreChapter(rqs_msg, handler(self, self.OnGetBaseStoreChapterSC))
end

function MallGoodsChapterManager:OnGetBaseStoreChapterSC(data)
  self.server_data = data
  self:broadcastEvent("eGameEvent_RefreshBaseStoreChapter")
  self:CheckUpdateMallGoodsChapterHaveRed()
end

function MallGoodsChapterManager:RqsGetBaseStoreChapterReward(iStoreId, iGoodsId, iLevel, is_all)
  self.iStoreId = iStoreId
  local msg = MTTDProto.Cmd_BaseStore_GetBaseStoreChapterReward_CS()
  msg.iStoreId = iStoreId
  msg.iGoodsId = iGoodsId
  msg.iLevel = iLevel
  msg.bAll = is_all
  RPCS():BaseStore_GetBaseStoreChapterReward(msg, handler(self, self.OnGetBaseStoreChapterRewardSC))
end

function MallGoodsChapterManager:OnGetBaseStoreChapterRewardSC(data)
  local reward_list = data.vFreeReward
  for i, v in ipairs(data.vPayReward) do
    local is_merge = true
    for ii, vv in ipairs(reward_list) do
      if v.iID == vv.iID then
        reward_list[ii].iNum = reward_list[ii].iNum + v.iNum
        is_merge = false
        break
      end
    end
    if is_merge then
      table.insert(reward_list, v)
    end
  end
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list, function()
      self:RqsGetBaseStoreChapter(self.iStoreId)
    end)
  end
  self:CheckUpdateMallGoodsChapterHaveRed()
end

function MallGoodsChapterManager:RqsBaseStoreBuyGoods(iStoreId, iGoodsId, sProductID, productSubId, exParam)
  local baseStoreBuyParam = MTTDProto.CmdBaseStoreBuyParam()
  baseStoreBuyParam.iStoreId = iStoreId
  baseStoreBuyParam.iGoodsId = iGoodsId
  local storeParam = sdp.pack(baseStoreBuyParam)
  local ProductInfo = {
    StoreID = iStoreId,
    GoodsID = iGoodsId,
    productId = sProductID,
    productSubId = productSubId,
    iStoreType = MTTDProto.IAPStoreType_BaseStore,
    productName = exParam.productName,
    productDesc = exParam.productDesc
  }
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, handler(self, self.OnBaseStoreBuyGoodsSC))
end

function MallGoodsChapterManager:OnBaseStoreBuyGoodsSC(isSuccess, param1, param2)
  if not isSuccess then
    IAPManager:OnCallbackFail(param1, param2)
  end
end

function MallGoodsChapterManager:GetStoreBaseGoodsChapterCfgByID(m_GoodsID)
  local StoreBaseGoodsChapterIns = ConfigManager:GetConfigInsByName("StoreBaseGoodsChapter")
  local config = StoreBaseGoodsChapterIns:GetValue_ByGoodsID(m_GoodsID)
  if config:GetError() then
    log.error("GetStoreBaseGoodsChapterCfgByID is error,  id  " .. tostring(m_GoodsID))
    return
  end
  return config
end

function MallGoodsChapterManager:GetAllStoreBaseGoodsChapterCfg()
  if self.all_StoreBaseGoodsChapter_config then
    return self.all_StoreBaseGoodsChapter_config
  end
  local StoreBaseGoodsChapterIns = ConfigManager:GetConfigInsByName("StoreBaseGoodsChapter")
  local all_config_dic = StoreBaseGoodsChapterIns:GetAll()
  local all_config = {}
  for _, v in pairs(all_config_dic) do
    if v.m_GoodsID then
      table.insert(all_config, v)
    end
  end
  table.sort(all_config, function(a, b)
    return a.m_GoodsID < b.m_GoodsID
  end)
  self.all_StoreBaseGoodsChapter_config = all_config
  return self.all_StoreBaseGoodsChapter_config
end

function MallGoodsChapterManager:GetStoreBaseGoodsChapterListByID(m_GoodsID)
  if self.all_GoodsChapterList and self.all_GoodsChapterList[m_GoodsID] then
    return self.all_GoodsChapterList[m_GoodsID]
  end
  local StoreBaseGoodsChapterListIns = ConfigManager:GetConfigInsByName("StoreBaseGoodsChapterList")
  local config = StoreBaseGoodsChapterListIns:GetValue_ByGoodsID(m_GoodsID)
  local all_config = {}
  for key, v in pairs(config) do
    if v.m_GoodsID then
      all_config[v.m_Level] = v
    end
  end
  self.all_GoodsChapterList = self.all_GoodsChapterList or {}
  self.all_GoodsChapterList[m_GoodsID] = all_config
  return self.all_GoodsChapterList[m_GoodsID]
end

function MallGoodsChapterManager:__GetCurGiftInfo(config)
  if not self.server_data then
    return
  end
  local server_chapter_data = self.server_data.stChapter.mChapter
  local data = server_chapter_data[config.m_GoodsID]
  if data then
    local GoodsChapterCfgList = self:GetStoreBaseGoodsChapterListByID(data.iGoodsId)
    local count = 0
    for key, v in pairs(data.mLevelInfo) do
      count = count + 1
    end
    if count >= #GoodsChapterCfgList + 1 then
      local next_goodsid = config.m_NextGoods
      if next_goodsid and 0 < next_goodsid then
        return self:__GetCurGiftInfo(self:GetStoreBaseGoodsChapterCfgByID(next_goodsid))
      else
        return config, data, true
      end
    else
      return config, data
    end
  end
  return config
end

function MallGoodsChapterManager:IsShowGoodChapterGift()
  if not self.server_data then
    return false
  end
  local showGiftList = {}
  local allCfg = self:GetAllStoreBaseGoodsChapterCfg()
  for _, v in pairs(allCfg) do
    local cfg, _, isHide = self:__GetCurGiftInfo(v)
    if not isHide then
      showGiftList[#showGiftList + 1] = cfg
    end
  end
  return table.getn(showGiftList) > 0, showGiftList
end

function MallGoodsChapterManager:GetCurStoreBaseGoodsChapterCfg()
  if not self.server_data then
    return false
  end
  local all_GoodsChapterCfg = self:GetAllStoreBaseGoodsChapterCfg()
  local first_GoodsChapterCfg = all_GoodsChapterCfg[1]
  return self:__GetCurGiftInfo(first_GoodsChapterCfg)
end

function MallGoodsChapterManager:GetServerData()
  return self.server_data
end

function MallGoodsChapterManager:IsLevelRewardCanGet(level_config)
  if not self.server_data then
    return false
  end
  local server_chapter_data = self.server_data.stChapter.mChapter
  local data = server_chapter_data[level_config.m_GoodsID]
  if not data or data.iBuyTime <= 0 then
    return false
  end
  local level_id = level_config.m_MainLevelID
  local is_unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, level_id)
  local is_got = data and data.mLevelInfo[level_config.m_Level] and true or false
  return is_unlock and not is_got
end

function MallGoodsChapterManager:IsFreeLevelRewardCanGet(level_config)
  if not self.server_data then
    return false
  end
  local server_chapter_data = self.server_data.stChapter.mChapter
  local data = server_chapter_data[level_config.m_GoodsID]
  local level = level_config.m_Level
  local level_id = level_config.m_MainLevelID
  local is_unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, level_id)
  local is_PreGot = level == 0 and true or data and data.mLevelInfo[level - 1]
  local is_got = data and data.mLevelInfo[level] and true or false
  return is_unlock and is_PreGot and not is_got
end

function MallGoodsChapterManager:HaveFreeLevelRewardCanGet(m_GoodsID)
  if not self.server_data then
    return false
  end
  local server_chapter_data = self.server_data.stChapter.mChapter
  local data = server_chapter_data[m_GoodsID]
  local goodsChapterLevelList = self:GetStoreBaseGoodsChapterListByID(m_GoodsID)
  if not data then
    return goodsChapterLevelList[0]
  end
  if not data.mLevelInfo[0] then
    return goodsChapterLevelList[0]
  end
  local last_config
  for _, v in ipairs(goodsChapterLevelList) do
    if v.m_Type == MTTDProto.BaseStoreChapterRewardType_Free then
      local level_id = v.m_MainLevelID
      local is_unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, level_id)
      local is_got = data.mLevelInfo[v.m_Level] and true or false
      if is_unlock and not is_got then
        return v
      end
      if not is_unlock then
        return v
      end
      last_config = v
    end
  end
  return last_config
end

function MallGoodsChapterManager:HaveAnyRewardsAvailable()
  local goodsChapterCfgList = self:GetAllStoreBaseGoodsChapterCfg()
  for _, v in pairs(goodsChapterCfgList) do
    local goodsChapterLevelList = self:GetStoreBaseGoodsChapterListByID(v.m_GoodsID)
    for _, v in pairs(goodsChapterLevelList) do
      if v.m_Type == MTTDProto.BaseStoreChapterRewardType_Pay then
        if self:IsLevelRewardCanGet(v) then
          return true
        end
      elseif v.m_Type == MTTDProto.BaseStoreChapterRewardType_Free and self:IsFreeLevelRewardCanGet(v) then
        return true
      end
    end
  end
  return false
end

function MallGoodsChapterManager:HaveRewardAvailableWithGoodsIs(goodID)
  local goodsChapterLevelList = self:GetStoreBaseGoodsChapterListByID(goodID)
  for _, v in pairs(goodsChapterLevelList) do
    if v.m_Type == MTTDProto.BaseStoreChapterRewardType_Pay then
      if self:IsLevelRewardCanGet(v) then
        return true
      end
    elseif v.m_Type == MTTDProto.BaseStoreChapterRewardType_Free and self:IsFreeLevelRewardCanGet(v) then
      return true
    end
  end
  return false
end

function MallGoodsChapterManager:GetSmallLevelData(goodsID)
  local goodsChapterLevelList = self:GetStoreBaseGoodsChapterListByID(goodsID)
  local allData = {}
  local levelDataMap = {}
  for _, v in pairs(goodsChapterLevelList) do
    local level_id = v.m_MainLevelID
    if not levelDataMap[level_id] then
      levelDataMap[level_id] = {
        freeData = {},
        payData = {}
      }
    end
    if v.m_Type == MTTDProto.BaseStoreChapterRewardType_Free then
      table.insert(levelDataMap[level_id].freeData, v)
    elseif v.m_Type == MTTDProto.BaseStoreChapterRewardType_Pay then
      table.insert(levelDataMap[level_id].payData, v)
    end
  end
  for level_id, data in pairs(levelDataMap) do
    table.insert(allData, {
      freeData = data.freeData,
      payData = data.payData
    })
  end
  table.sort(allData, function(a, b)
    if a.freeData[1] and b.freeData[1] then
      return a.freeData[1].m_Level < b.freeData[1].m_Level
    end
  end)
  return allData
end

function MallGoodsChapterManager:Check()
end

function MallGoodsChapterManager:CheckUpdateMallGoodsChapterHaveRed()
  local flag = self:HaveAnyRewardsAvailable()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.MallGoodsChapterTab,
    count = flag and 1 or 0
  })
end

return MallGoodsChapterManager
