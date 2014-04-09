note
	description: "Summary description for {CJ_TEMPLATE_TOOL}."
	author: ""
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
		end

feature -- Access

	title: STRING_32 = "Template"

feature -- Widget	

	widget: EV_CELL

feature -- Change

	clear
		do
			widget.wipe_out
		end

	set_template (coll: CJ_COLLECTION; tpl: CJ_TEMPLATE)
		local
			v: EV_VERTICAL_BOX
			hb: EV_HORIZONTAL_BOX
			lab: EV_LABEL
--			tf: EV_TEXT_FIELD
			tf: EV_TEXT
			tf_passwd: EV_PASSWORD_FIELD
			but: EV_BUTTON
			but_delete: detachable EV_BUTTON
			table: HASH_TABLE [EV_TEXT_COMPONENT, STRING_32]
			is_creation: BOOLEAN
			is_password: BOOLEAN
		do
			create v
			v.set_border_width (3)
			v.set_padding_width (5)
			create table.make (tpl.data.count)
			is_creation := True
			across
				tpl.data as d
			loop
				create lab.make_with_text (d.item.name)
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
			if attached coll.items as l_items and then attached l_items.first as first_item then
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

invariant
	widget_attached: widget /= Void

end
