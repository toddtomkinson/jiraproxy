$:.unshift File.join(File.dirname(__FILE__), '..')
require 'jiraproxytest'
require 'jiraproxy/util'

class JIRAProxy::UtilTest < Test::Unit::TestCase
  
  def test_process_simple_template_default
    template = 'this %a% my %b%'
    assert_equal('this is my template', JIRAProxy::Util.process_simple_template(template, { :a => 'is', :b => 'template' }))
  end
  
  def test_process_simple_template_custom_boundary
    template = 'this *a* my *b*'
    assert_equal('this is my template', JIRAProxy::Util.process_simple_template(template, { :a => 'is', :b => 'template' }, '*'))
  end
  
end