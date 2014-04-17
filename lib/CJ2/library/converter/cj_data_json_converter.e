note
	description: "A JSON converter for CJ_DATA"
	date: "$Date$"
	revision: "$Revision$"

class
	CJ_DATA_JSON_CONVERTER

inherit
	CJ_JSON_CONVERTER

create
	make

feature {NONE} -- Initialization

	make
		do
			create object.make
		end

feature -- Access

	object: CJ_DATA

feature -- Conversion

	from_json (j: like to_json): detachable like object
		local
			l_map: STRING_TABLE[READABLE_STRING_32]
			l_list: ARRAYED_LIST[READABLE_STRING_32]
		do
			create Result.make
			if attached {STRING_32} json_to_object (j.item (name_key), Void) as l_name then
				Result.set_name (l_name)
			end
			if attached {STRING_32} json_to_object (j.item (prompt_key), Void) as l_prompt then
				Result.set_prompt (l_prompt)
			end
			if attached {STRING_32} json_to_object (j.item (value_key), Void) as l_value then
				Result.set_value (l_value)
			elseif	attached {BOOLEAN} json_to_object (j.item (value_key), Void) as l_value then
				Result.set_value (l_value.out)
			end
			if attached {JSON_ARRAY} j.item (files_key) as l_files then
				Result.initilize_attachment
				across l_files as c  loop
					if attached {JSON_OBJECT} c.item as jo and then attached {JSON_STRING} jo.item("name") as l_key and then
						attached {JSON_STRING} jo.item("value") as l_content then
							Result.add_attachment (l_key.item, l_content.item)
					end
				end
			end
			if attached {JSON_VALUE} j.item (accepted_values_key) as l_accepted then
				if attached {JSON_STRING} l_accepted as l_string then
					Result.set_acceptable_url (l_string.item)
				elseif attached {JSON_ARRAY} l_accepted as l_array then
					if attached {JSON_STRING} l_array.i_th (1) then
						create l_list.make (0)
						across l_array as c  loop
							if attached {JSON_STRING} c.item as jo  then
								l_list.force (jo.item)
							end
						end
						Result.set_acceptable_list (l_list)
					else
						create l_map.make (0)
						across l_array as c  loop
							if attached {JSON_OBJECT} c.item as jo and then attached {JSON_STRING} jo.item("name") as l_key and then
								attached {JSON_STRING} jo.item("value") as l_content then
								l_map.force (l_content.item, l_key.item)
							end
						end
						Result.set_acceptable_map (l_map)
					end

				end


			end
			--|TODO improve this code
			--|is there a better way to write this?
			--|is a good idea create the Result object at the first line and then set the value
			--|if it is attached?
		end

	to_json (o: like object): JSON_OBJECT
		do
			create Result.make
			Result.put (json.value (o.name), name_key)
			if attached o.prompt as o_prompt then
				Result.put (json.value (o_prompt), prompt_key)
			end
			if attached o.value as o_value then
				Result.put (json.value (o_value), value_key)
			end
			if attached o.files as o_file then
				Result.put (to_json_attachments (o_file), files_key)
			end
			if attached o.acceptable_url as o_url then
				Result.put (json.value (o_url), accepted_values_key)
			elseif attached o.acceptable_list as o_list then
				Result.put (to_json_acceptable_list (o_list), accepted_values_key)
			elseif attached o.acceptable_map as o_map then
				Result.put (to_json_acceptable_map (o_map), accepted_values_key)
			end

		end

	to_json_attachments (a_files: STRING_TABLE[STRING]): JSON_ARRAY
		local
			l_jo: JSON_OBJECT
		do
			from
				a_files.start
				create Result.make_array
			until
				a_files.after
			loop
				create l_jo.make
				l_jo.put (create {JSON_STRING}.make_json (a_files.key_for_iteration.as_string_32), create {JSON_STRING}.make_json ("name"))
				l_jo.put (create {JSON_STRING}.make_json (a_files.item_for_iteration.as_string_32), create {JSON_STRING}.make_json ("value"))
				a_files.forth
				Result.add (l_jo)
			end
		end


	to_json_acceptable_list (a_list: LIST[READABLE_STRING_32]): JSON_ARRAY
		do
			from
				a_list.start
				create Result.make_array
			until
				a_list.after
			loop
				Result.add (create {JSON_STRING}.make_json (a_list.item_for_iteration.as_string_32))
				a_list.forth
			end
		end


	to_json_acceptable_map (a_map: STRING_TABLE[READABLE_STRING_32]): JSON_ARRAY
		local
			l_jo: JSON_OBJECT
		do
			from
				a_map.start
				create Result.make_array
			until
				a_map.after
			loop
				create l_jo.make
				l_jo.put (create {JSON_STRING}.make_json (a_map.key_for_iteration.as_string_32), create {JSON_STRING}.make_json ("name"))
				l_jo.put (create {JSON_STRING}.make_json (a_map.item_for_iteration.as_string_32), create {JSON_STRING}.make_json ("value"))
				a_map.forth
				Result.add (l_jo)
			end
		end



feature {NONE} -- Implementation

	prompt_key: JSON_STRING
		once
			create Result.make_json ("prompt")
		end

	name_key: JSON_STRING
		once
			create Result.make_json ("name")
		end

	value_key: JSON_STRING
		once
			create Result.make_json ("value")
		end

	files_key: JSON_STRING
		once
			create Result.make_json ("files")
		end

	accepted_values_key: JSON_STRING
		once
			create Result.make_json ("acceptableValues")
		end


note
	copyright: "2011-2014, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end -- class JSON_DATA_CONVERTER
