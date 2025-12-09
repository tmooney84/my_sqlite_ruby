require 'csv'

class MySqliteRequest
  def initialize
    @type_of_request    = :none
    @select_columns     = []
    @where_params       = []
    @insert_attributes  = []
    @update_attributes  = {}
    @join_params        = nil
    @order              = :asc
    @order_column       = nil 
    @table_name         = nil
  end

  def from(table_name)
    @table_name = table_name
    self
  end


  def select(*columns)
    columns.flatten.each do |col|
      @select_columns << col.to_s
    end

    self._setTypeOfRequest(:select)
    self
  end


  def where(column_name, criteria)
    @where_params << [column_name, criteria]
    self
  end
  
  def join(column_on_db_a, filename_db_b, column_on_db_b)
    col_a = column_on_db_a.split(".").last   # "team_id"
    col_b = column_on_db_b.split(".").last   # "team_id"
    @join_params = [col_a, filename_db_b, col_b] 
    self
  end

  def order(order, column_name)
    @order = order.to_sym
    @order_column = column_name.to_s
    self
  end

  def insert(table_name)
    self._setTypeOfRequest(:insert) 
    @table_name = table_name
    self
  end

  def values(data)
    if (@type_of_request == :insert)
      @insert_attributes = data
    else
      raise 'Wrong type of request to call values()'
    end
    self
  end

  def update(table_name)
    self._setTypeOfRequest(:update) 
    @table_name = table_name
    self
  end

  def set(data)
    if (@type_of_request == :update)
      @update_attributes = data
    else
      raise 'Wrong type of request to call set()'
    end
    self
  end

  def delete(table_name)
    self._setTypeOfRequest(:delete)
    @table_name = table_name
    self
  end
 
  def print_select_type
    puts "Select Attributes #{@select_columns}"
    puts "Where Attributes #{@where_params}"
    puts "Order By Attributes #{@order_column} #{@order}"
  end

  def print_insert_type
    puts "Insert Attributes #{@insert_attributes}"
  end

  def print_update_type
    puts "Update Attributes #{@update_attributes}"
    puts "Where Attributes #{@where_params}"
  end

  def print_delete_type
    puts "Where Attributes #{@where_params}"
  end
  
  def print
    puts "Type of Request #{@type_of_request}"
    puts "Table Name #{@table_name}"
    if(@type_of_request == :select)
      print_select_type
    elsif(@type_of_request == :insert)
      print_insert_type
    elsif(@type_of_request == :update)
      print_update_type
    elsif(@type_of_request == :delete)
      print_delete_type
    end
  end

  def run
    #print
    if(@type_of_request == :select)
      _run_select 
    elsif(@type_of_request == :insert)
      _run_insert
    elsif(@type_of_request == :update) 
      _run_update
    elsif(@type_of_request == :delete)
      _run_delete
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

  # JOIN SETUP ---------------------------------------------------
    join_column_a, join_filename, join_column_b =
      @join_params || [nil, nil, nil]

  # If a JOIN was declared, load the second CSV
    join_lookup = nil
    if join_filename
      join_lookup = {}

      CSV.parse(File.read(join_filename), headers: true).each do |join_row|
        key = join_row[join_column_b].to_s
        join_lookup[key] = join_row.to_hash
      end
    end

  # MAIN SELECT LOOP --------------------------------------------
    CSV.parse(File.read(@table_name), headers: true).each do |row|
      row_hash = row.to_hash

    # Perform JOIN (INNER JOIN)
      if join_lookup
        join_key = row_hash[join_column_a].to_s
        joined_row = join_lookup[join_key]

      # Skip rows that do not match join (INNER JOIN behavior)
        next unless joined_row

      # Merge columns from table B into table A row
        row_hash = row_hash.merge(joined_row)
      end

    # WHERE logic
      match =
        if @where_params.empty?
          true
        else
          @where_params.all? do |col, val|
            row_hash[col].to_s == val.to_s
          end
        end

      next unless match

    # SELECT logic
      if @select_columns == ["*"]
        result << row_hash
      else
        result << row_hash.slice(*@select_columns)
      end
    end

  # ORDER logic
    if @order_column
      result.sort_by! { |row| row[@order_column] }
      result.reverse! if @order == :desc
    end

    result
  end


  def _run_insert
    CSV.open(@table_name, 'a') do |csv|
      csv << @insert_attributes.values
    end
  end

  def _run_update
    table = CSV.table(@table_name)

    table.each do |row|
      match = @where_params.all? {|col, val| row[col.to_sym].to_s == val.to_s}
      
      if match || @where_params.empty?
        @update_attributes.each do |col, val|
          row[col.to_sym] = val
        end
      end
    end

    File.open(@table_name, 'w') { |f| f.write(table.to_csv) }
  end

  def _run_delete
    table = CSV.table(@table_name)

    table.delete_if do |row|
      @where_params.all? {|col, val| row[col.to_sym].to_s == val.to_s}
    end

    File.open(@table_name, 'w') { |f| f.write(table.to_csv) }
  end
end

def _main()

# ================================================================
# TESTING REQUEST LOGIC
# ================================================================

#SELECT * FROM db WHERE db.year_start = 1991;
  # request = MySqliteRequest.new
  # request = request.from('nba_player_data.csv')
  # request = request.select('name')
  # request = request.where('year_start', '1991')
  # p request.run
  # p request.run.count
  
  # request = MySqliteRequest.new
  # request = request.from('nba_player_data_light.csv')
  # request = request.select('name')
  # p request.run

#SELECT * FROM db WHERE db.year_start = 1991 ORDER BY name DESC;
  # request = MySqliteRequest.new
  # request = request.from('nba_player_data.csv')
  # request = request.select('name')
  # request = request.order('desc', 'name')
  # request = request.where('year_start', '1991')
  # p request.run
 
# INSERT INTO nba_player_data_light
#   (name, year_start, year_end, position, height, weight, birth_date, college)
# VALUES
#   ("Don Adams", "1971", "1977", "F", "6-6", "210", "November 27, 1947", "Northwestern University");

  # request = MySqliteRequest.new
  # request = request.insert('nba_player_data_light.csv')
  # request = request.values({"name" => "Don Adams","year_start" => "1971","year_end" => "1977","position" => "F","height" => "6-6","weight" => "210","birth_date" => "November 27, 1947","college" => "Northwestern University"})
  # request.run



################################ Need to finish SET

# UPDATE
# UPDATE nba_player_data_light
# SET
#   year_start = "1971",
#   year_end = "1977",
#   position = "F",
#   height = "6-6",
#   weight = "210",
#   birth_date = "November 27, 1947",
#   college = "Northwestern University"
# WHERE name = "Don Adams";

### if there is no WHERE, it updates all of the columns with the new info
  # request = MySqliteRequest.new
  # request = request.update('nba_player_data_light.csv')
  # request = request.set({
  #   "year_start" => "1971",
  #   "year_end"   => "1977",
  #   "position"   => "F",
  #   "height"     => "6-6",
  #   "weight"     => "210",
  #   "birth_date" => "November 27, 1947",
  #   "college"    => "Whatsamata U"
  # })
  # request = request.where("name", "Don Adams")
  # request.run



################################ Need to finish DELETE

# DELETE

# DELETE FROM nba_player_data_light
# WHERE name = "Don Adams";
  # request = MySqliteRequest.new
  # request = request.delete('nba_player_data_light.csv')
  # request = request.where("name", "Forest Able")
  # request.run


  # request = MySqliteRequest.new
  # rows = request
  #   .from("nba_player.csv")
  #   .select("name", "team_name")
  #   .join("team_id", "teams.csv", "team_id")
  #   .run

  # p rows


end

_main()

