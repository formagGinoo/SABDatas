local Form_BattleRecord = class("Form_BattleRecord", require("UI/UIFrames/Form_BattleRecordUI"))
local tabText = {
  ConfigManager:GetCommonTextById(20321),
  ConfigManager:GetCommonTextById(20322),
  ConfigManager:GetCommonTextById(20323)
}
local tabType = {
  Recommend = 1,
  Friend = 2,
  Alliance = 3
}
local TimeType = {
  Day = 1,
  Week = 2,
  Month = 3,
  All = 4
}
local HeroListMaxCount = tonumber(ConfigManager:GetGlobalSettingsByKey("ReferOtherTeamNumMax"))

function Form_BattleRecord:SetInitParam(param)
end

function Form_BattleRecord:AfterInit()
  self.super.AfterInit(self)
  self.tabCount = 1
  self:HideSomeTimeTab()
  self.tabList = {}
  self.heroListData = {
    [tabType.Recommend] = {},
    [tabType.Friend] = {},
    [tabType.Alliance] = {}
  }
  self.curChooseIndexTab = 0
  self.curTimeType = TimeType.All
  self.isOrderAsc = false
  self.dropDownIsShow = false
  self:InitUI()
  self.m_pnl_left_InfinityGrid:RegisterBindCallback(handler(self, self.OnTabBind))
  self.m_pnl_left_InfinityGrid:RegisterButtonCallback("c_btn_nor", handler(self, self.OnTabClick))
  self.m_herolist_InfinityGrid:RegisterBindCallback(handler(self, self.OnHeroListBind))
  self.m_herolist_InfinityGrid:RegisterButtonCallback("c_btn_copyteam", handler(self, self.OnCopyClick))
  self:OnInitData()
  self.rootAnimation = self.m_csui.m_uiGameObject.transform:GetComponent("Animation")
end

function Form_BattleRecord:OnActive()
  self.super.OnActive(self)
  self:GetHeroListData(self.curChooseIndexTab + 1)
end

function Form_BattleRecord:OnInactive()
  self.super.OnInactive(self)
end

function Form_BattleRecord:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattleRecord:HideSomeTimeTab()
  self.m_btn_tabday:SetActive(false)
  self.m_btn_tabweek:SetActive(false)
  self.m_btn_tabmonth:SetActive(false)
end

function Form_BattleRecord:InitUI()
  self.m_pnl_dropdown:SetActive(false)
  self.m_fitler_leftdown:SetActive(true)
  self.m_btn_refresh:SetActive(true)
end

function Form_BattleRecord:OnInitData()
  self.m_pnl_left_InfinityGrid:Clear()
  self.m_pnl_left_InfinityGrid.TotalItemCount = self.tabCount
  self:CreateDropDownTab()
end

function Form_BattleRecord:CreateHeroIconList(obj)
  local item = obj.transform:Find("c_item_hero/m_pnl_listteam/m_form_rootrecom/c_common_hero_small")
  self.heroIconList = {}
  for i = 1, 5 do
    local go = item.parent:Find(tostring(i))
    go = go or GameObject.Instantiate(item, item.parent)
    local HeroIcon = self:createHeroIcon(go)
    self.heroIconList[#self.heroIconList + 1] = HeroIcon
    go.name = i
    HeroIcon:SetActive(false)
  end
  UILuaHelper.SetActive(item, false)
end

function Form_BattleRecord:SetHerolistData()
  self.m_herolist_InfinityGrid.TotalItemCount = 0
  local heroCount = #self.heroListData[self.curChooseIndexTab + 1]
  if heroCount > HeroListMaxCount then
    heroCount = HeroListMaxCount
  end
  self.m_herolist_InfinityGrid.TotalItemCount = heroCount
end

function Form_BattleRecord:RefreshHeroIcon(data)
  for i = 1, #self.heroIconList do
    local heroIcon = self.heroIconList[i]
    if data[i] then
      heroIcon:SetActive(true)
      heroIcon:SetHeroData(data[i], nil, nil, true)
    else
      heroIcon:SetActive(false)
    end
  end
end

function Form_BattleRecord:OnHeroListBind(cache, go, index)
  local infoTable = self.heroListData[self.curChooseIndexTab + 1][index + 1]
  if infoTable == nil then
    return
  end
  cache:TMPPro("c_txt_heroname").text = infoTable.stRoleInfo.sName
  cache:TMPPro("c_txt_lv").text = infoTable.stRoleInfo.iLevel
  cache:TMPPro("c_txt_teambattle").text = infoTable.stStageArrange.iTotalPower
  cache:TMPPro("c_txt_complete").text = UILuaHelper.GetCommonText(20325)
  local heroId = infoTable.stRoleInfo.iHeadId
  if infoTable.stRoleInfo.iHeadId == 0 then
    heroId = 1300001
  end
  local headData = RoleManager:GetPlayerHeadCfg(heroId)
  local headImage = cache:CircleImage("c_img_head")
  UILuaHelper.SetBaseImageAtlasSprite(headImage, headData.m_HeadPic)
  local m_playerHeadCom = self:createPlayerHead(cache:GameObject("c_circle_head"))
  m_playerHeadCom:SetPlayerHeadClickBackFun(function()
    self:OnPlayerHeadClk(infoTable.stRoleInfo)
  end)
  go.name = index
  self:CreateHeroIconList(go)
  self:RefreshHeroIcon(infoTable.stStageArrange.vHero)
end

function Form_BattleRecord:OnTabBind(cache, go, index)
  if index ~= 0 then
    UILuaHelper.SetActive(cache:GameObject("c_btn_sel"), false)
  end
  cache:TMPPro("c_txt_tabsel").text = tabText[index + 1]
  cache:TMPPro("c_txt_pic").text = tabText[index + 1]
  go.name = index
  table.insert(self.tabList, cache:GameObject("c_btn_sel"))
end

function Form_BattleRecord:OnTabClick(index, go)
  if self.curChooseIndexTab == index then
    return
  end
  UILuaHelper.SetActive(self.tabList[self.curChooseIndexTab + 1], false)
  self.curChooseIndexTab = index
  UILuaHelper.SetActive(self.tabList[self.curChooseIndexTab + 1], true)
  self:GetHeroListData(self.curChooseIndexTab + 1)
end

function Form_BattleRecord:SetEmptyShow()
  if #self.heroListData[self.curChooseIndexTab + 1] ~= 0 then
    UILuaHelper.SetActive(self.m_empty, false)
  else
    UILuaHelper.SetActive(self.m_empty, true)
  end
end

function Form_BattleRecord:GetHeroListData(ArrangeType)
  local msg = MTTDProto.Cmd_Misc_QueryPassStageArrange_CS()
  msg.iStageType = LevelManager.m_curBattleLevelType
  msg.iStageID = LevelManager.m_curBattleLevelID
  msg.iArrangeType = ArrangeType
  msg.iTimeType = self.curTimeType
  msg.bOrderAsc = self.isOrderAsc
  RPCS():Misc_QueryPassStageArrange(msg, handler1(self, self.OnGetHeroListData, ArrangeType))
end

function Form_BattleRecord:OnGetHeroListData(arrangeType, data, msg)
  if not data then
    log.error("SCData == nil")
    return
  end
  self.heroListData[arrangeType] = data.vRoleArrange
  self:SetHerolistData()
  self:SetEmptyShow()
  if #self.heroListData[self.curChooseIndexTab + 1] ~= 0 then
    UILuaHelper.SetActive(self.m_herolist_InfinityGrid, true)
  else
    UILuaHelper.SetActive(self.m_herolist_InfinityGrid, false)
  end
end

function Form_BattleRecord:OnBtnrefreshClicked()
  self.dropDownIsShow = not self.dropDownIsShow
  UILuaHelper.SetActive(self.m_pnl_dropdown, self.dropDownIsShow)
  UILuaHelper.SetActive(self.m_btn_close, self.dropDownIsShow)
end

function Form_BattleRecord:OnBtncloseClicked()
  self:OnBtnrefreshClicked()
end

function Form_BattleRecord:OnCopyClick(index, go)
  local isForbide = true
  local myHeroList = BattleGlobalManager:GetLuaHeros()
  local copyHeroListHavaPos = self.heroListData[self.curChooseIndexTab + 1][index + 1].stStageArrange.vFormHero
  local copyHeroList = self.heroListData[self.curChooseIndexTab + 1][index + 1].stStageArrange.vHero
  local totalPower = self.heroListData[self.curChooseIndexTab + 1][index + 1].stStageArrange.iTotalPower
  for i = 1, #copyHeroList do
    local hero_data = HeroManager:GetHeroDataByID(copyHeroList[i].iHeroId)
    if hero_data then
      isForbide = false
    end
  end
  if isForbide then
    UIStatic.StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 52001)
  else
    StackFlow:Push(UIDefines.ID_FORM_BATTLEUPDATE, {
      otherPlayerTeam = copyHeroList,
      oterTotalPower = totalPower,
      otherPlayerPosTab = copyHeroListHavaPos,
      parentForm = self
    })
  end
end

function Form_BattleRecord:OnPlayerHeadClk(m_itemData)
  if not m_itemData then
    return
  end
  local tempStRoleID = m_itemData.stRoleId
  StackPopup:Push(UIDefines.ID_FORM_PERSONALCARD, {
    zoneID = tempStRoleID.iZoneId,
    otherRoleID = tempStRoleID.iUid
  })
end

function Form_BattleRecord:OnBtntaballClicked()
  if self.curTimeType == TimeType.All then
    return
  end
  self:RefreshTimeDropDown(self.curTimeType, TimeType.All)
  self:GetHeroListData(self.curChooseIndexTab + 1)
end

function Form_BattleRecord:OnBtntabdayClicked()
  if self.curTimeType == TimeType.Day then
    return
  end
  self:RefreshTimeDropDown(self.curTimeType, TimeType.Day)
  self:GetHeroListData(self.curChooseIndexTab + 1)
end

function Form_BattleRecord:OnBtntabweekClicked()
  if self.curTimeType == TimeType.Week then
    return
  end
  self:RefreshTimeDropDown(self.curTimeType, TimeType.Week)
  self:GetHeroListData(self.curChooseIndexTab + 1)
end

function Form_BattleRecord:OnBtntabmonthClicked()
  if self.curTimeType == TimeType.Month then
    return
  end
  self:RefreshTimeDropDown(self.curTimeType, TimeType.Month)
  self:GetHeroListData(self.curChooseIndexTab + 1)
end

function Form_BattleRecord:OnBtntabhlClicked()
  if not self.isOrderAsc then
    return
  end
  self.isOrderAsc = false
  self:RefreshPowerDropDown()
  self:GetHeroListData(self.curChooseIndexTab + 1)
end

function Form_BattleRecord:OnBtntablhClicked()
  if self.isOrderAsc then
    return
  end
  self.isOrderAsc = true
  self:RefreshPowerDropDown()
  self:GetHeroListData(self.curChooseIndexTab + 1)
end

function Form_BattleRecord:CreateDropDownTab()
  self.DropTabTimeSel = {
    [TimeType.All] = self.m_pnl_taballsel,
    [TimeType.Month] = self.m_pnl_tabmonthsel,
    [TimeType.Week] = self.m_pnl_tabweeksel,
    [TimeType.Day] = self.m_pnl_tabdaysel
  }
end

function Form_BattleRecord:RefreshTimeDropDown(lastTYpe, curType)
  self.DropTabTimeSel[lastTYpe]:SetActive(false)
  self.DropTabTimeSel[curType]:SetActive(true)
  self.curTimeType = curType
end

function Form_BattleRecord:RefreshPowerDropDown()
  if self.isOrderAsc then
    self.m_pnl_tablhsel:SetActive(true)
    self.m_pnl_tabhlsel:SetActive(false)
  else
    self.m_pnl_tablhsel:SetActive(false)
    self.m_pnl_tabhlsel:SetActive(true)
  end
end

function Form_BattleRecord:OnBtnReturnClicked()
  self:CloseForm()
  self.dropDownIsShow = false
  UILuaHelper.SetActive(self.m_pnl_dropdown, self.dropDownIsShow)
end

function Form_BattleRecord:OnBtnCloseClicked()
  self:CloseForm()
  self.dropDownIsShow = false
  UILuaHelper.SetActive(self.m_pnl_dropdown, self.dropDownIsShow)
end

function Form_BattleRecord:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BattleRecord", Form_BattleRecord)
return Form_BattleRecord
