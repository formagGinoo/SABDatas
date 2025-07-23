local Form_CastleStatueGeneralView = class("Form_CastleStatueGeneralView", require("UI/UIFrames/Form_CastleStatueGeneralViewUI"))

function Form_CastleStatueGeneralView:SetInitParam(param)
end

function Form_CastleStatueGeneralView:AfterInit()
  self.super.AfterInit(self)
  local root_trans = self.m_csui.m_uiGameObject.transform
  self.m_LevelPrefabHelper = root_trans:Find("pnl_mask/m_scrollView/Viewport/Content"):GetComponent("PrefabHelper")
  self.m_LevelPrefabHelper:RegisterCallback(handler(self, self.OnInitLevelItem))
  self.all_level_configs = StatueShowroomManager:GetAllCastleStatueLevelCfg()
  self.all_statue_configs = StatueShowroomManager:GetAllCastleStatueCfg()
  self.level_item_cache = {}
  self.statue_item_cache = {}
end

function Form_CastleStatueGeneralView:OnActive()
  self.super.OnActive(self)
  self.iRewardLevel = StatueShowroomManager:GetServerData().iRewardLevel or 0
  self:InitUI()
  GlobalManagerIns:TriggerWwiseBGMState(35)
end

function Form_CastleStatueGeneralView:InitUI()
  self.m_LevelPrefabHelper:CheckAndCreateObjs(#self.all_level_configs)
end

function Form_CastleStatueGeneralView:OnInitLevelItem(go, index)
  local idx = index + 1
  local item = self.level_item_cache[idx]
  if not item then
    local transform = go.transform
    item = {
      m_txt_rank_Text = transform:Find("m_txt_rank"):GetComponent("TMPPro"),
      m_common_item = transform:Find("c_common_item"),
      m_helepr = transform:Find("StatueList"):GetComponent("PrefabHelper")
    }
    item.m_helepr:RegisterCallback(handler(self, self.OnInitStatueListItem))
    self.level_item_cache[idx] = item
  end
  item.m_txt_rank_Text.text = idx
  local vRewardLua = utils.changeCSArrayToLuaTable(self.all_level_configs[idx].m_Rewards)
  local processData = ResourceUtil:GetProcessRewardData({
    iID = vRewardLua[1][1],
    iNum = vRewardLua[1][2]
  })
  local reward_item = self:createCommonItem(item.m_common_item)
  reward_item:SetItemInfo(processData)
  reward_item:SetItemHaveGetActive(idx <= self.iRewardLevel)
  reward_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
  self.cur_level_statue_list = StatueShowroomManager:GetLevelStatueList(idx)
  local count = #self.cur_level_statue_list > 0 and #self.cur_level_statue_list or 1
  item.m_helepr:CheckAndCreateObjs(count)
end

function Form_CastleStatueGeneralView:OnInitStatueListItem(go, index)
  local idx = index + 1
  local config = self.cur_level_statue_list[idx]
  local id = config and config.m_StatueID or 0
  local item = self.statue_item_cache[id]
  if not item or id == 0 then
    local transform = go.transform
    item = {
      m_icon = transform:Find("m_icon").gameObject,
      m_icon_gray = transform:Find("m_icon_gray").gameObject,
      m_icon_Image = transform:Find("m_icon"):GetComponent("Image"),
      m_icon_gray_Image = transform:Find("m_icon_gray"):GetComponent("Image"),
      m_icon_none = transform:Find("m_icon_none").gameObject,
      m_txt_des = transform:Find("m_txt_des").gameObject,
      m_txt_des_Text = transform:Find("m_txt_des"):GetComponent("TMPPro"),
      m_txt_des_none = transform:Find("m_txt_des_none").gameObject
    }
    if 0 < id then
      self.statue_item_cache[id] = item
    end
  end
  if id == 0 then
    item.m_icon:SetActive(false)
    item.m_icon_gray:SetActive(false)
    item.m_txt_des:SetActive(false)
    item.m_icon_none:SetActive(true)
    item.m_txt_des_none:SetActive(true)
  else
    UILuaHelper.SetAtlasSprite(item.m_icon_Image, config.m_StatuePic)
    UILuaHelper.SetAtlasSprite(item.m_icon_gray_Image, config.m_StatuePic)
    item.m_txt_des_Text.text = config.m_mStatueDes
    local server_data = StatueShowroomManager:GetServerData()
    item.m_icon:SetActive(server_data.iLevel >= config.m_StatueLevel)
    item.m_icon_gray:SetActive(server_data.iLevel < config.m_StatueLevel)
    item.m_txt_des:SetActive(true)
    item.m_icon_none:SetActive(false)
    item.m_txt_des_none:SetActive(false)
  end
end

function Form_CastleStatueGeneralView:OnInactive()
  self.super.OnInactive(self)
end

function Form_CastleStatueGeneralView:OnDestroy()
  self.super.OnDestroy(self)
  self.level_item_cache = {}
  self.statue_item_cache = {}
end

function Form_CastleStatueGeneralView:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleStatueGeneralView", Form_CastleStatueGeneralView)
return Form_CastleStatueGeneralView
