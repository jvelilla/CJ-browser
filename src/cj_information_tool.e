note
	description: "Summary description for {CJ_INFORMATION_TOOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CJ_INFORMATION_TOOL

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

	title: STRING_32 = "Information"

feature -- Widget

	widget: EV_CELL

feature -- Change

	set_text_widget (t: EV_WIDGET)
		do
			widget.replace (t)
		end

invariant
	widget_attached: widget /= Void

end
