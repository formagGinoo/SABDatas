local Form_PvpReplaceDetails = class("Form_PvpReplaceDetails", require("UI/UIFrames/Form_PvpReplaceDetailsUI"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local HeroWidgetPreStr = "c_common_hero_small"

function Form_PvpReplaceDetails:SetInitParam(param)
end

function Form_PvpReplaceDetails:AfterInit()
  self.super.AfterInit(self)
  self.m_enemyIndex = nil
  self.m_stRoleData = nil
  self.m_battleFormList = nil
  self.m_formHeroInfoList = nil
  self.m_formTeamNodeList = {}
  local teamNode = self:InitFormTeamNode(self.m_item_team, 1)
  self.m_teamItemNameStr = self.m_item_team.name
  self.m_item_team.name = self.m_teamItemNameStr .. 1
  self.m_formTeamNodeList[#self.m_formTeamNodeList + 1] = teamNode
  self.m_backFun = nil
end

function Form_PvpReplaceDetails:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpReplaceDetails:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_PvpReplaceDetails:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpReplaceDetails:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_enemyIndex = tParam.enemyIndex
    self.m_mBattleFormDic = tParam.param.mBattleForm
    self.m_stRoleData = tParam.param.stRoleSimple
    self.inbattle = tParam.inbattle
    self.m_battleFormList = {}
    self.m_formHeroInfoList = {}
    self.m_backFun = tParam.backFun
    self.m_enemyData = tParam.enemyData
    self:FreshFormData()
    self.m_csui.m_param = nil
  end
end

function Form_PvpReplaceDetails:ClearCacheData()
  self.m_enemyIndex = nil
  self.m_stRoleData = nil
end

function Form_PvpReplaceDetails:FreshFormData()
  if not self.m_mBattleFormDic then
    return
  end
  local tempList = {}
  local tempFormHeroList = {}
  self.m_battleFormList = {}
  self.m_formHeroInfoList = {}
  for key, tempFormData in pairs(self.m_mBattleFormDic) do
    local tempListFormData = {key = key, formData = tempFormData}
    tempList[#tempList + 1] = tempListFormData
    local stFormData = tempFormData.stForm
    local serverHeroDataDic = tempFormData.mCmdHero
    local heroList = stFormData.vHero
    local tempFormHeroDataList = {}
    for _, v in ipairs(heroList) do
      local heroID = v.iHeroId
      local serverHeroData = serverHeroDataDic[heroID]
      if serverHeroData then
        tempFormHeroDataList[#tempFormHeroDataList + 1] = serverHeroData
      end
    end
    local tempFormHeroData = {key = key, formHeroDataList = tempFormHeroDataList}
    tempFormHeroList[#tempFormHeroList + 1] = tempFormHeroData
  end
  table.sort(tempList, function(a, b)
    return a.key < b.key
  end)
  table.sort(tempFormHeroList, function(a, b)
    return a.key < b.key
  end)
  for i, v in ipairs(tempList) do
    self.m_battleFormList[#self.m_battleFormList + 1] = v.formData
  end
  for i, v in ipairs(tempFormHeroList) do
    self.m_formHeroInfoList[#self.m_formHeroInfoList + 1] = v.formHeroDataList
  end
end

function Form_PvpReplaceDetails:AddEventListeners()
  self:addEventListener("eGameEvent_ReplaceArena_SeasonInit", handler(self, self.OnSeasonInit))
end

function Form_PvpReplaceDetails:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpReplaceDetails:OnSeasonInit()
  self:CloseForm()
end

function Form_PvpReplaceDetails:FreshUI()
  if not self.m_enemyIndex then
    return
  end
  self:FreshBaseInfo()
  self:FreshShowForm()
  UILuaHelper.SetLocalPosition(self.m_team_root, 0, 0, 0)
  if self.inbattle then
    self.m_btn_Battle:SetActive(false)
  else
    self.m_btn_Battle:SetActive(true)
  end
  self:RefreshBattleTips()
end

function Form_PvpReplaceDetails:FreshBaseInfo()
  local playerNameStr = RoleManager:GetName()
  self.m_txt_name_Text.text = playerNameStr
  local enemyNameStr = self.m_stRoleData.sName
  self.m_txt_rival_name_Text.text = enemyNameStr
end

function Form_PvpReplaceDetails:FreshShowForm()
  if not self.m_battleFormList then
    return
  end
  local itemWidgets = self.m_formTeamNodeList
  local dataLen = #self.m_battleFormList
  local parentTrans = self.m_team_root
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      self:FreshFormTeamNode(itemWidget, i)
      UILuaHelper.SetActive(itemWidget.rootNode, true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_item_team, parentTrans.transform).gameObject
      local itemWidget = self:InitFormTeamNode(itemObj)
      itemWidgets[#itemWidgets + 1] = itemWidget
      self:FreshFormTeamNode(itemWidget, i)
      UILuaHelper.SetActive(itemWidget.rootNode, true)
    elseif i <= childCount and i > dataLen then
      UILuaHelper.SetActive(itemWidgets[i].rootNode, false)
    end
  end
end

function Form_PvpReplaceDetails:InitFormTeamNode(rootObj, index)
  local rootNode = rootObj.transform
  local txtTeamNum = rootNode:Find("txt_team_num"):GetComponent(T_TextMeshProUGUI)
  local txtTeamPowerNum = rootNode:Find("img_power_bg/m_txt_power"):GetComponent(T_TextMeshProUGUI)
  local formRoot = rootNode:Find("m_form_root")
  local heroWidgetList = {}
  for i = 1, FormPlotMaxNum do
    local heroNode = formRoot:Find(HeroWidgetPreStr .. i)
    local heroWid = self:createHeroIcon(heroNode)
    heroWid:SetHeroIconClickCB(function()
      self:OnHeroIconClk(index, i)
    end)
    heroWidgetList[#heroWidgetList + 1] = heroWid
  end
  return {
    rootNode = rootNode,
    txtTeamNum = txtTeamNum,
    txtTeamPowerNum = txtTeamPowerNum,
    heroWidgetList = heroWidgetList
  }
end

function Form_PvpReplaceDetails:FreshFormTeamNode(teamNode, index)
  local formData = self.m_battleFormList[index]
  if not formData then
    return
  end
  local stFormData = formData.stForm
  teamNode.txtTeamNum.text = "0" .. index
  teamNode.txtTeamPowerNum.text = stFormData.iPower or 0
  local heroInfoList = self.m_formHeroInfoList[index]
  for i = 1, FormPlotMaxNum do
    local formHeroData = heroInfoList[i]
    local heroIcon = teamNode.heroWidgetList[i]
    if heroIcon then
      if formHeroData then
        heroIcon:SetActive(true)
        heroIcon:SetHeroData(formHeroData)
      else
        heroIcon:SetActive(false)
      end
    end
  end
end

function Form_PvpReplaceDetails:OnBtnCloseClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceDetails:OnBtnReturnClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceDetails:OnBtnBattleClicked()
  BattleFlowManager:StartEnterBattle(PvpReplaceManager.LevelType.ReplacePVP, PvpReplaceManager.BattleEnterSubType.Attack, self.m_enemyIndex)
end

function Form_PvpReplaceDetails:OnHeroIconClk(teamIndex, i)
end

function Form_PvpReplaceDetails:RefreshBattleTips()
  UILuaHelper.SetActive(self.m_pnl_enemy_tips, false)
  if self.m_enemyData and self.m_enemyData.enemyData then
    local curRank = PvpReplaceManager:GetSeasonRank()
    if curRank <= 3 and curRank < self.m_enemyData.enemyData.iRank then
      UILuaHelper.SetActive(self.m_pnl_enemy_tips, true)
    end
  end
end

function Form_PvpReplaceDetails:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpReplaceDetails", Form_PvpReplaceDetails)
return Form_PvpReplaceDetails
