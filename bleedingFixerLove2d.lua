local spr = app.activeSprite

-- Checks for a valid sprite
if not spr then
    app.alert("There is no sprite to export")
    return
end

local d = Dialog("Bleading Fixer for LOVE2D")
d:label{ id="help", label="", text="Set the width and height of the tile" }
 :number{ id="tile_w", label="Tile Width:", text="16", focus=true }
 :number{ id="tile_h", label="Tile Height:", text="16" }
 :check {id="sameColor", label="Same color:", selected = true}
 :button{ id="ok", text="&OK", focus=true }
 :button{ text="&Cancel" }
 :show()

 -- Data validation
local data = d.data
if not data.ok then return end

function Fixer(tile_w, tile_h, spr)
    local rows = math.floor(spr.height/tile_h)
    local cols = math.floor(spr.width/tile_w)

    --resizing canvas
    spr.width = cols * (tile_w + 2)
    spr.height = rows * (tile_h + 2)
    
    --Split horizontally
    spr.selection = Selection(Rectangle(0, 0, spr.width, spr.height))    
    app.command.MoveMask{
        target='content',
        direction='right',
        units='pixel',
        quantity=1,
        wrap=true
        }

        app.command.DeselectMask()

    for i = 2, cols, 1 do
        spr.selection = Selection(Rectangle(-1 + ((i - 1) * (tile_w + 2)), 0, spr.width, spr.height))
        
        app.command.MoveMask{
            target='content',
            direction='right',
            units='pixel',
            quantity=2,
            wrap=true
          }

          app.command.DeselectMask()
    end

    --Spliting vertically
    spr.selection = Selection(Rectangle(0, 0, spr.width, spr.height))
    app.command.MoveMask{
        target='content',
        direction='down',
        units='pixel',
        quantity=1,
        wrap=true
        }
    app.command.DeselectMask()

    for i = 2, rows, 1 do
        spr.selection = Selection(Rectangle(0, -1 + ((i - 1) * (tile_h + 2)), spr.width, spr.height))
        
        app.command.MoveMask{
            target='content',
            direction='down',
            units='pixel',
            quantity=2,
            wrap=true
          }
          app.command.DeselectMask()
    end
    if data.sameColor then
        --left
        hSelection = Selection()
        for i = 1, cols, 1 do
            hSelection:add(Selection(Rectangle(1 + ((i - 1) * (tile_w + 2)), 0, 1, spr.height)))
        end

        spr.selection = hSelection
        app.command.Copy()
        app.command.DeselectMask()
        app.command.Paste()
        app.command.DeselectMask()

        --right
        hSelection = Selection()
        for i = 1, cols, 1 do
            hSelection:add(Selection(Rectangle(-2 + (i * (tile_w + 2)), 0, 1, spr.height)))
        end

        spr.selection = hSelection
        app.command.Copy()
        app.command.DeselectMask()
        app.command.Paste()
        app.command.MoveMask{
            target='content',
            direction='right',
            units='pixel',
            quantity=tile_w + 1,
            wrap=false
        }
        app.command.DeselectMask()

        --up
        vSelection = Selection()
        for i = 1, rows, 1 do
            vSelection:add(Selection(Rectangle(0, 1 + ((i - 1) * (tile_w + 2)), spr.width, 1)))
        end

        spr.selection = vSelection
        app.command.Copy()
        app.command.DeselectMask()
        app.command.Paste()
        app.command.DeselectMask()

        --down
        vSelection = Selection()
        for i = 1, rows, 1 do
            vSelection:add(Selection(Rectangle(0, -2 + (i * (tile_w + 2)), spr.width, 1)))
        end

        spr.selection = vSelection
        app.command.Copy()
        app.command.DeselectMask()
        app.command.Paste()
        app.command.MoveMask{
            target='content',
            direction='down',
            units='pixel',
            quantity= tile_h + 1,
            wrap=false
        }
        app.command.DeselectMask()
    end
end
app.transaction(
    function ()
        Fixer(data.tile_w, data.tile_h, spr)
    end
)