note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	CJ_CLIENT_PROXY

create
	make

feature {NONE} -- Initialization

	make (cl: like client)
			-- Initialize `Current'.
		do
			create context_adaptation_agents.make (1)
			client := cl
		end

feature {NONE} -- Access

	client: CJ_CLIENT

	adapted_context (a_ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT): detachable HTTP_CLIENT_REQUEST_CONTEXT
		do
			Result := a_ctx
			across
				context_adaptation_agents as c
			loop
				Result := c.item.item ([Result])
			end
		end

feature -- Access

	context_adaptation_agents: ARRAYED_LIST [FUNCTION [ANY, TUPLE [detachable HTTP_CLIENT_REQUEST_CONTEXT], like adapted_context]]

feature -- Execution

	get (a_path: READABLE_STRING_GENERAL; ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT): CJ_CLIENT_RESPONSE
		do
			Result := client.get (a_path, adapted_context (ctx))
		end

	query (q: CJ_QUERY; ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT): CJ_CLIENT_RESPONSE
		do
			Result := client.query (q, adapted_context (ctx))
		end

	create_with_template (a_path: READABLE_STRING_GENERAL; tpl: CJ_TEMPLATE; ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT): CJ_CLIENT_RESPONSE
		do
			Result := client.create_with_template (a_path, tpl, adapted_context (ctx))
		end

	update_with_template (a_path: READABLE_STRING_GENERAL; tpl: CJ_TEMPLATE; ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT): CJ_CLIENT_RESPONSE
		do
			Result := client.update_with_template (a_path, tpl, adapted_context (ctx))
		end

end
