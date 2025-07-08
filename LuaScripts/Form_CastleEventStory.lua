local Form_CastleEventStory = class("Form_CastleEventStory", require("UI/UIFrames/Form_CastleEventStoryUI"))

function Form_CastleEventStory:SetInitParam(param)
end

function Form_CastleEventStory:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("m_content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_btn_home:SetActive(false)
  self.m_btn_symbol:SetActive(false)
  self.itemHelper = self.m_Content:GetComponent("PrefabHelper")
end

function Form_CastleEventStory:OnActive()
  self.super.OnActive(self)
  self.cfgs = self.m_csui.m_param.cfg
  local storyList = self.m_csui.m_param.cache
  utils.ShowPrefabHelper(self.itemHelper, handler(self, self.OnInitStoryItem), storyList)
  self.m_scrollview_story:GetComponent("ScrollRect").normalizedPosition = CS.UnityEngine.Vector2(0, 0)
  local infocfg = CastleStoryManager:GetCastleStoryInfoCfgByStoryID(self.cfgs[1].m_StoryID)
  self.m_txt_plot_Text.text = infocfg.m_mTitle
end

function Form_CastleEventStory:OnInactive()
  self.super.OnInactive(self)
end

function Form_CastleEventStory:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleEventStory:OnInitStoryItem(go, index, data)
  local transform = go.transform
  local node_role = transform:Find("pnl_role").gameObject
  local node_choose = transform:Find("pnl_selectrcord").gameObject
  local node_player = transform:Find("pnl_player").gameObject
  local cfg = self.cfgs[data.ID[1]]
  node_role:SetActive(false)
  node_choose:SetActive(false)
  node_player:SetActive(false)
  if data.textType == CastleStoryManager.TextTypeEnum.Choose then
    node_choose:SetActive(true)
    local ids = data.ID
    local helper = node_choose.transform:Find("pnl_choose"):GetComponent("PrefabHelper")
    utils.ShowPrefabHelper(helper, handler(self, self.OnInitChooseItem), ids, data.chooseIdx)
  else
    local is_leader = data.is_leader
    if is_leader then
      node_player:SetActive(true)
      node_player.transform:Find("c_txt_playername"):GetComponent("TMPPro").text = cfg.m_mName
      node_player.transform:Find("c_txt_playertalk"):GetComponent("TMPPro").text = cfg.m_mText
    else
      node_role:SetActive(true)
      if cfg.m_Speaker > 0 then
        node_role.transform:Find("c_txt_rolename"):GetComponent("TMPPro").text = cfg.m_mName
      else
        node_role.transform:Find("c_txt_rolename"):GetComponent("TMPPro").text = ConfigManager:GetClientMessageTextById(48004)
      end
      node_role.transform:Find("c_txt_roletalk"):GetComponent("TMPPro").text = cfg.m_mText
    end
  end
end

function Form_CastleEventStory:OnInitChooseItem(go, index, textID, chooseIdx)
  local transform = go.transform
  local cfg = self.cfgs[textID]
  local txt_choose_Text = transform:Find("c_txt_choose"):GetComponent("TMPPro")
  txt_choose_Text.text = cfg.m_mText
  local obj_sel = transform:Find("pnl_choosesel").gameObject
  obj_sel:SetActive(index + 1 == chooseIdx)
  local txt_choosesel_Text = transform:Find("pnl_choosesel/c_txt_choosesel"):GetComponent("TMPPro")
  txt_choosesel_Text.text = cfg.m_mText
end

function Form_CastleEventStory:OnBackClk()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_CastleEventStory", Form_CastleEventStory)
return Form_CastleEventStory
