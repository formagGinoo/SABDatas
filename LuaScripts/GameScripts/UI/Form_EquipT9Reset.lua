local Form_EquipT9Reset = class("Form_EquipT9Reset", require("UI/UIFrames/Form_EquipT9ResetUI"))

function Form_EquipT9Reset:SetInitParam(param)
end

function Form_EquipT9Reset:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetItemIcon1 = self:createCommonItem(self.m_common_item_1)
  self.m_costItemIcon1 = self:createCommonItem(self.m_cost_item_1)
  self.m_costItemIcon2 = self:createCommonItem(self.m_cost_item_2)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnEquipItemClk)
  }
  self.m_equipListInfinityGrid = self:CreateInfinityGrid(self.m_equip_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_equipListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnEquipItemClk))
end

function Form_EquipT9Reset:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_iID = tParam.iID
  self.m_iNum = tParam.iNum or 0
  self.m_selCamp = tParam.iCampID or 1
  self.m_campIdList = {}
  self.m_selEquipMatList = {}
  if not self.m_iID then
    return
  end
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_EquipT9Reset:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_EquipT9Reset:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
  self:addEventListener("eGameEvent_EquipT9Reset_SelEquipMat", handler(self, self.OnSelEquipMat))
  self:addEventListener("eGameEvent_Equip_Merge", handler(self, self.OnEquipMerge))
end

function Form_EquipT9Reset:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipT9Reset:OnEquipMerge()
  self:OnBtnCloseClicked()
end

function Form_EquipT9Reset:OnSelEquipMat(selEquips)
  if not selEquips or #selEquips ~= EquipManager:GetCampEquipMergeCostNum() then
    return
  end
  self.m_selEquipMatList = selEquips
  self:RefreshMaterialsUI()
end

function Form_EquipT9Reset:RefreshUI()
  local itemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_iID,
    iNum = 0
  }, {
    bBag = self.m_bBag
  })
  self.m_widgetItemIcon1:SetItemInfo(itemData)
  local curHaveNum = ItemManager:GetItemNum(self.m_iID) or 0
  local item = EquipManager:GetCampEquipMergeCostItem()
  if item and item[2] then
    self.m_widgetItemIcon1:SetEffectiveItemNeedNum(item[2], curHaveNum)
  end
  self.m_txt_introduction_Text.text = itemData.description
  self.m_txt_num_Text.text = self.m_iNum
  self:RefreshRandomPoolList()
  self:RefreshCampBtnList()
  self:RefreshMaterialsUI()
end

function Form_EquipT9Reset:RefreshMaterialsUI()
  local needNum = EquipManager:GetCampEquipMergeCostNum()
  local bSameCamp = self:CheckSelEquipCamp(self.m_selEquipMatList, self.m_selCamp)
  for i = 1, 2 do
    UILuaHelper.SetActive(self["m_cost_node" .. i], i <= needNum)
    UILuaHelper.SetActive(self["m_cost_item_" .. i], self.m_selEquipMatList[i])
    if self.m_selEquipMatList[i] then
      local equipData = EquipManager:GetEquipDataByID(self.m_selEquipMatList[i])
      if equipData then
        local processItemData = ResourceUtil:GetProcessRewardData({
          equipData.iBaseId,
          0
        }, equipData)
        self["m_costItemIcon" .. i]:SetItemInfo(processItemData)
      end
    end
  end
  UILuaHelper.SetActive(self.m_pnl_z_txt, bSameCamp)
  local haveItem = self:CheckHaveEnoughItem()
  UILuaHelper.SetActive(self.m_btn_bg_grey, needNum ~= #self.m_selEquipMatList or not haveItem)
  UILuaHelper.SetActive(self.m_btn_bg_yes, needNum == #self.m_selEquipMatList and haveItem)
end

function Form_EquipT9Reset:CheckHaveEnoughItem()
  local item = EquipManager:GetCampEquipMergeCostItem()
  if item and item[1] then
    local num = ItemManager:GetItemNum(item[1])
    if num then
      return num >= item[2]
    end
  end
  return false
end

function Form_EquipT9Reset:RefreshCampBtnList()
  self.m_campIdList = HeroManager:GetCharacterAllCampIdList()
  if not self.m_campIdList or #self.m_campIdList == 0 then
    return
  end
  for i, camp in ipairs(self.m_campIdList) do
    if not utils.isNull(self["m_btn_camp_" .. i]) then
      UILuaHelper.SetActive(self["m_img_bg_slc_" .. i], camp == self.m_selCamp)
      local poolId = EquipManager:GetEquipMergeCampPoolByCampId(camp)
      UILuaHelper.SetActive(self["m_img_lock_" .. i], poolId == nil)
      UILuaHelper.SetActive(self["m_img_bg_grey_" .. i], camp ~= self.m_selCamp)
      ResourceUtil:CreateCampImg(self["m_img_camp_" .. i .. "_Image"], camp)
    end
  end
end

function Form_EquipT9Reset:RefreshRandomPoolList()
  local poolId = EquipManager:GetEquipMergeCampPoolByCampId(self.m_selCamp)
  if poolId then
    local equipList = {}
    self.m_itemList = ItemManager:GetRandomPoolInfoByPoolId(poolId)
    for i, v in pairs(self.m_itemList) do
      local processItemData = ResourceUtil:GetProcessRewardData(v)
      equipList[#equipList + 1] = processItemData
    end
    self.m_equipListInfinityGrid:ShowItemList(equipList)
    self.m_equipListInfinityGrid:LocateTo(0)
  end
end

function Form_EquipT9Reset:OnEquipItemClk(index, widgetItemObj)
  if not index then
    return
  end
  local fjItemIndex = index + 1
  if not self.m_equipListInfinityGrid then
    return
  end
  local chooseFJItemData = self.m_itemList[fjItemIndex]
  if chooseFJItemData then
    local itemData = chooseFJItemData
    if itemData.data and itemData.data.iEquipUid then
      itemData = itemData.data
    end
    utils.openItemDetailPop(itemData, nil, true)
  end
end

function Form_EquipT9Reset:ChooseCamp(index)
  local selCamp = self.m_campIdList[index] or 1
  local poolId = EquipManager:GetEquipMergeCampPoolByCampId(selCamp)
  if poolId then
    self.m_selCamp = selCamp
    self:RefreshUI()
    UILuaHelper.PlayAnimationByName(self.m_equip_list, "m_equip_list_in")
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 58001)
  end
end

function Form_EquipT9Reset:CheckSelEquipCamp(selEquips, iCamp)
  if not iCamp then
    return
  end
  for _, iEquipUid in pairs(selEquips) do
    local equipData = EquipManager:GetEquipDataByID(iEquipUid)
    if equipData then
      local equipCfg = EquipManager:GetEquipCfgByBaseId(equipData.iBaseId)
      if equipCfg.m_BonusCamp == iCamp then
        return true
      end
    end
  end
  return false
end

function Form_EquipT9Reset:OnBtncamp1Clicked()
  self:ChooseCamp(1)
end

function Form_EquipT9Reset:OnBtncamp2Clicked()
  self:ChooseCamp(2)
end

function Form_EquipT9Reset:OnBtncamp3Clicked()
  self:ChooseCamp(3)
end

function Form_EquipT9Reset:OnBtncamp4Clicked()
  self:ChooseCamp(4)
end

function Form_EquipT9Reset:OnBtncamp5Clicked()
  self:ChooseCamp(5)
end

function Form_EquipT9Reset:OnCostnode1Clicked()
  StackPopup:Push(UIDefines.ID_FORM_EQUIPSMELTINGMATERIALS, {
    iCamp = self.m_selCamp,
    selEquipIds = self.m_selEquipMatList
  })
end

function Form_EquipT9Reset:OnCostnode2Clicked()
  StackPopup:Push(UIDefines.ID_FORM_EQUIPSMELTINGMATERIALS, {
    iCamp = self.m_selCamp,
    selEquipIds = self.m_selEquipMatList
  })
end

function Form_EquipT9Reset:OnPnldetailsClicked()
  local poolId = EquipManager:GetEquipMergeCampPoolByCampId(self.m_selCamp)
  if poolId then
    StackPopup:Push(UIDefines.ID_FORM_ITEMRANDOMDETAIL, {iRandomPoolID = poolId})
  end
end

function Form_EquipT9Reset:OnBtnbggreyClicked()
  local needNum = EquipManager:GetCampEquipMergeCostNum()
  if needNum ~= #self.m_selEquipMatList then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 58004)
    return
  end
  local haveItem = self:CheckHaveEnoughItem()
  if not haveItem then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 58002)
  end
end

function Form_EquipT9Reset:CheckDailyTips(tipsId)
  if TimeUtil:GetServerTimeS() < LocalDataManager:GetIntSimple("Form_EquipT9Reset" .. tipsId, 0) then
    return false
  end
  return true
end

function Form_EquipT9Reset:SetDailyTips(tipsId)
  LocalDataManager:SetIntSimple("Form_EquipT9Reset" .. tipsId, TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
end

function Form_EquipT9Reset:OnBtnbgyesClicked()
  local bSameCamp = self:CheckSelEquipCamp(self.m_selEquipMatList, self.m_selCamp)
  local tipsID = bSameCamp and 1275 or 1276
  if not self:CheckDailyTips(tipsID) then
    EquipManager:ReqEquipMerge(self.m_selCamp, self.m_selEquipMatList)
  else
    local chooseToggle = false
    utils.popUpDirectionsUI({
      tipsID = tipsID,
      showToggle = true,
      toggleText = ConfigManager:GetClientMessageTextById(58008),
      toggleCallBack = function(isOn)
        chooseToggle = isOn
      end,
      func1 = function()
        EquipManager:ReqEquipMerge(self.m_selCamp, self.m_selEquipMatList)
        if chooseToggle then
          self:SetDailyTips(tipsID)
        end
      end
    })
  end
end

function Form_EquipT9Reset:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_EquipT9Reset:IsOpenGuassianBlur()
  return true
end

function Form_EquipT9Reset:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_EquipT9Reset", Form_EquipT9Reset)
return Form_EquipT9Reset
