local Form_HeroLegacyChange = class("Form_HeroLegacyChange", require("UI/UIFrames/Form_HeroLegacyChangeUI"))
local SkillIns = ConfigManager:GetConfigInsByName("Skill")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local AttrBaseShowCfg = _ENV.AttrBaseShowCfg
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local MaxLegacySkillNum = LegacyManager.MaxLegacySkillNum

function Form_HeroLegacyChange:SetInitParam(param)
end

function Form_HeroLegacyChange:AfterInit()
  self.super.AfterInit(self)
  self.m_curShowHeroData = nil
  self.m_curLegacyData = nil
  self.m_curLegacyCfg = nil
  self.m_curLegacyID = nil
  self.m_curLegacyLv = nil
  self.m_legacySkillDataList = {}
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
  self.m_showChangeHeroDataList = {}
  local initGridData = {
    itemClkBackFun = handler(self, self.OnLegacyChangeHeroItemClick)
  }
  self.m_luaLegacyListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_list_InfinityGrid, "Legacy/UILegacyChangeHeroItem", initGridData)
  self.m_itemWidget = self:createCommonItem(self.m_legacy_item)
  self.m_initTimer = {}
end

function Form_HeroLegacyChange:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_HeroLegacyChange:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_HeroLegacyChange:OnDestroy()
  self.super.OnDestroy(self)
  for i, v in pairs(self.m_initTimer) do
    if v then
      TimeService:KillTimer(v)
    end
  end
  self.m_initTimer = {}
end

function Form_HeroLegacyChange:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curShowHeroData = tParam.heroData
    self.m_curLegacyData = tParam.legacyData
    if self.m_curLegacyData then
      self.m_curLegacyID = self.m_curLegacyData.serverData.iLegacyId
      self.m_curLegacyCfg = self.m_curLegacyData.legacyCfg
      self.m_curLegacyLv = self.m_curLegacyData.serverData.iLevel
      self.m_curLegacyLvCfg = LegacyLevelIns:GetValue_ByIDAndLevel(self.m_curLegacyID, self.m_curLegacyLv)
      self:FreshLegacySkillData()
      self:FreshChangeHeroDataList()
    end
    self.m_csui.m_param = nil
  end
end

function Form_HeroLegacyChange:FreshLegacySkillData()
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
  local legacyLevelCfg = self.m_curLegacyLvCfg
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

function Form_HeroLegacyChange:FreshChangeHeroDataList()
  if not self.m_curLegacyData then
    return
  end
  local heroIDList = self.m_curLegacyData.serverData.vEquipBy
  self.m_showChangeHeroDataList = {}
  for _, heroID in ipairs(heroIDList) do
    local tempHeroData = HeroManager:GetHeroDataByID(heroID)
    if tempHeroData then
      self.m_showChangeHeroDataList[#self.m_showChangeHeroDataList + 1] = tempHeroData
    end
  end
end

function Form_HeroLegacyChange:ClearCacheData()
end

function Form_HeroLegacyChange:AddEventListeners()
  self:addEventListener("eGameEvent_Legacy_Swap", handler(self, self.OnLegacySwap))
end

function Form_HeroLegacyChange:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroLegacyChange:OnLegacySwap(param)
  if param.dstHeroID == self.m_curShowHeroData.serverData.iHeroId then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40031)
    self:CloseForm()
  end
end

function Form_HeroLegacyChange:InitShowAttr()
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

function Form_HeroLegacyChange:FreshUI()
  if not self.m_curLegacyData then
    return
  end
  self:FreshLegacyBaseInfo()
  self:FreshLegacySkillShow()
  self:FreshLegacyAttr()
  self:FreshChangeHeroListShow()
  self:CheckShowListAnim()
end

function Form_HeroLegacyChange:FreshLegacyBaseInfo()
  if not self.m_curLegacyCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_legacy_icon_Image, self.m_curLegacyCfg.m_Icon)
  self.m_txt_legacytitle_Text.text = self.m_curLegacyCfg.m_mName
  local equipHeroIDList = self.m_curLegacyData.serverData.vEquipBy
  local useNum = equipHeroIDList and #equipHeroIDList or 0
  local maxNum = self.m_curLegacyLvCfg.m_Wearable
  self.m_txt_person_item_num_Text.text = useNum .. "/" .. maxNum
  local processData = ResourceUtil:GetProcessRewardData({
    iID = self.m_curLegacyID,
    iNum = 0
  }, self.m_curLegacyData.serverData)
  self.m_itemWidget:SetItemInfo(processData)
end

function Form_HeroLegacyChange:FreshLegacySkillShow()
  if not self.m_legacySkillDataList then
    return
  end
  for i = 1, LegacyManager.MaxLegacySkillNum do
    local legacySkillData = self.m_legacySkillDataList[i]
    local legacyIconWidget = self.m_legacyIconWidgets[i]
    UILuaHelper.SetActive(self["m_img_skill_none" .. i], legacySkillData == nil)
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

function Form_HeroLegacyChange:FreshLegacyAttr()
  if not self.m_showAttrBaseItems then
    return
  end
  local legacyAttrTab = self.m_heroAttr:GetLegacyAttr(self.m_curLegacyID, self.m_curLegacyData.serverData.iLevel)
  for _, attrItem in ipairs(self.m_showAttrBaseItems) do
    local serverAttrValue = legacyAttrTab[attrItem.propertyCfg.m_ENName] or 0
    attrItem.attrNumText.text = BigNumFormat(serverAttrValue)
  end
end

function Form_HeroLegacyChange:FreshChangeHeroListShow()
  if not next(self.m_showChangeHeroDataList) then
    return
  end
  self.m_luaLegacyListInfinityGrid:ShowItemList(self.m_showChangeHeroDataList)
  self.m_luaLegacyListInfinityGrid:LocateTo()
end

function Form_HeroLegacyChange:CheckShowListAnim()
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

function Form_HeroLegacyChange:ShowListAnim()
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

function Form_HeroLegacyChange:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_HeroLegacyChange:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_HeroLegacyChange:OnLegacySkillIconClk(index)
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
  utils.openLegacySkillTips(self.m_curLegacyID, self.m_curLegacyLv, legacySkillData.skillID, rootTrans, {x = 0, y = 0.5}, {x = -5, y = 0})
end

function Form_HeroLegacyChange:OnLegacyChangeHeroItemClick(itemIndex)
  if not itemIndex then
    return
  end
  local heroData = self.m_showChangeHeroDataList[itemIndex]
  if not heroData then
    return
  end
  LegacyManager:ReqLegacySwap(heroData.serverData.iHeroId, self.m_curShowHeroData.serverData.iHeroId, self.m_curLegacyID)
end

function Form_HeroLegacyChange:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroLegacyChange", Form_HeroLegacyChange)
return Form_HeroLegacyChange
