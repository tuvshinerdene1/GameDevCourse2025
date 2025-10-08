# DialogueData.gd - Autoload singleton for managing dialogue content
#class_name DialogueData extends Node
extends Node

# Store all dialogue trees
var dialogue_trees: Dictionary = {}
var portraits: Dictionary = {}

func _ready():
	_load_portraits()
	_load_dialogue_trees()

func _load_portraits():
	# Load portrait images - replace with your actual portrait paths
	portraits["narrator"] = preload("res://icon.svg")
	portraits["creaky_voice"] = preload("res://icon.svg")
	portraits["manly_voice"] = preload("res://icon.svg")
	portraits["michael"] = preload("res://icon.svg")
	portraits["irons"] = preload("res://icon.svg")
	portraits["david"] = preload("res://icon.svg")
	portraits["old_lady"] = preload("res://icon.svg")
	portraits["friend"] = preload("res://icon.svg")
	portraits["boy"] = preload("res://icon.svg")

func _load_dialogue_trees():
	# ========================================
	# FRAGMENT 1: AWAKENING
	# ========================================
	dialogue_trees["awakening"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The morning light beams through cracked window to dirty living room. Several empty bottles of 'Sailor's Fortune' vodka litter the room. The air reeks of sweat, urine, and vomit.",
			"next": "wake_up"
		},
		"wake_up": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "Wake up, shithead. Don't you wanna party again? That's what you want the most isn't it?",
			"next": "who_are_you"
		},
		"who_are_you": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "Who are you? Your voice isn't coming. Just by thinking the simplest phrase, your brain suffers from the horrible hangover.",
			"next": "i_am_you"
		},
		"i_am_you": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "I am you, shithead. I am you but with a bit of something called dignity.",
			"next": "dont_be_harsh"
		},
		"dont_be_harsh": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "Don't be too harsh for him. He still can pick himself up from this mess.",
			"next": "embarrassing"
		},
		"embarrassing": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "Why not! He has been fucking embarrassing us for his whole career. Look at Mr. Optimistic...",
			"next": "not_dead"
		},
		"not_dead": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "You are not dead. Yet.",
			"next": "why_dead"
		},
		"why_dead": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "Why would I be dead?",
			"next": "best_selling_book"
		},
		"best_selling_book": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "Because isn't that what you are trying to accomplish instead of your 'best selling murder book'?",
			"next": "bad_choices"
		},
		"bad_choices": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "Because your choices haven't been the best ones in the past mate.",
			"next": "what_to_do"
		},
		"what_to_do": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "What should I do now?",
			"next": "get_up"
		},
		"get_up": {
			"speaker": "BOTH VOICES",
			"speaker_id": "narrator",
			"text": "Just get up and live another day.",
			"next": "light_flickers"
		},
		"light_flickers": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "Light flickers.",
			"choices": []
		}
	}
	
	# ========================================
	# FRAGMENT 2: IN THE LAB
	# ========================================
	dialogue_trees["lab_intro"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "Two people in a chilly, neat clean lab are staring at a computer terminal.",
			"next": "valid_candidate"
		},
		"valid_candidate": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "Do you still think he is a valid candidate?",
			"next": "only_one"
		},
		"only_one": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "He was the only one. The only one with prefrontal cortex and amygdala somewhat in contact.",
			"next": "injuries"
		},
		"injuries": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Both hands got severed, the chest ruptured but the brain was not that bad. Can't say the same about other victims.",
			"next": "explosion_question"
		},
		"explosion_question": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "Brain not that bad? He was near the man who exploded right?",
			"next": "explosion_angle"
		},
		"explosion_angle": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Yes, maybe the explosion angle was in our favor.",
			"next": "how_explode"
		},
		"how_explode": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "How does one just explode like a bomb? There was no clear evidence of any kind of explosive devices, chemicals right?",
			"next": "spontaneous"
		},
		"spontaneous": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Spontaneous human combustion it is.",
			"next": "internet_nonsense"
		},
		"internet_nonsense": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "But that's just internet nonsense isn't it?",
			"next": "better_assumption"
		},
		"better_assumption": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Do you have a better assumption?",
			"next": "no_still"
		},
		"no_still": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "No, still...",
			"next": "get_to_work"
		},
		"get_to_work": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Well Michael, let's get to work. The client said to do it in an hour most.",
			"next": "memory_program"
		},
		"memory_program": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "The memory reconstruction program works by connecting memory fragments. When enough fragments are connected in a layer, we can access the memory of the deceased.",
			"next": "what_if_fail"
		},
		"what_if_fail": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "What if I fail?",
			"next": "restart_buffer"
		},
		"restart_buffer": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Just restart it. Also, the human memory is encoded to a very large file, so we can't afford overflowing our buffer. When buffer overflows, it will restart automatically.",
			"next": "got_it"
		},
		"got_it": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "Okay I got it Mr. Irons.",
			"choices": []
		}
	}
	
	# ========================================
	# FRAGMENT 3: THE MESSY MORNING
	# ========================================
	dialogue_trees["messy_morning"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You barely get up naked. As naked as how you were introduced to the world from your mother's womb. Knees are shivering, head's aching beyond comprehension.",
			"next": "look_apartment"
		},
		"look_apartment": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "Look at your apartment. Why don't you sip the Sailor's Fortune and lie a bit?",
			"next": "get_dressed"
		},
		"get_dressed": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "Why don't you get dressed? Fresh air might help you a bit.",
			"next": "distinguished"
		},
		"distinguished": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You wear your dirty shirt, stained jeans and a sandal.",
			"next": "look_gentleman"
		},
		"look_gentleman": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "Look at this distinguished gentleman.",
			"next": "shut_up"
		},
		"shut_up": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "Shut up.",
			"next": "brick"
		},
		"brick": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "Sudden noise!! You turn around and found out someone threw a brick to your window and broke it. You approach the brick and there is a note attached on it.",
			"next": "note_text"
		},
		"note_text": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "'We demand truth, truth about what happened to 13 researchers!!' While you were sleeping, something terrible must have happened.",
			"next": "synapse_riot"
		},
		"synapse_riot": {
			"speaker": "SYNAPSE",
			"speaker_id": "narrator",
			"text": "There's been a riot caused by sudden disappearances of 13 scientists that went on a government demanded expedition. Well, the text on the graffiti and flags say so, but deep down they were fed up with the suppressive government.",
			"next": "date"
		},
		"date": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You read the note and there is a date: '2037.10.12'",
			"next": "when_explosion"
		},
		"when_explosion": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "Mr. Irons, when was the explosion?",
			"next": "13th"
		},
		"13th": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "13th of October. We must be close then. Keep going.",
			"next": "find_food"
		},
		"find_food": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You tried to find something to eat, but no success.",
			"next": "food_outside"
		},
		"food_outside": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "Maybe we will find food outside.",
			"next": "no_money"
		},
		"no_money": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "Like you have the money to buy it!",
			"next": "door"
		},
		"door": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You walk upon your door and open it.",
			"next": "forgot_lock"
		},
		"forgot_lock": {
			"speaker": "SYNAPSE",
			"speaker_id": "narrator",
			"text": "You forgot to lock?",
			"next": "no_lock"
		},
		"no_lock": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "There was none. You left the apartment.",
			"choices": []
		}
	}
	
	# ========================================
	# LAB INTERLUDE 1
	# ========================================
	dialogue_trees["lab_interlude_1"] = {
		"start": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "We're getting good data. The memory fragments are connecting.",
			"next": "irons_response"
		},
		"irons_response": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Keep the buffer stable. We need every detail.",
			"choices": []
		}
	}
	
	# ========================================
	# FRAGMENT 4: IN THE HALLWAY
	# ========================================
	dialogue_trees["hallway"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "While you were walking the apartment hallway, an old lady with gray hair and a hunchback is clearing the floor with dirty clothes.",
			"next": "david"
		},
		"david": {
			"speaker": "OLD LADY",
			"speaker_id": "old_lady",
			"text": "David?",
			"next": "synapse_name"
		},
		"synapse_name": {
			"speaker": "SYNAPSE CONNECTING",
			"speaker_id": "narrator",
			"text": "YOUR NAME WAS, NO 'IS' DAVID.",
			"next": "yes"
		},
		"yes": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "Yes.",
			"next": "forget_yesterday"
		},
		"forget_yesterday": {
			"speaker": "OLD LADY",
			"speaker_id": "old_lady",
			"text": "Please forget what I told you yesterday. Maybe I was too harsh to you. Everyone has those days you know.",
			"next": "remember_question"
		},
		"remember_question": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "You even remember what she said?",
			"next": "let_continue"
		},
		"let_continue": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "It's better to let her continue.",
			"next": "rent_late"
		},
		"rent_late": {
			"speaker": "OLD LADY",
			"speaker_id": "old_lady",
			"text": "I'm fine with your rent being late, just take care of yourself and pay it later ok?",
			"next": "yes_madam"
		},
		"yes_madam": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "Yes madam.",
			"next": "terrible_riot"
		},
		"terrible_riot": {
			"speaker": "OLD LADY",
			"speaker_id": "old_lady",
			"text": "And you really wanna go outside? There's a terrible riot.",
			"next": "fresh_air"
		},
		"fresh_air": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "I think I should get some fresh air and buy groceries madam.",
			"next": "be_careful"
		},
		"be_careful": {
			"speaker": "OLD LADY",
			"speaker_id": "old_lady",
			"text": "Your choice then, but be careful ok?",
			"next": "ok"
		},
		"ok": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "Ok.",
			"choices": []
		}
	}
	
	# ========================================
	# FRAGMENT 5: IN THE STREET
	# ========================================
	dialogue_trees["street"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You walk outside. People are rioting. On the opposite side, policemen with shields and batons are standing like a wall. A weak wall.",
			"next": "everyone_down"
		},
		"everyone_down": {
			"speaker": "WOMAN'S VOICE",
			"speaker_id": "narrator",
			"text": "Everyone down!",
			"next": "tear_gas"
		},
		"tear_gas": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "A strange green cloud emerges in the crowd. Must be something poisonous. Your eyes feel the sting. Tears slowly flow without control. It must have been tear gas.",
			"next": "knocked_down"
		},
		"knocked_down": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You stumble among the crowd to get to safety and someone hits you in the head with a protest flag. You got knocked down on the road.",
			"next": "vague_sounds"
		},
		"vague_sounds": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The sound of the crowd yelling becomes as vague as an old TV quietly flickering. In the merge of passing out, a hand holds you firmly and lifts.",
			"next": "carried"
		},
		"carried": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You are unable to walk. The man must have realized that, as he swiftly lifts you and runs.",
			"next": "safety"
		},
		"safety": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "It must've been around at least 10 minutes when you two finally came to safety. The man puts you down gently on the ground and says 'Go yourself from here.'",
			"next": "recognition"
		},
		"recognition": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The familiar eyes, long nose, and black hair. The big birthmark that looks as if he had a terrible burn on half of his face.",
			"next": "synapse_connect"
		},
		"synapse_connect": {
			"speaker": "SYNAPSE CONNECTING",
			"speaker_id": "narrator",
			"text": "He maybe realized too.",
			"next": "you_exclaim"
		},
		"you_exclaim": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "You!!",
			"next": "phone_rings"
		},
		"phone_rings": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "His phone rang and he picks it up. 'Oh I'm coming there now sweety.'",
			"next": "resentful_look"
		},
		"resentful_look": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "Without saying a word, he gave the last resentful look and runs away. You stay on the ground, motionless.",
			"choices": []
		}
	}
	
	# ========================================
	# LAB INTERLUDE 2
	# ========================================
	dialogue_trees["lab_interlude_2"] = {
		"start": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "The dots appeared first here. In this memory. This must be patient zero.",
			"next": "irons_notes"
		},
		"irons_notes": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Document everything. The Ministry needs this data.",
			"choices": []
		}
	}
	
	# ========================================
	# FRAGMENT 6: TRAIL & HOSPITAL
	# ========================================
	dialogue_trees["hospital"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You stand up and collect your thoughts for a moment.",
			"next": "who_we_met"
		},
		"who_we_met": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "Look who we met.",
			"next": "follow_him"
		},
		"follow_him": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "Do you want to follow him? He must be close. Better catch up.",
			"next": "chase"
		},
		"chase": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You barely run and start following him. After 20 minutes of barely passing out from shortness of breath, you catch up with him near a hospital called 'City No.12 Clinic.'",
			"next": "got_gut"
		},
		"got_gut": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "After all this you really have the gut to talk with him?",
			"next": "i_do"
		},
		"i_do": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "I do.",
			"next": "go_along"
		},
		"go_along": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "Go along then.",
			"next": "confrontation"
		},
		"confrontation": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The man pushes people out of his way to enter the hospital. He is really in a haste. You follow him and right after turning the corner, he confronts you with that cold stare.",
			"next": "fuck_you_need"
		},
		"fuck_you_need": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "The fuck you need?",
			"next": "silent"
		},
		"silent": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You stay silent.",
			"next": "after_funeral"
		},
		"after_funeral": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "After uncle's funeral you left Carol and me. And here you are, you drunk fuck.",
			"next": "dirt_broke"
		},
		"dirt_broke": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "Finally after being dirt broke, you remember me? If you're here to beg money, I don't have any.",
			"next": "carol_dead"
		},
		"carol_dead": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "Carol is dead a month ago from flu. And wife disappeared from that damn expedition and son's here lying sick.",
			"next": "worst_scenario"
		},
		"worst_scenario": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "You found me at the worst possible scenario, fucker.",
			"next": "try_apologize"
		},
		"try_apologize": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "Please try to apologize.",
			"next": "mess_up"
		},
		"mess_up": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "Try messing this up, shithead.",
			"next": "sorry"
		},
		"sorry": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "I just meant to say sorry.",
			"next": "sorry_response"
		},
		"sorry_response": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "Sorry? Sorry? You left us in dirt for your petty writing.",
			"next": "any_way_help"
		},
		"any_way_help": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "Is there any way to help you? Please, there must be one.",
			"next": "dont_need_help"
		},
		"dont_need_help": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "I don't need a drunk's help, just fucking go.",
			"next": "boy_appears"
		},
		"boy_appears": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "A young boy around age 10 comes from behind the man.",
			"next": "mr_hallinberg"
		},
		"mr_hallinberg": {
			"speaker": "THE BOY",
			"speaker_id": "boy",
			"text": "Dad, you brought me Mr. Hallinberg?",
			"next": "son_quiet"
		},
		"son_quiet": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "Son...",
			"next": "finish_book"
		},
		"finish_book": {
			"speaker": "THE BOY",
			"speaker_id": "boy",
			"text": "Mr., when will you finish the final entry of 'Mind Seekers'?",
			"next": "rough_draft"
		},
		"rough_draft": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "There's only a rough draft.",
			"next": "can_i_read"
		},
		"can_i_read": {
			"speaker": "THE BOY",
			"speaker_id": "boy",
			"text": "Please, can I read it?",
			"next": "pale_skin"
		},
		"pale_skin": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "Judging by the pale skin, horrible big green dots on his whole body... The boy will not live to see you finishing that damn book.",
			"next": "bring_now"
		},
		"bring_now": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "I will bring it now.",
			"next": "thank_you"
		},
		"thank_you": {
			"speaker": "THE BOY",
			"speaker_id": "boy",
			"text": "Thank you Mr.",
			"next": "sense_joy"
		},
		"sense_joy": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You sense the joy. Only if he was healthy, he would've been jumping right now from that enormous joy.",
			"next": "blood_transfusion"
		},
		"blood_transfusion": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "Son, you will have your blood transfusion now.",
			"next": "bring_tomorrow"
		},
		"bring_tomorrow": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "Bring it tomorrow.",
			"choices": []
		}
	}
	
	# ========================================
	# LAB INTERLUDE 3
	# ========================================
	dialogue_trees["lab_interlude_3"] = {
		"start": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "Mr. Irons... this memory. He was trying to save someone.",
			"next": "focus"
		},
		"focus": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Focus on the reconstruction, Michael. We're close to the end.",
			"choices": []
		}
	}
	
	# ========================================
	# FRAGMENT 7: THE DELIVERY & TRANSFORMATION
	# ========================================
	dialogue_trees["delivery"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You pick up the draft the next morning. You wonder if it would've become your best job if only it was finished.",
			"next": "how_long_waiting"
		},
		"how_long_waiting": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "How long has that boy been waiting for your mess, David?",
			"next": "dont_know"
		},
		"dont_know": {
			"speaker": "DAVID",
			"speaker_id": "david",
			"text": "I don't know.",
			"next": "two_years"
		},
		"two_years": {
			"speaker": "CREAKY VOICE",
			"speaker_id": "creaky_voice",
			"text": "2 years. Yes, you've been drinking yourself to the grave for the last 2 years.",
			"next": "hope_time"
		},
		"hope_time": {
			"speaker": "MANLY VOICE",
			"speaker_id": "manly_voice",
			"text": "Let's just hope the boy has enough time to enjoy it.",
			"next": "hospital_return"
		},
		"hospital_return": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You go to the hospital and enter the emergency room.",
			"next":"man_sits"
		},
		"man_sits": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The man sits beside his son and his son is lying on the bed motionless",
			"next":"transfusion_tired"
		},
		"transfusion_tired": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "Yesterday's transfusion tired him.",
			"next":"just_leave"
		},
		"just_leave": {
			"speaker": "THE FRIEND",
			"speaker_id": "friend",
			"text": "Just leave and go",
			"next":"boy_wakes"
		},
		"boy_wakes": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The boy wakes up and looks at you.",
			"next":"thank_you"
		},
		"thank_you": {
			"speaker": "THE BOY",
			"speaker_id": "boy",
			"text": "the boy gives very subtle, demising smile. The tears emerges from his little eyes and runs on his cheeks.",
			"next":"approaching_boy"
		},
		"approaching_boy": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "You are approaching boy to leave the drafts",
			"next":"suddenly_dots"
		},
		"suddenly_dots": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "Suddenly his dots turn into unholy, satanic white and the boy mumbles strange phrases that has out worldly rhythm to it.",
			"choices": []
			}
		}
	dialogue_trees["epilogue"] = {
		"start": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "It is the last one",
			"next": "continues_the"
		},
		"continues_the": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "continues the Mr. Glasses",
			"next": "the_man_who"
		},
		"the_man_who": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "You said it was the man who exploded.",
			"next": "just_assumed"
		},
		"just_assumed": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "I just assumed.",
			"next": "enough_symptoms"
		},
		"enough_symptoms": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "Do you think we have enough symptoms now?",
			"next": "ministry_of_thought"
		},
		"ministry_of_thought": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "Yeah, I will report back to the ministry of thought",
			"next": "did_well"
		},
		"did_well": {
			"speaker": "MR. IRONS",
			"speaker_id": "irons",
			"text": "You did well Michael",
			"next": "pleasure_to"
		},
		"pleasure_to": {
			"speaker": "MICHAEL",
			"speaker_id": "michael",
			"text": "Pleasure to serve",
			"choices": []
		}
	}
