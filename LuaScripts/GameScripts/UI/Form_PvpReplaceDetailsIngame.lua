local Form_PvpReplaceDetailsIngame = class("Form_PvpReplaceDetailsIngame", require("UI/UIFrames/Form_PvpReplaceDetailsIngameUI"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local HeroWidgetPreStr = "c_common_hero_small"

function Form_PvpReplaceDetailsIngame:SetInitParam(param)
end

function Form_PvpReplaceDetailsIngame:AfterInit()
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
end

function Form_PvpReplaceDetailsIngame:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpReplaceDetailsIngame:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_PvpReplaceDetailsIngame:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpReplaceDetailsIngame:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_enemyIndex = tParam.enemyIndex
    self.m_mBattleFormDic = tParam.param.mBattleForm
    self.m_stRoleData = tParam.param.stRoleSimple
    self.m_battleFormList = {}
    self.m_formHeroInfoList = {}
    self.completeBattleResult = {}
    for i = 1, tParam.completeBattleResult.Count do
      self.completeBattleResult[#self.completeBattleResult + 1] = tParam.completeBattleResult[i - 1]
    end
    self:FreshFormData()
    self.m_csui.m_param = nil
  end
end

function Form_PvpReplaceDetailsIngame:ClearCacheData()
  self.m_enemyIndex = nil
  self.m_stRoleData = nil
end

function Form_PvpReplaceDetailsIngame:FreshFormData()
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
        serverHeroData.iOriLevel = nil
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

function Form_PvpReplaceDetailsIngame:AddEventListeners()
end

function Form_PvpReplaceDetailsIngame:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpReplaceDetailsIngame:FreshUI()
  if not self.m_enemyIndex then
    return
  end
  self:FreshShowForm()
  UILuaHelper.SetLocalPosition(self.m_team_root, 0, 0, 0)
end

function Form_PvpReplaceDetailsIngame:FreshShowForm()
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

function Form_PvpReplaceDetailsIngame:InitFormTeamNode(rootObj, index)
  local rootNode = rootObj.transform
  local txtTeamNum = rootNode:Find("pnl_team/txt_team"):GetComponent(T_TextMeshProUGUI)
  local txtTeamPowerNum = rootNode:Find("img_power_bg/m_txt_power"):GetComponent(T_TextMeshProUGUI)
  local formRoot = rootNode:Find("m_form_root")
  local heroWidgetList = {}
  for i = 1, FormPlotMaxNum do
    local heroNode = formRoot:Find(HeroWidgetPreStr .. i)
    local heroWid = self:createHeroIcon(heroNode)
    heroWidgetList[#heroWidgetList + 1] = heroWid
  end
  return {
    rootNode = rootNode,
    txtTeamNum = txtTeamNum,
    txtTeamPowerNum = txtTeamPowerNum,
    heroWidgetList = heroWidgetList
  }
end

function Form_PvpReplaceDetailsIngame:FreshFormTeamNode(teamNode, index)
  local formData = self.m_battleFormList[index]
  if not formData then
    return
  end
  local stFormData = formData.stForm
  teamNode.txtTeamNum.text = string.CS_Format(ConfigManager:GetCommonTextById(20112), "0" .. index)
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
  local m_icon_offensive = teamNode.rootNode:Find("m_icon_offensive").gameObject
  local m_icon_defensive = teamNode.rootNode:Find("m_icon_defensive").gameObject
  local m_icon_battle = teamNode.rootNode:Find("m_icon_battle").gameObject
  local m_icon_standby = teamNode.rootNode:Find("m_icon_standby").gameObject
  m_icon_offensive:SetActive(false)
  m_icon_defensive:SetActive(false)
  m_icon_battle:SetActive(false)
  m_icon_standby:SetActive(false)
  if index - 1 == #self.completeBattleResult then
    m_icon_battle:SetActive(true)
  elseif index - 1 < #self.completeBattleResult then
    local ret = self.completeBattleResult[index]
    if ret then
      m_icon_offensive:SetActive(true)
    else
      m_icon_defensive:SetActive(true)
    end
  else
    m_icon_standby:SetActive(true)
  end
end

function Form_PvpReplaceDetailsIngame:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_PvpReplaceDetailsIngame:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_PvpReplaceDetailsIngame:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpReplaceDetailsIngame", Form_PvpReplaceDetailsIngame)
return Form_PvpReplaceDetailsIngame
