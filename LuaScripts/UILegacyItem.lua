local UIItemBase = require("UI/Common/UIItemBase")
local UILegacyItem = class("UILegacyItem", UIItemBase)
local SkillIns = ConfigManager:GetConfigInsByName("Skill")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local MaxLegacySkillNum = LegacyManager.MaxLegacySkillNum

function UILegacyItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_curLegacyData = nil
  self.m_curLegacyCfg = nil
  self.m_curLegacyID = nil
  self.m_curLegacyLv = nil
  self.m_legacySkillDataList = {}
  self.m_legacyLvCfgList = {}
  self.m_curLegacyLvCfg = nil
  self.m_ItemBase = self.m_itemRootObj.transform:Find("item_root/c_common_item")
  self.m_itemWidget = self:createCommonItem(self.m_ItemBase.gameObject)
  self.m_itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnLegacyItemClick(itemID, itemNum, itemCom)
  end)
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_attr_base_root_trans = self.m_attr_item_root.transform
  self.m_showAttrBaseCfgList = {}
  self.m_showAttrBaseItems = {}
  self:InitShowAttr()
  self.m_legacyIconWidgets = {}
  local tempLegacyIcon = self:createLegacySkillIcon(self.m_legacy_item_skill_item)
  self.m_legacyIconWidgets[1] = tempLegacyIcon
  tempLegacyIcon:SetItemClickBack(function()
    self:OnLegacySkillIconClk(1)
  end)
  self.m_isFull = false
end

function UILegacyItem:OnFreshData()
  local legacyData = self.m_itemData
  if not legacyData then
    return
  end
  self.m_curLegacyData = legacyData
  self.m_curLegacyServerData = self.m_curLegacyData.serverData or {}
  self.m_curLegacyID = self.m_curLegacyData.legacyCfg.m_ID
  self.m_curLegacyCfg = self.m_curLegacyData.legacyCfg
  self:FreshLegacyLvList()
  self.m_curLegacyLv = self.m_curLegacyServerData.iLevel or 1
  self.m_curLegacyLvCfg = LegacyLevelIns:GetValue_ByIDAndLevel(self.m_curLegacyID, self.m_curLegacyLv)
  self:FreshLegacySkillData()
  self:FreshItemUI()
  self.m_btn_go:SetActive(self.m_curLegacyData.serverData == nil)
  self.m_img_itemlock:SetActive(self.m_curLegacyData.serverData == nil)
  self.m_btn_Wear:SetActive(self.m_curLegacyData.serverData ~= nil)
  self.m_img_numicon:SetActive(self.m_curLegacyData.serverData ~= nil)
  self.m_txt_person_item_num:SetActive(self.m_curLegacyData.serverData ~= nil)
end

function UILegacyItem:OnDestroy()
  UILegacyItem.super.OnDestroy(self)
  for i, v in ipairs(self.m_showAttrBaseItems) do
    if 1 < i then
      GameObject.Destroy(v.itemRoot.gameObject)
    end
  end
end

function UILegacyItem:FreshLegacyLvList()
  if not self.m_curLegacyID then
    return
  end
  local legacyDic = LegacyLevelIns:GetValue_ByID(self.m_curLegacyID)
  if not legacyDic then
    return
  end
  for _, v in pairs(legacyDic) do
    self.m_legacyLvCfgList[v.m_Level] = v
  end
end

function UILegacyItem:FreshLegacySkillData()
  self.m_legacySkillDataList = {}
  if not self.m_curLegacyData then
    return
  end
  local legacyCfg = self.m_curLegacyData.legacyCfg
  if not legacyCfg then
    return
  end
  local lv = self.m_curLegacyServerData.iLevel
  local legacyLevelCfg = self.m_legacyLvCfgList[lv]
  for i = 1, MaxLegacySkillNum do
    local skillID = legacyCfg["m_Skillgroup" .. i]
    if skillID and skillID ~= 0 then
      local skillCfg = SkillIns:GetValue_BySkillID(skillID)
      if skillCfg:GetError() ~= true then
        local isLock = true
        local skillLevel = 0
        if legacyLevelCfg and legacyLevelCfg:GetError() ~= true then
          skillLevel = legacyLevelCfg["m_SkillLevel" .. i]
          if skillLevel and 0 < skillLevel then
            isLock = false
          end
        end
        local tempSkillItem = {
          skillID = skillID,
          skillCfg = skillCfg,
          isLock = isLock,
          skillLv = skillLevel
        }
        self.m_legacySkillDataList[#self.m_legacySkillDataList + 1] = tempSkillItem
      end
    end
  end
end

function UILegacyItem:InitShowAttr()
  local propertyAllCfg = PropertyIndexIns:GetAll()
  for _, tempCfg in pairs(propertyAllCfg) do
    if AttrBaseShowCfg[tempCfg.m_PropertyID] == true then
      self.m_showAttrBaseCfgList[tempCfg.m_PropertyID] = tempCfg
    end
  end
  for _, v in ipairs(self.m_showAttrBaseCfgList) do
    local attrItemRoot
    if #self.m_showAttrBaseItems == 0 then
      attrItemRoot = self.m_attr_item_base.transform
    else
      attrItemRoot = GameObject.Instantiate(self.m_attr_item_base, self.m_attr_base_root_trans).transform
    end
    UILuaHelper.SetActive(attrItemRoot, true)
    local attrNumText = attrItemRoot:Find("c_txt_num_attr"):GetComponent(T_TextMeshProUGUI)
    local attrIconImg = attrItemRoot:Find("c_icon_attr"):GetComponent(T_Image)
    local attrItem = {
      itemRoot = attrItemRoot,
      attrNumText = attrNumText,
      attrIconImg = attrIconImg,
      propertyCfg = v
    }
    UILuaHelper.SetAtlasSprite(attrIconImg, v.m_PropertyIcon .. "_02")
    self.m_showAttrBaseItems[#self.m_showAttrBaseItems + 1] = attrItem
  end
end

function UILegacyItem:FreshItemUI()
  self:FreshLegacyBaseInfo()
  self:FreshLegacySkillShow()
  self:FreshLegacyAttr()
end

function UILegacyItem:FreshLegacyBaseInfo()
  if not self.m_curLegacyCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_legacy_icon_Image, self.m_curLegacyCfg.m_Icon)
  self.m_txt_legacytitle_Text.text = self.m_curLegacyCfg.m_mName
  local equipHeroIDList = self.m_curLegacyServerData.vEquipBy
  local useNum = equipHeroIDList and #equipHeroIDList or 0
  local maxNum = self.m_curLegacyLvCfg.m_Wearable
  self.m_txt_person_item_num_Text.text = useNum .. "/" .. maxNum
  self.m_isFull = useNum >= maxNum
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_curLegacyID,
    iNum = 0
  }, self.m_curLegacyServerData)
  self.m_itemWidget:SetItemInfo(processItemData)
end

function UILegacyItem:FreshLegacySkillShow()
  if not self.m_legacySkillDataList then
    return
  end
  for i = 1, MaxLegacySkillNum do
    local legacySkillData = self.m_legacySkillDataList[i]
    local legacyIconWidget = self.m_legacyIconWidgets[i]
    UILuaHelper.SetActive(self["m_img_skill_none" .. i], legacySkillData == nil)
    if legacySkillData then
      if legacyIconWidget == nil then
        local newRoot = GameObject.Instantiate(self.m_legacy_item_skill_item, self["m_item_legacy_skill" .. i].transform).transform
        legacyIconWidget = self:createLegacySkillIcon(newRoot)
        self.m_legacyIconWidgets[i] = legacyIconWidget
        legacyIconWidget:SetItemClickBack(function()
          self:OnLegacySkillIconClk(i)
        end)
      end
      legacyIconWidget:FreshSkillInfo(legacySkillData.skillID, legacySkillData.skillLv)
      legacyIconWidget:FreshSkillIsLock(legacySkillData.isLock)
      legacyIconWidget:SetActive(true)
    elseif legacyIconWidget then
      legacyIconWidget:SetActive(false)
    end
  end
end

function UILegacyItem:FreshLegacyAttr()
  if not self.m_showAttrBaseItems then
    return
  end
  local legacyAttrTab = self.m_heroAttr:GetLegacyAttr(self.m_curLegacyID, self.m_curLegacyLv)
  for _, attrItem in ipairs(self.m_showAttrBaseItems) do
    local serverAttrValue = legacyAttrTab[attrItem.propertyCfg.m_ENName] or 0
    attrItem.attrNumText.text = BigNumFormat(serverAttrValue)
  end
end

function UILegacyItem:OnBtnWearClicked()
  if not self.m_curLegacyData then
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex, self.m_isFull)
  end
end

function UILegacyItem:OnBtngoClicked()
  QuickOpenFuncUtil:OpenFunc(1903)
  self:broadcastEvent("eGameEvent_Hero_Jump")
end

function UILegacyItem:OnLegacyItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function UILegacyItem:OnLegacySkillIconClk(index)
  if not index then
    return
  end
  local legacySkillData = self.m_legacySkillDataList[index]
  if not legacySkillData then
    return
  end
  local skillWid = self.m_legacyIconWidgets[index]
  if not skillWid then
    return
  end
  local rootTrans = skillWid:GetRootTrans()
  utils.openLegacySkillTips(self.m_curLegacyID, self.m_curLegacyLv, legacySkillData.skillID, rootTrans, {x = 0, y = 0.5}, {x = 30, y = 0})
end

return UILegacyItem
