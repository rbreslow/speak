local function fastdl()
    for _,path in ipairs(include "gen/resources.lua") do
        -- empty/new line at eof
        if #path > 0 then
            speak.logger.trace("adding", path)
            resource.AddFile(path)
        end
    end
end

if speak.settings.FAST_DL then
    fastdl()
else
    speak.logger.trace("adding workshop addon", speak.settings.WORKSHOP_ID)
    resource.AddWorkshop(speak.settings.WORKSHOP_ID)
end

