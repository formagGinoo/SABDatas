local Form_CastleStarMain = class("Form_CastleStarMain", require("UI/UIFrames/Form_CastleStarMainUI"))
local DragLimitNum = 25

function Form_CastleStarMain:SetInitParam(param)
end

function Form_CastleStarMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1133)
  self.m_starInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollview_InfinityGrid, "Stargazing/UIStargazingEffectItem")
  self.m_circle_touch_BtnExtension = self.m_scrollview_circle:GetComponent("ButtonExtensions")
  if self.m_circle_touch_BtnExtension then
    self.m_circle_touch_BtnExtension.BeginDrag = handler(self, self.OnBeginDrag)
    self.m_circle_touch_BtnExtension.Drag = handler(self, self.OnDrag)
    self.m_circle_touch_BtnExtension.EndDrag = handler(self, self.OnEndDrag)
  end
  self.m_beginDragPos = nil
  self.m_isInDrag = nil
end

function Form_CastleStarMain:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(133)
  self:InitView()
end

function Form_CastleStarMain:OnInactive()
  self.super.OnInactive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(134)
end

function Form_CastleStarMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleStarMain:InitView()
  self.m_scrollview:SetActive(false)
  self.m_btn_enter:SetActive(false)
  self.m_pnl_first:SetActive(true)
  self:RefreshStarChart()
end

function Form_CastleStarMain:OpenConstellationDetail()
  self.m_scrollview:SetActive(true)
  self.m_btn_enter:SetActive(true)
  self.m_pnl_first:SetActive(false)
  self:RefreshEffectDetail(self.m_iSelectConstellationID)
end

function Form_CastleStarMain:RefreshStarChart()
  self.m_oldCellObject = nil
  self.m_iSelectConstellationID = nil
  local data = StargazingManager:GetConstellationList()
  if self.m_loop_scroll_view_star == nil then
    local loopscroll = self.m_scrollview_circle
    local params = {
      show_data = data,
      item_count = 9,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewStarCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if self.m_loop_scroll_view_star:getDragFlag() or index == self.m_selectedIndex then
          return
        end
        CS.GlobalManager.Instance:TriggerWwiseBGMState(138)
        if click_name == "c_btn_1" or click_name == "c_btn_2" or click_name == "c_btn_3" then
          self.m_loop_scroll_view_star:setAutoMove(false)
          self:SelectConstellation(cell_data.m_ConstellationID, cell_object)
          self.m_loop_scroll_view_star:moveToCellVisible(index, true)
        end
      end
    }
    self.m_loop_scroll_view_star = CircleLoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view_star:setAutoMove(true)
    self.m_loop_scroll_view_star:reloadData(data)
  end
end

function Form_CastleStarMain:UpdateScrollViewStarCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_star_name", cell_data.m_mConstellationName)
  if self.m_iSelectConstellationID == cell_data.m_ConstellationID then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_select", true)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_select", false)
  end
  local img = LuaBehaviourUtil.findImg(luaBehaviour, "c_img_icon")
  UILuaHelper.SetAtlasSprite(img, cell_data.m_StarPic)
  if self.m_greyMat == nil then
    self.m_greyMat = img.material
  end
  local img2 = LuaBehaviourUtil.findImg(luaBehaviour, "c_img_stari_con")
  UILuaHelper.SetAtlasSprite(img2, cell_data.m_BackPic)
  if cell_data.m_StarPosXY ~= "" then
    local vPos = string.split(cell_data.m_StarPosXY, ",")
    img2:GetComponent("RectTransform").anchoredPosition = Vector2.New(tonumber(vPos[1]), tonumber(vPos[2]))
  end
  if self.m_greyMat2 == nil then
    self.m_greyMat2 = img2.material
  end
  if self.m_stariColor == nil then
    self.m_stariColor = img2.color
  end
  if StargazingManager:IsConstellationUnlock(cell_data.m_ConstellationID) then
    img.material = nil
    img2.material = nil
    img2.color = Color(0.627, 0.525, 0.365, 0.19)
  else
    img.material = self.m_greyMat
    img2.material = self.m_greyMat2
    img2.color = self.m_stariColor
  end
end

function Form_CastleStarMain:SelectConstellation(iConstellationID, cellObject)
  if self.m_oldCellObject then
    LuaBehaviourUtil.setObjectVisible(UIUtil.findLuaBehaviour(self.m_oldCellObject.transform), "c_img_select", false)
  end
  self.m_oldCellObject = cellObject
  LuaBehaviourUtil.setObjectVisible(UIUtil.findLuaBehaviour(cellObject.transform), "c_img_select", true)
  self.m_iSelectConstellationID = iConstellationID
  self:OpenConstellationDetail()
end

function Form_CastleStarMain:RefreshEffectDetail(iConstellationID)
  local vStarList = StargazingManager:GetAvailableStarList(iConstellationID)
  local data = {}
  for k, v in ipairs(vStarList) do
    data[#data + 1] = {
      iStarID = v,
      iConstellationID = self.m_iSelectConstellationID
    }
  end
  self.m_starInfinityGrid:ShowItemList(data)
  local list = self.m_starInfinityGrid:GetAllShownItemList()
  for k, v in ipairs(list) do
    v:PlayEffectIn()
  end
  if StargazingManager:IsConstellationUnlock(iConstellationID) then
    local starID = StargazingManager:GetFirstUnlockStarInfoByConstellation(iConstellationID)
    if StargazingManager:IsStarUnlock(iConstellationID, starID) then
      self.m_z_txt_enter:SetActive(false)
      self.m_z_txt_check:SetActive(true)
    else
      self.m_z_txt_enter:SetActive(true)
      self.m_z_txt_check:SetActive(false)
    end
  end
end

function Form_CastleStarMain:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local iStarID = cell_data
  local starInfo = StargazingManager:GetStarInfo(self.m_iSelectConstellationID, iStarID)
  if StargazingManager:IsStarUnlock(self.m_iSelectConstellationID, iStarID) then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_pnl_unlock", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_pnl_lock", false)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_desc_unlock", starInfo.m_mEffectDes)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_pnl_lock", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_pnl_unlock", false)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_desc_lock", starInfo.m_mEffectDes)
  end
end

function Form_CastleStarMain:OnBeginDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_beginDragPos = startPos
end

function Form_CastleStarMain:OnDrag(pointerEventData)
  if not self.m_isInDrag then
    local tempPos = pointerEventData.position
    local distanceX = tempPos.x - self.m_beginDragPos.x
    local distanceY = tempPos.y - self.m_beginDragPos.y
    local distanceNum = distanceX * distanceX + distanceY * distanceY
    if distanceNum > DragLimitNum then
      CS.GlobalManager.Instance:TriggerWwiseBGMState(137)
      self.m_isInDrag = true
    end
  end
end

function Form_CastleStarMain:OnEndDrag()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(143)
  self.m_isInDrag = false
end

function Form_CastleStarMain:OnBtnenterClicked()
  StackFlow:Push(UIDefines.ID_FORM_CASTLESTARUNLOCK, {
    iSelectConstellationID = self.m_iSelectConstellationID
  })
end

function Form_CastleStarMain:OnBackClk()
  self:CloseForm()
end

function Form_CastleStarMain:OnBackHome()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_CastleStarMain:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleStarMain", Form_CastleStarMain)
return Form_CastleStarMain
