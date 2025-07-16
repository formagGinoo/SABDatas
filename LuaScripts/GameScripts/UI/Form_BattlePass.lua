local Form_BattlePass = class("Form_BattlePass", require("UI/UIFrames/Form_BattlePassUI"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local BattlePassBuyStatus = ActivityManager.BattlePassBuyStatus

function Form_BattlePass:SetInitParam(param)
end

function Form_BattlePass:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1129)
  local size = utils.getScreenSafeAreaRealSize()
  if size.width / size.height > 1.7777777777777777 then
    self.m_pnl_fit:GetComponent("RectTransform").offsetMax.x = 660
  end
  self.m_stopUpdate = false
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_stActivity = nil
end

function Form_BattlePass:OnActiveTransitionDone()
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

function Form_BattlePass:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self.m_dt = 1
end

function Form_BattlePass:OnOpen()
  Form_BattlePass.super.OnOpen(self)
  self:FreshData()
  self:FreshUI()
end

function Form_BattlePass:OnUncoverd()
  self:FreshTaskRedShow()
  self:CheckShowLevelUp10()
  self:FreshShowActSpineInfo()
end

function Form_BattlePass:OnInactive()
  self.super.OnInactive(self)
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
end

function Form_BattlePass:OnUpdate(dt)
  if self.m_stopUpdate then
    return
  end
  self.m_dt = self.m_dt - dt
  if self.m_dt <= 0 then
    self.m_dt = 1
    self:RefreshRemainTime()
  end
end

function Form_BattlePass:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_BattlePass:FreshData()
  self.m_stActivity = nil
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_stActivity = tParam.stActivity
    self.m_curBuyStatus = self.m_stActivity:GetBuyStatus()
    self.m_csui.m_param = nil
  end
end

function Form_BattlePass:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_BattlePass_AdvancedPassBought", handler(self, self.OnAdvancedPassBought))
  self:addEventListener("eGameEvent_Activity_BattlePass_BuyExp", handler(self, self.OnBuyExp))
  self:addEventListener("eGameEvent_Activity_BattlePass_ReceiveTaskReward", handler(self, self.OnReceiveTaskReward))
  self:addEventListener("eGameEvent_Activity_BattlePass_DailyTaskRefresh", handler(self, self.OnTaskReFresh))
  self:addEventListener("eGameEvent_Activity_BattlePass_TaskUpdate", handler(self, self.OnTaskUpdate))
end

function Form_BattlePass:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BattlePass:OnAdvancedPassBought(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshRewardView()
    self:FreshGetAllStatusShow()
    local toBuyStatus = self.m_stActivity:GetBuyStatus()
    if self.m_curBuyStatus == BattlePassBuyStatus.Free and toBuyStatus ~= BattlePassBuyStatus.Free then
      UILuaHelper.PlayAnimationByName(self.m_icon_advanced_light, "BattlePass_advanced_lock")
    end
    self:FreshButtonStatus()
    self:FreshTaskLevelInfoShow()
  end
end

function Form_BattlePass:OnBuyExp(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshRewardView()
    self:FreshGetAllStatusShow()
    self:FreshTaskLevelInfoShow()
  end
end

function Form_BattlePass:OnReceiveTaskReward(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshTaskLevelInfoShow()
    self:FreshTaskRedShow()
  end
end

function Form_BattlePass:OnTaskReFresh(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshTaskRedShow()
  end
end

function Form_BattlePass:OnTaskUpdate(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshRewardView()
    self:FreshTaskLevelInfoShow()
    self:FreshTaskRedShow()
  end
end

function Form_BattlePass:FreshUI()
  if self.m_stActivity == nil then
    self:CloseForm()
    return
  end
  self:FreshRewardView()
  self:FreshGetAllStatusShow()
  self:FreshTaskLevelInfoShow()
  self:RefreshRemainTime()
  self:FreshShowActSpineInfo()
  self:FreshButtonStatus()
  self:CheckShowLevelUp10()
  self:FreshTaskRedShow()
end

function Form_BattlePass:FreshTaskLevelInfoShow()
  self.m_txt_rank_Text.text = self.m_stActivity:GetCurLevel()
  self:FreshProgress()
end

function Form_BattlePass:FreshProgress()
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

function Form_BattlePass:FreshGetAllStatusShow()
  local hasUnclaimedReward = self.m_stActivity:GetFirstUnclaimedLevel() ~= nil
  self.m_bg_getall_normal:SetActive(hasUnclaimedReward)
  self.m_bg_getall_grey:SetActive(not hasUnclaimedReward)
end

function Form_BattlePass:FreshTaskRedShow()
  local isTaskHaveRed = not self.m_stActivity:ReachMaxLevel() and self.m_stActivity:HasUnclaimedTask()
  UILuaHelper.SetActive(self.m_reddot_task, isTaskHaveRed)
end

function Form_BattlePass:FreshRewardView()
  local isHaveBuy = self.m_stActivity:IsHaveBuy()
  UILuaHelper.SetActive(self.m_advanced_lock, not isHaveBuy)
  UILuaHelper.SetActive(self.m_icon_advanced_gray, not isHaveBuy)
  UILuaHelper.SetActive(self.m_icon_advanced_light, isHaveBuy)
  self:FreshScrollView()
  self:FreshLastReward()
end

function Form_BattlePass:FreshShowActSpineInfo()
  local iAvatarId = self.m_stActivity:GetAvatarId()
  local heroCfg = CharacterInfoIns:GetValue_ByHeroID(iAvatarId)
  self:ShowHeroSpine(heroCfg.m_Spine)
end

function Form_BattlePass:FreshButtonStatus()
  local buyStatus = self.m_stActivity:GetBuyStatus()
  UILuaHelper.SetActive(self.m_btn_sale, buyStatus == ActivityManager.BattlePassBuyStatus.Free)
  UILuaHelper.SetActive(self.m_btn_saleup, buyStatus == ActivityManager.BattlePassBuyStatus.Paid)
  UILuaHelper.SetActive(self.m_btn_saledone, buyStatus == ActivityManager.BattlePassBuyStatus.Advanced)
end

function Form_BattlePass:FreshScrollView()
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
        elseif click_name == "c_advanced1_lock" or click_name == "c_advanced2_lock" then
          self:ShowBuyBattlePassPanel()
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(showData)
  end
end

function Form_BattlePass:updateScrollViewCell(index, cell_object, cell_data)
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
    local advItemIcon1 = self:createCommonItem(item_advanced1)
    advItemIcon1:SetItemIconClickCB(handler(self, self.OnItemClicked))
    local advItemIcon2 = self:createCommonItem(item_advanced2)
    advItemIcon2:SetItemIconClickCB(handler(self, self.OnItemClicked))
    vPaidList[#vPaidList + 1] = {item = item_advanced1, itemIcon = advItemIcon1}
    vPaidList[#vPaidList + 1] = {item = item_advanced2, itemIcon = advItemIcon2}
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
    else
      v.item:SetActive(false)
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
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_nml", levelCfg.iLevel)
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

function Form_BattlePass:FreshLastReward()
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
    itemIcon = self.m_advItemIcon1
  }
  vPaidList[#vPaidList + 1] = {
    item = self.m_item_foot_advanced2,
    itemIcon = self.m_advItemIcon2
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
    else
      v.item:SetActive(false)
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
  self.m_txt_foot_nml_Text.text = levelCfg.iLevel
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

function Form_BattlePass:RefreshRemainTime()
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

function Form_BattlePass:ShowHeroSpine(heroSpinePathStr)
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  self:CheckRecycleSpine()
  if self.m_HeroSpineDynamicLoader then
    local typeStr = SpinePlaceCfg.HeroDetail
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SetActive(self.m_curHeroSpineObj.spinePlaceObj, true)
    end)
  end
end

function Form_BattlePass:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_BattlePass:CheckShowLevelUp10()
  if not self.m_stActivity then
    return
  end
  local curBuyStatus = self.m_stActivity:GetBuyStatus()
  if curBuyStatus == BattlePassBuyStatus.Advanced then
    return
  end
  local isMax = self.m_stActivity:ReachMaxLevel()
  local actID = self.m_stActivity:getID()
  if isMax then
    local isShow = LocalDataManager:GetIntSimple("BattlePassMaxShowPanel" .. actID, 0) == 1
    if isShow then
      return
    end
    if curBuyStatus ~= BattlePassBuyStatus.Free then
      return
    end
    StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSLEVELUP10, {
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
      StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSLEVELUP10, {
        stActivity = self.m_stActivity
      })
      LocalDataManager:SetIntSimple("BattlePassInAdvanceAddLvShowPanel" .. actID, 1)
    end
  end
end

function Form_BattlePass:OnItemClicked(iItemId, iItemNum)
  utils.openItemDetailPop({iID = iItemId, iNum = 1})
end

function Form_BattlePass:OnLightfootfreeClicked(iItemId, iItemNum)
  self.m_stActivity:RequestGetLevelReward(self.m_finalLevelCfg.iLevel, function()
    self:FreshLastReward()
    self:FreshGetAllStatusShow()
  end)
end

function Form_BattlePass:OnLightfootadvancedClicked(iItemId, iItemNum)
  self.m_stActivity:RequestGetLevelReward(self.m_finalLevelCfg.iLevel, function()
    self:FreshLastReward()
    self:FreshGetAllStatusShow()
  end)
end

function Form_BattlePass:OnBackClk()
  self:CloseForm()
end

function Form_BattlePass:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_BattlePass:OnBtngetallClicked()
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

function Form_BattlePass:ShowBuyBattlePassPanel()
  if not self.m_stActivity then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSBENEFITS, {
    stActivity = self.m_stActivity
  })
end

function Form_BattlePass:OnBtnsaleClicked()
  self:ShowBuyBattlePassPanel()
end

function Form_BattlePass:OnBtnsaleupClicked()
  self:ShowBuyBattlePassPanel()
end

function Form_BattlePass:OnBtnsaledoneClicked()
  self:ShowBuyBattlePassPanel()
end

function Form_BattlePass:OnBtntaskClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSTASK, {
    stActivity = self.m_stActivity
  })
end

function Form_BattlePass:OnBtnaddClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSLEVELUPPOP, {
    stActivity = self.m_stActivity
  })
end

function Form_BattlePass:OnFootadvanced1lockClicked()
  self:ShowBuyBattlePassPanel()
end

function Form_BattlePass:OnFootadvanced2lockClicked()
  self:ShowBuyBattlePassPanel()
end

function Form_BattlePass:OnFootadvanced1lightClicked()
  self:ReqLastLvReward()
end

function Form_BattlePass:OnFootfreelightClicked()
  self:ReqLastLvReward()
end

function Form_BattlePass:OnFootadvanced2lightClicked()
  self:ReqLastLvReward()
end

function Form_BattlePass:OnAdvancedlockClicked()
  self:ShowBuyBattlePassPanel()
end

function Form_BattlePass:ReqLastLvReward()
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

function Form_BattlePass:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroID = tParam.stActivity:GetAvatarId()
  vPackage[#vPackage + 1] = {
    sName = tostring(heroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

function Form_BattlePass:IsFullScreen()
  return true
end

ActiveLuaUI("Form_BattlePass", Form_BattlePass)
return Form_BattlePass
