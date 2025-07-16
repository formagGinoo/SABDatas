local Form_HeroEquipReplacePop = class("Form_HeroEquipReplacePop", require("UI/UIFrames/Form_HeroEquipReplacePopUI"))
local EnterEquipBoxAnimStr = "equipment_in"
local RED_COLOR = {
  178,
  69,
  43
}
local GREEN_COLOR = {
  54,
  142,
  113
}
local DEFAULT_COLOR = {
  3,
  2,
  2
}

function Form_HeroEquipReplacePop:SetInitParam(param)
end

function Form_HeroEquipReplacePop:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnEquipItemClk)
  }
  self.m_EquipListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_equip_list_InfinityGrid, "Equip/UIEquipItem", initGridData)
  self.m_EquipListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnEquipItemClk))
  self.m_selEquipData = nil
  self.m_selPos = nil
  self.m_equipDataList = {}
  self.m_equipPosDataList = {}
  self.m_grayImgMaterial = self.m_img_gray_Image.material
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_HeroEquipReplacePop:OnActive()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(33)
  self.super.OnActive(self)
  self:AddEventListeners()
  self.m_curShowHeroData = self.m_csui.m_param.heroData
  local serverData = self.m_curShowHeroData.serverData
  local heroCfg = self.m_curShowHeroData.characterCfg
  self.m_equipDataList = serverData.mEquip
  self.m_equipPosDataList = {}
  self.m_equipType = heroCfg.m_Equiptype
  self.m_equipCamp = heroCfg.m_Camp
  self.m_selPos = self.m_csui.m_param.pos
  UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterEquipBoxAnimStr)
  self:ShowHeroSpine(heroCfg.m_Spine)
  self:RefreshEquipList(self.m_selPos)
end

function Form_HeroEquipReplacePop:OnInactive()
  self.super.OnInactive(self)
  self.m_selEquipData = nil
  if self.m_widgetItemIconSelected then
    self.m_widgetItemIconSelected:SetActive(false)
    self.m_widgetItemIconSelected = nil
  end
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
end

function Form_HeroEquipReplacePop:AddEventListeners()
  self:addEventListener("eGameEvent_Equip_InstallEquip", handler(self, self.OnEventInstallEquip))
  self:addEventListener("eGameEvent_Equip_UnInstallEquip", handler(self, self.OnEventInstallEquip))
end

function Form_HeroEquipReplacePop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroEquipReplacePop:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HeroEquipReplacePop:ShowHeroSpine(heroSpinePathStr)
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.HeroEquip
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    self:OnLoadSpineBack()
  end)
end

function Form_HeroEquipReplacePop:OnLoadSpineBack()
  if not self.m_curHeroSpineObj then
    return
  end
  local spineObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spineObj, true)
  self:CheckShowSpineEnterAnim()
end

function Form_HeroEquipReplacePop:CheckShowSpineEnterAnim()
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpine = self.m_curHeroSpineObj.spineObj
  if not heroSpine then
    return
  end
  self.m_spineDitherExtension = heroSpine:GetComponent("SpineDitherExtension")
  UILuaHelper.SpineResetInit(heroSpine)
  if heroSpine:GetComponent("SpineSkeletonPosControl") then
    heroSpine:GetComponent("SpineSkeletonPosControl"):OnResetInit()
  end
  UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, "idle", false, false, function()
    if not UILuaHelper.IsNull(heroSpine) then
      UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, "idle", true, false)
    end
  end)
  self:FreshShowSpineMaskAndGray()
end

function Form_HeroEquipReplacePop:FreshShowSpineMaskAndGray()
  if self.m_spineDitherExtension and not UILuaHelper.IsNull(self.m_spineDitherExtension) then
    self.m_spineDitherExtension:SetSpineMaskAndGray(true, 2)
    if self.m_curHeroSpineObj then
      local spineObj = self.m_curHeroSpineObj.spineObj
      if spineObj then
        UILuaHelper.SetSpineTimeScale(spineObj, 0)
      end
    end
  end
end

function Form_HeroEquipReplacePop:OnEventInstallEquip(pos)
  self:OnBtnbackClicked()
end

function Form_HeroEquipReplacePop:GeneratedListData(equipPosDataList)
  local equipDataList = {}
  local equippedData = self.m_equipDataList[self.m_selPos]
  local combat = 0
  if equippedData then
    local flag = EquipManager:CheckIsShowCampAttAddExtByCfgId(equippedData.iBaseId, self.m_curShowHeroData.serverData.iHeroId)
    combat = CombatUtil:CalculateEquipCombatsByLv(equippedData.iBaseId, equippedData.iLevel, flag)
  end
  local equipList = table.deepcopy(equipPosDataList)
  for i, v in ipairs(equipList) do
    v.equipData.combat_other = combat
    v.equipData.equip_bg = true
    v.equipData.equipHeroId = self.m_curShowHeroData.serverData.iHeroId
    local processData = {
      iID = v.equipData.iBaseId,
      iNum = 1,
      customData = v.equipData
    }
    equipDataList[#equipDataList + 1] = processData
  end
  equipDataList = EquipManager:EquipmentStacked(equipDataList)
  self.m_equipPosDataList = EquipManager:SortEquipList(equipDataList, self.m_equipCamp)
  return equipDataList
end

function Form_HeroEquipReplacePop:RefreshEquipList(pos)
  local equipPosDataList = EquipManager:GetEquipByPosAndEquipType(pos, self.m_equipType, self.m_curShowHeroData.serverData.iHeroId)
  if 0 < #equipPosDataList then
    self.m_equip_list:SetActive(true)
    self.m_img_null02:SetActive(false)
    local equipDataList = self:GeneratedListData(equipPosDataList)
    self.m_EquipListInfinityGrid:ShowItemList(equipDataList)
    self.m_EquipListInfinityGrid:LocateTo(0)
  else
    self.m_equip_list:SetActive(false)
    self.m_img_null02:SetActive(true)
  end
  self:RefreshSelEquipItem()
end

function Form_HeroEquipReplacePop:RefreshSelEquipItem()
  local itemIconRootL = self.m_equip_node_l
  local itemIconRootR = self.m_equip_node_r
  local equippedData = self.m_equipDataList[self.m_selPos]
  if self.m_selEquipData and equippedData then
    itemIconRootL:SetActive(true)
    itemIconRootR:SetActive(true)
    self:RefreshEquipItemInfo(itemIconRootL, equippedData)
    self:RefreshEquipItemInfo(itemIconRootR, self.m_selEquipData)
    local flag = EquipManager:CheckIsShowCampAttAddExtByCfgId(self.m_selEquipData.iBaseId, self.m_curShowHeroData.serverData.iHeroId)
    local attrInfoList = EquipManager:GetEquipBaseAttr(self.m_selEquipData.iBaseId, self.m_selEquipData.iLevel, flag)
    local flag2 = EquipManager:CheckIsShowCampAttAddExtByCfgId(equippedData.iBaseId, self.m_curShowHeroData.serverData.iHeroId)
    local equippedAttrInfoList = EquipManager:GetEquipBaseAttr(equippedData.iBaseId, equippedData.iLevel, flag2)
    for i = 1, 2 do
      local attrInfo = attrInfoList[i]
      if attrInfo then
        local beforeAttr = attrInfo.num
        local afterAttr = equippedAttrInfoList[i].num
        local txt_num = itemIconRootR.transform:Find("icon_attributes0" .. i .. "/c_txt_num_0" .. i):GetComponent(T_TextMeshProUGUI)
        if beforeAttr and afterAttr then
          if beforeAttr > afterAttr then
            self["m_equip_after_icon_arrow0" .. i]:SetActive(true)
            CS.UI.UILuaHelper.SetLocalRotationParam(self["m_equip_after_icon_arrow0" .. i], 0, 0, 0)
            UILuaHelper.SetColor(self["m_equip_after_icon_arrow0" .. i .. "_Image"], table.unpack(GREEN_COLOR))
            UILuaHelper.SetColor(txt_num, table.unpack(GREEN_COLOR))
          elseif beforeAttr == afterAttr then
            self["m_equip_after_icon_arrow0" .. i]:SetActive(false)
            UILuaHelper.SetColor(txt_num, table.unpack(DEFAULT_COLOR))
          elseif beforeAttr < afterAttr then
            self["m_equip_after_icon_arrow0" .. i]:SetActive(true)
            CS.UI.UILuaHelper.SetLocalRotationParam(self["m_equip_after_icon_arrow0" .. i], 0, 0, 180)
            UILuaHelper.SetColor(self["m_equip_after_icon_arrow0" .. i .. "_Image"], table.unpack(RED_COLOR))
            UILuaHelper.SetColor(txt_num, table.unpack(RED_COLOR))
          end
        else
          self["m_equip_after_icon_arrow0" .. i]:SetActive(false)
        end
      end
    end
    self.m_img_l_null:SetActive(false)
    self.m_img_r_null:SetActive(false)
  elseif not self.m_selEquipData and equippedData then
    itemIconRootL:SetActive(true)
    itemIconRootR:SetActive(false)
    self:RefreshEquipItemInfo(itemIconRootL, equippedData)
    self.m_equip_after_icon_arrow01:SetActive(false)
    self.m_equip_after_icon_arrow02:SetActive(false)
    self.m_img_l_null:SetActive(false)
    self.m_img_r_null:SetActive(true)
  elseif self.m_selEquipData and not equippedData then
    itemIconRootL:SetActive(false)
    itemIconRootR:SetActive(true)
    self:RefreshEquipItemInfo(itemIconRootR, self.m_selEquipData)
    self.m_equip_after_icon_arrow01:SetActive(false)
    self.m_equip_after_icon_arrow02:SetActive(false)
    self.m_img_r_null:SetActive(false)
    self.m_img_l_null:SetActive(true)
  else
    itemIconRootL:SetActive(false)
    itemIconRootR:SetActive(false)
    self.m_img_r_null:SetActive(true)
    self.m_img_l_null:SetActive(true)
  end
  UILuaHelper.SetActive(self.m_node_wear_light, self.m_selEquipData ~= nil)
  UILuaHelper.SetActive(self.m_node_wear_gray, self.m_selEquipData == nil)
end

function Form_HeroEquipReplacePop:RefreshEquipItemInfo(itemIconRoot, equipData)
  local cfg = EquipManager:GetEquipCfgByBaseId(equipData.iBaseId)
  local m_txt_equip_name = itemIconRoot.transform:Find("txt_equip_name"):GetComponent(T_TextMeshProUGUI)
  local m_icon_equip = itemIconRoot.transform:Find("icon_equip01"):GetComponent("Image")
  local m_icon_equip_quality = itemIconRoot.transform:Find("img_equip_bg"):GetComponent("Image")
  local m_txt_lv = itemIconRoot.transform:Find("txt_lv/txt_lv_num01"):GetComponent(T_TextMeshProUGUI)
  local m_img_camp_bg = itemIconRoot.transform:Find("pnl_lefticon/img_camp_bg").gameObject
  local m_icon_camp = itemIconRoot.transform:Find("pnl_lefticon/img_camp_bg/icon_camp"):GetComponent(T_Image)
  m_txt_equip_name.text = tostring(cfg.m_mEquipName)
  m_txt_lv.text = equipData.iLevel or 0
  local flag = EquipManager:CheckIsShowCampAttAddExtByCfgId(equipData.iBaseId, self.m_curShowHeroData.serverData.iHeroId)
  local equippedAttrInfoList = EquipManager:GetEquipBaseAttr(equipData.iBaseId, equipData.iLevel, flag)
  ResourceUtil:CreateEquipIcon(m_icon_equip, equipData.iBaseId)
  ResourceUtil:CreateEquipQualityImg(m_icon_equip_quality, cfg.m_Quality)
  local equipTypeIcon = itemIconRoot.transform:Find("pnl_lefticon/img_type_bg/icon_type")
  ResourceUtil:CreateEquipTypeImg(equipTypeIcon:GetComponent("Image"), cfg.m_EquiptypeRes)
  if 0 < cfg.m_BonusCamp then
    m_img_camp_bg:SetActive(true)
    ResourceUtil:CreateEquipCampImg(m_icon_camp, cfg.m_BonusCamp)
    if equipData.iEquipUid then
      local flag = EquipManager:CheckEquipShowCampAttAddExt(equipData.iBaseId, self.m_curShowHeroData.serverData.iHeroId)
      if flag then
        m_icon_camp.material = nil
      else
        m_icon_camp.material = self.m_grayImgMaterial
      end
      for i = 1, 5 do
        local campFx = m_img_camp_bg.transform:Find("icon_camp/c_common_item_camp" .. i).gameObject
        if campFx then
          campFx:SetActive(i == cfg.m_BonusCamp and flag)
        end
      end
    end
  else
    m_img_camp_bg:SetActive(false)
  end
  for i = 1, 2 do
    local attrInfo = equippedAttrInfoList[i]
    if attrInfo and attrInfo.cfg then
      local m_icon_attribute = itemIconRoot.transform:Find("icon_attributes0" .. i):GetComponent("Image")
      local m_attribute_name = itemIconRoot.transform:Find("icon_attributes0" .. i .. "/c_txt_attributes0" .. i):GetComponent(T_TextMeshProUGUI)
      local m_attribute_value = itemIconRoot.transform:Find("icon_attributes0" .. i .. "/c_txt_num_0" .. i):GetComponent(T_TextMeshProUGUI)
      ResourceUtil:CreatePropertyImg(m_icon_attribute, attrInfo.id)
      local attrCfg = attrInfo.cfg
      m_attribute_name.text = tostring(attrCfg.m_mCNName)
      m_attribute_value.text = tostring(attrInfo.num)
      if equippedAttrInfoList and equippedAttrInfoList[i] then
        m_attribute_value.text = tostring(equippedAttrInfoList[i].num)
      end
    end
  end
end

function Form_HeroEquipReplacePop:OnEquipItemClk(index, widgetItemObj)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  if self.m_widgetItemIconSelected then
    self.m_widgetItemIconSelected:SetActive(false)
  end
  self.m_widgetItemIconSelected = widgetItemObj.transform:Find("c_bg_selected").gameObject
  self.m_widgetItemIconSelected:SetActive(true)
  local chooseFJItemData = self.m_equipPosDataList[fjItemIndex].customData
  if chooseFJItemData then
    self.m_selEquipData = chooseFJItemData
    self:RefreshSelEquipItem()
  end
end

function Form_HeroEquipReplacePop:OnEquippedItemClk(pos)
  if self.m_equipDataList[pos] then
    self.m_selPos = pos
    StackPopup:Push(UIDefines.ID_FORM_ITEMTIPS, {
      equipData = self.m_equipDataList[pos],
      pos = pos
    })
  end
end

function Form_HeroEquipReplacePop:OnNodewearlightClicked()
  local iHeroId = self.m_curShowHeroData.serverData.iHeroId
  if self.m_selEquipData and self.m_selPos and iHeroId then
    if self.m_selEquipData.iHeroId ~= 0 then
      utils.CheckAndPushCommonTips({
        tipsID = 1002,
        func1 = function()
          EquipManager:ReqSwapEquip(self.m_selEquipData.iHeroId, iHeroId, self.m_selPos)
        end
      })
    else
      EquipManager:ReqInstallEquip(iHeroId, self.m_selPos, self.m_selEquipData.iEquipUid)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30002)
  end
end

function Form_HeroEquipReplacePop:OnBtnbackClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:broadcastEvent("eGameEvent_Hero_RefreshSpine")
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_HEROEQUIPREPLACEPOP)
end

function Form_HeroEquipReplacePop:OnNodeweargrayClicked()
  self:OnBtnbackClicked()
end

function Form_HeroEquipReplacePop:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

local fullscreen = true
ActiveLuaUI("Form_HeroEquipReplacePop", Form_HeroEquipReplacePop)
return Form_HeroEquipReplacePop
