local Form_ActivityMinigame108Assemble = class("Form_ActivityMinigame108Assemble", require("UI/UIFrames/Form_ActivityMinigame108AssembleUI"))

function Form_ActivityMinigame108Assemble:SetInitParam(param)
end

local EquipType = {
  HEAD = 1,
  CORN = 2,
  LEG = 3,
  ENGINE = 4
}
local MapBgDic = {
  [1] = {
    "activity108minigame_bg_grassland01",
    "activity108minigame_bg_grassland02"
  },
  [2] = {
    "activity108minigame_bg_wilderness01",
    "activity108minigame_bg_wilderness02"
  },
  [3] = {
    "activity108minigame_bg_snowfield01",
    "activity108minigame_bg_snowfield02"
  }
}

function Form_ActivityMinigame108Assemble:GetEquipConfigData(type)
  local data = {}
  local allEquipCfg = self.AssembleTb:GetAll()
  for _, v in pairs(allEquipCfg) do
    if v.m_Type == type then
      table.insert(data, v)
    end
  end
  return data
end

function Form_ActivityMinigame108Assemble:GetEquipListData(vItem, equipType)
  local result = {}
  for i = 1, #vItem do
    local id = vItem[i].iID
    local data = {}
    data.id = id
    data.cfg = self.AssembleTb:GetValue_ByEquipmentID(id)
    data.num = vItem[i].iNum
    data.is_select = false
    if data.cfg.m_Type == equipType then
      table.insert(result, data)
    end
  end
  return result
end

function Form_ActivityMinigame108Assemble:AfterInit()
  self.super.AfterInit(self)
  self.AssembleTb = ConfigManager:GetConfigInsByName("MiniGame108Equipment")
  self.myProperty1 = {
    0,
    0,
    0,
    0
  }
  self.myProperty2 = {
    0,
    0,
    0,
    0
  }
  self.myProperty3 = {
    0,
    0,
    0,
    0
  }
  self.myProperty4 = {
    0,
    0,
    0,
    0
  }
  self.myProperty = {
    0,
    0,
    0,
    0
  }
  self.curTabIndex = 0
  self.tabButtons = {}
  table.insert(self.tabButtons, self.m_btn_head)
  table.insert(self.tabButtons, self.m_btn_corn)
  table.insert(self.tabButtons, self.m_btn_leg)
  table.insert(self.tabButtons, self.m_btn_engine)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk, nil, handler(self, self.OnBackHome)))
  local initGridData = {
    OnItemClk = function(m_itemData, m_itemIndex, is_select)
      self:OnItemClk(m_itemData, m_itemIndex, is_select)
    end
  }
  self.m_Grid1 = self:CreateInfinityGrid(self.m_scrollView1_InfinityGrid, "ActivityMinigame108/Minigame108AssembleItem", initGridData)
  self.m_Grid2 = self:CreateInfinityGrid(self.m_scrollView2_InfinityGrid, "ActivityMinigame108/Minigame108AssembleItem", initGridData)
  self.m_Grid3 = self:CreateInfinityGrid(self.m_scrollView3_InfinityGrid, "ActivityMinigame108/Minigame108AssembleItem", initGridData)
  self.m_Grid4 = self:CreateInfinityGrid(self.m_scrollView4_InfinityGrid, "ActivityMinigame108/Minigame108AssembleItem", initGridData)
  self.m_SpiderSpine = self.m_img_spider.transform:Find("activity108_spider"):GetComponent(typeof(CS.Spine.Unity.SkeletonGraphic))
end

function Form_ActivityMinigame108Assemble:OnActive()
  self.super.OnActive(self)
  self.lastChoose = {
    1,
    1,
    1,
    1
  }
  self.main_id = self.m_csui.m_param.main_id
  self.lvconfig = self.m_csui.m_param.data
  local act_data = HeroActivityManager:GetHeroActData(self.main_id)
  local vItem = act_data.server_data.vItem
  self.m_allShowTabDataList = {}
  for i = 1, 4 do
    local tempDataList = self:GetEquipListData(vItem, i)
    if tempDataList[1] then
      tempDataList[1].is_select = true
    end
    self.m_allShowTabDataList[i] = tempDataList
    self["m_Grid" .. i]:ShowItemList(tempDataList)
  end
  local data_list = {}
  if act_data then
    local vItem = act_data.server_data.vItem
    data_list = self:GetEquipListData(vItem, EquipType.CORN)
    for i = 1, 4 do
      self.myProperty2[i] = data_list[1].cfg["m_Property" .. i .. "Num"]
    end
    data_list = self:GetEquipListData(vItem, EquipType.LEG)
    for i = 1, 4 do
      self.myProperty3[i] = data_list[1].cfg["m_Property" .. i .. "Num"]
    end
    data_list = self:GetEquipListData(vItem, EquipType.ENGINE)
    for i = 1, 4 do
      self.myProperty4[i] = data_list[1].cfg["m_Property" .. i .. "Num"]
    end
  end
  self.m_csui.m_param.myProperty = self.myProperty
  self.m_csui.m_param.recProperty = {}
  local rec_list = utils.changeCSArrayToLuaTable(self.lvconfig.m_RecProperty)
  for i = 1, 4 do
    self.m_csui.m_param.recProperty[i] = rec_list[i][2]
  end
  local d1 = self:GetEquipConfigData(EquipType.HEAD)
  local d2 = self:GetEquipConfigData(EquipType.CORN)
  local d3 = self:GetEquipConfigData(EquipType.LEG)
  local d4 = self:GetEquipConfigData(EquipType.ENGINE)
  self.spindata = {
    d1[1].m_Spine,
    d2[1].m_Spine,
    d3[1].m_Spine,
    d4[1].m_Spine
  }
  self.m_csui.m_param.spindata = self.spindata
  self.m_txt_racetrack_Text.text = self.lvconfig.m_mLevelName
  self:TabChange(EquipType.HEAD)
  self:ChangeSpineSkin(self.spindata)
  for i = 1, 4 do
    self["myProperty" .. self.m_allShowTabDataList[1][1].cfg.m_Type][i] = self.m_allShowTabDataList[1][1].cfg["m_Property" .. i .. "Num"]
  end
  for i = 1, 4 do
    local value = 0
    for j = 1, 4 do
      value = value + self["myProperty" .. j][i]
    end
    self.myProperty[i] = value
  end
  self:FreshProperty()
  UILuaHelper.SetUITexture(self.m_img_bg1_Image, MapBgDic[self.lvconfig.m_MapType][1])
  UILuaHelper.SetUITexture(self.m_img_bg2_Image, MapBgDic[self.lvconfig.m_MapType][2])
end

function Form_ActivityMinigame108Assemble:InitProperty()
end

function Form_ActivityMinigame108Assemble:FreshProperty()
  local rec_list = utils.changeCSArrayToLuaTable(self.lvconfig.m_RecProperty)
  for i = 1, 4 do
    local pnl_recommend = self["m_pnl_progress" .. i].transform:Find("pnl_recommend")
    local pnl_self = self["m_pnl_progress" .. i].transform:Find("pnl_self")
    for j = 0, pnl_recommend.transform.childCount - 1 do
      local t = pnl_recommend.transform:GetChild(j)
      if j < rec_list[i][2] then
        t.gameObject:SetActive(true)
        local color = t.gameObject:GetComponent("MultiColorChange")
        color:SetColorByIndex(2)
      else
        t.gameObject:SetActive(false)
      end
    end
    if 0 >= table.size(self.myProperty) then
      return
    end
    for j = 0, pnl_self.transform.childCount - 1 do
      local t = pnl_self.transform:GetChild(j)
      if j < self.myProperty[i] then
        t.gameObject:SetActive(true)
        local color = t.gameObject:GetComponent("MultiColorChange")
        color:SetColorByIndex(1)
      else
        t.gameObject:SetActive(false)
      end
    end
  end
end

function Form_ActivityMinigame108Assemble:OnItemClk(m_itemData, m_itemIndex, is_select)
  if not is_select then
    for i = 1, 4 do
      self["myProperty" .. m_itemData.cfg.m_Type][i] = m_itemData.cfg["m_Property" .. i .. "Num"]
    end
    for i = 1, 4 do
      local value = 0
      for j = 1, 4 do
        value = value + self["myProperty" .. j][i]
      end
      self.myProperty[i] = value
    end
  end
  self:FreshProperty()
  self.spindata[m_itemData.cfg.m_Type] = m_itemData.cfg.m_Spine
  self:ChangeSpineSkin(self.spindata)
  local lastIndex = self.lastChoose[m_itemData.cfg.m_Type]
  if not utils.isNull(lastIndex) then
    local lastChooseItem = self["m_Grid" .. m_itemData.cfg.m_Type]:GetShowItemByIndex(lastIndex)
    if lastChooseItem then
      lastChooseItem:SetSelect(false)
    elseif self.m_allShowTabDataList and self.m_allShowTabDataList[m_itemIndex] then
      self.m_allShowTabDataList[m_itemIndex].is_select = false
    end
  end
  if self.lastChoose[m_itemData.cfg.m_Type] ~= m_itemIndex then
    self:ShowEffect()
    GlobalManagerIns:TriggerWwiseBGMState(374)
  end
  self.lastChoose[m_itemData.cfg.m_Type] = m_itemIndex
  local curChooseItem = self["m_Grid" .. m_itemData.cfg.m_Type]:GetShowItemByIndex(m_itemIndex)
  if curChooseItem then
    curChooseItem:SetSelect(true)
  elseif self.m_allShowTabDataList and self.m_allShowTabDataList[m_itemIndex] then
    self.m_allShowTabDataList[m_itemIndex].is_select = true
  end
end

function Form_ActivityMinigame108Assemble:ShowEffect()
  UILuaHelper.SetActive(self.m_ParticleSystem1, false)
  UILuaHelper.SetActive(self.m_ParticleSystem2, false)
  UILuaHelper.SetActive(self.m_ParticleSystem1, true)
  UILuaHelper.SetActive(self.m_ParticleSystem2, true)
end

function Form_ActivityMinigame108Assemble:TabChange(equipType)
  if self.curTabIndex == equipType then
    return
  end
  for i = 1, #self.tabButtons do
    UILuaHelper.SetActive(self.tabButtons[i].transform:Find("m_on"), false)
  end
  UILuaHelper.SetActive(self.tabButtons[equipType].transform:Find("m_on"), true)
  self.curTabIndex = equipType
  for i = 1, 4 do
    if i == equipType then
      UILuaHelper.SetActive(self["m_scrollView" .. i .. "_InfinityGrid"], true)
    else
      UILuaHelper.SetActive(self["m_scrollView" .. i .. "_InfinityGrid"], false)
    end
  end
end

function Form_ActivityMinigame108Assemble:OnBtnheadClicked()
  self:TabChange(EquipType.HEAD)
end

function Form_ActivityMinigame108Assemble:OnBtncornClicked()
  self:TabChange(EquipType.CORN)
end

function Form_ActivityMinigame108Assemble:OnBtnlegClicked()
  self:TabChange(EquipType.LEG)
end

function Form_ActivityMinigame108Assemble:OnBtnengineClicked()
  self:TabChange(EquipType.ENGINE)
end

function Form_ActivityMinigame108Assemble:OnBtnconfirmClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITYMINIGAME108BATTLEMAIN, self.m_csui.m_param)
end

function Form_ActivityMinigame108Assemble:OnBackClk()
  self:DestroyForm()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMINIGAME108_POP)
end

function Form_ActivityMinigame108Assemble:OnBackHome()
  self:DestroyForm()
end

function Form_ActivityMinigame108Assemble:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActivityMinigame108Assemble:OnDestroy()
  self.super.OnDestroy(self)
  UILuaHelper.CheckClearSkeletonAssetData(self.m_SpiderSpine)
end

function Form_ActivityMinigame108Assemble:ChangeSpineSkin(skinNames)
  local skeleton = self.m_SpiderSpine.Skeleton
  local combinedSkin = CS.Spine.Skin("combinedSpine")
  for i = 1, #skinNames do
    local skin = skeleton.Data:FindSkin(skinNames[i])
    if skin ~= nil then
      combinedSkin:AddSkin(skin)
    end
  end
  skeleton:SetSkin(combinedSkin)
  skeleton:SetSlotsToSetupPose()
  self.m_SpiderSpine:UpdateMesh()
end

local fullscreen = true
ActiveLuaUI("Form_ActivityMinigame108Assemble", Form_ActivityMinigame108Assemble)
return Form_ActivityMinigame108Assemble
