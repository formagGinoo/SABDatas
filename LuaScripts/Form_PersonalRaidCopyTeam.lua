local Form_PersonalRaidCopyTeam = class("Form_PersonalRaidCopyTeam", require("UI/UIFrames/Form_PersonalRaidCopyTeamUI"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local FormTypeMaxNum = 6

function Form_PersonalRaidCopyTeam:SetInitParam(param)
end

function Form_PersonalRaidCopyTeam:AfterInit()
  self.super.AfterInit(self)
  self.m_HeroWidgetList = {}
  self.m_otherHeroWidgetList = {}
  self.otherPlayerTeam = {}
  self:InitHeroWidgets()
  self.grayMat = self.m_GrayMat_Image.material
end

function Form_PersonalRaidCopyTeam:InitHeroWidgets()
  for i = 1, FormPlotMaxNum do
    local heroIconRoot = self["m_common_hero_small_replace" .. i]
    if heroIconRoot then
      local heroWidget = self:createHeroIcon(heroIconRoot)
      if heroWidget then
        self.m_HeroWidgetList[#self.m_HeroWidgetList + 1] = heroWidget
        heroWidget:SetActive(false)
      end
    end
    local otherheroIconRoot = self["m_common_hero_small" .. i]
    if otherheroIconRoot then
      local heroWidget = self:createHeroIcon(otherheroIconRoot)
      if heroWidget then
        self.m_otherHeroWidgetList[#self.m_otherHeroWidgetList + 1] = heroWidget
        heroWidget:SetActive(false)
      end
    end
  end
end

function Form_PersonalRaidCopyTeam:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self.curChooseIndex = 1
  self:FreshData()
  self:FreshUI()
end

function Form_PersonalRaidCopyTeam:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_PersonalRaidCopyTeam:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PersonalRaidCopyTeam:FreshData()
  self.FormTypeBase = HeroManager.TeamTypeBase.SoloRaid
  if self.m_csui.m_param then
    self.otherPlayerTeam = self.m_csui.m_param.otherPlayerTeam or {}
  end
  self:FreshAllFormTeamData()
end

function Form_PersonalRaidCopyTeam:FreshAllFormTeamData()
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

function Form_PersonalRaidCopyTeam:FreshUI()
  self:FreshOtherPlayerTeamInfo()
  self:FreshMyTeamInfo()
end

function Form_PersonalRaidCopyTeam:FreshOtherPlayerTeamInfo()
  local heroDataList = self.otherPlayerTeam or {}
  for i = 1, FormPlotMaxNum do
    local serverData = heroDataList[i]
    local heroWidget = self.m_otherHeroWidgetList[i]
    if heroWidget then
      if serverData then
        heroWidget:SetActive(true)
        heroWidget:SetHeroData(serverData, nil, nil, true)
        local hero_data = HeroManager:GetHeroDataByID(serverData.iHeroId)
        if not hero_data then
          heroWidget:SetObtainActive(true)
          heroWidget:SetHeroGrey(true, self.grayMat)
        else
          heroWidget:SetObtainActive(false)
          heroWidget:SetHeroGrey(false)
        end
      else
        heroWidget:SetActive(false)
      end
    end
  end
end

function Form_PersonalRaidCopyTeam:FreshMyTeamInfo()
  self.m_txt_teamnum_Text.text = "0" .. self.curChooseIndex
  self.FormType = HeroManager:GetTeamTypeByTeamIdxAndTypeBase(self.FormTypeBase, self.curChooseIndex)
  local teamData = self.m_allFormTeams[self.FormType] or {}
  local heroDataList = teamData.heroDataList or {}
  for i = 1, FormPlotMaxNum do
    local heroData = heroDataList[i]
    local heroWidget = self.m_HeroWidgetList[i]
    if heroWidget then
      if heroData then
        heroWidget:SetActive(true)
        heroWidget:SetHeroData(heroData.serverData, nil, nil, true)
      else
        heroWidget:SetActive(false)
      end
    end
  end
  self.m_curShowTeamHeroList = heroDataList
end

function Form_PersonalRaidCopyTeam:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_SetForm", handler(self, self.OnEventSetForm))
end

function Form_PersonalRaidCopyTeam:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PersonalRaidCopyTeam:OnEventSetForm(param)
  if not param then
    return
  end
  local formType = param.formType
  local formData = param.formData
  self:FreshOneFromTeamData(formType, formData)
  local list = {}
  for i, v in ipairs(self.m_allFormTeams[formType].heroDataList) do
    list[#list + 1] = v.serverData
  end
  StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDCOPYTIPS, {
    teamData = list,
    teamIdx = self.curChooseIndex,
    call_back = function()
      if formType == self.FormType then
        self:FreshMyTeamInfo()
      end
    end
  })
end

function Form_PersonalRaidCopyTeam:FreshOneFromTeamData(formType, formData)
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

function Form_PersonalRaidCopyTeam:OnBtnarrowLClicked()
  local idx = self.curChooseIndex - 1
  if idx < 1 then
    idx = FormTypeMaxNum
  end
  self.curChooseIndex = idx
  self:FreshMyTeamInfo()
end

function Form_PersonalRaidCopyTeam:OnBtnarrowRClicked()
  local idx = self.curChooseIndex + 1
  if idx > FormTypeMaxNum then
    idx = 1
  end
  self.curChooseIndex = idx
  self:FreshMyTeamInfo()
end

function Form_PersonalRaidCopyTeam:OnBtncopyClicked()
  local isSameServer = self:IsChooseHeroSameServer()
  if isSameServer then
    StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDCOPYTIPS, {
      teamData = self.otherPlayerTeam,
      teamIdx = self.curChooseIndex
    })
    return
  end
  local chooseHeroIDList = {}
  local is_removed = false
  for _, heroData in ipairs(self.otherPlayerTeam) do
    local id = heroData.iHeroId
    local data = HeroManager:GetHeroDataByID(id)
    if data then
      chooseHeroIDList[#chooseHeroIDList + 1] = heroData.iHeroId
    else
      is_removed = true
    end
  end
  local tips_id
  if not self.m_allFormTeams[self.FormType] and is_removed then
    tips_id = 1144
  elseif self.m_allFormTeams[self.FormType] and not is_removed then
    tips_id = 1145
  elseif self.m_allFormTeams[self.FormType] and is_removed then
    tips_id = 1146
  end
  if tips_id then
    utils.popUpDirectionsUI({
      tipsID = tips_id,
      func1 = function()
        HeroManager:ReqSetPreset(self.FormType, chooseHeroIDList)
      end
    })
  else
    HeroManager:ReqSetPreset(self.FormType, chooseHeroIDList)
  end
end

function Form_PersonalRaidCopyTeam:IsChooseHeroSameServer()
  local team = self.m_allFormTeams[self.FormType]
  if not team then
    return false
  end
  local tempSeverFormData = team.serverFormData or {}
  local heroIDList = tempSeverFormData.vHeroId or {}
  local curChooseLen = #self.otherPlayerTeam
  local serverHeroLen = #heroIDList
  if curChooseLen ~= serverHeroLen then
    return false
  end
  for _, chooseHeroData in ipairs(self.otherPlayerTeam) do
    local isHaveSame = false
    for _, serverHeroID in ipairs(heroIDList) do
      if chooseHeroData.iHeroId == serverHeroID then
        isHaveSame = true
        break
      end
    end
    if not isHaveSame then
      return false
    end
  end
  return true
end

function Form_PersonalRaidCopyTeam:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_PersonalRaidCopyTeam:OnBtncancleClicked()
  self:CloseForm()
end

function Form_PersonalRaidCopyTeam:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_PersonalRaidCopyTeam:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRaidCopyTeam", Form_PersonalRaidCopyTeam)
return Form_PersonalRaidCopyTeam
