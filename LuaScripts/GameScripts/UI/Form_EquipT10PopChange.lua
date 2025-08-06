local Form_EquipT10PopChange = class("Form_EquipT10PopChange", require("UI/UIFrames/Form_EquipT10PopChangeUI"))
local SHOW_ATTR_TIPS_NUM = 3
local ATTR_MAX_LEVEL = 20
local FreshAnimStr = "EquipT10PopChange_refresh"

function Form_EquipT10PopChange:SetInitParam(param)
end

function Form_EquipT10PopChange:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetItemIcon = self:createCommonItem(self.m_common_item)
end

function Form_EquipT10PopChange:OnActive()
  self.super.OnActive(self)
  self:DestroyItem()
  self:AddEventListeners()
  self.m_equipData = self.m_csui.m_param.equipData
  self.m_openType = self.m_csui.m_param.openType
  self.m_stItemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_equipData.iBaseId,
    iNum = 0
  }, self.m_equipData)
  self.m_overLoadNewItemList = {}
  self:RefreshUI()
end

function Form_EquipT10PopChange:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:DestroyItem()
end

function Form_EquipT10PopChange:AddEventListeners()
  self:addEventListener("eGameEvent_SetEffectLock", handler(self, self.OnEventSetEffectLock))
  self:addEventListener("eGameEvent_ReOverload", handler(self, self.OnEventReOverload))
end

function Form_EquipT10PopChange:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipT10PopChange:RefreshUI()
  self:RefreshLeftUI()
  self:RefreshOverLoadExAttr()
  self:RefreshLockIcon()
end

function Form_EquipT10PopChange:RefreshOverLoadExAttr()
  local overloadEffect = self.m_equipData.mOverloadEffect
  for i = 1, SHOW_ATTR_TIPS_NUM do
    local tempItemNew = self["m_attr_item" .. i .. "_new"]
    UILuaHelper.SetActive(tempItemNew, false)
    local itemParentTrans = tempItemNew.transform.parent
    local animStr = FreshAnimStr
    if 1 < i then
      animStr = FreshAnimStr .. i
    end
    UILuaHelper.ResetAnimationByName(itemParentTrans, animStr)
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

function Form_EquipT10PopChange:RefreshLeftUI()
  self.m_widgetItemIcon:SetItemInfo(self.m_stItemData)
  local title = ""
  local content = ""
  local btnText = ""
  if self.m_openType == 1 then
    title = ConfigManager:GetCommonTextById(20086)
    content = ConfigManager:GetCommonTextById(20087)
    btnText = ConfigManager:GetCommonTextById(20101)
  else
    title = ConfigManager:GetCommonTextById(20084)
    content = ConfigManager:GetCommonTextById(20085)
    btnText = ConfigManager:GetCommonTextById(20102)
  end
  self.m_txt_name_Text.text = title
  self.m_z_txt_tips_Text.text = content
  self.m_txt_yes_Text.text = btnText
  self:RefreshCostUI()
end

function Form_EquipT10PopChange:RefreshCostUI()
  local _, _, reOverloadCost = EquipManager:GetEquipEffectLockOrReOverLoadCost(self.m_equipData.iEquipUid, self.m_equipData)
  local costId = reOverloadCost[0]
  local costNum = reOverloadCost[1]
  ResourceUtil:CreatIconById(self.m_cost_icon_Image, costId)
  local userNum = ItemManager:GetItemNum(costId, true)
  self.m_txt_cost_num_Text.text = string.format(ConfigManager:GetCommonTextById(20048), userNum, costNum)
  if costNum > userNum then
    UILuaHelper.SetColor(self.m_txt_cost_num_Text, table.unpack(GlobalConfig.COMMON_COLOR.Red))
  else
    UILuaHelper.SetColor(self.m_txt_cost_num_Text, 247, 241, 222, 1)
  end
end

function Form_EquipT10PopChange:RefreshLockIcon(iEquipUid)
  if iEquipUid then
    self.m_equipData = EquipManager:GetEquipDataByID(iEquipUid)
  end
  if self.m_equipData and self.m_equipData.mOverloadEffect and table.getn(self.m_equipData.mOverloadEffect) > 0 then
    local effectData = self.m_equipData.mOverloadEffect
    for i = 1, SHOW_ATTR_TIPS_NUM do
      if effectData[i] then
        self["m_icon_lock" .. i]:SetActive(effectData[i].bLock)
        self["m_icon_lock_un" .. i]:SetActive(not effectData[i].bLock)
      end
    end
  end
end

function Form_EquipT10PopChange:CreateOverLoadItem(item_base_obj, parentTransform)
  local cloneObj = GameObject.Instantiate(item_base_obj, parentTransform).gameObject
  UILuaHelper.SetActive(cloneObj, true)
  return cloneObj
end

function Form_EquipT10PopChange:ShowOverLoadAttrLevel(cloneObj, showRed)
  local rootTrans = cloneObj.transform
  local normalNode = rootTrans:Find("bg_red")
  local chooseNode = rootTrans:Find("bg_gray")
  normalNode.gameObject:SetActive(showRed)
  chooseNode.gameObject:SetActive(not showRed)
  UILuaHelper.SetActive(cloneObj, true)
end

function Form_EquipT10PopChange:ShowNewAttrEffectListAndAnim(changeEffectMap, backFun)
  if not changeEffectMap then
    return
  end
  local animLen
  for i = 1, SHOW_ATTR_TIPS_NUM do
    local changeEffectData = changeEffectMap[i]
    if changeEffectData then
      local tempChangeEffect = changeEffectData.equipEffectData
      UILuaHelper.SetActive(self["m_attr_item" .. i .. "_new"], tempChangeEffect ~= nil)
      UILuaHelper.SetActive(self["m_img_empty" .. i], tempChangeEffect == nil)
      if tempChangeEffect then
        local effectCfg = EquipManager:GetEquipEffectCfgByIdLv(tempChangeEffect.iGroupId, tempChangeEffect.iEffectLevel)
        local highQuality = effectCfg.m_HighQuality
        self["m_bg_special" .. i .. "_new"]:SetActive(highQuality == 1)
        self["m_txt_item_rank" .. i .. "_new_Text"].text = string.format(ConfigManager:GetCommonTextById(20033), tostring(tempChangeEffect.iEffectLevel))
        local cfgList = EquipManager:GetEquipEffectCfgByGroupId(tempChangeEffect.iGroupId)
        if self.m_overLoadNewItemList[i] then
          for _, obj in pairs(self.m_overLoadNewItemList[i]) do
            UILuaHelper.SetActive(obj, false)
          end
        end
        for m = 1, cfgList.Count do
          self["m_item_red" .. i .. "_new"]:SetActive(false)
          if not self.m_overLoadNewItemList[i] then
            self.m_overLoadNewItemList[i] = {}
          end
          if not self.m_overLoadNewItemList[i][m] then
            local cloneObj = self:CreateOverLoadItem(self["m_item_red" .. i .. "_new"], self["m_img_list_schedule" .. i .. "_new"].transform)
            self.m_overLoadNewItemList[i][m] = cloneObj
          end
          local showRed = m <= tempChangeEffect.iEffectLevel
          self:ShowOverLoadAttrLevel(self.m_overLoadNewItemList[i][m], showRed)
        end
        self["m_txt_item_name" .. i .. "_new_Text"].text = tostring(effectCfg.m_mDesc)
        self["m_txt_item_num" .. i .. "_new_Text"].text = tostring(effectCfg.m_Data)
        self["m_attr_item" .. i .. "_new"]:SetActive(true)
        self["m_icon_lock" .. i .. "_new"]:SetActive(tempChangeEffect.bLock)
        self["m_icon_lock_un" .. i .. "_new"]:SetActive(not tempChangeEffect.bLock)
      end
      local parentTransform = self["m_attr_item" .. i .. "_new"].transform.parent
      local animStr = FreshAnimStr
      if 1 < i then
        animStr = animStr .. i
      end
      if animLen == nil then
        animLen = UILuaHelper.GetAnimationLengthByName(parentTransform, animStr)
      end
      UILuaHelper.PlayAnimationByName(parentTransform, animStr)
    end
  end
  if animLen then
    if self.m_animFreshTimer ~= nil then
      TimeService:KillTimer(self.m_animFreshTimer)
      self.m_animFreshTimer = nil
    end
    self.m_animFreshTimer = TimeService:SetTimer(animLen, 1, function()
      self.m_animFreshTimer = nil
      if backFun then
        backFun()
      end
    end)
  elseif backFun then
    backFun()
  end
end

function Form_EquipT10PopChange:OnEventSetEffectLock(stData)
  if stData.bLock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20037)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20038)
  end
  self:RefreshLockIcon(stData.iEquipUid)
  self:RefreshCostUI()
end

function Form_EquipT10PopChange:OnEventReOverload(iEquipUid)
  local equipData = EquipManager:GetEquipDataByID(iEquipUid)
  StackPopup:Push(UIDefines.ID_FORM_EQUIPT10OVERLOADRANDOMWORD, {
    equipData = equipData,
    openType = self.m_openType,
    replaceBackFun = function(isSave, iEquipUID, changeEffectList)
      self:OnRandomReplaceBack(isSave, iEquipUID, changeEffectList)
    end
  })
end

function Form_EquipT10PopChange:OnRandomReplaceBack(isSave, iEquipUID, changeEffectList)
  if not self.m_equipData then
    return
  end
  if not iEquipUID then
    return
  end
  if not next(changeEffectList) then
    return
  end
  if iEquipUID ~= self.m_equipData.iEquipUid then
    return
  end
  
  local function freshUIFun()
    local tempEquipData = EquipManager:GetEquipDataByID(iEquipUID)
    if tempEquipData then
      self.m_equipData = tempEquipData
      self:RefreshUI()
    end
  end
  
  local isFreshUINow = false
  if isSave then
    if changeEffectList then
      self:ShowNewAttrEffectListAndAnim(changeEffectList, freshUIFun)
    else
      isFreshUINow = true
    end
  else
    isFreshUINow = true
  end
  if isFreshUINow then
    freshUIFun()
  end
end

function Form_EquipT10PopChange:DestroyItem()
  if self.m_overLoadItemList and table.getn(self.m_overLoadItemList) > 0 then
    for i = SHOW_ATTR_TIPS_NUM, 1, -1 do
      for m = ATTR_MAX_LEVEL, 1, -1 do
        if self.m_overLoadItemList[i] and self.m_overLoadItemList[i][m] then
          CS.UnityEngine.GameObject.Destroy(self.m_overLoadItemList[i][m])
          self.m_overLoadItemList[i][m] = nil
        end
      end
    end
  end
  self.m_overLoadItemList = {}
  if self.m_overLoadNewItemList and 0 < table.getn(self.m_overLoadNewItemList) then
    for i = SHOW_ATTR_TIPS_NUM, 1, -1 do
      for m = ATTR_MAX_LEVEL, 1, -1 do
        if self.m_overLoadNewItemList[i] and self.m_overLoadNewItemList[i][m] then
          CS.UnityEngine.GameObject.Destroy(self.m_overLoadNewItemList[i][m])
          self.m_overLoadNewItemList[i][m] = nil
        end
      end
    end
  end
  self.m_overLoadNewItemList = {}
end

function Form_EquipT10PopChange:OnBtnlock1Clicked()
  self:LockOverLoadAttrItem(1)
end

function Form_EquipT10PopChange:OnBtnlock2Clicked()
  self:LockOverLoadAttrItem(2)
end

function Form_EquipT10PopChange:OnBtnlock3Clicked()
  self:LockOverLoadAttrItem(3)
end

function Form_EquipT10PopChange:LockOverLoadAttrItem(iSlot)
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

function Form_EquipT10PopChange:OnBtnyesClicked()
  if self.m_openType == 1 then
    EquipManager:OnReqEquipReOverload(self.m_equipData.iEquipUid, false)
  else
    EquipManager:OnReqEquipReOverload(self.m_equipData.iEquipUid, true)
  end
end

function Form_EquipT10PopChange:OnBtnrateClicked()
  if self.m_openType == 1 then
    StackPopup:Push(UIDefines.ID_FORM_EQUIPT10POP2)
  else
    StackPopup:Push(UIDefines.ID_FORM_EQUIPT10POP1, {
      equipData = self.m_equipData
    })
  end
end

function Form_EquipT10PopChange:OnBtnnoClicked()
  self:OnBtnReturnClicked()
end

function Form_EquipT10PopChange:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_EquipT10PopChange:IsOpenGuassianBlur()
  return true
end

function Form_EquipT10PopChange:OnDestroy()
  self.super.OnDestroy(self)
  self:DestroyItem()
end

local fullscreen = true
ActiveLuaUI("Form_EquipT10PopChange", Form_EquipT10PopChange)
return Form_EquipT10PopChange
