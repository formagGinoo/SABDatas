local Form_MallMainNew = class("Form_MallMainNew", require("UI/UIFrames/Form_MallMainNewUI"))
local ItemIns = ConfigManager:GetConfigInsByName("Item")
local PaystoreType2SubPanel = {
  [MTTDProto.CmdActPayStoreType_Up] = "LimitUpPackSubPanel",
  [MTTDProto.CmdActPayStoreType_StepupGift] = "StepGiftSubPanel",
  [MTTDProto.CmdActPayStoreType_PickupGift] = "PickupGiftSubPanel",
  [MTTDProto.CmdActPayStoreType_OpenCard] = "ChainGiftPackSubPanel",
  [MTTDProto.CmdActPayStoreType_OpenNewShop] = "GameOpenGiftSubPanel",
  [MTTDProto.CmdActPayStoreType_OpenBeginner] = "MallNewbieGiftSubPanel",
  [MTTDProto.CmdActPayStoreType_PushGift] = "PushGiftSubPanel",
  [MTTDProto.CmdActPayStoreType_Permanent] = "MallDailyPackSubPanel",
  [MTTDProto.CmdActPayStoreType_MainStage] = "MallGoodsChapterSubPanel",
  [MTTDProto.CmdActPayStoreType_MonthlyCard] = "MallMonthlyCardMainSubPanel",
  [MTTDProto.CmdActPayStoreType_DaimondBuy] = "RechargeSubPanel",
  [MTTDProto.CmdActPayStoreType_SignGift] = "SignGiftFiveSunPanel",
  [MTTDProto.CmdActPayStoreType_FashionStore] = "FashionStoreSubPanel",
  [MTTDProto.CmdActPayStoreType_PickupGiftNew] = "CommonUpPackSubPanel"
}
local TabIdxToRedEunm = {
  [MTTDProto.CmdActPayStoreType_MonthlyCard] = RedDotDefine.ModuleType.MallMonthlyCardTab,
  [MTTDProto.CmdActPayStoreType_MainStage] = RedDotDefine.ModuleType.MallGoodsChapterTab,
  [MTTDProto.CmdActPayStoreType_PushGift] = RedDotDefine.ModuleType.MallPushGiftTab,
  [MTTDProto.CmdActPayStoreType_FashionStore] = RedDotDefine.ModuleType.MallFashionTab,
  [MTTDProto.CmdActPayStoreType_SignGift] = RedDotDefine.ModuleType.MallNewStudentsSupplyPackTab
}
local WindowRedEnum = {
  [1] = RedDotDefine.ModuleType.MallNewbieGiftPackTabl,
  [2] = RedDotDefine.ModuleType.ActivityGiftPackTabl,
  [3] = RedDotDefine.ModuleType.MallDailyPackTabl,
  [8] = RedDotDefine.ModuleType.MallFashionTab
}

function Form_MallMainNew:SetInitParam(param)
end

function Form_MallMainNew:AfterInit()
  self.super.AfterInit(self)
  local root_trans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = root_trans.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome))
  self.m_btn_symbol:SetActive(false)
  local root_trans = self.m_csui.m_uiGameObject.transform
  local resourceBarRoot = root_trans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_MainTabHelper = self.m_MainTabRoot:GetComponent("PrefabHelper")
  self.m_MainTabHelper:RegisterCallback(handler(self, self.OnInitMainTabItem))
  self.m_SubTabHelper = self.m_subTab:GetComponent("PrefabHelper")
  self.m_SubTabHelper:RegisterCallback(handler(self, self.OnInitSubTabItem))
  self.m_MainTabItemCache = {}
  self.m_SubTabItemCache = {}
  self.m_subPanelCache = {}
  self.m_txt_uid_Text.text = "UID:" .. CS.LoginContext.GetContext().AccountID
  self:CheckRegisterRedDot()
end

function Form_MallMainNew:OnActive()
  self.super.OnActive(self)
  self:RefreshResourceBar()
  self:AddEventListeners()
  self.is_GoodsChapterOpen, _, self.is_hide = MallGoodsChapterManager:GetCurStoreBaseGoodsChapterCfg()
  self:InitSubPanelInfo()
  self:InitData()
  self:RefreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(74)
end

function Form_MallMainNew:RefreshResourceBar()
  local isOpen = ActivityManager:OnCheckVoucherControlAndUrl()
  local resourceBarList = {}
  if isOpen then
    if not utils.isNull(self.m_btn_coupon) then
      self.m_btn_coupon:SetActive(true)
    end
    resourceBarList = {
      MTTDProto.SpecialItem_Welfare,
      MTTDProto.SpecialItem_Coin,
      MTTDProto.SpecialItem_ShowDiamond
    }
  else
    if ItemManager:GetItemNum(MTTDProto.SpecialItem_Welfare) > 0 then
      resourceBarList = {
        MTTDProto.SpecialItem_Welfare,
        MTTDProto.SpecialItem_Coin,
        MTTDProto.SpecialItem_ShowDiamond
      }
    else
      resourceBarList = {
        MTTDProto.SpecialItem_Coin,
        MTTDProto.SpecialItem_ShowDiamond
      }
    end
    if not utils.isNull(self.m_btn_coupon) then
      self.m_btn_coupon:SetActive(false)
    end
  end
  self.m_widgetResourceBar:FreshChangeItems(resourceBarList)
end

function Form_MallMainNew:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:ReSetSubPanel()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_MallMainNew:OnUpdate(dt)
  if self.m_subPanelCache then
    for k, v in pairs(self.m_subPanelCache) do
      if v.subPanelLua and v.subPanelLua.OnUpdate then
        v.subPanelLua:OnUpdate(dt)
      end
    end
  end
end

function Form_MallMainNew:OnDestroy()
  self.super.OnDestroy(self)
  self.m_MainTabItemCache = {}
  self.m_SubTabItemCache = {}
  self:ReSetSubPanel()
  if self.m_subPanelCache then
    for k, v in pairs(self.m_subPanelCache) do
      if v.subPanelLua and v.subPanelLua.dispose then
        v.subPanelLua:dispose()
        v.subPanelLua = nil
      end
    end
  end
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_MallMainNew:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_RefreshPayStore", handler(self, self.OnMallDataRefresh))
  self:addEventListener("eGameEvent_Activity_ResetStatus", handler(self, self.OnMallDataRefresh))
  self:addEventListener("eGameEvent_Activity_OtherRefreshRed", handler(self, self.GetOtherActRedState))
  self:addEventListener("eGameEvent_Activity_RefreshPayStoreTimer", handler(self, self.FreshTime))
end

function Form_MallMainNew:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_MallMainNew:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_goodsChapter_redPoint, RedDotDefine.ModuleType.PayShopCustomerService)
end

function Form_MallMainNew:InitData()
  local params = self.m_csui.m_param
  local iStoreId = params and params.iStoreId or self.iStoreId
  self:InitCurSelectTab(iStoreId)
  self.m_csui.m_param = nil
end

function Form_MallMainNew:OnMallDataRefresh()
  if not ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore) then
    return
  end
  self.is_GoodsChapterOpen, _, self.is_hide = MallGoodsChapterManager:GetCurStoreBaseGoodsChapterCfg()
  self:InitSubPanelInfo()
  self:InitCurSelectTab(self.iStoreId)
  self:RefreshUI()
end

function Form_MallMainNew:InitCurSelectTab(iStoreId)
  if not iStoreId then
    if not self.iCurSelectMainTab or self.iCurSelectMainTab > #self.m_StoreList then
      self.iCurSelectMainTab = 1
      self.iCurSelectSubTab = 1
    end
    if not self.iCurSelectSubTab or self.iCurSelectSubTab > #self.m_StoreList[self.iCurSelectMainTab] then
      self.iCurSelectSubTab = 1
    end
  else
    self.iCurSelectMainTab = 1
    self.iCurSelectSubTab = 1
    for i, v in ipairs(self.m_StoreList) do
      for ii, store in ipairs(v) do
        if store.iStoreId == iStoreId then
          self.iCurSelectMainTab = i
          self.iCurSelectSubTab = ii
          return
        end
      end
    end
  end
end

function Form_MallMainNew:RefreshUI(force_fresh)
  if force_fresh then
    self.iCurSelectMainTab = 1
    self.iCurSelectSubTab = 1
  end
  self:RefreshTab()
  self:ChangeSubPanel()
  self:RefreshJpRaw()
  self:RefreshRedDot()
  self:RefreshPackScore()
end

function Form_MallMainNew:RefreshTab()
  self.m_MainTabHelper:CheckAndCreateObjs(#self.m_StoreList)
  if not self.m_StoreList or not self.m_StoreList[self.iCurSelectMainTab] then
    self:CloseForm()
    log.error("Form_MallMainNew:RefreshTab() : store Data error!")
    return
  end
  local subStoreList = self.m_StoreList[self.iCurSelectMainTab]
  local store = subStoreList[self.iCurSelectSubTab]
  local subTabCount = #subStoreList
  if store and subTabCount <= 1 and (store.iStoreType == MTTDProto.CmdActPayStoreType_PushGift or store.iShowSingleTab and store.iShowSingleTab == 0) then
    self.m_subpnl_tab:SetActive(false)
    return
  end
  self.m_subpnl_tab:SetActive(true)
  self.m_SubTabHelper:CheckAndCreateObjs(subTabCount)
end

function Form_MallMainNew:RefreshJpRaw()
  if self.m_txt_JpRaw then
    UILuaHelper.SetActive(self.m_txt_JpRaw, false)
  end
  UILuaHelper.SetActive(self.m_pnl_groupbtn, false)
  if ChannelManager:IsAPChannel() then
    local upperStr = string.upper(RoleManager:GetLoginRoleCountry())
    if string.find(upperStr, "JP") then
      UILuaHelper.SetActive(self.m_pnl_groupbtn, true)
    end
  end
end

function Form_MallMainNew:RefreshRedDot()
  for i, v in ipairs(self.m_StoreList) do
    local redDotEnum
    if 1 < #v then
      redDotEnum = WindowRedEnum[v[1].iWindowID]
    else
      redDotEnum = TabIdxToRedEunm[v[1].iStoreType]
    end
    if redDotEnum then
      local item = self.m_MainTabItemCache[i]
      if item then
        self:RegisterOrUpdateRedDotItem(item.m_img_RedDot, redDotEnum)
      end
    else
      local item = self.m_MainTabItemCache[i]
      item.m_img_RedDot.gameObject:SetActive(false)
    end
  end
end

function Form_MallMainNew:FreshTime()
  local store = self.m_StoreList[self.iCurSelectMainTab][self.iCurSelectSubTab]
  if store.sColorType and store.sColorType ~= "" then
    local _, color = CS.UnityEngine.ColorUtility.TryParseHtmlString(store.sColorType)
    self.m_txt_timeleft_Text.color = color
  end
  self.m_img_timeleft:SetActive(false)
  if store.iStoreType == MTTDProto.CmdActPayStoreType_OpenNewShop or store.iStoreType == MTTDProto.CmdActPayStoreType_OpenCard or store.iStoreType == MTTDProto.CmdActPayStoreType_Up or store.iStoreType == MTTDProto.CmdActPayStoreType_OpenBeginner or store.iStoreType == MTTDProto.CmdActPayStoreType_StepupGift or store.iStoreType == MTTDProto.CmdActPayStoreType_PickupGiftNew or store.iStoreType == MTTDProto.CmdActPayStoreType_PickupGift then
    if store.iStoreEndTime <= 0 then
      self.m_img_timeleft:SetActive(false)
      return
    end
    local iEndTime = store.iStoreEndTime
    local iServerTime = TimeUtil:GetServerTimeS()
    local ileftTime = iEndTime - iServerTime
    if ileftTime <= 0 then
      self:RefreshUI(true)
      return
    end
    if self.timer then
      TimeService:KillTimer(self.timer)
      self.timer = nil
    end
    local lastTime = TimeUtil:SecondsToFormatCNStr4(ileftTime)
    self.m_txt_timeleft_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(220020), lastTime)
    self.timer = TimeService:SetTimer(1, ileftTime, function()
      ileftTime = ileftTime - 1
      local lastTimeCur = TimeUtil:SecondsToFormatCNStr4(ileftTime)
      self.m_txt_timeleft_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(220020), lastTimeCur)
      if ileftTime <= 0 then
        TimeService:KillTimer(self.timer)
        self.timer = nil
        self:RefreshUI(true)
      end
    end)
    self.m_img_timeleft:SetActive(true)
  elseif store.iStoreType == MTTDProto.CmdActPayStoreType_SignGift then
    if store.iStoreEndTime <= 0 then
      self.m_img_timeleft:SetActive(false)
      return
    end
    local act = ActivityManager:GetActivityByType(MTTD.ActivityType_SignGift)
    if act then
      local isBuy = act:GetBuyTimes()
      local iEndTime = 0
      local tipsTd = 220020
      if 0 < isBuy then
        iEndTime = act:getActivityShowEndTime()
        tipsTd = 220018
      else
        iEndTime = act:GetLimitBuyTimes()
        tipsTd = 220020
      end
      local iServerTime = TimeUtil:GetServerTimeS()
      local ileftTime = iEndTime - iServerTime
      ileftTime = ileftTime + 1
      if ileftTime <= 0 then
        self:RefreshUI(true)
        return
      end
      if self.timer then
        TimeService:KillTimer(self.timer)
        self.timer = nil
      end
      local lastTime = TimeUtil:SecondsToFormatCNStr3(ileftTime)
      self.m_txt_timeleft_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(tipsTd), lastTime)
      self.timer = TimeService:SetTimer(1, ileftTime, function()
        ileftTime = ileftTime - 1
        local lastTimeCur = TimeUtil:SecondsToFormatCNStr3(ileftTime)
        self.m_txt_timeleft_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(tipsTd), lastTimeCur)
        if ileftTime <= 0 then
          TimeService:KillTimer(self.timer)
          self.timer = nil
          self:InitSubPanelInfo()
          self:RefreshUI(true)
        end
      end)
      self.m_img_timeleft:SetActive(true)
    end
  elseif store.iStoreType == MTTDProto.CmdActPayStoreType_Permanent then
    self.m_img_timeleft:SetActive(false)
    local iEndTime = store.iStoreEndTime
    local iServerTime = TimeUtil:GetServerTimeS()
    local ileftTime = iEndTime - iServerTime
    if self.timer then
      TimeService:KillTimer(self.timer)
      self.timer = nil
    end
    if store.iRefreshType == MTTDProto.CmdActPayStoreRefreshType_Day then
      ileftTime = TimeUtil:GetServerNextCommonResetTime() - iServerTime
    elseif store.iRefreshType == MTTDProto.CmdActPayStoreRefreshType_Week then
      ileftTime = TimeUtil:GetNextWeekResetTime() - iServerTime
    elseif store.iRefreshType == MTTDProto.CmdActPayStoreRefreshType_Month then
      ileftTime = TimeUtil:GetNextMonthResetTime() - iServerTime
    end
    if iEndTime ~= 0 and ileftTime <= 0 then
      self:RefreshUI(true)
      return
    end
    local lastTime = TimeUtil:SecondsToFormatCNStr4(ileftTime)
    self.m_txt_timeleft_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(220022), lastTime)
    self.timer = TimeService:SetTimer(1, ileftTime, function()
      ileftTime = ileftTime - 1
      local lastTimeCur = TimeUtil:SecondsToFormatCNStr4(ileftTime)
      self.m_txt_timeleft_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(220022), lastTimeCur)
      if ileftTime <= 0 then
        TimeService:KillTimer(self.timer)
        self.timer = nil
        self:RefreshUI(true)
      end
    end)
    self.m_img_timeleft:SetActive(true)
  else
    self.m_img_timeleft:SetActive(false)
  end
end

function Form_MallMainNew:ExtraCheckStoreOpen(store)
  if store.iStoreType == MTTDProto.CmdActPayStoreType_PushGift then
    local act = ActivityManager:GetActivityByType(MTTD.ActivityType_PushGift)
    if not act then
      return false
    end
    local giftTab = act:GetInTimePushGift()
    if not giftTab or table.getn(giftTab) == 0 then
      return false
    end
  elseif store.iStoreType == MTTDProto.CmdActPayStoreType_MainStage then
    return not self.is_hide
  elseif store.iStoreType == MTTDProto.CmdActPayStoreType_OpenCard then
    local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
    local isShow = payStoreActivity:GetChainPackState()
    return isShow
  elseif store.iStoreType == MTTDProto.CmdActPayStoreType_OpenNewShop or store.iStoreType == MTTDProto.CmdActPayStoreType_OpenBeginner then
    local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
    local isShow = payStoreActivity:GetStoreSoldoutState(store.iStoreType)
    return isShow
  elseif store.iStoreType == MTTDProto.CmdActPayStoreType_SignGift then
    local signGiftAct = ActivityManager:GetActivityByType(MTTD.ActivityType_SignGift)
    if not signGiftAct then
      return false
    end
    local isShow = signGiftAct:checkCondition()
    return isShow
  elseif store.iStoreType == MTTDProto.CmdActPayStoreType_FashionStore then
    local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
    local isShow = payStoreActivity:CheckIsShowFashionStore()
    return isShow
  end
  return true
end

function Form_MallMainNew:InitSubPanelInfo()
  self.m_PayStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not self.m_PayStoreActivity then
    log.error("Form_MallMainNew:InitSubPanelInfo() : store Data error!")
    self:CloseForm()
    return
  end
  local mStoreList = self.m_PayStoreActivity:GetNewStoreList()
  local storeList = {}
  for _, v in ipairs(mStoreList) do
    local temp = {}
    local isStoreOpen = false
    for _, store in ipairs(v) do
      isStoreOpen = self.m_PayStoreActivity:CheckStoreIsOpen(store)
      if isStoreOpen and self:ExtraCheckStoreOpen(store) then
        temp[#temp + 1] = store
      end
    end
    if 0 < #temp then
      storeList[#storeList + 1] = temp
    end
  end
  self.m_StoreList = storeList
  if #storeList <= 0 then
    self:CloseForm()
    return
  end
  for _, v in ipairs(self.m_StoreList) do
    for i, store in ipairs(v) do
      local subPanelName = PaystoreType2SubPanel[store.iStoreType]
      if subPanelName ~= nil then
        local subPanel = self.m_subPanelCache[store.iStoreType]
        if subPanel == nil then
          subPanel = {
            panelRoot = self.m_root_submall,
            subPanelName = subPanelName,
            store = store
          }
          self.m_subPanelCache[store.iStoreType] = subPanel
        end
      end
    end
  end
end

function Form_MallMainNew:ReSetSubPanel(subPanel)
  for k, v in pairs(self.m_subPanelCache) do
    if v ~= subPanel and v.subPanelLua then
      v.subPanelLua:SetActive(false)
      if v.subPanelLua.OnInactivePanel then
        v.subPanelLua:OnInactivePanel()
      end
    end
  end
end

function Form_MallMainNew:ChangeSubPanel()
  if not self.m_StoreList or not self.m_StoreList[self.iCurSelectMainTab] then
    return
  end
  local store = self.m_StoreList[self.iCurSelectMainTab][self.iCurSelectSubTab]
  if not store then
    return
  end
  local iStoreType = store.iStoreType
  local subPanel = self.m_subPanelCache[iStoreType]
  if not subPanel then
    log.error("Form_MallMainNew:ChangeSubPanel() : store subPanelData error!")
    return
  end
  self.iStoreId = store.iStoreId
  if subPanel.subPanelLua == nil then
    local initData = subPanel.backFun and {
      backFun = subPanel.backFun
    } or nil
    
    local function loadCallBack(subPanelLua)
      self:ReSetSubPanel()
      if subPanelLua then
        subPanel.subPanelLua = subPanelLua
      end
      if subPanelLua.OnActivePanel then
        TimeService:SetTimer(0.05, 1, function()
          subPanelLua:OnActivePanel()
        end)
      end
    end
    
    SubPanelManager:LoadSubPanel(subPanel.subPanelName, subPanel.panelRoot, self, initData, {storeData = store}, loadCallBack)
  else
    self:ReSetSubPanel(subPanel)
    subPanel.subPanelLua:SetActive(true)
    subPanel.subPanelLua:FreshData({storeData = store})
    if subPanel.subPanelLua.OnActivePanel then
      TimeService:SetTimer(0.05, 1, function()
        subPanel.subPanelLua:OnActivePanel()
      end)
    end
  end
  self:FreshTime()
end

function Form_MallMainNew:OnInitMainTabItem(go, idx)
  local transform = go.transform
  local index = idx + 1
  local item = self.m_MainTabItemCache[index]
  local windowData = self.m_StoreList[index]
  if not item then
    item = {
      btn = transform:GetComponent(T_Button),
      m_tab_select = transform:Find("select").gameObject,
      m_tab_unselect = transform:Find("unselect").gameObject,
      m_img_line = transform:Find("unselect/img_line03"):GetComponent(T_Image),
      m_select_img_point_Image = transform:Find("select/img_icon_select"):GetComponent(T_Image),
      m_unselect_img_point_Image = transform:Find("unselect/img_icon_unselect"):GetComponent(T_Image),
      textSelected = transform:Find("select/txt_select"):GetComponent(T_TextMeshProUGUI),
      textUnselected = transform:Find("unselect/txt_unselect"):GetComponent(T_TextMeshProUGUI),
      m_img_RedDot = transform:Find("red")
    }
    self.m_MainTabItemCache[index] = item
  end
  item.textSelected.text = self.m_PayStoreActivity:getLangText(windowData[1].sWindowName)
  item.textUnselected.text = self.m_PayStoreActivity:getLangText(windowData[1].sWindowName)
  UILuaHelper.SetAtlasSprite(item.m_select_img_point_Image, windowData[1].sStorePic .. "_1")
  UILuaHelper.SetAtlasSprite(item.m_unselect_img_point_Image, windowData[1].sStorePic)
  item.m_tab_select:SetActive(self.iCurSelectMainTab == index)
  item.m_tab_unselect:SetActive(self.iCurSelectMainTab ~= index)
  item.btn.onClick:RemoveAllListeners()
  item.btn.onClick:AddListener(function()
    if self.iCurSelectMainTab == index then
      return
    end
    self.iCurSelectMainTab = index
    self.iCurSelectSubTab = 1
    self:RefreshUI()
    GlobalManagerIns:TriggerWwiseBGMState(75)
  end)
end

function Form_MallMainNew:OnInitSubTabItem(go, idx)
  local transform = go.transform
  local index = idx + 1
  local item = self.m_SubTabItemCache[index]
  local store = self.m_StoreList[self.iCurSelectMainTab][index]
  if not store then
    if not go then
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
  local count = #self.m_StoreList[self.iCurSelectMainTab]
  item.LineObj:SetActive(index < count)
  item.Selected:SetActive(index == self.iCurSelectSubTab)
  local titleName = self.m_PayStoreActivity:getLangText(store.sStoreName)
  item.TitleUnSelectText.text = titleName
  item.TitleSelectedText.text = titleName
  local isShow = self.m_PayStoreActivity:HasStoreRedDot(store)
  item.RedObj:SetActive(isShow)
  item.button.onClick:RemoveAllListeners()
  item.button.onClick:AddListener(function()
    if self.iCurSelectSubTab == index then
      return
    end
    self.iCurSelectSubTab = index
    GlobalManagerIns:TriggerWwiseBGMState(189)
    self.m_SubTabHelper:Refresh()
    self:ChangeSubPanel()
  end)
end

function Form_MallMainNew:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(PaystoreType2SubPanel) do
    local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
    if vPackageSub ~= nil then
      for i = 1, #vPackageSub do
        vPackage[#vPackage + 1] = vPackageSub[i]
      end
    end
    if vResourceExtraSub ~= nil then
      for i = 1, #vResourceExtraSub do
        vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
      end
    end
  end
  return vPackage, vResourceExtra
end

function Form_MallMainNew:OnBtnCallClicked()
  SettingManager:PullAiHelpMessage()
end

function Form_MallMainNew:OnBtnpaylayerClicked()
  local urlString = string.replace(ConfigManager:GetCommonTextById(220015), "\"\"", "\"")
  if ChannelManager:IsDMMChannel() then
    urlString = string.replace(ConfigManager:GetCommonTextById(230017), "\"\"", "\"")
  end
  if urlString and urlString ~= "" then
    StackPopup:Push(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS, urlString)
  end
end

function Form_MallMainNew:OnBtnbussinesClicked()
  local urlString = string.replace(ConfigManager:GetCommonTextById(220008), "\"\"", "\"")
  if ChannelManager:IsDMMChannel() then
    urlString = string.replace(ConfigManager:GetCommonTextById(230018), "\"\"", "\"")
  end
  if urlString and urlString ~= "" then
    StackPopup:Push(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS, urlString)
  end
end

function Form_MallMainNew:OnBtncouponClicked()
  local isShow, urlString = ActivityManager:OnCheckVoucherControlAndUrl()
  if isShow and urlString ~= "" then
    CS.DeviceUtil.OpenURLNew(urlString)
  end
end

function Form_MallMainNew:RealCloseSelf()
  for k, v in pairs(self.m_subPanelCache) do
    if v.subPanelLua and v.subPanelLua.OnClosePanel then
      v.subPanelLua:OnClosePanel()
    end
  end
end

function Form_MallMainNew:OnBackClk()
  self.iStoreId = nil
  self.iCurSelectMainTab = 1
  self.iCurSelectSubTab = 1
  self:RealCloseSelf()
  self:CloseForm()
end

function Form_MallMainNew:OnBackHome()
  self:RealCloseSelf()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
  self.iStoreId = nil
  self.iCurSelectMainTab = 1
  self.iCurSelectSubTab = 1
end

function Form_MallMainNew:GetOtherActRedState()
  if self.m_PayStoreActivity then
    self.m_PayStoreActivity:OnGetMallStoreOtherActRed()
    self:OnMallDataRefresh()
  end
end

function Form_MallMainNew:OnBtnpackscoreClicked()
  local act = ActivityManager:GetActivityByType(MTTD.ActivityType_ConsumeReward)
  if act and act:checkCondition() then
    ActivityManager:DealJump(ActivityManager.JumpType.Activity, act:getID())
  end
end

function Form_MallMainNew:RefreshPackScore()
  local isShow, itemId = ActivityManager:GetConsumeRewardState()
  if isShow and itemId then
    self.m_pnl_packscore:SetActive(true)
    local itemCfg = ItemIns:GetValue_ByItemID(itemId)
    if not itemCfg:GetError() then
      UILuaHelper.SetAtlasSprite(self.m_icon_packscore_Image, "Atlas_Item/" .. itemCfg.m_IconPath)
      self.m_txt_packscore_Text.text = ConfigManager:GetCommonTextById(220025)
    end
  else
    self.m_pnl_packscore:SetActive(false)
  end
end

function Form_MallMainNew:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_MallMainNew", Form_MallMainNew)
return Form_MallMainNew
