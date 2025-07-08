local Form_EquipT10Pop1 = class("Form_EquipT10Pop1", require("UI/UIFrames/Form_EquipT10Pop1UI"))

function Form_EquipT10Pop1:SetInitParam(param)
end

function Form_EquipT10Pop1:AfterInit()
  self.super.AfterInit(self)
  self.m_description = ConfigManager:GetCommonTextById(2104)
  self.m_rateLvDes = ConfigManager:GetCommonTextById(20093)
end

function Form_EquipT10Pop1:OnActive()
  self.super.OnActive(self)
  self.m_equipData = self.m_csui.m_param.equipData
  self:RefreshUI()
end

function Form_EquipT10Pop1:OnInactive()
  self.super.OnInactive(self)
  self:DestroyItem()
end

function Form_EquipT10Pop1:RefreshUI()
  self:DestroyItem()
  self.m_txt_title1_long_Text.text = ConfigManager:GetCommonTextById(2103)
  self:RefreshRateUI()
  self:RefreshDesc(false)
end

function Form_EquipT10Pop1:RefreshRateUI()
  local effectList = self:GetEquipEffectLevelRate()
  self.m_pnl_black:SetActive(false)
  self.m_rate_content:SetActive(false)
  local itemGroupTemplate = self.m_pnl_black
  local itemTemplateParent = self.m_rate_content
  for i = 1, #effectList do
    local stGetItemData = effectList[i]
    local rateItem = self.m_rateRootItem[i]
    if rateItem == nil then
      rateItem = {}
      rateItem.groupGo = CS.UnityEngine.GameObject.Instantiate(itemGroupTemplate, self.m_pnl_rate.transform)
      rateItem.levelGo = CS.UnityEngine.GameObject.Instantiate(itemTemplateParent, self.m_pnl_rate.transform)
      self.m_rateRootItem[i] = rateItem
    end
    rateItem.groupGo:SetActive(true)
    rateItem.levelGo:SetActive(true)
    rateItem.groupGo.transform:Find("m_txt_title1"):GetComponent(T_TextMeshProUGUI).text = stGetItemData.des
    rateItem.groupGo.transform:Find("m_txt_percent1"):GetComponent(T_TextMeshProUGUI).text = stGetItemData.effect
    if not self.m_ratePanelItem[i] then
      self.m_ratePanelItem[i] = {}
    end
    local itemTemplate = rateItem.levelGo.transform:Find("pnl_item").gameObject
    itemTemplate:SetActive(false)
    local infoList = stGetItemData.infoList
    local num = #infoList
    for m = 1, #infoList do
      local infoData = infoList[m]
      local lvRateItem = self.m_ratePanelItem[i][m]
      if lvRateItem == nil then
        lvRateItem = {}
        lvRateItem.go = CS.UnityEngine.GameObject.Instantiate(itemTemplate, rateItem.levelGo.transform)
        self.m_ratePanelItem[i][m] = lvRateItem
      end
      lvRateItem.go:SetActive(true)
      lvRateItem.go.transform:Find("m_txt_rank1"):GetComponent(T_TextMeshProUGUI).text = infoData.des
      lvRateItem.go.transform:Find("m_txt_percent"):GetComponent(T_TextMeshProUGUI).text = infoData.weight
      lvRateItem.go.transform:Find("m_img_lastline").gameObject:SetActive(m == num)
    end
    for j = #infoList + 1, #self.m_ratePanelItem do
      self.m_ratePanelItem[i][j].go:SetActive(false)
    end
    UILuaHelper.ForceRebuildLayoutImmediate(rateItem.levelGo)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_rate)
end

function Form_EquipT10Pop1:GetEquipEffectLevelRate()
  local effectLevelRateList = {}
  local EquipEffectGroupIns = ConfigManager:GetConfigInsByName("EquipEffectGroup")
  local overEffectList = self.m_equipData.mOverloadEffect
  for i, v in pairs(overEffectList) do
    local cfg = EquipEffectGroupIns:GetValue_ByGroupID(v.iGroupId)
    effectLevelRateList[#effectLevelRateList + 1] = {
      groupId = v.iGroupId,
      des = cfg.m_mDesc,
      effect = ""
    }
  end
  local EquipEffectIns = ConfigManager:GetConfigInsByName("EquipEffect")
  for i, v in ipairs(effectLevelRateList) do
    local cfgList = EquipEffectIns:GetValue_ByGroupID(v.groupId)
    local relatedWeightAll = self:GetEffectGroupRate(v.groupId)
    for m, n in pairs(cfgList) do
      local rate = n.m_RelatedWeight / relatedWeightAll * 100
      local des = string.gsubnumberreplace(self.m_rateLvDes, n.m_EffectLevel, n.m_mDesc, n.m_Data)
      local levelInfo = {
        date = n.m_Data,
        level = n.m_EffectLevel,
        des = des,
        weight = string.format(ConfigManager:GetCommonTextById(100009), string.format("%.4f", rate))
      }
      if not effectLevelRateList[i].infoList then
        effectLevelRateList[i].infoList = {}
      end
      effectLevelRateList[i].infoList[#effectLevelRateList[i].infoList + 1] = levelInfo
    end
    
    local function sortFun(data1, data2)
      return data1.level < data2.level
    end
    
    table.sort(effectLevelRateList[i].infoList, sortFun)
    local minStr = effectLevelRateList[i].infoList[1].date
    local maxStr = effectLevelRateList[i].infoList[#effectLevelRateList[i].infoList].date
    local effectRange = string.format(ConfigManager:GetCommonTextById(100016), tostring(minStr), tostring(maxStr))
    effectLevelRateList[i].effect = effectRange
  end
  return effectLevelRateList
end

function Form_EquipT10Pop1:GetEffectGroupRate(groupId)
  local EquipEffectIns = ConfigManager:GetConfigInsByName("EquipEffect")
  local cfgList = EquipEffectIns:GetValue_ByGroupID(groupId)
  local rateAll = 0
  for m, n in pairs(cfgList) do
    rateAll = rateAll + n.m_RelatedWeight
  end
  return rateAll
end

function Form_EquipT10Pop1:RefreshDesc(showAll)
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

function Form_EquipT10Pop1:OnTxtdescClicked()
  self:RefreshDesc(true)
end

function Form_EquipT10Pop1:OnTxtdesc2Clicked()
  self:RefreshDesc(false)
end

function Form_EquipT10Pop1:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_EquipT10Pop1:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_EquipT10Pop1:DestroyItem()
  if self.m_ratePanelItem and #self.m_ratePanelItem > 0 then
    for i = #self.m_ratePanelItem, 1, -1 do
      for j = #self.m_ratePanelItem[i], 1, -1 do
        CS.UnityEngine.GameObject.Destroy(self.m_ratePanelItem[i][j].go)
        self.m_ratePanelItem[i][j] = nil
      end
    end
  end
  self.m_ratePanelItem = {}
  if self.m_rateRootItem and 0 < #self.m_rateRootItem then
    for i = #self.m_rateRootItem, 1, -1 do
      CS.UnityEngine.GameObject.Destroy(self.m_rateRootItem[i].groupGo)
      CS.UnityEngine.GameObject.Destroy(self.m_rateRootItem[i].levelGo)
      self.m_rateRootItem[i] = nil
    end
  end
  self.m_rateRootItem = {}
end

function Form_EquipT10Pop1:IsOpenGuassianBlur()
  return true
end

function Form_EquipT10Pop1:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_EquipT10Pop1", Form_EquipT10Pop1)
return Form_EquipT10Pop1
