note
	description: "Summary description for {JSON_FORMATTED_TEXT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_FORMATTED_TEXT

inherit
	CLICKABLE_TEXT
		redefine
			make
		end

	JSON_VISITOR

create
	make

convert
	widget: {EV_WIDGET}

feature {NONE} -- Initialization

	make
		local
			ft: EV_FONT
		do
			Precursor
			initialize_visitor
			set_foreground_color ("name", create {EV_COLOR}.make_with_8_bit_rgb (0, 0, 255))
			create ft
			ft.set_weight ({EV_FONT_CONSTANTS}.Weight_bold)
			set_font ("name", ft)

			set_foreground_color ("string", create {EV_COLOR}.make_with_8_bit_rgb (0, 0, 0))
			create ft
			ft.set_shape ({EV_FONT_CONSTANTS}.Shape_italic)
			set_font ("string", ft)
		end

feature -- Change

	set_json (j: detachable JSON_VALUE)
		do
			wipe_out
			json := j
			if j /= Void then
				widget.set_text ("Click to get formatted body ...")
				widget.focus_in_actions.extend_kamikaze (agent set_text_from_json)
			end
		end

	json: detachable JSON_VALUE

	set_text_from_json
		local
			win: like parent_window_of
			p: detachable like {EV_WINDOW}.pointer_style
		do
			wipe_out
			if attached json as j then
				win := parent_window_of (widget)
				if win /= Void then
					p := win.pointer_style
					win.set_pointer_style (stock_pixmaps.busy_cursor)
				end
				j.accept (Current)
				if win /= Void then
					if p = Void then
						p := stock_pixmaps.standard_cursor
					end
					win.set_pointer_style (p)
				end
			end
		end

	stock_pixmaps: EV_STOCK_PIXMAPS
		once
			create Result
		end

feature	-- Json

	initialize_visitor
			-- Create a new instance
		do
			create indentation.make_empty
			indentation_step := "  "

			object_count_inlining := 3
			array_count_inlining := 1
		end

feature -- Access

	indentation: STRING_32

	indentation_step: like indentation

	line_number: INTEGER

	indent
		do
			indentation.append (indentation_step)
		end

	exdent
		do
			indentation.remove_tail (indentation_step.count)
		end

	new_line
		do
			append_new_line
			append_text (indentation)
			line_number := line_number + 1
		end

	object_count_inlining: INTEGER
	array_count_inlining: INTEGER

feature -- Visitor Pattern

	visit_json_array (a_json_array: JSON_ARRAY)
			-- Visit `a_json_array'.
		local
			value: JSON_VALUE
			l_json_array: ARRAYED_LIST [JSON_VALUE]
			l_line: like line_number
			l_multiple_lines: BOOLEAN
		do
			l_json_array := a_json_array.array_representation
			l_multiple_lines := l_json_array.count >= array_count_inlining or across l_json_array as p some attached {JSON_OBJECT} p.item or attached {JSON_ARRAY} p.item end
			append_text ("[")
			l_line := line_number
			indent
			from
				l_json_array.start
			until
				l_json_array.off
			loop
				if
					line_number > l_line or
					l_multiple_lines
				then
					new_line
				end
				value := l_json_array.item
				value.accept (Current)
				l_json_array.forth
				if not l_json_array.after then
					append_text (", ")
				end
			end
			exdent
			if
				line_number > l_line or
				l_json_array.count >= array_count_inlining
			then
				new_line
			end
			append_text ("]")
		end

	visit_json_boolean (a_json_boolean: JSON_BOOLEAN)
			-- Visit `a_json_boolean'.
		do
			append_text (a_json_boolean.item.out)
		end

	visit_json_null (a_json_null: JSON_NULL)
			-- Visit `a_json_null'.
		do
			append_text ("null")
		end

	visit_json_number (a_json_number: JSON_NUMBER)
			-- Visit `a_json_number'.
		do
			append_text (a_json_number.item)
		end

	visit_json_object (a_json_object: JSON_OBJECT)
			-- Visit `a_json_object'.
		local
			l_pairs: HASH_TABLE [JSON_VALUE, JSON_STRING]
			l_line: like line_number
			l_multiple_lines: BOOLEAN
		do
			l_pairs := a_json_object.map_representation
			l_multiple_lines := l_pairs.count >= object_count_inlining or across l_pairs as p some attached {JSON_OBJECT} p.item or attached {JSON_ARRAY} p.item end
			append_text ("{")
			l_line := line_number
			indent
			from
				l_pairs.start
			until
				l_pairs.off
			loop
				if
					line_number > l_line or
					l_multiple_lines
				then
					new_line
				end
				append_text ("%"")
				append_custom ("name", l_pairs.key_for_iteration.item)
				append_text ("%"")
--				l_pairs.key_for_iteration.accept (Current)
				append_text (": ")
				l_pairs.item_for_iteration.accept (Current)
				l_pairs.forth
				if not l_pairs.after then
					append_text (", ")
				end
			end
			exdent
			if
				line_number > l_line or
				l_pairs.count >= object_count_inlining
			then
				new_line
			end
			append_text ("}")
		end

    visit_json_string (a_json_string: JSON_STRING)
			-- Visit `a_json_string'.
		do
			append_text ("%"")
			append_custom ("string", a_json_string.item)
			append_text ("%"")
		end

end
