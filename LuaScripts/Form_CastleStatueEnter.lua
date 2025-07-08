local Form_CastleStatueEnter = class("Form_CastleStatueEnter", require("UI/UIFrames/Form_CastleStatueEnterUI"))

function Form_CastleStatueEnter:SetInitParam(param)
end

function Form_CastleStatueEnter:AfterInit()
  self.super.AfterInit(self)
  local root_trans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = root_trans.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1120)
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_list_InfinityGrid, "Castle/StatueItem")
  local red_dot = self.m_common_item.transform:Find("c_img_redpoint").gameObject
  self:RegisterOrUpdateRedDotItem(red_dot, RedDotDefine.ModuleType.CastleStatueReward)
end

function Form_CastleStatueEnter:OnOpen()
  self.super.OnOpen(self)
  ReportManager:ReportSystemModuleOpen("Form_CastleStatueEnter")
end

function Form_CastleStatueEnter:OnActive()
  self.super.OnActive(self)
  self:addEventListener("eGameEvent_StatueShowroom_GetReward", handler(self, self.RefreshUI))
  self:RefreshUI()
  StatueShowroomManager:CheckUpdateCastleStatueRewardHaveRed()
  self:PlayVoiceOnFirstEnter()
end

function Form_CastleStatueEnter:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function Form_CastleStatueEnter:RefreshUI()
  local statueInfo = StatueShowroomManager:GetStatueLevelInfo()
  self.m_txt_lv_num_Text.text = statueInfo.show_level
  self.m_img_line_Image.fillAmount = statueInfo.fillAmount
  self.m_num_percentage_Text.text = statueInfo.show_str
  self.m_UIFX_get:SetActive(false)
  if statueInfo.reward_info then
    local reward_item = self:createCommonItem(self.m_common_item)
    local processData = ResourceUtil:GetProcessRewardData({
      iID = statueInfo.reward_info[1],
      iNum = statueInfo.reward_info[2]
    })
    reward_item:SetItemInfo(processData)
    local server_data = StatueShowroomManager:GetServerData()
    reward_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      if server_data.iLevel > server_data.iRewardLevel then
        StatueShowroomManager:ReqGetStatusLevelReward()
      else
        CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
        utils.openItemDetailPop({iID = itemID, iNum = itemNum})
      end
    end)
    self.m_RewardNode:SetActive(true)
    self.m_item_none:SetActive(false)
    self.m_item_icon:SetActive(true)
    self.m_UIFX_get:SetActive(server_data.iLevel > server_data.iRewardLevel)
  else
    self.m_RewardNode:SetActive(false)
    self.m_item_none:SetActive(true)
    self.m_item_icon:SetActive(false)
  end
  local all_statue_configs = StatueShowroomManager:GetAllCastleStatueCfg()
  self.m_ListInfinityGrid:ShowItemList(all_statue_configs)
  UILuaHelper.SetAtlasSprite(self.m_item_icon_Image, ItemManager:GetItemIconPathByID(MTTDProto.SpecialItem_StatueExp))
  StatueShowroomManager:CheckAndPushTip()
end

function Form_CastleStatueEnter:OnBtnpreviewClicked()
  StackFlow:Push(UIDefines.ID_FORM_CASTLESTATUEGENERALVIEW)
end

function Form_CastleStatueEnter:OnNupercentageClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  local exp_count = ItemManager:GetItemNum(MTTDProto.SpecialItem_StatueExp)
  utils.openItemDetailPop({
    iID = MTTDProto.SpecialItem_StatueExp,
    iNum = exp_count
  })
end

function Form_CastleStatueEnter:OnBackClk()
  self:CloseForm()
end

function Form_CastleStatueEnter:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
  end
end

function Form_CastleStatueEnter:IsFullScreen()
  return true
end

function Form_CastleStatueEnter:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleStatueEnter:PlayVoiceOnFirstEnter()
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("CastleStatueVoice")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
end

local fullscreen = true
ActiveLuaUI("Form_CastleStatueEnter", Form_CastleStatueEnter)
return Form_CastleStatueEnter
