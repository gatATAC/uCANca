# -*- encoding: UTF-8 -*-

require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/dyi')
require 'pp'

class PathCommandTest < Test::Unit::TestCase
  def setup
    @start_point = DYI::Coordinate.new([100,200])
    @start_command = DYI::Shape::Path::MoveCommand.new(false, nil, @start_point)
    @absolute_points = [[110,220],[80,180],[130,120],[60,200],[-30,100],[-85,165]].map{|pt| DYI::Coordinate.new(pt)}
    @relative_points = [[10,20],[-30,-40],[50,-60],[-70,80],[-90,-100],[-55,65]].map{|pt| DYI::Coordinate.new(pt)}

    @absolute_points_2 = [[70,160],[0,240],[-55,305]].map{|pt| DYI::Coordinate.new(pt)}
    @absolute_points_3 = [[150,140],[95,205]].map{|pt| DYI::Coordinate.new(pt)}
    @absolute_control_points_2 = [[110,220],[120,100],[-90,140]].map{|pt| DYI::Coordinate.new(pt)}
    @absolute_control_points_3 = [[110,220],[70,160],[80,220],[60,40]].map{|pt| DYI::Coordinate.new(pt)}
  end

  def test_absolute_move_command
    cmds = DYI::Shape::Path::MoveCommand.absolute_commands(nil, *([@start_point] + @absolute_points))
    assert_equal(7, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(i == 0 ? DYI::Shape::Path::MoveCommand : DYI::Shape::Path::LineCommand, c)
      assert(c.absolute?)
      assert_equal(@start_point, c.start_point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i-1], c.point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i-1], c.last_point)
      assert_equal(case i
                     when 0 then nil
                     when 1 then @start_point
                     else @absolute_points[i-2]
                   end, c.preceding_point)
    end
  end

  def test_relative_move_command
    cmds = DYI::Shape::Path::MoveCommand.relative_commands(nil, *([@start_point] + @relative_points))
    assert_equal(7, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(i == 0 ? DYI::Shape::Path::MoveCommand : DYI::Shape::Path::LineCommand, c)
      assert(i == 0 ? c.absolute? : c.relative?)
      assert_equal(i == 0 ? @start_point : @relative_points[i-1], c.point)
      assert_equal(@start_point, c.start_point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i-1], c.last_point)
      assert_equal(case i
                     when 0 then nil
                     when 1 then @start_point
                     else @absolute_points[i-2]
                   end, c.preceding_point)
    end
  end

  def test_absolute_line_command
    cmds = DYI::Shape::Path::LineCommand.absolute_commands(@start_command, *@absolute_points)
    assert_equal(6, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::LineCommand, c)
      assert(c.absolute?)
      assert_equal(@absolute_points[i], c.point)
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points[i], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i-1], c.preceding_point)
    end
  end

  def test_relative_line_command
    cmds = DYI::Shape::Path::LineCommand.relative_commands(@start_command, *@relative_points)
    assert_equal(6, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::LineCommand, c)
      assert(c.relative?)
      assert_equal(@relative_points[i], c.point)
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points[i], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i-1], c.preceding_point)
    end
  end

  def test_close_command
    pre_cmd = DYI::Shape::Path::LineCommand.absolute_commands(@start_command, *@absolute_points).last
    assert_raise(NoMethodError){DYI::Shape::Path::CloseCommand.absolute_commands(pre_cmd)}
    assert_raise(NoMethodError){DYI::Shape::Path::CloseCommand.relative_commands(pre_cmd)}

    cmds = DYI::Shape::Path::CloseCommand.commands(pre_cmd)
    assert_equal(1, cmds.size)
    cmd = cmds.first
    assert_nil(cmd.point)
    assert_equal(@start_point, cmd.start_point)
    assert_equal(@start_point, cmd.last_point)
    assert_equal(@absolute_points.last, cmd.preceding_point)
  end

  def test_absolute_curve_command
    cmds = DYI::Shape::Path::CurveCommand.absolute_commands(@start_command, *@absolute_points)
    assert_equal(2, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::CurveCommand, c)
      assert(c.absolute?)
      assert_equal(@absolute_points[i*3+2], c.point)
      assert_equal(@absolute_points[i*3,2], [c.control_point1,c.control_point2])
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points[i*3+2], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i*3-1], c.preceding_point)
    end
  end

  def test_relative_curve_command
    cmds = DYI::Shape::Path::CurveCommand.relative_commands(@start_command, *@relative_points)
    assert_equal(2, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::CurveCommand, c)
      assert(c.relative?)
      assert_equal(@relative_points[i*3+2], c.point)
      assert_equal(@relative_points[i*3,2], [c.control_point1,c.control_point2])
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points_3[i], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points_3[i-1], c.preceding_point)
    end
  end

  def test_absolute_shorthand_curve_command
#               [100,200],[110,220],[80,180],[130,120], [60,200],[-30,100],[-85,165]
    ctrl_pts = [[100,200],[110,220],[50,140],[130,120],[-10,280],[-30,100]].map{|pt| DYI::Coordinate.new(pt)}

    cmds = DYI::Shape::Path::ShorthandCurveCommand.absolute_commands(@start_command, *@absolute_points)
    assert_equal(3, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::ShorthandCurveCommand, c)
      assert(c.absolute?)
      assert_equal(@absolute_points[i*2+1], c.point)
      assert_equal(ctrl_pts[i*2,2], [c.control_point1,c.control_point2])
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points[i*2+1], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i*2-1], c.preceding_point)
    end
  end

  def test_relative_shorthand_curve_command
#           [100,200],[10,20],[-30,-40],[50,-60],  [-70,80],[-90,-100],[-55,65]
    ctrl_pts = [[0,0],[10,20],[-40,-60],[50,-60],[-120,140],[-90,-100]].map{|pt| DYI::Coordinate.new(pt)}

    cmds = DYI::Shape::Path::ShorthandCurveCommand.relative_commands(@start_command, *@relative_points)
    assert_equal(3, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::ShorthandCurveCommand, c)
      assert(c.relative?)
      assert_equal(@relative_points[i*2+1], c.point)
      assert_equal(ctrl_pts[i*2,2], [c.control_point1,c.control_point2])
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points_2[i], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points_2[i-1], c.preceding_point)
    end
  end

  def test_absolute_quadratic_curve_command
    cmds = DYI::Shape::Path::QuadraticCurveCommand.absolute_commands(@start_command, *@absolute_points)
    assert_equal(3, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::QuadraticCurveCommand, c)
      assert(c.absolute?)
      assert_equal(@absolute_points[i*2+1], c.point)
      assert_equal(@absolute_points[i*2], c.control_point)
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points[i*2+1], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i*2-1], c.preceding_point)
    end
  end

  def test_relative_quadratic_curve_command
    cmds = DYI::Shape::Path::QuadraticCurveCommand.relative_commands(@start_command, *@relative_points)
    assert_equal(3, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::QuadraticCurveCommand, c)
      assert(c.relative?)
      assert_equal(@relative_points[i*2+1], c.point)
      assert_equal(@relative_points[i*2], c.control_point)
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points_2[i], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points_2[i-1], c.preceding_point)
    end
  end

  def test_absolute_shorthand_quadratic_curve_command
#               [100,200],[110,220],[80,180],[130,120],  [60,200],[-30,100],[-85,165]
    ctrl_pts = [[100,200],[120,240],[40,120],[220,120],[-100,280],[40,-80]].map{|pt| DYI::Coordinate.new(pt)}

    cmds = DYI::Shape::Path::ShorthandQuadraticCurveCommand.absolute_commands(@start_command, *@absolute_points)
    assert_equal(6, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::ShorthandQuadraticCurveCommand, c)
      assert(c.absolute?)
      assert_equal(@absolute_points[i], c.point)
      assert_equal(ctrl_pts[i], c.control_point)
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points[i], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i-1], c.preceding_point)
    end
  end

  def test_relative_shorthand_quadratic_curve_command
#           [100,200],[10,20],[-30,-40],[50,-60], [-70,80],[-90,-100],[-55,65]
    ctrl_pts = [[0,0],[10,20],[-40,-60],  [90,0],[-160,80],[70,-180]].map{|pt| DYI::Coordinate.new(pt)}

    cmds = DYI::Shape::Path::ShorthandQuadraticCurveCommand.relative_commands(@start_command, *@relative_points)
    assert_equal(6, cmds.size)
    cmds.each_with_index do |c, i|
      assert_kind_of(DYI::Shape::Path::ShorthandQuadraticCurveCommand, c)
      assert(c.relative?)
      assert_equal(@relative_points[i], c.point)
      assert_equal(ctrl_pts[i], c.control_point)
      assert_equal(@start_point, c.start_point)
      assert_equal(@absolute_points[i], c.last_point)
      assert_equal(i == 0 ? @start_point : @absolute_points[i-1], c.preceding_point)
    end
  end
end
