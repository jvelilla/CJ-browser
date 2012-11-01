note
	description: "Summary description for {CLICKABLE_TEXT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CLICKABLE_TEXT

create
	make

convert
	widget: {EV_WIDGET}

feature {NONE} -- Initialization

	make
		do
			create widget
			create links.make (0)
			create previous_properties.make (2)
			create properties.make (3)

			create link_activated_actions

			initialize
			widget.set_font (default_font)
			widget.set_foreground_color (default_foreground_color)
			widget.set_background_color (default_background_color)
			wipe_out

			widget.pointer_double_press_actions.extend (agent on_double_click)
		end

	initialize
		do
			set_foreground_color ("default", create {EV_COLOR}.make_with_8_bit_rgb (0, 0, 0))
			set_background_color ("default", create {EV_COLOR}.make_with_8_bit_rgb (255, 255, 255))
			set_font ("default", create {EV_FONT})

			set_foreground_color ("link", create {EV_COLOR}.make_with_8_bit_rgb (0, 0, 255))
		end

feature -- Widget

	widget: EV_RICH_TEXT

feature {NONE} -- Internals

	links: ARRAYED_LIST [TUPLE [left,right: INTEGER; title: detachable READABLE_STRING_GENERAL; location: READABLE_STRING_8]]

	link (pos: like widget.caret_position): detachable like links.item
		do
			across
				links as c
			until
				Result /= Void
			loop
				if c.item.left <= pos and pos <= c.item.right then
					Result := c.item
				end
			end
		end

feature -- Event

	on_double_click (x: INTEGER; y: INTEGER; button: INTEGER; x_tilt: DOUBLE; y_tilt: DOUBLE; pressure: DOUBLE; screen_x: INTEGER; screen_y: INTEGER)
		local
			pos: like widget.caret_position
		do
			if button = {EV_POINTER_CONSTANTS}.left then
				pos := widget.caret_position
				if attached link (pos) as l_link then
					on_link_double_clicked (l_link)
				end
			end
		end

	on_link_double_clicked (a_link: attached like link)
		do
			link_activated_actions.call ([a_link.location])
		end

feature -- Actions

	link_activated_actions: ACTION_SEQUENCE [TUPLE [location: READABLE_STRING_8]]

feature -- Basic operation

	wipe_out
		do
			widget.remove_text
			links.wipe_out
			previous_properties.wipe_out
			widget.set_caret_position (1)
			widget.set_current_format (default_format)
		end

	append_text (t: READABLE_STRING_GENERAL)
		do
			widget.append_text (t)
			widget.set_caret_position (widget.caret_position + t.count)
		end

feature -- Style

	enter_bold
		do
			apply_bold_properties
		end

	exit_bold
		require
			previous_properties_is_named ("bold")
		do
			revert_properties
		end

	enter_italic
		do
			apply_italic_properties
		end

	exit_italic
		require
			previous_properties_is_named ("italic")
		do
			revert_properties
		end

feature -- Access		

	append_new_line
		do
			append_text ("%N")
		end

	append_custom (a_style: STRING; t: READABLE_STRING_GENERAL)
		do
			apply_custom_properties (a_style)
			append_text (t)
			revert_properties
		end

	append_link (t: detachable READABLE_STRING_GENERAL; a_url: READABLE_STRING_8)
		local
			l_left, l_right: INTEGER
		do
			apply_link_properties
			l_left := widget.caret_position
			if t /= Void then
				append_text (t)
			else
				append_text (a_url)
			end
			revert_properties
			l_right := widget.caret_position
			links.extend ([l_left, l_right, t, a_url])
		end

feature {NONE} -- Properties

	current_format: EV_CHARACTER_FORMAT
		do
			if has_previous_properties then
				Result := widget.character_format (widget.caret_position)
			else
				Result := default_format
			end
		end

	new_format_from_current: like current_format
		do
			Result := new_format (current_format)
		end

	new_format (f: EV_CHARACTER_FORMAT): like current_format
		do
			create Result.make_with_font_and_color (f.font.twin, f.color.twin, f.background_color.twin)
		end

	previous_properties: ARRAYED_STACK [TUPLE [name: READABLE_STRING_GENERAL; format: EV_CHARACTER_FORMAT]]

	apply_bold_properties
		local
			f: like new_format
		do
			f := new_format_from_current

			f.font.set_weight ({EV_FONT_CONSTANTS}.Weight_bold)

			record_properties ("bold")
			widget.set_current_format (f)
		end

	apply_italic_properties
		local
			f: like current_format
		do
			f := new_format_from_current
			f.font.set_shape ({EV_FONT_CONSTANTS}.Shape_italic)

			record_properties ("italic")
			widget.set_current_format (f)
		end

	apply_custom_properties (a_style: STRING)
		local
			f: like current_format
		do
			f := new_format_from_current
			if attached foreground_color (a_style) as fg then
				f.set_color (fg)
			end
			if attached background_color (a_style) as bg then
				f.set_background_color (bg)
			end
			if attached font (a_style) as ft then
				f.set_font (ft)
			end
			record_properties (a_style)
			widget.set_current_format (f)
		end

	apply_link_properties
		do
			apply_custom_properties ("link")
		end

	record_properties (a_name: READABLE_STRING_GENERAL)
		do
			previous_properties.extend ([a_name, widget.character_format (widget.caret_position)])
		end

	revert_properties
		require
			has_previous_properties: has_previous_properties
		do
			if attached previous_properties.item as prop then
				widget.set_current_format (prop.format)
				previous_properties.remove
			else
				check has_previous_properties: False end
			end
		end

feature -- Properties status		

	has_previous_properties: BOOLEAN
		do
			Result := not previous_properties.is_empty
		end

	previous_properties_is_named (a_name: READABLE_STRING_GENERAL): BOOLEAN
		require
			has_previous_properties: has_previous_properties
		do
			if attached previous_properties.item as p then
				Result := a_name.is_case_insensitive_equal (p.name)
			end
		end

feature -- Default

	default_format: EV_CHARACTER_FORMAT
		once
			create Result.make_with_font_and_color (default_font, default_foreground_color, default_background_color)
		end

	default_font: EV_FONT
		do
			if attached font ("default") as ft then
				Result := ft
			else
				create Result
				set_font ("default", Result)
			end
		end

	default_foreground_color: EV_COLOR
		do
			if attached foreground_color ("default") as c then
				Result := c
			else
				create Result.make_with_8_bit_rgb (0, 0, 0)
				set_foreground_color ("default", Result)
			end
		end

	default_background_color: EV_COLOR
		do
			if attached background_color ("default") as c then
				Result := c
			else
				create Result.make_with_8_bit_rgb (255, 255, 255)
				set_background_color ("default", Result)
			end
		end

feature -- Properties

	set_font (a_name: STRING; ft: like font)
		do
			properties.force ([foreground_color (a_name), background_color (a_name), ft], a_name)
		end

	set_foreground_color (a_name: STRING; c: like foreground_color)
		do
			properties.force ([c, background_color (a_name), font (a_name)], a_name)
		end

	set_background_color (a_name: STRING; c: like background_color)
		do
			properties.force ([foreground_color (a_name), c, font (a_name)], a_name)
		end

	foreground_color (a_name: STRING): detachable EV_COLOR
		do
			if attached properties.item (a_name) as v then
				Result := v.foreground_color
			end
		end

	background_color (a_name: like properties.key_for_iteration): detachable EV_COLOR
		do
			if attached properties.item (a_name) as v then
				Result := v.background_color
			end
		end

	font (a_name: like properties.key_for_iteration): detachable EV_FONT
		do
			if attached properties.item (a_name) as v then
				Result := v.font
			end
		end

feature {NONE} -- Implementation

	properties: HASH_TABLE [TUPLE [foreground_color, background_color: detachable EV_COLOR; font: detachable EV_FONT], STRING]

invariant
	properties_attached: properties /= Void

end
