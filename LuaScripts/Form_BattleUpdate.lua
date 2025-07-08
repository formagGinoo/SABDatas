local Form_BattleUpdate = class("Form_BattleUpdate", require("UI/UIFrames/Form_BattleUpdateUI"))
local UIItemBase = require("UI/Common/UIItemBase")
local FormPlotMaxNum = HeroManager.FormPlotMaxNum

function Form_BattleUpdate:SetInitParam(param)
end

function Form_BattleUpdate:AfterInit()
  self.super.AfterInit(self)
  self.m_HeroWidgetList = {}
  self.m_otherHeroWidgetList = {}
  self.otherPlayerTeam = {}
  self.otherPlayerPosTab = {}
  self.oterTotalPower = 0
  self.parentForm = {}
  self:InitHeroWidgets()
  self.grayMat = self.m_GrayMat_Image_Image.material
end

function Form_BattleUpdate:InitHeroWidgets()
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

function Form_BattleUpdate:OnActive()
  self.super.OnActive(self)
  self:ReSetBtn(false)
  self:FreshData()
  self:FreshUI()
end

function Form_BattleUpdate:OnInactive()
  self.super.OnInactive(self)
end

function Form_BattleUpdate:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattleUpdate:FreshData()
  self.FormTypeBase = HeroManager.TeamTypeBase.SoloRaid
  if self.m_csui.m_param then
    self.otherPlayerTeam = self.m_csui.m_param.otherPlayerTeam or {}
    self.otherPlayerPosTab = self.m_csui.m_param.otherPlayerPosTab or {}
    self.oterTotalPower = self.m_csui.m_param.oterTotalPower or 0
    self.parentForm = self.m_csui.m_param.parentForm or {}
  end
end

function Form_BattleUpdate:FreshUI()
  self:FreshOtherPlayerTeamInfo()
  local teamData = utils.changeCSArrayToLuaTable(BattleGlobalManager:GetFormationHeros()) or {}
  self:FreshMyTeamInfo(teamData)
end

function Form_BattleUpdate:FreshOtherPlayerTeamInfo()
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
  self.m_txt_power_Text.text = self.oterTotalPower
end

function Form_BattleUpdate:FreshMyTeamInfo(teamData)
  self.myTeamData = {}
  for i = 1, #self.m_HeroWidgetList do
    local heroData = HeroManager:GetHeroDataByID(teamData[i])
    local heroWidget = self.m_HeroWidgetList[i]
    if heroWidget then
      if heroData then
        self.myTeamData[#self.myTeamData + 1] = heroData.serverData
        heroWidget:SetActive(true)
        heroWidget:SetHeroData(heroData.serverData, nil, nil, true)
      else
        heroWidget:SetActive(false)
      end
    end
  end
  self.m_txt_powermine_Text.text = self:GetMyTeamPower()
end

function Form_BattleUpdate:GetMyTeamPower()
  local power = 0
  for i = 1, #self.myTeamData do
    power = power + self.myTeamData[i].iPower
  end
  return power
end

function Form_BattleUpdate:ReplaceHero()
  local list = {}
  local myList = {}
  for i, v in ipairs(self.chooseHeroIDList) do
    list[#list + 1] = HeroManager:GetHeroDataByID(v.iHeroId).serverData
    myList[#myList + 1] = v.iHeroId
  end
  StackPopup:Push(UIDefines.ID_FORM_REFEROTHERTEAMCOPYTIPS, {
    teamData = list,
    call_back = function()
      self:FreshMyTeamInfo(myList)
    end
  })
  self:ReSetBtn(true)
end

function Form_BattleUpdate:ReSetBtn(isActive)
  UILuaHelper.SetActive(self.m_btn_cancle, isActive)
  UILuaHelper.SetActive(self.m_btn_sure, isActive)
  UILuaHelper.SetActive(self.m_btn_copy, not isActive)
end

function Form_BattleUpdate:OnBtncopyClicked()
  self.chooseHeroIDList = {}
  local is_removed = false
  for _, heroData in ipairs(self.otherPlayerPosTab) do
    local id = heroData.iHeroId
    if not BattleGlobalManager:CheckTrailHero(id) then
      local data = HeroManager:GetHeroDataByID(id)
      if data then
        self.chooseHeroIDList[#self.chooseHeroIDList + 1] = heroData
      else
        is_removed = true
      end
    end
  end
  local tips_id
  if is_removed then
    tips_id = 1144
  end
  if tips_id then
    utils.popUpDirectionsUI({
      tipsID = tips_id,
      func1 = function()
        self:ReplaceHero()
      end
    })
  else
    self:ReplaceHero()
  end
end

function Form_BattleUpdate:OnBtnsureClicked()
  self:CloseForm()
  self.parentForm:CloseForm()
  BattleGlobalManager:DeFormationAll()
  BattleGlobalManager:ReplaceFormation(self.chooseHeroIDList)
end

function Form_BattleUpdate:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_BattleUpdate:OnBtncancleClicked()
  self:CloseForm()
end

function Form_BattleUpdate:OnBtnCloseClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_BattleUpdate", Form_BattleUpdate)
return Form_BattleUpdate
