note
	description: "Summary description for {CJ_FORMATTED_BODY_TOOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CJ_FORMATTED_BODY_TOOL

inherit
	CJ_TOOL

create
	make

feature {NONE} -- Initialization

	create_interface_objects
		local
			t: like text
		do
			create t.make
			text := t
		end

feature -- Access

	title: STRING_32 = "Formatted body"

feature -- Widget	

	widget: EV_WIDGET
		do
			Result := text.widget
		end

	text: JSON_FORMATTED_TEXT

invariant
	widget_attached: widget /= Void

end
