note
	description: "Summary description for {CJ_CLIENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CJ_CLIENT

create
	make

feature {NONE} -- Initialization

	make (a_service: READABLE_STRING_8)
			-- Initialize `Current'.
		do
			create {LIBCURL_HTTP_CLIENT_SESSION} client.make (a_service) --"http://jfiat.dyndns.org:8190")
		end

feature -- Access		

	client: HTTP_CLIENT_SESSION

	get (a_path: READABLE_STRING_8; ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT): CJ_CLIENT_RESPONSE
		local
			l_http_response: STRING_8
			j_body: like json
			l_formatted_body: detachable STRING_8
			col: detachable CJ_COLLECTION
		do
			create l_http_response.make_empty
			if attached client.get (a_path, ctx) as g_response then
				l_http_response.append ("Status: " + g_response.status.out + "%N")
				l_http_response.append (g_response.raw_header)
				if attached g_response.body as l_body then
					l_http_response.append ("%N%N")
					l_http_response.append (l_body)
					if attached json (l_body) as j then
						j_body := j
						col := cj_collection (j)
					end
				else
					l_formatted_body := Void
				end
			end
			create Result.make (l_http_response, j_body, col)
		end

feature {NONE} -- Implementation

	shared_ejson: SHARED_EJSON
		once
			create Result
		end

	initialize_json_converters
		once
			if attached shared_ejson.json as j then
				j.add_converter (create {CJ_COLLECTION_JSON_CONVERTER}.make)
				j.add_converter (create {CJ_DATA_JSON_CONVERTER}.make)
				j.add_converter (create {CJ_ERROR_JSON_CONVERTER}.make)
				j.add_converter (create {CJ_ITEM_JSON_CONVERTER}.make)
				j.add_converter (create {CJ_QUERY_JSON_CONVERTER}.make)
				j.add_converter (create {CJ_TEMPLATE_JSON_CONVERTER}.make)
				j.add_converter (create {CJ_LINK_JSON_CONVERTER}.make)
				if j.converter_for (create {ARRAYED_LIST [detachable ANY]}.make (0)) = Void then
					j.add_converter (create {CJ_ARRAYED_LIST_JSON_CONVERTER}.make)
				end
			end
		end

feature -- Access		

	cj_collection (j: JSON_VALUE): detachable CJ_COLLECTION
		local
			conv: CJ_COLLECTION_JSON_CONVERTER
		do
			if attached {JSON_OBJECT} j as jo then
				initialize_json_converters
				create conv.make
				Result := conv.from_json (jo)
			end
		end

	json (s: READABLE_STRING_8): detachable JSON_VALUE
		local
			p: JSON_PARSER
		do
			create p.make_parser (s)
			if
				attached p.parse as v and then
				p.is_parsed
			then
				Result := v
			end
		end

end
