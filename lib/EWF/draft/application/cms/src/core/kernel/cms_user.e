note
	description: "Summary description for {CMS_USER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_USER

inherit
	DEBUG_OUTPUT

create
	make_new,
	make

feature {NONE} -- Initialization

	make (a_id: like id; n: like name; dt: like creation_date)
		require
			a_id > 0
		do
			id := a_id
			creation_date := dt
			name := n
		ensure
			valid_password: password = Void and encoded_password /= Void
		end

	make_new (n: like name)
		do
			name := n
			create creation_date.make_now_utc
		end

feature -- Access

	is_admin: BOOLEAN
		do
			Result := id = 1
		end

	id: INTEGER

	name: STRING_8

	password: detachable READABLE_STRING_32

	encoded_password: detachable READABLE_STRING_8

	email: detachable READABLE_STRING_8

	profile: detachable CMS_USER_PROFILE

	creation_date: DATE_TIME

	last_login_date: detachable DATE_TIME

	data: detachable HASH_TABLE [detachable ANY, STRING]

	data_item (k: STRING): detachable ANY
		do
			if attached data as l_data then
				Result := l_data.item (k)
			end
		end

feature -- Status report

	has_id: BOOLEAN
		do
			Result := id > 0
		end

	has_email: BOOLEAN
		do
			Result := attached email as e and then not e.is_empty
		end

	debug_output: STRING
		do
			Result := name
		end

	same_as (u: detachable CMS_USER): BOOLEAN
		do
			Result := u /= Void and then id = u.id
		end

feature -- Element change

	set_id (a_id: like id)
		do
			id := a_id
		end

	set_password (p: like password)
		do
			password := p
		end

	set_encoded_password (p: like encoded_password)
		do
			encoded_password := p
		end

	set_email (m: like email)
		do
			email := m
		end

	set_profile (prof: like profile)
		do
			profile := prof
		end

	set_data_item (k: READABLE_STRING_8; d: like data_item)
		local
			l_data: like data
		do
			l_data := data
			if l_data = Void then
				create l_data.make (1)
				data := l_data
			end
			l_data.force (d, k)
		end

	remove_data_item (k: READABLE_STRING_8)
		do
			if attached data as l_data then
				l_data.remove (k)
			end
		end

	set_profile_item (k: READABLE_STRING_8; v: READABLE_STRING_8)
		local
			prof: like profile
		do
			prof := profile
			if prof = Void then
				create prof.make
				profile := prof
			end
			prof.force (v, k)
		end

	set_last_login_date (dt: like last_login_date)
		do
			last_login_date := dt
		end

	set_last_login_date_now
		do
			set_last_login_date (create {DATE_TIME}.make_now_utc)
		end

end
