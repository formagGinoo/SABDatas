local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ActivityReturnSubPanel = class("ActivityReturnSubPanel", UISubPanelBase)

function ActivityReturnSubPanel:OnInit()
  self.tweenSequence = self.m_rootObj:AddComponent(typeof(CS.TweenSequence))
  self.taskItems = {}
  self.rewardItems = {}
  self:BuildTaskItem(self.m_item2.transform)
  self:BuildRewardItem(self.m_item.transform)
  self:SwitchRightPanelState(1)
  self:OnActivityDataChange()
  self:addEventListener("eGameEvent_Activity_RefreshReturnTask", handler(self, self.OnActivityDataChange))
  self:addEventListener("eGameEvent_Activity_RefreshReturnTaskStatus", handler(self, self.OnActivityStateChange))
  self:addEventListener("eGameEvent_Activity_RefreshReturnBuyPackage", handler(self, self.ShowPackageUnlock))
  self.m_img_bg_lock2_Image.raycastTarget = true
end

function ActivityReturnSubPanel:OnFreshData()
end

function ActivityReturnSubPanel:OnActivePanel()
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  if returnTaskAct:NeedRemindGift() then
    StackPopup:Push(UIDefines.ID_FORM_RETURNEEEVENTPOP, self)
  else
    self:SwitchRightPanelState(self.rightPanleIndex or 1)
  end
end

function ActivityReturnSubPanel:OnInactivePanel()
end

function ActivityReturnSubPanel:OnDestroy()
  self.super.OnDestroy(self)
  self:clearEventListener()
end

function ActivityReturnSubPanel:OnActivityDataChange()
  self:RefreshByConfig()
  self:OnActivityStateChange()
end

function ActivityReturnSubPanel:OnActivityStateChange()
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  self:RefreshTask(returnTaskAct)
  self:RefreshRewardState(returnTaskAct)
  self:RefreshProgress(returnTaskAct)
  self:RefreshPackageState(returnTaskAct)
end

function ActivityReturnSubPanel:SwitchRightPanelState(index)
  if self.rightPanleIndex == index then
    return
  end
  self.rightPanleIndex = index
  if index == 1 then
    self.m_scrollview:GetComponent("ScrollRect").verticalNormalizedPosition = 1
  end
  self.m_pnl_pack1:SetActive(index == 1)
  self.m_pnl_pack2:SetActive(index == 2)
  self.m_btn_rw_grey:SetActive(index == 2)
  self.m_btn_wsd_grey:SetActive(index == 1)
end

function ActivityReturnSubPanel:ShowPackageUnlock(index, from, to)
  self:SwitchRightPanelState(1)
  if index == 1 then
    self.tweenSequence:AppendActive(self.m_fx_light_lock1, true)
    self.tweenSequence:AppendInterval(1)
    if from < to then
      self:ShowProgressIncrease(from, to)
    end
    self.tweenSequence:AppendActive(self.m_fx_light_lock1, false)
  elseif index == 2 then
    self.tweenSequence:AppendActive(self.m_fx_light_lock2, true)
    self.tweenSequence:AppendInterval(1)
    if from < to then
      self:ShowProgressIncrease(from, to)
    end
    self.tweenSequence:AppendActive(self.m_fx_light_lock2, false)
  end
  self.tweenSequence:AppendAction(handler(self, self.OnActivityStateChange))
end

function ActivityReturnSubPanel:ShowProgressIncrease(from, to)
  if to <= from then
    return
  end
  self:SwitchRightPanelState(1)
  self.tweenSequence:AppendAction(function()
    self.m_txt_leve_Text.text = tostring(to)
  end)
  local scroll = self.m_scrollview:GetComponent("ScrollRect")
  local hasScroll = false
  for i, v in ipairs(self.rewardItems) do
    if from <= v.ProgressValue and to >= v.ProgressValue then
      if not hasScroll then
        hasScroll = true
        self.tweenSequence:AppendAction(function()
          local value = math.clamp(1 - (i - 1) / (#self.rewardItems + 1), 0, 1)
          if value < scroll.verticalNormalizedPosition then
            scroll.verticalNormalizedPosition = value
          end
        end)
      end
      local prevItem = self.rewardItems[i - 1]
      local prevValue = prevItem and prevItem.ProgressValue or 0
      local total = v.ProgressValue - prevValue
      local current = math.clamp((from - prevValue) / total, 0, 1)
      local value = math.clamp((to - prevValue) / total, 0, 1)
      local duration = (value - current) * 0.1
      self.tweenSequence:Append(DOTweenModuleUI.DOFillAmount(v.LineImage, value, duration))
      self.tweenSequence:AppendActive(v.IconLight, true)
      self.tweenSequence:AppendActive(v.IconGray, false)
      self.tweenSequence:AppendActive(v.ProgressFX, true)
    end
  end
  self.tweenSequence:AppendAction(function()
    local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
    if returnTaskAct == nil then
      return
    end
    self:RefreshProgress(returnTaskAct)
    self:RefreshRewardState(returnTaskAct)
  end)
  self.tweenSequence:AppendInterval(0.5)
  self.tweenSequence:AppendAction(function()
    for i, v in ipairs(self.rewardItems) do
      self.tweenSequence:AppendActive(v.ProgressFX, false)
    end
  end)
end

function ActivityReturnSubPanel:RefreshByConfig()
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  self:RefreshTask(returnTaskAct)
  self:RefreshReward(returnTaskAct)
  self:RefreshPackage(returnTaskAct)
end

function ActivityReturnSubPanel:RefreshReward(returnTaskAct)
  local rewardList = returnTaskAct:GetRewardList()
  local rewardRoot = self.m_item.transform.parent
  while #self.rewardItems < #rewardList do
    local item = CS.UnityEngine.Object.Instantiate(self.m_item, rewardRoot)
    self:BuildRewardItem(item.transform)
  end
  for i, v in ipairs(self.rewardItems) do
    v.Root:SetActive(i <= #rewardList)
  end
  for i, v in ipairs(rewardList) do
    local item = self.rewardItems[i]
    item.ProgressValue = v.iProgressValue
    item.GrayNumTxt.text = tostring(v.iProgressValue)
    item.LightNumTxt.text = tostring(v.iProgressValue)
    local freeReward = v.vFreeReward[1]
    local lowerReward = v.vLowerPayReward[1]
    local seniorReward = v.vHigherPayReward[1]
    self:InitRewardItem(item.Item1, freeReward, i, 0)
    self:InitRewardItem(item.Item2, lowerReward, i, 1)
    self:InitRewardItem(item.Item3, seniorReward, i, 2)
    item.LineImage.fillAmount = 0
    if i == 1 then
      item.LineTransform.localScale = Vector3(1, 0.6, 1)
    end
  end
end

function ActivityReturnSubPanel:RefreshPackage(returnTaskAct)
  local lowPackCfg = returnTaskAct:GetGoodCfg(1)
  local lowPrice = IAPManager:GetProductPrice(lowPackCfg.sProductId, true)
  self.m_txt_price_Text.text = lowPrice
  self.m_txt_price2_Text.text = lowPrice
  if lowPackCfg.iExtraBonusProgressValue > 0 then
    self.m_img_tilebg:SetActive(true)
    self.m_txt_qty_Text.text = "x" .. lowPackCfg.iExtraBonusProgressValue
  else
    self.m_img_tilebg:SetActive(false)
  end
  self.m_txt_pack_Text.text = returnTaskAct:getLangText(lowPackCfg.iGiftName)
  self.m_txt_tile3_Text.text = returnTaskAct:getLangText(lowPackCfg.iGiftName)
  local imgIcon = self.m_pnl_item.transform:Find("img_icon"):GetComponent(T_Image)
  UILuaHelper.SetAtlasSprite(imgIcon, lowPackCfg.iGiftPic)
  self.m_txt_pct2_Text.text = tostring(lowPackCfg.iCostEffectivenes) .. "%"
  self:InitPackageRewardItems(self.m_pnl_prop.transform, returnTaskAct:GetLowRewardItems())
  local highPackCfg = returnTaskAct:GetGoodCfg(2)
  local highPrice = IAPManager:GetProductPrice(highPackCfg.sProductId, true)
  self.m_txt_price4_Text.text = highPrice
  self.m_txt_price5_Text.text = highPrice
  if highPackCfg.iExtraBonusProgressValue > 0 then
    self.m_img_tilebg2:SetActive(true)
    self.m_txt_qty2_Text.text = "x" .. highPackCfg.iExtraBonusProgressValue
  else
    self.m_img_tilebg2:SetActive(false)
  end
  self.m_txt_pack2_Text.text = returnTaskAct:getLangText(highPackCfg.iGiftName)
  self.m_txt_tile4_Text.text = returnTaskAct:getLangText(highPackCfg.iGiftName)
  local imgIcon2 = self.m_pnl_item2.transform:Find("img_icon"):GetComponent(T_Image)
  UILuaHelper.SetAtlasSprite(imgIcon2, highPackCfg.iGiftPic)
  self.m_txt_pct3_Text.text = tostring(highPackCfg.iCostEffectivenes) .. "%"
  self:InitPackageRewardItems(self.m_pnl_prop2.transform, returnTaskAct:GetHeighRewardItems())
  self.m_txt_pct_Text.text = tostring(math.max(lowPackCfg.iCostEffectivenes, highPackCfg.iCostEffectivenes)) .. "%"
end

function ActivityReturnSubPanel:InitPackageRewardItems(root, rewards)
  local template = root:GetChild(0).gameObject
  while root.childCount < #rewards do
    CS.UnityEngine.Object.Instantiate(template, root)
  end
  local childCount = root.childCount
  for i = 1, childCount do
    local child = root:GetChild(i - 1).gameObject
    if i <= #rewards then
      child:SetActive(true)
      local reward = rewards[i]
      local c_free_light = child.transform:Find("c_free_light").gameObject
      c_free_light:SetActive(false)
      local processData = ResourceUtil:GetProcessRewardData(reward)
      local itemWidgetIcon = self:createCommonItem(child)
      itemWidgetIcon:SetItemInfo(processData)
      itemWidgetIcon:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        utils.openItemDetailPop({iID = itemID, iNum = itemNum})
      end)
    else
      child:SetActive(false)
    end
  end
end

function ActivityReturnSubPanel:InitRewardItem(itemGo, reward, index, type)
  local processData = ResourceUtil:GetProcessRewardData(reward)
  local itemWidgetIcon = self:createCommonItem(itemGo)
  itemWidgetIcon:SetItemInfo(processData)
  itemWidgetIcon:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom, index, type)
  end)
end

function ActivityReturnSubPanel:RefreshTask(returnTaskAct)
  local taskList = returnTaskAct:GetTaskInfoList()
  local taskRoot = self.m_item2.transform.parent
  while #self.taskItems < #taskList do
    local item = CS.UnityEngine.Object.Instantiate(self.m_item2, taskRoot)
    self:BuildTaskItem(item.transform)
  end
  for i, v in ipairs(self.taskItems) do
    v.Root:SetActive(i <= #taskList)
  end
  for i, v in ipairs(taskList) do
    local item = self.taskItems[i]
    local txt = ConfigManager:GetCommonTextById(220029)
    local fmt = "<color=#7DB859>%d</color>/%d"
    if v.FinishTimes >= v.MaxFinishTimes then
      fmt = "<color=#D30000>%d</color>/%d"
    end
    local p = string.format(fmt, v.FinishTimes, v.MaxFinishTimes)
    item.TitleTxt.text = string.CS_Format(txt, p)
    item.Mask:SetActive(v.AwardedTimes >= v.MaxFinishTimes)
    local times = v.FinishTimes - v.AwardedTimes
    if times <= 0 then
      times = 1
    end
    item.ScoreTxt.text = tostring(v.ProgressValue * times)
    item.StepTxt.text = string.format("%d/%d", v.Step, v.Element.m_ObjectiveCount)
    item.ProgressImg.fillAmount = 0 < v.Element.m_ObjectiveCount and v.Step / v.Element.m_ObjectiveCount or 0
    local c_free_light = item.ItemGo.transform:Find("c_free_light").gameObject
    c_free_light:SetActive(v.AwardedTimes < v.FinishTimes)
    if item.TaskID ~= v.TaskID or item.Index ~= v.Index then
      item.TaskID = v.TaskID
      item.Index = v.Index
      local param = utils.changeCSArrayToLuaTable(v.Element.m_DescParam)
      item.ContentTxt.text = string.CS_Format(v.Element.m_mTaskName, param)
      if v.Reward then
        item.ItemGo:SetActive(true)
        local processData = ResourceUtil:GetProcessRewardData(v.Reward)
        local itemWidgetIcon = self:createCommonItem(item.ItemGo)
        itemWidgetIcon:SetItemInfo(processData)
        itemWidgetIcon:SetItemIconClickCB(function(itemID, itemNum, itemCom)
          self:OnTaskRewardClick(itemID, itemNum, itemCom, v.Index)
        end)
      else
        item.ItemGo:SetActive(false)
      end
    end
    if v.Reward then
      item.ItemGo.transform:Find("c_num_bg/c_txt_num"):GetComponent("TMPPro").text = tostring(v.Reward.iNum * times)
    end
  end
end

function ActivityReturnSubPanel:RefreshRewardState(returnTaskAct)
  local rewardList = returnTaskAct:GetRewardList()
  local currentProgress = returnTaskAct:GetCurrentProgress()
  local isLowUnlock = returnTaskAct:IsGoodUnlock(1)
  local isHeighUnlock = returnTaskAct:IsGoodUnlock(2)
  self.m_img_mask:SetActive(not isLowUnlock)
  for i, v in ipairs(rewardList) do
    local item = self.rewardItems[i]
    if item ~= nil then
      item.ItemLock2:SetActive(not isLowUnlock)
      item.ItemLock3:SetActive(not isHeighUnlock)
      local isTakeFree = returnTaskAct:IsRewardTake(item.ProgressValue, 0)
      local isTakeLower = returnTaskAct:IsRewardTake(item.ProgressValue, 1)
      local isTakeHeigh = returnTaskAct:IsRewardTake(item.ProgressValue, 2)
      local typeFree = 0
      local typeLower = 0
      local typeHeigh = 0
      if currentProgress and currentProgress >= item.ProgressValue then
        typeFree = 1
        if isLowUnlock then
          typeLower = 1
        end
        if isHeighUnlock then
          typeHeigh = 1
        end
        if isTakeFree then
          typeFree = 2
        end
        if isTakeLower then
          typeLower = 2
        end
        if isTakeHeigh then
          typeHeigh = 2
        end
      end
      self:SetItemState(item.Item1, typeFree)
      self:SetItemState(item.Item2, typeLower)
      self:SetItemState(item.Item3, typeHeigh)
    end
  end
end

function ActivityReturnSubPanel:RefreshPackageState(returnTaskAct)
  local unlockLow = returnTaskAct:IsGoodUnlock(1)
  local unlockHeigh = returnTaskAct:IsGoodUnlock(2)
  self.m_img_bg_lock:SetActive(false)
  self.m_img_bg_get:SetActive(unlockLow)
  self.m_pnl_bg_light:SetActive(not unlockLow)
  self.m_img_bg_lock2:SetActive(not unlockLow)
  self.m_pnl_bg_light2:SetActive(unlockLow and not unlockHeigh)
  self.m_img_bg_get2:SetActive(unlockHeigh)
end

function ActivityReturnSubPanel:SetItemState(item, type)
  local transform = item.transform
  local haveGet = transform:Find("c_item_have_get").gameObject
  local canGet = transform:Find("c_free_light").gameObject
  haveGet:SetActive(type == 2)
  canGet:SetActive(type == 1)
end

function ActivityReturnSubPanel:RefreshProgress(returnTaskAct)
  local rewardList = returnTaskAct:GetRewardList()
  local currentProgress = returnTaskAct:GetCurrentProgress()
  self.m_txt_leve_Text.text = tostring(currentProgress)
  for i, v in ipairs(rewardList) do
    local prev = rewardList[i - 1]
    local item = self.rewardItems[i]
    local prevValue = prev and prev.iProgressValue or 0
    local total = v.iProgressValue - prevValue
    local current = currentProgress - prevValue
    item.LineImage.fillAmount = math.clamp(current / total, 0, 1)
    item.IconLight:SetActive(currentProgress >= v.iProgressValue)
    item.IconGray:SetActive(currentProgress < v.iProgressValue)
  end
end

function ActivityReturnSubPanel:BuildTaskItem(child)
  local taskItem = {
    TaskIndex = -1,
    TaskID = -1,
    Root = child.gameObject,
    TitleTxt = child:Find("img_tile_task/m_txt_tps"):GetComponent("TMPPro"),
    Mask = child:Find("pnl_task/m_pnl_mask").gameObject,
    ScoreTxt = child:Find("pnl_task/img_icon/m_task_num"):GetComponent("TMPPro"),
    ContentTxt = child:Find("pnl_task/m_txt_task"):GetComponent("TMPPro"),
    StepTxt = child:Find("pnl_task/pnl_pgb/m_txt_pgb"):GetComponent("TMPPro"),
    ProgressImg = child:Find("pnl_task/pnl_pgb/m_img_pgb"):GetComponent(T_Image),
    ItemGo = child:Find("pnl_task/m_common_item").gameObject
  }
  table.insert(self.taskItems, taskItem)
  local click = child:Find("pnl_task"):GetComponent(T_Image)
  click.raycastTarget = true
  local btn = click.gameObject:GetComponent(T_Button)
  if btn then
    btn.onClick:RemoveAllListeners()
  else
    btn = click.gameObject:AddComponent(T_Button)
    btn.transition = CS.UnityEngine.UI.Selectable.Transition.None
  end
  local index = #self.taskItems
  btn.onClick:AddListener(function()
    self:OnTaskBGClick(index)
  end)
end

function ActivityReturnSubPanel:BuildRewardItem(child)
  local rewardItem = {
    ProgressValue = -1,
    Root = child.gameObject,
    Item1 = child:Find("m_common_item2").gameObject,
    Item2 = child:Find("m_common_item3").gameObject,
    Item3 = child:Find("m_common_item4").gameObject,
    ItemLock2 = child:Find("m_img_lock").gameObject,
    ItemLock3 = child:Find("m_img_lock2").gameObject,
    IconGray = child:Find("m_icon_grey").gameObject,
    GrayNumTxt = child:Find("m_icon_grey/m_txt_num"):GetComponent("TMPPro"),
    IconLight = child:Find("m_icon_light").gameObject,
    LightNumTxt = child:Find("m_icon_light/m_txt_num2"):GetComponent("TMPPro"),
    LineImage = child:Find("m_img_linebg/m_img_line"):GetComponent(T_Image),
    LineTransform = child:Find("m_img_linebg"),
    ProgressFX = child:Find("m_fx_getaward").gameObject
  }
  child.name = tostring(#self.rewardItems)
  table.insert(self.rewardItems, rewardItem)
  local click = child:Find("img_bg"):GetComponent(T_Image)
  click.raycastTarget = true
  local btn = click.gameObject:GetComponent(T_Button)
  if btn then
    btn.onClick:RemoveAllListeners()
  else
    btn = click.gameObject:AddComponent(T_Button)
    btn.transition = CS.UnityEngine.UI.Selectable.Transition.None
  end
  btn.onClick:AddListener(handler(self, self.OnRewardBGClick))
end

function ActivityReturnSubPanel:OnTaskRewardClick(itemID, itemNum, itemCom, index)
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct ~= nil then
    local taskList = returnTaskAct:GetTaskInfoList()
    for i, v in ipairs(taskList) do
      if v.Index == index then
        if v.AwardedTimes < v.FinishTimes then
          returnTaskAct:TaskQuestReward(v.Index, handler(self, self.OnTaskTaskReward))
          return
        end
        break
      end
    end
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function ActivityReturnSubPanel:OnTaskBGClick(index)
  local item = self.taskItems[index]
  index = item and item.Index or -1
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct ~= nil then
    local taskList = returnTaskAct:GetTaskInfoList()
    for i, v in ipairs(taskList) do
      if v.Index == index then
        if v.AwardedTimes < v.FinishTimes then
          returnTaskAct:TaskQuestReward(index, handler(self, self.OnTaskTaskReward))
          return
        end
        break
      end
    end
  end
end

function ActivityReturnSubPanel:OnRewardItemClick(itemID, itemNum, itemCom, index, type)
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct ~= nil then
    local item = self.rewardItems[index]
    if item.ProgressValue <= returnTaskAct:GetCurrentProgress() then
      local isLowUnlock = returnTaskAct:IsGoodUnlock(type)
      if isLowUnlock and not returnTaskAct:IsRewardTake(item.ProgressValue, type) then
        returnTaskAct:TakeReward(item.ProgressValue)
        return
      end
    end
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function ActivityReturnSubPanel:OnRewardBGClick()
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct ~= nil and returnTaskAct:IsAnyRewardCanTake() then
    returnTaskAct:TakeReward()
  end
end

function ActivityReturnSubPanel:OnTaskTaskReward(taskIndex, preValue, toValue)
  if preValue == toValue then
    self.OnActivityStateChange()
    return
  end
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  self:SwitchRightPanelState(1)
  for i, v in ipairs(self.taskItems) do
    if v.Index == taskIndex then
      local pos = CS.UI.UILuaHelper.UIPositionToLocalPointInRectangle(v.ScoreTxt.transform.parent, self.m_uifx_trail_star.transform.parent)
      self.tweenSequence:AppendActive(self.m_uifx_trail_star, true)
      self.tweenSequence:AppendAnchoredPosition(self.m_uifx_trail_star.transform, pos)
      local target = self.m_txt_leve.transform.parent:Find("img_icon")
      local targetPos = CS.UI.UILuaHelper.UIPositionToLocalPointInRectangle(target, self.m_uifx_trail_star.transform.parent)
      self.tweenSequence:AppendRectangleMove(self.m_uifx_trail_star.transform, targetPos, 1)
      break
    end
  end
  self:RefreshTask(returnTaskAct)
  self.tweenSequence:AppendInterval(0.2)
  self.tweenSequence:AppendActive(self.m_uifx_trail_star, false)
  self:ShowProgressIncrease(preValue, toValue)
  self.tweenSequence:AppendAction(handler(self, self.OnActivityStateChange))
end

function ActivityReturnSubPanel:OnBtndescClicked()
  utils.popUpDirectionsUI({
    tipsID = 1262,
    func1 = function()
    end
  })
end

function ActivityReturnSubPanel:OnBtnrwgreyClicked()
  self:SwitchRightPanelState(1)
end

function ActivityReturnSubPanel:OnBtnwsdgreyClicked()
  self:SwitchRightPanelState(2)
end

function ActivityReturnSubPanel:OnBtnbglightClicked()
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  local unlockLow = returnTaskAct:IsGoodUnlock(1)
  if not unlockLow then
    returnTaskAct:BuyGiftPackage(1)
  else
    self:OnActivityStateChange()
  end
end

function ActivityReturnSubPanel:OnBtnbglight2Clicked()
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  local unlock = returnTaskAct:IsGoodUnlock(2)
  if not unlock then
    returnTaskAct:BuyGiftPackage(2)
  else
    self:OnActivityStateChange()
  end
end

function ActivityReturnSubPanel:OnImgbglock2Clicked()
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  local txt = ConfigManager:GetClientMessageTextById(52012)
  local cfg = returnTaskAct:GetGoodCfg(1)
  txt = string.CS_Format(txt, returnTaskAct:getLangText(cfg.iGiftName))
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, txt)
end

return ActivityReturnSubPanel
