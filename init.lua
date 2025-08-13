local nd_core = exports["ND_Core"]

NDCore = setmetatable({}, {
    __index = function(self, index)
        self[index] = function(...)
            return nd_core[index](nil, ...)
        end

        return self[index]
    end
})

return NDCore
