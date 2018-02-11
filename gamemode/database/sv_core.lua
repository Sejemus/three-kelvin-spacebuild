require("mysqloo")
TK.DB = TK.DB or {}
local MySQL = {}

--/--- MySQL Settings ---\\\
MySQL.loginDetails = include("./sv_login.lua")
MySQL.priorityCache = {}
MySQL.cache = {}
MySQL.connectionID = 0
MySQL.database = nil
MySQL.isConnected = false
MySQL.schema = {}

MySQL.placeholder = {
    ["DB_TIME"] = "UNIX_TIMESTAMP()",
    ["DB_CONN_ID"] = "CONNECTION_ID()"
}

--/--- ---\\\
--/--- Database Setup ---\\\
function MySQL:setup()
    self.schema = list.Get("TK_Database")

    self:makePriorityQuery("SELECT CONNECTION_ID()", function(Data)
        MySQL.connectionID = tonumber(Data[1]["CONNECTION_ID()"])
    end)

    for k, v in pairs(self:getCreateQueries()) do
        self:makePriorityQuery(v)
    end
end

function MySQL:connect()
    if self.loginDetails == null && !file.Exists( "gamemodes/" .. GAMEMODE_NAME .. "/gamemode/database/sv_login.lua", "GAME" ) then
        error("Setup sv_login.lua file!") 
    end

    print("------------------")
    print("MySQLOO Connecting")
    print("------------------")
    MySQL.database = mysqloo.connect(self.loginDetails.Host, self.loginDetails.Username, self.loginDetails.Password, self.loginDetails.Database, self.loginDetails.Port)
    MySQL.database:connect()
    
    function MySQL.database:onConnected()
        print("-----------------")
        print("MySQLOO Connected")
        print("-----------------")
        MySQL.isConnected = true
        MySQL:setup()
    end
    function MySQL.database:onConnectionFailed( err )
        print("--------------------------")
        print("MySQLOO Connection failed!")
        print( "Error:", err )
        print("--------------------------")
        MySQL.isConnected = false
    end
end

--/--- ---\\\
--/--- Query Setup ---\\\
function MySQL:getCreateQueries()
    local query_list = {}

    for dbtable, data in pairs(self.schema) do
        local query = {"CREATE TABLE IF NOT EXISTS",  dbtable,  "("}

        for idx, val in pairs(data) do
            table.insert(query, idx)

            for _, value in ipairs(val) do
                table.insert(query, value)
            end

            table.insert(query, ",")
        end

        query[#query] = ")"
        table.insert(query_list, table.concat(query, " "))
    end

    return query_list
end

--/--- ---\\\
--/--- Query Queuing ---\\\
function MySQL:makePriorityQuery( query, callback, ... )
    queryData = {}
    queryData.query = query
    queryData.callback = callback
    queryData.parameters = {...}
    
    table.insert(self.priorityCache, queryData)
end
function MySQL:makeQuery( query, callback, ... )
    queryData = {}
    queryData.query = query
    queryData.callback = callback
    queryData.parameters = {...}
    
    table.insert(self.cache, queryData)
end

--/--- ---\\\
--/--- Query Processing ---\\\
function MySQL:processQuery(queryData)
    if not queryData.query then print("Ignoring") return end
    
    local query = self.database:query(queryData.query)
    query:start()
    
    function query:onSuccess(data)
        if not queryData.callback then return end        
        local valid, info
        
        if queryData.parameters then
            valid, info = pcall(queryData.callback, data, unpack(queryData.parameters))
        else
            valid, info = pcall(queryData.callback, data)
        end
        
        if not valid then
            print("Callback failed: "..info)
        end
    end
    
    function query:onError(err)
        print("An error occured while executing the query: " .. err)
    end
end

--/--- ---\\\
--/--- Formatting ---\\\
function MySQL:formatInsertQuery(dbtable, values)
    if not self.schema[dbtable] then return end
    local query = {"INSERT IGNORE INTO ",  dbtable,  " SET "}

    for idx, val in pairs(values) do
        table.insert(query, SQLStr(idx, true) .. " = " .. self:gmodToDatabase(dbtable, idx, val))
        table.insert(query, ", ")
    end

    query[#query] = nil

    return table.concat(query, "")
end
function MySQL:formatSelectQuery(dbtable, values, where, order, limit)
    if not self.schema[dbtable] then return end
    local query = {"SELECT "}
    values = (not values or table.Count(values) == 0) and {"*"} or values

    for _, val in pairs(values) do
        table.insert(query, SQLStr(val, true))
        table.insert(query, ", ")
    end

    query[#query] = " FROM " .. dbtable .. "  WHERE "

    for k, v in pairs(where) do
        table.insert(query, string.format(SQLStr(k, true), SQLStr(v, type(v) == "number")))
        table.insert(query, " AND ")
    end

    if order then
        query[#query] = " ORDER BY "
        local desc = false

        for k, v in pairs(order) do
            if v == "DESC" then
                desc = true
                continue
            end

            table.insert(query, SQLStr(v, true))
            table.insert(query, ", ")
        end

        if desc then
            query[#query] = " DESC"
            table.insert(query, " ")
        end
    end

    if limit then
        query[#query] = " LIMIT "
        table.insert(query, SQLStr(tonumber(limit), true))
        table.insert(query, " ")
    end

    query[#query] = nil

    return table.concat(query, "")
end
function MySQL:formatUpdateQuery(dbtable, values, where)
    if not self.schema[dbtable] then return end
    local query = {"UPDATE ",  dbtable,  " SET "}

    for idx, val in pairs(values) do
        table.insert(query, SQLStr(idx, true) .. " = " .. self:gmodToDatabase(dbtable, idx, val))
        table.insert(query, ", ")
    end

    query[#query] = " WHERE "

    for k, v in pairs(where) do
        table.insert(query, string.format(SQLStr(k, true), SQLStr(v, type(v) == "number")))
        table.insert(query, " AND ")
    end

    query[#query] = " LIMIT 1"

    return table.concat(query, "")
end

--/--- ---\\\
--/--- Conversions ---\\\
function MySQL:gmodToDatabase(dbtable, idx, value)
    if not self.schema[dbtable] then return value end
    if not self.schema[dbtable][idx] then return value end

    if self.schema[dbtable][idx].p_h then
        for k, v in pairs(MySQL.placeholder) do
            if value ~= k then continue end

            return v
        end
    elseif self.schema[dbtable][idx].type == "table" then
        return SQLStr(util.TableToJSON(value))
    elseif self.schema[dbtable][idx].type == "boolean" then
        return SQLStr(value and 1 or 0, true)
    elseif self.schema[dbtable][idx].type == "number" then
        return SQLStr(tonumber(value), true)
    end

    return SQLStr(value)
end

function MySQL:databaseToGmod(dbtable, idx, value)
    if not self.schema[dbtable] then return value end
    if not self.schema[dbtable][idx] then return value end

    if self.schema[dbtable][idx].type == "table" then
        return util.JSONToTable(value)
    elseif self.schema[dbtable][idx].type == "boolean" then
        return value == 1
    elseif self.schema[dbtable][idx].type == "number" then
        return tonumber(value)
    end

    return tostring(value)
end

--/--- ---\\\
--/--- TK.DB Functions ---\\\
function TK.DB:IsConnected()
    return MySQL.isConnected
end

function TK.DB:ConnectionID()
    return MySQL.connectionID
end

function TK.DB:InsertQuery(dbtable, values)
    MySQL:makeQuery(MySQL:FormatInsertQuery(dbtable, values))
end

function TK.DB:SelectQuery(dbtable, values, where, order, limit, callback, ...)
    MySQL:makePriorityQuery(MySQL:formatSelectQuery(dbtable, values, where, order, limit), callback, ...)
end
function TK.DB:UpdateQuery(dbtable, values, where)
    MySQL:makeQuery(MySQL:formatUpdateQuery(dbtable, values, where))
end

function TK.DB:GmodToDatabase(dbtable, idx, value)
    return MySQL:gmodToDatabase(dbtable, idx, value)
end

function TK.DB:DatabaseToGmod(dbtable, idx, value)
    return MySQL:databaseToGmod(dbtable, idx, value)
end

--/--- Hooks ---\\\
hook.Add("Initialize", "MySQLLoad", function()
    MySQL:connect()
end)

hook.Add("OnReloaded", "MySQLLoad", function()
    MySQL:connect()
end)

hook.Add("Tick", "MySQLQuery", function()
    local pcache_count = #MySQL.priorityCache
    local cache_count = #MySQL.cache
    if pcache_count == 0 and cache_count == 0 then return end

    if pcache_count ~= 0 then
        MySQL:processQuery(MySQL.priorityCache[1])
        table.remove(MySQL.priorityCache, 1)
    elseif cache_count ~= 0 then
        MySQL:processQuery(MySQL.cache[1])
        table.remove(MySQL.cache, 1)
    else
        print("Query System Error")
    end
end)