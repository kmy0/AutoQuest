local vars = {}

vars.posting = false
vars.interact_trigger = false
vars.selected = false
vars.decide_trigger = false
vars.cursor = nil
vars.selection_timer = 0
vars.selection_timer_max = 1500
vars.selection_trigger = false
vars.close_trigger = false
vars.post_quest_trigger = false
vars.posting_method_changed = false
vars.prev_game_state = nil
vars.game_state = nil
vars.quest_type = nil
vars.matching = false

return vars
