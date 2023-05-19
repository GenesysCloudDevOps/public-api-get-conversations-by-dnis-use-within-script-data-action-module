resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "description" = "Check if we had interactions for a certain DNIS",
        "properties" = {
            "DNIS" = {
                "description" = "DNIS in e.164 format",
                "type" = "string"
            },
            "Date" = {
                "description" = "Date in the format YYYY-MM-DDThh:mm:ss/YYYY-MM-DDThh:mm:ss (yesterday/today+1 for example, a query that does not exceed 31 days)",
                "format" = "YYYY-MM-DDThh:mm:ss/YYYY-MM-DDThh:mm:ss",
                "type" = "string"
            }
        },
        "required" = [
            "DNIS",
            "Date"
        ],
        "title" = "Check for interactions with DNIS",
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "description" = "Returns the Interaction IDs",
        "properties" = {
            "InteractionIds" = {
                "description" = "The Interaction ID(s) that contain the DNIS you looked up",
                "items" = {
                    "title" = "Interaction ID",
                    "type" = "string"
                },
                "type" = "array"
            }
        },
        "title" = "Check for interactions with DNIS",
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\r\n \"interval\": \"$${input.Date}\",\r\n \"order\": \"asc\",\r\n \"orderBy\": \"conversationStart\",\r\n \"paging\": {\r\n  \"pageSize\": 25,\r\n  \"pageNumber\": 1\r\n },\r\n \"segmentFilters\": [\r\n  {\r\n   \"type\": \"and\",\r\n   \"predicates\": [\r\n    {\r\n     \"type\": \"dimension\",\r\n     \"dimension\": \"dnis\",\r\n     \"operator\": \"matches\",\r\n     \"value\": \"$${input.DNIS}\"\r\n    }\r\n   ]\r\n  }\r\n ]\r\n}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/conversations/details/query"
        headers = {
			Content-Type = "application/json"
		}
    }

    config_response {
        success_template = "{\"InteractionIds\": $${InteractionIds}}"
        translation_map = { 
			InteractionIds = "$.conversations[*].conversationId"
		}
        translation_map_defaults = {       
			InteractionIds = "[\r\n  \"\"\r\n]"
		}
    }
}