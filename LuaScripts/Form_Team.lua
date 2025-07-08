local Form_Team = class("Form_Team", require("UI/UIFrames/Form_TeamUI"))
local FormTypeMaxNum = 6
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local DefaultChooseType = 1
local String_Format = string.format
local table_sort = table.sort
local TeamFreshFxAnimStr = "card_sx"
local HeroManager = _ENV.HeroManager
local moonTypeCount = 3

function Form_Team:SetInitParam(param)
end

function Form_Team:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1154)
  self.m_curChooseFormType = nil
  self.m_allFormTeams = nil
  self.m_HeroWidgetList = {}
  self.m_curShowTeamHeroList = {}
  self:InitHeroWidgets()
end

function Form_Team:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:ResetTabState()
  self:FreshData()
  self:FreshUI()
end

function Form_Team:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_Team:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Team:Init(gameObject, csui)
  self:InitClicks()
  self.super.Init(self, gameObject, csui)
end

function Form_Team:InitClicks()
  for i = 1, FormTypeMaxNum do
    local clickFunName = String_Format("OnBtnteam0%dClicked", i)
    self[clickFunName] = function()
      self:OnTeamClk(i)
    end
  end
  for i = 1, FormPlotMaxNum do
    local clickFunName = String_Format("OnBtncard0%dClicked", i)
    self[clickFunName] = function()
      self:OnTeamCardClk(i)
    end
  end
end

function Form_Team:InitHeroWidgets()
  for i = 1, FormPlotMaxNum do
    local tempBtnTrans = self["m_btn_card0" .. i].transform
    if tempBtnTrans then
      local heroIconRoot = tempBtnTrans:Find("img_mask/c_common_team_item").gameObject
      local heroWidget = self:createHeroTeamIcon(heroIconRoot)
      if heroWidget then
        self.m_HeroWidgetList[#self.m_HeroWidgetList + 1] = heroWidget
        heroWidget:SetActive(false)
      end
    end
  end
end

function Form_Team:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_SetForm", handler(self, self.OnEventSetForm))
end

function Form_Team:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Team:OnEventSetForm(param)
  if not param then
    return
  end
  local formType = param.formType
  local formData = param.formData
  self:FreshOneFromTeamData(formType, formData)
  if formType == self.m_curChooseFormType then
    self:FreshFormTeamUI()
    self:FreshShowTeamFx()
  end
end

function Form_Team:GetBattleTopHeroIDList()
  local heroList = HeroManager:GetHeroList()
  if heroList and next(heroList) then
    table_sort(heroList, function(a, b)
      return a.serverData.iPower > b.serverData.iPower
    end)
  end
  local heroIDList = {}
  for i, v in ipairs(heroList) do
    if #heroIDList < FormPlotMaxNum then
      local trueIdentity = v.characterCfg.m_TrueIdentity
      local is_have = false
      for _, heroID in ipairs(heroIDList) do
        local cfg = HeroManager:GetHeroConfigByID(heroID)
        if trueIdentity and trueIdentity ~= 0 and trueIdentity == cfg.m_TrueIdentity then
          is_have = cfg
          break
        end
      end
      if not is_have then
        heroIDList[#heroIDList + 1] = v.serverData.iHeroId
      end
    end
  end
  return heroIDList
end

function Form_Team:ResetTabState()
  for i = 1, FormTypeMaxNum do
    local lastChooseNode = self["m_team_choose" .. i]
    if lastChooseNode then
      UILuaHelper.SetActive(lastChooseNode, false)
      UILuaHelper.SetColor(self["m_z_txt_team_name0" .. i], 121, 121, 121, 1)
    end
  end
end

function Form_Team:FreshData()
  local params = self.m_csui.m_param
  local FormTypeBase = params and params.FormTypeBase or HeroManager.TeamTypeBase.Default
  if self.FormTypeBase ~= FormTypeBase then
    self.formType = DefaultChooseType
  end
  self.FormTypeBase = params and params.FormTypeBase or HeroManager.TeamTypeBase.Default
  self:FreshAllFormTeamData()
end

function Form_Team:FreshAllFormTeamData()
  local allFormDic = HeroManager:GetPresetDic() or {}
  local allFormTeams = {}
  for k, v in pairs(allFormDic) do
    local serverFormData = v
    local heroIDList = serverFormData.vHeroId
    local heroDataList = {}
    for _, heroID in ipairs(heroIDList) do
      if v then
        heroDataList[#heroDataList + 1] = HeroManager:GetHeroDataByID(heroID)
      end
    end
    local formData = {serverFormData = v, heroDataList = heroDataList}
    allFormTeams[k] = formData
  end
  self.m_allFormTeams = allFormTeams
end

function Form_Team:FreshOneFromTeamData(formType, formData)
  if not formType then
    return
  end
  if not formData then
    return
  end
  if not self.m_allFormTeams then
    return
  end
  local heroIDList = formData.vHeroId
  local heroDataList = {}
  for _, heroID in ipairs(heroIDList) do
    heroDataList[#heroDataList + 1] = HeroManager:GetHeroDataByID(heroID)
  end
  local tempFormData = {serverFormData = formData, heroDataList = heroDataList}
  self.m_allFormTeams[formType] = tempFormData
end

function Form_Team:IsSameHeroTeam(heroIDList)
  if not heroIDList then
    return
  end
  local curFormData = self.m_allFormTeams[self.m_curChooseFormType] or {}
  local curHeroDataList = curFormData.heroDataList or {}
  local curChooseLen = #curHeroDataList
  local heroLen = #heroIDList
  if curChooseLen ~= heroLen then
    return false
  end
  for index, chooseHeroID in ipairs(heroIDList) do
    local tempHeroData = curHeroDataList[index]
    if tempHeroData == nil or tempHeroData.serverData == nil or tempHeroData.serverData.iHeroId ~= chooseHeroID then
      return false
    end
  end
  return true
end

function Form_Team:GetChooseHeroIDList()
  local teamData = self.m_allFormTeams[self.m_curChooseFormType]
  if not teamData then
    return {}
  end
  local heroDataList = teamData.heroDataList or {}
  if not heroDataList then
    return {}
  end
  local heroIDList = {}
  for i, heroData in ipairs(heroDataList) do
    if heroData then
      heroIDList[#heroIDList + 1] = heroData.serverData.iHeroId
    end
  end
  return heroIDList
end

function Form_Team:FreshUI()
  self:OnTeamClk(self.formType or DefaultChooseType)
end

function Form_Team:FreshFormTeamUI()
  if not self.m_curChooseFormType then
    return
  end
  local teamData = self.m_allFormTeams[self.m_curChooseFormType] or {}
  local heroDataList = teamData.heroDataList or {}
  local moonInfo = {}
  for i = 1, FormPlotMaxNum do
    local heroData = heroDataList[i]
    local heroWidget = self.m_HeroWidgetList[i]
    if heroWidget then
      local teamBg = self["m_btn_bg_" .. i]
      if heroData then
        heroWidget:SetActive(true)
        UILuaHelper.SetActive(teamBg, false)
        UILuaHelper.SetActive(self["m_UIFX_teamchoose" .. i], true)
        heroWidget:SetHeroData(heroData.serverData, nil, nil, true)
        local moon = heroData.characterCfg.m_MoonType
        moonInfo[moon] = moon
      else
        heroWidget:SetActive(false)
        UILuaHelper.SetActive(teamBg, true)
        UILuaHelper.SetActive(self["m_UIFX_teamchoose" .. i], false)
      end
    end
  end
  self:ResetTipsInfo()
  if #heroDataList == 0 then
    self.m_item_warningfault:SetActive(true)
  elseif #heroDataList < FormPlotMaxNum then
    self.m_item_warningnotfull:SetActive(true)
  elseif #moonInfo == moonTypeCount then
    self.m_item_resasonable:SetActive(true)
  else
    self.m_item_warningmoon:SetActive(true)
    self.m_img_bg1:SetActive(not moonInfo[1])
    self.m_img_bg2:SetActive(not moonInfo[2])
    self.m_img_bg3:SetActive(not moonInfo[3])
  end
  local formData = teamData.serverFormData or {}
  local teamPower = formData.iPower or 0
  self.m_txt_power_num_Text.text = teamPower
  self.m_curShowTeamHeroList = heroDataList
end

function Form_Team:ResetTipsInfo()
  self.m_item_warningfault:SetActive(false)
  self.m_item_warningnotfull:SetActive(false)
  self.m_item_warningmoon:SetActive(false)
  self.m_item_resasonable:SetActive(false)
end

function Form_Team:FreshShowTeamFx()
  UILuaHelper.PlayAnimationByName(self.m_pnl_card_list, TeamFreshFxAnimStr)
end

function Form_Team:OnTeamClk(formType)
  self.formType = formType
  local lastFormType = HeroManager:GetTeamIdxByTypeBaseAndTeamType(self.FormTypeBase, self.m_curChooseFormType)
  if lastFormType then
    local lastChooseNode = self["m_team_choose" .. lastFormType]
    if lastChooseNode then
      UILuaHelper.SetActive(lastChooseNode, false)
      UILuaHelper.SetColor(self["m_z_txt_team_name0" .. lastFormType], 121, 121, 121, 1)
    end
  end
  self.m_curChooseFormType = HeroManager:GetTeamTypeByTeamIdxAndTypeBase(self.FormTypeBase, formType)
  local curChooseNode = self["m_team_choose" .. formType]
  if curChooseNode then
    UILuaHelper.SetActive(curChooseNode, true)
    UILuaHelper.SetColor(self["m_z_txt_team_name0" .. formType], 255, 255, 255, 1)
  end
  self:FreshFormTeamUI()
end

function Form_Team:OnTeamCardClk(teamPlot)
  if not teamPlot then
    return
  end
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, "out")
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "out")
  TimeService:SetTimer(aniLen, 1, function()
    StackFlow:Push(UIDefines.ID_FORM_TEAMHEROLIST, {
      formType = self.m_curChooseFormType,
      teamPlot = teamPlot
    })
  end)
end

function Form_Team:OnBtnbianduiClicked()
  if not self.m_curChooseFormType then
    return
  end
  local heroIDList = self:GetBattleTopHeroIDList()
  if not heroIDList or not next(heroIDList) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10002)
    return
  end
  if self:IsSameHeroTeam(heroIDList) == true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10003)
    return
  end
  if heroIDList and next(heroIDList) then
    HeroManager:ReqSetPreset(self.m_curChooseFormType, heroIDList)
  end
end

function Form_Team:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_TEAM)
end

function Form_Team:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Team", Form_Team)
return Form_Team
