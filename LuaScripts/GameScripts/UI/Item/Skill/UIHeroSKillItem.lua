local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroSKillItem = class("UIHeroSKillItem", UIItemBase)
local SkillBuffIns = ConfigManager:GetConfigInsByName("SkillBuff")

function UIHeroSKillItem:OnInit()
  self.m_buffItemList = {}
end

function UIHeroSKillItem:OnFreshData()
  self:DestroyBuffItem()
  self:SetSkillInfo(self.m_itemData)
end

function UIHeroSKillItem:SetSkillInfo(itemData)
  local skillCfg = itemData.skillCfg
  local skillDes = itemData.skillDes or ""
  local upStarDesTab = itemData.upStarDesTab or {}
  local skillLv = itemData.skillLv
  UILuaHelper.SetAtlasSprite(self.m_icon_kill01_Image, skillCfg.m_Skillicon)
  self.m_txt_skill_name_Text.text = skillCfg.m_mName
  self.m_txt_skill_lv_num01_Text.text = tostring(skillLv)
  self.m_txt_desc_Text.text = skillDes
  if skillCfg.m_BuffDescID then
    self:CreatBuffInfoItem(skillCfg.m_BuffDescID, 1)
  end
  self.m_txt_ult_Text.text = itemData.skillTypeName
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_itemRootObj)
  local maxSkillLv = HeroManager:GetSkillMaxLevelById(itemData.skillGroupID, skillCfg.m_SkillID)
  if skillLv == maxSkillLv and maxSkillLv == 1 then
    self.m_img_skill_rectangle01:SetActive(false)
  else
    self.m_img_skill_rectangle01:SetActive(true)
  end
  if itemData.skillShowType == 3 then
    UILuaHelper.SetColor(self.m_img_skill_frame_Image, 202, 196, 150, 1)
  else
    UILuaHelper.SetColor(self.m_img_skill_frame_Image, 33, 33, 33, 1)
  end
  UILuaHelper.SetActive(self.m_pnl_skillcost, false)
  self.m_img_line:SetActive(self.m_itemIndex ~= 1)
  local cost = HeroManager:GetSkillCost(skillCfg.m_SkillID, skillLv)
  UILuaHelper.SetActive(self.m_pnl_skillcost, false)
  if 0 < cost then
    UILuaHelper.SetActive(self.m_pnl_skillcost, true)
    self.m_txt_skillcost_Text.text = tostring(cost)
  end
end

function UIHeroSKillItem:ChangeSkillDesParam(description, param)
  local params = {}
  local valueList = utils.changeCSArrayToLuaTable(param)
  local paramFStr = "%.f"
  local paramFStr1 = "%.1f"
  for i, skillValueId in ipairs(valueList) do
    local value, valueType = HeroManager:GetSkillValueByIdAndLevel(skillValueId, 1)
    if GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[valueType] then
      local paramF = GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.Fixed == valueType and paramFStr or paramFStr1
      value = string.format(paramF, value / GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[valueType])
    end
    if GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent == valueType then
      value = string.format(ConfigManager:GetCommonTextById(100009), tostring(value))
    else
    end
    params[#params + 1] = value
  end
  if params == nil or #params == 0 then
    return description
  end
  return string.gsubnumberreplace(description, table.unpack(params))
end

function UIHeroSKillItem:CreatBuffInfoItem(buffIDArray, index)
  if not buffIDArray then
    return
  end
  local buffIDLen = buffIDArray.Length
  local buffCfgList = {}
  for i = 1, buffIDLen do
    local tempBuffID = buffIDArray[i - 1]
    local buffCfg = SkillBuffIns:GetValue_ByBuffID(tempBuffID)
    if buffCfg:GetError() ~= true then
      buffCfgList[#buffCfgList + 1] = buffCfg
    end
  end
  local dataLen = #buffCfgList
  if dataLen == 0 then
    UILuaHelper.SetActive(self["m_buff_list" .. index], false)
  else
    UILuaHelper.SetActive(self["m_buff_list" .. index], true)
    for i = 1, dataLen do
      local buffObj
      if self["m_baseBuff" .. index] and i == 1 then
        buffObj = self["m_baseBuff" .. index].transform
      else
        local newItemTrans = GameObject.Instantiate(self["m_baseBuff" .. index], self["m_buff_list" .. index].transform).transform
        self.m_buffItemList[#self.m_buffItemList + 1] = newItemTrans
        buffObj = newItemTrans
      end
      self:RefreshBuffInfo(buffObj, index, buffCfgList[i])
    end
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self["m_buff_list" .. index])
end

function UIHeroSKillItem:RefreshBuffInfo(buffObjTran, index, buffCfg)
  local buffIcon = buffObjTran:Find("m_img_buff_icon" .. index):GetComponent(T_Image)
  local txt_buff_desc = buffObjTran:Find("m_txt_buff_desc" .. index):GetComponent(T_TextMeshProUGUI)
  UILuaHelper.SetAtlasSprite(buffIcon, "Atlas_Buff/" .. buffCfg.m_Icon)
  local buffName = buffCfg.m_mName
  local showParamStr = HeroManager:GetBuffDescribeByCfg(buffCfg)
  txt_buff_desc.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20092), buffName, showParamStr)
end

function UIHeroSKillItem:DestroyBuffItem()
  if self.m_buffItemList then
    for i = #self.m_buffItemList, 1, -1 do
      CS.UnityEngine.GameObject.Destroy(self.m_buffItemList[i].gameObject)
    end
  end
end

function UIHeroSKillItem:dispose()
  UIHeroSKillItem.super.dispose(self)
  self:DestroyBuffItem()
end

return UIHeroSKillItem
