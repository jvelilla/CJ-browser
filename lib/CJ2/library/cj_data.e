note
	description: "[
				Data objects may have three possible properties:
					- name   (REQUIRED)
					- value  (OPTIONAL)
					- prompt (OPTIONAL)
			]"
	date: "$Date$"
	revision: "$Revision$"
	example: "[
		{
		  "prompt" : STRING_32,
		  "name" : STRING_32,
		  "value" : STRING_32
		  
		}
	]"
   EIS: "Lookup Extension", "src=https://github.com/jvelilla/collection-json/blob/jv_extensions/extensions/lookup.md", "protocol=uri"
   EIS: "Attachment Extension", "src=https://github.com/jvelilla/collection-json/blob/jv_extensions/extensions/attachment.md", "protocol=uri"
   EIS: "Value Types Extension", "src=https://github.com/collection-json/extensions/blob/master/value-types.md", "protocol=uri"

class
	CJ_DATA

create
	make,
	make_with_name

feature {NONE} -- Initialization

	make
		do
			make_with_name (create {like name}.make_empty)
		end

	make_with_name (a_name: like name)
		do
			name := a_name
		end

feature -- Access

	name: STRING_32

	prompt: detachable STRING_32

	value: detachable STRING_32
			-- this propertie May contain
			-- one of the following data types, STRING, NUMBER, Boolean(true,false), null

feature -- Attachment Extension

	files: detachable STRING_TABLE[STRING]
			-- A key, value pair of attached files
			-- this property is optional.



feature -- Lookup Extension

	acceptable_values: detachable ANY
			-- list of key, a list of value pairs, or a URL

	acceptable_url: detachable READABLE_STRING_32
			-- Acceptable value as a URL, if any.
		do
			if attached {READABLE_STRING_32} acceptable_values as l_val then
				Result := l_val
			end
		end

	acceptable_list: detachable LIST[READABLE_STRING_32]
			-- Acceptable value as a list, if any.
		do
			if attached {LIST[READABLE_STRING_32]} acceptable_values as l_val then
				Result := l_val
			end
		end

	acceptable_map: detachable STRING_TABLE[READABLE_STRING_32]
			-- Acceptable value as a list, if any.
		do
			if attached {STRING_TABLE[READABLE_STRING_32]} acceptable_values as l_val then
				Result := l_val
			end
		end

feature -- Value Types Extension

	array : detachable LIST[READABLE_STRING_32]
		--  An array value is defined to only contain the scalar values as defined by section 6.6.

	object:  detachable TUPLE[key:READABLE_STRING_32; value:READABLE_STRING_32]
		-- An object is a JSON object containing key value pairs where the values are restricted by section 6.6.		

feature -- Reset Value Types Extension

	reset_array
			-- Reset the current elements.
		do
			array := Void
		end

feature -- Element Change

	set_name (a_name: like name)
			-- Set `name' to `a_name'.
		do
			name := a_name
		ensure
			name_set: name ~ a_name
		end

	set_prompt (a_prompt: like prompt)
			-- Set `prompt' to `a_prompt'.	
		do
			prompt := a_prompt
		ensure
			prompt_set: prompt ~ a_prompt
		end

	set_value (a_value: like value)
		do
			value := a_value
		ensure
			value_set: value ~ a_value
		end

	initilize_attachment
		do
			create files.make (0)
		ensure
			files_set: attached files
		end

	add_attachment (a_key: READABLE_STRING_32; a_content: READABLE_STRING_32)
			-- Add a file with a key `a_key' and their content `a_content'.
			-- The content is added in BASE64 encoding, the content will be encoded if needed.
		local
			l_files: like files
		do
			l_files := files
			if l_files = Void then
				create l_files.make(0)
				files := l_files
			end
			l_files.force (a_content, a_key)
		end


	add_element_to_array (a_content: READABLE_STRING_32)
			-- Add a file with a key `a_key' and their content `a_content'.
			-- The content is added in BASE64 encoding, the content will be encoded if needed.
		local
			l_array: like array
		do
			l_array := array
			if l_array = Void then
				create {ARRAYED_LIST[READABLE_STRING_32]}l_array.make(0)
				array := l_array
			end
			l_array.force (a_content)
		end

	set_object (a_key: READABLE_STRING_32; a_content: READABLE_STRING_32)
			-- Add a pair with a key `a_key' and their content `a_content'.
		do
			object := [a_key, a_content]
		ensure
			object_set: attached object
		end

	set_acceptable_url (a_url: READABLE_STRING_32)
			--Set `acceptable_values as a URL'
		do
			acceptable_values := a_url
		ensure
			acceptable_values_set: acceptable_values = a_url
		end

	set_acceptable_list (a_list: LIST[READABLE_STRING_32])
			-- Set `acceptable_values' as a list of keys
		do
			acceptable_values := a_list
		ensure
			acceptable_values_set: acceptable_values = a_list
		end

	set_acceptable_map (a_map: STRING_TABLE[READABLE_STRING_32])
			-- Set `acceptable_values' as a map of key value pairs
		do
			acceptable_values := a_map
		ensure
			acceptable_values_set: acceptable_values = a_map
		end

note
	copyright: "2011-2014, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
