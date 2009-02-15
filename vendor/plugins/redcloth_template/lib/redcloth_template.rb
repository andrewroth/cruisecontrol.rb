# $Id: redcloth_template.rb 39 2008-07-24 20:30:11Z toupeira $

require 'redcloth'

module RedCloth
  class Template < ActionView::TemplateHandlers::ERB
    def render(template)
      RedCloth.new(super).to_html
    end
  end
end
