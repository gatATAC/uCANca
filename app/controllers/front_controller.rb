class FrontController < ApplicationController

  hobo_controller

  def index; end

  def summary
    if !current_user.administrator?
      redirect_to user_login_path
    end
  end

  def index
=begin
    # Generates a image using DYI
    require 'dyi'

    canvas = DYI::Canvas.new(200, 100)

    brush = DYI::Drawing::Brush.red_brush
    brush.draw_circle(canvas, [150, 60], 30)

    pen = DYI::Drawing::Pen.blue_pen(:width => 3)
    pen.draw_rectangle(canvas, [20, 10], 130, 70)

    canvas.save('image.svg')
    @canvas=canvas
=end
    end

  def search
    if params[:query]
      site_search(params[:query])
    end
  end

end
