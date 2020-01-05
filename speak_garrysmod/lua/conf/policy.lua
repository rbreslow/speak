local policy = Policy("speak")

--[[ tag_position (def: true)
     TRUE: enforce chat tags to be on the left.
     FALSE: enforce chat tags to be on the right.
]]
-- policy:Enforce("tag_position", true)

--[[ emoji_pack (def: 1)
    1: enforce everyone to use Apple emoji.
    2: enforce everyone to use Google emoji.
    3: enforce everyone to use Twitter emoji.
    4: enforce everyone to use Emoji One emoji.

    IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("emoji_pack", 1)

--[[ emoji_enabled (def: true)
     TRUE: enforce emoji to be enabled.
     FALSE: enforce emoji to be disabled.
]]
-- policy:Enforce("emoji_enabled", true)

--[[ timestamps_enabled (def: true)
     TRUE: enforce displaying timestamps in the console log to be enabled.
     FALSE: enforce displaying timestamps in the console log to be disabled.
]]
-- policy:Enforce("timestamps_enabled", true)

--[[ timestamps_type (def: true)
     TRUE: enforce 12 hour time for all timestamps (1:00 PM as opposed to 13:00).
     FALSE: enforce 24 hour time for all timestamps (13:00 as opposed to 1:00 PM).

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("timestamps_type", true)

--[[ timestamps_color (def: Color(114, 188, 212))
     any RGB color value, ex. Color(255, 0, 0) is red.
]]
-- policy:Enforce("timestamps_color", Color(114, 188, 212))

--[[ chatbox_x (def: 30)
     chatbox x coordinate.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("chatbox_x", 30)

--[[ chatbox_y (def: calculated on client)
     chatbox y coordinate. no default value cause default value is dependent on screen height.

     !!! IT IS NOT ESPECIALLY NOT RECCOMENDED TO ENFORCE THIS VALUE. !!!
]]
-- policy:Enforce("chatbox_y", 50)

--[[ chatbox_w (def: 614)
     chatbox width.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("chatbox_w", 614)

--[[ chatbox_h (def: 376)
     chatbox height.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("chatbox_h", 376)

--[[ avatars_enabled (def: true)
     TRUE: enforce displaying avatars in chat.
     FALSE: enforce not displaying avatars in chat.
]]
-- policy:Enforce("avatars_enabled", true)

--[[ avatars_type (def: false)
     TRUE: enforce avatars showing as player models.
     FALSE: enforce avatars showing as steam avatars.
]]
-- policy:Enforce("avatars_type", false)

--[[ font_name (def: "Roboto Bold")
     font name.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("font_name", "Roboto Bold")

--[[ font_size (def: 11)
     font size in point.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("font_size", 11)

--[[ font_weight (def: 100)
     font weight.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("font_weight", 100)

--[[ font_border_type (def: true)
     TRUE: drop shadow.
     FALSE: stroke around text.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("font_border_type", true)

--[[ font_border_blur (def: 1)
     font border blur.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("font_border_blur", 1)

--[[ font_border_opacity (def: 1)
     range has to be between 0.1 to 1.0.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("font_border_opacity", 1)

--[[ notification_sound (def: 1)
     1: Ding
     2: Ta Da!
     3: Here you go
     4: Knock brush
     5: Boing
     6: Plink
     7: Hi
     8: Woah
     9: Drop
     10: Wow
     12: Yoink
     12: *DISABLE SOUNDS*

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("notification_sound", 1)

--[[ notification_duration (def: 10)
     duration to display notifications in seconds.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("notification_duration", 10)

--[[ notification_enabled (def: true)
     TRUE: display notifications.
     FALSE: don't display notifications.

     IT IS NOT RECCOMENDED TO ENFORCE THIS VALUE.
]]
-- policy:Enforce("notification_enabled", true)

--[[ show_typing (def: true)
     TRUE: display messages as players write them out above their heads.
     FALSE: don't display messages as players write them out above their heads.
]]
-- policy:Enforce("show_typing", true)

policy:UpdateClients()

--[[ Compatability Layer for Clockwork and DarkRP ]]
hook.Add("Initialize", "speak.policy.Initialize", function()
    if Clockwork or DarkRP then
        -- If we're in a roleplaying gamemode then force the avatars to be displayed as player models
        policy:Enforce("avatars_type", true)
        policy:UpdateClients()
    end
end)



