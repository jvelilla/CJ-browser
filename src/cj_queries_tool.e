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
			table: HASH_TABLE [EV_ANY, STRING_32]
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
						if attached d.item.acceptable_map as l_map then

							create lab.make_with_text (d.item.name)
							if attached d.item.prompt as p then
								lab.set_text (p)
							end

								-- Multivalue
							if attached d.item.array as l_array then
								set_template_acceptable_map_multi (l_map, lab, v, table, l_array)
								d.item.reset_array
							elseif attached d.item.value as l_value then
								set_template_acceptable_map (l_map, lab, v, table, l_value)
							end

						elseif attached d.item.acceptable_list as l_list then
							create lab.make_with_text (d.item.name)
							if attached d.item.prompt as p then
								lab.set_text (p)
							end
							if attached d.item.value as l_value then
								set_template_acceptable_list (l_list, lab, v, table, l_value)
							end


						else
							create hb
							hb.set_padding_width (3)
							create lab.make_with_text (d.item.name)
							if attached d.item.prompt as p then
								lab.set_text (p)
							end
							create tf
							if attached d.item.value as l then
								tf.set_text (l)
							end
							hb.extend (lab)
							hb.disable_item_expand (lab)
							hb.extend (tf)
							v.extend (hb)
							v.disable_item_expand (hb)
							table.force (tf, d.item.name)
						end
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

	on_query (coll: CJ_COLLECTION; q: CJ_QUERY; table: HASH_TABLE [EV_ANY, STRING_32])
		local
			ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
			create ctx.make
			if attached q.data as l_data then
				across
					l_data as c
				loop
					if
						attached {EV_CHECKABLE_LIST} table.item (c.item.name) as cl and then
						not cl.checked_items.is_empty
					then
						across cl.checked_items as lic loop
							if attached {STRING_8} lic.item.data as l_item_data then
								c.item.add_element_to_array (l_item_data)
							end
						end
					elseif attached {EV_COMBO_BOX} table.item (c.item.name) as cb
					then
							if  attached {EV_LIST_ITEM} cb.first as l_item and then
					   			 attached {STRING_8} l_item.data as l_value
							then
								c.item.set_value (l_value)
							end
					elseif attached {EV_TEXT_FIELD} table.item (c.item.name) as tf then
						c.item.set_value (tf.text)
					end
				end
			end
			on_query_actions.call ([q])
		end


feature -- Implementation

	set_template_acceptable_map (a_map: STRING_TABLE[READABLE_STRING_32]; a_lab: EV_LABEL; v: EV_VERTICAL_BOX; a_table: HASH_TABLE [EV_ANY, STRING_32]; a_value: READABLE_STRING_32)
		local
			l_acceptable_list: EV_COMBO_BOX
			hb: EV_HORIZONTAL_BOX
			l_item: EV_LIST_ITEM
		do
			create l_acceptable_list
			create hb
			hb.extend (a_lab)
			hb.disable_item_expand (a_lab)
			hb.set_padding_width (3)
			hb.extend (l_acceptable_list)
			v.extend (hb)
			v.disable_item_expand (hb)
			a_table.force (l_acceptable_list, a_lab.text)

			from
				a_map.start
			until
				a_map.after
			loop
				create l_item.make_with_text (a_map.item_for_iteration)
				l_item.set_tooltip (a_map.item_for_iteration)
				l_item.set_data (a_map.key_for_iteration)
				if
					a_value.is_case_insensitive_equal_general (a_map.item_for_iteration) or else
				   	a_value.is_case_insensitive_equal_general (a_map.key_for_iteration)
				then
					l_acceptable_list.set_text (a_map.item_for_iteration)
					l_acceptable_list.put_front(l_item)
				else
					l_acceptable_list.force (l_item)
				end
				a_map.forth
			end
		end


	set_template_acceptable_list (a_list: LIST[READABLE_STRING_32]; a_lab: EV_LABEL; v: EV_VERTICAL_BOX; a_table: HASH_TABLE [EV_ANY, STRING_32]; a_value: READABLE_STRING_32)
		local
			l_acceptable_list: EV_COMBO_BOX
			hb: EV_HORIZONTAL_BOX
			l_item: EV_LIST_ITEM
		do
			create l_acceptable_list
			create hb
			hb.extend (a_lab)
			hb.disable_item_expand (a_lab)
			hb.set_padding_width (3)
			hb.extend (l_acceptable_list)
			v.extend (hb)
			v.disable_item_expand (hb)
			a_table.force (l_acceptable_list, a_lab.text)

			a_list.compare_objects
			from
				a_list.start
			until
				a_list.after
			loop
				create l_item.make_with_text (a_list.item_for_iteration)
				l_item.set_tooltip (a_list.item_for_iteration)
				l_item.set_data (a_list.item_for_iteration)
				if a_value.is_case_insensitive_equal_general (a_list.item_for_iteration)  then
					l_acceptable_list.set_text (a_list.item_for_iteration)
					l_acceptable_list.put_front(l_item)
				else
					l_acceptable_list.force (l_item)
				end
				a_list.forth
			end
		end

	set_template_acceptable_map_multi (a_map: STRING_TABLE[READABLE_STRING_32]; a_lab: EV_LABEL; v: EV_VERTICAL_BOX; a_table: HASH_TABLE [EV_ANY, STRING_32]; a_array: LIST[READABLE_STRING_32])
		local
			l_acceptable_list: EV_CHECKABLE_LIST
			hb: EV_HORIZONTAL_BOX
			l_item: EV_LIST_ITEM
		do
			create l_acceptable_list
			create hb
			hb.extend (a_lab)
			hb.disable_item_expand (a_lab)
			hb.set_padding_width (6)
			hb.extend (l_acceptable_list)
			v.extend (hb)
			v.disable_item_expand (hb)
			a_table.force (l_acceptable_list, a_lab.text)
			a_array.compare_objects

			from
				a_map.start
			until
				a_map.after
			loop
				create l_item.make_with_text (a_map.item_for_iteration)
				l_item.set_tooltip (a_map.item_for_iteration)
				l_item.set_data (a_map.key_for_iteration)
				l_acceptable_list.force (l_item)
				if a_array.has (a_map.item_for_iteration) then
					l_acceptable_list.check_item (l_item)
				end
				a_map.forth
			end
		end


invariant
	widget_attached: widget /= Void

end
