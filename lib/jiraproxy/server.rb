require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'jiraproxy/namespace'
require 'jiraproxy/util'
require 'jiraSOAP'

class JIRAProxy::Server < Sinatra::Base
  
  before '/jira/*' do
    @auth = Rack::Auth::Basic::Request.new(request.env)
    validCredentials = @auth && @auth.provided? && @auth.basic? && @auth.credentials
    if !validCredentials
      headers 'WWW-Authenticate' => 'Basic realm="jiraproxy"'
      halt [ 401, 'Authorization Required' ]
    end
  end
  
  post '/jira/projects/:project/issues' do
    validate_parameter(params, :jira_url)
    issue = JIRA::Issue.new
    #required parameters
    #project
    validate_parameter(params, :project)
    issue.project_name = params[:project]
    #type
    validate_parameter(params, :type_id)
    issue.type_id = params[:type_id]
    #priority
    validate_parameter(params, :priority_id)
    issue.priority_id = params[:priority_id]
    
    #add "helper" parameters to allow processing of arrays
    helper_params = {}
    params.each do |key, value|
      if value.respond_to?('join')
        helper_params["#{key}_commas"] = value.join(', ')
        helper_params["#{key}_newline"] = value.join("\n")
      end
    end
    params.merge! helper_params
    
    #summary
    validate_parameter(params, :summary)
    issue.summary = JIRAProxy::Util.process_simple_template(params[:summary], params)
    #description
    validate_parameter(params, :description)
    issue.description = JIRAProxy::Util.process_simple_template(params[:description], params)

    @jira = JIRA::JIRAService.new(params[:jira_url])
    @jira.login(@auth.credentials[0], @auth.credentials[1])
    issue = @jira.create_issue_with_issue(issue)
    redirect_url = "/jira/projects/#{params[:project]}/issues.html"
    if params[:redirect_url]
      redirect_url = params[:redirect_url]
    end
    redirect redirect_url
  end

  helpers do
    def validate_parameter(params, key)
      if !params[key]
        halt "You must supply a valid value for #{key}"
      end
    end
  end
  
end


Rack::Handler::Thin.run(
  Rack::CommonLogger.new( \
    Rack::ShowExceptions.new( \
      JIRAProxy::Server.new)),
  :Port => 9200)