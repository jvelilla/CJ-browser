note
	description: "Summary description for {CJ_TEMPLATE_TOOL}."
	date: "$Date$"
	revision: "$Revision$"

class
	CJ_TEMPLATE_TOOL

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
			create v
		end

feature -- Access

	title: STRING_32 = "Template"

feature -- Widget	

	widget: EV_CELL

feature -- Primitives

	list:  detachable EV_CHECKABLE_LIST

	v: EV_VERTICAL_BOX

feature -- Change

	clear
		do
			widget.wipe_out
		end

	set_template (coll: CJ_COLLECTION; tpl: CJ_TEMPLATE)
		local
			hb: EV_HORIZONTAL_BOX
			lab, lab1: EV_LABEL
--			tf: EV_TEXT_FIELD
			tf: EV_TEXT
			tf_passwd: EV_PASSWORD_FIELD
			but: EV_BUTTON
			but_delete: detachable EV_BUTTON
			but_add_file: EV_BUTTON
			table: HASH_TABLE [EV_TEXT_COMPONENT, STRING_32]
			is_creation: BOOLEAN
			is_password: BOOLEAN
			l_file_dialog: EV_FILE_OPEN_DIALOG
			l_list: like list
			l_item: EV_LIST_ITEM
		do
			create v
			list := Void
			v.set_border_width (3)
			v.set_padding_width (5)
			create table.make (tpl.data.count)
			is_creation := True
			across
				tpl.data as d
			loop
				create lab.make_with_text (d.item.name)
				if attached d.item.files as l_files then
					l_list := list
					if l_list = Void then
						create l_list
						list := l_list
						l_list.enable_multiple_selection
						create hb
						hb.set_padding_width (6)
						hb.extend (l_list)
						v.extend (hb)
						v.disable_item_expand (hb)
					end
					from
						l_files.start
					until
						l_files.after
					loop
						create l_item.make_with_text (l_files.key_for_iteration)
						l_item.set_tooltip (l_files.key_for_iteration)
						l_list.force (l_item)
						l_list.check_item (l_item)
						l_files.forth
					end
					create hb
					hb.set_padding_width (6)
					create but_add_file.make_with_text ("Add File")
					but_add_file.select_actions.extend (agent on_add_file (coll, tpl, table))
					hb.extend (but_add_file)
					hb.disable_item_expand (but_add_file)
					v.extend (hb)
					v.disable_item_expand (hb)
				else
					if attached d.item.prompt as p then
						lab.set_text (p)
						if p.is_case_insensitive_equal ("Password") then
							is_password := True
						else
							is_password := False
						end
					end
					create hb
					hb.set_padding_width (3)
					if is_password then
						create tf_passwd
						if attached d.item.value as l_val then
							if not l_val.is_empty then
									is_creation := False
							end
							tf_passwd.set_text (l_val)
						else
							tf_passwd.remove_text
						end
						hb.extend (lab)
						hb.disable_item_expand (lab)
						hb.extend (tf_passwd)
						v.extend (hb)
						v.disable_item_expand (hb)
						table.force (tf_passwd, d.item.name)
	                else
						create tf
						if attached d.item.value as l_val then
							if not l_val.is_empty then
								is_creation := False
							end
							tf.set_text (l_val)
						else
							tf.remove_text
						end
						hb.extend (lab)
						hb.disable_item_expand (lab)
						hb.extend (tf)
						v.extend (hb)
						v.disable_item_expand (hb)
						table.force (tf, d.item.name)
					end
				end
			end
			widget.replace (v)
			if is_creation then
				create but.make_with_text ("Create")
				but.select_actions.extend (agent on_post (coll, tpl, table, True))
			else
				create but.make_with_text ("Update")
				but.select_actions.extend (agent on_post (coll, tpl, table, False))
				create but_delete.make_with_text ("Delete")
				but_delete.select_actions.extend (agent on_delete (coll, tpl, table))

			end

			v.extend (create {EV_CELL})
			v.extend (but)
			if but_delete /= Void then
				v.extend (but_delete)
				v.disable_item_expand (but_delete)

			end
			v.disable_item_expand (but)
			-- FIXME
		end

	on_post (coll: CJ_COLLECTION; tpl: CJ_TEMPLATE; table: HASH_TABLE [EV_TEXT_COMPONENT, STRING_32]; is_creation: BOOLEAN)
		local
			ctx: HTTP_CLIENT_REQUEST_CONTEXT
			l_href: STRING_8
			dlg: EV_INFORMATION_DIALOG
			resp: CJ_CLIENT_RESPONSE
		do
			create ctx.make
			across
				tpl.data as c
			loop
				if attached table.item (c.item.name) as tf then
					c.item.set_value (tf.text)
				end
				if attached c.item.files as l_files then
					c.item.initilize_attachment
					if attached list as l_list and then not l_list.checked_items.is_empty then
						across l_list.checked_items as lc loop
							c.item.add_attachment (lc.item.tooltip, file_content (lc.item.text))
						end
					end
				end
			end
--			across table as t loop ctx.add_form_parameter (t.key, t.item.text) end
			if not is_creation and then attached coll.items as l_items and then attached l_items.first as first_item then
				l_href := first_item.href
				resp := cj_client.update_with_template (l_href, tpl, Void)
			else
				l_href := coll.href
				resp := cj_client.create_with_template (l_href, tpl, Void)
			end
			create dlg.make_with_text ("Result")
			list := Void
			dlg.set_text (resp.http_response)
			dlg.show
--			dlg.focus_out_actions.extend (agent dlg.destroy_and_exit_if_last)
		end

	on_delete (coll: CJ_COLLECTION; tpl: CJ_TEMPLATE; table: HASH_TABLE [EV_TEXT_COMPONENT, STRING_32])
		local
			ctx: HTTP_CLIENT_REQUEST_CONTEXT
			l_href: STRING_8
			dlg: EV_INFORMATION_DIALOG
			resp: CJ_CLIENT_RESPONSE
		do
			create ctx.make
			across
				tpl.data as c
			loop
				if attached table.item (c.item.name) as tf then
					c.item.set_value (tf.text)
				end
			end
			if attached coll.items as l_items and then not l_items.is_empty and then attached l_items.first as first_item then
				l_href := first_item.href
				resp := cj_client.delete(l_href, Void )
			else
				l_href := coll.href
				resp := cj_client.delete (l_href, Void)
			end
			create dlg.make_with_text ("Result")
			dlg.set_text (resp.http_response)
			dlg.show
		end

	on_add_file (coll: CJ_COLLECTION; tpl: CJ_TEMPLATE; table: HASH_TABLE [EV_TEXT_COMPONENT, STRING_32])
		local
			l_href: STRING_8
			l_dlg: EV_FILE_OPEN_DIALOG
			l_selected_file: STRING
			l_name: STRING
			l_content: STRING
			l_list:  like list
			l_item: EV_LIST_ITEM
			hb: EV_HORIZONTAL_BOX
		do
			create l_dlg.make_with_title ("Add File")
			l_dlg.show_modal_to_window (create {EV_WINDOW}.default_create)
			l_selected_file := l_dlg.file_name
			l_name := l_dlg.file_title
			l_list := list
			if l_list /= Void then
				create l_item.make_with_text (l_selected_file)
				l_item.set_tooltip (l_name)
				l_list.force (l_item)
				l_list.check_item (l_item)
			end

		end

	file_content (a_fn: STRING): STRING
			-- Return the content of the uploaded file `a_fn '
		local
			f: RAW_FILE
			s: STRING
			done: BOOLEAN
			retried: BOOLEAN
		do
			create Result.make_empty
			if not retried then
				create f.make_with_name (a_fn)
				if f.exists then
					f.open_read
					from
					until
						done
					loop
						f.read_stream_thread_aware (1_024)
						s := f.last_string
						if s.is_empty then
							done := True
						else
							Result.append (s)
							done := f.exhausted or f.end_of_file
						end
					end
					f.close
				end
			end
		rescue
			retried := True
			retry
		end

invariant
	widget_attached: widget /= Void

end
