require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def column_names
    DB[:conn].execute("pragma table_info #{table_name} ")
  end
  
end
