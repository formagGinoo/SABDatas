local UISubPanelBase = require("UI/Common/UISubPanelBase")
local MallPushGiftSubPanel = class("MallPushGiftSubPanel", UISubPanelBase)
local CHANGE_TAG_ANIM_STR = "activity_panel_fixedgift_item_all"

function MallPushGiftSubPanel:OnInit()
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_hero_list_InfinityGrid, "PayStore/PushGiftItem")
  self.m_selTabIndex = 1
  self.m_selObj = nil
  self.m_tabObjTab = {}
end

function MallPushGiftSubPanel:OnUpdate(dt)
  self.m_ListInfinityGrid:OnUpdate(dt)
end

function MallPushGiftSubPanel:OnFreshData()
  self.m_giftConfig = self.m_panelData.storeData
  self.m_stActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PushGift)
  self.m_giftData = self.m_stActivity:GetInTimePushGift()
  self.m_stPushGiftActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PushGift)
  self.m_selTabIndex = 1
  self.m_GiftShowTab = {}
  self.openTime = TimeUtil:GetServerTimeS()
  self.m_selObj = nil
  if not self.m_giftData then
    self:broadcastEvent("eGameEvent_Activity_RefreshPayStore")
    return
  end
  self.m_enterFlag = true
  self.m_GiftShowTab = self:GeneratedData()
  self.m_GiftNum = #self.m_GiftShowTab
  self:OnEnterUI()
  self.m_enterFlag = false
end

function MallPushGiftSubPanel:OnInactivePanel()
  self.openTime = nil
  self.m_selTabIndex = 1
  self.m_selObj = nil
end

function MallPushGiftSubPanel:SendReportData()
  if self.openTime == nil then
    return
  end
  if self.m_selTabIndex == nil or self.m_selTabIndex < 1 then
    return
  end
  local second = TimeUtil:GetServerTimeS() - self.openTime
  if second < 2 then
    return
  end
  local store = self.m_GiftShowTab[self.m_selTabIndex]
  if not store then
    return
  end
  local goodsData = store.mGoods
  if not goodsData then
    return
  end
  local serverData = self.m_giftData[self.m_selTabIndex]
  if not serverData then
    return
  end
  local sGoods = ""
  local sGoodsIndex = ""
  for i, v in pairs(goodsData) do
    sGoodsIndex = sGoodsIndex .. tostring(v.iGiftIndex) .. ";"
    for m, n in pairs(v.sGiftItems) do
      sGoods = sGoods .. tostring(v.iGiftIndex) .. "," .. tostring(n.iID) .. "," .. tostring(n.iNum) .. ";"
    end
  end
  local reportData = {
    stayTime = second,
    iGroupIndex = store.iGroupIndex,
    iSubProductID = store.iSubProductID,
    iActivityID = store.iActivityID,
    storeId = self.m_giftConfig.iStoreId,
    iExpireTime = store.iExpireTime,
    sGoods = sGoods,
    sGoodsIndex = sGoodsIndex,
    iTriggerParam = serverData.iTriggerParam,
    iTotalRecharge = serverData.iTotalRecharge,
    iTriggerIndex = serverData.iGroupIndex,
    storeDes = store.sStoreDesc
  }
  ReportManager:ReportProductView(reportData)
  self.openTime = TimeUtil:GetServerTimeS()
end

function MallPushGiftSubPanel:OnEnterUI()
  self:OnSelectTable(1)
  local data = self.m_GiftShowTab[1]
  if data then
    local expireTime = LocalDataManager:GetIntSimple("Push_Gift_" .. tostring(data.iActivityID) .. tostring(data.iSubProductID), 0)
    if expireTime == 0 or expireTime ~= data.iExpireTime then
      LocalDataManager:SetIntSimple("Push_Gift_" .. tostring(data.iActivityID) .. tostring(data.iSubProductID), data.iExpireTime)
      ActivityManager:RefreshPushGiftRedPoint()
    end
    self:refreshTabLoopScroll()
  end
end

function MallPushGiftSubPanel:GeneratedData()
  local giftTab = {}
  for i, v in ipairs(self.m_giftData) do
    local data = self.m_stActivity:GetGiftGroupDataByGroupIndex(v.iGroupIndex)
    if data and data.stPushGoodsConfig and data.stPushGoodsConfig.mGoods then
      local mGoods = data.stPushGoodsConfig.mGoods
      local goodsTab = {}
      for _, index in ipairs(v.vGiftIndex) do
        goodsTab[#goodsTab + 1] = mGoods[index]
      end
      
      local function sortFunc(data1, data2)
        return data1.iGiftIndex < data2.iGiftIndex
      end
      
      table.sort(goodsTab, sortFunc)
      local iconTab = string.split(data.sIcon, ";")
      for p = 1, #goodsTab do
        goodsTab[p].sIcon = iconTab[p]
        goodsTab[p].iSubProductID = v.iSubProductID
        goodsTab[p].iStoreId = self.m_giftConfig.iStoreId
        goodsTab[p].iExpireTime = v.iExpireTime
        goodsTab[p].iTriggerParam = v.iTriggerParam
        goodsTab[p].iTotalRecharge = v.iTotalRecharge
        goodsTab[p].iTriggerIndex = v.iGroupIndex
        goodsTab[p].giftPushForm = "MallPushGiftSubPanel"
        goodsTab[p].sortIndex = p
      end
      giftTab[#giftTab + 1] = {
        iExpireTime = v.iExpireTime,
        iGroupIndex = v.iGroupIndex,
        iSubProductID = v.iSubProductID,
        iActivityID = v.iActivityID,
        iTimeDuration = data.iTimeDuration,
        iconTab = iconTab,
        sTitle = data.iTitle,
        mGoods = goodsTab
      }
    end
  end
  return giftTab
end

function MallPushGiftSubPanel:refreshTabLoopScroll()
  local prefabHelper = self.m_Content:GetComponent("PrefabHelper")
  utils.ShowPrefabHelper(prefabHelper, function(go, idx, cell_data)
    local transform = go.transform
    local index = idx + 1
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_tab_sel1", self.m_selTabIndex == index)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_title1", self.m_stActivity:getLangText(cell_data.sTitle))
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_title2", self.m_stActivity:getLangText(cell_data.sTitle))
    if self.m_enterFlag and index == 1 then
      self.m_selObj = LuaBehaviourUtil.findGameObject(luaBehaviour, "m_img_tab_sel1")
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_Img_cutline1", self.m_GiftNum ~= index)
    local expireTime = LocalDataManager:GetIntSimple("Push_Gift_" .. tostring(cell_data.iActivityID) .. tostring(cell_data.iSubProductID), 0)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_reddot", expireTime == 0 or expireTime ~= cell_data.iExpireTime)
    local btn = LuaBehaviourUtil.findGameObject(luaBehaviour, "m_pnl_tab"):GetComponent(T_Button)
    UILuaHelper.BindButtonClickManual(self, btn, function()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
      expireTime = LocalDataManager:GetIntSimple("Push_Gift_" .. tostring(cell_data.iActivityID) .. tostring(cell_data.iSubProductID), 0)
      if expireTime == 0 or expireTime ~= cell_data.iExpireTime then
        LocalDataManager:SetIntSimple("Push_Gift_" .. tostring(cell_data.iActivityID) .. tostring(cell_data.iSubProductID), cell_data.iExpireTime)
        ActivityManager:RefreshPushGiftRedPoint()
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_reddot", false)
      end
      if self.m_selTabIndex == index then
        return
      end
      self.m_selTabIndex = index
      if not utils.isNull(self.m_selObj) then
        self.m_selObj:SetActive(false)
      end
      local m_selected_obj = LuaBehaviourUtil.findGameObject(luaBehaviour, "m_img_tab_sel1")
      m_selected_obj:SetActive(true)
      self.m_selObj = m_selected_obj
      self:OnSelectTable(index)
    end)
  end, self.m_GiftShowTab)
end

function MallPushGiftSubPanel:SecondToTimeText(second)
  if second <= 0 then
    return ""
  end
  local lastTime = TimeUtil:SecondsToFormatCNStr4(second)
  self.m_txt_timeleft_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(220020), lastTime)
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self.m_downTimer = TimeService:SetTimer(1, second, function()
    second = second - 1
    if second < 0 then
      TimeService:KillTimer(self.m_downTimer)
      self:broadcastEvent("eGameEvent_Activity_RefreshPayStore")
      return
    end
    local lastTimeCur = TimeUtil:SecondsToFormatCNStr4(second)
    self.m_txt_timeleft_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(220020), lastTimeCur)
  end)
end

function MallPushGiftSubPanel:RefreshList()
  self.m_giftData = self.m_stActivity:GetInTimePushGift()
  if not self.m_giftData then
    self:broadcastEvent("eGameEvent_Activity_RefreshPayStore")
    return
  end
  self.m_GiftShowTab = self:GeneratedData()
  self.m_GiftNum = #self.m_GiftShowTab
  self:refreshTabLoopScroll()
  self.m_ListInfinityGrid:ReBindAll()
end

function MallPushGiftSubPanel:OnSelectTable(index)
  if self.m_GiftShowTab[index] then
    self.m_ListInfinityGrid:ShowItemList(self.m_GiftShowTab[index].mGoods)
    self.m_ListInfinityGrid:LocateTo(0)
    UILuaHelper.PlayAnimationByName(self.m_hero_list, CHANGE_TAG_ANIM_STR)
    local time = self.m_GiftShowTab[index].iExpireTime - TimeUtil:GetServerTimeS()
    self:SecondToTimeText(time)
  end
  self:SendReportData()
end

function MallPushGiftSubPanel:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
end

return MallPushGiftSubPanel
