local Form_BagFilter = class("Form_BagFilter", require("UI/UIFrames/Form_BagFilterUI"))
local EquipPosIns = ConfigManager:GetConfigInsByName("EquipPos")
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local EquipTypeIns = ConfigManager:GetConfigInsByName("EquipType")
local InitPosTime = 0.06

function Form_BagFilter:SetInitParam(param)
end

function Form_BagFilter:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_DoubleTrigger = self.m_double_trigger:GetComponent("ButtonTriggerDouble")
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.Clicked = handler(self, self.OnDoubleTriggerClk)
  end
  self.FilterData = {
    [EquipManager.EquipFilterType.Pos] = {
      transRoot = self.m_equipposition_choose_root,
      CfgIns = EquipPosIns,
      icon = "m_posicon",
      ChooseItemList = {}
    },
    [EquipManager.EquipFilterType.Camp] = {
      transRoot = self.m_camp_choose_root,
      CfgIns = CampCfgIns,
      icon = "m_FilterIcon",
      show_empty = true,
      ChooseItemList = {}
    },
    [EquipManager.EquipFilterType.EquipType] = {
      transRoot = self.m_equip_type_choose_root,
      CfgIns = EquipTypeIns,
      icon = "m_FilterIcon",
      ChooseItemList = {}
    },
    [EquipManager.EquipFilterType.Quality] = {
      transRoot = self.m_equiplevel_choose_root,
      Cfg = GlobalConfig.QUALITY_EQUIP_Filter,
      ChooseItemList = {}
    }
  }
  self.m_equipenhance_toggle_Toggle.isOn = false
  self.m_equipenhance_toggle_Toggle.onValueChanged:AddListener(function()
    self:OnToggleValueChanged()
  end)
  self.m_chooseBackFun = nil
  self:InitConfigUI()
  UILuaHelper.SetActive(self.m_content_node, false)
end

function Form_BagFilter:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param or {}
  self.m_click_transform = tParam.click_transform
  self.m_pivot = tParam.content_pivot
  self.m_posOffset = tParam.pos_offset or {x = 0, y = 0}
  self.m_equipDataList = tParam.equipDataList or {}
  self.m_chooseBackFun = tParam.chooseBackFun
  self.m_curChooseFilterType = tParam.chooseFilterType or {}
  self.m_equipSlot = tParam.equipSlot
  self.m_openFormBag = tParam.openFormBag
  self:InitPosNode()
  self:RefreshUI()
  local tipsId = self.m_openFormBag and 100819 or 100820
  self.m_txt_equipenhance_Text.text = ConfigManager:GetCommonTextById(tipsId)
  UILuaHelper.SetActive(self.m_tempPos, false)
  self:setTimer(InitPosTime, 1, function()
    if self.m_click_transform then
      self:InitSetPos()
    else
      UILuaHelper.SetLocalPosition(self.m_choose_list, 0, 0, 0)
    end
  end)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(323)
end

function Form_BagFilter:IsHaveChooseFilter()
  for _, tempChooseData in pairs(self.m_curChooseFilterType) do
    if tempChooseData and type(tempChooseData) == "table" then
      for i, v in pairs(tempChooseData) do
        if v then
          return true
        end
      end
    end
  end
  return false
end

function Form_BagFilter:FreshEquipEnhanceToggleShow()
  if self.m_curChooseFilterType[EquipManager.EquipFilterType.Enhance] then
    self.m_equipenhance_toggle_Toggle.interactable = true
    self.m_equipenhance_toggle_Toggle.isOn = true
    UILuaHelper.SetActive(self.m_icon_unsel, false)
    return
  else
    self.m_equipenhance_toggle_Toggle.isOn = false
  end
  if self.m_openFormBag then
    local isChooseFilter = self:IsHaveChooseFilter()
    UILuaHelper.SetActive(self.m_icon_unsel, isChooseFilter ~= true)
    if isChooseFilter ~= true then
      self.m_equipenhance_toggle_Toggle.interactable = false
    else
      self.m_equipenhance_toggle_Toggle.interactable = true
    end
  else
    UILuaHelper.SetActive(self.m_icon_unsel, false)
    self.m_equipenhance_toggle_Toggle.interactable = true
  end
end

function Form_BagFilter:OnInactive()
  self.super.OnInactive(self)
  self:ClearDataRefresh()
end

function Form_BagFilter:InitPosNode()
  local filterData = self.FilterData[EquipManager.EquipFilterType.Pos]
  if filterData and filterData.ChooseItemList then
    for index, item in pairs(filterData.ChooseItemList) do
      if not utils.isNull(item.rootNode) then
        UILuaHelper.SetActive(item.rootNode, true)
      end
    end
  end
end

function Form_BagFilter:RefreshUI()
  if self.m_equipSlot and self.m_equipSlot > 0 then
    if not self.m_curChooseFilterType[EquipManager.EquipFilterType.Pos] then
      self.m_curChooseFilterType[EquipManager.EquipFilterType.Pos] = {}
    end
    self.m_curChooseFilterType[EquipManager.EquipFilterType.Pos][self.m_equipSlot] = true
    local filterData = self.FilterData[EquipManager.EquipFilterType.Pos]
    if filterData and filterData.ChooseItemList then
      for index, item in pairs(filterData.ChooseItemList) do
        if index ~= self.m_equipSlot then
          UILuaHelper.SetActive(item.rootNode, false)
        end
      end
    end
  end
  for filterType, v in pairs(self.FilterData) do
    if 0 < table.getn(v.ChooseItemList) then
      for _, item in pairs(v.ChooseItemList) do
        UILuaHelper.SetActive(item.normalNode, true)
        UILuaHelper.SetActive(item.chooseNode, false)
      end
    end
    if self.m_curChooseFilterType[filterType] then
      for index, _ in pairs(self.m_curChooseFilterType[filterType]) do
        self:OnChooseClk(filterType, index or 0, true)
      end
    end
  end
  self:FreshEquipEnhanceToggleShow()
end

function Form_BagFilter:OnToggleValueChanged()
  if self.m_openFormBag then
    local isChooseFilter = self:IsHaveChooseFilter()
    if isChooseFilter ~= true then
      return
    end
  end
  if self.m_chooseBackFun then
    local flag = self.m_equipenhance_toggle_Toggle.isOn and true or nil
    self.m_curChooseFilterType[EquipManager.EquipFilterType.Enhance] = flag
    self.m_chooseBackFun(self.m_curChooseFilterType)
  end
end

function Form_BagFilter:InitSetPos()
  local pos = self.m_tempPos.transform.parent:InverseTransformPoint(self.m_click_transform.position)
  UILuaHelper.SetLocalPosition(self.m_tempPos, pos.x, pos.y, 0)
  local rectTransform = self.m_choose_list:GetComponent("RectTransform")
  rectTransform.pivot = Vector2.New(self.m_pivot.x, self.m_pivot.y)
  UILuaHelper.SetLocalPosition(self.m_choose_list, self.m_posOffset.x, self.m_posOffset.y, 0)
  UILuaHelper.SetActive(self.m_tempPos, true)
end

function Form_BagFilter:InitConfigUI()
  for filterType, filterData in ipairs(self.FilterData) do
    local chooseItemList = filterData.ChooseItemList
    local cfgList = {}
    if filterData.CfgIns then
      local allCamp = filterData.CfgIns:GetAll()
      for key, tempCfg in pairs(allCamp) do
        cfgList[key] = tempCfg
      end
    else
      cfgList = filterData.Cfg
    end
    for key, Cfg in ipairs(cfgList) do
      local chooseItem = self:InitCreateChooseItem(filterData, filterType, key, Cfg)
      if chooseItem then
        chooseItemList[#chooseItemList + 1] = chooseItem
      end
    end
    if filterData.show_empty then
      local chooseItem = self:InitCreateChooseItem(filterData, filterType, 0, nil)
      if chooseItem then
        chooseItemList[0] = chooseItem
      end
    end
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_choose_list)
end

function Form_BagFilter:InitCreateChooseItem(filterData, filterType, index, cfg)
  local cloneObj = GameObject.Instantiate(self.m_btn_choose_base, filterData.transRoot.transform).gameObject
  UILuaHelper.SetActive(cloneObj, true)
  UILuaHelper.SetChildIndex(cloneObj, index)
  local rootTrans = cloneObj.transform
  local normalNode = rootTrans:Find("node_normal")
  local chooseNode = rootTrans:Find("node_choose")
  local icon_empty = rootTrans:Find("node_icon_bg/m_icon_empty")
  local node_icon = rootTrans:Find("node_icon_bg/node_icon")
  local txt_name = rootTrans:Find("node_icon_bg/txt_name")
  local normalNodeTxt = rootTrans:Find("node_normaltier")
  local chooseNodeTxt = rootTrans:Find("node_choosetier")
  local showEmpty = index == 0
  UILuaHelper.SetActive(icon_empty, showEmpty)
  UILuaHelper.SetActive(node_icon, not showEmpty and filterData.icon)
  UILuaHelper.SetActive(normalNode, filterType ~= EquipManager.EquipFilterType.Quality)
  UILuaHelper.SetActive(normalNodeTxt, filterType == EquipManager.EquipFilterType.Quality)
  UILuaHelper.SetActive(txt_name, filterType == EquipManager.EquipFilterType.Quality)
  UILuaHelper.SetActive(chooseNodeTxt, false)
  UILuaHelper.SetActive(chooseNode, false)
  local normalBgNode = normalNode
  local chooseBgNode = chooseNode
  if index ~= 0 then
    local imgIcon = node_icon:GetComponent(T_Image)
    if filterData.icon and cfg[filterData.icon] then
      UILuaHelper.SetAtlasSprite(imgIcon, cfg[filterData.icon])
    end
    if cfg.name then
      local textName = txt_name:GetComponent(T_TextMeshProUGUI)
      textName.text = ConfigManager:GetCommonTextById(cfg.name)
      normalBgNode = normalNodeTxt
      chooseBgNode = chooseNodeTxt
    end
  end
  local buttonCom = cloneObj:GetComponent(T_Button)
  UILuaHelper.BindButtonClickManual(self, buttonCom, function()
    self:OnChooseClk(filterType, index)
  end)
  local chooseItem = {
    rootNode = cloneObj,
    normalNode = normalBgNode,
    chooseNode = chooseBgNode
  }
  return chooseItem
end

function Form_BagFilter:OnChooseClk(filterType, index, isFirst)
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
  if filterType == EquipManager.EquipFilterType.Pos and self.m_equipSlot and self.m_equipSlot > 0 and not isFirst then
    return
  end
  if not isFirst then
    if not self.m_curChooseFilterType[filterType] then
      self.m_curChooseFilterType[filterType] = {}
      self.m_curChooseFilterType[filterType][index] = true
    elseif not self.m_curChooseFilterType[filterType][index] then
      self.m_curChooseFilterType[filterType][index] = true
    else
      self.m_curChooseFilterType[filterType][index] = nil
      if table.getn(self.m_curChooseFilterType[filterType]) == 0 then
        self.m_curChooseFilterType[filterType] = nil
      end
      local isEmpty = self:CheckFilterChooseIsEmpty()
      if isEmpty then
        self.m_curChooseFilterType[EquipManager.EquipFilterType.Enhance] = nil
      end
    end
  end
  local curChooseItem = chooseItemList[index]
  if curChooseItem then
    if self.m_curChooseFilterType[filterType] and self.m_curChooseFilterType[filterType][index] then
      UILuaHelper.SetActive(curChooseItem.chooseNode, true)
      UILuaHelper.SetActive(curChooseItem.normalNode, false)
    else
      UILuaHelper.SetActive(curChooseItem.chooseNode, false)
      UILuaHelper.SetActive(curChooseItem.normalNode, true)
    end
  end
  if self.m_chooseBackFun and not isFirst then
    self.m_chooseBackFun(self.m_curChooseFilterType)
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(322)
  self:FreshEquipEnhanceToggleShow()
end

function Form_BagFilter:CheckFilterChooseIsEmpty()
  local isEmpty = true
  for i, v in pairs(EquipManager.EquipFilterType) do
    if self.m_curChooseFilterType[v] and v ~= EquipManager.EquipFilterType.Enhance then
      isEmpty = false
      break
    end
  end
  return isEmpty
end

function Form_BagFilter:ClearDataRefresh()
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

function Form_BagFilter:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BagFilter:OnDoubleTriggerClk()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_BagFilter", Form_BagFilter)
return Form_BagFilter
