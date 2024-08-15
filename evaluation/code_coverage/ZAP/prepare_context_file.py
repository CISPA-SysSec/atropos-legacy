import json
import yaml

# ZAP context file description: https://www.zaproxy.org/docs/desktop/addons/automation-framework/environment/


def get(data, key, context_key=None):
    if context_key is None:
        context_key = key

    if context_key in data:
        return {
            key: data[context_key]
        }
    return {}


def generate_context_data(ii, app_context_data):
    return {
                "name": f"context {ii}",
                "urls": [app_context_data["url"]],
                **get(app_context_data, "includePaths", "include_paths"),
                **get(app_context_data, "excludePaths", "exclude_paths"),
                "authentication": {
                    **get(app_context_data, "method", "authentication_method"),
                    "parameters": {
                        **get(app_context_data, "hostname"),
                        **get(app_context_data, "port"),
                        **get(app_context_data, "realm"),
                        **get(app_context_data, "loginPageUrl", "login_page_url"),
                        **get(app_context_data, "loginRequestUrl", "login_request_url"),
                        **get(app_context_data, "loginRequestBody", "login_request_body"),
                        **get(app_context_data, "script"),
                        **get(app_context_data, "scriptEngine", "script_engine")
                    },
                    "verification": {
                        "method": "response",
                        "loggedInRegex": "",
                        "loggedOutRegex": "",
                        "pollFrequency": 0,
                        "pollUnits": "",
                        "pollUrl": "",
                        "pollPostData": "",
                        "pollAdditionalHeaders": []
                    }
                },
                "sessionManagement": {
                    "method": "cookie",
                    "parameters": []
                },
                # "technology": {
                #     "exclude": []
                # },
                "users": [{
                    "name": f"user {ii}",
                    "credentials": [{
                        **get(app_context_data, "username"),
                        **get(app_context_data, "password"),
                    }]
                }]
            }

def generate_context_file():
    with open("/app_info.json", "r") as f:
        app_info = json.load(f)

    zap_app_info = {
        "contexts": [
            generate_context_data(ii + 1, app_context_data)
            for ii, app_context_data
            in enumerate(app_info)
        ],
        "vars": {},
        "parameters": {
            "failOnError": False,
            "failOnWarning": False,
            "progressToStdout": True
        }
    }

    assert len(app_info) == 1, "Only one context is supported at the moment"

    with open("/target.txt", "w") as f:
        f.write(app_info[0]["url"])

    with open("/context.yaml", "w") as f:
        yaml.dump(zap_app_info, f)


def main():
    generate_context_file()


if __name__ == "__main__":
    main()


# env:                                   # The environment, mandatory
#   contexts :                           # List of 1 or more contexts, mandatory
#     - name: context 1                  # Name to be used to refer to this context in other jobs, mandatory
#       urls:                            # A mandatory list of top level urls, everything under each url will be included
#       includePaths:                    # An optional list of regexes to include
#       excludePaths:                    # An optional list of regexes to exclude
#       authentication:
#         method:                        # String, one of 'manual', 'http', 'form', 'json' or 'script'
#         parameters:                    # May include any required for scripts. All of the parameters support vars except for the port 
#           hostname:                    # String, only for 'http' authentication
#           port:                        # Int, only for 'http' authentication
#           realm:                       # String, only for 'http' authentication
#           loginPageUrl:                # String, the login page URL to read prior to making the request, only for 'form' or 'json' authentication
#           loginRequestUrl:             # String, the login URL to request, only for 'form' or 'json' authentication
#           loginRequestBody:            # String, the login request body - if not supplied a GET request will be used, only for 'form' or 'json' authentication
#           script:                      # String, path to script, only for 'script' authentication
#           scriptEngine:                # String, the name of the script engine to use, only for 'script' authentication
#         verification:
#           method:                      # String, one of 'response', 'request', 'both', 'poll'
#           loggedInRegex:               # String, regex pattern for determining if logged in
#           loggedOutRegex:              # String, regex pattern for determining if logged out
#           pollFrequency:               # Int, the poll frequency, only for 'poll' verification
#           pollUnits:                   # String, the poll units, one of 'requests', 'seconds', only for 'poll' verification
#           pollUrl:                     # String, the URL to poll, only for 'poll' verification
#           pollPostData:                # String, post dat to include in the poll, only for 'poll' verification
#           pollAdditionalHeaders:       # List of additional headers for poll request, only for 'poll' verification
#           - header:                    # The header name
#             value:                     # The header value
#       sessionManagement:
#         method:                        # String, one of 'cookie', 'http', 'script'
#         parameters:                    # List of 0 or more parameters - may include any required for scripts
#           script:                      # String, path to script, only for 'script' session management
#           scriptEngine:                # String, the name of the script engine to use, only for 'script' session management
#       technology:
#         exclude:                       # List of tech to exclude, as per https://www.zaproxy.org/techtags/ (just use last names)
#       users:                           # List of one or more users available to use for authentication
#       - name:                          # String, the name to be used by the jobs
#         credentials:                   # List of user credentials - may include any required for scripts
#           username:                    # String, the username to use when authenticating, vars supported
#           password:                    # String, the password to use when authenticating, vars supported
#   vars:                                # List of 0 or more custom variables to be used throughout the config file
#     myVarOne: CustomConfigVarOne       # Can be used as ${myVarOne} anywhere throughout the config
#     myVarTwo: ${myVarOne}.VarTwo       # Can refer other vars    
#   parameters:
#     failOnError: true                  # If set exit on an error         
#     failOnWarning: false               # If set exit on a warning
#     progressToStdout: true             # If set will write job progress to stdout