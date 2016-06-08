module FrontHelper
  
  def project_tree_options_for_select(projects, options = {})
    s = ''
    projects.each do |project|
      tag_options = {:value => project.id}
      if project == options[:selected] || (options[:selected].respond_to?(:include?) && options[:selected].include?(project))
        tag_options[:selected] = 'selected'
      else
        tag_options[:selected] = nil
      end
      tag_options.merge!(yield(project)) if block_given?
      s << content_tag('option', h(project), tag_options)
    end
    s.html_safe
  end

  def req_doc_tree_options_for_select(req_docs, options = {})
    s = ''
    req_docs.each do |req_doc|
      tag_options = {:value => req_doc.id}
      if req_doc == options[:selected] || (options[:selected].respond_to?(:include?) && options[:selected].include?(req_doc))
        tag_options[:selected] = 'selected'
      else
        tag_options[:selected] = nil
      end
      tag_options.merge!(yield(req_doc)) if block_given?
      s << content_tag('option', h(req_doc), tag_options)
    end
    s.html_safe
  end
  
end
