note
	description: "Summary description for {CJ_CLIENT_RESPONSE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CJ_CLIENT_RESPONSE

create
	make

feature {NONE} -- Initialization

	make (a_href: like href; h: like http_response; b: like body; cj: like collection)
		do
			href := a_href
			http_response := h
			body := b
			collection := cj
		end

feature -- Access

	href: STRING_8

	http_response: READABLE_STRING_8

	body: detachable JSON_VALUE

	formatted_body: detachable STRING_32
		local
			vis: JSON_PRETTY_STRING_VISITOR
		do
			if attached body as j then
				create Result.make_empty
				create vis.make (Result)
				j.accept (vis)
			end
		end

	collection: detachable CJ_COLLECTION

end
