note
	description: "Summary description for {CJ_QUERIES_TOOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CJ_QUERIES_TOOL

inherit
	CJ_TOOL

create
	make

feature {NONE} -- Initialization

	create_interface_objects
		local
			w: like widget
		do
			create w
			widget := w
			create on_query_actions
		end

feature -- Access

	title: STRING_32 = "Queries"

	on_query_actions: ACTION_SEQUENCE [TUPLE [CJ_QUERY]]

feature -- Widget	

	widget: EV_CELL

feature -- Change

	clear
		do
			widget.wipe_out
		end

	set_queries (coll: CJ_COLLECTION; lst: ITERABLE [CJ_QUERY])
		local
			main,v: EV_VERTICAL_BOX
			hb: EV_HORIZONTAL_BOX
			lab: EV_LABEL
			tf: EV_TEXT_FIELD
			but: EV_BUTTON
			table: HASH_TABLE [EV_TEXT_FIELD, STRING_32]
			f: EV_FRAME
			q: CJ_QUERY
			l_title: STRING_32
		do
			create main
			main.set_border_width (3)
			main.set_padding_width (5)
			across
				lst as c
			loop
				q := c.item
				if attached q.prompt as l_prompt then
					l_title := l_prompt
				elseif attached q.name as l_name then
					l_title := l_name
				else
					l_title := q.rel
				end
				create f.make_with_text (l_title)
				create v
				v.set_border_width (3)
				v.set_padding_width (5)
				f.extend (v)
				if attached q.data as l_data then
					create table.make (l_data.count)
					across
						l_data as d
					loop
						create hb
						hb.set_padding_width (3)
						create lab.make_with_text (d.item.name)
						if attached d.item.prompt as p then
							lab.set_text (p)
						end
						create tf
						hb.extend (lab)
						hb.disable_item_expand (lab)
						hb.extend (tf)
						v.extend (hb)
						v.disable_item_expand (hb)
						table.force (tf, d.item.name)
					end
				else
					create table.make (0)
				end
				create but.make_with_text ("Query")
				but.select_actions.extend (agent on_query (coll, q, table))
				v.extend (but)
				v.disable_item_expand (but)
				main.extend (f)
				main.disable_item_expand (f)
			end
			widget.replace (main)
		end

	on_query (coll: CJ_COLLECTION; q: CJ_QUERY; table: HASH_TABLE [EV_TEXT_FIELD, STRING_32])
		local
			ctx: HTTP_CLIENT_REQUEST_CONTEXT
			dlg: EV_INFORMATION_DIALOG
			resp: CJ_CLIENT_RESPONSE
		do
			create ctx.make
			if attached q.data as l_data then
				across
					l_data as c
				loop
					if attached table.item (c.item.name) as tf then
						c.item.set_value (tf.text)
					end
				end
			end
			on_query_actions.call ([q])
		end

invariant
	widget_attached: widget /= Void

end
