SMODS.Atlas {
  -- Key for code to find it with
  key = "KTaNE",
  -- The name of the file, for the code to pull the atlas from
  path = "KTaNE.png",
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}

SMODS.current_mod.optional_features = { cardareas = { unscored = true } }

function count_enhancements()
	local enhancement_tally = 0
    for k, v in pairs(G.playing_cards) do
        if v.ability.name ~= G.P_CENTERS.c_base then enhancement_tally = enhancement_tally + 1 end
    end
	return enhancement_tally
end

SMODS.Enhancement {
	object_type = "Enhancement",
	key = "module",
  loc_txt = {
    name = 'Module Card',
    text = {
      "{C:money}$#1#{} when played",
      "and scored",
      "{C:red,E:2}self destructs{}"
    }
  },
	atlas = "KTaNE",
	pos = { x = 0, y = 1 },
	config = { p_dollars = 3 },
	loc_vars = function(self, info_queue)
		return { vars = { self.config.p_dollars } }
	end,
  calculate = function(self, card, context)
    if context.destroying_card then
      G.E_MANAGER:add_event(Event({
        func = function()
          card:start_dissolve()
  
          G.E_MANAGER:add_event(Event {
            func = function()
              SMODS.calculate_context({
                remove_playing_cards = true,
                removed = { card }
              })
              return true
            end
          })
  
          return true
        end
      }))
    card.destroyed = true
    end
  end
}

SMODS.Joker {
  key = 'wires',
  loc_txt = {
    name = 'Wires',
    text = {
      "Solves when idk"
    }
  },
  config = { extra = { solved = false } },
  rarity = 2,
  atlas = 'KTaNE',
  cost = 7,
  pos = { x = 1, y = 0 },
  solved_pos = { x = 2, y = 0 },
  loc_vars = function(self, info_queue, card)
    return { vars = {  } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main then
      card.ability.extra.solved = true
      card.children.center:set_sprite_pos(self.solved_pos)
    end
  end,
  set_sprites = function(self, card, front)
    if card and card.children and card.children.center and card.children.center.set_sprite_pos and card.ability and card.ability.extra and card.ability.extra.solved then
      card.children.center:set_sprite_pos(self.solved_pos)
    end
  end
}