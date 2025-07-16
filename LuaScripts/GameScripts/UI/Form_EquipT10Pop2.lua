local Form_EquipT10Pop2 = class("Form_EquipT10Pop2", require("UI/UIFrames/Form_EquipT10Pop2UI"))
local EQUIP_RATE_DES_STR = {
  20327,
  20328,
  20329
}

function Form_EquipT10Pop2:SetInitParam(param)
end

function Form_EquipT10Pop2:AfterInit()
  self.super.AfterInit(self)
  self.m_description = ConfigManager:GetCommonTextById(2107)
end

function Form_EquipT10Pop2:OnActive()
  self.super.OnActive(self)
  self:RefreshUI()
end

function Form_EquipT10Pop2:OnInactive()
  self.super.OnInactive(self)
  self:DestroyItem()
end

function Form_EquipT10Pop2:RefreshUI()
  self:DestroyItem()
  self:RefreshRateList()
  self:RefreshSlotRateUI()
  self:RefreshDesc(false)
  self.m_txt_title1_long_Text.text = ConfigManager:GetCommonTextById(2105)
end

function Form_EquipT10Pop2:RefreshDesc(showAll)
  if showAll then
    self.m_txt_desc2_Text.text = self.m_description
    self.m_img_arrow:SetActive(true)
    self.m_txt_desc:SetActive(false)
    self.m_txt_desc2:SetActive(true)
  else
    self.m_txt_desc_Text.text = self.m_description
    self.m_txt_desc:SetActive(true)
    self.m_txt_desc2:SetActive(false)
    self.m_img_arrow:SetActive(false)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_scroll_content)
end

function Form_EquipT10Pop2:DestroyItem()
  if self.m_ratePanelItem and #self.m_ratePanelItem > 0 then
    for i = #self.m_ratePanelItem, 1, -1 do
      CS.UnityEngine.GameObject.Destroy(self.m_ratePanelItem[i].go)
      self.m_ratePanelItem[i] = nil
    end
  end
  self.m_ratePanelItem = {}
end

function Form_EquipT10Pop2:GetSlotRate()
  local slotRateList = {}
  local EquipEffectSlotIns = ConfigManager:GetConfigInsByName("EquipEffectSlot")
  local cfgAll = EquipEffectSlotIns:GetAll()
  for i, v in pairs(cfgAll) do
    local rate = v.m_Percentage / 100
    slotRateList[#slotRateList + 1] = {
      slot = v.m_SlotID,
      percentage = string.format(ConfigManager:GetCommonTextById(100009), rate)
    }
  end
  
  local function sortFun(data1, data2)
    return data1.slot < data2.slot
  end
  
  table.sort(slotRateList, sortFun)
  return slotRateList
end

function Form_EquipT10Pop2:RefreshSlotRateUI()
  local slotRateList = self:GetSlotRate()
  for i = 1, 3 do
    self["m_item2_num" .. i .. "_Text"].text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(EQUIP_RATE_DES_STR[i]), slotRateList[i].percentage)
  end
end

function Form_EquipT10Pop2:GetEquipEffectGroupRate()
  local effectGroupRateList = {}
  local EquipEffectGroupIns = ConfigManager:GetConfigInsByName("EquipEffectGroup")
  local cfgAll = EquipEffectGroupIns:GetAll()
  local relatedWeightAll = 0
  for i, v in pairs(cfgAll) do
    relatedWeightAll = relatedWeightAll + v.m_RelatedWeight
  end
  for i, v in pairs(cfgAll) do
    local rate = v.m_RelatedWeight / relatedWeightAll * 100
    effectGroupRateList[#effectGroupRateList + 1] = {
      groupID = v.m_GroupID,
      des = v.m_mDesc,
      weight = string.format(ConfigManager:GetCommonTextById(100009), string.format("%.4f", rate))
    }
  end
  
  local function sortFun(data1, data2)
    return data1.groupID < data2.groupID
  end
  
  table.sort(effectGroupRateList, sortFun)
  return effectGroupRateList
end

function Form_EquipT10Pop2:RefreshRateList()
  local effectList = self:GetEquipEffectGroupRate()
  local itemTemplate = self.m_content.transform:Find("pnl_item").gameObject
  itemTemplate:SetActive(false)
  local vGetItemInfo = effectList
  local num = #vGetItemInfo
  for i = 1, #vGetItemInfo do
    local stGetItemData = vGetItemInfo[i]
    local rateItem = self.m_ratePanelItem[i]
    if rateItem == nil then
      rateItem = {}
      rateItem.go = CS.UnityEngine.GameObject.Instantiate(itemTemplate, self.m_content.transform)
      self.m_ratePanelItem[i] = rateItem
    end
    rateItem.go:SetActive(true)
    rateItem.go.transform:Find("m_txt_rank1"):GetComponent(T_TextMeshProUGUI).text = stGetItemData.des
    rateItem.go.transform:Find("m_txt_percent"):GetComponent(T_TextMeshProUGUI).text = stGetItemData.weight
    rateItem.go.transform:Find("m_img_lastline").gameObject:SetActive(i == num)
  end
  for i = #vGetItemInfo + 1, #self.m_ratePanelItem do
    self.m_ratePanelItem[i].go:SetActive(false)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_content)
end

function Form_EquipT10Pop2:OnTxtdescClicked()
  self:RefreshDesc(true)
end

function Form_EquipT10Pop2:OnTxtdesc2Clicked()
  self:RefreshDesc(false)
end

function Form_EquipT10Pop2:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_EquipT10Pop2:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_EquipT10Pop2:IsOpenGuassianBlur()
  return true
end

function Form_EquipT10Pop2:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_EquipT10Pop2", Form_EquipT10Pop2)
return Form_EquipT10Pop2
