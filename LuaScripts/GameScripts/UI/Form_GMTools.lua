local Form_GMTools = class("Form_GMTools", require("UI/UIFrames/Form_GMToolsUI"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local Color = CS.UnityEngine.Color
local UnityEditor = CS.UnityEditor
local ShowMode = {
  Min = 1,
  Max = 2,
  PickMode = 3,
  SpinePos = 4,
  TextPickMode = 5
}

function Form_GMTools:SetInitParam(param)
end

function Form_GMTools:AfterInit()
  self.super.AfterInit(self)
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.TableBtns = {
    self.m_btn_inputCommand,
    self.m_btn_shortcuts,
    self.m_btn_Tool,
    self.m_btn_TestText
  }
  self.TablePanels = {
    self.m_pnl_inputCommand,
    self.m_pnl_shortcuts,
    self.m_pnl_tool,
    self.m_pnl_testText
  }
  self.m_ListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_commandList_InfinityGrid, "GMCommandItem")
  self.m_DetailContent:SetActive(false)
  self.Poster = self.m_ContentPanel:GetComponent("GMCommandPoster")
  self.m_input_command_TMP_InputField.onValueChanged:AddListener(handler(self, self.OnInputChanged))
  self.m_input_charid_TMP_InputField.onEndEdit:AddListener(handler(self, self.OnInputCharacterID))
  self.m_input_skinid_TMP_InputField.onEndEdit:AddListener(handler(self, self.OnInputSkinID))
  self.RectOutline = self.m_UIPickMode:GetComponent("RectTransformOutLine")
  local pickTool = self.m_TextPickMode:GetComponent("TextPickTool")
  pickTool:SetLang(CS.LanguageMgr.GetLanguageTableName())
  local commands = CS.CData_GMShortcuts.GetInstance():GetAll()
  local shortCutCommands = {}
  for i, v in pairs(commands) do
    if v.m_Command ~= "" then
      table.insert(shortCutCommands, v)
    end
  end
  table.sort(shortCutCommands, function(a, b)
    return a.m_Index < b.m_Index
  end)
  local panelRoot = self.m_shortcut_item.transform.parent
  local childCount = panelRoot.childCount
  local elementCount = #shortCutCommands
  while childCount < elementCount do
    GameObject.Instantiate(self.m_shortcut_item, panelRoot)
    childCount = childCount + 1
  end
  for i, v in ipairs(shortCutCommands) do
    local child = panelRoot:GetChild(i - 1).gameObject
    child:SetActive(true)
    local txt = child.transform:GetChild(0):GetComponent("TMPPro")
    txt.text = v.m_Name
    local btn = child:GetComponent(T_Button)
    btn.onClick:AddListener(handler1(self, self.OnClickShortcutItem, v))
  end
  self.Commands = {}
  local GMCommands = CS.CData_GMCommand.GetInstance():GetAll()
  for i, v in pairs(GMCommands) do
    table.insert(self.Commands, {
      Config = v,
      OnSelected = handler(self, self.OnCommandSelected),
      LowerCommand = string.lower(v.m_Key)
    })
  end
  table.sort(self.Commands, function(a, b)
    return a.LowerCommand < b.LowerCommand
  end)
  self.m_ListInfinityGrid:ShowItemList(self.Commands)
  self.LastInputCommand = ""
  local characterAll = CharacterInfoIns:GetAll()
  local heroIDs = {}
  for _, tempCfg in pairs(characterAll) do
    heroIDs[#heroIDs + 1] = tempCfg.m_HeroID
  end
  table.sort(heroIDs, function(a, b)
    return a < b
  end)
  self.m_allHeroIDList = heroIDs
  self:SwitchShowMode(ShowMode.Max)
  self:SwitchPanel(1)
end

function Form_GMTools:OnInputChanged(val)
  val = string.trim(val)
  local fromIdx, endIdx = string.find(val, " ")
  if fromIdx then
    val = string.sub(val, 1, fromIdx - 1)
  end
  if self.LastInputCommand == val then
    return
  end
  self.LastInputCommand = val
  if val == "" then
    self.m_ListInfinityGrid:ShowItemList(self.Commands)
  else
    local matcheds = {}
    local lowerInput = string.lower(val)
    for _, v in ipairs(self.Commands) do
      local start, _ = string.find(v.LowerCommand, lowerInput)
      if start then
        table.insert(matcheds, v)
      end
    end
    self.m_ListInfinityGrid:ShowItemList(matcheds)
  end
end

function Form_GMTools:OnCommandSelected(cfg)
  self.m_input_command_TMP_InputField.text = cfg.m_Key .. " "
  self.m_input_command_TMP_InputField:ActivateInputField()
end

function Form_GMTools:OnBtnexccommandClicked()
  local input = self.m_input_command_TMP_InputField.text
  if input == "" then
    return
  end
  local command = input
  local fromIdx, endIdx = string.find(command, " ")
  if fromIdx then
    command = string.sub(command, 1, fromIdx - 1)
  end
  local appendUID = false
  for _, v in ipairs(self.Commands) do
    if v.Config.m_Key == command then
      appendUID = v.Config.m_InsertUID == 1
      break
    end
  end
  self:ExcCammond(input, appendUID, true)
end

function Form_GMTools:OnClickShortcutItem(cfg)
  self:ExcCammond(cfg.m_Command, false, false)
end

function Form_GMTools:ExcCammond(input, appendUID, showResult)
  local curZoneID = UserDataManager:GetZoneID()
  local curAccountID = UserDataManager:GetAccountID()
  local params = string.split(input, " ")
  local newParams = {}
  for _, v in ipairs(params) do
    if v and v ~= " " then
      if v == "UID" then
        table.insert(newParams, curAccountID)
      else
        table.insert(newParams, v)
      end
    end
  end
  if appendUID then
    table.insert(newParams, 2, curAccountID)
  end
  local newInput = table.concat(newParams, " ")
  if showResult then
    CS.UI.UILuaHelper.PostGMCommand(self.Poster, curZoneID, newInput, handler(self, self.OnGMResult))
  else
    CS.UI.UILuaHelper.PostGMCommand(self.Poster, curZoneID, newInput, nil)
  end
end

function Form_GMTools:OnGMResult(isSuccess, content)
  self.m_command_tip_Text.text = content
  self.m_tipDetail_Text.text = content
end

function Form_GMTools:OnCommandtipClicked()
  self.m_DetailContent:SetActive(true)
end

function Form_GMTools:OnBtnUIPickModeClicked()
  self:SwitchShowMode(ShowMode.PickMode)
end

function Form_GMTools:OnBtnhiddenGMToolClicked()
  self:CloseForm()
end

function Form_GMTools:OnBtnSpinePosToolClicked()
  self:SwitchShowMode(ShowMode.SpinePos)
end

function Form_GMTools:OnBtnGetStrKeyClicked()
  self:SwitchShowMode(ShowMode.TextPickMode)
end

function Form_GMTools:OnBtninputCommandClicked()
  self:SwitchPanel(1)
end

function Form_GMTools:OnBtnshortcutsClicked()
  self:SwitchPanel(2)
end

function Form_GMTools:OnBtnToolClicked()
  self:SwitchPanel(3)
end

function Form_GMTools:OnBtnTestTextClicked()
  self:SwitchPanel(4)
end

function Form_GMTools:OnBtncloseClicked()
  self:SwitchShowMode(ShowMode.Min)
end

function Form_GMTools:OnContentPanelClicked()
  self:SwitchShowMode(ShowMode.Min)
end

function Form_GMTools:OnExitPickModeClicked()
  self:SwitchShowMode(ShowMode.Min)
end

function Form_GMTools:OnBtnclose2Clicked()
  self.m_SheetDetail:SetActive(false)
end

function Form_GMTools:SwitchShowMode(mode)
  self.m_ContentPanel:SetActive(mode == ShowMode.Max)
  self.m_Entry:SetActive(mode == ShowMode.Min)
  self.m_UIPickMode:SetActive(mode == ShowMode.PickMode)
  self.m_TextPickMode:SetActive(mode == ShowMode.TextPickMode)
  self.m_SpinePosOutput:SetActive(mode == ShowMode.SpinePos)
  self.RectOutline.Target = nil
end

function Form_GMTools:OnEntryClicked()
  self:SwitchShowMode(ShowMode.Max)
end

function Form_GMTools:OnDetailContentClicked()
  self.m_DetailContent:SetActive(false)
end

function Form_GMTools:SwitchPanel(index)
  if self.selectedIndex == index then
    return
  end
  self.selectedIndex = index
  local normalColor = Color(0.6, 0.6, 0.6, 1)
  local selectColor = Color(0.6, 0.6, 0, 1)
  for i, v in ipairs(self.TableBtns) do
    local img = v:GetComponent(T_Image)
    if img then
      if i == index then
        img.color = selectColor
      else
        img.color = normalColor
      end
    end
  end
  for i, v in ipairs(self.TablePanels) do
    v:SetActive(i == index)
  end
end

local HeroModuleIDs = {
  UIDefines.ID_FORM_HEROBREAKTHROUGH,
  UIDefines.ID_FORM_HERODETAIL,
  UIDefines.ID_FORM_HEROCHECK,
  UIDefines.ID_FORM_HEROUPGRADE,
  UIDefines.ID_FORM_HEROEQUIPREPLACEPOP,
  UIDefines.ID_FORM_HEROSHOW,
  UIDefines.ID_FORM_ATTRACTMAIN2,
  UIDefines.ID_FORM_ATTRACTLEVELUP2,
  UIDefines.ID_FORM_ATTRACTBOOK2,
  UIDefines.ID_FORM_HEROPREVIEW,
  UIDefines.ID_FORM_BATTLECHARACTERDATA,
  UIDefines.ID_FORM_BATTLEVICTORY,
  UIDefines.ID_FORM_BATTLEPASS,
  UIDefines.ID_FORM_ACTIVITYDAYTASKCHOOSE
}
local HeroPlaceNodes = {
  "herodetail",
  "battlewin",
  "heroshow",
  "herobreak",
  "heroequip",
  "heroequipmain",
  "heropreview"
}

function Form_GMTools:TrySearchHeroPlaceRoot(go)
  local transform = go.transform
  for i = 0, transform.childCount - 1 do
    if string.sub(transform:GetChild(i).name, 1, string.len("hero_place_")) == "hero_place_" then
      return transform:GetChild(i).parent
    end
    if 0 < transform:GetChild(i).transform.childCount then
      local result = self:TrySearchHeroPlaceRoot(transform:GetChild(i))
      if result then
        return result
      end
    end
  end
end

function Form_GMTools:OnInputCharacterID(var)
  self.m_selected_heroModuleUI = nil
  self.m_selected_spine = nil
  self.m_selected_moduleID = nil
  for key, moduleID in pairs(HeroModuleIDs) do
    local heroModuleUI = UIStatic.StackFlow:GetUIInstanceLua(moduleID)
    if heroModuleUI and heroModuleUI.m_csui and heroModuleUI:IsActive() then
      self.m_selected_heroModuleUI = heroModuleUI
      self.m_selected_moduleID = moduleID
      break
    end
    heroModuleUI = UIStatic.StackPopup:GetUIInstanceLua(moduleID)
    if heroModuleUI and heroModuleUI.m_csui and heroModuleUI:IsActive() then
      self.m_selected_heroModuleUI = heroModuleUI
      self.m_selected_moduleID = moduleID
      break
    end
  end
  local heroCfg = CharacterInfoIns:GetValue_ByHeroID(var)
  if heroCfg:GetError() == true then
    heroCfg = nil
    self:SwitchShowMode(ShowMode.Min)
    return
  end
  if self.m_selected_heroModuleUI then
    self.m_selected_spine = heroCfg.m_Spine
    local filePath = "Assets/BundleResource/UI/Prefabs/HeroPlaceHolder/hero_place_" .. self.m_selected_spine .. ".prefab"
    local mPrefab = UnityEditor.AssetDatabase.LoadAssetAtPath(filePath, typeof(CS.UnityEngine.GameObject))
    if not mPrefab then
      local go = CS.UnityEngine.GameObject("hero_place_" .. self.m_selected_spine)
      go:AddComponent(typeof(CS.UnityEngine.RectTransform))
      go.layer = 5
      for i = 1, #HeroPlaceNodes do
        local node = CS.UnityEngine.GameObject(HeroPlaceNodes[i])
        node:AddComponent(typeof(CS.UnityEngine.RectTransform))
        node.transform.parent = go.transform
      end
      mPrefab = UnityEditor.PrefabUtility.CreatePrefab(filePath, go)
      CS.UnityEngine.GameObject.Destroy(go)
    end
    xpcall(function()
      if self.m_selected_heroModuleUI.ShowHeroSpine then
        self.m_selected_heroModuleUI:ShowHeroSpine(self.m_selected_spine)
      else
        local root = self:TrySearchHeroPlaceRoot(self.m_selected_heroModuleUI.m_csui.m_uiGameObject.transform)
        if root then
          for i = 0, root.transform.childCount - 1 do
            root.transform:GetChild(i).gameObject:SetActive(false)
          end
          if self.m_selected_moduleID == UIDefines.ID_FORM_HEROSHOW then
            self.m_HeroSpineDynamicLoader:LoadHeroSpine(self.m_selected_spine, "heroshow", root)
          elseif self.m_selected_moduleID == UIDefines.ID_FORM_BATTLEVICTORY then
            self.m_HeroSpineDynamicLoader:LoadHeroSpine(self.m_selected_spine, "battlewin", root)
          elseif self.m_selected_moduleID == UIDefines.ID_FORM_HEROBREAKTHROUGH then
            self.m_HeroSpineDynamicLoader:LoadHeroSpine(self.m_selected_spine, "herobreak", root)
          else
            self.m_HeroSpineDynamicLoader:LoadHeroSpine(self.m_selected_spine, "herodetail", root)
          end
        end
      end
    end, function()
      log.error("设置Spine失败")
    end)
  end
end

function Form_GMTools:OnInputSkinID(var)
  log.debug("设置皮肤" .. var)
end

function Form_GMTools:OnBtnPosOutputClicked()
  if not (self.m_selected_spine and self.m_selected_heroModuleUI) or not self.m_selected_heroModuleUI:IsActive() then
    self:SwitchShowMode(ShowMode.Min)
    return
  end
  local configs = {}
  local spineLoadObj = self.m_selected_heroModuleUI.m_curHeroSpineObj
  if not spineLoadObj then
    return
  end
  local spinePlaceObj = spineLoadObj.spinePlaceTrans
  if not spinePlaceObj then
    return
  end
  local childCount = spinePlaceObj.childCount
  for i = 1, childCount do
    local child = spinePlaceObj.transform:GetChild(i - 1)
    configs[child.gameObject.name] = child
  end
  local filePath = "Assets/BundleResource/UI/Prefabs/HeroPlaceHolder/" .. spinePlaceObj.gameObject.name .. ".prefab"
  local go = UnityEditor.AssetDatabase.LoadAssetAtPath(filePath, typeof(CS.UnityEngine.GameObject))
  if go then
    for key, value in pairs(configs) do
      if go.transform:Find(key) then
        go.transform:Find(key).anchoredPosition = value.anchoredPosition
        go.transform:Find(key).localScale = value.localScale
      else
        local node = CS.UnityEngine.GameObject(key)
        node.transform.parent = go.transform
        node.transform.anchoredPosition = value.anchoredPosition
        node.transform.localScale = value.localScale
      end
    end
    UnityEditor.EditorUtility.SetDirty(go)
  end
end

function Form_GMTools:OnBtnPreCharClicked()
  local curIndex = table.indexof(self.m_allHeroIDList, tonumber(self.m_input_charid_TMP_InputField.text)) or 1
  if curIndex ~= 1 then
    self.m_input_charid_TMP_InputField.text = self.m_allHeroIDList[curIndex - 1]
  else
    self.m_input_charid_TMP_InputField.text = self.m_allHeroIDList[#self.m_allHeroIDList]
  end
  self:OnInputCharacterID(tonumber(self.m_input_charid_TMP_InputField.text))
end

function Form_GMTools:OnBtnNextCharClicked()
  local curIndex = table.indexof(self.m_allHeroIDList, tonumber(self.m_input_charid_TMP_InputField.text)) or 1
  if curIndex ~= #self.m_allHeroIDList then
    self.m_input_charid_TMP_InputField.text = self.m_allHeroIDList[curIndex + 1]
  else
    self.m_input_charid_TMP_InputField.text = self.m_allHeroIDList[1]
  end
  self:OnInputCharacterID(tonumber(self.m_input_charid_TMP_InputField.text))
end

function Form_GMTools:OnBtnConfirmCommonTipsClicked()
  self:SwitchTextShowMode(1)
end

function Form_GMTools:OnBtnClientMessageClicked()
  self:SwitchTextShowMode(2)
end

function Form_GMTools:OnBtnSendMsgClicked()
  if self.selectedTextMode == 1 then
    utils.popUpDirectionsUI({
      tipsID = tonumber(self.m_input_config_TMP_InputField.text)
    })
  elseif self.selectedTextMode == 2 then
    StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(tonumber(self.m_input_config_TMP_InputField.text)))
  end
end

function Form_GMTools:SwitchTextShowMode(index)
  if self.selectedTextMode == index then
    return
  end
  self.selectedTextMode = index
  local tabs = {
    self.m_btn_ConfirmCommonTips,
    self.m_btn_ClientMessage
  }
  local normalColor = Color(0.6, 0.6, 0.6, 1)
  local selectColor = Color(0.6, 0.6, 0, 1)
  for i, v in ipairs(tabs) do
    local img = v:GetComponent(T_Image)
    if img then
      if i == index then
        img.color = selectColor
      else
        img.color = normalColor
      end
    end
  end
end

local fullscreen = true
ActiveLuaUI("Form_GMTools", Form_GMTools)
return Form_GMTools
