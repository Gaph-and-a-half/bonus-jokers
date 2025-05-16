
to_big = to_big or function(x)
  return x
end
to_number = to_number or function(x)
  return x
end

local ed = ease_dollars
function ease_dollars(mod, x)
    ed(mod, x)
    for i = 1, #G.jokers.cards do
	    eval_card(G.jokers.cards[i], { BNS_ease_dollars = to_big(mod)})
    end
end

local function contains(table_, value)
    for _, v in pairs(table_) do
        if v == value then
            return true
        end
    end

    return false
end

SMODS.Atlas{
    key = 'Jokers', 
    path = 'Jokers.png', 
    px = 71,
    py = 95
}

SMODS.Joker{ --Archibald
    name = "Archibald",
    key = "archibald",
    config = {
        extra = {
            XMult = 1,
            XMultMod = 0.1,
            odds = 2
        }
    },
    loc_txt = {
        ['name'] = 'Archibald',
        ['text'] = {
            [1] = "Whenever {C:money}money{} is earned,",
            [2] = "{C:green}#3# in #4#{} chance for this",
            [3] = "Joker to gain {X:mult,C:white}X#2#{} Mult",
            [4] = "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive})"
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    soul_pos = { 
        x = 0, 
        y = 1 
    },
    cost = 20,
    rarity = 4,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'Jokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.XMult, card.ability.extra.XMultMod, G.GAME.probabilities.normal, card.ability.extra.odds}}
    end,

    calculate = function(self, card, context)
        if context.BNS_ease_dollars and not context.blueprint then
            if context.BNS_ease_dollars > to_big(0) and pseudorandom('archi') < G.GAME.probabilities.normal / card.ability.extra.odds then
                card.ability.extra.XMult = card.ability.extra.XMult + card.ability.extra.XMultMod
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.XMult}},
                        colour = G.C.RED,
                    card = card
                })
            end

        elseif context.cardarea == G.jokers and context.joker_main and card.ability.extra.XMult > 1 then
            return{
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.XMult}},
                Xmult_mod = card.ability.extra.XMult
            }
        end
    end
}

SMODS.Joker{ --Hungry Joker
    name = "Hungry Joker",
    key = "hungryjoker",
    config = {
        extra = {
            XMult = 1,
            XMultMod = 0.5
        }
    },
    loc_txt = {
        ['name'] = 'Hungry Joker',
        ['text'] = {
            [1] = "If played hand contains ",
            [2] = "both a scoring {C:attention}7{} and {C:attention}9{},",
            [3] = "destroy all scoring {C:attention}9{},",
            [4] = "and this Joker gains {X:mult,C:white}X#2#{} Mult",
            [5] = "for each {C:attention}9{} destroyed",
            [6] = "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive})"
        }
    },
    pos = {
        x = 4,
        y = 0
    },
    cost = 9,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'Jokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.XMult, card.ability.extra.XMultMod}}
    end,

    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == G.play and not context.blueprint then
            local _seven, _nine = false, false
            for i = 1, #context.scoring_hand do
                if not SMODS.has_no_rank(context.scoring_hand[i]) then
                    if context.scoring_hand[i]:get_id() == 7 then
                        _seven = true
                        if _nine == true then
                            break
                        end
                    end
                    if context.scoring_hand[i]:get_id() == 9 then
                        _nine = true
                        if _seven == true then
                            break
                        end
                    end
                end
            end
            if _seven and _nine and context.destroy_card:get_id() == 9 then
                card.ability.extra.XMult = card.ability.extra.XMult + card.ability.extra.XMultMod
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.XMult}},colour = G.C.RED,card = card})
                return {
                remove = true,
                message = localize('k_upgrade_ex'),
                card = card
                }
            end
            
        elseif context.cardarea == G.jokers and context.joker_main and card.ability.extra.XMult > 1 then
            return{
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.XMult}},
                Xmult_mod = card.ability.extra.XMult
            }
        end
    end
}

SMODS.Joker{ --Recyclomancer
    name = "Recyclomancer",
    key = "recyclomancer",
    config = {
        extra = {
            unc_sold = 0,
            total = 3
        }
    },
    loc_txt = {
        ['name'] = 'Recyclomancer',
        ['text'] = {
            [1] = "After {C:green}#2# Uncommon {C:money}Jokers",
            [2] = "have been {C:money}sold{}, create",
            [3] = "a random {C:red}Rare {C:money}Joker",
            [4] = "{C:inactive}(Must have room)",
            [5] = "{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#)"
        }
    },
    pos = {
        x = 1,
        y = 0
    },
    cost = 7,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'Jokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.unc_sold, card.ability.extra.total}}
    end,

    calculate = function(self, card, context)
        if context.selling_card then
            if context.card.config.center.rarity == 2 then
                card.ability.extra.unc_sold = card.ability.extra.unc_sold + 1
                if card.ability.extra.unc_sold < card.ability.extra.total then
                    return {
                        message = 'Casting...',
                        colour = G.C.GREEN
                    }
                elseif card.ability.extra.unc_sold == card.ability.extra.total then
                   local new_card = create_card('Joker', G.jokers, false, 3)
                   new_card:add_to_deck()
                   G.jokers:emplace(new_card)
                   card.ability.extra.unc_sold = 0
                   return {
                       message = 'Recycled!',
                       colour = G.C.RED
                   }
                end
            end
        end
    end
}

SMODS.Joker{ --Utility Knife
    name = "Utility Knife",
    key = "utilityknife",
    config = {
        extra = {
            amount = 3
        }
    },
    loc_txt = {
        ['name'] = 'Utility Knife',
        ['text'] = {
            [1] = "If played hand contains {C:money}#1#{} or more ",
            [2] = " {C:money}unique enhancements{},",
            [3] = "{C:money}retrigger {}all played {C:money}enhanced {}cards"
        }
    },
    pos = {
        x = 2,
        y = 0
    },
    cost = 8,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'Jokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.amount}}
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition then
            local enhanced = {}
            for i=1, #context.scoring_hand do
                for k, v in pairs(SMODS.get_enhancements(context.scoring_hand[i])) do
                    if v then
                        if not contains(enhanced, k) then
                            enhanced[#enhanced+1] = k
                        end
                    end
                end
            end
            if #enhanced >= card.ability.extra.amount and next(SMODS.get_enhancements(context.other_card)) then
                return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
            end
        end
    end
}

SMODS.Joker{ --Fruitcake
    name = "Fruitcake",
    key = "fruitcake",
    config = {
        extra = {
            hand_penalty = -3
        }
    },
    loc_txt = {
        ['name'] = 'Fruitcake',
        ['text'] = {
            [1] = "{C:red}-3 {}hand size",
            [2] = "Sell this joker to give every card",
            [3] = "held in hand a random {C:attention}seal"
        }
    },
    pos = {
        x = 3,
        y = 0
    },
    cost = 8,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'Jokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.hand_penalty}}
    end,

    add_to_deck = function(self, card, from_debuff)
		G.hand:change_size(card.ability.extra.hand_penalty)
	end,

    remove_from_deck = function(self, card, from_debuff)
		G.hand:change_size(-card.ability.extra.hand_penalty)
	end,
    
    calculate = function(self, card, context)
        if context.selling_self then
            for i=1, #G.hand.cards do
                local scard = G.hand.cards[i]
                local seal_type = SMODS.poll_seal({guaranteed = true})
                scard:set_seal(seal_type, true)
                scard:juice_up(0.5,0.5)
            end
        end
    end
}

