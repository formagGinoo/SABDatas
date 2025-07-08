local BaseNode = require("Base/BaseNode")
local UIPromptTips = class("UIPromptTips", BaseNode)

function UIPromptTips:ctor(parentObj, uiObject, params)
  if not parentObj then
    return
  end
  self.m_params = params
  self.m_parentObj = parentObj
  self.m_uiObject = uiObject
  UIPromptTips.super.ctor(self, uiObject)
  self.m_content = uiObject.transform:Find("m_content").gameObject
  self.m_reward_node = self.m_content.transform:Find("m_reward_node").gameObject
  self.m_prompt_node = self.m_content.transform:Find("m_prompt_node").gameObject
  UILuaHelper.SetActive(self.m_content, false)
  if params.popStyle == utils.PromptTipsStyle.RewardTips then
    UILuaHelper.SetActive(self.m_reward_node, true)
    UILuaHelper.SetActive(self.m_prompt_node, false)
  else
    UILuaHelper.SetActive(self.m_reward_node, false)
    UILuaHelper.SetActive(self.m_prompt_node, true)
  end
  local delay_open = self.m_params.delayOpen or 0.1
  local delay_close = self.m_params.delayClose or 2
  if 0 < delay_close then
    local sequence = Tweening.DOTween.Sequence()
    sequence:AppendInterval(delay_open + delay_close)
    sequence:OnComplete(function()
      self.m_delay_close_sequence = nil
      self:OnDestroy()
    end)
    sequence:SetAutoKill(true)
    self.m_delay_close_sequence = sequence
  end
end

function UIPromptTips:OnCreate()
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(self.m_params.delayOpen or 0.1)
  sequence:OnComplete(function()
    self.m_delay_open_sequence = nil
    self:RefreshUI()
  end)
  sequence:SetAutoKill(true)
  self.m_delay_open_sequence = sequence
end

function UIPromptTips:RefreshUI()
  UILuaHelper.SetActive(self.m_content, true)
  if self.m_params.popStyle == utils.PromptTipsStyle.RewardTips and self.m_params.rewardTab then
    local imageItem = self.m_reward_node.transform:Find("m_icon_get"):GetComponent("Image")
    local reward = self.m_params.rewardTab
    if type(self.m_params.rewardTab[1]) == "table" then
      reward = self.m_params.rewardTab[1]
    end
    ResourceUtil:CreatIconById(imageItem, reward.iID)
    local txt_props = self.m_reward_node.transform:Find("m_txt_props_name"):GetComponent(T_TextMeshProUGUI)
    local itemData = ResourceUtil:GetProcessRewardData(reward)
    txt_props.text = string.format("%s x%s", itemData.name, itemData.data_num)
  else
    local prompts = self.m_params.prompts or ""
    if type(self.m_params.prompts) == "number" then
      prompts = UnlockSystemUtil:GetLockClientMessage(self.m_params.prompts)
    end
    local txt_props = self.m_prompt_node.transform:Find("m_txt_prompt"):GetComponent(T_TextMeshProUGUI)
    txt_props.text = prompts
  end
  local delay_close = self.m_params.delayClose or 2
  if 0 < delay_close then
    local sequence = Tweening.DOTween.Sequence()
    sequence:AppendInterval(0.5)
    sequence:Append(self.m_content.transform:DOLocalMoveY(260, delay_close - 0.5))
    sequence:SetAutoKill(true)
    self.m_move_sequence = sequence
  end
end

function UIPromptTips:dispose()
  UIPromptTips.super.dispose(self)
end

function UIPromptTips:OnDestroy()
  if self.m_delay_close_sequence then
    self.m_delay_close_sequence:Kill()
    self.m_delay_close_sequence = nil
  end
  if self.m_delay_open_sequence then
    self.m_delay_open_sequence:Kill()
    self.m_delay_open_sequence = nil
  end
  if self.m_move_sequence then
    self.m_move_sequence:Kill()
    self.m_move_sequence = nil
  end
  utils.resetLookInfoTips()
  if self.m_uiObject then
    CS.UnityEngine.GameObject.Destroy(self.m_uiObject)
    self.m_uiObject = nil
  end
end

return UIPromptTips
