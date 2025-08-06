local Form_ItemTips = class("Form_ItemTips", require("UI/UIFrames/Form_ItemTipsUI"))
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local BTN_CHANGE_POS1 = {
  436,
  2,
  0
}
local BTN_CHANGE_POS2 = {
  270,
  2,
  0
}
local BTN_TAKEOFF_POS1 = {
  66,
  2,
  0
}
local BTN_TAKEOFF_POS2 = {
  -270,
  2,
  0
}
local BTN_UPGRADE_POS1 = {
  -401,
  2,
  0
}
local BTN_UPGRADE_POS2 = {
  0,
  2,
  0
}
local BTN_OVERLOAD_POS1 = {
  -401,
  -9,
  0
}
local BTN_OVERLOAD_POS2 = {
  0,
  -9,
  0
}
local IntervalNum = 5

function Form_ItemTips:SetInitParam(param)
end

function Form_ItemTips:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.m_widgetItemIcon = self:createCommonItem(self.m_common_item)
  self.m_widgetNumStepper = self:createNumStepper(self.m_pnl_use)
  self.m_grayImgMaterial = self.m_img_gray_Image.material
  self.m_updateQueueItemBig = self:addComponent("UpdateQueue", IntervalNum)
end

function Form_ItemTips:OnActive()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(35)
  self.super.OnActive(self)
  self.m_random_item_list = {}
  self.m_vGiftPanelItem = {}
  self.m_hRewardPanelItem = {}
  self.m_vJumpPanelItem = {}
  self.m_iNumCur = 1
  self.m_updateQueueItemBig:clear()
  self.m_widgetNumStepper:SetNumCur(1)
  self:RefreshData()
  self:RefreshLeftUI()
  self:RefreshRightUI()
  self:AddEventListeners()
end

function Form_ItemTips:RefreshData()
  local tParam = self.m_csui.m_param
  if tParam.equipData then
    self.m_equipData = tParam.equipData
    self.m_selPos = tParam.pos
    self.m_bBag = tParam.bBag
    self.m_iEquipLv = tParam.equipData.iLevel or 0
    self.m_iNum = tParam.iNum or 0
    self.m_iID = self.m_equipData.iID
    if self.m_equipData and self.m_equipData.iBaseId then
      self.m_iID = self.m_equipData.iBaseId
    end
    self.m_stItemData = ResourceUtil:GetProcessRewardData({
      iID = self.m_iID,
      iNum = 0
    }, self.m_equipData)
    self.m_closeCallBackFun = tParam.callBackFun
  else
    self.m_iID = tParam.iID
    self.m_iNum = tParam.iNum or 0
    self.m_bBag = tParam.bBag
    self.m_closeCallBackFun = tParam.callBackFun
    self.forceSetNum = tParam.forceSetNum
    local item_type = ResourceUtil:GetResourceTypeById(self.m_iID)
    local num = item_type == ResourceUtil.RESOURCE_TYPE.FRAGMENT and self.m_iNum or 0
    self.m_stItemData = ResourceUtil:GetProcessRewardData({
      iID = self.m_iID,
      iNum = num
    }, {
      bBag = self.m_bBag,
      showRedPoint = 0
    })
  end
end

function Form_ItemTips:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_updateQueueItemBig:clear()
  self:DestroyObj()
end

function Form_ItemTips:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Use", handler(self, self.OnEventItemUse))
  self:addEventListener("eGameEvent_Equip_UnInstallEquip", handler(self, self.OnEventUnInstallEquip))
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.RefreshLeftUI))
  self:addEventListener("eGameEvent_Equip_AddExp", handler(self, self.OnEquipLevelUp))
  self:addEventListener("eGameEvent_Equip_Overload", handler(self, self.OnBtnCloseClicked))
end

function Form_ItemTips:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_ItemTips:OnEquipLevelUp(param)
  self.m_iEquipLv = param.iLevel
  self.m_equipData.iLevel = self.m_iEquipLv
  local m_iID = self.m_equipData.iID
  if self.m_equipData and self.m_equipData.iBaseId then
    m_iID = self.m_equipData.iBaseId
  end
  self.m_stItemData = ResourceUtil:GetProcessRewardData({iID = m_iID, iNum = 0}, self.m_equipData)
  self:RefreshLeftUI()
  self:RefreshRightUI()
end

function Form_ItemTips:RefreshLeftUI()
  self.m_widgetItemIcon:SetItemInfo(self.m_stItemData)
  if CS.UnityEngine.Application.isEditor then
    self:FreshGMBtn()
  else
    UILuaHelper.SetActive(self.m_btn_gm, false)
  end
  self.m_txt_name_Text.text = self.m_stItemData.name
  local total = self.m_stItemData.sub_type == ItemManager.ItemSubType.Equipment and EquipManager:GetEquipNumByCfgID(self.m_iID) or ItemManager:GetItemNum(self.m_iID)
  self.m_txt_num_Text.text = BigNumFormat(total)
  if self.m_stItemData.config.m_ItemMaxNum and self.m_stItemData.config.m_ItemMaxNum > 0 and self.m_iNum >= self.m_stItemData.config.m_ItemMaxNum then
    self.m_img_max:SetActive(true)
    UILuaHelper.SetColor(self.m_txt_num_Text, table.unpack(GlobalConfig.COMMON_COLOR.Red))
  else
    self.m_img_max:SetActive(false)
    UILuaHelper.SetColor(self.m_txt_num_Text, table.unpack(GlobalConfig.COMMON_COLOR.Normal))
  end
  if self.forceSetNum then
    self.m_txt_num_Text.text = self.m_iNum or 0
  end
  local item_type = ResourceUtil:GetResourceTypeById(self.m_iID)
  if item_type == ResourceUtil.RESOURCE_TYPE.HEAD_ICONS or item_type == ResourceUtil.RESOURCE_TYPE.HEAD_FRAME_ICONS then
    UILuaHelper.SetActive(self.m_pnl_num, false)
  else
    UILuaHelper.SetActive(self.m_pnl_num, true)
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_num)
  end
  local act = ActivityManager:GetActivityByType(MTTD.ActivityType_ConsumeReward)
  if act then
    if not act:checkCondition() then
      return
    end
    local pointItemId = act:GetPointItemId()
    if pointItemId == self.m_iID then
      local total = act:GetCurPoint()
      self.m_txt_num_Text.text = BigNumFormat(total)
    end
  end
end

function Form_ItemTips:RefreshRightUI()
  self.m_pnl_attributes:SetActive(false)
  self.m_pnl_camp:SetActive(false)
  self.m_btn_possible_detail:SetActive(false)
  self.m_pnl_gift:SetActive(false)
  self.m_pnl_reward:SetActive(false)
  self.m_img_t10_quality:SetActive(false)
  self:RefreshJump()
  if self.m_stItemData.sub_type == ItemManager.ItemSubType.Equipment then
    self.m_pnl_down_item:SetActive(false)
    self.m_pnl_down_equip:SetActive(true)
    local showBtn = false
    if self.m_equipData.iHeroId and self.m_selPos and self.m_equipData.iHeroId ~= 0 and self.m_selPos ~= 0 then
      showBtn = true
    end
    self.m_btn_takeoff:SetActive(showBtn)
    self.m_btn_change:SetActive(showBtn)
    self.m_img_line:SetActive(showBtn)
    local canLvUpFlag = EquipManager:CheckEquipCanLvUp(self.m_equipData.iEquipUid)
    local showUpgrade = (showBtn or self.m_bBag) and canLvUpFlag
    self.m_btn_upgrade:SetActive(showUpgrade)
    self.m_z_txt_maxlevel:SetActive((showBtn or self.m_bBag) and not canLvUpFlag)
    self:RefreshEquipAttrs()
    self:RefreshEquipCampInfo()
    self.m_img_t10_quality:SetActive(true)
    self:ShowEquipQuality()
    local showOverLoad = EquipManager:CheckEquipCanOverloadById(self.m_equipData.iEquipUid)
    self.m_btn_overload:SetActive(showOverLoad and not self.m_bBag)
    if showBtn and (showUpgrade or showOverLoad) then
      UILuaHelper.SetLocalPosition(self.m_btn_change, table.unpack(BTN_CHANGE_POS1))
      UILuaHelper.SetLocalPosition(self.m_btn_takeoff, table.unpack(BTN_TAKEOFF_POS1))
      UILuaHelper.SetLocalPosition(self.m_btn_upgrade, table.unpack(BTN_UPGRADE_POS1))
      UILuaHelper.SetLocalPosition(self.m_btn_overload, table.unpack(BTN_OVERLOAD_POS1))
    elseif showBtn and not showUpgrade and not showOverLoad then
      UILuaHelper.SetLocalPosition(self.m_btn_change, table.unpack(BTN_CHANGE_POS2))
      UILuaHelper.SetLocalPosition(self.m_btn_takeoff, table.unpack(BTN_TAKEOFF_POS2))
    elseif not showBtn then
      UILuaHelper.SetLocalPosition(self.m_btn_upgrade, table.unpack(BTN_UPGRADE_POS2))
      UILuaHelper.SetLocalPosition(self.m_btn_overload, table.unpack(BTN_OVERLOAD_POS2))
    end
    if self.m_stItemData.config and self.m_stItemData.config.m_Maxlevel then
      self.m_bg_equip_tips:SetActive(self.m_stItemData.config.m_Maxlevel == 1)
    else
      self.m_bg_equip_tips:SetActive(false)
    end
  else
    self.m_pnl_down_item:SetActive(true)
    self.m_pnl_down_equip:SetActive(false)
    self.m_img_line:SetActive(false)
    self.m_z_txt_maxlevel:SetActive(false)
    self.m_btn_overload:SetActive(false)
    self:RefreshGift()
  end
  if (self.m_pnl_des.activeSelf or self.m_pnl_jump.activeSelf) and not self.m_pnl_attributes.activeSelf and not self.m_pnl_camp.activeSelf and not self.m_pnl_gift.activeSelf then
    self:RefreshDesc(true)
  else
    self:RefreshDesc()
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_scroll_content)
  local panelItemList = self.m_scrollview:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.y = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
end

function Form_ItemTips:ShowEquipQuality()
  local quality = self.m_stItemData.quality
  if self.m_equipData.iOverloadHero and self.m_equipData.iOverloadHero > 0 then
    quality = self.m_stItemData.quality + 1
  end
  local qualityCfg = GlobalConfig.QUALITY_EQUIP_SETTING[quality]
  if qualityCfg then
    self.m_txt_t10_quality_Text.text = ConfigManager:GetCommonTextById(qualityCfg.name)
    ResourceUtil:CreateEquipQualityImg(self.m_img_t10_quality_Image, quality, GlobalConfig.EQUIP_QUALITY_STYLE.Line)
  end
end

function Form_ItemTips:RefreshDesc(showAll)
  self.m_pnl_des:SetActive(true)
  if showAll then
    self.m_txt_desc2_Text.text = self.m_stItemData.description
    self.m_img_arrow:SetActive(true)
    self.m_txt_desc:SetActive(false)
    self.m_txt_desc2:SetActive(true)
  else
    self.m_txt_desc_Text.text = self.m_stItemData.description
    self.m_txt_desc:SetActive(true)
    self.m_txt_desc2:SetActive(false)
    self.m_img_arrow:SetActive(false)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_scroll_content)
end

function Form_ItemTips:RefreshGift()
  local vGetItemInfo = {}
  local maxNum = self.m_iNum
  self.m_pnl_down_item:SetActive(true)
  local showMax = false
  if self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestCertain or self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestCustom or self.m_stItemData.sub_type == ItemManager.ItemSubType.IdleCapsule then
    self.m_pnl_gift:SetActive(true)
    vGetItemInfo = utils.changeStringRewardToLuaTable(self.m_stItemData.config.m_ItemUse)
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.FragmentCertain then
    self.m_pnl_gift:SetActive(true)
    vGetItemInfo = utils.changeStringRewardToLuaTable(self.m_stItemData.config.m_ItemUse)
    local iOneCount = tonumber(string.split(self.m_stItemData.config.m_ItemUse, ":")[2])
    if self.m_stItemData.useLimit > 0 and self.m_iNum > self.m_stItemData.useLimit then
      maxNum = math.floor(self.m_stItemData.useLimit / iOneCount)
    else
      maxNum = math.floor(self.m_iNum / iOneCount)
    end
    self.m_iNumCur = maxNum == 0 and maxNum or self.m_iNumCur
    showMax = true
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestRandom then
    self.m_pnl_gift:SetActive(true)
    self.m_btn_possible_detail:SetActive(true)
    local iRandomPoolID = tonumber(self.m_stItemData.config.m_ItemUse)
    local stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(iRandomPoolID)
    if stRandomPoolData:GetError() then
      log.error("get Randompool cfg error itemUseId == " .. tostring(iRandomPoolID))
      return
    end
    vGetItemInfo = utils.changeCSArrayToLuaTable(stRandomPoolData.m_RandompoolContent)
    if ActivityManager:IsInCensorOpen() then
      local temp = utils.changeCSArrayToLuaTable(stRandomPoolData.m_CensorRandompoolContent)
      if 0 < #temp then
        vGetItemInfo = temp or vGetItemInfo
      end
    end
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.FragmentRandom then
    self.m_pnl_gift:SetActive(true)
    self.m_btn_possible_detail:SetActive(true)
    vGetItemInfo = utils.changeStringRewardToLuaTable(self.m_stItemData.config.m_ItemUse)
    local iOneCountTab = string.split(self.m_stItemData.config.m_ItemUse, ":")
    if self.m_stItemData.useLimit > 0 and self.m_iNum > self.m_stItemData.useLimit then
      maxNum = math.floor(self.m_stItemData.useLimit / tonumber(iOneCountTab[2]))
    else
      maxNum = math.floor(self.m_iNum / tonumber(iOneCountTab[2]))
    end
    self.m_iNumCur = maxNum == 0 and maxNum or self.m_iNumCur
    showMax = true
    local iRandomPoolID = tonumber(iOneCountTab[1])
    local stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(iRandomPoolID)
    if stRandomPoolData:GetError() then
      log.error("get Randompool cfg error itemUseId == " .. tostring(iRandomPoolID))
      return
    end
    vGetItemInfo = utils.changeCSArrayToLuaTable(stRandomPoolData.m_RandompoolContent)
    if ActivityManager:IsInCensorOpen() then
      local temp = utils.changeCSArrayToLuaTable(stRandomPoolData.m_CensorRandompoolContent)
      if 0 < #temp then
        vGetItemInfo = temp or vGetItemInfo
      end
    end
  elseif self.m_stItemData.config.m_ItemType == MTTDProto.ItemType_StoreExchange then
    maxNum = 1
    self.m_iNumCur = 1
    showMax = true
  else
    self.m_pnl_use:SetActive(false)
    self.m_pnl_use_btn:SetActive(false)
    self.m_img_line:SetActive(false)
    return
  end
  if self.m_bBag then
    if self.m_stItemData.sub_type ~= ItemManager.ItemSubType.ChestCustom then
      self.m_pnl_use:SetActive(self.m_stItemData.canUse == 1)
      self.m_widgetNumStepper:SetNumShowMax(showMax)
      self.m_widgetNumStepper:SetNumMax(maxNum)
      self.m_widgetNumStepper:SetNumCur(self.m_iNumCur)
      self.m_widgetNumStepper:SetNumChangeCB(handler(self, self.OnNumStepperChange))
    else
      self.m_pnl_use:SetActive(false)
    end
    self.m_pnl_use_btn:SetActive(self.m_stItemData.canUse == 1)
    self.m_img_line:SetActive(true)
  else
    self.m_pnl_down_item:SetActive(false)
    self.m_img_line:SetActive(false)
  end
  local vNum = math.floor(#vGetItemInfo / 6) + (#vGetItemInfo % 6 == 0 and 0 or 1)
  local hNum = #vGetItemInfo % 6
  for i = 1, vNum do
    local iIndex = i
    self.m_updateQueueItemBig:addWait(function()
      local goGiftPanelItem = self.m_vGiftPanelItem[iIndex]
      if goGiftPanelItem == nil then
        goGiftPanelItem = {}
        goGiftPanelItem.go = CS.UnityEngine.GameObject.Instantiate(self.m_pnl_reward, self.m_pnl_gift.transform)
        self.m_vGiftPanelItem[iIndex] = goGiftPanelItem
        self.m_hRewardPanelItem[iIndex] = {}
      end
      for m = 1, 6 do
        local goRewardItem = self.m_hRewardPanelItem[iIndex][m]
        if goRewardItem == nil then
          goRewardItem = {}
          local itemObj = self.m_vGiftPanelItem[iIndex].go.transform:Find("c_common_item").gameObject
          goRewardItem.go = CS.UnityEngine.GameObject.Instantiate(itemObj, self.m_vGiftPanelItem[iIndex].go.transform)
          goRewardItem.widgetItemIcon = self:createCommonItem(goRewardItem.go)
          self.m_hRewardPanelItem[iIndex][m] = goRewardItem
        end
        if iIndex == vNum and m > hNum and hNum ~= 0 then
          goRewardItem.go:SetActive(false)
        else
          goRewardItem.go:SetActive(true)
          local index = (iIndex - 1) * 6 + m
          local vItemInfoStr = vGetItemInfo[index]
          local iGetItemID = tonumber(vItemInfoStr[1])
          local iGetItemNum = tonumber(vItemInfoStr[2] or 0)
          if self.m_stItemData.sub_type == ItemManager.ItemSubType.IdleCapsule then
            iGetItemNum = HangUpManager:GetItemProductionByIdAndSeconds(iGetItemID, iGetItemNum)
            local selNum = self.m_widgetNumStepper:GetCurNum()
            iGetItemNum = iGetItemNum * tonumber(selNum)
          end
          local processData = ResourceUtil:GetProcessRewardData({iID = iGetItemID, iNum = iGetItemNum})
          goRewardItem.widgetItemIcon:SetItemIconClickCB(function(itemID, itemNum, itemCom)
            self:OnRewardItemClick(itemID, itemNum, itemCom)
          end)
          if processData then
            goRewardItem.widgetItemIcon:SetItemInfo(processData)
          end
        end
      end
      goGiftPanelItem.go:SetActive(true)
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_gift)
      return true
    end)
  end
  for i = vNum + 1, #self.m_vGiftPanelItem do
    self.m_vGiftPanelItem[i].go:SetActive(false)
    for m = hNum + 1, #self.m_hRewardPanelItem[i] do
      self.m_hRewardPanelItem[i][m].go:SetActive(false)
    end
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_gift)
end

function Form_ItemTips:OnNumStepperChange(iNumCur, iNumChange, sTag)
  self.m_iNumCur = iNumCur
  self:RefreshRightUI()
end

function Form_ItemTips:RefreshJump()
  local jumpList = utils.changeCSArrayToLuaTable(self.m_stItemData.config.m_SystemWarp)
  local isOpen = UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.GuideDefeatJump)
  if not (isOpen and jumpList) or #jumpList == 0 then
    self.m_pnl_jump:SetActive(false)
    return
  end
  self.m_pnl_jump:SetActive(true)
  local goJumpPanelItemTemplate = self.m_pnl_jump.transform:Find("pnl_item").gameObject
  local vGetItemInfo = jumpList
  for i = 1, #vGetItemInfo do
    local goJumpPanelItem = self.m_vJumpPanelItem[i]
    if goJumpPanelItem == nil then
      goJumpPanelItem = {}
      goJumpPanelItem.go = CS.UnityEngine.GameObject.Instantiate(goJumpPanelItemTemplate, self.m_pnl_jump.transform)
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
        StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ITEMTIPS)
        self:broadcastEvent("eGameEvent_Item_Jump")
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
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
          end
        end)
      elseif BattleFlowManager:IsInBattle() == true then
        m_btn_jump_obj:SetActive(false)
        m_btn_lock_obj:SetActive(false)
      else
        m_btn_jump_obj:SetActive(true)
        m_btn_lock_obj:SetActive(false)
      end
    end
  end
  for i = #vGetItemInfo + 1, #self.m_vJumpPanelItem do
    self.m_vJumpPanelItem[i].go:SetActive(false)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_jump)
end

function Form_ItemTips:OnPnlusebtnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  if self.m_stItemData.sub_type == ItemManager.ItemType.IdleCapsule then
    local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AFK)
    if not openFlag then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id or 10247)
      return
    end
  end
  if self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestCertain or self.m_stItemData.sub_type == ItemManager.ItemSubType.IdleCapsule then
    ItemManager:RequestItemUse(self.m_iID, self.m_widgetNumStepper:GetNumCur())
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.ChestCustom then
    StackPopup:Push(UIDefines.ID_FORM_OPTIONALGIFT, {
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
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
    end
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.FragmentRandom then
    local iNum = self.m_widgetNumStepper:GetNumCur()
    if 0 < iNum then
      local iOneCount = tonumber(string.split(self.m_stItemData.config.m_ItemUse, ":")[2])
      iNum = iNum * iOneCount
      ItemManager:RequestItemUse(self.m_iID, iNum)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
    end
  elseif self.m_stItemData.sub_type == ItemManager.ItemSubType.FragmentDeduplicatedRandom then
    local iNum = self.m_widgetNumStepper:GetNumCur()
    if 0 < iNum then
      local iOneCount = tonumber(self.m_stItemData.config.m_ItemUse)
      iNum = iNum * iOneCount
      ItemManager:RequestItemUse(self.m_iID, iNum)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
    end
  elseif self.m_stItemData.config.m_ItemType == MTTDProto.ItemType_StoreExchange then
    if self.m_stItemData.config.m_ItemSubType == MTTDProto.ItemSubType_SmallMonthCard then
      if MonthlyCardManager:CheckCanBuyCard(true) then
        ItemManager:RequestItemUse(self.m_iID, 1)
      else
        utils.popUpDirectionsUI({
          tipsID = 1024,
          func1 = function()
            self:OnBtnCloseClicked()
          end
        })
      end
    elseif self.m_stItemData.config.m_ItemSubType == MTTDProto.ItemSubType_BigMonthCard then
      if MonthlyCardManager:CheckCanBuyCard(false) then
        ItemManager:RequestItemUse(self.m_iID, 1)
      else
        utils.popUpDirectionsUI({
          tipsID = 1025,
          func1 = function()
            self:OnBtnCloseClicked()
          end
        })
      end
    elseif self.m_stItemData.config.m_ItemSubType == MTTDProto.ItemSubType_BattlePass then
      local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_BattlePass)
      local act
      local openFlagBP = false
      for _, v in ipairs(act_list) do
        if v:checkCondition() and v:isInActivityShowTime() and v:GetItemBaseId() == self.m_iID then
          openFlagBP = true
          act = v
          break
        end
      end
      if not openFlagBP then
        utils.popUpDirectionsUI({
          tipsID = 1027,
          func1 = function()
            self:OnBtnCloseClicked()
          end
        })
      elseif act then
        local isIsAdvanced = act:IsHaveBuy()
        if not isIsAdvanced then
          ItemManager:RequestItemUse(self.m_iID, 1)
        else
          utils.popUpDirectionsUI({
            tipsID = 1026,
            func1 = function()
              self:OnBtnCloseClicked()
            end
          })
        end
      end
    end
  end
end

function Form_ItemTips:OnBtnpossibledetailClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  local iRandomPoolID
  if self.m_stItemData.sub_type == ItemManager.ItemSubType.FragmentRandom then
    local iOneCountTab = string.split(self.m_stItemData.config.m_ItemUse, ":")
    iRandomPoolID = tonumber(iOneCountTab[1])
  else
    iRandomPoolID = tonumber(self.m_stItemData.config.m_ItemUse)
  end
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

function Form_ItemTips:OnBtnprobabilitydetailClicked()
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

function Form_ItemTips:OnEventItemUse(stItemUseInfo)
  local iID = stItemUseInfo.iID
  if self.m_iID == iID then
    local ItemUseSC = stItemUseInfo.ItemUseSC
    if ItemUseSC.vItem and next(ItemUseSC.vItem) then
      utils.popUpRewardUI(ItemUseSC.vItem, function()
      end, ItemUseSC.mChangeReward)
    end
    StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ITEMTIPS)
  end
end

function Form_ItemTips:RefreshEquipAttrs()
  self.m_pnl_attributes:SetActive(true)
  local flag = EquipManager:CheckIsShowCampAttAddExt(self.m_equipData.iEquipUid)
  local attrInfoList = EquipManager:GetEquipBaseAttr(self.m_stItemData.data_id, self.m_iEquipLv, flag)
  for i = 1, 2 do
    local attrInfo = attrInfoList[i]
    if attrInfo and attrInfo.cfg then
      ResourceUtil:CreatePropertyImg(self["m_icon_attributes0" .. i .. "_Image"], attrInfo.id)
      local attrCfg = attrInfo.cfg
      self["m_txt_attributes0" .. i .. "_Text"].text = tostring(attrCfg.m_mCNName)
      self["m_txt_num_before0" .. i .. "_Text"].text = tostring(attrInfo.num)
    end
  end
end

function Form_ItemTips:RefreshEquipCampInfo()
  local cfg = EquipManager:GetEquipCfgByBaseId(self.m_stItemData.data_id)
  if cfg.m_BonusCamp > 0 then
    self.m_pnl_camp:SetActive(true)
    local camp = cfg.m_BonusCamp
    local stItemData = CampCfgIns:GetValue_ByCampID(camp)
    if stItemData:GetError() then
      log.error("ResourceUtil createCampImg camp  " .. tostring(camp))
      return
    end
    if not stItemData.m_CampIcon then
      return
    end
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_icon_equip_camp_Image, stItemData.m_CampIcon .. "_big", nil, nil, true)
    self.m_txt_camp_name_Text.text = stItemData.m_mCampName
    self.m_txt_camp_des_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20108), stItemData.m_mCampName)
    if self.m_equipData.iHeroId and self.m_equipData.iHeroId ~= 0 then
      local heroCfg = HeroManager:GetHeroConfigByID(self.m_equipData.iHeroId)
      if camp == heroCfg.m_Camp then
        self.m_icon_equip_camp_Image.material = nil
      else
        self.m_icon_equip_camp_Image.material = self.m_grayImgMaterial
      end
    else
      self.m_icon_equip_camp_Image.material = self.m_grayImgMaterial
    end
  else
    self.m_pnl_camp:SetActive(false)
  end
end

function Form_ItemTips:OnEventUnInstallEquip()
  self:OnBtnCloseClicked()
end

function Form_ItemTips:OnBtntakeoffClicked()
  if self.m_equipData.iHeroId ~= 0 and self.m_selPos ~= 0 then
    EquipManager:ReqUnInstallEquip(self.m_equipData.iHeroId, self.m_selPos)
  end
end

function Form_ItemTips:OnBtnchangeClicked()
  self:OnBtnCloseClicked()
  self:broadcastEvent("eGameEvent_Equip_ChangeEquip", self.m_selPos)
end

function Form_ItemTips:OnBtnupgradeClicked()
  StackPopup:Push(UIDefines.ID_FORM_EQUIPMENTUPGRADE, {
    equipData = self.m_equipData,
    pos = self.m_selPos
  })
end

function Form_ItemTips:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ITEMTIPS)
  if self.m_closeCallBackFun then
    self.m_closeCallBackFun()
  end
end

function Form_ItemTips:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_ItemTips:OnTxtdescClicked()
  self:RefreshDesc(true)
end

function Form_ItemTips:OnBtnarrowClicked()
  self:RefreshDesc(true)
end

function Form_ItemTips:OnTxtdesc2Clicked()
  self:RefreshDesc(false)
end

function Form_ItemTips:OnImgarrowClicked()
  self:RefreshDesc(false)
end

function Form_ItemTips:DestroyObj()
  if self.m_vJumpPanelItem then
    for i = #self.m_vJumpPanelItem, 1, -1 do
      if not UILuaHelper.IsNull(self.m_vJumpPanelItem[i].go) then
        GameObject.Destroy(self.m_vJumpPanelItem[i].go)
        self.m_vJumpPanelItem[i] = nil
      end
    end
  end
  if self.m_vGiftPanelItem then
    for i = #self.m_vGiftPanelItem, 1, -1 do
      if not UILuaHelper.IsNull(self.m_vGiftPanelItem[i].go) then
        GameObject.Destroy(self.m_vGiftPanelItem[i].go)
        self.m_vGiftPanelItem[i] = nil
      end
    end
  end
  self.m_vJumpPanelItem = nil
  self.m_vGiftPanelItem = nil
  self.m_hRewardPanelItem = nil
end

function Form_ItemTips:OnDestroy()
  self.super.OnDestroy(self)
  self:DestroyObj()
end

function Form_ItemTips:FreshGMBtn()
  local curValue = LocalDataManager:GetIntSimple("PREF_STR_ITEM999TOOL_OPEN", 0)
  UILuaHelper.SetActive(self.m_btn_gm, curValue == 1)
end

function Form_ItemTips:OnBtngmClicked()
  local loginContext = CS.LoginContext.GetContext()
  Util.RequestGM(loginContext.CurZoneInfo.iZoneId, "add_item " .. loginContext.AccountID .. " " .. self.m_iID .. " 999")
end

function Form_ItemTips:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ITEMTIPS)
  local curID = self.m_iID
  local curNum = self.m_iNum
  local inBag = self.m_bBag
  
  local function callBackFun()
    utils.openItemDetailPop({iID = curID, iNum = curNum}, nil, inBag)
  end
  
  utils.openItemDetailPop({iID = itemID, iNum = itemNum}, callBackFun)
end

function Form_ItemTips:OnBtnoverloadClicked()
  StackPopup:Push(UIDefines.ID_FORM_EQUIPT10OVERLOAD, self.m_equipData)
end

function Form_ItemTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ItemTips", Form_ItemTips)
return Form_ItemTips
