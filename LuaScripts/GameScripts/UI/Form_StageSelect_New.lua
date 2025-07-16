local Form_StageSelect_New = class("Form_StageSelect_New", require("UI/UIFrames/Form_StageSelect_NewUI"))

function Form_StageSelect_New:SetInitParam(param)
end

function Form_StageSelect_New:AfterInit()
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_ListPanel_InfinityGrid:RegisterBindCallback(handler(self, self.OnBind))
  self.m_ListPanel_InfinityGrid:RegisterButtonCallback("c_EnterButton", handler(self, self.OnEnterClick))
  self.tableMapID = {}
  CS.ShowRoomManagerS.Instance:Init()
end

function Form_StageSelect_New:OnActive()
  self:OnInitData()
end

function Form_StageSelect_New:OnUpdate(dt)
end

function Form_StageSelect_New:OnInitData()
  self.tableMapID = {}
  local slkDataAll = CS.CData_BattleWorld.GetInstance():GetAll()
  for k, v in pairs(slkDataAll) do
    table.insert(self.tableMapID, k)
  end
  self.m_ListPanel_InfinityGrid:Clear()
  self.m_ListPanel_InfinityGrid.TotalItemCount = table.getn(self.tableMapID)
  self.m_InputLevelId_TMP_InputField.text = CS.UnityEngine.PlayerPrefs.GetInt("DebugWorldId")
end

function Form_StageSelect_New:OnBind(cache, go, index)
  local mapID = self.tableMapID[index + 1]
  local slkData = ConfigManager:GetBattleWorldCfgById(mapID)
  if slkData:GetError() then
    return
  end
  cache:TMPPro("c_Demo_Name").text = ConfigManager:BattleWorldMapName(slkData)
  cache:TMPPro("c_Index").text = tostring(index + 1)
  go.name = index
end

function Form_StageSelect_New:OnEnterClick(index, go)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  local mapID = self.tableMapID[index + 1]
  local slkData = ConfigManager:GetBattleWorldCfgById(mapID)
  if slkData:GetError() then
    return
  end
  LevelManager:SetDebugLevelData()
  CS.BattleGlobalManager.Instance:EnterPVEBattle(mapID)
  CS.UnityEngine.PlayerPrefs.SetInt("DebugWorldId", mapID)
  self:CloseForm()
end

function Form_StageSelect_New:OnQuickEnterClicked()
  local id = self.m_InputLevelId_TMP_InputField.text
  local confData = ConfigManager:GetBattleWorldCfgById(tonumber(id))
  if confData:GetError() then
    return
  end
  LevelManager:SetDebugLevelData()
  CS.BattleGlobalManager.Instance:EnterPVEBattle(tonumber(id))
  CS.UnityEngine.PlayerPrefs.SetInt("DebugWorldId", tonumber(id))
  self:CloseForm()
end

function Form_StageSelect_New:OnBackClk()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_STAGESELECT_NEW)
end

local fullscreen = true
ActiveLuaUI("Form_StageSelect_New", Form_StageSelect_New)
return Form_StageSelect_New
