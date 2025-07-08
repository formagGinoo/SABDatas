local os = _ENV.os
local utils = require("common/utils")
local dir = require("common/dir")
local path = require("common/path")
local file = {}
file.read = utils.readfile
file.write = utils.writefile
file.copy = dir.copyfile
file.move = dir.movefile
file.access_time = path.getatime
file.creation_time = path.getctime
file.modified_time = path.getmtime
file.delete = os.remove
return file
