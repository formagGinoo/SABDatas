local M = class("CircleLoopScrollViewUtil")
M.m_loop_scroll_view = nil

function M:ctor(params)
  self.m_loop_scroll_object = params.loop_scroll_object
  self.m_init_cell = params.init_cell or function()
  end
  self.m_update_cell = params.update_cell
  self.m_click_func = params.click_func
  self.m_show_data = params.show_data or {}
  self.m_item_count = params.item_count
  self.m_cache_cells = {}
  self.m_cache_data = {}
  self:init()
end

function M:init()
  self.m_loop_scroll_view = self.m_loop_scroll_object:GetComponent("CircleLoopScrollView")
  self.m_loop_scroll_view.scrollViewAction = handler(self, self.actionFunc)
  self.m_loop_scroll_view:AddItems(self.m_item_count)
end

function M:GetUnShowedData(index, bReverse)
  if bReverse then
    if index + 1 > self.m_item_count then
      index = 1
    else
      index = index + 1
    end
    local idx = self.m_cache_data[index]
    if idx == nil then
      return {
        self.m_show_data[#self.m_show_data],
        #self.m_show_data
      }
    end
    if idx - 1 < 1 then
      idx = #self.m_show_data
    else
      idx = idx - 1
    end
    return {
      self.m_show_data[idx],
      idx
    }
  else
    if index - 1 < 1 then
      index = self.m_item_count
    else
      index = index - 1
    end
    local idx = self.m_cache_data[index]
    if idx == nil then
      return {
        self.m_show_data[1],
        1
      }
    end
    if idx + 1 > #self.m_show_data then
      idx = 1
    else
      idx = idx + 1
    end
    return {
      self.m_show_data[idx],
      idx
    }
  end
  return nil
end

function M:actionFunc(scroll_view, hander_type, index, cell_object)
  if hander_type == 1 then
    if self.m_init_cell then
      local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
      if luaBehaviour then
        luaBehaviour:RegistButtonClick(handler(self, self.itemClick))
      end
      self.m_init_cell(index + 1, cell_object)
    end
  elseif hander_type == 2 then
    if self.m_update_cell then
      local idx = index + 1
      local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
      if luaBehaviour then
        luaBehaviour.itag = idx
      end
      self.m_cache_cells[idx] = cell_object
      local itemData = self:GetUnShowedData(idx)
      if itemData then
        self.m_cache_data[idx] = itemData[2]
        self.m_update_cell(idx, cell_object, itemData[1])
      end
    end
  elseif hander_type == 3 then
    if self.m_update_cell then
      local idx = index + 1
      local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
      if luaBehaviour then
        luaBehaviour.itag = idx
      end
      self.m_cache_cells[idx] = cell_object
      local itemData = self:GetUnShowedData(idx, true)
      if itemData then
        self.m_cache_data[idx] = itemData[2]
        self.m_update_cell(idx, cell_object, itemData[1])
      end
    end
  elseif hander_type == 4 then
    local idx = index + 1
    self.m_cache_cells[idx] = nil
    if self.m_cache_data[idx] then
      self.m_cache_data[idx] = nil
    end
  end
end

function M:itemClick(click_object, click_name, idx)
  local cell_object = self.m_cache_cells[idx]
  if self.m_click_func and cell_object then
    self.m_click_func(idx, cell_object, self.m_show_data[self.m_cache_data[idx]], click_object, click_name)
  end
end

function M:reloadData(data, keep_offset)
  if keep_offset == nil then
    keep_offset = false
  end
  self.m_show_data = data
  self.m_cache_data = {}
  self.m_cache_cells = {}
  self.m_loop_scroll_view:ReloadData(#data, keep_offset)
end

function M:moveToCell2Degree(index, degree, bAnimate)
  self.m_loop_scroll_view:MoveToCell2Degree(index - 1, degree, bAnimate)
end

function M:moveToCellVisible(index, bAnimate)
  self.m_loop_scroll_view:MoveToCellVisible(index - 1, bAnimate)
end

function M:updateCellIndex(index)
  self.m_loop_scroll_view:UpdateCellAtIndex(index)
end

function M:getDragFlag()
  return self.m_loop_scroll_view:GetDragFlag()
end

function M:setAutoMove(b)
  self.m_loop_scroll_view.IsAutoMove = b
end

function M:setRotateDegree(value)
end

return M
