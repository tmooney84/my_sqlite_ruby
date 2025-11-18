require 'csv'

=begin
PART I Describing scope of project

#SELECT QUERY
#INSERT QUERY
#UPDATE
#DELETE  

#1 Type of request
#2 Set settings
#3 Run
=end


class MySqliteRequest
  def initialize
    @type_of_request = :none
    @select_columns  = []
    @where_params    = []
    @table_name      = nil
    @order           = :asc
  end

  def from(table_name)
    @table_name = table_name
    self
  end

  def select(columns)
    if(columns.is_a?(Array))
      @select_columns += columns.collect { |elem| elem.to_s }
    else
      @select_columns << columns.to_s
    end
    self._setTypeOfRequest(:select) 
    self
  end

  def where(column_name, criteria)
    @where_params << [column_name, criteria]
    self
  end
  
  def join(column_on_db_a, filename_db_b, column_on_db_b)
    self
  end

  def order(order, column_name)
    self
  end

  def insert(table_name)
    self._setTypeOfRequest(:insert) 
    @table_name = table_name
    self
  end

  def values(data)
    self
  end

  def update(table_name)
    self._setTypeOfRequest(:update) 
    @table_name = table_name
    self
  end

  def set(data)
    self
  end

  def delete
    self._setTypeOfRequest(:update) 
    self
  end

  def print_select_type
    puts "Select Attributes #{@select_columns}"
    puts "Where Attributes #{@where_params}"
  end

  def print
    puts "Type of Request #{@type_of_request}"
    puts "Table Name #{@table_name}"
    if(@type_of_request == :select)
      print_select_type
    end
  end

  def run
    print
    if(@type_of_request == :select)
      _run_select 
    end
  end

  def _setTypeOfRequest(new_type)
    if(@type_of_request == :none or @type_of_request == new_type)
      @type_of_request = new_type
    else
      raise "Invalid: type of request already set to #{@type_of_request} (new type -> #{new_type})"
    end

  end

  def _run_select
    result = []
    CSV.parse(File.read(@table_name), headers: true).each do |row|
      @where_params.each do |where_attribute|
        if(row[where_attribute[0]] == where_attribute[1])
          result << @select_columns.slice(*select_columns)
        end
      end
    end
    result
  end
end

def _main()
  request = MySqliteRequest.new
  request = request.from('nba_player_data.csv')
  request = request.select('name')
  request = request.where('birth_state', 'Indiana')
  request.run
end

_main()
