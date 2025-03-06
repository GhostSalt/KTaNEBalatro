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
  if not G.playing_cards then return 0 end
	local enhancement_tally = 0
    for k, v in pairs(G.playing_cards) do
      if next(SMODS.get_enhancements(v)) then enhancement_tally = enhancement_tally + 1 end
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
      "{C:green,s:0.75}To solve this Joker:{}",
	  "{C:attention}Destroy{} a {C:diamonds}Diamond{} card {C:inactive}[#3#]{}, {C:clubs}Club{} card {C:inactive}[#4#]{},",
	  "{C:hearts}Heart{} card {C:inactive}[#5#]{} and {C:spades}Spade{} card {C:inactive}[#6#]{}",
      "{C:green,s:0.75}When solved, gains the ability:{}",
	  "Gives {C:white,X:mult}X#1#{} Mult per",
	  "card {C:attention}destroyed{}",
	  "{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult){}"
    }
  },
  config = { extra = { solved = false, added_xmult = 0.5, current_xmult = 1, diamond_status = "N", club_status = "N", heart_status = "N", spade_status = "N" } },
  rarity = 2,
  atlas = 'KTaNE',
  cost = 8,
  pos = { x = 1, y = 0 },
  solved_pos = { x = 2, y = 0 },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult, card.ability.extra.diamond_status, card.ability.extra.club_status, card.ability.extra.heart_status, card.ability.extra.spade_status } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.solved and card.ability.extra.current_xmult > 1 then return { xmult = card.ability.extra.current_xmult } end
	
    if context.remove_playing_cards then
	  if not card.ability.extra.solved then
        for k, v in ipairs(context.removed) do
	 	  if v:is_suit("Diamonds") then card.ability.extra.diamond_status = "Y" end
	 	  if v:is_suit("Clubs") then card.ability.extra.club_status = "Y" end
	 	  if v:is_suit("Hearts") then card.ability.extra.heart_status = "Y" end
	 	  if v:is_suit("Spades") then card.ability.extra.spade_status = "Y" end
	    end
	  else
	    card.ability.extra.current_xmult = card.ability.extra.current_xmult + (card.ability.extra.added_xmult * #context.removed)
	  end
	  
	  local should_solve = not card.ability.extra.solved and card.ability.extra.diamond_status == "Y" and card.ability.extra.club_status == "Y" and card.ability.extra.heart_status == "Y" and card.ability.extra.spade_status == "Y"
	  card.ability.extra.solved = should_solve or card.ability.extra.solved
	  if should_solve then
	    card.children.center:set_sprite_pos(self.solved_pos)
	  end
    end
  end,
  set_sprites = function(self, card, front)
    if card and card.children and card.children.center and card.children.center.set_sprite_pos and card.ability and card.ability.extra and card.ability.extra.solved then
      card.children.center:set_sprite_pos(self.solved_pos)
    end
  end
}

SMODS.Joker {
  key = 'thebutton',
  loc_txt = {
    name = 'The Button',
    text = {
      "{C:green,s:0.75}To solve this Joker:{}",
	  "Play {C:attention}#3#{} {C:inactive}[#4#]{} High Cards",
      "{C:green,s:0.75}When solved, gains the ability:{}",
	  "Gives {C:white,X:mult}X#1#{} Mult",
	  "per used {C:planet}Pluto{}",
	  "{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult){}"
    }
  },
  config = { extra = { solved = false, added_xmult = 0.5, current_xmult = 1, target_high_cards = 11, current_high_cards = 0 } },
  rarity = 2,
  atlas = 'KTaNE',
  cost = 8,
  pos = { x = 3, y = 0 },
  solved_pos = { x = 4, y = 0 },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult, card.ability.extra.target_high_cards, card.ability.extra.target_high_cards - card.ability.extra.current_high_cards } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.solved and card.ability.extra.current_xmult > 1 then return { xmult = card.ability.extra.current_xmult } end
	
    if context.using_consumeable and card.ability.extra.solved then
	  if context.consumeable.config.center.key == "c_pluto" then
	    card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
	  end
	end
	  
	if context.joker_main and context.scoring_name == "High Card" and not card.ability.extra.solved then
	  card.ability.extra.current_high_cards = card.ability.extra.current_high_cards + 1
	  
	  if card.ability.extra.current_high_cards >= card.ability.extra.target_high_cards then
	    card.ability.extra.solved = true
	    card.children.center:set_sprite_pos(self.solved_pos)
	  end
    end
  end,
  set_sprites = function(self, card, front)
    if card and card.children and card.children.center and card.children.center.set_sprite_pos and card.ability and card.ability.extra and card.ability.extra.solved then
      card.children.center:set_sprite_pos(self.solved_pos)
    end
  end
}