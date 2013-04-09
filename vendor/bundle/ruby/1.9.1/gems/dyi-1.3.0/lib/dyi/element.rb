# -*- encoding: UTF-8 -*-

# Copyright (c) 2009-2012 Sound-F Co., Ltd. All rights reserved.
#
# Author:: Mamoru Yuo
#
# This file is part of DYI.
#
# DYI is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# DYI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DYI.  If not, see <http://www.gnu.org/licenses/>.

#
module DYI

  # Abstract class that represents a element contained in the image.
  # @abstract
  # @since 1.0.0
  class Element
    extend AttributeCreator
    ID_REGEXP = /\A[:A-Z_a-z][\-\.0-9:A-Z_a-z]*\z/

    # Returns a title of the element.
    # @return [String] a title of the element
    # @since 1.1.1
    attr_accessor :title

    # Returns a description of the element.
    # @return [String] a description of the element
    # @since 1.1.1
    attr_accessor :description

    # Returns id for the element. If the element has no id yet, makes id and
    # returns it.
    # @return [String] id for the element
    def id
      @id ||= canvas && canvas.publish_shape_id
    end

    alias publish_id id

    # Returns id of the element. If the element has no id yet, returns nil.
    # @return [String] id for the element if it has id, nil if not
    def inner_id
      @id
    end

    # Sets id for the element.
    # @param [String] value id for the element
    # @return [String] id that is given
    # @raise [ArgumentError] value is empty or illegal format
    def id=(value)
      # TODO: veryfy that the id is unique.
      raise ArgumentError, "`#{value}' is empty" if value.to_s.size == 0
      raise ArgumentError, "`#{value}' is a illegal id" if value.to_s !~ ID_REGEXP
      @id = value.to_s
    end

    # Returns the canvas where the shape is drawn.
    # @return [Canvas] the canvas where the shape is drawn
    def canvas
      current_node = self
      loop do
        return current_node if current_node.nil? || current_node.root_element?
        current_node = current_node.parent
      end
    end

    # Returns an array of child elements.
    # @return [Array<Element>] an empty array
    def child_elements
      []
    end

    # Returns whether the element has reference of external file.
    # @return [Boolean] always false
    def include_external_file?
      false
    end

    # Returns whether the element has URI reference.
    # @return [Boolean] always false
    def has_uri_reference?
      false
    end
  end

  # Abstract class that represents a graphic element.
  # @abstract
  # @since 1.0.0
  class GraphicalElement < Element

    # Returns a CSS class attribute of the element.
    # @return [String] a class name or set of class names. If the elements has
    #   multiple class names, class names are separated by white space
    attr_reader :css_class

    CLASS_REGEXP = /\A[A-Z_a-z][\-0-9A-Z_a-z]*\z/

    # Sets a CSS class attribute.
    # @param [String] css_class a CSS class attribute
    # @see {#css_class}
    # @raise [ArgumentError] parameter 'css_class' is illegal class name
    def css_class=(css_class)
      return @css_class = nil if css_class.nil?
      classes = css_class.to_s.split(/\s+/)
      classes.each do |c|
        if c.to_s !~ CLASS_REGEXP
          raise ArgumentError, "`#{c}' is a illegal class-name"
        end
      end
      @css_class = classes.join(' ')
    end

    # Returns an array of CSS class names.
    # @return [Array<String>] an array of CSS class names
    def css_classes
      css_class.to_s.split(/\s+/)
    end

    # Adds a CSS class.
    # @param [String] css_class a CSS class name
    # @return [String, nil] value of parameter 'css_class' if successes to add
    #   a class, nil if failures
    # @raise [ArgumentError] parameter 'css_class' is illegal class name
    def add_css_class(css_class)
      if css_class.to_s !~ CLASS_REGEXP
        raise ArgumentError, "`#{css_class}' is a illegal class-name"
      end
      if css_classes.include?(css_class.to_s)
        return nil
      end
      @css_class = css_classes.push(css_class).join(' ')
      css_class
    end

    # Remove a CSS class.
    # @param [String] css_class a CSS class name that will be removed
    # @return [String, nil] value of parameter 'css_class' if successes to
    #   remove a class, nil if failures
    def remove_css_class(css_class)
      classes = css_classes
      if classes.delete(css_class.to_s)
        @css_class = classes.empty? ? nil : classes.join(' ')
        css_class
      else
        nil
      end
    end

    # Returns event listeners that is associated with the element.
    # @return [Hash] hash of event listeners
    def event_listeners
      @event_listeners ||= {}
    end

    # Sets an event to this element.
    # @param [Event] event an event that is set to the element
    # @return [String] id for this element
    def set_event(event)
      @events ||= []
      @events << event
      publish_id
    end

    # Returns whether an event is set to the element.
    # @return [Boolean] true if an event is set to the element, false otherwise
    def event_target?
      !(@events.nil? || @events.empty?)
    end

    # Registers event listeners on this element.
    # @param [Symbol] event_name an event name for which the user is registering
    # @param [Script::EcmaScript::EventListener, #to_s] listener an event listener which contains
    #   the methods to be called when the event occurs.
    def add_event_listener(event_name, listener)
      unless listener.respond_to?(:related_to)
        listener = DYI::Script::EcmaScript::EventListener.new(listener.to_s)
      end
      listener.related_to(DYI::Event.new(event_name, self))
      if event_listeners.key?(event_name)
        unless event_listeners[event_name].include?(listener)
          event_listeners[event_name] << listener
          canvas.add_script(listener)
        end
      else
        event_listeners[event_name] = [listener]
        canvas.add_script(listener)
      end
    end

    # Removes event listeners from this element.
    # @param [Symbol] event_name an event name for which the user is registering
    # @param [Script::SimpleScript] listener an event listener to be removed
    def remove_event_listener(event_name, listener)
      if event_listeners.key?(event_name)
        event_listeners[event_name].delete(listener)
      end
    end

    # @since 1.3.0
    def to_reused_source
      publish_id
      self
    end
  end
end
