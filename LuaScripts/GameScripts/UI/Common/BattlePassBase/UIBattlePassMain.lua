local UIBattlePassMain = class("UIBattlePassMain", require("UI/Common/UIBase"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local BattlePassBuyStatus = ActivityManager.BattlePassBuyStatus

function UIBattlePassMain:SetInitParam(param)
end

function UIBattlePassMain:AfterInit()
  UIBattlePassMain.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local size = utils.getScreenSafeAreaRealSize()
  if size.width / size.height > 1.7777777777777777 then
    self.m_pnl_fit:GetComponent("RectTransform").offsetMax.x = 660
  end
  self.m_stopUpdate = false
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_stActivity = nil
  self.m_isInitTopBtn = false
  self.m_titleType = 1
  self.m_lastBuState = 0
end

function UIBattlePassMain:OnActiveTransitionDone()
  self:OnSetRewardIndex()
end

function UIBattlePassMain:OnSetRewardIndex()
  if self.m_loop_scroll_view then
    TimeService:SetTimer(0.05, 1, function()
      if self.m_stActivity:GetAllLevelReward() then
        self.m_loop_scroll_view:moveToCellIndex(1)
      else
        local idx = self.m_stActivity:GetFirstUnclaimedLevel() or self.m_stActivity:GetCurLevel() + 1
        self.m_loop_scroll_view:moveToCellIndex(idx)
      end
    end)
  end
end

function UIBattlePassMain:OnActive()
  UIBattlePassMain.super.OnActive(self)
  self:AddEventListeners()
  self.m_dt = 1
end

function UIBattlePassMain:OnOpen()
  UIBattlePassMain.super.OnOpen(self)
  self:FreshData()
  self:FreshUI()
end

function UIBattlePassMain:OnUncoverd()
  self:FreshTaskRedShow()
  self:CheckShowLevelUp10()
  self:FreshShowActSpineInfo()
  self:OnSetRewardIndex()
  self:OnAdvancedPassBought()
  if self.m_lastBuState ~= self.m_stActivity:GetBuyStatus() then
    self.m_lastBuState = self.m_stActivity:GetBuyStatus()
    local animaStr = self.m_stActivity:GetMainPanelAnimaStr()
    UILuaHelper.PlayAnimationByName(self.m_icon_advanced_light, animaStr)
  end
end

function UIBattlePassMain:OnInactive()
  UIBattlePassMain.super.OnInactive(self)
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
end

function UIBattlePassMain:OnUpdate(dt)
  if self.m_stopUpdate then
    return
  end
  if self.m_dt then
    self.m_dt = self.m_dt - dt
    if self.m_dt <= 0 then
      self.m_dt = 1
      self:RefreshRemainTime()
    end
  end
end

function UIBattlePassMain:OnDestroy()
  UIBattlePassMain.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function UIBattlePassMain:FreshData()
  self.m_stActivity = nil
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_stActivity = tParam.stActivity
    self.m_curBuyStatus = self.m_stActivity:GetBuyStatus()
    self.m_lastBuState = self.m_curBuyStatus
    self.m_titleType = self.m_stActivity:GetTitleType()
    self.m_iActivityId = self.m_stActivity:getID()
    self.m_csui.m_param = nil
  end
end

function UIBattlePassMain:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_BattlePass_AdvancedPassBought", handler(self, self.OnAdvancedPassBought))
  self:addEventListener("eGameEvent_Activity_BattlePass_BuyExp", handler(self, self.OnBuyExp))
  self:addEventListener("eGameEvent_Activity_BattlePass_ReceiveTaskReward", handler(self, self.OnReceiveTaskReward))
  self:addEventListener("eGameEvent_Activity_BattlePass_DailyTaskRefresh", handler(self, self.OnTaskReFresh))
  self:addEventListener("eGameEvent_Activity_BattlePass_TaskUpdate", handler(self, self.OnTaskUpdate))
  self:addEventListener("eGameEvent_Activity_AnywayReload", handler(self, self.OnFreshActivity))
  self:addEventListener("eGameEvent_Activity_BattlePass_CloseMain", handler(self, self.OnBackClk))
end

function UIBattlePassMain:OnFreshActivity()
  if self.m_iActivityId then
    self.m_stActivity = ActivityManager:GetActivityByID(self.m_iActivityId)
    if not self.m_stActivity then
      self:CloseForm()
    end
  end
end

function UIBattlePassMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function UIBattlePassMain:OnAdvancedPassBought(data)
  self:FreshRewardView()
  self:FreshGetAllStatusShow()
  self:FreshButtonStatus()
  self:FreshTaskLevelInfoShow()
end

function UIBattlePassMain:OnBuyExp(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshRewardView()
    self:FreshGetAllStatusShow()
    self:FreshTaskLevelInfoShow()
  end
end

function UIBattlePassMain:OnReceiveTaskReward(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshTaskLevelInfoShow()
    self:FreshTaskRedShow()
  end
end

function UIBattlePassMain:OnTaskReFresh(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshTaskRedShow()
  end
end

function UIBattlePassMain:OnTaskUpdate(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshRewardView()
    self:FreshTaskLevelInfoShow()
    self:FreshTaskRedShow()
  end
end

function UIBattlePassMain:FreshUI()
  if self.m_stActivity == nil then
    self:CloseForm()
    return
  end
  self:FreshTitlePanel()
  self:FreshTopTipsAndClose()
  self:FreshRewardView()
  self:FreshGetAllStatusShow()
  self:FreshTaskLevelInfoShow()
  self:RefreshRemainTime()
  self:FreshShowActSpineInfo()
  self:FreshButtonStatus()
  self:CheckShowLevelUp10()
  self:FreshTaskRedShow()
  self:FreshBgPic()
end

function UIBattlePassMain:FreshTitlePanel()
  if not self.m_stActivity then
    return
  end
  self.m_pnl_title1:SetActive(false)
  self.m_pnl_title2:SetActive(false)
  if self.m_titleType == 2 then
    self.m_pnl_title1:SetActive(false)
    self.m_pnl_title2:SetActive(true)
    local roleName = self.m_stActivity:GetRoleName()
    local isShowRoleName = roleName and roleName ~= ""
    self.m_txt_role2:SetActive(isShowRoleName)
    if isShowRoleName then
      self.m_txt_role2_Text.text = roleName
    end
    local skinName = self.m_stActivity:GetSkinName()
    local isShowSkinName = skinName and skinName ~= ""
    self.m_txt_bp_titlle2:SetActive(isShowSkinName)
    if isShowSkinName then
      self.m_txt_bp_titlle2_Text.text = skinName
    end
  else
    self.m_pnl_title1:SetActive(true)
    self.m_pnl_title2:SetActive(false)
    local titleName = self.m_stActivity:GetTitleAndEnterName()
    if titleName and titleName ~= "" then
      self.m_pnl_name1:SetActive(false)
      self.m_pnl_name2:SetActive(true)
      self.m_txt_bp_titlle_Text.text = titleName
    else
      self.m_pnl_name1:SetActive(true)
      self.m_pnl_name2:SetActive(false)
    end
  end
end

function UIBattlePassMain:FreshTopTipsAndClose()
  local tipsId
  if self.m_stActivity then
    tipsId = self.m_stActivity:GetTipsID()
  end
  if not self.m_isInitTopBtn then
    local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
    self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), tipsId)
    self.m_isInitTopBtn = true
  end
end

function UIBattlePassMain:FreshTaskLevelInfoShow()
  if not self.m_stActivity then
    return
  end
  self.m_txt_rank_Text.text = self.m_stActivity:GetCurLevel()
  self:FreshProgress()
end

function UIBattlePassMain:FreshProgress()
  local curLevel = self.m_stActivity:GetCurLevel()
  local levelCfg = self.m_stActivity:GetLevelCfg(curLevel)
  if levelCfg then
    local needExp = self.m_stActivity:GetUpLevelExp()
    if curLevel == self.m_stActivity:GetMaxLevel() then
      self.m_img_bar_Image.fillAmount = 1
      self.m_icon_txt_Text.text = needExp .. "/" .. needExp
      UILuaHelper.SetActive(self.m_btn_add, false)
      UILuaHelper.SetActive(self.m_z_txt_max, true)
    else
      local curExp = self.m_stActivity:GetCurExp()
      if needExp <= curExp then
        self.m_img_bar_Image.fillAmount = 1
      else
        self.m_img_bar_Image.fillAmount = curExp / needExp
      end
      self.m_icon_txt_Text.text = curExp .. "/" .. needExp
      UILuaHelper.SetActive(self.m_btn_add, true)
      UILuaHelper.SetActive(self.m_z_txt_max, false)
    end
  end
end

function UIBattlePassMain:FreshGetAllStatusShow()
  if not self.m_stActivity then
    return
  end
  local hasUnclaimedReward = self.m_stActivity:GetFirstUnclaimedLevel() ~= nil
  self.m_bg_getall_normal:SetActive(hasUnclaimedReward)
  self.m_bg_getall_grey:SetActive(not hasUnclaimedReward)
end

function UIBattlePassMain:FreshTaskRedShow()
  if not self.m_stActivity then
    return
  end
  if not self.m_stActivity.ReachMaxLevel or not self.m_stActivity.HasUnclaimedTask then
    return
  end
  local isTaskHaveRed = not self.m_stActivity:ReachMaxLevel() and self.m_stActivity:HasUnclaimedTask()
  UILuaHelper.SetActive(self.m_reddot_task, isTaskHaveRed)
end

function UIBattlePassMain:FreshRewardView()
  if not self.m_stActivity then
    return
  end
  local isHaveBuy = self.m_stActivity:IsHaveBuy()
  UILuaHelper.SetActive(self.m_advanced_lock, not isHaveBuy)
  UILuaHelper.SetActive(self.m_icon_advanced_gray, not isHaveBuy)
  UILuaHelper.SetActive(self.m_icon_advanced_light, isHaveBuy)
  self:FreshScrollView()
  self:FreshLastReward()
end

function UIBattlePassMain:FreshBgPic()
  if self.m_stActivity then
    local bg, bg1 = self.m_stActivity:GetBpBgPic()
    if bg and bg ~= "" then
      UILuaHelper.SetUITexture(self.m_img_bg_Image, bg, function()
        self.m_img_bg:SetActive(true)
      end)
    end
    if bg1 and bg1 ~= "" then
      UILuaHelper.SetUITexture(self.m_img_bg1_Image, bg1, function()
        self.m_img_bg1:SetActive(true)
      end)
    end
  end
end

function UIBattlePassMain:FreshShowActSpineInfo()
  if self.m_stActivity then
    local spineStr = self.m_stActivity:GetAvatarSpineName()
    if spineStr and spineStr ~= "" then
      self:ShowHeroSpine(self.m_stActivity:GetAvatarSpineName())
    end
  end
end

function UIBattlePassMain:FreshButtonStatus()
  if not self.m_stActivity then
    return
  end
  local buyStatus = self.m_stActivity:GetBuyStatus()
  UILuaHelper.SetActive(self.m_btn_sale, buyStatus == ActivityManager.BattlePassBuyStatus.Free)
  if self.m_stActivity:GetBattlePassHasAdvance() then
    UILuaHelper.SetActive(self.m_btn_saleup, buyStatus == ActivityManager.BattlePassBuyStatus.Paid)
    UILuaHelper.SetActive(self.m_btn_saledone, buyStatus == ActivityManager.BattlePassBuyStatus.Advanced)
  else
    UILuaHelper.SetActive(self.m_btn_saleup, false)
    UILuaHelper.SetActive(self.m_btn_saledone, 0 < buyStatus)
  end
end

function UIBattlePassMain:FreshScrollView()
  local data = self.m_stActivity:GetLevelCfg()
  local showData = {}
  local max = #data - 1
  for k = 1, max do
    showData[#showData + 1] = {
      levelCfg = data[k],
      activity = self.m_stActivity
    }
  end
  self.m_scrollItemCache = {}
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_scrollview
    local params = {
      show_data = showData,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "c_advanced1_light" or click_name == "c_free_light" or click_name == "c_advanced2_light" then
          local levelCfg = cell_data.levelCfg
          self.m_stActivity:RequestGetLevelReward(levelCfg.iLevel, function()
            self.m_loop_scroll_view:updateCellIndex(index - 1)
            self:FreshGetAllStatusShow()
          end)
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(showData)
  end
end

function UIBattlePassMain:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local data = cell_data
  local levelCfg = data.levelCfg
  local activity = data.activity
  local drawStatus = activity:GetDrawStatus(levelCfg.iLevel)
  local curLevel = activity:GetCurLevel()
  local isHaveBuy = activity:IsHaveBuy()
  local isNotGetLevel = curLevel < levelCfg.iLevel
  local item_free = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_item_free")
  if self.m_scrollItemCache[cell_object] == nil then
    local vPaidList = {}
    local item_advanced1 = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_item_advanced1")
    local item_advanced2 = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_item_advanced2")
    local item_State1 = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_pnl_advanced1_state")
    local item_State2 = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_pnl_advanced2_state")
    local advItemIcon1 = self:createCommonItem(item_advanced1)
    advItemIcon1:SetItemIconClickCB(handler(self, self.OnItemClicked))
    local advItemIcon2 = self:createCommonItem(item_advanced2)
    advItemIcon2:SetItemIconClickCB(handler(self, self.OnItemClicked))
    vPaidList[#vPaidList + 1] = {
      item = item_advanced1,
      itemIcon = advItemIcon1,
      itemState = item_State1
    }
    vPaidList[#vPaidList + 1] = {
      item = item_advanced2,
      itemIcon = advItemIcon2,
      itemState = item_State2
    }
    local freeItemIcon = self:createCommonItem(item_free)
    freeItemIcon:SetItemIconClickCB(handler(self, self.OnItemClicked))
    self.m_scrollItemCache[cell_object] = {vPaidList = vPaidList, freeItemIcon = freeItemIcon}
  end
  local vPaidList = self.m_scrollItemCache[cell_object].vPaidList
  local freeItemIcon = self.m_scrollItemCache[cell_object].freeItemIcon
  local vPaidReward = levelCfg.vPaidReward
  for k, v in ipairs(vPaidList) do
    local reward = vPaidReward[k]
    if reward then
      v.item:SetActive(true)
      local itemData = ResourceUtil:GetProcessRewardData({
        iID = reward.iID,
        iNum = reward.iNum
      })
      v.itemIcon:SetItemInfo(itemData)
      if v.itemState then
        v.itemState:SetActive(true)
      end
    else
      v.item:SetActive(false)
      if v.itemState then
        v.itemState:SetActive(false)
      end
    end
  end
  local vFreeReward = levelCfg.vFreeReward
  if 0 < #vFreeReward then
    item_free:SetActive(true)
    freeItemIcon:SetItemInfo(ResourceUtil:GetProcessRewardData({
      iID = vFreeReward[1].iID,
      iNum = vFreeReward[1].iNum
    }))
  else
    item_free:SetActive(false)
  end
  local showText = string.CS_Format(ConfigManager:GetCommonTextById(220021), levelCfg.iLevel)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_nml", showText)
  local advanced1_light = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_advanced1_light")
  local advanced1_lock = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_advanced1_lock")
  local advanced2_light = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_advanced2_light")
  local advanced2_lock = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_advanced2_lock")
  local free_light = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_free_light")
  UILuaHelper.SetActive(advanced1_lock, not isHaveBuy)
  UILuaHelper.SetActive(advanced2_lock, not isHaveBuy)
  if isNotGetLevel then
    freeItemIcon:SetItemHaveGetActive(false)
    UILuaHelper.SetActive(free_light, false)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(false)
    end
    UILuaHelper.SetActive(advanced1_light, false)
    UILuaHelper.SetActive(advanced2_light, false)
  elseif drawStatus == 0 then
    freeItemIcon:SetItemHaveGetActive(false)
    UILuaHelper.SetActive(free_light, true)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(false)
    end
    UILuaHelper.SetActive(advanced1_light, isHaveBuy)
    UILuaHelper.SetActive(advanced2_light, isHaveBuy)
  elseif drawStatus == 1 then
    freeItemIcon:SetItemHaveGetActive(true)
    UILuaHelper.SetActive(free_light, false)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(false)
    end
    UILuaHelper.SetActive(advanced1_light, isHaveBuy)
    UILuaHelper.SetActive(advanced2_light, isHaveBuy)
  elseif drawStatus == 2 then
    freeItemIcon:SetItemHaveGetActive(true)
    UILuaHelper.SetActive(free_light, false)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(isHaveBuy)
    end
    UILuaHelper.SetActive(advanced1_light, false)
    UILuaHelper.SetActive(advanced2_light, false)
  end
end

function UIBattlePassMain:FreshLastReward()
  local vPaidList = {}
  if self.m_advItemIcon1 == nil then
    self.m_advItemIcon1 = self:createCommonItem(self.m_item_foot_advanced1)
    self.m_advItemIcon1:SetItemIconClickCB(handler(self, self.OnItemClicked))
  end
  if self.m_advItemIcon2 == nil then
    self.m_advItemIcon2 = self:createCommonItem(self.m_item_foot_advanced2)
    self.m_advItemIcon2:SetItemIconClickCB(handler(self, self.OnItemClicked))
  end
  vPaidList[#vPaidList + 1] = {
    item = self.m_item_foot_advanced1,
    itemIcon = self.m_advItemIcon1,
    itemState = self.m_pnl_advanced1_state
  }
  vPaidList[#vPaidList + 1] = {
    item = self.m_item_foot_advanced2,
    itemIcon = self.m_advItemIcon2,
    itemState = self.m_pnl_advanced2_state
  }
  if self.m_freeItemIcon == nil then
    self.m_freeItemIcon = self:createCommonItem(self.m_item_foot_free)
    self.m_freeItemIcon:SetItemIconClickCB(handler(self, self.OnItemClicked))
  end
  local levelCfg = self.m_stActivity:GetFinalLevelCfg()
  local drawStatus = self.m_stActivity:GetDrawStatus(levelCfg.iLevel)
  local curLevel = self.m_stActivity:GetCurLevel()
  local isHaveBuy = self.m_stActivity:IsHaveBuy()
  local isNotGetLevel = curLevel < levelCfg.iLevel
  self.m_finalLevelCfg = levelCfg
  local vPaidReward = levelCfg.vPaidReward
  for k, v in ipairs(vPaidList) do
    local reward = vPaidReward[k]
    if reward then
      v.item:SetActive(true)
      local itemData = ResourceUtil:GetProcessRewardData({
        iID = reward.iID,
        iNum = reward.iNum
      })
      v.itemIcon:SetItemInfo(itemData)
      if v.itemState then
        v.itemState:SetActive(true)
      end
    else
      v.item:SetActive(false)
      if v.itemState then
        v.itemState:SetActive(false)
      end
    end
  end
  local vFreeReward = levelCfg.vFreeReward
  if 0 < #vFreeReward then
    UILuaHelper.SetActive(self.m_item_foot_free, true)
    self.m_freeItemIcon:SetItemInfo(ResourceUtil:GetProcessRewardData({
      iID = vFreeReward[1].iID,
      iNum = vFreeReward[1].iNum
    }))
  else
    UILuaHelper.SetActive(self.m_item_foot_free, false)
  end
  local showText = string.CS_Format(ConfigManager:GetCommonTextById(220021), levelCfg.iLevel)
  self.m_txt_foot_nml_Text.text = showText
  UILuaHelper.SetActive(self.m_foot_advanced1_lock, not isHaveBuy)
  UILuaHelper.SetActive(self.m_foot_advanced2_lock, not isHaveBuy)
  if isNotGetLevel then
    self.m_freeItemIcon:SetItemHaveGetActive(false)
    UILuaHelper.SetActive(self.m_foot_free_light, false)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(false)
    end
    UILuaHelper.SetActive(self.m_foot_advanced1_light, false)
    UILuaHelper.SetActive(self.m_foot_advanced2_light, false)
  elseif drawStatus == 0 then
    self.m_freeItemIcon:SetItemHaveGetActive(false)
    UILuaHelper.SetActive(self.m_foot_free_light, true)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(false)
    end
    UILuaHelper.SetActive(self.m_foot_advanced1_light, isHaveBuy)
    UILuaHelper.SetActive(self.m_foot_advanced2_light, isHaveBuy)
  elseif drawStatus == 1 then
    self.m_freeItemIcon:SetItemHaveGetActive(true)
    UILuaHelper.SetActive(self.m_foot_free_light, false)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(false)
    end
    UILuaHelper.SetActive(self.m_foot_advanced1_light, isHaveBuy)
    UILuaHelper.SetActive(self.m_foot_advanced2_light, isHaveBuy)
  elseif drawStatus == 2 then
    self.m_freeItemIcon:SetItemHaveGetActive(true)
    UILuaHelper.SetActive(self.m_foot_free_light, false)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(isHaveBuy)
    end
    UILuaHelper.SetActive(self.m_foot_advanced1_light, false)
    UILuaHelper.SetActive(self.m_foot_advanced2_light, false)
  end
end

function UIBattlePassMain:RefreshRemainTime()
  if not self.m_stActivity then
    return
  end
  local remainTime = self.m_stActivity:getActivityRemainTime()
  if 0 < remainTime then
    local showTimeStr = TimeUtil:SecondsToFormatCNStr(remainTime)
    showTimeStr = string.CS_Format(ConfigManager:GetCommonTextById(220018), showTimeStr)
    self.m_txt_time_Text.text = showTimeStr
  else
    self.m_stopUpdate = true
    utils.CheckAndPushCommonTips({
      tipsID = 1751,
      func1 = function()
        self:CloseForm()
      end
    })
  end
end

function UIBattlePassMain:ShowHeroSpine(heroSpinePathStr)
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  self:CheckRecycleSpine()
  if self.m_HeroSpineDynamicLoader then
    local typeStr = SpinePlaceCfg.HeroBpMain
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SetActive(self.m_curHeroSpineObj.spinePlaceObj, true)
    end)
  end
end

function UIBattlePassMain:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function UIBattlePassMain:CheckShowLevelUp10()
  if not self.m_stActivity then
    return
  end
  local curBuyStatus = self.m_stActivity:GetBuyStatus()
  if self.m_stActivity:GetBattlePassHasAdvance() and curBuyStatus == BattlePassBuyStatus.Advanced then
    return
  end
  if curBuyStatus == BattlePassBuyStatus.Paid then
    return
  end
  local isMax = self.m_stActivity:ReachMaxLevel()
  local actID = self.m_stActivity:getID()
  local levelPrefabId = self.m_stActivity:GetBuyPanel2Prefab()
  if isMax then
    local isShow = LocalDataManager:GetIntSimple("BattlePassMaxShowPanel" .. actID, 0) == 1
    if isShow then
      return
    end
    if curBuyStatus ~= BattlePassBuyStatus.Free then
      return
    end
    StackFlow:Push(levelPrefabId, {
      stActivity = self.m_stActivity
    })
    LocalDataManager:SetIntSimple("BattlePassMaxShowPanel" .. actID, 1)
  else
    local curLv = self.m_stActivity:GetCurLevel()
    local advanceAddLvNum = self.m_stActivity:GetAdvancedAddLv()
    local maxLv = self.m_stActivity:GetMaxLevel()
    if curLv == maxLv - advanceAddLvNum then
      local isShow = LocalDataManager:GetIntSimple("BattlePassInAdvanceAddLvShowPanel" .. actID, 0) == 1
      if isShow then
        return
      end
      StackFlow:Push(levelPrefabId, {
        stActivity = self.m_stActivity
      })
      LocalDataManager:SetIntSimple("BattlePassInAdvanceAddLvShowPanel" .. actID, 1)
    end
  end
end

function UIBattlePassMain:OnItemClicked(iItemId, iItemNum)
  utils.openItemDetailPop({iID = iItemId, iNum = 1})
end

function UIBattlePassMain:OnLightfootfreeClicked(iItemId, iItemNum)
  self.m_stActivity:RequestGetLevelReward(self.m_finalLevelCfg.iLevel, function()
    self:FreshLastReward()
    self:FreshGetAllStatusShow()
  end)
end

function UIBattlePassMain:OnLightfootadvancedClicked(iItemId, iItemNum)
  self.m_stActivity:RequestGetLevelReward(self.m_finalLevelCfg.iLevel, function()
    self:FreshLastReward()
    self:FreshGetAllStatusShow()
  end)
end

function UIBattlePassMain:OnBackClk()
  self:CloseForm()
end

function UIBattlePassMain:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function UIBattlePassMain:OnBtngetallClicked()
  local hasUnclaimedReward = self.m_stActivity:GetFirstUnclaimedLevel() ~= nil
  if not hasUnclaimedReward then
    StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, 20101)
    return
  end
  self.m_stActivity:RequestGetLevelReward(0, function()
    self:FreshScrollView()
    self:FreshLastReward()
    self:FreshGetAllStatusShow()
  end)
end

function UIBattlePassMain:ShowBuyBattlePassPanel()
  if not self.m_stActivity then
    return
  end
  local panelId = self.m_stActivity:GetBuyPanelPrefab()
  if panelId then
    StackFlow:Push(panelId, {
      stActivity = self.m_stActivity
    })
  end
end

function UIBattlePassMain:OnBtnsaleClicked()
  self:ShowBuyBattlePassPanel()
end

function UIBattlePassMain:OnBtnsaleupClicked()
  self:ShowBuyBattlePassPanel()
end

function UIBattlePassMain:OnBtnsaledoneClicked()
  self:ShowBuyBattlePassPanel()
end

function UIBattlePassMain:OnBtntaskClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSTASK, {
    stActivity = self.m_stActivity
  })
end

function UIBattlePassMain:OnBtnaddClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSLEVELUPPOP, {
    stActivity = self.m_stActivity
  })
end

function UIBattlePassMain:OnFootadvanced1lockClicked()
  self:ShowBuyBattlePassPanel()
end

function UIBattlePassMain:OnFootadvanced2lockClicked()
  self:ShowBuyBattlePassPanel()
end

function UIBattlePassMain:OnFootadvanced1lightClicked()
  self:ReqLastLvReward()
end

function UIBattlePassMain:OnFootfreelightClicked()
  self:ReqLastLvReward()
end

function UIBattlePassMain:OnFootadvanced2lightClicked()
  self:ReqLastLvReward()
end

function UIBattlePassMain:OnAdvancedlockClicked()
  self:ShowBuyBattlePassPanel()
end

function UIBattlePassMain:OnBtncheck3Clicked()
  local heroId = self.m_stActivity:GetHeroId()
  local skinId = self.m_stActivity:GetSkinId()
  if heroId and skinId then
    StackFlow:Push(UIDefines.ID_FORM_FASHION, {heroID = heroId, fashionID = skinId})
  end
end

function UIBattlePassMain:ReqLastLvReward()
  if not self.m_stActivity then
    return
  end
  local levelCfg = self.m_stActivity:GetFinalLevelCfg()
  if not levelCfg then
    return
  end
  self.m_stActivity:RequestGetLevelReward(levelCfg.iLevel, function()
    self:FreshLastReward()
    self:FreshGetAllStatusShow()
  end)
end

function UIBattlePassMain:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local spineName = tParam.stActivity:GetAvatarSpineName()
  if spineName then
    vResourceExtra[#vResourceExtra + 1] = {
      sName = spineName,
      eType = DownloadManager.ResourceType.UI
    }
  end
  return vPackage, vResourceExtra
end

function UIBattlePassMain:IsFullScreen()
  return true
end

return UIBattlePassMain
