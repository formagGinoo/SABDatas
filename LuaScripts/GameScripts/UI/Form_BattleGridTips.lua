local Form_BattleGridTips = class("Form_BattleGridTips", require("UI/UIFrames/Form_BattleGridTipsUI"))

function Form_BattleGridTips:SetInitParam(param)
end

function Form_BattleGridTips:AfterInit()
  self.super.AfterInit(self)
  self.itemGos = {}
  for i = 1, self.m_pnl_list.transform.childCount do
    table.insert(self.itemGos, self.m_pnl_list.transform:GetChild(i - 1).gameObject)
  end
end

function Form_BattleGridTips:OnActive()
  self.super.OnActive(self)
  self:InitView(self.m_csui.m_param)
end

function Form_BattleGridTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_BattleGridTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattleGridTips:InitView(gridEffectIds)
  for i = 1, #self.itemGos do
    self.itemGos[i]:SetActive(false)
  end
  for i = 1, gridEffectIds.Count do
    if i < #self.itemGos then
      local itemObj = self.itemGos[i]
      itemObj:SetActive(true)
      local cfg = CS.CData_GridEffect.GetInstance():GetValue_ByID(gridEffectIds[i - 1])
      if not cfg:GetError() then
        if CS.UI.UILuaHelper.GetGridEffectDescribe(gridEffectIds[i - 1]) ~= "" then
          UILuaHelper.SetAtlasSprite(itemObj.transform:Find("img_plot"):GetComponent(T_Image), cfg.m_Icon, nil, nil, true)
          itemObj.transform:Find("pnl_title/txt_plot_title"):GetComponent(T_TextMeshProUGUI).text = cfg.m_mName
          itemObj.transform:Find("txt_plot_des"):GetComponent(T_TextMeshProUGUI).text = CS.UI.UILuaHelper.GetGridEffectDescribe(gridEffectIds[i - 1])
        else
          itemObj:SetActive(false)
        end
      end
    end
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_list)
end

function Form_BattleGridTips:OnBtnmaskClicked()
  self:CloseForm()
end

local fullscreen = false
ActiveLuaUI("Form_BattleGridTips", Form_BattleGridTips)
return Form_BattleGridTips
