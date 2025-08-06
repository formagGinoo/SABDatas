local Form_Filter = class("Form_Filter", require("UI/UIFrames/Form_FilterUI"))
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local EquipTypeIns = ConfigManager:GetConfigInsByName("EquipType")
local MoonTypeIns = ConfigManager:GetConfigInsByName("MoonType")

function Form_Filter:SetInitParam(param)
end

function Form_Filter:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_DoubleTrigger = self.m_double_trigger:GetComponent("ButtonTriggerDouble")
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.Clicked = handler(self, self.OnDoubleTriggerClk)
  end
  self.FilterData = {
    [HeroManager.FilterType.Camp] = {
      transRoot = self.m_camp_choose_root,
      CfgIns = CampCfgIns,
      ParamName = "m_mCampName",
      ChooseItemList = {}
    },
    [HeroManager.FilterType.Career] = {
      transRoot = self.m_career_choose_root,
      CfgIns = CareerCfgIns,
      ParamName = "m_mCareerName",
      ChooseItemList = {}
    },
    [HeroManager.FilterType.EquipType] = {
      transRoot = self.m_equip_type_choose_root,
      CfgIns = EquipTypeIns,
      ParamName = "m_mEquiptypeName",
      ChooseItemList = {}
    },
    [HeroManager.FilterType.MoonType] = {
      transRoot = self.m_moon_choose_root,
      CfgIns = MoonTypeIns,
      ParamName = "m_mMoontypeName",
      ChooseItemList = {}
    }
  }
  self.m_curChooseFilterType = {}
  self.m_chooseBackFun = nil
  self:InitConfigUI()
end

function Form_Filter:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param or {}
  self.m_click_transform = tParam.click_transform
  self.m_pivot = tParam.content_pivot
  self.m_posOffset = tParam.pos_offset or {x = 0, y = 0}
  self:FreshUI()
  UILuaHelper.SetActive(self.m_tempPos, false)
  self:setTimer(0.06, 1, function()
    if self.m_click_transform then
      self:InitSetPos()
    else
      UILuaHelper.SetLocalPosition(self.m_choose_list, 0, 0, 0)
    end
  end)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(323)
end

function Form_Filter:InitSetPos()
  local pos = self.m_tempPos.transform.parent:InverseTransformPoint(self.m_click_transform.position)
  UILuaHelper.SetLocalPosition(self.m_tempPos, pos.x, pos.y, 0)
  local rectTransform = self.m_choose_list:GetComponent("RectTransform")
  rectTransform.pivot = Vector2.New(self.m_pivot.x, self.m_pivot.y)
  UILuaHelper.SetLocalPosition(self.m_choose_list, self.m_posOffset.x, self.m_posOffset.y, 0)
  UILuaHelper.SetActive(self.m_tempPos, true)
end

function Form_Filter:OnInactive()
  self.super.OnInactive(self)
  self:ClearDataRefresh()
  self:broadcastEvent("eGameEvent_Form_FilterClosed")
end

function Form_Filter:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Filter:InitConfigUI()
  for filterType, filterData in ipairs(self.FilterData) do
    local chooseItemList = filterData.ChooseItemList
    local allCamp = filterData.CfgIns:GetAll()
    local cfgList = {}
    for key, tempCfg in pairs(allCamp) do
      cfgList[key] = tempCfg
    end
    for key, campCfg in ipairs(cfgList) do
      local chooseItem = self:InitCreateChooseItem(filterData, filterType, key, campCfg)
      if chooseItem then
        chooseItemList[#chooseItemList + 1] = chooseItem
      end
    end
    local chooseItem = self:InitCreateChooseItem(filterData, filterType, 0, nil)
    if chooseItem then
      chooseItemList[0] = chooseItem
    end
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_choose_list)
end

function Form_Filter:InitCreateChooseItem(filterData, filterType, index, cfg)
  local cloneObj = GameObject.Instantiate(self.m_btn_choose_base, filterData.transRoot.transform).gameObject
  UILuaHelper.SetActive(cloneObj, true)
  UILuaHelper.SetChildIndex(cloneObj, index)
  local rootTrans = cloneObj.transform
  local normalNode = rootTrans:Find("node_normal")
  local chooseNode = rootTrans:Find("node_choose")
  local allNode = rootTrans:Find("node_all")
  local iconNode = rootTrans:Find("node_icon_bg")
  local isFirst = index == 0
  UILuaHelper.SetActive(allNode, isFirst)
  UILuaHelper.SetActive(iconNode, not isFirst)
  if index ~= 0 then
    local imgIcon = rootTrans:Find("node_icon_bg/node_icon"):GetComponent(T_Image)
    if cfg.m_FilterIcon then
      UILuaHelper.SetAtlasSprite(imgIcon, cfg.m_FilterIcon)
    end
  end
  UILuaHelper.SetActive(normalNode, true)
  UILuaHelper.SetActive(chooseNode, index == 0)
  local buttonCom = cloneObj:GetComponent(T_Button)
  UILuaHelper.BindButtonClickManual(self, buttonCom, function()
    self:OnChooseClk(filterType, index)
  end)
  local chooseItem = {
    rootNode = cloneObj,
    normalNode = normalNode,
    chooseNode = chooseNode
  }
  return chooseItem
end

function Form_Filter:OnChooseClk(filterType, index, isFirst)
  if not filterType then
    return
  end
  local filterData = self.FilterData[filterType]
  if not filterData then
    return
  end
  local chooseItemList = filterData.ChooseItemList
  if not next(chooseItemList) then
    return
  end
  local lastChooseIndex = self.m_curChooseFilterType[filterType]
  lastChooseIndex = lastChooseIndex or 0
  if lastChooseIndex then
    local lastItem = chooseItemList[lastChooseIndex]
    if lastItem then
      UILuaHelper.SetActive(lastItem.normalNode, true)
      UILuaHelper.SetActive(lastItem.chooseNode, false)
    end
  end
  local curChooseItem = chooseItemList[index]
  if curChooseItem then
    UILuaHelper.SetActive(curChooseItem.normalNode, false)
    UILuaHelper.SetActive(curChooseItem.chooseNode, true)
  end
  self.m_curChooseFilterType[filterType] = index
  if self.m_chooseBackFun and not isFirst then
    self.m_chooseBackFun(self.m_curChooseFilterType)
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(322)
end

function Form_Filter:ClearDataRefresh()
  for i, v in pairs(self.FilterData) do
    if v.ChooseItemList then
      for m, n in pairs(v.ChooseItemList) do
        if n.normalNode then
          UILuaHelper.SetActive(n.normalNode, false)
        end
        if n.chooseNode then
          UILuaHelper.SetActive(n.chooseNode, false)
        end
      end
    end
  end
end

function Form_Filter:FreshUI()
  self.m_chooseBackFun = nil
  local tParam = self.m_csui.m_param
  local filterData = {}
  local fight_Type = CS.BattleGlobalManager.Instance:GetSaveInt(CS.LogicDefine.IntVariableType.FightType)
  local fight_subType = CS.BattleGlobalManager.Instance:GetSaveInt(CS.LogicDefine.IntVariableType.FightSubType)
  if self.m_choose_list.transform:Find("camp_group") then
    local groupTypeObj = self.m_choose_list.transform:Find("camp_group").gameObject
    UILuaHelper.SetActive(groupTypeObj, true)
    if tParam.isInBattle then
      if fight_Type == MTTDProto.FightType_Tower and fight_subType ~= MTTDProto.FightTowerSubType_Main then
        UILuaHelper.SetActive(groupTypeObj, false)
      else
        UILuaHelper.SetActive(groupTypeObj, true)
      end
    end
    if tParam.isHideCamp then
      UILuaHelper.SetActive(groupTypeObj, false)
    end
  end
  if self.m_choose_list.transform:Find("moon_group") then
    local moonTypeObj = self.m_choose_list.transform:Find("moon_group").gameObject
    if tParam.isHideShowMoonType then
      UILuaHelper.SetActive(moonTypeObj, false)
    else
      UILuaHelper.SetActive(moonTypeObj, true)
    end
  end
  if tParam and tParam.filterData then
    self.m_chooseBackFun = tParam.chooseBackFun
    filterData = tParam.filterData
  end
  for filterType, tempFilterData in pairs(self.FilterData) do
    if tempFilterData then
      self:OnChooseClk(filterType, filterData[filterType] or 0, true)
    end
  end
end

function Form_Filter:OnDoubleTriggerClk()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_Filter", Form_Filter)
return Form_Filter
