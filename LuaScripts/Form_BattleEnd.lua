local Form_BattleEnd = class("Form_BattleEnd", require("UI/UIFrames/Form_BattleEndUI"))

function Form_BattleEnd:SetInitParam(param)
end

function Form_BattleEnd:AfterInit()
  self.m_RewarListPanel_InfinityGrid:RegisterBindCallback(handler(self, self.OnBindReward))
  self.tableRewardID = {}
  self.tableRewardCnt = {}
  self.m_bPassEnd = false
  self._nMapID = 0
  self._nPassID = 0
  self._BattleConfigID = 0
  self._bPvp = false
end

function Form_BattleEnd:OnActive()
  self:OnInitData()
end

function Form_BattleEnd:OnInitData()
  self._nMapID = CS.GlobalManager.Instance:GetBattleWorldID()
  self._nAreaID = CS.GlobalManager.Instance:GetBattleAreaID()
  local mapData = ConfigManager:GetBattleWorldCfgById(self._nMapID)
  if mapData:GetError() then
    log.error("mapID error " .. tostring(self._nMapID))
    return
  end
  local result = CS.BattleGameManager.Instance:GetWinResult()
  self.m_TextResult_Text.text = "战斗胜利！"
  if self._bPvp then
    self.m_Reward:SetActive(false)
  else
    self.m_Reward:SetActive(true)
  end
  self.m_Bg_button:SetActive(true)
  self.m_TextClickBack:SetActive(true)
  self.m_ButtonAgain:SetActive(false)
  self.m_ButtonBack:SetActive(false)
  goto lbl_112
  self.m_TextResult_Text.text = "战斗失败！"
  if self._bPvp then
    self.m_ButtonAgain:SetActive(false)
    self.m_ButtonBack:SetActive(false)
    self.m_Reward:SetActive(false)
    self.m_Bg_button:SetActive(true)
    self.m_TextClickBack:SetActive(true)
  else
    self.m_ButtonAgain:SetActive(true)
    self.m_ButtonBack:SetActive(true)
    self.m_Reward:SetActive(false)
    self.m_Bg_button:SetActive(false)
    self.m_TextClickBack:SetActive(false)
  end
  ::lbl_112::
  self.m_bPassEnd = false
  if self._nPassID > mapData.m_BattleConfigID.Length then
    self.m_bPassEnd = true
    return
  end
  self._BattleConfigID = tonumber(mapData.m_BattleConfigID[self._nPassID])
  local battleConfigData = CS.CData_BattleConfig.GetInstance():GetValue_ByID(self._BattleConfigID)
  if battleConfigData:GetError() then
    log.error("battleConfigData error " .. tostring(self._BattleConfigID))
    return
  end
  local nRewardCount = battleConfigData.m_Reward.Length
  self.m_RewarListPanel_InfinityGrid:Clear()
  if 0 < nRewardCount then
    for i = 0, nRewardCount - 1 do
      local tabItem = string.split(battleConfigData.m_Reward[i], "|")
      if 2 <= #tabItem then
        local itemID = tonumber(tabItem[1])
        local itemCnt = tonumber(tabItem[2])
        table.insert(self.tableRewardID, itemID)
        table.insert(self.tableRewardCnt, itemCnt)
      end
    end
    self.m_RewarListPanel_InfinityGrid.TotalItemCount = nRewardCount
  end
end

function Form_BattleEnd:OnBindReward(cache, go, index)
  local itemID = self.tableRewardID[index + 1]
  local itemCnt = self.tableRewardCnt[index + 1]
  local itemData = CS.CData_Item.GetInstance():GetValue_ByItemID(itemID)
  if itemData:GetError() then
    log.error("OnBindReward item id  " .. tostring(itemID))
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(cache:Image("c_RewardIcon"), itemData.m_IconPath)
  cache:TMPPro("c_RewardNum").text = tostring(itemCnt)
end

function Form_BattleEnd:OnBgbuttonClicked()
  self:CloseForm()
end

function Form_BattleEnd:OnButtonBackClicked()
  CS.BattleGameManager.Instance:ResetCurrentPassID()
  self:CloseForm()
end

function Form_BattleEnd:OnClearCardPoolData()
  local szKey = "NovaCardPoolData"
  local str = ""
  CS.UnityEngine.PlayerPrefs.SetString(szKey, str)
end

function Form_BattleEnd:OnButtonAgainClicked()
  CS.BattleGameManager.Instance:ResetCurrentPassID()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_BattleEnd", Form_BattleEnd)
return Form_BattleEnd
