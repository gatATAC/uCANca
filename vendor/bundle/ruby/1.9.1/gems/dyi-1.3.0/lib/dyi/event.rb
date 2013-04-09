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
# == Overview
#
# This file provides the DYI::Event class, which provides event supports for
# DYI.  The event becomes effective only when it is output by SVG format.
#
# See the documentation to the DYI::Length class for more details and
# examples of usage.

#
module DYI

  # Class representing a event.  The event becomes effective only when it is
  # output by SVG format.
  # @since 1.0.0
  class Event
=begin
    # IMPLEMENT_EVENTS abolished at version 1.3.0
    IMPLEMENT_EVENTS = [:focusin,:focusout,:click,:mousedown,:mouseup,
                        :mouseover,:mousemove,:mouseout,:load]
=end

    # @return [Symbol] event name
    attr_reader :event_name

    # @return [GraphicalElement] an element to which the event applied
    attr_reader :target

    # @param [Symbol] event_name event name, one of followings: focusin,
    #                            focusout, click, mousedown, mouseup, mouseover,
    #                            mousemove, mouseout, load
    # @param [GraphicalElement] target a element to which the event applied
    # @raise [ArgumentError] unknown event name is given
    def initialize(event_name, target)
      event_name = event_name.to_sym
      @event_name = event_name
      (@target = target).set_event(self)
    end

    # Sets a event listener.
    # @param [Script::EcmaScript::EventListener] event_listener a script to be
    #           called when the event occurs
    def set_listener(event_listener)
      target.add_event_listener(event_name, event_listener)
      event_listener.related_to(self)
    end

    # Removes a event listener.
    # @param [Script::EcmaScript::EventListener] event_listener a script that
    #           is removed
    def remove_listener(event_listener)
      target.remove_event_listener(event_name, event_listener)
      event_listener.unrelated_to(self)
    end

    # @since 1.0.1
    def ==(other)
      event_name == other.event_name && target == other.target
    end

    # @since 1.0.1
    def eql?(other)
      self == other
    end

    # @since 1.0.1
    def hash
      event_name.hash ^ target.hash
    end

    class << self

      # Creates a new focus-in event.
      # @param target (see Event#initialize)
      # @return [Event] a new focus-in event
      def focusin(target)
        new(:focusin, target)
      end

      # Creates a new focus-out event.
      # @param target (see Event#initialize)
      # @return [Event] a new focus-out event
      def focusout(target)
        new(:focusout, target)
      end

      # Creates a new click event.
      # @param target (see Event#initialize)
      # @return [Event] a new click event
      def click(target)
        new(:click, target)
      end

      # Creates a new mouse-down event.
      # @param target (see Event#initialize)
      # @return [Event] a new mouse-down event
      def mousedown(target)
        new(:mousedown, target)
      end

      # Creates a new mouse-up event.
      # @param target (see Event#initialize)
      # @return [Event] a new mouse-up event
      def mouseup(target)
        new(:mouseup, target)
      end

      # Creates a new mouse-over event.
      # @param target (see Event#initialize)
      # @return [Event] a new mouse-over event
      def mouseover(target)
        new(:mouseover, target)
      end

      # Creates a new mouse-move event.
      # @param target (see Event#initialize)
      # @return [Event] a new mouse-move event
      def mousemove(target)
        new(:mousemove, target)
      end

      # Creates a new mouse-out event.
      # @param target (see Event#initialize)
      # @return [Event] a new mouse-out event
      def mouseout(target)
        new(:mouseout, target)
      end

      # Creates a new load event.
      # @param target (see Event#initialize)
      # @return [Event] a new load event
      def load(target)
        new(:load, target)
      end
    end
  end
end
