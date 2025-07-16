local Form_Item_Tips = class("Form_Item_Tips", require("UI/UIFrames/Form_Item_TipsUI"))

function Form_Item_Tips:SetInitParam(param)
end

function Form_Item_Tips:AfterInit()
  local goRoot = self.m_csui.m_uiGameObject
  local goItemIconRoot = self.m_pnl_base.transform:Find("c_common_item_middle").gameObject
  self.m_widgetItemIcon = self:createItemIcon(goItemIconRoot)
  self.m_goChestCertainPanelItemTemplate = self.m_scrollview_mustwin:GetComponent("ScrollRect").content.transform:Find("pnl_item").gameObject
  self.m_goChestCertainPanelItemTemplate:SetActive(false)
  self.m_vChestCertainPanelItem = {}
  self.m_goJumpPanelItemTemplate = self.m_scrollview_access:GetComponent("ScrollRect").content.transform:Find("pnl_item").gameObject
  self.m_goJumpPanelItemTemplate:SetActive(false)
  self.m_vJumpPanelItem = {}
  self.m_widgetNumStepper = self:createNumStepper(self.m_pnl_use.transform:Find("ui_common_stepper"))
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_random_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
  self.m_vJumpPanelItem = {}
end

function Form_Item_Tips:OnActive()
  local tParam = self.m_csui.m_param
  self.m_iID = tParam.iID
  self.m_iNum = tParam.iNum
  self.m_bBag = tParam.bBag
  self.m_stItemData = ResourceUtil:GetProcessRewardData(tParam)
  self.m_random_item_list = {}
  ResourceUtil:CreateEquipQualityImg(self.m_img_line_colour_Image, self.m_stItemData.quality, GlobalConfig.EQUIP_QUALITY_STYLE.Line)
  self.m_widgetItemIcon:SetItemInfo(self.m_iID)
  if CS.UnityEngine.Application.isEditor then
    self.m_iWidgetItemIconClickLastTime = 0
    self.m_widgetItemIcon:SetItemIconClickCB(handler(self, self.OnWidgetItemIconClicked))
  else
    self.m_widgetItemIcon:SetItemIconClickCB(nil)
  end
  self.m_txt_name_Text.text = self.m_stItemData.name
  self.m_txt_num_Text.text = tostring(self.m_iNum)
  if self.m_stItemData.config.m_ItemMaxNum and 0 < self.m_stItemData.config.m_ItemMaxNum and self.m_iNum >= self.m_stItemData.config.m_ItemMaxNum then
    self.m_img_max:SetActive(true)
  else
    self.m_img_max:SetActive(false)
  end
  self.m_pnl_des:SetActive(false)
  self.m_pnl_mustwin:SetActive(false)
  self.m_pnl_random:SetActive(false)
  self.m_pnl_coin:SetActive(false)
  self.m_pnl_use:SetActive(false)
  self.m_pnl_btn:SetActive(false)
  if self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestCertain then
    self:RefreshSubTypeChestCertain()
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestCustom then
    self:RefreshSubTypeChestCustom()
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestRandom then
    self:RefreshSubTypeChestRandom()
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.FragmentCertain then
    self:RefreshSubTypeFragmentCertain()
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.FragmentRandom then
    self:RefreshSubTypeFragmentRandom()
  else
    self:RefreshDesc()
  end
  self:RefreshJump()
  self:RemoveEventListeners()
  self.m_iHandlerIDItemUse = self:addEventListener("eGameEvent_Item_Use", handler(self, self.OnEventItemUse))
end

function Form_Item_Tips:RefreshDesc()
  self.m_pnl_des:SetActive(true)
  local v2TextDescOffset = self.m_txt_desc:GetComponent("RectTransform").anchoredPosition
  v2TextDescOffset.y = 0
  self.m_txt_desc:GetComponent("RectTransform").anchoredPosition = v2TextDescOffset
  self.m_txt_desc_Text.text = self.m_stItemData.description
end

function Form_Item_Tips:RefreshJump()
  local jumpList = utils.changeCSArrayToLuaTable(self.m_stItemData.config.m_SystemWarp)
  if not jumpList or #jumpList == 0 then
    self.m_pnl_jump:SetActive(false)
    return
  end
  self.m_pnl_jump:SetActive(true)
  local panelItemList = self.m_scrollview_access:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.y = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  local goJumpPanelItemTemplate = panelItemList.transform:Find("pnl_item").gameObject
  local vGetItemInfo = jumpList
  for i = 1, #vGetItemInfo do
    local goJumpPanelItem = self.m_vJumpPanelItem[i]
    if goJumpPanelItem == nil then
      goJumpPanelItem = {}
      goJumpPanelItem.go = CS.UnityEngine.GameObject.Instantiate(goJumpPanelItemTemplate, panelItemList)
      self.m_vJumpPanelItem[i] = goJumpPanelItem
    end
    goJumpPanelItem.go:SetActive(true)
    local stGetItemData = CS.CData_Jump.GetInstance():GetValue_ByJumpID(vGetItemInfo[i])
    if stGetItemData then
      goJumpPanelItem.go.transform:Find("c_txt_item_name1"):GetComponent(T_TextMeshProUGUI).text = stGetItemData.m_mName
    end
    local m_btn_jump = goJumpPanelItem.go.transform:Find("m_btn_jump"):GetComponent("Button")
    local m_btn_jump_obj = goJumpPanelItem.go.transform:Find("m_btn_jump").gameObject
    local m_btn_lock = goJumpPanelItem.go.transform:Find("m_btn_lock"):GetComponent("Button")
    local m_btn_lock_obj = goJumpPanelItem.go.transform:Find("m_btn_lock").gameObject
    m_btn_jump.onClick:RemoveAllListeners()
    UILuaHelper.BindButtonClickManual(self, m_btn_jump, function()
      if vGetItemInfo then
        QuickOpenFuncUtil:OpenFunc(vGetItemInfo[i])
        StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ITEM_TIPS)
      end
    end)
    local jumpIns = ConfigManager:GetConfigInsByName("Jump")
    local jump_item = jumpIns:GetValue_ByJumpID(vGetItemInfo[i])
    if jump_item then
      local open_condition_id = jump_item.m_SystemID or 0
      local open_flag, tips_id = UnlockSystemUtil:IsSystemOpen(open_condition_id)
      if 0 < open_condition_id and not open_flag then
        m_btn_jump_obj:SetActive(false)
        m_btn_lock_obj:SetActive(true)
        m_btn_lock.onClick:RemoveAllListeners()
        UILuaHelper.BindButtonClickManual(self, m_btn_lock, function()
          if tips_id then
            local paramData = {delayClose = 2, prompts = tips_id}
            utils.createPromptTips(paramData)
          end
        end)
      else
        m_btn_jump_obj:SetActive(true)
        m_btn_lock_obj:SetActive(false)
      end
    end
  end
  for i = #vGetItemInfo + 1, #self.m_vJumpPanelItem do
    self.m_vJumpPanelItem[i].go:SetActive(false)
  end
end

function Form_Item_Tips:RefreshSubTypeChestCertain()
  self.m_pnl_mustwin:SetActive(true)
  local panelItemList = self.m_scrollview_mustwin:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.y = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  local vGetItemInfo = string.split(self.m_stItemData.config.m_ItemUse, ";")
  for i = 1, #vGetItemInfo do
    local goChestCertainPanelItem = self.m_vChestCertainPanelItem[i]
    if goChestCertainPanelItem == nil then
      goChestCertainPanelItem = {}
      goChestCertainPanelItem.go = CS.UnityEngine.GameObject.Instantiate(self.m_goChestCertainPanelItemTemplate, panelItemList)
      goChestCertainPanelItem.widgetItemIcon = self:createCommonItem(goChestCertainPanelItem.go.transform:Find("c_common_item"))
      self.m_vChestCertainPanelItem[i] = goChestCertainPanelItem
    end
    goChestCertainPanelItem.go:SetActive(true)
    local vItemInfoStr = string.split(vGetItemInfo[i], ",")
    local iGetItemID = tonumber(vItemInfoStr[1])
    local iGetItemNum = tonumber(vItemInfoStr[2])
    local processData = ResourceUtil:GetProcessRewardData({iID = iGetItemID, iNum = iGetItemNum})
    goChestCertainPanelItem.widgetItemIcon:SetItemInfo(processData)
    local stGetItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(iGetItemID)
    if self.m_stItemData.sub_type == ItemManager.ItemSubType.IdleCapsule then
      iGetItemNum = HangUpManager:GetItemProductionByIdAndSeconds(iGetItemID, iGetItemNum)
    end
    goChestCertainPanelItem.go.transform:Find("c_txt_item_name_1"):GetComponent(T_TextMeshProUGUI).text = "x" .. tostring(iGetItemNum)
    goChestCertainPanelItem.go.transform:Find("c_txt_item_name"):GetComponent(T_TextMeshProUGUI).text = stGetItemData.m_mItemName
  end
  for i = #vGetItemInfo + 1, #self.m_vChestCertainPanelItem do
    self.m_vChestCertainPanelItem[i].go:SetActive(false)
  end
  if self.m_bBag then
    self.m_pnl_use:SetActive(true)
    self.m_btn_usedetail:SetActive(false)
    self.m_widgetNumStepper:SetNumShowMax(false)
    self.m_widgetNumStepper:SetNumMax(self.m_iNum)
    self.m_widgetNumStepper:SetNumCur(1)
    self.m_pnl_btn:SetActive(true)
    self.m_btnUse_Button.interactable = true
  end
end

function Form_Item_Tips:RefreshSubTypeChestCustom()
  self:RefreshDesc()
  self.m_pnl_random:SetActive(true)
  self.m_btn_randomdetail:SetActive(false)
  self.m_pnl_random.transform:Find("txt_des_random").gameObject:SetActive(false)
  self.m_pnl_random.transform:Find("txt_des_custom").gameObject:SetActive(true)
  self:RefreshRandomRewardList(self.m_stItemData.config.m_ItemUse)
  if self.m_bBag then
    self.m_pnl_btn:SetActive(true)
    self.m_btnUse_Button.interactable = true
  end
end

function Form_Item_Tips:RefreshSubTypeChestRandom()
  self:RefreshDesc()
  self.m_pnl_random:SetActive(true)
  self.m_btn_randomdetail:SetActive(true)
  self.m_pnl_random.transform:Find("txt_des_random").gameObject:SetActive(true)
  self.m_pnl_random.transform:Find("txt_des_custom").gameObject:SetActive(false)
  local iRandomPoolID = tonumber(self.m_stItemData.config.m_ItemUse)
  local stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(iRandomPoolID)
  if stRandomPoolData == nil then
    return
  end
  local vRandomItemInfo = utils.changeCSArrayToLuaTable(stRandomPoolData.m_RandompoolContent)
  if ActivityManager:IsInCensorOpen() then
    local temp = utils.changeCSArrayToLuaTable(stRandomPoolData.m_CensorRandompoolContent)
    vRandomItemInfo = 0 < #temp and temp or vRandomItemInfo
  end
  self:RefreshRandomRewardList(vRandomItemInfo)
  if self.m_bBag then
    self.m_pnl_use:SetActive(true)
    self.m_btn_usedetail:SetActive(false)
    self.m_widgetNumStepper:SetNumShowMax(false)
    self.m_widgetNumStepper:SetNumMax(self.m_iNum)
    self.m_widgetNumStepper:SetNumCur(1)
    self.m_pnl_btn:SetActive(true)
    self.m_btnUse_Button.interactable = true
  end
end

function Form_Item_Tips:RefreshRandomRewardList(itemList)
  local dataList = {}
  for i, itemInfo in ipairs(itemList) do
    local iGetItemID = tonumber(itemInfo[1])
    local iGetItemNum = tonumber(itemInfo[2])
    local processData = ResourceUtil:GetProcessRewardData({iID = iGetItemID, iNum = iGetItemNum})
    dataList[#dataList + 1] = processData
  end
  self.m_random_item_list = dataList
  self.m_rewardListInfinityGrid:ShowItemList(dataList)
end

function Form_Item_Tips:RefreshSubTypeFragmentCertain()
  self:RefreshDesc()
  if self.m_bBag then
    self.m_pnl_use:SetActive(true)
    self.m_btn_usedetail:SetActive(false)
    local iOneCount = tonumber(string.split(self.m_stItemData.config.m_ItemUse, ":")[2])
    local iMaxNum = math.floor(self.m_iNum / iOneCount)
    self.m_widgetNumStepper:SetNumShowMax(true)
    if iMaxNum == 0 then
      self.m_widgetNumStepper:SetNumMax(0)
      self.m_widgetNumStepper:SetNumCur(0)
      self.m_btnUse_Button.interactable = false
    else
      self.m_widgetNumStepper:SetNumMax(iMaxNum)
      self.m_widgetNumStepper:SetNumCur(1)
      self.m_btnUse_Button.interactable = true
    end
    self.m_pnl_btn:SetActive(true)
  end
end

function Form_Item_Tips:RefreshSubTypeFragmentRandom()
  self:RefreshDesc()
  if self.m_bBag then
    self.m_pnl_use:SetActive(true)
    self.m_btn_usedetail:SetActive(true)
    local iOneCount = tonumber(string.split(self.m_stItemData.config.m_ItemUse, ":")[2])
    local iMaxNum = math.floor(self.m_iNum / iOneCount)
    self.m_widgetNumStepper:SetNumShowMax(true)
    if iMaxNum == 0 then
      self.m_widgetNumStepper:SetNumMax(0)
      self.m_widgetNumStepper:SetNumCur(0)
      self.m_btnUse_Button.interactable = false
    else
      self.m_widgetNumStepper:SetNumMax(iMaxNum)
      self.m_widgetNumStepper:SetNumCur(1)
      self.m_btnUse_Button.interactable = true
    end
    self.m_pnl_btn:SetActive(true)
  end
end

function Form_Item_Tips:RemoveEventListeners()
  if self.m_iHandlerIDItemUse then
    self:removeEventListener("eGameEvent_Item_Use", self.m_iHandlerIDItemUse)
    self.m_iHandlerIDItemUse = nil
  end
end

function Form_Item_Tips:OnInactive()
  self:RemoveEventListeners()
end

function Form_Item_Tips:OnBtnrandomdetailClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  local iRandomPoolID = tonumber(self.m_stItemData.config.m_ItemUse)
  local stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(iRandomPoolID)
  if stRandomPoolData == nil then
    return
  end
  if stRandomPoolData.m_RandompoolUIType == 1 then
    StackPopup:Push(UIDefines.ID_FORM_BAGINFO, {iRandomPoolID = iRandomPoolID})
  else
    StackPopup:Push(UIDefines.ID_FORM_ITEMRANDOMDETAIL, {iRandomPoolID = iRandomPoolID})
  end
end

function Form_Item_Tips:OnBtnusedetailClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  local iRandomPoolID = tonumber(string.split(self.m_stItemData.config.m_ItemUse, ":")[1])
  local stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(iRandomPoolID)
  if stRandomPoolData == nil then
    return
  end
  if stRandomPoolData.m_RandompoolUIType == 1 then
    StackPopup:Push(UIDefines.ID_FORM_BAGINFO, {iRandomPoolID = iRandomPoolID})
  else
    StackPopup:Push(UIDefines.ID_FORM_ITEMRANDOMDETAIL, {iRandomPoolID = iRandomPoolID})
  end
end

function Form_Item_Tips:OnEventItemUse(stItemUseInfo)
  local iID = stItemUseInfo.iID
  if self.m_iID == iID then
    local vReward = stItemUseInfo.vReward
    if vReward and next(vReward) then
      utils.popUpRewardUI(vReward)
    end
    StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ITEM_TIPS)
  end
end

function Form_Item_Tips:OnBtnUseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  if self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestCertain then
    ItemManager:RequestItemUse(self.m_iID, self.m_widgetNumStepper:GetNumCur())
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestCustom then
    StackFlow:Push(UIDefines.ID_FORM_OPTIONALGIFT, {
      iID = self.m_iID
    })
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestRandom then
    ItemManager:RequestItemUse(self.m_iID, self.m_widgetNumStepper:GetNumCur())
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.FragmentCertain then
    local iNum = self.m_widgetNumStepper:GetNumCur()
    if 0 < iNum then
      local iOneCount = tonumber(string.split(self.m_stItemData.config.m_ItemUse, ":")[2])
      iNum = iNum * iOneCount
      ItemManager:RequestItemUse(self.m_iID, iNum)
    end
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.FragmentRandom then
    local iNum = self.m_widgetNumStepper:GetNumCur()
    if 0 < iNum then
      local iOneCount = tonumber(string.split(self.m_stItemData.config.m_ItemUse, ":")[2])
      iNum = iNum * iOneCount
      ItemManager:RequestItemUse(self.m_iID, iNum)
    end
  end
end

function Form_Item_Tips:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_random_item_list[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    })
  end
end

function Form_Item_Tips:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ITEM_TIPS)
end

function Form_Item_Tips:OnWidgetItemIconClicked()
  local iDiff = CS.Util.GetTime() - self.m_iWidgetItemIconClickLastTime
  if iDiff <= 300 then
    local loginContext = CS.LoginContext.GetContext()
    Util.RequestGM(loginContext.CurZoneInfo.iZoneId, "add_item " .. loginContext.AccountID .. " " .. self.m_iID .. " 999")
  end
  self.m_iWidgetItemIconClickLastTime = CS.Util.GetTime()
end

function Form_Item_Tips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Item_Tips", Form_Item_Tips)
return Form_Item_Tips
