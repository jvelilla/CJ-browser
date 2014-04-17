note
	description: "Summary description for {TEST_ENCODE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_ENCODE

inherit

	EQA_TEST_SET


feature -- Tests

	test_valid_64_encoding
		do
			assert ("Expected encoded True:", is_valid_base64_encoding ((create {BASE64}).encoded_string ("content")))
		end

	test_not_valid64_encoding
		do
			assert ("Expected encoded False:", not is_valid_base64_encoding ("content"))
		end


feature {NONE} -- Implementation

	is_valid_base64_encoding (a_string: STRING): BOOLEAN
			-- is `a_string' base64 encoded?
		local
			l_encoder: BASE64
			l_string: STRING
			l_retry: BOOLEAN
		do
			if not l_retry then
				create l_encoder
				l_string := l_encoder.decoded_string (a_string)
				Result := not l_encoder.has_error
			end
		rescue
			l_retry := True
			retry
		end
end
