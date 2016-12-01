require "../lib/xmlmc-rb"

#session = Xmlmc::Api::Session
kb = Xmlmc::Api::Knowledge_base

#session.analyst_logon('admin', '')
print kb.methods
#session.analyst_logoff