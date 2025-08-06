local Form_ItemTipsT10 = class("Form_ItemTipsT10", require("UI/UIFrames/Form_ItemTipsT10UI"))
local BTN_CHANGE1_POS1 = {
  31,
  -324,
  0
}
local BTN_CHANGE1_POS2 = {
  -240,
  -324,
  0
}
local BTN_CHANGE2_POS1 = {
  400,
  -324,
  0
}
local BTN_CHANGE2_POS2 = {
  240,
  -324,
  0
}

function Form_ItemTipsT10:SetInitParam(param)
end

function Form_ItemTipsT10:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetItemIcon = self:createCommonItem(self.m_common_item)
end

function Form_ItemTipsT10:OnActive()
  self.super.OnActive(self)
  self:DestroyItem()
  self:AddEventListeners()
  self.m_equipData = self.m_csui.m_param.equipData
  self.m_stItemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_equipData.iBaseId,
    iNum = 0
  }, self.m_equipData)
  self:RefreshUI()
end

function Form_ItemTipsT10:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:DestroyItem()
end

function Form_ItemTipsT10:AddEventListeners()
  self:addEventListener("eGameEvent_SetEffectLock", handler(self, self.OnEventSetEffectLock))
  self:addEventListener("eGameEvent_SaveReOverload", handler(self, self.OnEventSaveReOverload))
  self:addEventListener("eGameEvent_Equip_AddExp", handler(self, self.OnEquipLevelUp))
end

function Form_ItemTipsT10:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_ItemTipsT10:OnEquipLevelUp(param)
  self.m_equipData.iLevel = param.iLevel
  self.m_stItemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_equipData.iBaseId,
    iNum = 0
  }, self.m_equipData)
  self:RefreshLeftUI()
end

function Form_ItemTipsT10:DestroyItem()
  if self.m_overLoadItemList and table.getn(self.m_overLoadItemList) > 0 then
    for i = 3, 1, -1 do
      for m = 20, 1, -1 do
        if self.m_overLoadItemList[i] and self.m_overLoadItemList[i][m] then
          CS.UnityEngine.GameObject.Destroy(self.m_overLoadItemList[i][m])
          self.m_overLoadItemList[i][m] = nil
        end
      end
    end
  end
  self.m_overLoadItemList = {}
end

function Form_ItemTipsT10:RefreshUI()
  self:RefreshLeftUI()
  self:RefreshDesc()
  self:RefreshOverLoadExAttr()
  self:RefreshLockIcon()
end

function Form_ItemTipsT10:RefreshLeftUI()
  self.m_widgetItemIcon:SetItemInfo(self.m_stItemData)
  local overLoadAttrInfoList = EquipManager:GetEquipOverLoadBaseAttr(self.m_equipData.iBaseId, self.m_equipData.iLevel)
  for i = 1, 2 do
    local overLoadInfo = overLoadAttrInfoList[i]
    if overLoadInfo and overLoadInfo.cfg then
      ResourceUtil:CreatePropertyImg(self["m_icon_attributes0" .. i .. "_Image"], overLoadInfo.id)
      local attrCfg = overLoadInfo.cfg
      self["m_txt_attributes0" .. i .. "_Text"].text = tostring(attrCfg.m_mCNName)
      self["m_txt_num_before0" .. i .. "_Text"].text = tostring(overLoadInfo.num)
    end
  end
  self.m_txt_name_Text.text = self.m_stItemData.name
  local canLvUpFlag = EquipManager:CheckEquipCanLvUp(self.m_equipData.iEquipUid)
  self.m_btn_upgrade:SetActive(canLvUpFlag)
  if canLvUpFlag then
    UILuaHelper.SetLocalPosition(self.m_btn_change1, table.unpack(BTN_CHANGE1_POS1))
    UILuaHelper.SetLocalPosition(self.m_btn_change2, table.unpack(BTN_CHANGE2_POS1))
  else
    UILuaHelper.SetLocalPosition(self.m_btn_change1, table.unpack(BTN_CHANGE1_POS2))
    UILuaHelper.SetLocalPosition(self.m_btn_change2, table.unpack(BTN_CHANGE2_POS2))
  end
  local quality = self.m_stItemData.quality
  if self.m_equipData.iOverloadHero and self.m_equipData.iOverloadHero > 0 then
    quality = self.m_stItemData.quality + 1
  end
  local qualityCfg = GlobalConfig.QUALITY_EQUIP_SETTING[quality]
  if qualityCfg then
    self.m_txt_t10_quality_Text.text = ConfigManager:GetCommonTextById(qualityCfg.name)
    ResourceUtil:CreateEquipQualityImg(self.m_img_t10_quality_Image, quality, GlobalConfig.EQUIP_QUALITY_STYLE.Line)
  end
  self.m_z_txt_maxlevel:SetActive(not canLvUpFlag)
end

function Form_ItemTipsT10:RefreshDesc(showAll)
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

function Form_ItemTipsT10:RefreshOverLoadExAttr()
  local overloadEffect = self.m_equipData.mOverloadEffect
  for i = 1, 3 do
    if overloadEffect[i] then
      local effectCfg = EquipManager:GetEquipEffectCfgByIdLv(overloadEffect[i].iGroupId, overloadEffect[i].iEffectLevel)
      local highQuality = effectCfg.m_HighQuality
      self["m_bg_special" .. i]:SetActive(highQuality == 1)
      self["m_txt_item_rank" .. i .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(20033), tostring(overloadEffect[i].iEffectLevel))
      local cfgList = EquipManager:GetEquipEffectCfgByGroupId(overloadEffect[i].iGroupId)
      if self.m_overLoadItemList[i] then
        for _, obj in pairs(self.m_overLoadItemList[i]) do
          UILuaHelper.SetActive(obj, false)
        end
      end
      for m = 1, cfgList.Count do
        self["m_item_red" .. i]:SetActive(false)
        if not self.m_overLoadItemList[i] then
          self.m_overLoadItemList[i] = {}
        end
        if not self.m_overLoadItemList[i][m] then
          local cloneObj = self:CreateOverLoadItem(self["m_item_red" .. i], self["m_img_list_schedule" .. i].transform)
          self.m_overLoadItemList[i][m] = cloneObj
        end
        local showRed = m <= overloadEffect[i].iEffectLevel
        self:ShowOverLoadAttrLevel(self.m_overLoadItemList[i][m], showRed)
      end
      self["m_txt_item_name" .. i .. "_Text"].text = tostring(effectCfg.m_mDesc)
      self["m_txt_item_num" .. i .. "_Text"].text = tostring(effectCfg.m_Data)
      self["m_attr_item" .. i]:SetActive(true)
      self["m_img_empty" .. i]:SetActive(false)
      self["m_icon_lock" .. i]:SetActive(overloadEffect[i].bLock)
    else
      self["m_attr_item" .. i]:SetActive(false)
      self["m_img_empty" .. i]:SetActive(true)
    end
  end
end

function Form_ItemTipsT10:RefreshLockIcon(iEquipUid)
  if iEquipUid then
    self.m_equipData = EquipManager:GetEquipDataByID(iEquipUid)
  end
  if self.m_equipData and self.m_equipData.mOverloadEffect and table.getn(self.m_equipData.mOverloadEffect) > 0 then
    local effectData = self.m_equipData.mOverloadEffect
    for i = 1, 3 do
      if effectData[i] then
        self["m_icon_lock" .. i]:SetActive(effectData[i].bLock)
        self["m_icon_lock_un" .. i]:SetActive(not effectData[i].bLock)
      end
    end
  end
end

function Form_ItemTipsT10:CreateOverLoadItem(item_base_obj, parentTransform)
  local cloneObj = GameObject.Instantiate(item_base_obj, parentTransform).gameObject
  UILuaHelper.SetActive(cloneObj, true)
  return cloneObj
end

function Form_ItemTipsT10:ShowOverLoadAttrLevel(cloneObj, showRed)
  local rootTrans = cloneObj.transform
  local normalNode = rootTrans:Find("bg_red")
  local chooseNode = rootTrans:Find("bg_gray")
  normalNode.gameObject:SetActive(showRed)
  chooseNode.gameObject:SetActive(not showRed)
  UILuaHelper.SetActive(cloneObj, true)
end

function Form_ItemTipsT10:OnEventSetEffectLock(stData)
  if stData.bLock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20037)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20038)
  end
  self:RefreshLockIcon(stData.iEquipUid)
end

function Form_ItemTipsT10:OnEventSaveReOverload(param)
  if not param then
    return
  end
  local tempEquipData = EquipManager:GetEquipDataByID(param.iEquipUid)
  if not tempEquipData then
    return
  end
  self.m_equipData = tempEquipData
  self:RefreshUI()
end

function Form_ItemTipsT10:OnBtnupgradeClicked()
  StackPopup:Push(UIDefines.ID_FORM_EQUIPMENTUPGRADE, {
    equipData = self.m_equipData
  })
end

function Form_ItemTipsT10:OnTxtdescClicked()
  self:RefreshDesc(true)
end

function Form_ItemTipsT10:OnBtnarrowClicked()
  self:RefreshDesc(true)
end

function Form_ItemTipsT10:OnTxtdesc2Clicked()
  self:RefreshDesc(false)
end

function Form_ItemTipsT10:OnImgarrowClicked()
  self:RefreshDesc(false)
end

function Form_ItemTipsT10:OnBtnchange1Clicked()
  StackPopup:Push(UIDefines.ID_FORM_EQUIPT10POPCHANGE, {
    equipData = self.m_equipData,
    openType = 1
  })
end

function Form_ItemTipsT10:OnBtnchange2Clicked()
  StackPopup:Push(UIDefines.ID_FORM_EQUIPT10POPCHANGE, {
    equipData = self.m_equipData,
    openType = 2
  })
end

function Form_ItemTipsT10:OnBtnlock1Clicked()
  self:LockOverLoadAttrItem(1)
end

function Form_ItemTipsT10:OnBtnlock2Clicked()
  self:LockOverLoadAttrItem(2)
end

function Form_ItemTipsT10:OnBtnlock3Clicked()
  self:LockOverLoadAttrItem(3)
end

function Form_ItemTipsT10:LockOverLoadAttrItem(iSlot)
  local equipData = self.m_equipData
  local bLock, effectData = EquipManager:CheckEquipEffectIsLockBySlot(equipData.iEquipUid, iSlot, equipData)
  if bLock ~= nil then
    if bLock == false then
      local _, lockCost, _ = EquipManager:GetEquipEffectLockOrReOverLoadCost(equipData.iEquipUid, equipData)
      local effectCfg = EquipManager:GetEquipEffectCfgByIdLv(effectData.iGroupId, effectData.iEffectLevel)
      utils.ShowCommonTipCost({
        confirmCommonTipsID = 1702,
        beforeItemID = lockCost[0],
        beforeItemNum = lockCost[1],
        formatFun = function(sContent)
          local effectLevel = string.format(ConfigManager:GetCommonTextById(20033), tostring(effectData.iEffectLevel))
          return string.gsubnumberreplace(sContent, effectLevel, effectCfg.m_mDesc, effectCfg.m_Data)
        end,
        funSure = function()
          local userNum = ItemManager:GetItemNum(lockCost[0], true)
          if userNum < lockCost[1] then
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
            return
          end
          EquipManager:OnReqEquipSetEffectLock(equipData.iEquipUid, iSlot, not bLock)
        end
      })
    else
      utils.popUpDirectionsUI({
        tipsID = 1701,
        func1 = function()
          EquipManager:OnReqEquipSetEffectLock(equipData.iEquipUid, iSlot, not bLock)
        end
      })
    end
  else
    log.error("OnReqEquipSetEffectLock is error")
  end
end

function Form_ItemTipsT10:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_ItemTipsT10:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_ItemTipsT10:IsOpenGuassianBlur()
  return true
end

function Form_ItemTipsT10:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_ItemTipsT10", Form_ItemTipsT10)
return Form_ItemTipsT10
