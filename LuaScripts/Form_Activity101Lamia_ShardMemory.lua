local Form_Activity101Lamia_ShardMemory = class("Form_Activity101Lamia_ShardMemory", require("UI/UIFrames/Form_Activity101Lamia_ShardMemoryUI"))

function Form_Activity101Lamia_ShardMemory:SetInitParam(param)
end

function Form_Activity101Lamia_ShardMemory:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.text_item_cache = {}
  self.m_pnl_txt:SetActive(false)
  self.m_txt_time_Text = goRoot.transform:Find("content_node/pnl_2/txt_time"):GetComponent("TMPPro")
  self.m_txt_place_Text = goRoot.transform:Find("content_node/pnl_1/txt_place"):GetComponent("TMPPro")
end

function Form_Activity101Lamia_ShardMemory:OnActive()
  self.super.OnActive(self)
  local params = self.m_csui.m_param
  self.cur_text_index = params.cur_text_index
  self.config = params.config
  self.m_MemoryID = self.config.m_MemoryID
  self.call_back = params.call_back
  self.m_ChoiceTime = utils.changeCSArrayToLuaTable(self.config.m_ChoiceTime)
  self.m_ChoicePlace = utils.changeCSArrayToLuaTable(self.config.m_ChoicePlace)
  self.m_btn_end:SetActive(params.is_done)
  if not self.cur_text_index then
    local text_config = HeroActivityManager:GetFormatActMemoryTextCfgByID(self.m_MemoryID)
    local text_list = text_config[HeroActivityManager.ActMemoryTextType.Final]
    local min_idx
    for k, v in pairs(text_list) do
      if not min_idx then
        min_idx = k
      elseif k < min_idx then
        min_idx = k
      end
    end
    self.cur_text_index = min_idx
  end
  self.m_iTouchClickLastTime = 0
  local time_cfg = HeroActivityManager:GetActMemoryChoiceByTypeAndChoiceID(self.m_ChoiceTime[1], self.m_ChoiceTime[2])
  local place_cfg = HeroActivityManager:GetActMemoryChoiceByTypeAndChoiceID(self.m_ChoicePlace[1], self.m_ChoicePlace[2])
  self.m_txt_time_Text.text = time_cfg.m_mText
  self.m_txt_place_Text.text = place_cfg.m_mText
  UILuaHelper.SetAtlasSprite(self.m_icon_time_Image, time_cfg.m_Pic1)
  UILuaHelper.SetAtlasSprite(self.m_icon_place_Image, place_cfg.m_Pic1)
  UILuaHelper.SetAtlasSprite(self.m_icon_item_Image, ItemManager:GetItemIconPathByID(self.config.m_Item))
  UILuaHelper.SetAtlasSprite(self.m_img_pic_Image, self.config.m_Pic)
  self:FreshUI()
end

local function __ShowCurText(self, config)
  local item = self.text_item_cache[self.cur_text_index]
  if not item then
    local obj = GameObject.Instantiate(self.m_pnl_txt, self.m_pnl_txt.transform.parent).gameObject
    local trans = obj.transform
    item = {
      obj = obj,
      m_bg_title_name_Image = trans:Find("m_bg_title_name"):GetComponent("Image"),
      m_txt_name_Text = trans:Find("m_bg_title_name/m_txt_name"):GetComponent("TMPPro"),
      m_CommonTMPTypewriter = trans:Find("m_txt_content"):GetComponent("CommonTMPTypewriter"),
      m_txt_content_Text = trans:Find("m_txt_content"):GetComponent("TMPPro")
    }
    self.text_item_cache[self.cur_text_index] = item
  end
  item.obj.transform:SetSiblingIndex(self.cur_text_index)
  item.obj:SetActive(true)
  local color_rgb = string.split(config.m_NameColor, ",")
  color_rgb[4] = color_rgb[4] or 255
  item.m_bg_title_name_Image.color = Color(color_rgb[1] / 255, color_rgb[2] / 255, color_rgb[3] / 255, color_rgb[4] / 255)
  item.m_txt_name_Text.text = config.m_mName
  self.cur_TMPtween = item.m_CommonTMPTypewriter
  self.is_typing = true
  self.m_btn_continue:SetActive(false)
  self.m_btn_touch:SetActive(true)
  self.cur_TMPtween:StartTypeweiteByFixedSpeed(config.m_mText, function()
    self.is_typing = false
    self.m_btn_continue:SetActive(true)
    self.m_btn_touch:SetActive(false)
  end)
end

function Form_Activity101Lamia_ShardMemory:OnInactive()
  self.super.OnInactive(self)
  if self.text_item_cache then
    for k, v in pairs(self.text_item_cache) do
      v.obj:SetActive(false)
    end
  end
end

function Form_Activity101Lamia_ShardMemory:FreshUI()
  local text_config = HeroActivityManager:GetFormatActMemoryTextCfgByID(self.m_MemoryID)
  local text_list = text_config[HeroActivityManager.ActMemoryTextType.Final]
  local config = text_list[self.cur_text_index]
  if config then
    __ShowCurText(self, config)
  else
    self.m_btn_end:SetActive(true)
  end
end

function Form_Activity101Lamia_ShardMemory:OnBtntouchClicked()
  local iDiff = CS.Util.GetTime() - self.m_iTouchClickLastTime
  self.m_iTouchClickLastTime = CS.Util.GetTime()
  if iDiff <= 300 and self.cur_TMPtween and self.is_typing then
    self.cur_TMPtween:StopTypewrite()
    return
  end
end

function Form_Activity101Lamia_ShardMemory:OnBtncontinueClicked()
  self.m_btn_continue:SetActive(false)
  self.m_btn_touch:SetActive(true)
  self.cur_text_index = self.cur_text_index + 1
  self:FreshUI()
end

function Form_Activity101Lamia_ShardMemory:OnBackClk()
  self:CloseForm()
  if self.call_back then
    self.call_back()
    self.call_back = nil
  end
end

function Form_Activity101Lamia_ShardMemory:OnBtnendClicked()
  self:CloseForm()
  if self.call_back then
    self.call_back()
    self.call_back = nil
  end
end

function Form_Activity101Lamia_ShardMemory:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_ShardMemory", Form_Activity101Lamia_ShardMemory)
return Form_Activity101Lamia_ShardMemory
