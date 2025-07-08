local Form_HeroLegacyManage = class("Form_HeroLegacyManage", require("UI/UIFrames/Form_HeroLegacyManageUI"))
local SkillIns = ConfigManager:GetConfigInsByName("Skill")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local MaxLegacySkillNum = LegacyManager.MaxLegacySkillNum
local DefaultSort = false
local TipsParams = {
  [1] = {
    pivot = {x = 1, y = 0.5},
    offset = {x = 0, y = 0}
  },
  [2] = {
    pivot = {x = 1, y = 0.5},
    offset = {x = 0, y = 0}
  },
  [3] = {
    pivot = {x = 1, y = 0.5},
    offset = {x = 0, y = 0}
  }
}

function Form_HeroLegacyManage:SetInitParam(param)
end

function Form_HeroLegacyManage:AfterInit()
  self.super.AfterInit(self)
  self.m_curShowHeroData = nil
  self.m_curLegacyData = nil
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
    self:OnLegacyIconClk(1)
  end)
  self.m_legacyDataList = nil
  self.m_isSortRevert = true
  local initGridData = {
    itemClkBackFun = handler(self, self.OnLegacyItemClick)
  }
  self.m_luaLegacyListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_list_InfinityGrid, "Legacy/UILegacyItem", initGridData)
  self.m_itemWidget = self:createCommonItem(self.m_item_legacy_icon)
  self.m_initTimer = {}
end

function Form_HeroLegacyManage:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_HeroLegacyManage:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_HeroLegacyManage:OnDestroy()
  self.super.OnDestroy(self)
  for i, v in pairs(self.m_initTimer) do
    if v then
      TimeService:KillTimer(v)
    end
  end
  self.m_initTimer = {}
end

function Form_HeroLegacyManage:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curShowHeroData = tParam.heroData
    self.m_curLegacyData = tParam.legacyData
    if self.m_curLegacyData then
      self.m_curLegacyID = self.m_curLegacyData.serverData.iLegacyId
      self.m_curLegacyCfg = self.m_curLegacyData.legacyCfg
      self:FreshLegacyLvList()
      self.m_curLegacyLv = self.m_curLegacyData.serverData.iLevel
      self.m_curLegacyLvCfg = self.m_legacyLvCfgList[self.m_curLegacyLv]
      self:FreshLegacySkillData()
    else
      self.m_curLegacyID = nil
      self.m_curLegacyCfg = nil
      self.m_legacyLvCfgList = nil
      self.m_curLegacyLv = nil
      self.m_curLegacyLvCfg = nil
      self.m_legacySkillDataList = nil
    end
    self.m_csui.m_param = nil
  end
end

function Form_HeroLegacyManage:FreshLegacyLvList()
  if not self.m_curLegacyID then
    return
  end
  local legacyDic = LegacyLevelIns:GetValue_ByID(self.m_curLegacyID)
  if not legacyDic then
    return
  end
  self.m_legacyLvCfgList = {}
  for _, v in pairs(legacyDic) do
    self.m_legacyLvCfgList[v.m_Level] = v
  end
end

function Form_HeroLegacyManage:FreshLegacySkillData()
  self.m_legacySkillDataList = {}
  if not self.m_curLegacyData then
    return
  end
  local legacyCfg = self.m_curLegacyData.legacyCfg
  if not legacyCfg then
    return
  end
  local lv = self.m_curLegacyData.serverData.iLevel
  if not lv then
    return
  end
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

function Form_HeroLegacyManage:ClearCacheData()
end

function Form_HeroLegacyManage:AddEventListeners()
  self:addEventListener("eGameEvent_Legacy_Install", handler(self, self.OnLegacyInstall))
  self:addEventListener("eGameEvent_Legacy_UnInstall", handler(self, self.OnLegacyUnInstall))
  self:addEventListener("eGameEvent_Legacy_Swap", handler(self, self.OnLegacySwap))
  self:addEventListener("eGameEvent_Legacy_Upgrade", handler(self, self.OnLegacyUpgrade))
end

function Form_HeroLegacyManage:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroLegacyManage:OnLegacyInstall(param)
  if param.heroID == self.m_curShowHeroData.serverData.iHeroId then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40031)
    self:CloseForm()
  end
end

function Form_HeroLegacyManage:OnLegacyUnInstall(param)
  if param.heroID == self.m_curShowHeroData.serverData.iHeroId then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40030)
    self:CloseForm()
  end
end

function Form_HeroLegacyManage:OnLegacySwap(param)
  if param.dstHeroID == self.m_curShowHeroData.serverData.iHeroId then
    local legacyID = self.m_curShowHeroData.serverData.stLegacy.iLegacyId
    self.m_curLegacyData = LegacyManager:GetLegacyDataByID(legacyID)
    if self.m_curLegacyData then
      self.m_curLegacyID = self.m_curLegacyData.serverData.iLegacyId
      self.m_curLegacyCfg = self.m_curLegacyData.legacyCfg
      self:FreshLegacyLvList()
      self.m_curLegacyLv = self.m_curLegacyData.serverData.iLevel
      self.m_curLegacyLvCfg = self.m_legacyLvCfgList[self.m_curLegacyLv]
      self:FreshLegacySkillData()
    end
    self:FreshUI()
  end
end

function Form_HeroLegacyManage:OnLegacyUpgrade(param)
  local showItemDic = self.m_luaLegacyListInfinityGrid:GetAllShownItem()
  for _, v in pairs(showItemDic) do
    if v.m_itemData and v.m_itemData.serverData and v.m_itemData.serverData.iLegacyId == param.legacyID then
      v:FreshData(v.m_itemData, v.m_itemIndex)
    end
  end
end

function Form_HeroLegacyManage:InitShowAttr()
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

function Form_HeroLegacyManage:FreshUI()
  UILuaHelper.SetActive(self.m_pnl_legacy, self.m_curLegacyData ~= nil)
  UILuaHelper.SetActive(self.m_img_listnone, self.m_curLegacyData == nil)
  if self.m_curLegacyData then
    self:FreshLegacyBaseInfo()
    self:FreshLegacySkillShow()
    self:FreshLegacyAttr()
  end
  self.m_legacyDataList = self:GetLegacyShowList(self.m_curLegacyID)
  if self.m_isSortRevert == nil then
    self.m_isSortRevert = DefaultSort
  end
  self:OnSortChange()
  self:CheckShowListAnim()
end

function Form_HeroLegacyManage:GetLegacyShowList(excludeID)
  local legacyDataList = {}
  local legacyIns = ConfigManager:GetConfigInsByName("Legacy")
  local legacyAllCfg = legacyIns:GetAll()
  for i, v in pairs(legacyAllCfg) do
    local chapterCfg = LegacyLevelManager:GetChapterConfigByID(v.m_LegacyChapterID)
    if v.m_ID ~= excludeID and chapterCfg then
      local legacyData = LegacyManager:GetLegacyDataByID(v.m_ID)
      if legacyData then
        legacyDataList[#legacyDataList + 1] = legacyData
      else
        legacyDataList[#legacyDataList + 1] = {legacyCfg = v}
      end
    end
  end
  return legacyDataList
end

function Form_HeroLegacyManage:FreshLegacyBaseInfo()
  if not self.m_curLegacyCfg then
    return
  end
  local equipHeroIDList = self.m_curLegacyData.serverData.vEquipBy
  local useNum = equipHeroIDList and #equipHeroIDList or 0
  local maxNum = self.m_curLegacyLvCfg.m_Wearable
  self.m_txt_person_num_Text.text = useNum .. "/" .. maxNum
  local processData = ResourceUtil:GetProcessRewardData({
    iID = self.m_curLegacyID,
    iNum = 0
  }, self.m_curLegacyData.serverData or {})
  self.m_itemWidget:SetItemInfo(processData)
end

function Form_HeroLegacyManage:FreshLegacySkillShow()
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
          self:OnLegacyIconClk(i)
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

function Form_HeroLegacyManage:FreshLegacyAttr()
  if not self.m_showAttrBaseItems then
    return
  end
  local legacyAttrTab = self.m_heroAttr:GetLegacyAttr(self.m_curLegacyID, self.m_curLegacyData.serverData.iLevel)
  for _, attrItem in ipairs(self.m_showAttrBaseItems) do
    local serverAttrValue = legacyAttrTab[attrItem.propertyCfg.m_ENName] or 0
    attrItem.attrNumText.text = BigNumFormat(serverAttrValue)
  end
end

function Form_HeroLegacyManage:OnSortChange()
  local isRevert = self.m_isSortRevert
  table.sort(self.m_legacyDataList, function(a, b)
    local sortA = a.serverData ~= nil and 1 or 0
    local sortB = b.serverData ~= nil and 1 or 0
    if sortA == sortB then
      if a.serverData and b.serverData then
        local levelA = a.serverData.iLevel
        local levelB = b.serverData.iLevel
        if levelA ~= levelB then
          if isRevert then
            return levelA < levelB
          else
            return levelA > levelB
          end
        end
      else
        return a.legacyCfg.m_ID < b.legacyCfg.m_ID
      end
    else
      return sortA > sortB
    end
  end)
  self.m_luaLegacyListInfinityGrid:ShowItemList(self.m_legacyDataList)
  UILuaHelper.SetActive(self.m_img_arrow_up, self.m_isSortRevert)
  UILuaHelper.SetActive(self.m_img_arrow_down, not self.m_isSortRevert)
  UILuaHelper.SetActive(self.m_empty, #self.m_legacyDataList <= 0)
end

function Form_HeroLegacyManage:CheckShowListAnim()
  if not self.m_luaLegacyListInfinityGrid then
    return
  end
  local itemList = self.m_luaLegacyListInfinityGrid:GetAllShownItemList()
  for i, tempHeroItem in ipairs(itemList) do
    local tempObj = tempHeroItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
  end
  TimeService:SetTimer(self.m_uiVariables.ListAnimDelayTime, 1, function()
    self:ShowListAnim()
  end)
end

function Form_HeroLegacyManage:ShowListAnim()
  local allShownItemList = self.m_luaLegacyListInfinityGrid:GetAllShownItemList()
  for i, tempHeroItem in ipairs(allShownItemList) do
    local tempObj = tempHeroItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    if i == 1 then
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, self.m_uiVariables.ItemInAnimStr)
    else
      do
        local leftIndex = i - 1
        self.m_initTimer[leftIndex] = TimeService:SetTimer(leftIndex * self.m_uiVariables.ItemDurationTime, 1, function()
          UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
          UILuaHelper.PlayAnimationByName(tempObj, self.m_uiVariables.ItemInAnimStr)
          self.m_initTimer[leftIndex] = nil
        end)
      end
    end
  end
end

function Form_HeroLegacyManage:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_HeroLegacyManage:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_HeroLegacyManage:OnLegacyIconClk(skillIndex)
  if not skillIndex then
    return
  end
  local legacySkillData = self.m_legacySkillDataList[skillIndex]
  if not legacySkillData then
    return
  end
  local skillWid = self.m_legacyIconWidgets[skillIndex]
  if not skillWid then
    return
  end
  local showParam = TipsParams[skillIndex]
  local rootTrans = skillWid:GetRootTrans()
  utils.openLegacySkillTips(self.m_curLegacyID, self.m_curLegacyLv, legacySkillData.skillID, rootTrans, showParam.pivot, showParam.offset)
end

function Form_HeroLegacyManage:OnLegacyItemClick(itemIndex, isFull)
  if not itemIndex then
    return
  end
  local legacyData = self.m_legacyDataList[itemIndex]
  if not legacyData then
    return
  end
  local legacyID = legacyData.serverData.iLegacyId
  if isFull then
    StackFlow:Push(UIDefines.ID_FORM_HEROLEGACYCHANGE, {
      heroData = self.m_curShowHeroData,
      legacyData = legacyData
    })
  else
    LegacyManager:ReqLegacyInstall(self.m_curShowHeroData.serverData.iHeroId, legacyID)
  end
end

function Form_HeroLegacyManage:OnBtnrelieveClicked()
  if not self.m_curLegacyData then
    return
  end
  LegacyManager:ReqLegacyUninstall(self.m_curShowHeroData.serverData.iHeroId)
end

function Form_HeroLegacyManage:OnBtnleveltouchClicked()
  self.m_isSortRevert = not self.m_isSortRevert
  self:OnSortChange()
end

function Form_HeroLegacyManage:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroLegacyManage", Form_HeroLegacyManage)
return Form_HeroLegacyManage
