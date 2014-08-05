note
	description: "HAL application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit

	SHARED_EJSON

create
	make

feature -- Initialization

	make
		do
			initialize_converters
			print ("test data%N")
			test_data
			print ("%Ntest error%N")
			test_error
			print ("%Ntest link%N")
			test_link
			print ("%Ntest template%N")
			test_template
			print ("%Ntest item%N")
			test_item
			print ("%Ntest queries%N")
			test_queries
			print ("%Ntest collection%N")
			test_collection
			print ("%Ntest files attachments%N")
			test_attachment
			print ("%Ntest acceptable url%N")
			test_acceptable_url
			print ("%Ntest acceptable list%N")
			test_acceptable_list
			print ("%Ntest acceptable map%N")
			test_acceptable_map
			print ("%Ntest value type array map%N")
			test_value_type_array
		end

	initialize_converters
			-- Initialize json converters
		do
			json.add_converter (create {CJ_COLLECTION_JSON_CONVERTER}.make)
			json.add_converter (create {CJ_DATA_JSON_CONVERTER}.make)
			json.add_converter (create {CJ_ERROR_JSON_CONVERTER}.make)
			json.add_converter (create {CJ_ITEM_JSON_CONVERTER}.make)
			json.add_converter (create {CJ_QUERY_JSON_CONVERTER}.make)
			json.add_converter (create {CJ_TEMPLATE_JSON_CONVERTER}.make)
			json.add_converter (create {CJ_LINK_JSON_CONVERTER}.make)
			if json.converter_for (create {ARRAYED_LIST [detachable ANY]}.make (0)) = Void then
				json.add_converter (create {CJ_ARRAYED_LIST_JSON_CONVERTER}.make)
			end
		end

	test_data
			--{"name" : "full-name", "value" : "", "prompt" : "Full Name"}
		local
			l_data: CJ_DATA
		do
			create l_data.make
			l_data.set_name ("full-name")
			l_data.set_value ("test")
			l_data.set_prompt ("Full Name")
			if attached {JSON_VALUE} json.value (l_data) as jv then
				print (pretty_string (jv))
			end
		end

	test_error
			-- {
			--"title" : "Server Error",
			--"code" : "X1C2",
			--"message" : "The server have encountered an error, please wait and try again."
			--}
		local
			l_error: CJ_ERROR
		do
			create l_error.make_empty
			l_error.set_code ("X1C2")
			l_error.set_message ("The server have encountered an error, please wait and try again.")
			l_error.set_title ("Server Error")
			if attached {JSON_VALUE} json.value (l_error) as jv then
				print (pretty_string (jv))
			end
		end

	test_link
			--{"rel" : "avatar", "href" : "http://examples.org/images/jdoe", "prompt" : "Avatar", "render" : "image"}
		local
			l_link: CJ_LINK
		do
			create l_link.make ("http://examples.org/images/jdoe", "avatar")
			l_link.set_prompt ("Avatar")
			l_link.set_render ("image")
			if attached {JSON_VALUE} json.value (l_link) as jv then
				print (pretty_string (jv))
			end
		end

	test_template
			--{
			-- "data" : [
			--{"name" : "full-name", "value" : "", "prompt" : "Full Name"},
			--{"name" : "email", "value" : "", "prompt" : "Email"},
			--{"name" : "blog", "value" : "", "prompt" : "Blog"},
			--{"name" : "avatar", "value" : "", "prompt" : "Avatar"}
			--]
			-- }
		local
			l_template: CJ_TEMPLATE
		do
			create l_template.make
			l_template.add_data (new_data ("full-name", "", "Full Name"))
			l_template.add_data (new_data ("email", "", "Email"))
			l_template.add_data (new_data ("blog", "", "Blog"))
			l_template.add_data (new_data ("avatar", "", "Avatar"))
			if attached {JSON_VALUE} json.value (l_template) as jv then
				print (pretty_string (jv))
			end
		end

	test_item
			--      {
			--        "href" : "http://example.org/friends/jdoe",
			--        "data" : [
			--          {"name" : "full-name", "value" : "J. Doe", "prompt" : "Full Name"},
			--          {"name" : "email", "value" : "jdoe@example.org", "prompt" : "Email"}
			--        ],
			--        "links" : [
			--          {"rel" : "blog", "href" : "http://examples.org/blogs/jdoe", "prompt" : "Blog"},
			--          {"rel" : "avatar", "href" : "http://examples.org/images/jdoe", "prompt" : "Avatar", "render" : "image"}
			--        ]
			--      }
		local
			l_item: CJ_ITEM
		do
			create l_item.make ("http://example.org/friends/jdoe")
			l_item.add_data (new_data ("full-name", "J. Doe", "Full Name"))
			l_item.add_data (new_data ("email", "jdoe@example.org", "Email"))
			l_item.add_link (new_link ("http://examples.org/blogs/jdoe", "blog", "Blog", Void, Void))
			l_item.add_link (new_link ("http://examples.org/images/jdoe", "avatar", "Avatar", Void, "image"))
			if attached {JSON_VALUE} json.value (l_item) as jv then
				print (pretty_string (jv))
			end
		end

	test_queries
			--
			--      {"rel" : "search", "href" : "http://example.org/friends/search", "prompt" : "Search",
			--        "data" : [
			--          {"name" : "search", "value" : ""}
			--        ]
			--      }
			--
		local
			l_query: CJ_QUERY
		do
			create l_query.make ("http://example.org/friends/search", "search")
			l_query.set_prompt ("Search")
			l_query.add_data (new_data ("search", "", ""))
			if attached {JSON_VALUE} json.value (l_query) as jv then
				print (pretty_string (jv))
			end
		end

	test_collection
			--		{
			--    "version" : "1.0",
			--    "href" : "http://example.org/friends/",
			--
			--    "links" : [
			--      {"rel" : "feed", "href" : "http://example.org/friends/rss"}
			--    ],
			--
			--    "items" : [
			--      {
			--        "href" : "http://example.org/friends/jdoe",
			--        "data" : [
			--          {"name" : "full-name", "value" : "J. Doe", "prompt" : "Full Name"},
			--          {"name" : "email", "value" : "jdoe@example.org", "prompt" : "Email"}
			--        ],
			--        "links" : [
			--          {"rel" : "blog", "href" : "http://examples.org/blogs/jdoe", "prompt" : "Blog"},
			--          {"rel" : "avatar", "href" : "http://examples.org/images/jdoe", "prompt" : "Avatar", "render" : "image"}
			--        ]
			--      },
			--
			--      {
			--        "href" : "http://example.org/friends/msmith",
			--        "data" : [
			--          {"name" : "full-name", "value" : "M. Smith", "prompt" : "Full Name"},
			--          {"name" : "email", "value" : "msmith@example.org", "prompt" : "Email"}
			--        ],
			--        "links" : [
			--          {"rel" : "blog", "href" : "http://examples.org/blogs/msmith", "prompt" : "Blog"},
			--          {"rel" : "avatar", "href" : "http://examples.org/images/msmith", "prompt" : "Avatar", "render" : "image"}
			--        ]
			--      },
			--
			--      {
			--        "href" : "http://example.org/friends/rwilliams",
			--        "data" : [
			--          {"name" : "full-name", "value" : "R. Williams", "prompt" : "Full Name"},
			--          {"name" : "email", "value" : "rwilliams@example.org", "prompt" : "Email"}
			--        ],
			--        "links" : [
			--          {"rel" : "blog", "href" : "http://examples.org/blogs/rwilliams", "prompt" : "Blog"},
			--          {"rel" : "avatar", "href" : "http://examples.org/images/rwilliams", "prompt" : "Avatar", "render" : "image"}
			--        ]
			--      }
			--    ],
			--
			--    "queries" : [
			--      {"rel" : "search", "href" : "http://example.org/friends/search", "prompt" : "Search",
			--        "data" : [
			--          {"name" : "search", "value" : ""}
			--        ]
			--      }
			--    ],
			--
			--    "template" : {
			--      "data" : [
			--        {"name" : "full-name", "value" : "", "prompt" : "Full Name"},
			--        {"name" : "email", "value" : "", "prompt" : "Email"},
			--        {"name" : "blog", "value" : "", "prompt" : "Blog"},
			--        {"name" : "avatar", "value" : "", "prompt" : "Avatar"}
			--
			--      ]
			--    },
			--
			--    "error" : {
			--          "title" : "Server Error",
			--          "code" : "X1C2",
			--          "message" : "The server have encountered an error, please wait and try again."
			--    }
			--  }
		local
			l_collection: CJ_COLLECTION
			l_item: CJ_ITEM
			l_query: CJ_QUERY
			l_template: CJ_TEMPLATE
			l_error: CJ_ERROR
			s: like pretty_string
		do
			create l_collection.make_with_href ("http://example.org/friends/")
			l_collection.add_link (new_link ("http://example.org/friends/rss", "feed", Void, Void, Void))

				-- Add items
			create l_item.make ("http://example.org/friends/jdoe")
			l_item.add_data (new_data ("full-name", "J. Doe", "Full Name"))
			l_item.add_data (new_data ("email", "jdoe@example.org", "Email"))
			l_item.add_link (new_link ("http://examples.org/blogs/jdoe", "blog", "Blog", Void, Void))
			l_item.add_link (new_link ("http://examples.org/images/jdoe", "avatar", "Avatar", Void, "image"))
			l_collection.add_item (l_item)
			create l_item.make ("http://example.org/friends/msmith")
			l_item.add_data (new_data ("full-name", "M. Smith", "Full Name"))
			l_item.add_data (new_data ("email", "msmith@example.org", "Email"))
			l_item.add_link (new_link ("http://examples.org/blogs/msmith", "blog", "Blog", Void, Void))
			l_item.add_link (new_link ("http://examples.org/images/msmith", "avatar", "Avatar", Void, "image"))
			l_collection.add_item (l_item)
			create l_item.make ("http://example.org/friends/rwilliams")
			l_item.add_data (new_data ("full-name", "R. Williams", "Full Name"))
			l_item.add_data (new_data ("email", "rwilliams@example.org", "Email"))
			l_item.add_link (new_link ("http://examples.org/blogs/rwilliams", "blog", "Blog", Void, Void))
			l_item.add_link (new_link ("http://examples.org/images/rwilliams", "avatar", "Avatar", Void, "image"))
			l_collection.add_item (l_item)

				-- Add Queries
			create l_query.make ("http://example.org/friends/search", "search")
			l_query.set_prompt ("Search")
			l_query.add_data (new_data ("search", "", ""))
			l_collection.add_query (l_query)

				-- Add templates

			create l_template.make
			l_template.add_data (new_data ("full-name", "", "Full Name"))
			l_template.add_data (new_data ("email", "", "Email"))
			l_template.add_data (new_data ("blog", "", "Blog"))
			l_template.add_data (new_data ("avatar", "", "Avatar"))
			l_collection.set_template (l_template)

				--Add Error
			create l_error.make_empty
			l_error.set_code ("X1C2")
			l_error.set_message ("The server have encountered an error, please wait and try again.")
			l_error.set_title ("Server Error")
			l_collection.set_error (l_error)
			if attached {JSON_VALUE} json.value (l_collection) as jv then
				s := pretty_string (jv)
				print (s.as_string_8)
				print ("%N")
				if attached (create {CJ_COLLECTION_FACTORY}).collection (s) as v_collection then
					if attached {JSON_VALUE} json.value (l_collection) as jv2 then
						if s.same_string (pretty_string (jv2)) then
							if attached (create {RAW_FILE}.make_create_read_write ("test_collection.json")) as f then
								f.put_string (s)
								f.close
							end
							print ("Success%N")
						else
							print ("Failure%N")
						end
					else
						print ("Failure%N")
					end
				else
					print ("Failure%N")
				end
			end
		end

	test_attachment
			--{
			-- "data" : [
			--{"name" : "full-name", "value" : "", "prompt" : "Full Name"},
			--{"name" : "email", "value" : "", "prompt" : "Email"},
			--{"name" : "blog", "value" : "", "prompt" : "Blog"},
			--{"name" : "avatar", "value" : "", "prompt" : "Avatar"}
			-- {"name" : "attachments", "files" : [ {"name": "file1.txt", "value": "content"} ] , "prompt" : "Attachments"}
			--]
			-- }
		local
			l_template: CJ_TEMPLATE
		do
			create l_template.make
			l_template.add_data (new_data ("full-name", "", "Full Name"))
			l_template.add_data (new_data ("email", "", "Email"))
			l_template.add_data (new_data ("blog", "", "Blog"))
			l_template.add_data (new_data ("avatar", "", "Avatar"))
			l_template.add_data (new_data_with_attachments ("attachments", "", "Attachment", new_attachements))
			if attached {JSON_VALUE} json.value (l_template) as jv then
				print (pretty_string (jv))
			end
		end

	test_acceptable_url
			--{
			-- "data" : [
			--{"name" : "full-name", "value" : "", "prompt" : "Full Name"},
			--{"name" : "email", "value" : "", "prompt" : "Email"},
			--{"name" : "blog", "value" : "", "prompt" : "Blog"},
			--{"name" : "avatar", "value" : "", "prompt" : "Avatar"}
			-- {"name" : "status", "acceptableValues" : "http://localhost:9090/status","value":""}
			--]
			-- }
		local
			l_template: CJ_TEMPLATE
		do
			create l_template.make
			l_template.add_data (new_data ("full-name", "", "Full Name"))
			l_template.add_data (new_data ("email", "", "Email"))
			l_template.add_data (new_data ("blog", "", "Blog"))
			l_template.add_data (new_data ("avatar", "", "Avatar"))
			l_template.add_data (new_data_acceptable_url ("status", "", "http://localhost:9090/status", "Status"))
			if attached {JSON_VALUE} json.value (l_template) as jv then
				print (pretty_string (jv))
			end
		end

	test_acceptable_list
			--{
			-- "data" : [
			--{"name" : "full-name", "value" : "", "prompt" : "Full Name"},
			--{"name" : "email", "value" : "", "prompt" : "Email"},
			--{"name" : "blog", "value" : "", "prompt" : "Blog"},
			--{"name" : "avatar", "value" : "", "prompt" : "Avatar"}
			-- {"name" : "status", "acceptableValues" : ["Open","Close","Pending","Won't Fix"],"value":""}
			--]
			-- }
		local
			l_template: CJ_TEMPLATE
		do
			create l_template.make
			l_template.add_data (new_data ("full-name", "", "Full Name"))
			l_template.add_data (new_data ("email", "", "Email"))
			l_template.add_data (new_data ("blog", "", "Blog"))
			l_template.add_data (new_data ("avatar", "", "Avatar"))
			l_template.add_data (new_data_acceptable_list ("status", "", new_list, "Status"))
			if attached {JSON_VALUE} json.value (l_template) as jv then
				print (pretty_string (jv))
			end
		end


	test_acceptable_map
			--{
			-- "data" : [
			--{"name" : "full-name", "value" : "", "prompt" : "Full Name"},
			--{"name" : "email", "value" : "", "prompt" : "Email"},
			--{"name" : "blog", "value" : "", "prompt" : "Blog"},
			--{"name" : "avatar", "value" : "", "prompt" : "Avatar"}
			-- {"name" : "status", "acceptableValues" : [{"id":"1", "name":"Open"},{"id":"2", "name":"Close"},{"id":"3", "name":"Pending"},{"id":"4", "name":"Won't Fix"}] ,"value":""}

			--]
			-- }
		local
			l_template: CJ_TEMPLATE
		do
			create l_template.make
			l_template.add_data (new_data ("full-name", "", "Full Name"))
			l_template.add_data (new_data ("email", "", "Email"))
			l_template.add_data (new_data ("blog", "", "Blog"))
			l_template.add_data (new_data ("avatar", "", "Avatar"))
			l_template.add_data (new_data_acceptable_map ("status", "", new_map, "Status"))
			if attached {JSON_VALUE} json.value (l_template) as jv then
				print (pretty_string (jv))
			end
		end


	test_value_type_array
	    --"data" : [
	    --  {"name" : "full-name", "value" : ""},
	    --  {"name" : "email", "value" : ""},
	    --  {"name" : "status", "array" : ["Open","Close","Pending","Won't Fix"]}
	    -- ]
		local
			l_template: CJ_TEMPLATE
		do
			create l_template.make
			l_template.add_data (new_data ("full-name", "", "Full Name"))
			l_template.add_data (new_data ("email", "", "Email"))
			l_template.add_data (new_data ("blog", "", "Blog"))
			l_template.add_data (new_data_value_type_array ("status", "", new_array, "Status"))
			if attached {JSON_VALUE} json.value (l_template) as jv then
				print (pretty_string (jv))
			end
		end





	pretty_string (j: JSON_VALUE): STRING_32
		local
			v: JSON_PRETTY_STRING_VISITOR
		do
			create Result.make_empty
			create v.make_custom (Result, 4, 2)
			j.accept (v)
		end

feature {NONE} -- Implementation

	new_data (name: STRING; value: STRING; prompt: STRING): CJ_DATA
		do
			create Result.make
			Result.set_name (name)
			Result.set_value (value)
			Result.set_prompt (prompt)
		end

	new_data_acceptable_url (name: STRING; value: STRING; a_url: READABLE_STRING_32; prompt: STRING): CJ_DATA
		do
			Result := new_data (name, value, prompt)
			Result.set_acceptable_url (a_url)

		end

	new_data_acceptable_list (name: STRING; value: STRING; a_list: LIST[READABLE_STRING_32]; prompt: STRING): CJ_DATA
		do
			Result := new_data (name, value, prompt)
			Result.set_acceptable_list (a_list)
		end

	new_data_acceptable_map (name: STRING; value: STRING; a_map: STRING_TABLE[READABLE_STRING_32]; prompt: STRING): CJ_DATA
		do
			Result := new_data (name, value, prompt)
			Result.set_acceptable_map (a_map)
		end

	new_data_value_type_array (name: STRING; value: STRING; a_array: LIST[READABLE_STRING_32]; prompt: STRING): CJ_DATA
		do
			Result := new_data (name, value, prompt)
			across a_array as c loop Result.add_element_to_array(c.item) end
		end


	new_data_with_attachments (name: STRING; value: STRING; prompt: STRING; a_attachments: STRING_TABLE[STRING]): CJ_DATA
		do
			Result := new_data (name, value, prompt)
			from
				a_attachments.start
			until
				a_attachments.after
			loop
				Result.add_attachment (a_attachments.key_for_iteration.as_string_32, a_attachments.item_for_iteration.as_string_32)
				a_attachments.forth
			end

		end


	new_link (href: STRING; rel: STRING; prompt: detachable STRING; name: detachable STRING; render: detachable STRING): CJ_LINK
		do
			create Result.make (href, rel)
			if attached name as l_name then
				Result.set_name (l_name)
			end
			if attached render as l_render then
				Result.set_render (l_render)
			end
			if attached prompt as l_prompt then
				Result.set_prompt (l_prompt)
			end
		end


	new_attachements: STRING_TABLE[STRING]
		do
			create Result.make(0)
			Result.put ("content", "file1.txt")
		end

	new_list: LIST[READABLE_STRING_32]
		do
			create {ARRAYED_LIST[READABLE_STRING_32]}Result.make (4)
			Result.force ("Open")
			Result.force ("Close")
			Result.force ("Pending")
			Result.force ("Won't Fix")
		end

	new_map: STRING_TABLE[READABLE_STRING_32]
		do
			create Result.make (4)
			Result.force ("Open", "1")
			Result.force ("Close", "2")
			Result.force ("Pending","3")
			Result.force ("Won't Fix","4")
		end

	new_array: LIST [READABLE_STRING_32]
		do
			create {ARRAYED_LIST[READABLE_STRING_32]}Result.make (4)
			Result.force ("Open")
			Result.force ("Close")
			Result.force ("Pending")
			Result.force ("Won't Fix")
		end

end