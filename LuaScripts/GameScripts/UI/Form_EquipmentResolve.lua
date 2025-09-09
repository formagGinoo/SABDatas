local Form_EquipmentResolve = class("Form_EquipmentResolve", require("UI/UIFrames/Form_EquipmentResolveUI"))

function Form_EquipmentResolve:SetInitParam(param)
end

function Form_EquipmentResolve:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnEquipItemClk)
  }
  self.m_EquipListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_resolve_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_EquipListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnEquipItemClk))
end

function Form_EquipmentResolve:OnActive()
  self.super.OnActive(self)
  self.m_equipTab = self.m_csui.m_param.equipTab
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_EquipmentResolve:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_EquipmentResolve:AddEventListeners()
  self:addEventListener("eGameEvent_Equip_Decompose", handler(self, self.OnBtnReturnClicked))
end

function Form_EquipmentResolve:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipmentResolve:RefreshUI()
  local str = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100818), table.getn(self.m_equipTab))
  self.m_txt_resolveinfo_Text.text = str
  self:RefreshEquipList()
  local itemList = EquipManager:ResolveEquipToExpItemByEquipMap(self.m_equipTab)
  for i = 1, 2 do
    local itemData = itemList[i]
    self["m_icon_resolve0" .. i]:SetActive(itemData)
    if itemData then
      ResourceUtil:CreatIconById(self["m_icon_resolve0" .. i .. "_Image"], itemData.iID)
      self["m_txt_resolvenum0" .. i .. "_Text"].text = itemData.iNum
    end
  end
end

function Form_EquipmentResolve:GeneratedListData(equipTab)
  local dataList = {}
  for i, v in pairs(equipTab) do
    local equipData = v.data
    if equipData then
      local data = {
        iBaseId = equipData.iBaseId,
        iEquipUid = equipData.iEquipUid,
        iLevel = equipData.iLevel,
        iExp = equipData.iExp,
        iHeroId = equipData.iHeroId,
        iOverloadHero = equipData.iOverloadHero,
        optimizing = true
      }
      dataList[#dataList + 1] = {
        iID = equipData.iBaseId,
        iNum = 1,
        customData = data,
        data = data
      }
    end
  end
  dataList = EquipManager:EquipmentStacked(dataList)
  dataList = EquipManager:SortEquipListByQuality(dataList, false)
  return dataList
end

function Form_EquipmentResolve:RefreshEquipList()
  self.m_itemList = self:GeneratedListData(self.m_equipTab)
  if #self.m_itemList > 0 then
    self.m_resolve_list:SetActive(true)
    self.m_EquipListInfinityGrid:ShowItemList(self.m_itemList)
    self.m_EquipListInfinityGrid:LocateTo(0)
  else
    self.m_resolve_list:SetActive(false)
  end
end

function Form_EquipmentResolve:OnEquipItemClk(index)
  if not index then
    return
  end
  local fjItemIndex = index + 1
  if not self.m_EquipListInfinityGrid or not self.m_itemList then
    return
  end
  local chooseFJItemData = self.m_itemList[fjItemIndex]
  if chooseFJItemData then
    local itemData = chooseFJItemData
    if itemData.data and itemData.data.iEquipUid then
      itemData = itemData.data
    end
    if itemData and itemData.iEquipUid and itemData.iOverloadHero and itemData.iOverloadHero ~= 0 then
      StackPopup:Push(UIDefines.ID_FORM_ITEMTIPST10, {equipData = itemData})
    else
      utils.openItemDetailPop(itemData, nil, true)
    end
    self:OnBtnReturnClicked()
  end
end

function Form_EquipmentResolve:OnBtnconfirmClicked()
  local dataList = {}
  for uid, v in pairs(self.m_equipTab) do
    dataList[#dataList + 1] = uid
  end
  if #dataList == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40053)
    return
  end
  EquipManager:ReqEquipDecompose(dataList)
end

function Form_EquipmentResolve:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_EquipmentResolve:OnBtnclose02Clicked()
  self:CloseForm()
end

function Form_EquipmentResolve:IsOpenGuassianBlur()
  return true
end

function Form_EquipmentResolve:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_EquipmentResolve", Form_EquipmentResolve)
return Form_EquipmentResolve
