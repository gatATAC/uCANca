class HoboMigration44 < ActiveRecord::Migration
  def self.up
    add_column :state_machines, :graphviz_link, :string, :default => "?cht=gv:neato&amp;chl=digraph{edge[fontsize=7];fontsize=11;nodesep=1;ranksep=1;sep=3;overlap=scale;"
    add_column :state_machines, :graphviz_size, :string, :default => "&amp;chs=500x500"
  end

  def self.down
    remove_column :state_machines, :graphviz_link
    remove_column :state_machines, :graphviz_size
  end
end
