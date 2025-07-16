local Form_EquipT10OverloadSuccessful = class("Form_EquipT10OverloadSuccessful", require("UI/UIFrames/Form_EquipT10OverloadSuccessfulUI"))
local SHOW_ATTR_TIPS_NUM = 3
local ATTR_MAX_LEVEL = 20

function Form_EquipT10OverloadSuccessful:SetInitParam(param)
end

function Form_EquipT10OverloadSuccessful:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetItemIcon = self:createCommonItem(self.m_common_item)
end

function Form_EquipT10OverloadSuccessful:OnActive()
  self.super.OnActive(self)
  self:DestroyItem()
  self.m_equipUid = self.m_csui.m_param
  self.m_equipData = EquipManager:GetEquipDataByID(self.m_equipUid)
  local canvasGroup = self.m_csui.m_uiGameObject.transform:GetComponent("CanvasGroup")
  canvasGroup.alpha = 1
  self.m_isClose = false
  self:RefreshUI()
end

function Form_EquipT10OverloadSuccessful:OnInactive()
  self.super.OnInactive(self)
  self.m_isClose = false
  self:DestroyItem()
end

function Form_EquipT10OverloadSuccessful:DestroyItem()
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
end

function Form_EquipT10OverloadSuccessful:RefreshUI()
  local itemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_equipData.iBaseId,
    iNum = 0
  }, self.m_equipData)
  self.m_widgetItemIcon:SetItemInfo(itemData)
  self.m_txt_equip_name_Text.text = itemData.name
  local flag = EquipManager:CheckIsShowCampAttAddExt(self.m_equipData.iEquipUid)
  local attrInfoList = EquipManager:GetEquipBaseAttr(self.m_equipData.iBaseId, self.m_equipData.iLevel, flag)
  local overLoadAttrInfoList = EquipManager:GetEquipOverLoadBaseAttr(self.m_equipData.iBaseId, 0)
  for i = 1, 2 do
    local attrInfo = attrInfoList[i]
    local overLoadInfo = overLoadAttrInfoList[i]
    if attrInfo and attrInfo.cfg and overLoadInfo and overLoadInfo.cfg then
      ResourceUtil:CreatePropertyImg(self["m_ability_icon" .. i .. "_Image"], attrInfo.id)
      local attrCfg = attrInfo.cfg
      self["m_txt_ability_name" .. i .. "_Text"].text = tostring(attrCfg.m_mCNName)
      self["m_before_ability_num" .. i .. "_Text"].text = tostring(attrInfo.num)
      self["m_after_ability_num" .. i .. "_Text"].text = tostring(overLoadInfo.num)
    end
  end
  local overloadEffect = self.m_equipData.mOverloadEffect
  for i = 1, 3 do
    if overloadEffect[i] then
      local effectCfg = EquipManager:GetEquipEffectCfgByIdLv(overloadEffect[i].iGroupId, overloadEffect[i].iEffectLevel)
      local highQuality = effectCfg.m_HighQuality
      self["m_bg1_item" .. i]:SetActive(highQuality == 1)
      self["m_bg2_item" .. i]:SetActive(highQuality == 0)
      self["m_txt_level_item" .. i .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(20033), tostring(overloadEffect[i].iEffectLevel))
      self["m_pnl_type1_item" .. i]:SetActive(true)
      self["m_pnl_type2_item" .. i]:SetActive(false)
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
      self["m_txt_desc_item" .. i .. "_Text"].text = tostring(effectCfg.m_mDesc)
      self["m_txt_num_item" .. i .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(20094), tostring(effectCfg.m_Data))
    else
      self["m_pnl_type1_item" .. i]:SetActive(false)
      self["m_pnl_type2_item" .. i]:SetActive(true)
    end
  end
end

function Form_EquipT10OverloadSuccessful:CreateOverLoadItem(item_base_obj, parentTransform)
  local cloneObj = GameObject.Instantiate(item_base_obj, parentTransform).gameObject
  UILuaHelper.SetActive(cloneObj, true)
  return cloneObj
end

function Form_EquipT10OverloadSuccessful:ShowOverLoadAttrLevel(cloneObj, showRed)
  local rootTrans = cloneObj.transform
  local normalNode = rootTrans:Find("bg_red")
  local chooseNode = rootTrans:Find("bg_gray")
  normalNode.gameObject:SetActive(showRed)
  chooseNode.gameObject:SetActive(not showRed)
  UILuaHelper.SetActive(cloneObj, true)
end

function Form_EquipT10OverloadSuccessful:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_EquipT10OverloadSuccessful:OnBtnCloseClicked()
  if self.m_isClose == true then
    return
  end
  self.m_isClose = true
  local canvasGroup = self.m_csui.m_uiGameObject.transform:GetComponent("CanvasGroup")
  local sequence = Tweening.DOTween.Sequence()
  sequence:Insert(self.sequence_time, DOTweenModuleUI.DOFade(canvasGroup, 0, 0.35))
  sequence:OnComplete(function()
    if self and self.CloseForm then
      self:CloseForm()
      local pos = EquipManager:GetHeroEquippedPosByData(self.m_equipData)
      if pos then
        StackPopup:Push(UIDefines.ID_FORM_ITEMTIPST10, {
          equipData = self.m_equipData,
          pos = pos
        })
      end
    end
  end)
  sequence:SetAutoKill(true)
end

function Form_EquipT10OverloadSuccessful:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_EquipT10OverloadSuccessful", Form_EquipT10OverloadSuccessful)
return Form_EquipT10OverloadSuccessful
