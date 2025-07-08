local M = class("LoopScrollViewUtil")
M.m_loop_scroll_view = nil

function M:ctor(params)
  self.m_loop_scroll_object = params.loop_scroll_object
  self.m_init_cell = params.init_cell or function()
  end
  self.m_update_cell = params.update_cell
  self.m_pull_refresh = params.pull_refresh
  self.m_click_func = params.click_func
  self.m_prefab_name = params.prefab_name
  self.m_show_data = params.show_data or {}
  self.m_one_line_count = params.one_line_count or 1
  self.m_all_cell_size = params.all_cell_size
  self.m_ui_name = params.ui_name
  self.m_pos_center = params.pos_center
  self.m_spacing = params.spacing or 0
  self.m_cache_cells = {}
  self.m_init_cells = {}
  self.m_do_tween_reload_play = params.do_tween_reload_play or false
  self:init()
end

function M:init()
  self.m_scroll_rect = self.m_loop_scroll_object:GetComponent("ScrollRect")
  self.m_loop_scroll_view = self.m_loop_scroll_object:GetComponent("LoopScrollView")
  if self.m_all_cell_size then
    self.m_loop_scroll_view:SetCellSizeForIndexDelegate(function(index)
      return self.m_all_cell_size[index + 1] or Vector2.zero
    end)
  end
  self.sequence_time = 0
  self.loop_score_sequence = Tweening.DOTween.Sequence()
  self.score_dotween = self.m_loop_scroll_view.score_dotween
  self.tweenTime = self.m_loop_scroll_view.tweenTime
  self.intervalTime = self.m_loop_scroll_view.intervalTime
  self.is_Group = self.m_loop_scroll_view.is_Group
  self.is_Move = self.m_loop_scroll_view.is_Move
  self.is_Update = self.m_loop_scroll_view.is_Update
  self:updateCellCount()
  local prefab
  if self.m_prefab_name then
    prefab = ResourceUtil:CreatePrefab(self.m_prefab_name, self.m_scroll_rect.content.transform)
  end
  self:setPosCenterPadding()
  self.m_loop_scroll_view:Initialize(handler(self, self.actionFunc), prefab)
end

function M:setPosCenterPadding()
  if self.m_pos_center and self.m_loop_scroll_view.direction == CS.UI.LoopScrollView.EDirection.HORIZONTAL then
    local view_rt = self.m_scroll_rect.viewport.rect
    local cellSize = self.m_loop_scroll_view.cellSize
    local spacing = self.m_spacing > 0 and self.m_spacing or self.m_loop_scroll_view.spacing
    local padding = self.m_loop_scroll_view.padding
    padding.left = math.floor(math.max(0, view_rt.width - cellSize.x * self.m_count - (self.m_count - 1) * spacing) / 2)
  end
end

function M:scoreDotween(trans)
  if self.score_dotween == CS.UI.LoopScrollView.ScrollViewDotween.No then
    return
  end
  local node = self:getDotweenNode(trans)
  local cell_prefab = self.m_loop_scroll_view.cellPrefab
  local cell_prefab_node = self:getDotweenNode(cell_prefab.transform)
  if self.m_do_tween_reload_play and self.m_do_tween_reload_play == true then
    if self.is_Move then
      if self.score_dotween == CS.UI.LoopScrollView.ScrollViewDotween.HORIZONTAL then
        node.transform:DOLocalMoveX(self.m_loop_scroll_view.dotween_X, 0)
      elseif self.score_dotween == CS.UI.LoopScrollView.ScrollViewDotween.VERTICAL then
        node.transform:DOLocalMoveY(self.m_loop_scroll_view.dotween_Y, 0)
      end
    end
    if self.is_Group then
      local canvasGroup = node.transform:GetComponent("CanvasGroup")
      canvasGroup.alpha = 1
    end
    return
  end
  if self.is_Move then
    if self.score_dotween == CS.UI.LoopScrollView.ScrollViewDotween.HORIZONTAL then
      if cell_prefab_node ~= nil then
        local pos = node.transform.localPosition
        pos.x = cell_prefab_node.transform.localPosition.x
        node.transform.localPosition = pos
      end
      self.loop_score_sequence:Insert(self.sequence_time, node.transform:DOLocalMoveX(self.m_loop_scroll_view.dotween_X, self.tweenTime):SetEase(Tweening.Ease.OutSine))
    elseif self.score_dotween == CS.UI.LoopScrollView.ScrollViewDotween.VERTICAL then
      if cell_prefab_node ~= nil then
        local pos = node.transform.localPosition
        pos.y = cell_prefab_node.transform.localPosition.y
        node.transform.localPosition = pos
      end
      self.loop_score_sequence:Insert(self.sequence_time, node.transform:DOLocalMoveY(self.m_loop_scroll_view.dotween_Y, self.tweenTime):SetEase(Tweening.Ease.OutSine))
    end
  end
  
  local function endCallFunc()
    self.sequence_time = 0
  end
  
  if self.is_Group then
    local canvasGroup = node.transform:GetComponent("CanvasGroup")
    canvasGroup.alpha = 0
    self.loop_score_sequence:Insert(self.sequence_time, DOTweenModuleUI.DOFade(canvasGroup, 1, self.tweenTime))
  end
  self.sequence_time = self.sequence_time + self.intervalTime
  self.loop_score_sequence:OnComplete(endCallFunc)
end

function M:getDotweenNode(trans)
  local luaBehaviour = UIUtil.findLuaBehaviour(trans)
  local node = luaBehaviour:FindGameObject("node")
  if node == nil then
    node = luaBehaviour:FindGameObject("offset")
    if node == nil then
      node = luaBehaviour:FindGameObject("content")
      if node == nil then
        node = trans
      end
    end
  end
  return node
end

function M:updateCellCount()
  self.m_count = #self.m_show_data
  self.m_line_count = math.ceil(self.m_count / self.m_one_line_count)
  self.m_loop_scroll_view.cellsCount = self.m_line_count
end

function M:actionFunc(scroll_view, hander_type, index, cell_object)
  if hander_type == 1 then
    if self.m_init_cell then
      table.insert(self.m_init_cells, cell_object)
      if 1 < self.m_one_line_count then
        local transform = cell_object.transform
        for i = 1, self.m_one_line_count do
          local trans = transform:Find("cell_" .. i)
          if trans then
            local idx = index * self.m_one_line_count + i
            local luaBehaviour = UIUtil.findLuaBehaviour(trans)
            if luaBehaviour then
              luaBehaviour:RegistButtonClick(handler(self, self.itemClick))
            end
            self.m_init_cell(idx, trans.gameObject)
            self:scoreDotween(trans)
          end
        end
      else
        local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
        if luaBehaviour then
          luaBehaviour:RegistButtonClick(handler(self, self.itemClick))
        end
        self.m_init_cell(index + 1, cell_object)
        self:scoreDotween(cell_object.transform)
      end
    end
  elseif hander_type == 2 then
    if self.m_update_cell then
      if 1 < self.m_one_line_count then
        local transform = cell_object.transform
        for i = 1, self.m_one_line_count do
          local trans = transform:Find("cell_" .. i)
          if trans then
            local go = trans.gameObject
            local idx = index * self.m_one_line_count + i
            if idx <= self.m_count then
              go:SetActive(true)
              local luaBehaviour = UIUtil.findLuaBehaviour(trans)
              if luaBehaviour then
                luaBehaviour.itag = idx
              end
              self.m_cache_cells[idx] = go
              self.m_update_cell(idx, go, self.m_show_data[idx])
            else
              go:SetActive(false)
            end
            if self.is_Update then
              self:scoreDotween(trans)
            end
          end
        end
      else
        local idx = index + 1
        local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
        if luaBehaviour then
          luaBehaviour.itag = idx
        end
        self.m_cache_cells[idx] = cell_object
        self.m_update_cell(idx, cell_object, self.m_show_data[idx])
        if self.is_Update then
          self:scoreDotween(cell_object.transform)
        end
      end
    end
  elseif hander_type == 3 and self.m_pull_refresh then
    self.m_pull_refresh()
  end
end

function M:itemClick(click_object, click_name, idx)
  local cell_object = self.m_cache_cells[idx]
  if self.m_click_func and cell_object then
    self.m_click_func(idx, cell_object, self.m_show_data[idx], click_object, click_name)
  end
end

function M:reloadData(data, keep_offset, all_cell_size, do_tween_reload_play, pos_center)
  self.m_show_data = data or {}
  self.m_do_tween_reload_play = do_tween_reload_play or false
  self:updateCellCount()
  if all_cell_size then
    self.m_all_cell_size = all_cell_size
  end
  if keep_offset == nil then
    keep_offset = false
  end
  if pos_center then
    self:setPosCenterPadding()
  end
  self.m_loop_scroll_view:ReloadData(self.m_line_count, keep_offset)
end

function M:getContentOffset()
  return self.m_loop_scroll_view:GetContentOffset()
end

function M:setContentOffset(offset)
  self.m_loop_scroll_view:SetContentOffset(offset)
end

function M:moveToCellIndex(index, offset)
  local real_index = math.ceil(index / self.m_one_line_count)
  self.m_loop_scroll_view:MoveToCellIndex(real_index - 1, offset or 0)
end

function M:updateCellIndex(index)
  self.m_loop_scroll_view:UpdateCellAtIndex(index)
end

function M:getDragFlag()
  return self.m_loop_scroll_view:GetDragFlag()
end

function M:setHorizontalNormalizedPosition(value, doTweenAnim)
  if doTweenAnim then
    DOTweenModuleUI.DOHorizontalNormalizedPos(self.m_scroll_rect, value, 0.2)
  else
    self.m_scroll_rect.horizontalNormalizedPosition = value or 0
  end
end

function M:getHorizontalNormalizedPosition()
  return self.m_scroll_rect.horizontalNormalizedPosition
end

function M:setVerticalNormalizedPosition(value, doTweenAnim)
  if doTweenAnim then
    DOTweenModuleUI.DOVerticalNormalizedPos(self.m_scroll_rect, value, 0.2)
  else
    self.m_scroll_rect.verticalNormalizedPosition = value or 0
  end
end

function M:getVerticalNormalizedPosition()
  return self.m_scroll_rect.verticalNormalizedPosition
end

function M:moveHorizontalPage(add_value, doTweenAnim)
  local pos = self:getHorizontalNormalizedPosition()
  local cur_page = 0
  local offset = pos
  local max_index = self.m_line_count - 1
  for i = 0, max_index do
    local temp_offset = math.abs(pos - i / max_index)
    if offset > temp_offset then
      cur_page = i
      offset = temp_offset
    end
  end
  if cur_page == 0 and add_value == -1 or cur_page == max_index and add_value == 1 then
    return cur_page, max_index
  end
  self:setHorizontalNormalizedPosition((cur_page + add_value) / max_index, doTweenAnim)
  return cur_page + add_value
end

function M:GetPage()
  local pos = self:getHorizontalNormalizedPosition()
  local cur_page = 0
  local offset = pos
  local max_index = self.m_line_count - 1
  for i = 0, max_index do
    local temp_offset = math.abs(pos - i / max_index)
    if offset > temp_offset then
      cur_page = i
      offset = temp_offset
    end
  end
  return cur_page
end

function M:getInitCells()
  return self.m_init_cells
end

return M
