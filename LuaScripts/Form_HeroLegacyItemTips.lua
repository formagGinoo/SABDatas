local Form_HeroLegacyItemTips = class("Form_HeroLegacyItemTips", require("UI/UIFrames/Form_HeroLegacyItemTipsUI"))
local SkillIns = ConfigManager:GetConfigInsByName("Skill")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local MaxLegacySkillNum = LegacyManager.MaxLegacySkillNum

function Form_HeroLegacyItemTips:SetInitParam(param)
end

function Form_HeroLegacyItemTips:AfterInit()
  self.super.AfterInit(self)
  self.m_curLegacyShowData = nil
  self.m_curLegacyCfg = nil
  self.m_curLegacyID = nil
  self.m_curLegacyLv = nil
  self.m_legacySkillDataList = {}
  self.m_legacyLvCfgList = {}
  self.m_curLegacyLvCfg = nil
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_attr_base_root_trans = self.m_attr_base_root.transform
  self.m_showAttrBaseCfgList = {}
  self.m_showAttrBaseItems = {}
  self:InitShowAttr()
  self.m_legacyIconWidgets = {}
  local tempLegacyIcon = self:createLegacySkillIcon(self.m_legacy_skill_item)
  self.m_legacyIconWidgets[1] = tempLegacyIcon
  tempLegacyIcon:SetItemClickBack(function()
    self:OnLegacySkillIconClk(1)
  end)
  self.m_itemWidget = self:createCommonItem(self.m_common_item)
  self.m_closeCallBackFun = nil
end

function Form_HeroLegacyItemTips:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  self:CheckRegisterRedDot()
end

function Form_HeroLegacyItemTips:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
  self:UnRegisterAllRedDotItem()
end

function Form_HeroLegacyItemTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroLegacyItemTips:CheckRegisterRedDot()
  if self.m_curLegacyShowData then
    self:RegisterOrUpdateRedDotItem(self.m_legacy_upgrade_red_dot, RedDotDefine.ModuleType.LegacyUp, self.m_curLegacyID)
  end
end

function Form_HeroLegacyItemTips:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curLegacyID = tParam.legacyID
    self.m_curLegacyCfg = LegacyManager:GetLegacyCfgByID(self.m_curLegacyID)
    local tempLegacyData = LegacyManager:GetLegacyDataByID(self.m_curLegacyID) or {}
    self.m_curLegacyShowData = tempLegacyData.serverData
    if self.m_curLegacyShowData then
      self:FreshLegacyLvList()
      self.m_curLegacyLv = self.m_curLegacyShowData.iLevel
      self.m_curLegacyLvCfg = self.m_legacyLvCfgList[self.m_curLegacyLv]
      self:FreshLegacySkillData()
      self.m_closeCallBackFun = tParam.callBackFun
    else
      self:FreshLegacyLvList()
      self.m_curLegacyLv = 1
      self.m_curLegacyLvCfg = self.m_legacyLvCfgList[self.m_curLegacyLv]
      self:FreshLegacySkillData()
      self.m_closeCallBackFun = tParam.callBackFun
    end
    self.m_csui.m_param = nil
  end
end

function Form_HeroLegacyItemTips:FreshLegacyLvList()
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

function Form_HeroLegacyItemTips:FreshLegacySkillData()
  self.m_legacySkillDataList = {}
  local legacyCfg = self.m_curLegacyCfg
  if not legacyCfg then
    return
  end
  local legacyLevelCfg = self.m_curLegacyLvCfg
  for i = 1, MaxLegacySkillNum do
    local skillID = legacyCfg["m_Skillgroup" .. i]
    if skillID and skillID ~= 0 then
      local skillCfg = SkillIns:GetValue_BySkillID(skillID)
      if skillCfg:GetError() ~= true then
        local isLock = true
        local skillLevel = 0
        if self.m_curLegacyShowData and legacyLevelCfg and legacyLevelCfg:GetError() ~= true then
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

function Form_HeroLegacyItemTips:ClearCacheData()
end

function Form_HeroLegacyItemTips:AddEventListeners()
  self:addEventListener("eGameEvent_Legacy_Upgrade", handler(self, self.OnLegacyUpgrade))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnItemJump))
end

function Form_HeroLegacyItemTips:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroLegacyItemTips:OnLegacyUpgrade(param)
  if param.legacyID == self.m_curLegacyID then
    self.m_curLegacyShowData = LegacyManager:GetLegacyDataByID(self.m_curLegacyID).serverData
    if self.m_curLegacyShowData then
      self:FreshLegacyLvList()
      self.m_curLegacyLv = self.m_curLegacyShowData.iLevel
      self.m_curLegacyLvCfg = self.m_legacyLvCfgList[self.m_curLegacyLv]
      self:FreshLegacySkillData()
      self:FreshUI()
    end
  end
end

function Form_HeroLegacyItemTips:OnItemJump()
  self:CloseForm()
end

function Form_HeroLegacyItemTips:InitShowAttr()
  local propertyAllCfg = PropertyIndexIns:GetAll()
  for _, tempCfg in pairs(propertyAllCfg) do
    if AttrBaseShowCfg[tempCfg.m_PropertyID] == true then
      self.m_showAttrBaseCfgList[tempCfg.m_PropertyID] = tempCfg
    end
  end
  for _, v in ipairs(self.m_showAttrBaseCfgList) do
    local attrItemRoot
    if #self.m_showAttrBaseItems == 0 then
      attrItemRoot = self.m_attributes_item_base.transform
    else
      attrItemRoot = GameObject.Instantiate(self.m_attributes_item_base, self.m_attr_base_root_trans).transform
    end
    UILuaHelper.SetActive(attrItemRoot, true)
    local attrNumText = attrItemRoot:Find("c_txt_num"):GetComponent(T_TextMeshProUGUI)
    local attrIconImg = attrItemRoot:Find("c_icon"):GetComponent(T_Image)
    local attrNameText = attrItemRoot:Find("c_txt_sx_name"):GetComponent(T_TextMeshProUGUI)
    local attrItem = {
      itemRoot = attrItemRoot,
      attrNumText = attrNumText,
      attrIconImg = attrIconImg,
      attrNameText = attrNameText,
      propertyCfg = v
    }
    attrNameText.text = v.m_mCNName
    UILuaHelper.SetAtlasSprite(attrIconImg, v.m_PropertyIcon .. "_02")
    self.m_showAttrBaseItems[#self.m_showAttrBaseItems + 1] = attrItem
  end
end

function Form_HeroLegacyItemTips:FreshUI()
  self:FreshLegacyBaseInfo()
  self:FreshLegacySkillShow()
  UILuaHelper.SetActive(self.m_attr_base_root, true)
  UILuaHelper.SetActive(self.m_pnl_skill, true)
  if self.m_curLegacyShowData then
    UILuaHelper.SetActive(self.m_pnl_num, true)
    UILuaHelper.SetActive(self.m_z_txt_maxnum, true)
    UILuaHelper.SetActive(self.m_btn_upgrade, true)
    UILuaHelper.SetActive(self.m_z_txt_legacy_none, false)
    self:FreshLegacyAttr(self.m_curLegacyShowData.iLevel)
    self:FreshUpgradeStatus()
  else
    UILuaHelper.SetActive(self.m_pnl_num, false)
    UILuaHelper.SetActive(self.m_z_txt_maxnum, false)
    UILuaHelper.SetActive(self.m_btn_upgrade, false)
    UILuaHelper.SetActive(self.m_z_txt_legacy_none, true)
    self:FreshLegacyAttr(self.m_curLegacyLv)
  end
end

function Form_HeroLegacyItemTips:FreshLegacyBaseInfo()
  if not self.m_curLegacyCfg then
    return
  end
  self.m_txt_name_Text.text = self.m_curLegacyCfg.m_mName
  local itemShowLegacy
  if self.m_curLegacyShowData then
    local equipHeroIDList = self.m_curLegacyShowData.vEquipBy
    local useNum = equipHeroIDList and #equipHeroIDList or 0
    local maxNum = self.m_curLegacyLvCfg.m_Wearable
    self.m_txt_person_num_Text.text = useNum .. "/" .. maxNum
    itemShowLegacy = self.m_curLegacyShowData
  end
  local processData = ResourceUtil:GetProcessRewardData({
    iID = self.m_curLegacyID,
    iNum = 0
  }, itemShowLegacy or {})
  self.m_itemWidget:SetItemInfo(processData)
  self:RefreshDesc()
end

function Form_HeroLegacyItemTips:FreshLegacySkillShow()
  if not self.m_legacySkillDataList then
    return
  end
  for i = 1, LegacyManager.MaxLegacySkillNum do
    local legacySkillData = self.m_legacySkillDataList[i]
    local legacyIconWidget = self.m_legacyIconWidgets[i]
    UILuaHelper.SetActive(self["m_img_none" .. i], legacySkillData == nil)
    if legacySkillData then
      if legacyIconWidget == nil then
        local newRoot = GameObject.Instantiate(self.m_legacy_skill_item, self["m_legacy_skill" .. i].transform).transform
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

function Form_HeroLegacyItemTips:FreshLegacyAttr(lv)
  if not self.m_showAttrBaseItems then
    return
  end
  local legacyAttrTab = self.m_heroAttr:GetLegacyAttr(self.m_curLegacyID, lv)
  for _, attrItem in ipairs(self.m_showAttrBaseItems) do
    local serverAttrValue = legacyAttrTab[attrItem.propertyCfg.m_ENName] or 0
    attrItem.attrNumText.text = BigNumFormat(serverAttrValue)
  end
end

function Form_HeroLegacyItemTips:FreshUpgradeStatus()
  local maxNum = #self.m_legacyLvCfgList
  local isMax = maxNum <= self.m_curLegacyLv
  UILuaHelper.SetActive(self.m_btn_upgrade, not isMax)
  UILuaHelper.SetActive(self.m_z_txt_maxnum, isMax)
end

function Form_HeroLegacyItemTips:RefreshDesc(showAll)
  self.m_pnl_des:SetActive(true)
  if showAll then
    self.m_txt_desc2_Text.text = self.m_curLegacyCfg.m_mDesc
    self.m_img_arrow:SetActive(true)
    self.m_txt_desc:SetActive(false)
    self.m_txt_desc2:SetActive(true)
  else
    self.m_txt_desc_Text.text = self.m_curLegacyCfg.m_mDesc
    self.m_txt_desc:SetActive(true)
    self.m_txt_desc2:SetActive(false)
    self.m_img_arrow:SetActive(false)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_scroll_content)
end

function Form_HeroLegacyItemTips:OnBtnCloseClicked()
  self:CloseForm()
  if self.m_closeCallBackFun then
    self.m_closeCallBackFun()
  end
end

function Form_HeroLegacyItemTips:OnBtnReturnClicked()
  self:CloseForm()
  if self.m_closeCallBackFun then
    self.m_closeCallBackFun()
  end
end

function Form_HeroLegacyItemTips:OnLegacySkillIconClk(index)
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
  utils.openLegacySkillTips(self.m_curLegacyID, self.m_curLegacyLv, legacySkillData.skillID, rootTrans, {x = 0.5, y = 1})
end

function Form_HeroLegacyItemTips:OnBtnupgradeClicked()
  if not self.m_curLegacyShowData then
    return
  end
  local legacyData = LegacyManager:GetLegacyDataByID(self.m_curLegacyID)
  StackPopup:Push(UIDefines.ID_FORM_HEROLEGACYUPGRADE, {legacyData = legacyData})
end

function Form_HeroLegacyItemTips:OnTxtdescClicked()
  self:RefreshDesc(true)
end

function Form_HeroLegacyItemTips:OnTxtdesc2Clicked()
  self:RefreshDesc(false)
end

function Form_HeroLegacyItemTips:OnBtnarrowClicked()
  self:RefreshDesc(true)
end

function Form_HeroLegacyItemTips:OnImgarrowClicked()
  self:RefreshDesc(false)
end

function Form_HeroLegacyItemTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroLegacyItemTips", Form_HeroLegacyItemTips)
return Form_HeroLegacyItemTips
