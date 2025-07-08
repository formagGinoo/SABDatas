local Form_PvpMainPopup = class("Form_PvpMainPopup", require("UI/UIFrames/Form_PvpMainPopupUI"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum

function Form_PvpMainPopup:SetInitParam(param)
end

function Form_PvpMainPopup:AfterInit()
  self.super.AfterInit(self)
  self.m_enemyIndex = nil
  self.m_stRoleData = nil
  self.m_stFormData = nil
  self.m_serverHeroDataDic = nil
  self.m_heroWidgetList = {}
  self:CreateFormHeroWidgetList()
end

function Form_PvpMainPopup:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpMainPopup:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_PvpMainPopup:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpMainPopup:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_enemyIndex = tParam.enemyIndex
    self.m_stFormData = tParam.param.stForm
    self.m_stRoleData = tParam.param.stRoleSimpleInfo
    self.m_serverHeroDataDic = tParam.param.mCmdHero
    self:FreshFormData()
    self.m_csui.m_param = nil
  end
end

function Form_PvpMainPopup:ClearCacheData()
  self.m_enemyIndex = nil
  self.m_stRoleData = nil
  self.m_stFormData = nil
  self.m_serverHeroDataDic = nil
end

function Form_PvpMainPopup:FreshFormData()
  if not self.m_stFormData then
    return
  end
  self.m_heroFormDataList = {}
  local heroList = self.m_stFormData.vHero
  for _, v in ipairs(heroList) do
    local heroID = v.iHeroId
    local serverHeroData = self.m_serverHeroDataDic[heroID]
    if serverHeroData then
      local heroData = ArenaManager:GeneratePvpHeroModifyData(serverHeroData)
      self.m_heroFormDataList[#self.m_heroFormDataList + 1] = heroData
    end
  end
end

function Form_PvpMainPopup:AddEventListeners()
  self:addEventListener("eGameEvent_Level_ArenaUnknown", handler(self, self.OnEnemyUnknown))
  self:addEventListener("eGameEvent_Arena_SeasonInit", handler(self, self.OnSeasonInit))
end

function Form_PvpMainPopup:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpMainPopup:OnEnemyUnknown()
  self:CloseForm()
end

function Form_PvpMainPopup:OnSeasonInit()
  self:CloseForm()
end

function Form_PvpMainPopup:CreateFormHeroWidgetList()
  for i = 1, FormPlotMaxNum do
    local tempHeroRoot = self.m_form_root.transform:Find("c_common_hero_middle" .. i)
    local heroWid
    if tempHeroRoot then
      heroWid = self:createHeroIcon(tempHeroRoot)
      heroWid:SetHeroIconClickCB(function()
        self:OnHeroIconClk(i)
      end)
      self.m_heroWidgetList[#self.m_heroWidgetList + 1] = heroWid
    end
  end
end

function Form_PvpMainPopup:FreshUI()
  if not self.m_enemyIndex then
    return
  end
  self:FreshBaseInfo()
  self:FreshShowForm()
end

function Form_PvpMainPopup:FreshBaseInfo()
  local playerNameStr = RoleManager:GetName()
  self.m_txt_name_Text.text = playerNameStr
  local enemyNameStr = self.m_stRoleData.sName
  self.m_txt_rival_name_Text.text = enemyNameStr
end

function Form_PvpMainPopup:FreshShowForm()
  if not self.m_stFormData then
    return
  end
  self.m_txt_power_Text.text = self.m_stFormData.iPower or 0
  self:FreshShowFormList()
end

function Form_PvpMainPopup:FreshShowFormList()
  if not self.m_heroWidgetList then
    return
  end
  if not next(self.m_heroWidgetList) then
    return
  end
  for i = 1, FormPlotMaxNum do
    local formHeroData = self.m_heroFormDataList[i]
    local heroIcon = self.m_heroWidgetList[i]
    if heroIcon then
      if formHeroData then
        heroIcon:SetActive(true)
        heroIcon:SetHeroData(formHeroData, nil, nil, true)
      else
        heroIcon:SetActive(false)
      end
    end
  end
end

function Form_PvpMainPopup:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_PvpMainPopup:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_PvpMainPopup:OnBtnBattleClicked()
  BattleFlowManager:StartEnterBattle(BattleFlowManager.ArenaType.Arena, BattleFlowManager.ArenaSubType.ArenaBattle, self.m_enemyIndex)
end

function Form_PvpMainPopup:OnHeroIconClk(i)
end

function Form_PvpMainPopup:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpMainPopup", Form_PvpMainPopup)
return Form_PvpMainPopup
