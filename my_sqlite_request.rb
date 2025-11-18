class MySqliteRequest
  def initialize
  end

  def from(table_name)
  end

  def select(array)
  end

  def where(column_name, criteria)
  end
  
  def join(column_on_db_a, filename_db_b, column_on_db_b)
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
