local Form_Activity101Lamia_ShardTable = class("Form_Activity101Lamia_ShardTable", require("UI/UIFrames/Form_Activity101Lamia_ShardTableUI"))

function Form_Activity101Lamia_ShardTable:SetInitParam(param)
end

function Form_Activity101Lamia_ShardTable:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_btn_symbol:SetActive(false)
  local item_cache = {}
  for i = 1, 7 do
    item_cache[i] = {
      go = goRoot.transform:Find("content_node/btn_item" .. i).gameObject,
      btn = goRoot.transform:Find("content_node/btn_item" .. i):GetComponent("Button")
    }
    item_cache[i].go:SetActive(false)
  end
  self.item_cache = item_cache
end

function Form_Activity101Lamia_ShardTable:OnActive()
  self.super.OnActive(self)
  self.format_configs = self.m_csui.m_param
  CS.GlobalManager.Instance:TriggerWwiseBGMState(146)
  self:FreshUI()
end

function Form_Activity101Lamia_ShardTable:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity101Lamia_ShardTable:FreshUI()
  for i, config in ipairs(self.format_configs) do
    local pos_idx = config.m_Position
    local item = self.item_cache[pos_idx]
    self["m_txt_bg_name" .. pos_idx .. "_Text"].text = ItemManager:GetItemName(config.m_Item)
    local num = ItemManager:GetItemNum(config.m_Item)
    local is_got = num and 0 < num
    item.go:SetActive(is_got)
    item.btn.onClick:RemoveAllListeners()
    item.btn.onClick:AddListener(function()
      StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDITEM, {
        item_id = config.m_Item
      })
    end)
  end
end

function Form_Activity101Lamia_ShardTable:OnBackClk()
  self:CloseForm()
end

function Form_Activity101Lamia_ShardTable:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity101Lamia_ShardTable:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_ShardTable", Form_Activity101Lamia_ShardTable)
return Form_Activity101Lamia_ShardTable
