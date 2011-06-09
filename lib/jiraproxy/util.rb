require "jiraproxy/namespace"

class JIRAProxy::Util
  
  # VERY simple rdoc like templating.
  def self.process_simple_template(template, hash, boundary = '%')
    result = template.clone
    hash.each do |key, value|
      if result.match "\\#{boundary}#{key}\\#{boundary}"
        result.gsub!("#{boundary}#{key}#{boundary}", value)
      end
    end
    result
  end
  
end