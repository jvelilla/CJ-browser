note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	CJ_CLIENT_WINDOW

inherit
	EV_TITLED_WINDOW
		redefine
			initialize,
			create_interface_objects
		end

feature {NONE} -- Initialization

	create_interface_objects
		local
			ft: EV_FONT
		do
			Precursor
			create field_url
			create ft
			ft.set_family ({EV_FONT_CONSTANTS}.Family_sans)
			ft.set_height (10)

			create text_formatted_body.make

			create text_http_response
			text_http_response.set_font (ft)

			create button_go.make_with_text ("Go")
			create cell_info

			create cj_client.make ("")
		end

	initialize
			-- Initialize `Current'.
		local
			vb: EV_VERTICAL_BOX
			hb: EV_HORIZONTAL_BOX
			lab: EV_LABEL
			nb: EV_NOTEBOOK
		do
			Precursor
			create vb
			extend (vb)
			vb.set_border_width (3)

			create hb
			hb.set_padding_width (5)
			hb.set_border_width (3)
			create lab.make_with_text ("Location")
			hb.extend (lab)
			hb.disable_item_expand (lab)
			hb.extend (field_url)
			hb.extend (button_go)
			hb.disable_item_expand (button_go)

			vb.extend (hb)
			vb.disable_item_expand (hb)

			create nb
			vb.extend (nb)
			nb.extend (cell_info)
			nb.extend (text_formatted_body)
			nb.extend (text_http_response)
			nb.item_tab (cell_info).set_text ("Information")
			nb.item_tab (text_formatted_body).set_text ("Formatted body")
			nb.item_tab (text_http_response).set_text ("HTTP response")

			set_title ("Collection-JSON explorer")
			set_size (600, 500)

			initialize_actions

			close_request_actions.extend (agent destroy_and_exit_if_last)
		end

	initialize_actions
		do
			button_go.select_actions.extend (agent on_go)
		end

feature -- Action

	on_go
		local
			l_url: STRING_32
		do
			l_url := field_url.text
			explore (l_url.to_string_8)
		end

feature -- Access

	cj_client: CJ_CLIENT

feature -- Explore

	set_field_url_from_location (s: READABLE_STRING_8)
		do
			field_url.set_text (s)
		end

	explore (a_url: READABLE_STRING_8)
		local
			t: CLICKABLE_TEXT
			i: INTEGER
			retried: BOOLEAN
		do
			if not retried then
				set_pointer_style (stock_pixmaps.Busy_cursor)

				create t.make
				t.set_foreground_color ("title", create {EV_COLOR}.make_with_8_bit_rgb (180, 0, 0))
				t.set_foreground_color ("link", create {EV_COLOR}.make_with_8_bit_rgb (0, 0, 255))

				t.append_custom ("title", "Location: " + a_url)
				t.append_new_line
				if
					attached cj_client.get (a_url, Void) as resp
				then
					text_http_response.set_text (resp.http_response)
					if attached resp.body as b then
						text_formatted_body.set_json (b)
					else
						text_formatted_body.wipe_out
					end
					if attached resp.collection as coll then
						t.enter_bold
						t.append_text ("  Version: ")
						t.exit_bold
						t.append_text (coll.version)
						t.append_new_line

						t.enter_bold
						t.append_text ("  Href: ")
						t.exit_bold

						if coll.href.is_empty then
							t.append_text ("no href")
						else
							t.append_link (Void, coll.href)
						end
						t.append_new_line
						if attached coll.links as l_links then
							t.append_custom ("title", "Collection Links")
							t.append_new_line
							i := 0
							across
								l_links as c
							loop
								i := i + 1
								append_link_line_to (i, c.item, t)
								t.append_new_line
							end
						end

						if attached coll.items as l_items then
							t.append_custom ("title", "Items")
							t.append_new_line
							i := 0
							across
								l_items as c
							loop
								i := i + 1
								append_item_line_to (i, c.item, t)
								t.append_text ("%N")
							end
						end
						if attached coll.queries as l_queries then
							t.append_custom ("title", "Queries")
							t.append_new_line
							i := 0
							across
								l_queries as c
							loop
								i := i + 1
								append_query_line_to (i, c.item, t)
								t.append_text ("%N")
							end

							t.append_custom ("title", "Queries (details)")
							t.append_new_line
							i := 0
							across
								l_queries as c
							loop
								i := i + 1
								append_query_to (i, c.item, t)
								t.append_text ("%N")
							end
						end

						if attached coll.template as tpl then
							t.append_custom ("title", "Template")
							t.append_new_line
							across
								tpl.data as d
							loop
								append_data_line_to (d.item, t)
							end
						end

						if attached coll.error as l_error then
							append_error_to (l_error, t)
							t.append_new_line
						end
					end
				end
				cell_info.replace (t)
				cell_info.set_focus

				t.link_activated_actions.extend (agent set_field_url_from_location)
				t.link_activated_actions.extend (agent explore)
			end

			set_pointer_style (stock_pixmaps.Standard_cursor)
		rescue
			retried := True
			retry
		end

	append_error_to (a_error: CJ_ERROR; t: CLICKABLE_TEXT)
		do
			t.enter_bold
			t.append_text ("ERROR[")
			t.exit_bold
			t.append_text (a_error.code)
			t.enter_bold
			t.append_text ("] ")
			t.append_text (a_error.title)
			t.exit_bold
			t.append_new_line
			t.enter_italic
			t.append_text (a_error.message)
			t.exit_italic
		end

	append_link_line_to (a_index: INTEGER; a_link: CJ_LINK; t: CLICKABLE_TEXT)
		local
			l_title: READABLE_STRING_32
		do
			if attached a_link.prompt as l_prompt then
				l_title := l_prompt
			elseif attached a_link.name as l_name then
				l_title := l_name
			else
				l_title := a_link.rel
			end

			t.enter_bold
			t.append_text (" - Link #" + a_index.out)
			t.exit_bold
			t.append_text (" ")
			t.append_link (l_title + {STRING_32} " ("+ a_link.href + {STRING_32} ")", a_link.href)
		end

	append_query_line_to (a_index: INTEGER; a_query: CJ_QUERY; t: CLICKABLE_TEXT)
		local
			l_title: READABLE_STRING_32
		do
			if attached a_query.prompt as l_prompt then
				l_title := l_prompt
			elseif attached a_query.name as l_name then
				l_title := l_name
			else
				l_title := a_query.rel
			end

			t.enter_bold
			t.append_text (" - Query #" + a_index.out)
			t.exit_bold
			t.append_text (" ")
			t.append_link (l_title + {STRING_32} " ("+ a_query.href + {STRING_32} ")", a_query.href)
		end

	append_query_to (a_index: INTEGER; a_query: CJ_QUERY; t: CLICKABLE_TEXT)
		do
			append_query_line_to (a_index, a_query, t)
			t.append_new_line
			if attached a_query.data as l_data then
				t.enter_bold
				t.append_text ("%TData")
				t.exit_bold
				t.append_new_line
				across
					l_data as d
				loop
					t.append_text ("%T - ")
					append_data_line_to (d.item, t)
					t.append_new_line
				end
			end
		end

	append_item_line_to (a_index: INTEGER; a_item: CJ_ITEM; t: CLICKABLE_TEXT)
		do
			t.append_link (" - Item #" + a_index.out + " " + a_item.href, a_item.href)
			if attached a_item.data as l_data then
				t.append_text ("%N%T")
				t.enter_bold
				t.append_text ("Data")
				t.exit_bold
				across
					l_data as d
				loop
					t.append_text ("%N%T%T")
					append_data_line_to (d.item, t)
				end
			end
		end

	append_data_line_to (a_data: CJ_DATA; t: CLICKABLE_TEXT)
		do
			t.enter_bold
			t.append_text (a_data.name)
			if attached a_data.prompt as l_prompt then
				t.append_text (" %"")
				t.append_text (l_prompt)
				t.append_text ("%"")
			end
			t.exit_bold
			if attached a_data.value as l_value then
				t.append_text ("=")
				t.enter_italic
				t.append_text (l_value)
				t.exit_italic
			end
		end

feature -- Widget

	cell_info: EV_CELL

	field_url: EV_TEXT_FIELD

	text_formatted_body: JSON_FORMATTED_TEXT
	text_http_response: EV_TEXT

	button_go: EV_BUTTON

	stock_pixmaps: EV_STOCK_PIXMAPS
		once
			create Result
		end

end
