local SaveManager = {};
SaveManager.__index = SaveManager

local Service = setmetatable({},{
    __index = function(self, serviceName)
        local Passed, Statement = pcall(Instance.new, serviceName)
        local Service = Passed and Statement or game:GetService(serviceName) or settings():GetService(serviceName) or UserSettings():GetService(serviceName)

        if cloneref then
            Service = cloneref(Service)
        end

        self[serviceName] = Service
        return Service
    end
}
);

local HttpService = Service['HttpService'] 
local Players = Service['Players'] 
local LocalPlayer = Players.LocalPlayer;

function SaveManager.new(mainfolder,mode)
    --local self = setmetatable({},SaveManager)
    
    SaveManager.Data = {};
    SaveManager.Set = {};

    local function Update()
        if not isfile(SaveManager.LocalPlayerConfig) then return end;
        return writefile(SaveManager.LocalPlayerConfig,HttpService:JSONEncode({DataSave = SaveManager.Data}))
    end;

    SaveManager.configuration = {
        folder = mainfolder,
        Mode = mode,
    };

    if not isfolder(mainfolder) then makefolder(mainfolder); end;
    if not isfolder(mainfolder..'/User') then  makefolder(mainfolder..'/User');end;
    
    if not isfile(mainfolder..'/User/'..LocalPlayer.Name..'.json') then 
        writefile(mainfolder..'/User/'..LocalPlayer.Name..'.json',HttpService:JSONEncode({}))
    end;

    if mode then 
        if not isfolder(mainfolder..'/Macro') then makefolder(mainfolder..'/Macro'); end;
        SaveManager.MacroFolder = mainfolder..'/Macro';
    end;

    SaveManager.UserFolder = mainfolder..'/User';
    SaveManager.LocalPlayerConfig =  mainfolder..'/User/'..LocalPlayer.Name..'.json';

    setmetatable(SaveManager.Set,{ __newindex = function(table,key,value) 
        SaveManager.Data[key] = value;
        Update();
    end,});

    return SaveManager;
end;

function SaveManager.Export(path)
    if not path then return end;
    if not isfile(SaveManager.MacroFolder..'/'..path) then return end;

    return setclipboard(readfile(SaveManager.MacroFolder..'/'..path));
end;

function SaveManager.Import(url,name)
    local HttpGet = http_request or request

    local GET = HttpGet({
        ['Url'] = url,
        ['Method'] = 'GET',
    });

    local decode = HttpService:JSONDecode('['..GET['Body']..']');
    local encode =  HttpService:JSONEncode(decode);
    writefile(SaveManager.MacroFolder..'/'..name..'.json',encode)
end;

function SaveManager:Update()
    if not isfile(SaveManager.LocalPlayerConfig) then return end;
    return writefile(SaveManager.LocalPlayerConfig,HttpService:JSONEncode({DataSave = SaveManager.Data}))
end;

function SaveManager:Load(default) 
    if isfile(SaveManager.LocalPlayerConfig) then 
        local success,statement = pcall(function()
            local decode = HttpService:JSONDecode(readfile(SaveManager.LocalPlayerConfig));
            if not decode.DataSave then return end;
            SaveManager.Data = decode.DataSave;
        end)

        if not success then     
            delfile(SaveManager.LocalPlayerConfig);
            SaveManager.new(SaveManager.configuration.folder,SaveManager.configuration.Mode);
        end;
    end;

    for key,data in next , default do
        if (not SaveManager.Data[key]) then
            SaveManager.Data[key] = data;
        end;
    end;
end;

function SaveManager.MakeMacroFile(name)
    if not SaveManager.configuration.Mode then return end;

    if isfile(SaveManager.MacroFolder..'/'..name..".json") then 
        return 'This file already exists'
    end;

    writefile(SaveManager.MacroFolder..'/'..name..".json",HttpService:JSONEncode({}));
    return name;
end;

function SaveManager.SaveMacro(name,data)
    if not SaveManager.configuration.Mode then return end;
    if not isfile(SaveManager.MacroFolder..'/'..name..".json") then return end;
    local encode = HttpService:JSONEncode(data);

    writefile(SaveManager.MacroFolder..'/'..name..".json",encode);
end;

function SaveManager.RemoveMacroFile(name)
    if not SaveManager.configuration.Mode then return end;

    if not (SaveManager.MacroFolder..'/'..name..".json") then 
        return 'This file was not found.'
    end;

    delfile(SaveManager.MacroFolder..'/'..name..".json");
    return true;
end;

function SaveManager.GetFiles(path,mode)
    local list = listfiles(path);
    local out = {};

    for i = 1, #list do
        local file = list[i]
        if file:sub(-5) == '.json' then
            local pos = file:find('.json', 1, true)
            local start = pos

            local char = file:sub(pos, pos)

            while char ~= '/' and char ~= '\\' and char ~= '' do
                pos = pos - 1
                char = file:sub(pos, pos)
            end

            if char == '/' or char == '\\' then
                table.insert(out, file:sub(pos + 1, start - 1))
            end;
        end;
    end;

    if mode then 
        table.insert(out,'AI - Full Auto Play')
    end;

    return out;
end;


return SaveManager;
