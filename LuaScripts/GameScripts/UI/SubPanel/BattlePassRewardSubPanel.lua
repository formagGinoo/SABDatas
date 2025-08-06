local UISubPanelBase = require("UI/Common/UISubPanelBase")
local BattlePassRewardSubPanel = class("BattlePassRewardSubPanel", UISubPanelBase)

function BattlePassRewardSubPanel:OnInit()
end

function BattlePassRewardSubPanel:OnActive(activityId)
  if not activityId then
    log.error("Bp Task Tab ActivityId is nil")
    return
  end
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  if not self.m_stActivity then
    log.error("Bp Task Tab Activity is nil")
    return
  end
  self:AddEventListeners()
  self:FreshUI()
end

function BattlePassRewardSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_BattlePass_AdvancedPassBought", handler(self, self.FreshUI))
  self:addEventListener("eGameEvent_Activity_BattlePass_BuyExp", handler(self, self.FreshUI))
end

function BattlePassRewardSubPanel:FreshUI()
  if not self.m_stActivity then
    return
  end
  self:FreshGetAllStatusShow()
  self:FreshButtonStatus()
  self:FreshRewardView()
  self:OnSetRewardIndex()
end

function BattlePassRewardSubPanel:FreshRewardView()
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

function BattlePassRewardSubPanel:OnSetRewardIndex()
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

function BattlePassRewardSubPanel:FreshScrollView()
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

function BattlePassRewardSubPanel:FreshGetAllStatusShow()
  if not self.m_stActivity then
    return
  end
  local hasUnclaimedReward = self.m_stActivity:GetFirstUnclaimedLevel() ~= nil
  self.m_bg_getall_normal:SetActive(hasUnclaimedReward)
  self.m_bg_getall_grey:SetActive(not hasUnclaimedReward)
end

function BattlePassRewardSubPanel:FreshButtonStatus()
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

function BattlePassRewardSubPanel:OnBtnsaleClicked()
  self:ShowBuyBattlePassPanel()
end

function BattlePassRewardSubPanel:OnFootadvanced1lockClicked()
  self:ShowBuyBattlePassPanel()
end

function BattlePassRewardSubPanel:OnFootadvanced2lockClicked()
  self:ShowBuyBattlePassPanel()
end

function BattlePassRewardSubPanel:OnFootadvanced1lightClicked()
  self:ReqLastLvReward()
end

function BattlePassRewardSubPanel:OnFootfreelightClicked()
  self:ReqLastLvReward()
end

function BattlePassRewardSubPanel:OnFootadvanced2lightClicked()
  self:ReqLastLvReward()
end

function BattlePassRewardSubPanel:OnAdvancedlockClicked()
  self:ShowBuyBattlePassPanel()
end

function BattlePassRewardSubPanel:ShowBuyBattlePassPanel()
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

function BattlePassRewardSubPanel:updateScrollViewCell(index, cell_object, cell_data)
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
  local item_txt_num = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_txt_nml")
  local item_txt_numUnlock = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_txt_unlock")
  local item_rewardFx = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_pnl_unlock")
  local advanced1_light = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_advanced1_light")
  local advanced1_lock = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_advanced1_lock")
  local advanced2_light = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_advanced2_light")
  local advanced2_lock = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_advanced2_lock")
  local free_light = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_free_light")
  UILuaHelper.SetActive(advanced1_lock, not isHaveBuy)
  UILuaHelper.SetActive(advanced2_lock, not isHaveBuy)
  local isShowRewardLight = false
  if isNotGetLevel then
    freeItemIcon:SetItemHaveGetActive(false)
    UILuaHelper.SetActive(free_light, false)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(false)
    end
    isShowRewardLight = false
    UILuaHelper.SetActive(item_rewardFx, false)
    UILuaHelper.SetActive(advanced1_light, false)
    UILuaHelper.SetActive(advanced2_light, false)
  elseif drawStatus == 0 then
    freeItemIcon:SetItemHaveGetActive(false)
    UILuaHelper.SetActive(free_light, true)
    UILuaHelper.SetActive(item_rewardFx, true)
    isShowRewardLight = true
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
    UILuaHelper.SetActive(item_rewardFx, isHaveBuy)
    isShowRewardLight = isHaveBuy
  elseif drawStatus == 2 then
    freeItemIcon:SetItemHaveGetActive(true)
    UILuaHelper.SetActive(free_light, false)
    for k, v in ipairs(vPaidList) do
      v.itemIcon:SetItemHaveGetActive(isHaveBuy)
    end
    UILuaHelper.SetActive(advanced1_light, false)
    UILuaHelper.SetActive(advanced2_light, false)
    UILuaHelper.SetActive(item_rewardFx, false)
    isShowRewardLight = false
  end
  if isShowRewardLight then
    item_txt_num:SetActive(false)
    item_txt_numUnlock:SetActive(true)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_unlock", showText)
  else
    item_txt_num:SetActive(true)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_nml", showText)
    item_txt_numUnlock:SetActive(false)
  end
end

function BattlePassRewardSubPanel:FreshLastReward()
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

function BattlePassRewardSubPanel:OnItemClicked(iItemId, iItemNum)
  utils.openItemDetailPop({iID = iItemId, iNum = 1})
end

function BattlePassRewardSubPanel:OnBtngetallClicked()
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

function BattlePassRewardSubPanel:OnBtnsaleupClicked()
  self:ShowBuyBattlePassPanel()
end

function BattlePassRewardSubPanel:OnBtnsaledoneClicked()
  self:ShowBuyBattlePassPanel()
end

function BattlePassRewardSubPanel:ReqLastLvReward()
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

function BattlePassRewardSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function BattlePassRewardSubPanel:OnInActive()
  self:RemoveAllEventListeners()
end

function BattlePassRewardSubPanel:OnRefreshUI()
end

return BattlePassRewardSubPanel
