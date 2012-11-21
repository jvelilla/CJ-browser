note
	description: "Summary description for {CJ_HTTP_RESPONSE_TOOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CJ_HTTP_RESPONSE_TOOL

inherit
	CJ_TOOL

create
	make

feature {NONE} -- Initialization

	create_interface_objects
		local
			t: like text
		do
			create t
			text := t
		end

feature -- Access

	title: STRING_32 = "HTTP Response"

feature -- Widget	

	widget: EV_WIDGET
		do
			Result := text
		end

	text: EV_TEXT


invariant
	widget_attached: widget /= Void

end
